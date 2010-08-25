{:: This unit defines the functionality of the embedded images.
    It is not linked into the RTF engine which makes it necessary to add the
    unit explicitely to a project which uses images.
    The standard TWPObject already knows how to work with bitmap and
    metafile data - in this unit mainly the loading and saving
    is optimized. So, if you need to change the way objects are saved
    you can modify this unit. }

unit WPOBJ_Image;

//******************************************************************************
// WPTools V5 + 6 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPOBJImage - WPTools 5 Embedded Images
//
// Optional graphics libraries are used when this compiler symbols are defined
// PNGLIB: Support for PNGLib http://pngdelphi.sourceforge.net/
// GIFIMG: Support for GifImage http://home20.inet.tele.dk/tolderlund/delphi/
// GRAPHICEX: PNG and GIF with GraphicEx : http://www.soft-gems.net/
//
// Note: You can define a compiler symbol in the option dialog of a project.
// We recommend to use PNGLib!
//
// You can compress the images for file saving using the Compress method:
// procedure TForm1.WPRichText1PrepareImageforSaving(
//    RTFData: TWPRTFDataCollection; Writer: TWPCustomTextWriter;
//    TextObject: TWPTextObj; var DontSave: Boolean);
// begin
//   if (TextObject.IsImage) then TextObject.ObjRef.Compress;
// end;
//
//******************************************************************************
// 18.1.2008
//******************************************************************************

{$I WPINC.INC}

// GraphicEx cannot be used together with PNGLib and GifImage

{$IFDEF GIFIMG}{$IFDEF PNGIMG}{$UNDEF GRAPHICEX}{$ENDIF}{$ENDIF}

// Activate this define to use the Delphi JPEG support. (Default)

{$DEFINE USEJPEG}

{-$UNDEF PNGIMG}

// Inform about the use ...
{$IFNDEF VER130}
{$IFDEF GRAPHICEX}
{$MESSAGE Warn '*** GraphicEx included due to compiler symbol "GRAPHICEX"'}
{$ENDIF}
{$IFDEF GIFIMG}
{$MESSAGE Warn '*** GifImage included due to compiler symbol "GIFIMG"'}
{$ENDIF}
{$IFDEF PNGIMG}
{$MESSAGE Warn '*** PNGLib included due to compiler symbol "PNGIMG"'}
{$ENDIF}
{$ENDIF}

{$IFDEF PNGIMG}
   {-$DEFINE NOJPEGCOMPRESS}//OFF
{$ENDIF}

 {-$DEFINE PNGCOMPRESS}//OFF - Compress all bitmaps, not only those with 1,4 and 8 bit depth
{$DEFINE KEEP_COMPRESSED_BITMAP_DATA} //ON - keep compressed data (except metafiles)
{$DEFINE PDFTASKS} //ON
{-$DEFINE DONT_CHECK_META}//OFF
{-$DEFINE DONT_USE_DIBS}//OFF - dont use the conversion to DIB for printing
{-$DEFINE CONVERT_GIF_TO_PNG}//OFF. in Method "Compress".
{-$DEFINE USETRANSBITBLT}//OFF - Printer do not support

// Used by WPTools 6 to load web images through HTTP in single instead of
// multiple single threads:
{-$DEFINE NON_THREADED}//OFF

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

interface

uses Classes, Sysutils, Forms, Windows, WPRTEDefs, WPRTEPaint, Graphics, FileCtrl
{$IFDEF PNGIMG}, pngimage{$ENDIF}
{$IFDEF GIFIMG}, gifimage{$ENDIF}
{$IFDEF GRAPHICEX}, GraphicEx{$ENDIF}
{$IFDEF USEJPEG}, Jpeg{$ENDIF};

{$IFDEF GRAPHICEX}

{$I GraphicConfiguration.inc}

{$ENDIF}

{$O-} // tested on Delphi 7: Paint() does otherwise not work!
{$R-}

type
  TWPOImage = class;
 

  TWPOImage = class(TWPObject)
  protected
    FLastSavePath, FLastSaveName, FLastSaveFileName: string;
    FTransparentColor: TColor;
    bDisablePaint: Boolean;
    FCompressedStream: TMemoryStream; // assigned in LoadFromStream for PNG images!
 
    function IsBitmap: Boolean; override;
    function WriteRTFBitmapData(Writer: TWPCustomTextWriter; AliasTextObj: TWPTextObj; AllowBinary: Boolean): Boolean; virtual;
  private
    FPDFRun, FPDFNr: Integer;
    function LoadMetafileStream(s: TMemoryStream; w, h, WMetafileType: Integer): Boolean;
  public
    class function UseForExtension(const Extension: string): Boolean; override;
    destructor Destroy; override;
    procedure Compress; override;
    procedure CompressEx(var aFileExtension: string; var aCompressedStream: TMemoryStream;
      var better_keep_data: Boolean; MetafilesToo: Boolean = false);
    function ReadRTFData(Reader: TWPCustomTextReader; ReadPicData: TWPReadPictData): Boolean; override;
    procedure WriteRTFData(Writer: TWPCustomTextWriter;
      AliasTextObj: TWPTextObj; AllowBinary: Boolean; LinkedToFile: string = ''); override;
 
    function LoadFromStream(Source: TStream): Boolean; override;
    function SaveToStream(Dest: TStream): Boolean; override;
    function CurrentExt: string; override;
    function CanSaveAsRTF(Ref: TWPTextObj): Boolean; override;
    procedure AssignBitmap(Source: TGraphic); override;
    procedure Paint(toCanvas: TCanvas;
      BoundsRect: TRect;
      ParentTxtObj: TWPTextObj;
      PaintMode: TWPTextObjectPaintModes); override;
    {:: This functions saves the contents of this object to a file.
        The filename will be used without any extension specified.
        If the file already exists a new filename is created using a number
        fed into the Format() function with the format string passed as
        RenameFormatString. The default is '%d'.
        If you do not want renaming pass RenameFormatString as string without
        number placeholder (%d). }
    function SaveToFile(path, filename: string;
      RenameFormatString: string = '%d';
      Compress: Boolean = FALSE;
      DestStream: TMemoryStream = nil): string; override;
  published
    property FileName stored HasFileName;
    property URL stored HasURL;
    property Transparent stored IsTransparent;
    property TransparentColor: TColor read FTransparentColor write FTransparentColor stored IsTransparent;
  end;

type
  TShapeType = (stRectangle, stSquare, stRoundRect, stRoundSquare,
    stEllipse, stCircle, stParenteseLeft, stParenteseRight);

  TWPOCustomShape = class(TWPObject) { very similar to original TShape in VCL! }

  private
    FPen: TPen;
    FBrush: TBrush;
    FShape: TShapeType;
    FCaption: string;
    FColor: TColor;
    procedure SetBrush(Value: TBrush);
    procedure SetPen(Value: TPen);
    procedure SetShape(Value: TShapeType);
    procedure StyleChanged(Sender: TObject);
    function GetBrush: TBrush;
    function GetPen: TPen;
    function GetShape: TShapeType;
  public
    constructor Create(RTFData: TWPRTFDataCollection); override;
    destructor Destroy; override;
    procedure Paint(toCanvas: TCanvas;
      BoundsRect: TRect;
      ParentTxtObj: TWPTextObj;
      PaintMode: TWPTextObjectPaintModes); override;

  public
    property Color: TColor read FColor write FColor;
    property Brush: TBrush read GetBrush write SetBrush;
    property Pen: TPen read GetPen write SetPen;
    property Caption: string read FCaption write FCaption;
    property Shape: TShapeType read GetShape write SetShape default stRectangle;
  end;

  TWPOShape = class(TWPOCustomShape)
  published
    property Color;
    property Brush;
    property Pen;
    property Caption;
    property Shape;
  end;

var WPMaxPrintDPI: Integer = 300;
  WPExportEMFAsBitmap: Boolean = FALSE; // FALSE; // for PDF export
{$IFNDEF PDFTASKS} // should be defined (Requires WPTools V5.20.8)
  WPPDFRun: Integer = 1;
{$ENDIF}
 

function WPMetafileIsOnlyBitmap(meta: TMetafile): Boolean;

implementation

// Protect writing methods
var FLockImgCritical: TRTLCriticalSection;

{$IFNDEF PDFTASKS} // should allways be defined (Requires WPTools V5.20.8)
  ImageEmbedNr: Integer;
{$ENDIF}

{$IFDEF DONT_CHECK_META}

function WPMetafileIsOnlyBitmap(meta: TMetafile): Boolean;
begin
  Result := FALSE;
end;
{$ELSE}

type
  PAMetaRecord = ^AMetaRecord;
  AMetaRecord = packed record
    iType: DWORD; { Record type EMR_XXX}
    nSize: DWORD; { Record size in bytes}
    dParm: array[0..100] of DWORD; { Parameters, 0 based open array }
  end;

function EnumerateMetaObjects(hDC: HDC; var ObjectTable: THandleTable;
  mr: PAMetaRecord; ObjectCount: DWORD; IsBitmap: PBOOL): DWORD; stdcall;
