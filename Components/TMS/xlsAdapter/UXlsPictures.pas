unit UXlsPictures;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
{$IFDEF LINUX}{$INCLUDE ../FLXCONFIG.INC}{$ELSE}{$INCLUDE ..\FLXCONFIG.INC}{$ENDIF}

interface
uses
  {$IFDEF FLX_VCL}
    Windows, Graphics, JPEG,
    {$IFDEF USEPNGLIB}
      //////////////////////////////// IMPORTANT ///////////////////////////////////////
      //To be able to display PNG images and WMFs, you have to install TPNGImage from http://pngdelphi.sourceforge.net/
      //If you don't want to install it, edit ../FLXCONFIG.INC and delete the line:
      // "{$DEFINE USEPNGLIB}" on the file
      //Note that this is only needed on Windows, CLX has native support for PNG
      ///////////////////////////////////////////////////////////////////////////////////
        pngimage, pngzlib,
      ///////////////////////////////////////////////////////////////////////////////////
      //If you are getting an error here, please read the note above.
      ///////////////////////////////////////////////////////////////////////////////////
    {$ENDIF}
  {$ENDIF}
  {$IFDEF FLX_CLX}
    Qt, QGraphics, QGrids, Types, QControls,
  {$ENDIF}
  {$IFDEF ConditionalExpressions}{$if CompilerVersion >= 14} variants, {$IFEND}{$ENDIF} //Delphi 6 or above

  SysUtils, Classes, UFlxMessages, UExcelAdapter;

  type
  TSmallRect=packed record
    Left,
    Top,
    Right,
    Bottom: SmallInt;
  end;

  //WMF Header
  TMetafileHeader = packed record
    Key: Longint;
    Handle: SmallInt;
    Rect: TSmallRect;

    Inch: Word;
    Reserved: Longint;
    CheckSum: Word;
  end;

////////////////////////////////////////////////////////////////////////
  procedure LoadWmf(const OutPicture: TPicture; const InStream: TStream; const PicType: TXlsImgTypes);
  procedure SaveImgStreamToGraphic(const Pic: TStream; const PicType: TXlsImgTypes; const Picture: TPicture; var Handled: boolean);

  function CreateBmpPattern(const n, ColorFg, ColorBg: integer): TBitmap;
  function ComputeAldusChecksum(var WMF: TMetafileHeader): Word;

////////////////////////////////////////////////////////////////////////

implementation
function ComputeAldusChecksum(var WMF: TMetafileHeader): Word;
type
  PWord = ^Word;
var
  pW: PWord;
  pEnd: PWord;
begin
  Result := 0;
  pW := @WMF;
  pEnd := @WMF.CheckSum;
  while Longint(pW) < Longint(pEnd) do
  begin
    Result := Result xor pW^;
    Inc(Longint(pW), SizeOf(Word));
  end;
end;

{$IFDEF USEPNGLIB}

procedure LoadWmf(const OutPicture: TPicture; const InStream: TStream; const PicType: TXlsImgTypes);
const
  Z_OK=0;
  Z_STREAM_END=1;
var
  WmfHead: TMetafileHeader;
  MemStream, CompressedStream: TMemoryStream;
  ZL: TZStreamRec;
  Buff: Array of char;
  Res, LastOut: integer;
  BoundRect: TRect;
  IsCompressed: byte;
