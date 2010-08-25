unit DiskID;

// ----------------------------------------------------------------------------
interface
// ----------------------------------------------------------------------------

Type
  TDiskFormat = ( dfUnknown, dfNZRT86Compatible, dfNZNewFormat, dfOZRT86Compatible, dfOZNewFormat, dfUKNewFormat );

Function GetDiskFormat( Const FileName : String ): TDiskFormat;

// ----------------------------------------------------------------------------
implementation uses Classes, SysUtils, NZDiskObj, NZTypes, OZTypes, UKTypes, NFDiskObj, FHExceptions, NFUtils;
// ----------------------------------------------------------------------------

Function GetDiskFormat( Const FileName : String ): TDiskFormat;
Const
  ProcName = 'DiskID.GetDiskFormat';
Var
  Buffer  : Array[ 1..128 ] of Byte;
  NZID    : NZDiskIDRec Absolute Buffer;
  OZID    : OZDiskIDRec Absolute Buffer;
  UKID    : UKDiskIDRec Absolute Buffer;
  NFID    : NewDiskIDRec Absolute Buffer;
  NumRead : Integer;
  InFile  : File;
Begin
  Result := dfUnknown;
  If not FileExists( FileName ) then Raise FHException.CreateFmt( '%s ERROR: the file %s does not exist', [ ProcName, FileName ] );
  Assign( InFile, FileName );
  Reset( InFile, 1 );
  Try
    BlockRead( InFile, Buffer, Sizeof( Buffer ), NumRead );
    If NumRead <> Sizeof( Buffer ) then exit;
    Case Buffer[1] of
      6 : If OZID.idFileType = 'OZLink' then Result := dfOZRT86Compatible;
      //6 : If UKID.idFileType = 'UKLink' then Result := dfUKRT86Compatible;  //Need a value here for case for UK????
      8 : Begin
            If NZID.idFileType = 'BankLink' then
            Begin
              Result := dfNZRT86Compatible;
              exit;
            end;
            If NFID.nidFileType = NFFileType then
            Begin
              If NFID.nidCountryID = NFCountryNZ then
                Result := dfNZNewFormat
              else
              If NFID.nidCountryID = NFCountryAU then
                Result := dfOZNewFormat
              else
              If NFID.nidCountryID = NFCountryUK then
                Result := dfUKNewFormat;
            end;
          end;
    end; { of Case }
  Finally
    Close( InFile );
  end;
end;

// ----------------------------------------------------------------------------

end.