begin
  if (mr.iType in [2..8]) or
    (mr.iType in [41..47]) or
    (mr.iType in [83..92]) or
    (mr.iType in [96..97]) or
    (mr.iType = 108) then
  begin
    IsBitmap^ := FALSE;
    result := 0;
  end
  else Result := 1;
end;

function WPMetafileIsOnlyBitmap(meta: TMetafile): Boolean;
var DC: HDC;
  res: Boolean;
begin
  Result := TRUE;
  DC := GetDC(0);
  try
    try
      if meta.Enhanced then
        res := EnumEnhMetaFile(DC, meta.Handle, @EnumerateMetaObjects, @Result, Rect(0, 0, 1440, 1440))
      else res := EnumMetaFile(DC, meta.Handle, @EnumerateMetaObjects, Cardinal(@Result));
      if not res then Result := FALSE; // render as WMF
    except
      Result := TRUE; // Render to bitmap
    end;
  finally
    ReleaseDC(0, DC);
  end;
end;

(*
// Code to detect "Bitmap only" metafile
type
  PAMetaRecord = ^AMetaRecord;
  AMetaRecord = packed record
    iType: DWORD; { Record type EMR_XXX}
    nSize: DWORD; { Record size in bytes}
    dParm: array[0..100] of DWORD; { Parameters, 0 based open array }
  end;

function WPMetafileIsOnlyBitmap(meta: TMetafile): Boolean;
var c, c2: Cardinal;
  Bits, p: PByte;
  pe: PAMetaRecord;
  RefDC: HDC;
begin
  RefDC := 0;
  try
    if meta.Enhanced then c := GetEnhMetaFileBits(meta.Handle, 0, nil)
    else
    begin
      RefDC := GetDC(0);
      c := GetWinMetaFileBits(meta.Handle, 0, nil, MM_ANISOTROPIC, RefDC);
    end;
    GetMem(Bits, c);
    try
      if meta.Enhanced then
            c2 := GetEnhMetaFileBits(meta.Handle, c, Bits)
      else  c2 := GetWinMetaFileBits(meta.Handle, c, Bits, MM_ANISOTROPIC, RefDC);
      if c2 < c then
        Result := FALSE
      else
      begin
        p := Bits;
        Result := TRUE; // assume bitmap
        while (c > 0) do
        begin
          pe := PAMetaRecord(p);
          if pe.iType = 14 then break
          else if (pe.iType in [2..8]) or (pe.iType in [41..47]) or
            (pe.iType in [83..92]) or (pe.iType in [96..97]) or
            (pe.iType = 108) then
          begin
            Result := FALSE; // not only bitmap!
            break;
          end;
          if (pe.nSize<0) or (pe.nSize>c) then break; // Detect Error
          dec(c, pe.nSize);
          inc(p, pe.nSize);
        end;
      end;
    finally
      FreeMem(Bits);
    end;
  finally
    if RefDC <> 0 then ReleaseDC(0, RefDC);
  end;
end;
*)
{$ENDIF}

class function TWPOImage.UseForExtension(const Extension: string): Boolean;
begin
  Result := inherited UseForExtension(Extension) // Checks Classname
    or (CompareText(Extension, 'WMF') = 0) // Which FileExtension do we support here ?
    or (CompareText(Extension, 'EMF') = 0)
    or (CompareText(Extension, 'BMP') = 0)
{$IFDEF GIFIMG}
  or (CompareText(Extension, 'GIF') = 0)
{$ENDIF}
{$IFDEF PNGIMG}
  or (CompareText(Extension, 'PNG') = 0)
{$ENDIF}
{$IFDEF GRAPHICEX}
  or (CompareText(Extension, 'GIF') = 0)
    or (CompareText(Extension, 'PNG') = 0)
{$ENDIF}
{$IFDEF USEJPEG}
  or (CompareText(Extension, 'JPG') = 0)
    or (CompareText(Extension, 'JPEG') = 0)
{$ENDIF}
  ;
end;

destructor TWPOImage.Destroy;
{$IFDEF PNGIMG}
var gr: TObject;
{$ENDIF}
begin
 
  if FCompressedStream <> nil then
    FCompressedStream.Free;

  FreeAndNil(FPicture); //V5.38

{$IFDEF PNGIMG}
  gr := Graphic;
  if gr is tpngobject then
  try
    tpngobject(gr).Assign(nil); // CLEAR!
  except
  end;
{$ENDIF}
  Graphic := nil;
  inherited Destroy;
end;

 

procedure TWPOImage.AssignBitmap(Source: TGraphic);
var bit: TBitmap;
begin
  if Source = nil then
    Graphic := nil
  else if (Source is TBitmap) or (Source is TMetafile) then
  begin
    Graphic := Source;
    if (WidthTW = 0) or (HeightTW = 0) then
    begin
      WidthTW := MulDiv(Source.Width, 1440, WPScreenPixelsPerInch);
      HeightTW := MulDiv(Source.Height, 1440, WPScreenPixelsPerInch);
    end;
  end
  else
  begin
    bit := TBitmap.Create;
    try
      bit.Assign(Source);
      Graphic := bit;
    finally // V5.15.6 was: except
      bit.Free;
    end;
  end;
end;

// V5.22 - try PNG first and then JPEG. Keep the smaller!

procedure TWPOImage.Compress;
var f: string; dummy: Boolean;
begin
  f := FileExtension;
  CompressEx(f, FCompressedStream, dummy, false);
  FileExtension := f;
end;

procedure TWPOImage.CompressEx(var aFileExtension: string; var aCompressedStream: TMemoryStream;
  var better_keep_data: Boolean; MetafilesToo: Boolean = false);
var
{$IFDEF PNGIMG}
  png: tpngobject;
{$ENDIF}
{$IFNDEF NOJPEGCOMPRESS}
  jpeg: TJPEGImage;
  tempstream: TMemoryStream;
  Size: Integer;
  bit: TBitmap;
{$ENDIF}
  avoid_jpeg: Boolean;
begin
{$IFDEF KEEP_COMPRESSED_BITMAP_DATA}
  better_keep_data := true; // always !!!
{$ELSE}
  better_keep_data := false;
{$ENDIF}
  avoid_jpeg := FALSE;
  if (CompareText(aFileExtension, 'JPG') <> 0) and
    (CompareText(aFileExtension, 'PNG') <> 0) and
    (CompareText(aFileExtension, 'JPEG') <> 0) then
  begin
{$IFNDEF NOJPEGCOMPRESS}
    Size := -1;
{$ENDIF}
{$IFDEF PNGIMG}
    png := nil;
    try
{$IFDEF CONVERT_GIF_TO_PNG}
      if CompareText(aFileExtension, 'GIF') = 0 then
      begin a
        avoid_jpeg := true;
        png := tpngobject.createblank(COLOR_RGB, 16, Graphic.Width, Graphic.Height);
        png.Canvas.Brush.Color := clWhite;
        png.Canvas.FillRect(Rect(0, 0, png.width, png.height));
        png.Canvas.Draw(0, 0, Graphic);
        better_keep_data := false; // Don't keep the PNG data. There was a conversion
      end else
{$ENDIF}
        if Graphic is TMetafile then
        begin
          if MetafilesToo then
          begin
            if not WPMetafileIsOnlyBitmap(TMetafile(Graphic)) then
            begin
              better_keep_data := false; // NEVER keep compressed data !
              avoid_jpeg := True;
            end;
          end else
          begin
            if not WPMetafileIsOnlyBitmap(TMetafile(Graphic)) then
              exit;
          end;
          png := tpngobject.createblank(COLOR_RGB, 16,
            Round(TMetafile(Graphic).MMWidth * 200 / 2540), // 200 DPI
            Round(TMetafile(Graphic).MMHeight * 200 / 2540)); // 200 DPI
          png.Canvas.Brush.Color := clWhite;
          png.Canvas.FillRect(Rect(0, 0, png.width, png.height));
          png.Canvas.StretchDraw(Rect(0, 0, png.Width, png.Height), Graphic);
        end else
          if ((Graphic is TBitmap) and (TBitmap(Graphic).PixelFormat in [pf1bit, pf4bit, pf8bit])) then
          begin
            if TBitmap(Graphic).PixelFormat = pf1bit then
              png := tpngobject.createblank(COLOR_RGB, 1, Graphic.Width, Graphic.Height)
            else if TBitmap(Graphic).PixelFormat = pf4bit then
              png := tpngobject.createblank(COLOR_RGB, 4, Graphic.Width, Graphic.Height)
            else png := tpngobject.createblank(COLOR_RGB, 8, Graphic.Width, Graphic.Height);
            png.Canvas.StretchDraw(Rect(0, 0, Graphic.Width, Graphic.Height), Graphic);
            better_keep_data := true; //yes, lossless
            avoid_jpeg := true;
          end
{$IFDEF PNGCOMPRESS} // Compress all images, with photos this creates huge files!
          else
          begin
            png := tpngobject.createblank(COLOR_RGB, 16, Graphic.Width, Graphic.Height);
            png.Canvas.StretchDraw(Rect(0, 0, Graphic.Width, Graphic.Height), Graphic);
            better_keep_data := true; //yes, lossless
          end
{$ENDIF};
      if png <> nil then
      begin
        png.TransparentColor := clWhite;
        png.InterlaceMethod := imAdam7;
        png.MaxIdatSize := 100;
        png.AddztXt('Made using', WPEngineName);
        png.AddztXt('Website', 'http://www.wpcubed.com');
        if aCompressedStream = nil then aCompressedStream := TMemoryStream.Create
        else aCompressedStream.Clear;
        png.SaveToStream(aCompressedStream);
{$IFNDEF NOJPEGCOMPRESS}
        Size := aCompressedStream.Size;
{$ENDIF}
        aFileExtension := 'PNG';
      end;
    finally
      png.Free;
    end;
{$ENDIF}
{$IFNDEF NOJPEGCOMPRESS}
    jpeg := nil;
    if not avoid_jpeg then
    try
      if Graphic is TMetafile then
      begin
        if not WPMetafileIsOnlyBitmap(TMetafile(Graphic)) then exit;
        bit := TBitmap.Create;
        jpeg := TJPEGImage.Create;
        bit.Width := Round(TMetafile(Graphic).MMWidth * 200 / 2540); // 200 DPI
        bit.Height := Round(TMetafile(Graphic).MMHeight * 200 / 2540); // 200 DPI
        bit.Canvas.StretchDraw(Rect(0, 0, bit.Width, bit.Height), Graphic);
        jpeg.Assign(bit);
        bit.Free;
      end else
      begin
        jpeg := TJPEGImage.Create;
        jpeg.Assign(Graphic);
      end;
      jpeg.JPEGNeeded;
      if Size > 0 then
      begin
        tempstream := TMemoryStream.Create;
        try
          jpeg.SaveToStream(tempstream);
          if (tempstream.Size > 0) and (tempstream.Size < Size) then
          begin
            FreeAndNil(aCompressedStream);
            aCompressedStream := tempstream;
            tempstream := nil;
            aFileExtension := 'JPEG';
          end;
        finally
          FreeAndNil(tempstream);
        end;
      end else
      begin
        if aCompressedStream = nil then aCompressedStream := TMemoryStream.Create
        else aCompressedStream.Clear;
        jpeg.SaveToStream(aCompressedStream);
        aFileExtension := 'JPEG';
      end;
    finally
      jpeg.Free;
    end;
{$ENDIF}
  end;
