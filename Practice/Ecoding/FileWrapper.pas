unit FileWrapper;
//------------------------------------------------------------------------------
{
   Title:       File Wrapper

   Description: Holds wrapper definitions and routines to get and set wrapper details

   Remarks:

   Author:      Matthew Hopkins

}
//------------------------------------------------------------------------------

interface

const
   ECODINGFILE_SIGNATURE = $EC0DE;

type
   pWrapper = ^TWrapper;
   TWrapper = packed Record
      wCRC              : LongWord;
      wSignature        : LongInt;
      wCountry          : Byte;
      wCode             : String[8];
      wName             : String[60];
      wPassword         : String[16];  //encoded md5 string
      wVersion          : LongInt;
      wSave_Count       : LongInt;
      wMagic_Number     : LongInt;
      wUpdateServer     : String[60];
      wSpare            : Array[1..124] of Byte;
   end;

   Function GetWrapper( const Filename : string; var aWrapper : TWrapper): Boolean;
   procedure WrapFile( const Filename : string; const WrappedFilename : string; var aWrapper);
   procedure UnwrapFile( const Filename : string; UnwrappedFilename : string);

   procedure ValidateWrapper( const aWrapper : TWrapper);

//******************************************************************************
implementation
Uses
   Classes,
   SysUtils,
   CRCFileUtils;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function GetWrapper( const Filename : string; var aWrapper : TWrapper): Boolean;
Var FileStream : TFileStream;
    Numread : integer;
begin
   //read file wrapper
  Fillchar(aWrapper, Sizeof(aWrapper), 0);
  result := False;
  FileStream := TFileStream.Create( filename, fmOpenRead);
  try Try
      //check the crc
     CrcFileUtils.CheckEmbeddedCRC( FileStream); // May cause ecxception

     //reposition the cursor to the front of the file and read the wrapper
     FileStream.Position := 0;
     NumRead := FileStream.Read( aWrapper, SizeOf( aWrapper));
     if NumRead <> SizeOf( aWrapper) then begin
        Exit;
     end;

     //check file signature
     if ( aWrapper.wSignature <> FileWrapper.ECODINGFILE_SIGNATURE) then begin
        Exit;
     end;
     aWrapper.wUpdateServer := '';
     {  Do we realy care....
     //check file version no
     if ( aWrapper.wVersion > ECDEFS.EC_FILE_VERSION) then begin
        Exit;
     end;
     }
     // Still here..
     Result := true;
  except
  end;
  finally
     FileStream.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure WrapFile( const Filename : string; const WrappedFilename : string; var aWrapper);
begin
   //save new file with wrapper

   //embed crc
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure UnwrapFile( const Filename : string; UnwrappedFilename : string);
begin
   //remove wrapper and save file to new name

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ValidateWrapper( const aWrapper : TWrapper);
begin
   //check contents of wrapper

end;


end.
