// ***************************************************************
//  madScreenShot.pas         version:  1.0b  ·  date: 2004-05-01
//  -------------------------------------------------------------
//  create a screen shot as compressed png
//  -------------------------------------------------------------
//  Copyright (C) 1999 - 2004 www.madshi.net, All Rights Reserved
// ***************************************************************

// 2004-05-01 1.0b mouse cursor is now added to the bitmap
// 2004-03-14 1.0a (1) if sizeOf(256col) < sizeOf(16gray) then result := 256col
//                 (2) removed gray dithering, optimized gray palette
//                 (3) significant speedup if the desktop screen depth is 32bit
// 2004-03-07 1.0  initial version

unit madScreenShot;

{$I mad.inc}

interface

// ***************************************************************

// which mode shall be used for screen shotting?
type TScreenShotType = (st256Colors, st16Grays, st50kb, st100kb, st200kb, st300kb);

// create a screen shot of the current full screen in form of a png file
// the png file content is returned as a binary string
function CreateScreenShotPng (screenShotType: TScreenShotType) : string;

// ***************************************************************

implementation

uses Windows, madZip, madTypes;

// ***************************************************************

function CreateScreenShotPng(screenShotType: TScreenShotType) : string;
type TPalette = array [0..255] of packed record r, g, b : byte; end;

  function CreatePng(width, height: dword; palette, bitmap: string) : string;

    function SwapDword(dw: dword) : dword;
    begin
      result := (dw shr 24)               +
                (dw shr  8) and $0000ff00 +
                (dw shl  8) and $00ff0000 +
                (dw shl 24);
    end;

    function GetPngHeader : string;
    var pdw : ^dword;
    begin
      SetLength(result, 8);
      if length(palette) = sizeOf(TPalette) then
           result := result + #$08#$03#00#00#00
      else result := result + #$04#$03#00#00#00;
      pointer(pdw) := pointer(result);
      pdw^ := SwapDword(width);
      inc(pdw);
      pdw^ := SwapDword(height);
    end;

    function CompressBitmap : string;

      function Adler32(buf: PByte; len: integer) : dword;
      const Base = dword(65521); // largest prime smaller than 65536
            NMAX = 3854;         // Code with signed 32 bit integer
      var c1, c2 : dword;
          i1     : integer;
      begin
        c1 := 1;
        c2 := 0;
        while len > 0 do begin
          if len < NMAX then
               i1 := len
          else i1 := NMAX;
          dec(len, i1);
          while i1 > 0 do begin
            inc(c1, buf^);
            inc(c2, c1);
            inc(buf);
            dec(i1);
          end;
          c1 := c1 mod Base;
          c2 := c2 mod Base;
        end;
        result := (c2 shl 16) or c1;
      end;

    var i1  : integer;
        pdw : ^dword;
    begin
      SetLength(result, length(bitmap) * 11 div 10 + 12);
      i1 := Compress(pointer(bitmap), pointer(result), length(bitmap), length(result));
      if i1 > 0 then begin
        SetLength(result, i1);
        result := #$78#$01 + result + 'adlr';
        pointer(pdw) := pchar(result) + length(result) - 4;
        pdw^ := SwapDword(Adler32(pointer(bitmap), length(bitmap)));
      end;
    end;

    procedure AddPngPart(var png: string; name, data: string);
    var pdw : ^dword;
        crc : dword;
    begin
      png := png + 'len ' + name + data + 'crc ';
      pointer(pdw) := pchar(png) + Length(png) - 4 - Length(data) - 8;
      crc := not UpdateCrc32($ffffffff, pointer(dword(pdw) + 4)^, 4 + Length(data));
      pdw^ := SwapDword(Length(data));
      pointer(pdw) := pchar(png) + Length(png) - 4;
      pdw^ := SwapDword(crc);
    end;

  begin
    result := #$89#$50#$4e#$47#$0d#$0a#$1a#$0a;
    AddPngPart(result, 'IHDR', GetPngHeader);
    if palette <> '' then
      AddPngPart(result, 'PLTE', palette);
    AddPngPart(result, 'IDAT', CompressBitmap);
    AddPngPart(result, 'IEND', '');
  end;

  procedure FindOptimalPalette(bmp: pchar; pixels: integer; var palette: TPalette; noOfCols: integer);
  //  C Implementation of Wu's Color Quantizer (v. 2)
  //  (see Graphics Gems vol. II, pp. 126-133)
  //
  //    Author:	Xiaolin Wu
  //    Dept. of Computer Science
  //    Univ. of Western Ontario
  //    London, Ontario N6A 5B7
  //    wu@csd.uwo.ca
  //
  //  Algorithm: Greedy orthogonal bipartition of RGB space for variance
  //       minimization aided by inclusion-exclusion tricks.
  //       For speed no nearest neighbor search is done. Slightly
  //       better performance can be expected by more sophisticated
  //       but more expensive versions.
  //
  // The author thanks Tom Lane at Tom_Lane@G.GP.CS.CMU.EDU for much of
  // additional documentation and a cure to a previous bug.
  //
  // Free to distribute, comments and suggestions are appreciated.
  type
    TADouble  = array [0..maxInt shr 3 - 1] of double;
    TPADouble = ^TADouble;
    TDir = (dRed, dGreen, dBlue);
    TBox = record
      r0, r1 : integer;  // x0 = min value, exclusive
      g0, g1 : integer;  // x1 = max value, inclusive
      b0, b1 : integer;
      vol    : integer;
    end;
    T333Integer = array [0..32, 0..32, 0..32] of integer;
    T333Double  = array [0..32, 0..32, 0..32] of double;
  var m2             : ^T333Double;
      wt, mr, mg, mb : ^T333Integer;

    procedure Hist3d(wt, mr, mg, mb: TPAInteger; m2: TPADouble);
    // build 3-D color histogram of counts, r/g/b, c^2
    var ind, r, g, b  : integer;
        inr, ing, inb : integer;
        table         : array [0..255] of integer;
        i             : integer;
    begin
      for i := 0 to 255 do
        table[i] := i * i;
      for i := 0 to pixels - 1 do begin
        r := byte(bmp[2]);
        g := byte(bmp[1]);
        b := byte(bmp[0]);
        inc(bmp, 4);
        inr := r shr 3 + 1;
        ing := g shr 3 + 1;
        inb := b shr 3 + 1;
        ind := inr shl 10 + inr shl 6 + inr + ing shl 5 + ing + inb;  // ind := [inr][ing][inb]
        inc(wt[ind]);
        inc(mr[ind], r);
        inc(mg[ind], g);
        inc(mb[ind], b);
        m2[ind] := m2[ind] + (table[r] + table[g] + table[b]);
      end;
    end;

    procedure M3d(wt, mr, mg, mb: TPAInteger; m2: TPADouble);
    // compute cumulative moments.
    var ind1, ind2                   : word;
        i, r, g, b                   : byte;
        line, line_r, line_g, line_b : integer;
        area, area_r, area_g, area_b : array [0..32] of integer;
        line2                        : double;
        area2                        : array [0..32] of double;
    begin
      for r := 1 to 32 do begin
        for i := 0 to 32 do begin
          area   [i] := 0;
          area_r [i] := 0;
          area_g [i] := 0;
          area_b [i] := 0;
          area2  [i] := 0;
        end;
        for g := 1 to 32 do begin
          line   := 0;
          line_r := 0;
          line_g := 0;
          line_b := 0;
          line2  := 0;
          for b := 1 to 32 do begin
            ind1 := r shl 10 + r shl 6 + r + g shl 5 + g + b;  // ind1 := [r][g][b]
            line := line + wt[ind1];
            line_r := line_r + mr[ind1];
            line_g := line_g + mg[ind1];
            line_b := line_b + mb[ind1];
            line2  := line2 + m2[ind1];
            area[b] := area[b] + line;
            area_r[b] := area_r[b] + line_r;
            area_g[b] := area_g[b] + line_g;
            area_b[b] := area_b[b] + line_b;
            area2[b] := area2[b] + line2;
            ind2 := ind1 - 1089;  // ind2 := [r-1][g][b]
            wt[ind1] := wt[ind2] + area[b];
            mr[ind1] := mr[ind2] + area_r[b];
            mg[ind1] := mg[ind2] + area_g[b];
            mb[ind1] := mb[ind2] + area_b[b];
            m2[ind1] := m2[ind2] + area2[b];
          end;
        end;
      end;
    end;

    function Vol(var cube: TBox; var mmt: T333Integer) : integer;
    // Compute sum over a box of any given statistic
    begin
      result := + mmt[cube.r1, cube.g1, cube.b1]
                - mmt[cube.r1, cube.g1, cube.b0]
                - mmt[cube.r1, cube.g0, cube.b1]
                + mmt[cube.r1, cube.g0, cube.b0]
                - mmt[cube.r0, cube.g1, cube.b1]
                + mmt[cube.r0, cube.g1, cube.b0]
                + mmt[cube.r0, cube.g0, cube.b1]
                - mmt[cube.r0, cube.g0, cube.b0];
    end;

    function Bottom(var cube: TBox; dir: TDir; var mmt: T333Integer) : integer;
    // Compute part of Vol(cube, mmt) that doesn't depend on r1, g1, or b1 (depending on dir)
    begin
      case dir of
        dRed   : result := - mmt[cube.r0, cube.g1, cube.b1]
                           + mmt[cube.r0, cube.g1, cube.b0]
                           + mmt[cube.r0, cube.g0, cube.b1]
                           - mmt[cube.r0, cube.g0, cube.b0];
        dGreen : result := - mmt[cube.r1, cube.g0, cube.b1]
                           + mmt[cube.r1, cube.g0, cube.b0]
                           + mmt[cube.r0, cube.g0, cube.b1]
                           - mmt[cube.r0, cube.g0, cube.b0];
        else     result := - mmt[cube.r1, cube.g1, cube.b0]
                           + mmt[cube.r1, cube.g0, cube.b0]
                           + mmt[cube.r0, cube.g1, cube.b0]
                           - mmt[cube.r0, cube.g0, cube.b0];
      end;
    end;

    function Top(var cube: TBox; dir: TDir; pos: integer; var mmt: T333Integer) : integer;
    // Compute remainder of Vol(cube, mmt), substituting pos for r1, g1, or b1 (depending on dir)
    begin
      case dir of
        dRed   : result := + mmt[pos, cube.g1, cube.b1]
                           - mmt[pos, cube.g1, cube.b0]
                           - mmt[pos, cube.g0, cube.b1]
                           + mmt[pos, cube.g0, cube.b0];
        dGreen : result := + mmt[cube.r1, pos, cube.b1]
                           - mmt[cube.r1, pos, cube.b0]
                           - mmt[cube.r0, pos, cube.b1]
                           + mmt[cube.r0, pos, cube.b0];
        else     result := + mmt[cube.r1, cube.g1, pos]
                           - mmt[cube.r1, cube.g0, pos]
                           - mmt[cube.r0, cube.g1, pos]
                           + mmt[cube.r0, cube.g0, pos];
      end;
    end;

    function Var_(var cube: TBox) : double;
    // Compute the weighted variance of a box
    var dr, dg, db, xx : double;
    begin
      dr := Vol(cube, mr^);
      dg := Vol(cube, mg^);
      db := Vol(cube, mb^);
      xx := + m2[cube.r1, cube.g1, cube.b1]
            - m2[cube.r1, cube.g1, cube.b0]
            - m2[cube.r1, cube.g0, cube.b1]
            + m2[cube.r1, cube.g0, cube.b0]
            - m2[cube.r0, cube.g1, cube.b1]
            + m2[cube.r0, cube.g1, cube.b0]
            + m2[cube.r0, cube.g0, cube.b1]
            - m2[cube.r0, cube.g0, cube.b0];
      result := xx - (dr * dr + dg * dg + db * db) / Vol(cube, wt^);
    end;

    function Maximize(var cube: TBox; dir: TDir; first, last: integer; var cut: integer;
                      whole_r, whole_g, whole_b, whole_w: integer) : double;
    // We want to minimize the sum of the variances of two subboxes.
    // The sum(c^2) terms can be ignored since their sum over both subboxes
    // is the same (the sum for the whole box) no matter where we split.
    // The remaining terms have a minus sign in the variance formula,
    // so we drop the minus sign and MAXIMIZE the sum of the two terms.
    var half_r, half_g, half_b, half_w : integer;
        base_r, base_g, base_b, base_w : integer;
        i                              : integer;
        temp1, temp2, max              : double;
    begin
      base_r := Bottom(cube, dir, mr^);
      base_g := Bottom(cube, dir, mg^);
      base_b := Bottom(cube, dir, mb^);
      base_w := Bottom(cube, dir, wt^);
      max := 0.0;
      cut := -1;
      for i := first to last - 1 do begin
        half_r := base_r + Top(cube, dir, i, mr^);
        half_g := base_g + Top(cube, dir, i, mg^);
        half_b := base_b + Top(cube, dir, i, mb^);
        half_w := base_w + Top(cube, dir, i, wt^);
        // now half_x is sum over lower half of box, if split at i
        if half_w = 0 then   // subbox could be empty of pixels!
          continue;          // never split into an empty box
        temp1 := half_r * half_r;
        temp1 := temp1 + half_g * half_g;
        temp1 := temp1 + half_b * half_b;
        temp1 := temp1 / half_w;
        half_r := whole_r - half_r;
        half_g := whole_g - half_g;
        half_b := whole_b - half_b;
        half_w := whole_w - half_w;
        if half_w = 0 then   // subbox could be empty of pixels!
          continue;          // never split into an empty box
        temp2 := half_r * half_r;
        temp2 := temp2 + half_g * half_g;
        temp2 := temp2 + half_b * half_b;
        temp2 := temp2 / half_w;
        temp1 := temp1 + temp2;
        if temp1 > max then begin
          max := temp1;
          cut := i;
        end;
      end;
      result := max;
    end;

    function Cut(var set1, set2: TBox) : boolean;
    var dir                                : TDir;
        cutr, cutg, cutb                   : integer;
        maxr, maxg, maxb                   : double;
        whole_r, whole_g, whole_b, whole_w : integer;
    begin
      whole_r := Vol(set1, mr^);
      whole_g := Vol(set1, mg^);
      whole_b := Vol(set1, mb^);
      whole_w := Vol(set1, wt^);
      maxr := Maximize(set1, dRed,   set1.r0 + 1, set1.r1, cutr, whole_r, whole_g, whole_b, whole_w);
      maxg := Maximize(set1, dGreen, set1.g0 + 1, set1.g1, cutg, whole_r, whole_g, whole_b, whole_w);
      maxb := Maximize(set1, dBlue,  set1.b0 + 1, set1.b1, cutb, whole_r, whole_g, whole_b, whole_w);
      if (maxr >= maxg) and (maxr >= maxb) then begin
        dir := dRed;
        if cutr < 0 then begin
          result := false;  // can't split the box
          exit;
        end;
      end else
        if (maxg >= maxr) and (maxg >= maxb) then
          dir := dGreen
        else
          dir := dBlue;
      set2.r1 := set1.r1;
      set2.g1 := set1.g1;
      set2.b1 := set1.b1;
      case dir of
        dRed   : begin
                   set1.r1 := cutr;
                   set2.r0 := cutr;
                   set2.g0 := set1.g0;
                   set2.b0 := set1.b0;
                 end;
        dGreen : begin
                   set1.g1 := cutg;
                   set2.g0 := cutg;
                   set2.r0 := set1.r0;
                   set2.b0 := set1.b0;
                 end;
        else     begin
                   set1.b1 := cutb;
                   set2.b0 := cutb;
                   set2.r0 := set1.r0;
                   set2.g0 := set1.g0;
                 end;
      end;
      set1.vol := (set1.r1 - set1.r0) * (set1.g1 - set1.g0) * (set1.b1 - set1.b0);
      set2.vol := (set2.r1 - set2.r0) * (set2.g1 - set2.g0) * (set2.b1 - set2.b0);
      result := true;
    end;

  var cube : array of TBox;
      next : integer;
      i, weight, k : integer;
      vv   : array of double;
      temp : double;
  begin
    GetMem(m2, sizeOf(m2^)); ZeroMemory(m2, sizeOf(m2^));
    GetMem(wt, sizeOf(wt^)); ZeroMemory(wt, sizeOf(wt^));
    GetMem(mr, sizeOf(mr^)); ZeroMemory(mr, sizeOf(mr^));
    GetMem(mg, sizeOf(mg^)); ZeroMemory(mg, sizeOf(mg^));
    GetMem(mb, sizeOf(mb^)); ZeroMemory(mb, sizeOf(mb^));
    SetLength(cube, 256);
    SetLength(vv,   256);
    Hist3d(pointer(wt), pointer(mr), pointer(mg), pointer(mb), pointer(m2));
    M3d   (pointer(wt), pointer(mr), pointer(mg), pointer(mb), pointer(m2));
    cube[0].r0 := 0;
    cube[0].g0 := 0;
    cube[0].b0 := 0;
    cube[0].r1 := 32;
    cube[0].g1 := 32;
    cube[0].b1 := 32;
    next := 0;
    i := 1;
    while i < noOfCols do begin
      if Cut(cube[next], cube[i]) then begin
        if cube[next].vol > 1 then
             vv[next] := Var_(cube[next])
        else vv[next] := 0.0;
        if cube[i].vol > 1 then
             vv[i] := Var_(cube[i])
        else vv[i] := 0.0;
      end else begin
        vv[next] := 0.0;
        dec(i);
      end;
      next := 0;
      temp := vv[0];
      for k := 1 to i do
        if vv[k] > temp then begin
          temp := vv[k];
          next := k;
        end;
      if temp <= 0.0 then begin
        noOfCols := i + 1;
        break;
      end;
      inc(i);
    end;
    FreeMem(m2);
    for k := 0 to noOfCols - 1 do begin
      weight := Vol(cube[k], wt^);
      if weight <> 0 then begin
        palette[k].r := Vol(cube[k], mr^) div weight;
        palette[k].g := Vol(cube[k], mg^) div weight;
        palette[k].b := Vol(cube[k], mb^) div weight;
      end;
    end;
    FreeMem(wt);
    FreeMem(mr);
    FreeMem(mg);
    FreeMem(mb);
  end;

  function InitColorLookup : TDASmallInt;
  var i1 : integer;
  begin
    SetLength(result, 1 shl 15);
    for i1 := 0 to high(result) do
      result[i1] := -1;
  end;

  function ColorLookup(const lookup: TDASmallInt; const pal: TPalette; r, g, b: byte) : byte;
  var i1, i2, i3, i4 : integer;
  begin
    i1 := r shr 3 + (g and $f8) shl 2 + (b and $f8) shl 7;
    if lookup[i1] = -1 then begin
      i3 := maxInt;
      for i2 := 0 to 255 do begin
        i4 := abs(r - pal[i2].r) + abs(g - pal[i2].g) + abs(b - pal[i2].b);
        if i4 < i3 then begin
          lookup[i1] := i2;
          i3 := i4;
        end;
      end;
    end;
    result := lookup[i1];
  end;

  function GetGrayPal(const values: array of byte) : string;
  var i1, i2 : integer;
  begin
    SetLength(result, 3 * length(values) + 3);
    i2 := 0;
    for i1 := 0 to length(values) do
      with TPalette(pointer(result)^)[i1] do begin
        r := i2;
        g := i2;
        b := i2;
        if i1 < length(values) then
          inc(i2, values[i1]);
      end;
  end;

  function InitGrayLookup : TDASmallInt;
  var i1 : integer;
  begin
    SetLength(result, 256);
    for i1 := 0 to high(result) do
      result[i1] := -1;
  end;

  function GrayLookup(const lookup: TDASmallInt; const pal: TPalette; value: byte) : byte;
  var i2, i3, i4 : integer;
  begin
    if lookup[value] = -1 then begin
      i3 := maxInt;
      for i2 := 0 to 15 do begin
        i4 := abs(value - pal[i2].r);
        if i4 < i3 then begin
          lookup[value] := i2;
          i3 := i4;
        end;
      end;
    end;
    result := lookup[value];
  end;

  procedure DrawCursor(dc: dword);
  var ci  : TCursorInfo;
      gci : function (var ci: TCursorInfo) : bool; stdcall;
      wnd : dword;
      tid : dword;
      ii  : TIconInfo;
  begin
    ZeroMemory(@ci, sizeOf(ci));
    ci.cbSize := sizeOf(ci);
    gci := GetProcAddress(GetModuleHandle(user32), 'GetCursorInfo');
    if (@gci = nil) or (not gci(ci)) then
      if GetCursorPos(ci.ptScreenPos) then begin
        wnd := WindowFromPoint(ci.ptScreenPos);
        if wnd <> 0 then
             tid := GetWindowThreadProcessID(wnd, nil)
        else tid := 0;
        if tid <> 0 then
          AttachThreadInput(GetCurrentThreadID, tid, true);
        ci.hCursor := GetCursor;
        if tid <> 0 then
          AttachThreadInput(GetCurrentThreadID, tid, false);
      end;
    if (ci.hCursor <> 0) and (ci.flags and CURSOR_SHOWING <> 0) then begin
      if GetIconInfo(ci.hCursor, ii) then begin
        DeleteObject(ii.hbmMask);
        DeleteObject(ii.hbmColor);
        dec(ci.ptScreenPos.X, ii.xHotSpot);
        dec(ci.ptScreenPos.Y, ii.yHotSpot);
      end;
      DrawIconEx(dc, ci.ptScreenPos.X, ci.ptScreenPos.Y, ci.hCursor, 0, 0, 0, 0, DI_NORMAL);
    end;
  end;