end;

function TWPOImage.SaveToFile(path, filename: string;
  RenameFormatString: string = '%d';
  Compress: Boolean = FALSE;
  DestStream: TMemoryStream = nil): string;
var ext: string;
  function MakeName: string; // protected by FLockImgCritical
  var i: Integer;
    s, s1: string;
  begin
    i := 1;
    if (path <> '') then
      ForceDirectories(path);
    if RenameFormatString = '' then
      Result := path + filename + '.' + ext
    else
    begin
      s := Format(RenameFormatString, [i]);
      repeat
        Result := path + filename + s + '.' + ext;
        inc(i);
        s1 := s;
        s := Format(RenameFormatString, [i]);
        if s = s1 then break; // No renaming wanted !
      until not FileExists(Result);
    end;
  end;
var i: Integer;
  aCompressedStream: TMemoryStream;
  lossless: Boolean;
begin
  // Do not increment for each save
  EnterCriticalSection(FLockImgCritical);
  try
    if (FLastSavePath = path) and (FLastSaveName = filename) and (FLastSaveFileName <> '') and
      (FileExists(FLastSaveFileName)) then
    begin
      Result := FLastSaveFileName;
      exit;
    end;
  finally
    LeaveCriticalSection(FLockImgCritical);
  end;

  FLastSavePath := path;
  FLastSaveName := filename;
  FLastSaveFileName := '';

  if (path <> '') and ((path[Length(path)] = '\') or (path[Length(path)] = '/')) then
  begin
     //   path := path
  end
  else if path <> '' then
    path := path + '\'
  else path := '';

  i := Length(filename);
  while i > 0 do
  begin
    if filename[i] = '.' then break;
    dec(i);
  end;
  if i > 0 then filename := Copy(filename, 1, i - 1);

  ext := GetFileExtension;
  aCompressedStream := nil;
  if Compress and
    (CompareText(ext, 'JPG') <> 0) and
    (CompareText(ext, 'PNG') <> 0) and
    (CompareText(ext, 'GIF') <> 0) and
    (CompareText(ext, 'JPEG') <> 0) then
  begin
    lossless := false;
    Self.CompressEx(ext, aCompressedStream, lossless, true);
    if (aCompressedStream <> nil)
      and lossless
      then
    begin
      FreeAndNil(FCompressedStream);
      FileExtension := ext;
      FCompressedStream := aCompressedStream;
      aCompressedStream := nil;
    end;
  end;
  try
    EnterCriticalSection(FLockImgCritical);
    try
      if (aCompressedStream <> nil) and (aCompressedStream.Size > 0) and (ext <> '') then
      begin
        Result := MakeName;
        if DestStream <> nil then
        begin
          aCompressedStream.Position := 0;
          DestStream.CopyFrom(aCompressedStream, aCompressedStream.Size)
        end
        else aCompressedStream.SaveToFile(Result);
      end else
        if (FCompressedStream <> nil) and (FCompressedStream.Size > 0) and (ext <> '') then
        begin
          Result := MakeName;
          if DestStream <> nil then
          begin
            FCompressedStream.Position := 0;
            DestStream.CopyFrom(FCompressedStream, FCompressedStream.Size);
          end
          else FCompressedStream.SaveToFile(Result);
        end
        else if (Picture.Graphic <> nil) and (ext <> '') then
        begin
          Result := MakeName;
          if DestStream <> nil then
            Picture.Graphic.SaveToStream(DestStream)
          else Picture.SaveToFile(Result);
        end else filename := '';
    except
      Result := '';
    end;
  finally
    aCompressedStream.Free;
    LeaveCriticalSection(FLockImgCritical);
    FLastSaveFileName := Result;
  end;

end;

procedure TWPOImage.Paint(
  toCanvas: TCanvas;
  BoundsRect: TRect;
  ParentTxtObj: TWPTextObj;
  PaintMode: TWPTextObjectPaintModes);
   // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{$IFDEF DONT_USE_DIBS}
  procedure StetchDrawDIB(printthis: TBitmap);
  begin
    toCanvas.StretchDraw(BoundsRect, printthis);
  end;
{$ELSE}
  procedure StetchDrawDIB(printthis: TBitmap);
  var
    Info: PBitmapInfo;
    InfoSize: DWORD;
    Image: Pointer;
    ImageHandle, oo: Integer;
    ImageSize, ROPCode: DWORD;
    Bits: HBITMAP;
    DIBWidth, DIBHeight: Longint;
  begin
    Bits := TBitmap(printthis).Handle;
    oo := 0;
    if Bits = 0 then exit; { Bitmap invalid }
    GetDIBSizes(Bits, InfoSize, ImageSize);
    inc(ImageSize, 1000); // reserve  (not for Win95)
    Info := AllocMem(InfoSize);
    try
      ImageHandle := GlobalAlloc(GMEM_MOVEABLE, ImageSize);
      Image := GlobalLock(ImageHandle);
      try
        GetDIB(Bits, TBitmap(printthis).Palette, Info^, Image^);
        with Info^.bmiHeader do
        begin
          DIBWidth := biWidth;
          DIBHeight := biHeight;
        end;
        ROPCode := SRCCOPY;
        SetStretchBltMode(toCanvas.Handle, HALFTONE);
        SelectPalette(toCanvas.Handle, TBitmap(printthis).Palette, FALSE);
        RealizePalette(toCanvas.Handle);
        StretchDIBits(toCanvas.Handle, BoundsRect.Left, BoundsRect.Top,
          BoundsRect.Right - BoundsRect.Left, BoundsRect.Bottom - BoundsRect.Top, 0, 0,
          DIBWidth, DIBHeight, Image, Info^, DIB_RGB_COLORS, ROPCode);
        if oo <> 0 then
          SetStretchBltMode(toCanvas.Handle, oo);
      finally
        if Image <> nil then
        begin
          GlobalUnlock(ImageHandle);
          GlobalFree(ImageHandle);
        end;
      end;
    finally
      FreeMem(Pointer(Info), InfoSize);
    end;
  end;
{$ENDIF}
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var abit: TBitmap;
  w, h, m: Integer;
  mem: TMemoryStream;
{$IFDEF USETRANSBITBLT}col: TColor; {$ENDIF}
  n: string;
{$IFDEF PDFTASKS}WPPDFRun: Integer; {$ENDIF}
begin
  if not bDisablePaint and (toCanvas <> nil) then
  try
    toCanvas.CopyMode := cmSrcCopy;
    // When we are printing or exporting to PDF create a TRUE COLOR DIB!
    // Some printer will otherwise print back rectangles for "transparent" PNGs!
    if (Graphic <> nil) and not (wpPaintObjInEditor in PaintMode) then
    begin
      if ((wpPaintObjDestIsPDF in PaintMode) or (wpPaintObjMetaAsBitmap in PaintMode))
        and (Graphic is TMetafile)
        and
        (WPExportEMFAsBitmap
        or (wpPaintObjMetaAsBitmap in PaintMode)
{$IFDEF ICONFIX}
        or
        ((Graphic.Height < 10) and
        (Graphic.Width < 20))
{$ENDIF}
        )
        then
      begin
        abit := TBitmap.Create;
        abit.PixelFormat := pf24bit;
        try
          abit.Width := MulDiv(ParentTxtObj.Width, 300, 1440); // export as 300 dpi!
          abit.Height := MulDiv(ParentTxtObj.Height, 300, 1440);
          abit.Canvas.StretchDraw(Rect(0, 0, abit.Width, abit.Height), Graphic);
          // toCanvas.StretchDraw(BoundsRect, abit);
          StetchDrawDIB(TBitmap(abit));
        finally
          abit.Free;
        end;
      end else
        if (Graphic is TMetafile) and not WPMetafileIsOnlyBitmap(TMetafile(Graphic))
          then
        try
          //V5.40 - suppress small objects
          if (BoundsRect.Right - BoundsRect.Left > 6) or (BoundsRect.Bottom - BoundsRect.Top > 6) then
            toCanvas.StretchDraw(BoundsRect, Graphic);
        except
          toCanvas.Pen.Width := 0;
          toCanvas.Pen.Color := clred;
          toCanvas.Rectangle(BoundsRect);
          toCanvas.Pen.Color := clBlack;
        end
        else
        begin
          if (Graphic is TBitmap) and
            ((TBitmap(Graphic).PixelFormat = pf24bit) or
            (TBitmap(Graphic).PixelFormat = pf1bit)
{$IFDEF USETRANSBITBLT}
{$IFDEF WPDF3} or (Transparent and (wpPaintObjDestIsPDF in PaintMode)){$ENDIF}
{$ENDIF}
            )
            then
          begin
            if (wpPaintObjDestIsPDF in PaintMode) then
            begin
{$IFDEF WPDF3}
{$IFDEF USETRANSBITBLT}
              if Transparent then
              begin
                if FTransparentColor = clNone then col := TBitmap(Graphic).Canvas.Pixels[0, 0]
                else col := FTransparentColor;
                TransparentBlt(toCanvas.Handle,
                  BoundsRect.Left, BoundsRect.Top,
                  BoundsRect.Right - BoundsRect.Left,
                  BoundsRect.Bottom - BoundsRect.Top,
                  TBitmap(Graphic).Canvas.Handle,
                  0, 0, TBitmap(Graphic).Width, TBitmap(Graphic).Height,
                  ColorToRGB(col)
                  )
              end else
{$ENDIF}
{$ENDIF}
                toCanvas.StretchDraw(BoundsRect, Graphic);
            end
            else StetchDrawDIB(TBitmap(Graphic));
          end
          else
            if (wpPaintObjDestIsPDF in PaintMode) and (Graphic is TJPEGImage) then
            begin
{$IFDEF PDFTASKS}
              WPPDFRun := ParentTxtObj.ParentPar.RTFData.DataCollection._WPPDFRun;
{$ENDIF}

              if (WPPDFRun > 0) and (FPDFRun = WPPDFRun) then
                WPWriteComment(toCanvas.Handle, 2001, BoundsRect, AnsiString('WPToolsJIF_' + IntToStr(FPDFNr)))
              else
              begin
                mem := TMemoryStream.Create;
                try
{$IFDEF PDFTASKS}
                  inc(ParentTxtObj.ParentPar.RTFData.DataCollection._ImageEmbedNr);
                  n := 'WPToolsJIF_' + IntToStr(ParentTxtObj.ParentPar.RTFData.DataCollection._ImageEmbedNr);
{$ELSE}
                  inc(ImageEmbedNr);
                  n := 'WPToolsJIF_' + IntToStr(ImageEmbedNr);
{$ENDIF}
                  if TJPEGImage(Graphic).Grayscale then m := 7
                  // else if TJPEGImage(Graphic).IsCMYK then m := 6
                  else m := 2;
                  TJPEGImage(Graphic).JPEGNeeded;
                  TJPEGImage(Graphic).SaveToStream(mem);
                  // 1. embed
                  WPWriteComment(toCanvas.Handle, 3001, Rect(
{$IFDEF PDFTASKS}
                    ParentTxtObj.ParentPar.RTFData.DataCollection._ImageEmbedNr
{$ELSE}ImageEmbedNr{$ENDIF}, m,
                    TJPEGImage(Graphic).Width, TJPEGImage(Graphic).Height), mem.Memory, mem.Size);
                  // 2. use
                  WPWriteComment(toCanvas.Handle, 2001, BoundsRect, AnsiString(n));
                  // remember use
                  FPDFRun := WPPDFRun;
                  FPDFNr := {$IFDEF PDFTASKS}
                  ParentTxtObj.ParentPar.RTFData.DataCollection._ImageEmbedNr
{$ELSE}ImageEmbedNr{$ENDIF};
                finally
                  mem.Free;
                end;
              end;
            end
            else if (Graphic.Width <> 0) and (Graphic.Height <> 0) then
            begin
              abit := TBitmap.Create;
              w := Abs(Graphic.Width);
              h := Abs(Graphic.Height);
            // Limit the size to 300 dpi! --------------------------------------
              if ParentTxtObj <> nil then
              begin
                if w > MulDiv(ParentTxtObj.Width, WPMaxPrintDPI, 1440) then
                  w := MulDiv(ParentTxtObj.Width, WPMaxPrintDPI, 1440);
                if h > MulDiv(ParentTxtObj.Height, WPMaxPrintDPI, 1440) then
                  h := MulDiv(ParentTxtObj.Height, WPMaxPrintDPI, 1440);
              end;
            // -----------------------------------------------------------------
              abit.Width := w;
              abit.Height := h;
              abit.PixelFormat := pf24bit;
              try
                SetStretchBltMode(abit.Canvas.Handle, HALFTONE);
                abit.Canvas.StretchDraw(Rect(0, 0, abit.Width, abit.Height), Graphic);
                StetchDrawDIB(abit);
              finally
                abit.Free;
              end;
            end
        // Width and Height = 0? This can happen with metafiles!
            else inherited Paint(toCanvas, BoundsRect, ParentTxtObj, PaintMode);
        end;
    end else
    begin
{$IFDEF GIFIMG}
      if (Graphic <> nil) and (Graphic is TGIFImage) then
      begin
        toCanvas.StretchDraw(BoundsRect, Graphic);
      end else
{$ENDIF}
{$IFDEF PNGIMG}
        if (Graphic <> nil) and (Graphic is TPngObject) then
        begin
          {
          abit := TBitmap.Create;
          w := Abs(Graphic.Width);
          h := Abs(Graphic.Height);
          abit.Width  := w;
          abit.Height := h;
          abit.PixelFormat := pf24bit;
          try
                TPngObject(Graphic).Draw(abit.Canvas, Rect(0,0, w,h));
                SetStretchBltMode(toCanvas.Handle, HALFTONE);
                toCanvas.StretchDraw(BoundsRect, aBit);
          finally
                abit.Free;
          end; }
          TPngObject(Graphic).Draw(toCanvas, BoundsRect);
        end else
{$ENDIF}
{$IFDEF GRAPHICEX}
          if (Graphic <> nil) and (Graphic is TPNGGraphic) then
          begin
            toCanvas.StretchDraw(BoundsRect, Graphic);
          end else
{$ENDIF}
{$IFDEF USETRANSBITBLT}
            if Transparent and (Graphic is TBitmap) then
            begin
              if FTransparentColor = clNone then col := TBitmap(Graphic).Canvas.Pixels[0, 0]
              else col := FTransparentColor;
              TransparentBlt(toCanvas.Handle,
                BoundsRect.Left, BoundsRect.Top,
                BoundsRect.Right - BoundsRect.Left,
                BoundsRect.Bottom - BoundsRect.Top,
                TBitmap(Graphic).Canvas.Handle,
                0, 0, TBitmap(Graphic).Width, TBitmap(Graphic).Height,
                ColorToRGB(col)
                )
            end else
{$ENDIF} //USETRANSBITBLT
              inherited Paint(toCanvas, BoundsRect, ParentTxtObj, PaintMode);
    end;
  except
    bDisablePaint := TRUE;
  end else if not bDisablePaint then inherited Paint(toCanvas, BoundsRect, ParentTxtObj, PaintMode);
end;

function TWPOImage.LoadFromStream(Source: TStream): Boolean;
var bit: TBitmap; meta: TMetaFile; oldpos: Integer;
  buf: array[0..10] of AnsiChar;
{$IFDEF USEJPEG}jpgpic: TJPEGImage; {$ENDIF}
{$IFDEF GIFIMG}gifpic: TGIFImage; {$ENDIF}
{$IFDEF PNGIMG}pngpic: TPngObject; CannotLoad: Boolean; {$ENDIF}
{$IFDEF GRAPHICEX}
{$IFDEF UseLZW}
{$IFNDEF GIFIMG}gifpic: TGIFGraphic; {$ENDIF}
{$ENDIF}
{$IFNDEF PNGIMG}pngpic: TPNGGraphic; {$ENDIF}
{$ENDIF}
begin
  Result := FALSE;
  FreeAndNil(FCompressedStream);
  oldpos := Source.Position;
  if (Length(FileExtension) > 1) and (FileExtension[1] = '.') then
    FileExtension := Copy(FileExtension, 2, Length(FileExtension));

  // Detect Header!
  FillChar(buf[0], 10, 0);
  Source.Read(buf[0], 10);
  Source.Position := oldpos;

  if Source.Size - Source.Position > 4 then // Detect empty data
  try
    if CompareText(FileExtension, 'BMP') = 0 then
    begin
      bit := TBitmap.Create;
      try
        bit.LoadFromStream(Source);
        Graphic := bit;
        Result := TRUE;
      finally
        bit.Free;
      end;
    end
    else if (CompareText(FileExtension, 'WMF') = 0)
      or (CompareText(FileExtension, 'EMF') = 0) then
    begin
      meta := TMetafile.Create;
      try
        meta.LoadFromStream(Source);
        Graphic := meta;
        Result := TRUE;
      finally
        meta.Free;
      end;
    end
{$IFDEF USEJPEG} // Also detect JFIF
    else if (CompareText(FileExtension, 'JPG') = 0)
      or (CompareText(FileExtension, 'JPEG') = 0)
      or ((buf[6] = 'J') and (buf[7] = 'F') and (buf[8] = 'I') and (buf[9] = 'F'))
      then
    begin
      jpgpic := TJPEGImage.Create;
      try
        jpgpic.LoadFromStream(Source);
        Graphic := jpgpic;
        Result := TRUE;
      finally
        jpgpic.Free;
      end;
      FileExtension := 'JPG';
    end
{$ENDIF}
{$IFDEF GIFIMG} // Detect also GIF indentification characters!  (Word handles GIF=PNG)
    else if (CompareText(FileExtension, 'GIF') = 0)
      or ((buf[0] = 'G') and (buf[1] = 'I') and (buf[2] = 'F') and (buf[3] = '8') and (buf[4] = '9'))
      then
    begin
      gifpic := TGIFImage.Create;
      try
        FCompressedStream := TMemoryStream.Create;
        FCompressedStream.SetSize(Source.Size - oldpos);
        Source.Position := oldpos;
        Source.Read(PChar(FCompressedStream.Memory)^, FCompressedStream.Size);
        FCompressedStream.Position := 0;
        if FCompressedStream.Size>10 then // trap invalid data 
        begin
          gifpic.LoadFromStream(FCompressedStream);
          Graphic := gifpic;
          Result := TRUE;
          FileExtension := 'GIF';
        end;
        gifpic.Free;
      except
          gifpic.Free;
          Result := FALSE;
      end;   
    end
{$ENDIF}
{$IFDEF PNGIMG} // http://pngdelphi.sourceforge.net/
    else if (CompareText(FileExtension, 'PNG') = 0)
      or ((buf[0] = #$89) and (buf[1] = 'P') and (buf[2] = 'N') and (buf[3] = 'G'))
      then
    begin
      pngpic := TPNGObject.Create;
      try
        CannotLoad := FALSE;
        try
          pngpic.LoadFromStream(Source);
          FileExtension := 'PNG'; // detect header
          Result := TRUE;
        except
          CannotLoad := TRUE;
        end;
        if not CannotLoad then
          Graphic := pngpic
        else
{$IFDEF GIFIMG} // Should not happen ...
        begin
          gifpic := TGIFImage.Create;
          try
            Source.Position := oldpos;
            gifpic.LoadFromStream(Source);
            Graphic := gifpic;
            Result := TRUE;
          finally
            gifpic.Free;
          end;
        end;
{$ELSE}
          exit;
{$ENDIF}
        FCompressedStream := TMemoryStream.Create;
        FCompressedStream.SetSize(Source.Size - oldpos);
        Source.Position := oldpos;
        Source.Read(PChar(FCompressedStream.Memory)^, FCompressedStream.Size);
        Result := TRUE;
      finally
        pngpic.Free;
      end;
    end
{$ELSE}
{$IFDEF GRAPHICEX}
    else if (CompareText(FileExtension, 'PNG') = 0)
      or ((buf[0] = #$89) and (buf[1] = 'P') and (buf[2] = 'N') and (buf[3] = 'G')) then
    begin
      pngpic := TPNGGraphic.Create;
      try
        pngpic.LoadFromStream(Source);
        Graphic := pngpic;
        FCompressedStream := TMemoryStream.Create;
        FCompressedStream.SetSize(Source.Size - oldpos);
        Source.Position := oldpos;
        Source.Read(PChar(FCompressedStream.Memory)^, FCompressedStream.Size);
        Result := TRUE;
        FileExtension := 'PNG';
      finally
        pngpic.Free;
      end;
    end
{$ENDIF}
{$ENDIF}
{$IFDEF GRAPHICEX}
{$IFDEF UseLZW}
{$IFNDEF GIFIMG}
    else if (CompareText(FileExtension, 'GIF') = 0) then
    begin
      gifpic := TGIFGraphic.Create;
      try
        gifpic.LoadFromStream(Source);
        Graphic := gifpic;
        Result := TRUE;
      finally
        gifpic.Free;
      end;
    end
{$ENDIF}
{$ENDIF}
{$ENDIF}
    else
    begin
      Source.Position := oldpos;
      Result := inherited LoadFromStream(Source);
    end;
  except
    { File invalid ? }
  end;
end;

function TWPOImage.IsBitmap: Boolean;
begin
  if FPicture = nil then Result := FALSE else
    Result := (FPicture.Graphic is TBitmap)
{$IFDEF GRAPHICEX} or (FPicture.Graphic is TPNGGraphic){$ENDIF}
{$IFDEF USEJPEG} or (FPicture.Graphic is TJPEGImage){$ENDIF}
{$IFDEF GIFIMG} or (FPicture.Graphic is TGIFImage){$ENDIF}
{$IFDEF PNGIMG} or (FPicture.Graphic is TPngObject){$ENDIF}
    ;
end;

function TWPOImage.SaveToStream(Dest: TStream): Boolean;
begin
  FFileExtension := UpperCase(FFileExtension);
  Result := FALSE;
  if FPicture <> nil then
  begin
    if (FPicture.Graphic = nil) or
      ((FCompressedStream <> nil) and (
      ((FPicture.Graphic is TBitmap) and //V5.42 - we used the method compress
      (CompareText(FileExtension, 'JPG') = 0)
      or (CompareText(FileExtension, 'JPEG') = 0)) or
      ((FPicture.Graphic is TBitmap) and
      (CompareText(FileExtension, 'PNG') = 0))))
      then
    begin
      if (FCompressedStream <> nil) and (FFileExtension <> '') then
        FCompressedStream.SaveToStream(Dest);
    end
{$IFDEF GRAPHICEX}
    else if (FPicture.Graphic is TPNGGraphic)
      and (FFileExtension = 'PNG')
      and (FCompressedStream <> nil) then
    begin
      FCompressedStream.Position := 0;
      FCompressedStream.SaveToStream(Dest);
      FFileExtension := 'PNG';
      Result := TRUE;
    end
{$ELSE}
{$IFDEF PNGIMG}
    else if (FPicture.Graphic is TPNGObject)
      and (FFileExtension = 'PNG')
      and (FCompressedStream <> nil) then
    begin
      FCompressedStream.Position := 0;
      FCompressedStream.SaveToStream(Dest);
      FFileExtension := 'PNG';
      Result := TRUE;
    end
    else if (FPicture.Graphic is TPNGObject)
      and (FCompressedStream = nil) then
    begin
      TPngObject(FPicture.Graphic).SaveToStream(Dest);
      FFileExtension := 'PNG';
      Result := TRUE;
    end
{$ENDIF}
{$IFDEF GIFIMG}
    else if (FPicture.Graphic is TGifImage)
      and (FFileExtension = 'GIF')
      and (FCompressedStream <> nil) then
    begin
      FCompressedStream.Position := 0;
      FCompressedStream.SaveToStream(Dest);
      FFileExtension := 'GIF';
      Result := TRUE;
    end
{$ENDIF}
{$ENDIF}
{$IFDEF USEJPEG}
    else if FPicture.Graphic is TJPEGImage then
    begin
      TJPEGImage(FPicture.Graphic).SaveToStream(Dest);
      FFileExtension := 'JPG';
      Result := TRUE;
    end
{$ENDIF}
    else if FPicture.Graphic is TBitmap then
    begin
      TBitmap(FPicture.Graphic).SaveToStream(Dest);
      FFileExtension := 'BMP';
      Result := TRUE;
    end else if FPicture.Graphic is TMetafile then
    begin
      TMetafile(FPicture.Graphic).SaveToStream(Dest);
      FFileExtension := 'EMF';
      Result := TRUE;
    end
    else
    begin
      // FPicture.SaveToFile ...
    end;
  end;
end;

function TWPOImage.CanSaveAsRTF(Ref: TWPTextObj): Boolean;
begin
  Result := TRUE;
end;

function TWPOImage.CurrentExt: string;
begin
  Result := FFileExtension;
  if (FPicture = nil) or (FPicture.Graphic = nil) then
  begin

  end
{$IFDEF GRAPHICEX}
  // The TPNGGraphic cannot save PNG format
  // - we use the data stored in FCompressedStream
  else if (FPicture.Graphic is TPNGGraphic) and (FCompressedStream <> nil) then
  begin
    Result := 'PNG';
  end
{$ENDIF}
{$IFDEF USEJPEG}
  else if FPicture.Graphic is TJPEGImage then
  begin
    Result := 'JPG';
  end
{$ENDIF}
  else if Graphic is TBitmap then
  begin
    Result := 'BMP';
  end
  else if Graphic is TMetafile then
  begin
    Result := 'EMF';
  end;
end;

{$WARNINGS OFF} // unsave pointer ...

function TWPOImage.LoadMetafileStream(s: TMemoryStream; w, h, WMetafileType: Integer): Boolean;
var
  metahandle: HMetafile;
  lpmfp: TMetaFilePict;
  meta: TMetafile;
  inch: Integer;
  EMFHeader: TEnhMetaheader;
begin
  Result := TRUE;
  if WMetafileType = 6 then { MM_TWIPS }
  begin
    WidthTW := w;
    HeightTW := h;
    inch := 1440;
  end else
    if WMetafileType = 7 then { MM_ISOTROPIC->MM_HIMETRIC }
    begin
      WidthTW := MulDiv(w, 144, 254);
      HeightTW := MulDiv(h, 144, 254);
      inch := Round(Screen.PixelsPerInch / 2.54 * 10000);
    end else
      if WMetafileType = 8 then { MM_ANISOTROPIC->MM_HIMETRIC }
      begin
        WidthTW := MulDiv(w, 144, 254);
        HeightTW := MulDiv(h, 144, 254);
        inch := Round(Screen.PixelsPerInch / 2.54 * 10000);
      end else
      begin
        WidthTW := MulDiv(w, Screen.PixelsPerInch, 96); { MM_TEXT }
        HeightTW := MulDiv(h, Screen.PixelsPerInch, 96);
        inch := 96;
      end;
  lpmfp.mm := 1; // WMetafileType;
  lpmfp.hMF := 0;
  lpmfp.xExt := w;
  lpmfp.yExt := h;

  metahandle := SetWinMetaFileBits(s.Size, s.Memory, 0, lpmfp);
  if metahandle <> 0 then
  begin
    if GetEnhMetaFileHeader(metahandle, Sizeof(EMFHeader), @EMFHeader) <> 0 then
    begin
      lpmfp.mm := 8;
      lpmfp.xExt := EMFHeader.rclFrame.Right; //  * inch;
      lpmfp.yExt := EMFHeader.rclFrame.Bottom; //  * inch;
      lpmfp.hMF := 0;
      DeleteEnhMetafile(metahandle);
      metahandle := SetWinMetaFileBits(s.Size, s.Memory, 0, lpmfp);
    end;
    meta := TMetafile.Create;
    meta.Handle := metahandle;
    meta.inch := inch;
    try
      Picture.Graphic := meta;
    finally
      meta.Free;
      //NO: DeleteEnhMetafile(metahandle);
    end;
  end else Result := FALSE; // raise Exception.Create('Cannot load metafile');
end;
{$WARNINGS ON}

{$WARNINGS OFF}

// Save JPEG and PNG

function TWPOImage.WriteRTFBitmapData(Writer: TWPCustomTextWriter; AliasTextObj: TWPTextObj; AllowBinary: Boolean): Boolean;
var w, h: Integer; str: string; mem: TMemoryStream;
begin
{$IFDEF USEJPEG}
  if ((CompareText(FileExtension, 'JPG') = 0) or
    (CompareText(FileExtension, 'JPEG') = 0)) and (Graphic is TJPEGImage) then
  begin
    h := MulDiv(Picture.Graphic.Height, 1440, 96);
    w := MulDiv(Picture.Graphic.Width, 1440, 96);
    str := '\jpegblip'
      + '\picw' + IntToStr(w)
      + '\pich' + IntToStr(h)
      + '\picwgoal' + IntToStr(AliasTextObj.Width)
      + '\pichgoal' + IntToStr(AliasTextObj.Height) + #13#10;
    mem := TMemoryStream.Create;
    try
      TJPEGImage(Graphic).SaveToStream(mem);
      Writer.WriteString(str);
      if AllowBinary then
      begin
        Writer.WriteString('\bin');
        Writer.WriteInteger(mem.Size);
        Writer.WriteString(#32);
        Writer.WriteStream(mem, false, 0);
      end else
        Writer.WriteStream(mem, true, 0);
    finally
      mem.Free;
    end;
    Result := TRUE;
  end else
{$ENDIF}
    if ((CompareText(FileExtension, 'PNG') = 0) or
      (CompareText(FileExtension, 'GIF') = 0)) and
      (FCompressedStream <> nil) then
    begin
      h := MulDiv(Picture.Graphic.Height, 1440, 96);
      w := MulDiv(Picture.Graphic.Width, 1440, 96);
      str := '\pngblip'
        + '\picw' + IntToStr(w)
        + '\pich' + IntToStr(h)
        + '\picwgoal' + IntToStr(AliasTextObj.Width)
        + '\pichgoal' + IntToStr(AliasTextObj.Height) + #13#10;
      FCompressedStream.Position := 0;
      mem := FCompressedStream;
      Writer.WriteString(str);
      if AllowBinary then
      begin
        Writer.WriteString('\bin');
        Writer.WriteInteger(mem.Size);
        Writer.WriteString(#32);
        Writer.WriteStream(mem, false, 0);
      end else
        Writer.WriteStream(mem, true, 0);
      Result := TRUE;
    end else
    begin
      // The caller now tries to save
      Result := FALSE;
    end;
end;

procedure TWPOImage.WriteRTFData(Writer: TWPCustomTextWriter; AliasTextObj: TWPTextObj;
  AllowBinary: Boolean; LinkedToFile: string = '');
type
  TMetafileHeader = packed record
    Key: Longint;
    Handle: SmallInt;
    Box: TSmallRect;
    Inch: Word;
    Reserved: Longint;
    CheckSum: Word;
  end;
var
  bin: TMemoryStream;
  buf: array[0..409] of AnsiChar;
  l, OldPos: Longint;
  InfoHeader: ^TBitmapInfoHeader;
  st, fnam: string;
  i: Integer;
  old_enhanced, Written, shp_mode: Boolean;
begin
  buf[0] := #0;
  fnam := LinkedToFile;
{$IFDEF WPIMG_USE_SOURCE_AS_LINK}
  if fnam = '' then
    fnam := AliasTextObj.Source;
{$ENDIF}
  // "FileName" is optional for HTML, not used here !
  if fnam = '' then fnam := Streamname;

  // Ignore the stream names and EMBED!
  if Writer.OptAlwaysEmbed then fnam := '';

  // Create a file link !
  if (fnam <> '') and
    ((LinkedToFile <> '') or not (soAlwaysEmbedFilesInRTF in Writer.StoreOptions)) then
  begin
         { old fashioned HELPCompiler include }
      (*  if (ReaderWriter is TWPTextWriter) and
          TWPTextWriter(ReaderWriter).FWriteHelpCompilerStyle then
        begin
          StrPLCopy(buf, '\{bmc ' + TWPTextWriter(ReaderWriter).StrToRTFStr(f) + '\}', 200);
        end
        else  *)

    l := Length(fnam);
    st := '';
    i := 1;
    while i <= l do
    begin
      if fnam[i] = '\' then st := st + '\\\\'
      else st := st + fnam[i];
      inc(i);
    end;
    Writer.WriteString(#13 + '{\field{');
    Writer.WriteString('\*\fldinst{INCLUDEPICTURE "');
    Writer.WriteString(st);
    Writer.WriteString('" MERGEFORMAT \\d');

    Writer.WriteString(' \\w'); 
    Writer.WriteInteger(AliasTextObj.Width);
    Writer.WriteString(' \\h'); 
    Writer.WriteInteger(AliasTextObj.Height);

    if AliasTextObj.PositionMode <> wpotChar then 
    begin
      Writer.WriteString(' \\pm');
      Writer.WriteInteger(Integer(AliasTextObj.PositionMode));
      Writer.WriteString(' \\px');
      Writer.WriteInteger(Integer(AliasTextObj.RelX));
      Writer.WriteString(' \\py');
      Writer.WriteInteger(Integer(AliasTextObj.RelY));
      Writer.WriteString(' \\pw');
      Writer.WriteInteger(Integer(AliasTextObj.Wrap));
    end;

    Writer.WriteString('}}}');
  end
  else { ********** Write Graphic in compatible RTF code *************** }
    if Picture <> nil then
    begin
      Written := TRUE;
      bin := nil;

      if wpobjRelativeToParagraph in AliasTextObj.Mode then
      begin
        Writer.WriteString('{\shp{\*\shpinst');
        Writer.WriteString('\shpleft');
        Writer.WriteInteger(AliasTextObj.RelX); // - Writer.RTFDataCollection.Header.LeftMargin);
        Writer.WriteString('\shptop');
        Writer.WriteInteger(AliasTextObj.RelY);
        Writer.WriteString('\shpright');
        Writer.WriteInteger(AliasTextObj.RelX + AliasTextObj.Width); // - Writer.RTFDataCollection.Header.LeftMargin);
        Writer.WriteString('\shpbottom');
        Writer.WriteInteger(AliasTextObj.RelY + AliasTextObj.Height);

        Writer.WriteString('\shpbypara\shpbxpage'); //V5.20.1, was: shpbxpara');
        if AliasTextObj.Frame = [] then
          Writer.WriteString('{\sp{\sn shapeType}{\sv 75}}');
        Writer.WriteString('{\sp{\sn pib}{\sv{');
        shp_mode := TRUE;
      end else
        if wpobjRelativeToPage in AliasTextObj.Mode then
        begin
          Writer.WriteString('{\shp{\*\shpinst');
          Writer.WriteString('\shpleft');
          Writer.WriteInteger(AliasTextObj.RelX);
          Writer.WriteString('\shptop');
          Writer.WriteInteger(AliasTextObj.RelY);
          Writer.WriteString('\shpright');
          Writer.WriteInteger(AliasTextObj.RelX + AliasTextObj.Width);
          Writer.WriteString('\shpbottom');
          Writer.WriteInteger(AliasTextObj.RelY + AliasTextObj.Height);
          Writer.WriteString('\shpbxpage\shpbypage');
          if AliasTextObj.Frame = [] then
            Writer.WriteString('{\sp{\sn shapeType}{\sv 75}}');
          Writer.WriteString('{\sp{\sn pib}{\sv{');
          shp_mode := TRUE;
        end else shp_mode := FALSE;

      if shp_mode then
      begin
        case AliasTextObj.Wrap of
          wpwrAutomatic: Writer.WriteString('\shpwr2\shpwrk3');
          wpwrLeft: Writer.WriteString('\shpwr2\shpwrk1');
          wpwrRight: Writer.WriteString('\shpwr2\shpwrk2');
          wpwrNone: Writer.WriteString('\shpwr3');
          wpwrBoth: Writer.WriteString('\shpwr2\shpwrk0');
          wpwrUseWholeLine: Writer.WriteString('\shpwr1');
        end;
        if wpobjPositionInMargin in AliasTextObj.Mode then
          Writer.WriteString('\wpshppos1')
        else if wpobjPositionAtCenter in AliasTextObj.Mode then
          Writer.WriteString('\wpshppos2')
        else if wpobjPositionAtRight in AliasTextObj.Mode then
          Writer.WriteString('\wpshppos3');
      end
      else Writer.WriteString('{'); //V5.11
      Writer.WriteString('\pict');
      // WriteRTFBitStart;
      OldPos := Writer.GetWritePosition;

   { ------------------ Write special binary data  -------------------}
      if WriteRTFBitmapData(Writer, AliasTextObj, AllowBinary) then
      begin
             // Ok, done
      end
    { ------------------ Write Metafile ------------------------------}
      else if Picture.Graphic is TMetafile then
      try
        bin := TMemoryStream.Create;
        old_enhanced := Picture.Metafile.Enhanced;
 
        begin
          Picture.Metafile.Enhanced := FALSE;
          Picture.Graphic.SaveToStream(bin);
          if bin.Size > 0 then
          begin
            Picture.Metafile.Enhanced := old_enhanced;
            StrPLCopy(buf, '\wmetafile8\picw'
              + IntToStr(MulDiv(AliasTextObj.Width, 254, 144))
              + '\pich' + IntToStr(MulDiv(AliasTextObj.Height, 254, 144))
              + '\picwgoal' + IntToStr(AliasTextObj.Width)
              + '\pichgoal' + IntToStr(AliasTextObj.Height) + #13#10, 200);
            Writer.WriteString(buf);
            bin.Position := 0;
            if AllowBinary then
            begin
              Writer.WriteString('\bin');
              Writer.WriteInteger(bin.Size - Sizeof(TMetafileHeader));
              Writer.WriteString(#32);
              Writer.WriteStream(bin, false, Sizeof(TMetafileHeader));
            end else
              Writer.WriteStream(bin, true, Sizeof(TMetafileHeader));
          end else Written := FALSE;
        end;
      finally
        bin.Free;
      end
      else if Picture.Graphic is TBitmap then
      try
        bin := TMemoryStream.Create;
        Picture.Bitmap.SaveToStream(bin);
        if bin.Size > 0 then
        begin
          InfoHeader := Pointer(Pchar(bin.Memory) + SizeOf(TBitmapFileHeader));
               { l := bin.Size; }
          //h := MulDiv(Picture.Graphic.Height, 1440, 96);
          //w := MulDiv(Picture.Graphic.Width, 1440, 96);
          StrPLCopy(buf, '\dibitmap0'
            + '\wbmbitspixel' + IntToStr(InfoHeader^.biBitCount)
            + '\wbmplanes' + IntToStr(InfoHeader^.biPlanes)
            + '\wbmwidthbytes' + IntToStr((InfoHeader^.biWidth
            * InfoHeader^.biBitCount + 7) div 8)
            + '\picw' + IntToStr(InfoHeader^.biWidth)
            + '\pich' + IntToStr(InfoHeader^.biHeight)
           // + '\picscalex' +  IntToStr(muldiv(AliasTextObj.Width, 100, w))
           // + '\picscaley' +  IntToStr(muldiv(AliasTextObj.Height, 100, h))
            + '\picwgoal' + IntToStr(AliasTextObj.Width)
            + '\pichgoal' + IntToStr(AliasTextObj.Height) + #13#10, 400);
          Writer.WriteString(buf);

          if AllowBinary then
          begin
            Writer.WriteString('\bin');
            Writer.WriteInteger(bin.Size - Sizeof(TBitmapFileHeader));
            Writer.WriteString(#32);
            Writer.WriteStream(bin, false, Sizeof(TBitmapFileHeader));
          end else
            Writer.WriteStream(bin, true, Sizeof(TBitmapFileHeader));
        end else Written := FALSE;
      finally
        bin.Free;
      end;
      if Written then
      begin
        Writer.WriteString('}'); // Pict
        if shp_mode then
          Writer.WriteString('}}}}'); // ShpResult ???
      end else
        Writer.SetWritePosition(OldPos);
    end;
end;

function TWPOImage.ReadRTFData(Reader: TWPCustomTextReader; ReadPicData: TWPReadPictData): Boolean;
const
  BM = $4D42; {Bitmap type identifier}
var
  BMF: TBitmapFileHeader;
  bit: TBitmap;
  res: Integer;
  BMStream: TMemoryStream;
  // BMPSize: longint;
BI: ^TBitmapInfoHeader; 
  Temp: HBITMAP;
  // NumColors: WORD;
  function GetDINColors(BITCOUNT: WORD): INTEGER;
  begin
    case BitCount of
      1, 4, 8: Result := 1 shl BitCount;
    else
      Result := 0;
    end;
  end;
  function WIDTHBYTES(I: LONGINT): LONGINT;
  begin
    Result := ((I + 31) div 32) * 4;
  end;

begin

  res := Screen.PixelsPerInch; // can change !!

     // Let the standard handler check it out first
  Result := inherited ReadRTFData(Reader, ReadPicData);
     // End if this did not work try our luck here
  if not Result and (ReadPicData.pData.Size > 0) then
  begin
    if ReadPicData.pScaleWidth <> 0 then
      ReadPicData.pGoalWidth := MulDiv(ReadPicData.pGoalWidth, ReadPicData.pScaleWidth, 100);
    if ReadPicData.pScaleHeight <> 0 then
      ReadPicData.pGoalHeight := MulDiv(ReadPicData.pGoalHeight, ReadPicData.pScaleHeight, 100);

    if ReadPicData.Name <> '' then { old \*\picfile tag }
    begin
      StreamName := ReadPicData.Name;
      WidthTW := ReadPicData.w;
      HeightTW := ReadPicData.h;
    end
    else
      if ReadPicData.pType = wpreadPictWBitmap then { device dependant Bitmaps }
      begin

        temp := CreateBitmap(ReadPicData.w, ReadPicData.h, ReadPicData.WPlanes,
          ReadPicData.bPixels, ReadPicData.pData.Memory);

        bit := TBitmap.Create; // V5.17.3
        try
          bit.Handle := Temp;
          Graphic := bit;
        finally
          bit.Free;
        end;
        Result := TRUE;
      end
  { Read Device independent Bitmap }
      else
        if ReadPicData.pType = wpreadPictDBitmap then
        try

          BI := ReadPicData.pData.Memory;
          with BI^ do
          begin
            biSizeImage := WidthBytes(Longint(biWidth) * biBitCount) * biHeight;
            // NumColors := GetDInColors(biBitCount);
          end;
          // BMPSize := SizeOf(BI^) + (NumColors * SizeOf(TRGBQuad)) + BI^.biSizeImage;
          BMF.bfType := BM;
          BMStream := TMemoryStream.Create;
          try
        //WRONG: BMStream.SetSize(BMPSize + SizeOf(BMF));
            BMStream.SetSize(ReadPicData.pData.Size + SizeOf(BMF));
            BMStream.Write(BMF, SizeOf(BMF));
        //WRONG: BMStream.Write(BI^, BMPSize); { check for windows problem }
            BMStream.Write(BI^, ReadPicData.pData.Size);
            BMStream.Seek(0, 0);
            try
              bit := TBitmap.Create; // V5.17.3
              try
                bit.LoadFromStream(BMStream);
                Graphic := bit;
                WidthTW := MulDiv(bit.Width, 1440, res);
                HeightTW := MulDiv(bit.Height, 1440, res);
              finally
                bit.Free;
              end;
            except
            end;
          finally
            BMStream.Free;
          end;
          ReadPicData.pData.Position := 0;
          Result := TRUE;

  { Read Metafile }
        except
          Result := FALSE; // cannot load !
        end else
          if ReadPicData.pType = wpreadPictWMetafile then
          begin
            LoadMetafileStream(ReadPicData.pData, ReadPicData.w, ReadPicData.h,
              ReadPicData.mMetafile);
            Result := TRUE;
          end else
            if ReadPicData.pType = wpreadPictPMMetafile then
            begin
              LoadMetafileStream(ReadPicData.pData, ReadPicData.w, ReadPicData.h,
                ReadPicData.mMetafile);
              Result := TRUE;
            end
            else
              if ReadPicData.pType = wpreadPictBMPFile then
              begin
                ReadPicData.pData.Position := 0;
                bit := TBitmap.Create; // V5.17.3
                try
                  bit.LoadFromStream(ReadPicData.pData);
                  bit.Width := ReadPicData.w;
                  bit.Height := ReadPicData.h;
                  Graphic := bit;
                finally
                  bit.Free;
                end;
                WidthTW := MulDiv(ReadPicData.w, 1440, res);
                HeightTW := MulDiv(ReadPicData.h, 1440, res);
                Result := TRUE;
              end
              else if ReadPicData.pType in [wpreadPictJPEG, wpreadPictEMF, wpreadPictPNG] then // PNG - requires GraphicEx
              begin
                ReadPicData.pData.Position := 0;
                try
                  Result := LoadFromStream(ReadPicData.pData);
                  if ((ReadPicData.w = 0) or (ReadPicData.h = 0)) and
                    not ReadPicData.HasWH and (Graphic <> nil) then
                  begin
                    WidthTW := MulDiv(Graphic.Width, 1440, res);
                    HeightTW := MulDiv(Graphic.Height, 1440, res);
                  end else
                  begin
                    WidthTW := MulDiv(ReadPicData.w, 1440, res);
                    HeightTW := MulDiv(ReadPicData.h, 1440, res);
                  end;
                except
                  WidthTW := MulDiv(ReadPicData.w, 1440, res);
                  HeightTW := MulDiv(ReadPicData.h, 1440, res);
                end;
              end;

    // ---------------- Use GoalWidth/Height to size the image! ---------------
    if (ReadPicData.pGoalWidth <> 0) and (ReadPicData.pGoalHeight <> 0) then
    begin
      // TODO: Handle the cropping
      WidthTW := ReadPicData.pGoalWidth - ReadPicData.pCropL - ReadPicData.pCropR;
      HeightTW := ReadPicData.pGoalHeight - ReadPicData.pCropB - ReadPicData.pCropT;
    end else //V5.20.9
    begin
      if ReadPicData.pScaleWidth <> 0 then
        WidthTW := MulDiv(WidthTW, ReadPicData.pScaleWidth, 100);
      if ReadPicData.pScaleHeight <> 0 then
        HeightTW := MulDiv(HeightTW, ReadPicData.pScaleHeight, 100);
    end;
  end;
end;
{$WARNINGS ON}

{ ---------- TWPOCustomShape Class ---------------------------------------- }

constructor TWPOCustomShape.Create(RTFData: TWPRTFDataCollection);
begin
  inherited Create(RTFData);
  FPen := TPen.Create;
  FPen.OnChange := StyleChanged;
  FBrush := TBrush.Create;
  FBrush.OnChange := StyleChanged;
end;

destructor TWPOCustomShape.Destroy;
begin
  FPen.Free;
  FBrush.Free;
  inherited Destroy;
end;

procedure TWPOCustomShape.Paint(toCanvas: TCanvas;
  BoundsRect: TRect; ParentTxtObj: TWPTextObj; PaintMode: TWPTextObjectPaintModes);
var
  X, Y, W, H, S: Integer;
  r: TRect;
begin
  with toCanvas do
  begin
    if Self.Transparent then
    begin
       { fill background ?? }
    end else
    begin
      toCanvas.Brush.Color := Color;
      FillRect(BoundsRect);
    end;

    Pen := FPen;
    Brush := FBrush;
    X := BoundsRect.Left + Pen.Width div 2;
    Y := BoundsRect.Top + Pen.Width div 2;
    W := BoundsRect.Right - BoundsRect.Left - Pen.Width + 1;
    H := BoundsRect.Bottom - BoundsRect.Top - Pen.Width + 1;
    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;
    if W < H then S := W else S := H;
    if FShape in [stSquare, stRoundSquare, stCircle] then
    begin
      Inc(X, (W - S) div 2);
      Inc(Y, (H - S) div 2);
      W := S;
      H := S;
    end;
    case FShape of
      stRectangle, stSquare:
        Rectangle(X, Y, X + W, Y + H);
      stRoundRect, stRoundSquare:
        RoundRect(X, Y, X + W, Y + H, S div 4, S div 4);
      stCircle, stEllipse:
        Ellipse(X, Y, X + W, Y + H);
      stParenteseLeft:
        begin
          MoveTo(X, Y);
          LineTo(x + w - 1, y);
          LineTo(x + w - 1, y + h - Pen.Width);
          LineTo(x, y + h - Pen.Width);
        end;
      stParenteseRight:
        begin
          MoveTo(X + w - 1, Y);
          LineTo(x, y);
          LineTo(x, y + h - Pen.Width);
          LineTo(x + w - 1, y + h - Pen.Width);
        end;
    end;
    if FCaption <> '' then
    begin
      Brush.Style := bsClear;
      r.Top := y;
      r.Bottom := y + h;
      y := TextWidth('A') div 2;
      r.Left := x + y;
      r.Right := x + w - y;
      DrawTextEx(Handle, PChar(FCaption), -1, r,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE or
        DT_END_ELLIPSIS, nil);
    end;
  end;
end;

procedure TWPOCustomShape.StyleChanged(Sender: TObject);
begin
  // Update; { instead of invalidate }
end;

procedure TWPOCustomShape.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TWPOCustomShape.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

function TWPOCustomShape.GetBrush: TBrush; begin Result := FBrush; end;

function TWPOCustomShape.GetPen: TPen; begin Result := FPen; end;

function TWPOCustomShape.GetShape: TShapeType; begin Result := FShape; end;

procedure TWPOCustomShape.SetShape(Value: TShapeType);
begin
  if FShape <> Value then
  begin
    FShape := Value;
    // Update; { instead of invalidate }
  end;
end;

// Register the object class - this works with a global WPToolsEnviroment. If you are
// using per-thread enviroments you need to register the reader in each thread

initialization
  InitializeCriticalSection(FLockImgCritical);

  if GlobalWPToolsCustomEnviroment <> nil then
  begin
    GlobalWPToolsCustomEnviroment.RegisterWPObject([TWPOImage]);
    GlobalWPToolsCustomEnviroment.RegisterWPObject([TWPOShape]);
  end;

finalization

  if GlobalWPToolsCustomEnviroment <> nil then
  begin
    GlobalWPToolsCustomEnviroment.UnRegisterWPObject([TWPOImage]);
    GlobalWPToolsCustomEnviroment.UnRegisterWPObject([TWPOShape]);
  end;

  DeleteCriticalSection(FLockImgCritical);

end.

