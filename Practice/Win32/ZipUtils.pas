unit ZipUtils;
//------------------------------------------------------------------------------
{
   Title:       Zip Utils

   Description: BK Zip/Unzip utilities.  Decend from Abbrevia components

   Remarks:     Raise ECompressionFailure if fails

   Author:      Matthew Hopkins  Nov 2001

}
//------------------------------------------------------------------------------
interface

uses
  VCLZip, Classes;

   procedure CompressFile( const SourceFilename : string; const DestFilename : string);
   function CompressString(const SourceStr: String; HttpCompression: Boolean = False): String;
   procedure CompressStream(Source, Dest: TStream; HttpCompression: Boolean = False);

//******************************************************************************
implementation
uses
   bk5Except,
   sysUtils;

const
   Unitname = 'ZIPUTILS';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CompressFile( const SourceFilename : string; const DestFilename : string);
//raise an exception if compress fails
var
  Zipper : TVCLZip;
begin
  Zipper := TVCLZip.Create( nil);
  try
    try
      Zipper.ZipName     := DestFilename;
      Zipper.FilesList.Add( SourceFilename);
      Zipper.StorePaths  := False;
      Zipper.Zip;
    except
      //reraise any errors as compression failure
      on e : exception do
      begin
        raise ECompressionFailure.Create( 'Compression failure compressing ' +
                                          SourceFilename + ' to ' +
                                          DestFilename + '  '+
                                          e.Message +
                                          ' [' + e.Classname + ']');
      end;
    end;
  finally
    Zipper.Free;
  end;
end;

function CompressString(const SourceStr: String; HttpCompression: Boolean = False): String;
var
  Zipper : TVCLZip;
begin
  Zipper := TVCLZip.Create( nil);
  try
    try
      Result := Zipper.ZLibCompressStr(SourceStr, HttpCompression);
    except
      on E:Exception do
      begin
        raise ECompressionFailure.Create(E.Message);
      end;  
    end;
  finally
    Zipper.Free;
  end;
end;

procedure CompressStream(Source, Dest: TStream; HttpCompression: Boolean = False);
var
  Zipper : TVCLZip;
begin
  Zipper := TVCLZip.Create( nil);
  try
    try
      Zipper.ZLibCompressStream(Source, Dest, HttpCompression);
    except
      on E:Exception do
      begin
        raise ECompressionFailure.Create(E.Message);
      end;
    end;
  finally
    Zipper.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