begin
  MemStream:=TMemoryStream.Create;
  try
    if PicType=xli_wmf then
    begin
      //Write Metafile Header
      FillChar(WmfHead, SizeOf(WmfHead), 0);
      WmfHead.Key:=Integer($9AC6CDD7);
      InStream.Position:=4;

      //We can't just read into WmfHead.Rect, because this is small ints, not ints
      InStream.ReadBuffer(BoundRect, SizeOf(BoundRect));
      WmfHead.Rect.Left:=BoundRect.Left;
      WmfHead.Rect.Top:=BoundRect.Top;
      WmfHead.Rect.Right:=BoundRect.Right;
      WmfHead.Rect.Bottom:=BoundRect.Bottom;

      WmfHead.Inch:=96;
      WmfHead.CheckSum:=ComputeAldusChecksum(WmfHead);
      MemStream.WriteBuffer(WmfHead, SizeOf(WmfHead));
    end;

    InStream.Position:=32;
    InStream.Read(IsCompressed, SizeOf(IsCompressed));
    InStream.Position:=34;

    if IsCompressed=0 then //Data is compressed
    begin
      //Uncompress Data
      Fillchar(ZL, SIZEOF(TZStreamRec), #0);

      CompressedStream:=TMemoryStream.Create;
      try
        CompressedStream.CopyFrom(InStream, InStream.Size- InStream.Position);
        CompressedStream.Position:=0;
        FillChar(Zl, SizeOf(Zl), #0);
        Zl.next_in:=CompressedStream.Memory;
        Zl.avail_in:=CompressedStream.Size;
        SetLength(Buff, 2048);     //Arbitrary block size
        Zl.next_out:=@Buff[0];
        Zl.avail_out:=Length(Buff);
        LastOut:=0;
        try
          if InflateInit_(ZL, zlib_version, SIZEOF(TZStreamRec))<> Z_OK then
            raise Exception.Create(ErrInvalidWmf);
          repeat
            Res:=Inflate(ZL,0);
            if (Res<> Z_OK) and (Res<>Z_STREAM_END) then
              raise Exception.Create(ErrInvalidWmf);

            MemStream.WriteBuffer(Buff[0], Zl.Total_Out-LastOut);
            LastOut:=Zl.Total_Out;
            Zl.next_out:=@Buff[0];
            Zl.avail_out:=Length(Buff);
          until Res= Z_STREAM_END;
        finally
          InflateEnd(ZL);
        end; //Finally
      finally
        FreeAndNil(CompressedStream);
      end;
    end else
    begin
      MemStream.CopyFrom(InStream, InStream.Size-InStream.Position);
    end;

    MemStream.Position:=0;
    OutPicture.Graphic.LoadFromStream(MemStream);
  finally
    FreeAndNil(MemStream);
  end; //Finally
end;
{$ELSE}
procedure LoadWmf(const OutPicture: TPicture; const InStream: TStream; const PicType: TXlsImgTypes);
begin
end;
{$ENDIF}

procedure SaveImgStreamToGraphic(const Pic: TStream; const PicType: TXlsImgTypes; const Picture: TPicture; var Handled: boolean);
var
  Bmp:TBitmap;
  {$IFDEF FLX_VCL}
  Jpeg: TJpegImage;
  {$ENDIF}
  {$IFDEF USEPNGLIB}
    Png: TPNGObject;
    Wmf: TMetafile;
  {$ENDIF}
begin
  Handled:=true;
  case PicType of
    {$IFDEF FLX_VCL}
       xli_Jpeg:
       begin
         Jpeg:=TJPEGImage.Create;
         try
           Picture.Graphic:=Jpeg;
         finally
           FreeAndNil(Jpeg); //Remember TPicture.Graphic keeps a COPY of the TGraphic
         end;
         (Picture.Graphic as TJPEGImage).Performance:=jpBestQuality;
         Picture.Graphic.LoadFromStream(Pic);
       end;
      xli_Bmp:
      begin
        Bmp:=TBitmap.Create;
        try
          Picture.Graphic:=Bmp;
         finally
           FreeAndNil(Bmp); //Remember TPicture.Graphic keeps a COPY of the TGraphic
         end;
        Picture.Graphic.LoadFromStream(Pic);
      end;
      //There is no direct support for PNG, because there is not a standard Delphi class to support it.
      //No direct support for wmf/emf, because it uses zlib and it would have to be added to the package list.
      //To support it define USEPNGLIB at the top of this file

      {$IFDEF USEPNGLIB}
        xli_png:
        begin
          Png:=TPNGObject.Create;
          try
            Picture.Graphic:=Png;
           finally
             FreeAndNil(Png); //Remember TPicture.Graphic keeps a COPY of the TGraphic
           end;
          Picture.Graphic.LoadFromStream(Pic);
        end;

        xli_wmf, xli_emf:
        begin
          Wmf:=TMetaFile.Create;
          try
            Picture.Graphic:=Wmf;
          finally
            FreeAndNil(Wmf);
          end; //finally
          LoadWmf(Picture, Pic, PicType);
        end;
      {$ENDIF}

    {$ENDIF}
    {$IFDEF FLX_CLX}
    //Here png is directly supported. Not metafiles...
      xli_Bmp, xli_Jpeg, xli_Png:
      begin
        Bmp:=TBitmap.Create;
        try
          Picture.Graphic:=Bmp;
         finally
           FreeAndNil(Bmp); //Remember TPicture.Graphic keeps a COPY of the TGraphic
         end;
        Picture.Graphic.LoadFromStream(Pic);
      end;
    {$ENDIF}

    else Handled:=False;
  end; //case
end;

{$IFDEF FLX_CLX}
   {$IFDEF VER140}
     {$IFNDEF LINUX}  // Kylix3 is 140 too... and it allows patterns. Patterns are not allowed for d6/bcb6 clx.
       {$DEFINE FLX_NOPATTERN}
     {$ENDIF}
   {$ENDIF}
{$ENDIF}

procedure Fill8x8Image(const Bmp: TBitmap);
begin
  Bmp.Canvas.Draw(0,4,Bmp);
  Bmp.Canvas.Draw(4,0,Bmp);
end;

{$IFDEF FLX_NOPATTERN}
function CreateBmpPattern(const n, ColorFg, ColorBg: integer): TBitmap;
var
  Ac: TCanvas;
begin
  Result:=TBitmap.Create;
  try
    Result.Width:=8;
    Result.Height:=8;
{$IFDEF FLX_CLX}
    Result.PixelFormat:=pf32bit;
{$ELSE}
    Result.PixelFormat := pfDevice; //for win95
{$ENDIF}
    Ac:=Result.Canvas;
    case n of
      1: //No pattern
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,8,8));
        end;
      else //fill pattern     //No pixel support on tcanvas, so we can't use patterns here.
        begin
          Ac.Brush.Color:=ColorFg;
          Ac.FillRect(Rect(0,0,8,8));
        end;
    end; //case
  except
    FreeAndNil(Result);
    raise;
  end;
