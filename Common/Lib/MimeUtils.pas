unit MimeUtils;
//------------------------------------------------------------------------------
{
   Title:       Mime Encoding/Decoding Utilities

   Description:

   Author:      Matthew Hopkins

   Remarks:     Allows us to mime encode an image into a stream

                Note: Delphi 6 crashes while stepping thru this code when
               the "local variables" debug window is turned on
}
//------------------------------------------------------------------------------

interface
uses
  Classes, Graphics, jpeg;

function EncodeImageToString( Filename : string) : string;
procedure DecodePictureFromString( S : string; aPicture : TPicture);
//******************************************************************************
implementation
uses
  DIMIMEStreams,
  SysUtils,
  WinUtils;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EncodeImageToString( Filename : string) : string;
var
  InputStream  : TMemoryStream;
  OutputStream : TStringStream;
begin
  result := '';
  if not BKFileExists( Filename) then exit;

  InputStream := TMemoryStream.Create;
  try
    OutputStream := TStringStream.Create('');
    try
      //load the file from disc
      InputStream.LoadFromFile( Filename);
      //MIME encode the file
      MimeEncodeStream(InputStream, OutputStream);
      //MIME encoded data is accessed via the DataString property
      result := OutputStream.DataString;
    finally
      OutputStream.Free;
    end;
  finally
    InputStream.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DecodePictureFromString( S : string; aPicture : TPicture);
var
  SourceStream       : TStringStream;
  OutputStream       : TMemoryStream;
  FileHeader         : Longword;
  NewGraphic         : TGraphic;
begin
  if S = '' then exit;

  //need to load the string into a stream so can encode
  SourceStream := TStringStream.Create( S);
  try
    OutputStream := TMemoryStream.Create;
    try
      //mime decode image
      SourceStream.Position := 0;
      MimeDecodeStream(SourceStream,OutputStream);
      //read header bytes so can determine graphic type
      OutputStream.Position := 0;
      OutputStream.Read(FileHeader,SizeOf(FileHeader));
      OutputStream.Position := 0;
      if ((FileHeader and $0000FFFF) = $4D42) then
      begin
        //bitmap
        NewGraphic := TBitmap.Create;
        try
          NewGraphic.LoadFromStream( OutputStream);
          aPicture.Graphic := NewGraphic;
        finally
          NewGraphic.Free;
        end;
      end
      else if ((FileHeader and $00FFFFFF) = $00FFD8FF) then
      begin
        //jpeg
        NewGraphic := TJPEGImage.Create;
        try
          NewGraphic.LoadFromStream( OutputStream);
          aPicture.Graphic := NewGraphic;
        finally
          NewGraphic.Free;
        end;
      end;
    finally
      OutputStream.Free;
    end;
  finally
    SourceStream.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