const SM_XVIRTUALSCREEN  = 76;
      SM_YVIRTUALSCREEN  = 77;
      SM_CXVIRTUALSCREEN = 78;
      SM_CYVIRTUALSCREEN = 79;
      SM_CMONITORS       = 80;
var sdc, bdc   : dword;
    bmp, obmp  : dword;
    bi         : TBitmapInfo;
    ix, iy     : integer;
    iw, ih     : integer;
    bits       : pointer;
    src, dst   : pchar;
    bmpBuf     : string;
    palBuf     : string;
    i1, i2, i3 : integer;
    b1         : boolean;
    lookup     : TDASmallInt;
    s1         : string;
begin
  result := '';
  lookup := nil;
  sdc := CreateDC('DISPLAY', nil, nil, nil);
  if sdc <> 0 then begin
    if GetSystemMetrics(SM_CMONITORS) > 0 then begin
      ix := GetSystemMetrics(SM_XVIRTUALSCREEN);
      iy := GetSystemMetrics(SM_YVIRTUALSCREEN);
      iw := GetSystemMetrics(SM_CXVIRTUALSCREEN);
      ih := GetSystemMetrics(SM_CYVIRTUALSCREEN);
    end else begin
      ix := 0;
      iy := 0;
      iw := GetDeviceCaps(sdc, HORZRES);
      ih := GetDeviceCaps(sdc, VERTRES);
    end;
    bdc := CreateCompatibleDC(sdc);
    if bdc <> 0 then begin
      ZeroMemory(@bi, sizeOf(bi));
      with bi.bmiHeader do begin
        biSize     := sizeOf(bi.bmiHeader);
        biWidth    := iw;
        biHeight   := -ih;
        biPlanes   := 1;
        biBitCount := 32;
      end;
      bits := nil;
      bmp := CreateDIBSection(0, bi, DIB_RGB_COLORS, pointer(bits), 0, 0);
      if (bmp <> 0) and (bits <> nil) then begin
        obmp := SelectObject(bdc, bmp);
        if BitBlt(bdc, 0, 0, iw, ih, sdc, ix, iy, SRCCOPY) then begin
          DrawCursor(bdc);
          if screenShotType <> st16Grays then begin
            src := bits;
            lookup := InitColorLookup;
            SetLength(palBuf, sizeOf(TPalette));
            FindOptimalPalette(src, iw * ih, TPalette(pointer(palBuf)^), 256);
            SetLength(bmpBuf, iw * ih + ih);
            dst := pointer(bmpBuf);
            for i1 := 0 to ih - 1 do begin
              dst^ := #0;
              inc(dst);
              for i2 := 0 to iw - 1 do begin
                byte(dst^) := ColorLookup(lookup, TPalette(pointer(palBuf)^),
                                          byte(src[2]), byte(src[1]), byte(src[0]));
                inc(dst);
                inc(src, 4);
              end;
            end;
            result := CreatePng(iw, ih, palBuf, bmpBuf);
          end;
          b1 := result = '';
          if not b1 then
            case screenShotType of
              st50kb  : if length(result) >  50 * 1024 then b1 := true;
              st100kb : if length(result) > 100 * 1024 then b1 := true;
              st200kb : if length(result) > 200 * 1024 then b1 := true;
              st300kb : if length(result) > 300 * 1024 then b1 := true;
            end;
          if b1 then begin
            src := bits;
            for i1 := 1 to iw * ih do begin
              i3 := (integer(byte(src[2])) * 77 + integer(byte(src[1])) * 151 + integer(byte(src[0])) * 28) shr 8;
              byte(src[0]) := i3;
              byte(src[1]) := i3;
              byte(src[2]) := i3;
              inc(src, 4);
            end;
            src := bits;
            lookup := InitGrayLookup;
            palBuf := GetGrayPal([28, 24, 21, 19, 17, 16, 15, 15, 15, 15, 14, 14, 14, 14, 14]);
            SetLength(bmpBuf, (iw * ih) div 2 + ih);
            dst := pointer(bmpBuf);
            for i1 := 0 to ih - 1 do begin
              dst^ := #0;
              inc(dst);
              for i2 := 0 to iw - 1 do begin
                i3 := GrayLookup(lookup, TPalette(pointer(palBuf)^), byte(src[0]));
                if odd(i2) then
                     byte(dst^) := byte(dst^) and $f0 + i3
                else byte(dst^) := i3 shl 4;
                if odd(i2) then
                  inc(dst);
                inc(src, 4);
              end;
            end;
            s1 := CreatePng(iw, ih, palBuf, bmpBuf);
            if (s1 <> '') and ((result = '') or (Length(s1) < Length(result))) then
              result := s1;
          end;
        end;
        SelectObject(bdc, obmp);
        DeleteObject(bmp);
      end;
      DeleteDC(bdc);
    end;
    DeleteDC(sdc);
  end;
end;

// ***************************************************************

initialization
  // make sure that Delphi's smart linker doesn't remove our code
  // so madExcept can access it later at runtime
  // we do it this way because the snap shot code costs about 12 KB
  // if madExcept would directly link to the code, those 12 KB would be added
  // to each and every madExcept enabled project
  // the way I've solved it the 12 KB are only added if you enable screen shots
  // in the madExcept settings for your project
  if @CreateScreenShotPng = nil then ;
end.