end;
{$ELSE}
function CreateBmpPattern(const n, ColorFg, ColorBg: integer): TBitmap;
var
  Ac: TCanvas;
  x,y: integer;
begin
  Result:=TBitmap.Create;
  try
    Result.Width:=8; //We just need a 4x4 bitmap, but windows95 does not like it.
    Result.Height:=8;
{$IFDEF FLX_CLX}
    Result.PixelFormat:=pf32bit;
{$ELSE}
    Result.PixelFormat := pfDevice; //for win95
{$ENDIF}
    Ac:=Result.Canvas;
    case n of
      1: //No pattern
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,8,8));
        end;
      2: //fill pattern
        begin
          Ac.Brush.Color:=ColorFg;
          Ac.FillRect(Rect(0,0,8,8));
        end;
      3: //50%
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,8,8));
          for y:=0 to 7 do
            for x:=0 to 3 do
              Ac.Pixels[x*2+y mod 2,y]:=ColorFg;
        end;
      4: //75%
        begin
          Ac.Brush.Color:=ColorFg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[0,0]:=ColorBg;
          Ac.Pixels[2,1]:=ColorBg;
          Ac.Pixels[0,2]:=ColorBg;
          Ac.Pixels[2,3]:=ColorBg;
          Fill8x8Image(Result);
        end;
      5: //25%
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[0,0]:=ColorFg;
          Ac.Pixels[2,1]:=ColorFg;
          Ac.Pixels[0,2]:=ColorFg;
          Ac.Pixels[2,3]:=ColorFg;
          Fill8x8Image(Result);
        end;
      6: //Horz lines
        begin
          Ac.Brush.Color:=ColorFg;
          Ac.FillRect(Rect(0,0,4,2));
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,2,4,4));
          Fill8x8Image(Result);
        end;
      7: //Vert lines
        begin
          Ac.Brush.Color:=ColorFg;
          Ac.FillRect(Rect(0,0,2,4));
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(2,0,4,4));
          Fill8x8Image(Result);
        end;
      8: //   \ lines
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[0,0]:=ColorFg; Ac.Pixels[1,0]:=ColorFg;
          Ac.Pixels[1,1]:=ColorFg; Ac.Pixels[2,1]:=ColorFg;
          Ac.Pixels[2,2]:=ColorFg; Ac.Pixels[3,2]:=ColorFg;
          Ac.Pixels[3,3]:=ColorFg; Ac.Pixels[0,3]:=ColorFg;
          Fill8x8Image(Result);
        end;
      9: //   / lines
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[2,0]:=ColorFg; Ac.Pixels[3,0]:=ColorFg;
          Ac.Pixels[1,1]:=ColorFg; Ac.Pixels[2,1]:=ColorFg;
          Ac.Pixels[0,2]:=ColorFg; Ac.Pixels[1,2]:=ColorFg;
          Ac.Pixels[3,3]:=ColorFg; Ac.Pixels[0,3]:=ColorFg;
          Fill8x8Image(Result);
        end;
      10: //  diagonal hatch
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[0,0]:=ColorFg; Ac.Pixels[1,0]:=ColorFg;
          Ac.Pixels[0,1]:=ColorFg; Ac.Pixels[1,1]:=ColorFg;
          Ac.Pixels[2,2]:=ColorFg; Ac.Pixels[3,2]:=ColorFg;
          Ac.Pixels[2,3]:=ColorFg; Ac.Pixels[3,3]:=ColorFg;
          Fill8x8Image(Result);
        end;
      11: //  bold diagonal
        begin
          Ac.Brush.Color:=ColorFg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[2,0]:=ColorBg; Ac.Pixels[3,0]:=ColorBg;
          Ac.Pixels[0,2]:=ColorBg; Ac.Pixels[1,2]:=ColorBg;
          Fill8x8Image(Result);
        end;
      12: //  thin horz lines
        begin
          Ac.Brush.Color:=ColorFg;
          Ac.FillRect(Rect(0,0,4,1));
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,1,4,4));
          Fill8x8Image(Result);
        end;
      13: //  thin vert lines
        begin
          Ac.Brush.Color:=ColorFg;
          Ac.FillRect(Rect(0,0,1,4));
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(1,0,4,4));
          Fill8x8Image(Result);
        end;
      14: //  thin \ lines
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[0,0]:=ColorFg;
          Ac.Pixels[1,1]:=ColorFg;
          Ac.Pixels[2,2]:=ColorFg;
          Ac.Pixels[3,3]:=ColorFg;
          Fill8x8Image(Result);
        end;
      15: //  thin / lines
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[3,0]:=ColorFg;
          Ac.Pixels[2,1]:=ColorFg;
          Ac.Pixels[1,2]:=ColorFg;
          Ac.Pixels[0,3]:=ColorFg;
          Fill8x8Image(Result);
        end;
      16: //  thin horz hatch
        begin
          Ac.Brush.Color:=ColorFg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(1,1,4,4));
          Fill8x8Image(Result);
        end;
      17: //  thin diag
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[0,0]:=ColorFg; Ac.Pixels[2,0]:=ColorFg;
          Ac.Pixels[1,1]:=ColorFg;
          Ac.Pixels[0,2]:=ColorFg; Ac.Pixels[2,2]:=ColorFg;
          Ac.Pixels[3,3]:=ColorFg;
          Fill8x8Image(Result);
        end;
      18: //  12.5 %
        begin
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,4,4));
          Ac.Pixels[0,0]:=ColorFg;
          Ac.Pixels[2,2]:=ColorFg;
          Fill8x8Image(Result);
        end;
      19: //  6.25 %
        begin
          //Not needed now. Result.Width:=8;
          Ac.Brush.Color:=ColorBg;
          Ac.FillRect(Rect(0,0,8,8));
          Ac.Pixels[0,0]:=ColorFg;
          Ac.Pixels[4,2]:=ColorFg;
          Ac.Pixels[0,4]:=ColorFg;
          Ac.Pixels[4,6]:=ColorFg;
        end;
    end; //case
  except
    FreeAndNil(Result);
    raise;
  end;
end;
{$ENDIF}


end.
