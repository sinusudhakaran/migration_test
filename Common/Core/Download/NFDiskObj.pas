unit NFDiskObj;

// ----------------------------------------------------------------------------
interface uses BaseDisk, Classes, NFUtils;
// ----------------------------------------------------------------------------

type
  FileExtractProc = procedure (const FileName: string; filestream: TStream) of object;

type
  TNewFormatDisk = class ( TBankLink_Disk )
  protected
    function  GetZipStream( Const FileName : String; Var ID : NewDiskIDRec ): TMemoryStream; overload;
    function  GetZipStream( FileStream: TStream; Var ID : NewDiskIDRec): TMemoryStream; overload;
    Function  SaveToNFStream: TMemoryStream;
    Procedure LoadFromNFStream( AStream : TMemoryStream );
    procedure SetID(ID : NewDiskIDRec);
  private
  public
    procedure Validate; Override;
    function  CanAddAccount: Boolean; Virtual; Abstract;
    function  CanAddTransaction: Boolean; Virtual; Abstract;
    procedure SaveAsText( Const FileName : String ); Override;
    procedure SaveAsExport( Const FileName : String );
    procedure SaveToFile( Const FileName : String; Const Attachments : TStringList );
    function  LoadFromFile( Const FileName : String;
                            Const AttachmentDir : String;
                            Const GetAttachments : Boolean ): TStringList;



    procedure SaveToFileOF( Const FileName : String; Const Attachments : TStringList ); Virtual; Abstract;
    function  LoadFromFileOF( Const FileName : String;
                            Const AttachmentDir : String;
                            Const GetAttachments : Boolean ): TStringList; Virtual; Abstract;

    procedure ExtractFromStreamOF(const FileName: string;
                                  FileStream: TStream;
                                  ToProc: FileExtractProc); Virtual; Abstract;

    procedure ExtractFromStream(const FileName: string;
                                FileStream: TStream;
                                ToProc: FileExtractProc);

    procedure LoadFromUpdateFile( const FileName: string);
    procedure WriteLabelFile(const FileName: string);
  end;

  //declared this object so do not have to create and instance of TNewFormatDisk
  //which has virtual methods
  TUpdateDiskReader = class( TNewFormatDisk)
  public
    function  CanAddAccount : boolean;  override;
    function  CanAddTransaction : boolean;  override;
    procedure SaveToFileOF( Const FileName : String; Const Attachments : TStringList ); override;
    function  LoadFromFileOF( Const FileName : String; Const AttachmentDir : String; Const GetAttachments : Boolean ): TStringList; override;

    procedure ExtractFromStreamOF(const FileName: string;
                                  FileStream: TStream;
                                  ToProc: FileExtractProc); override;

    procedure LoadFromUpdateFile( const FileName: string);
    procedure Validate; override;
  end;

// ----------------------------------------------------------------------------
implementation uses SysUtils, VCLZip, dbObj, FHDefs, dtList,
  CRC32, CRCFileUtils, CryptX, StStrS, StDate, StDateSt, (* ProcUtils, *)
  StreamIO, FHDTIO, FHExceptions, dbList, ECollect;
// ----------------------------------------------------------------------------

Const
  DefEpoch = 1970;

// -----------------------------------------------------------------------------

Function Date2Str( ADate : Integer ): ShortString;
Begin
  If ADate >0 then
    Result := StDateToDateString( 'dd/mm/yy', ADate, False )
  else
    Result := '';
end;
// -----------------------------------------------------------------------------

Function Str2Date( S : String ): Integer;
Begin
  If Trim(S)<>'' then
    Result := DateStringToStDate( 'dd/mm/yy', Trim(S), DefEpoch )
  else
    Result := 0;
end;
// -----------------------------------------------------------------------------

procedure S2A(const S: string; Var A: array of char);
// Copy string to array of char
var
  i,l: integer;
Begin
  l:=length(S)-1;
  for i:=0 to High(A) do
    if i<=l then
      A[i]:=S[i+1]
    else
      A[i]:=' ';
end;
//------------------------------------------------------------------------------

Function FieldS( SourceStr : String; FieldNo : Integer ): ShortString;
//note: TrimRight is used on the result because the client software does
//      not expect fields that are padded with spaces.
Var
  no, i : Integer;
  RLen : Byte Absolute Result;
Begin
  RLen := 0;
  no := 1;
  For i := 1 to Length( SourceStr ) do
  Begin
    If SourceStr[ i ] = '|' then
    Begin
      If ( no = FieldNo ) then
      begin
        //have found the vertical bar that indicates the
        //end of the current field
        Result := TrimRight( Result);   //see note above
        exit;
      end;
      Inc( no );
      RLen := 0;
    end
    else
    If ( no = FieldNo ) then
    Begin
      Inc( RLen );
      Result[ RLen ] := SourceStr[i];
    end;
  end;
  //this will only be hit when the requested field is the last field
  //and the string does not end with a seperator
  //Assert( No = FieldNo );

  if FieldNo>No then
    Result:='';        // to allow reading of old images by new builds

  Result := TrimRight( Result);         //see note above
end;
//------------------------------------------------------------------------------

Function RM( Const S : ShortString ): Int64;
Var
  E : Integer;
Begin
  If Trim(S) = '' then
    Result := Unknown
  else
  Begin
    Val( Trim(S), Result, E );
    Assert( E=0 );
  end;
end;
//------------------------------------------------------------------------------

Function RI( Const S : ShortString ): Integer;
Var
  E : Integer;
Begin
  Val( Trim(S), Result, E );
  Assert( E=0 );
end;
//------------------------------------------------------------------------------

Function RID( Const S : ShortString; const default: integer ): Integer;
Var
  E : Integer;
Begin
  If Trim(S) = '' then
    Result := default
  else
  begin
    Val( Trim(S), Result, E );
    Assert( E=0 );
  end
end;
//------------------------------------------------------------------------------

Function TNewFormatDisk.SaveToNFStream: TMemoryStream;
Var
  OutFile      : TextFile;

  Procedure WS( S : ShortString );
  Var
    SLen : Byte Absolute S;
    i : Integer;
  Begin
    For i := 1 to SLen do
      If ( S[i]<' ' ) or ( S[i]='|' ) or ( S[i]>#$7F ) then
        S[i] := ' ';
    S := TrimRight( S);
    Write( OutFile, '|', S );
  end;

  Procedure WM( Const M : Int64 );
  Begin
    If M = Unknown then
      Write( OutFile, '|' )
    else
      Write( OutFile, '|', M );
  end;

  Procedure WD( Const D : Integer );
  Begin
    Write( OutFile, '|', Date2Str( D ) );
  end;

  Procedure WI( Const I : Integer );
  Begin
    Write( OutFile, '|', i );
  end;

  procedure WB( const B: boolean);
  begin
    if B then
      WS('Y')
    else
      WS('N');
  end;

Var
  i, t         : Integer;
  DBA          : TDisk_Bank_Account;
  P            : pDisk_Transaction_Rec;
  OutStream    : TMemoryStream;
  TotalCredits,
  TotalDebits  : Int64;
Begin
  (* Profile( 'TNewFormatDisk.SaveToNFStream' ); *)
  OutStream := TMemoryStream.Create;
  AssignStream( OutFile, OutStream ); { See StreamIO unit }
  Rewrite( OutFile );

  TotalCredits:=0;
  TotalDebits:=0;

  Write( OutFile, 'F' );              // File header
  WS(NFFileType);
  WS(NFDataStr);
  WS(whCountryCodes[dhFields.dhCountry_Code]);
  WS(NFVersion);
  WS(NFExpFields);
  WS(dhFields.dhClient_Code);
  WS(dhFields.dhClient_Name);
  WD(dhFields.dhCreation_Date);
  WD(dhFields.dhFirst_Transaction_Date);
  WD(dhFields.dhLast_Transaction_Date);
  WI(dhFields.dhDisk_Number);
  WI(dhFields.dhSequence_In_Set);
  WI(dhFields.dhNo_Of_Disks_in_Set);
  Writeln( OutFile );

  For i := dhAccount_List.First to dhAccount_List.Last do
  Begin
    DBA := dhAccount_List.Disk_Bank_Account_At( i );

    Write( OutFile, 'A' );                 // Account header
    WS( DBA.dbFields.dbAccount_Number );
    WS( DBA.dbFields.dbOriginal_Account_Number );
    WS( DBA.dbFields.dbAccount_Name );
    WS( DBA.dbFields.dbFile_Code );
    WS( DBA.dbFields.dbCost_Code );
    WS( DBA.dbFields.dbBank_Prefix );
    WS( DBA.dbFields.dbBank_Name );
    WM( DBA.dbFields.dbOpening_Balance );
    WM( DBA.dbFields.dbClosing_Balance );
    WB( DBA.dbFields.dbCan_Redate_Transactions );
    WB( DBA.dbFields.dbIs_New_Account );
    WB( DBA.dbFields.dbContinued_On_Next_Disk );
    WS( DBA.dbFields.dbCurrency );
    WI( DBA.dbFields.dbInstitution_ID );
    WI( DBA.dbFields.dbAccount_LRN );
    WI( DBA.dbFields.dbFrequency_ID );
    WB( DBA.dbFields.dbIs_Provisional );
    Writeln( OutFile );

    For t := DBA.dbTransaction_List.First to DBA.dbTransaction_List.Last do
    Begin
      P := DBA.dbTransaction_List.Disk_Transaction_At( t );
      Write( OutFile, 'E' );               // Transaction
      WI( P.dtBankLink_ID );
      WI( P.dtEntry_Type );
      WD( P.dtEffective_Date );
      WD( P.dtOriginal_Date );
      WS( P.dtBank_Type_Code_OZ_Only );
      WS( P.dtDefault_Code_OZ_Only );
      WM( P.dtAmount );
      WM( P.dtGST_Amount );
      WB( P.dtGST_Amount_Known );
      WS( P.dtReference );
      WS( P.dtNarration );
      WS( P.dtAnalysis_Code_NZ_Only );
      WS( P.dtOther_Party_NZ_Only );
      WS( P.dtParticulars_NZ_Only );
      WS( P.dtOrig_BB );
      WM( P.dtQuantity );
      WI( P.dtBankLink_ID_H );
      Writeln( OutFile );
    end;

    Write( OutFile, 'T' );              // Account trailer
    WM( DBA.dbFields.dbCredit_Total );
    WM( DBA.dbFields.dbDebit_Total );
    WI( DBA.dbFields.dbNo_Of_Transactions );
    Writeln( OutFile );

    TotalCredits:=TotalCredits+DBA.dbFields.dbCredit_Total;
    TotalDebits:=TotalDebits+DBA.dbFields.dbDebit_Total;
  end;
  Write( OutFile, 'X' );                // File trailer
  WM(TotalCredits);
  WM(TotalDebits);
  WI(dhFields.dhNo_Of_Accounts);
  WI(dhFields.dhNo_Of_Transactions);
  Writeln( OutFile );

  Close( OutFile );
  OutStream.Position := 0;
  Result := OutStream;
end;

procedure TNewFormatDisk.SetID(ID: NewDiskIDRec);

 function InsertDot(inp: array of char): string;
  var
    i: integer;
    cnt: integer;
  begin
    result:='';
    i:=High(inp);
    while (i>0) and (inp[i]<=' ') do
      Dec(i);
    for cnt:=1 to 3 do
    begin
      result:=inp[i]+result;
      Dec(i);
    end;
    result:='.'+result;
    for cnt:=i downto 0 do
    begin
      result:=inp[i]+result;
      Dec(i);
    end
  end;


begin
   EmptyDisk;

   if ID.nidCountryID = NFCountryNZ then
      dhFields.dhCountry_Code := whNewZealand
   else if ID.nidCountryID = NFCountryAU then
      dhFields.dhCountry_Code := whAustralia
   else if ID.nidCountryID = NFCountryUK then
      dhFields.dhCountry_Code := whUnitedKingdom;

   dhFields.dhVersion        := Trim(ID.nidVersion);
   dhFields.dhFile_SubType   := Trim(ID.nidFileSubType);

   dhFields.dhCreation_Date := Str2Date( ID.nidFileDate );

   case dhFields.dhCountry_Code of
      whNewZealand :
        begin
          dhFields.dhFloppy_Desc_NZ_Only := Trim(ID.nidFloppyDesc);
          if ID.nidThisDiskNumber<3600 then
            dhFields.dhFile_Name := InsertDot( ID.nidFloppyDesc )
          else
            dhFields.dhFile_Name := Trim(ID.nidFloppyDesc);
        end;
      whAustralia  : dhFields.dhFile_Name := Trim(ID.nidFloppyDesc);
      whUnitedKingdom  : dhFields.dhFile_Name := Trim(ID.nidFloppyDesc);
   end;

   dhFields.dhTrue_File_Name:=Trim(ID.nidFileName);

   dhFields.dhFirst_Transaction_Date := Str2Date( ID.nidFromDate );
   dhFields.dhLast_Transaction_Date := Str2Date( ID.nidToDate );
   dhFields.dhClient_Code          := Trim(ID.nidClientCode);
   dhFields.dhClient_Name          := TrimRight(ID.nidClientName);
   dhFields.dhDisk_Number          := ID.nidThisDiskNumber;
   dhFields.dhSequence_In_Set      := ID.nidSequenceInSet;
   dhFields.dhNo_Of_Disks_in_Set   := ID.nidNoOfDisksInSet;

end;

//------------------------------------------------------------------------------

Procedure TNewFormatDisk.LoadFromNFStream( AStream : TMemoryStream );
Var
  InFile : TextFile;
  DBA    : TDisk_Bank_Account;
  P      : pDisk_Transaction_Rec;
  InStr  : String;
Begin
  (* Profile( 'TNewFormatDisk.LoadFromNFStream' ); *)

  Assert( Assigned( AStream ) );
  Assert( AStream.Size > 0 );

  Assert( dhAccount_List.ItemCount = 0 );

  AStream.Position := 0;
  DBA := NIL;

  AssignStream( InFile, AStream );
  Reset( InFile );

  While not EOF( InFile ) do
  Begin
    Readln( InFile, InStr );
    If Length( InStr ) > 0 then
    Begin
      Case InStr[1] of
        'A' :
          Begin
            DBA := TDisk_Bank_Account.Create;
            DBA.dbFields.dbAccount_Number          := FieldS( InStr, 2 );
            DBA.dbFields.dbOriginal_Account_Number := FieldS( InStr, 3 );
            DBA.dbFields.dbAccount_Name            := FieldS( InStr, 4 );
            DBA.dbFields.dbFile_Code               := FieldS( InStr, 5 );
            DBA.dbFields.dbCost_Code               := FieldS( InStr, 6 );
            DBA.dbFields.dbBank_Prefix             := FieldS( InStr, 7 );
            DBA.dbFields.dbBank_Name               := FieldS( InStr, 8 );
            DBA.dbFields.dbOpening_Balance         := RM( FieldS( InStr, 9 ) );
            DBA.dbFields.dbClosing_Balance         := RM( FieldS( InStr, 10 ) );
            DBA.dbFields.dbCan_Redate_Transactions := ( FieldS( InStr, 11 ) = 'Y' );
            DBA.dbFields.dbIs_New_Account          := ( FieldS( InStr, 12 ) = 'Y' );
            DBA.dbFields.dbContinued_On_Next_Disk  := ( FieldS( InStr, 13 ) = 'Y' );
            DBA.dbFields.dbCurrency                := FieldS( InStr, 14 );
            DBA.dbFields.dbInstitution_ID          := RID( FieldS( InStr, 15 ), 0 );
            DBA.dbFields.dbAccount_LRN             := RID( FieldS( InStr, 16 ), 0 );
            DBA.dbFields.dbFrequency_ID            := RID( FieldS( InStr, 17 ), 0 );
            DBA.dbFields.dbIs_Provisional          := ( FieldS( InStr, 18 ) = 'Y' );

            dhAccount_List.Insert( DBA );
            Inc( dhFields.dhNo_Of_Accounts );
          end;
        'E' :
          Begin
            P := FHDTIO.New_Disk_Transaction_Rec;
            P.dtBankLink_ID                 := RI( FieldS( InStr, 2 ) );
            P.dtEntry_Type                  := RI( FieldS( InStr, 3 ) );
            P.dtEffective_Date              := Str2Date( FieldS( InStr, 4 ) );
            P.dtOriginal_Date               := Str2Date( FieldS( InStr, 5 ) );
            P.dtBank_Type_Code_OZ_Only      := FieldS( InStr, 6 );
            P.dtDefault_Code_OZ_Only        := FieldS( InStr, 7 );
            P.dtAmount                      := RM( FieldS( InStr, 8 ) );
            P.dtGST_Amount                  := RM( FieldS( InStr, 9 ) );
            P.dtGST_Amount_Known            := ( FieldS( InStr, 10 ) = 'Y' );
            P.dtReference                   := FieldS( InStr, 11 );
            P.dtNarration                   := FieldS( InStr, 12 );
            P.dtAnalysis_Code_NZ_Only       := FieldS( InStr, 13 );
            P.dtOther_Party_NZ_Only         := FieldS( InStr, 14 );
            P.dtParticulars_NZ_Only         := FieldS( InStr, 15 );
            P.dtOrig_BB                     := FieldS( InStr, 16 );
            P.dtQuantity                    := RM( FieldS( InStr, 17 ) );
            P.dtBankLink_ID_H               := RID( FieldS( InStr, 18 ), 0 );

            if (DBA.dbFields.dbFirst_Transaction_Date=0) or
               (DBA.dbFields.dbFirst_Transaction_Date>P.dtEffective_Date) then
              DBA.dbFields.dbFirst_Transaction_Date:=P.dtEffective_Date;
            if DBA.dbFields.dbLast_Transaction_Date<P.dtEffective_Date then
              DBA.dbFields.dbLast_Transaction_Date:=P.dtEffective_Date;

            DBA.dbTransaction_List.Insert( P );
            Inc( dhFields.dhNo_Of_Transactions );
          end;
        'T' :
          Begin
            DBA.dbFields.dbCredit_Total       := RM( FieldS( InStr, 2 ) );
            DBA.dbFields.dbDebit_Total        := RM( FieldS( InStr, 3 ) );
            DBA.dbFields.dbNo_Of_Transactions := RI( FieldS( InStr, 4 ) );
          end;
        'X' :
          Begin
          end;
      end; { of Case }
    end;
  end;
  Close( InFile );
end;



// -----------------------------------------------------------------------------

procedure TNewFormatDisk.SaveToFile( Const FileName : String; Const Attachments : TStringList );
Const
  ChunkSize = 8192;
  ProcName = 'TNewFormatDisk.SaveToFile';
Var
  i            : Integer;
  ID           : NewDiskIDRec;
  Buffer       : Pointer;
  CRC          : LongInt;
  MemoryStream : TMemoryStream;
  ZipStream    : TMemoryStream;
  FileStream   : TMemoryStream;
  NumRead      : Integer;
  NumWritten   : Integer;
  Zipper       : TVclZip;
Begin
  (* Profile( 'TNewFormatDisk.SaveToFile' ); *)
  Validate;
  { Generate the File Header Record }
  FillChar( ID, Sizeof( ID ), 0 );
  With ID do
  Begin
    S2A(NFFileType,nidFileType);
    S2A(NFDataStr,nidFileSubType);
    S2A(whCountryCodes[dhFields.dhCountry_Code],nidCountryID);
    S2A(NFVersion,nidVersion);
    S2A(ExtractFileName(FileName),nidFileName);
    Case dhFields.dhCountry_Code of
      whNewZealand :
        begin
          if dhFields.dhDisk_Number<3600 then
            S2A(dhFields.dhFloppy_Desc_NZ_Only,nidFloppyDesc) { 'XXXXXXXnnn' }
          else
            S2A(dhFields.dhFile_Name,nidFloppyDesc);
        end;
      whAustralia  : S2A(dhFields.dhFile_Name,nidFloppyDesc);
      whUnitedKingdom  : S2A(dhFields.dhFile_Name,nidFloppyDesc);
    end;
    S2A(dhFields.dhClient_Code,nidClientCode);
    S2A(dhFields.dhClient_Name,nidClientName);
    S2A(Date2Str(dhFields.dhCreation_Date),nidFileDate);
    S2A(Date2Str(dhFields.dhFirst_Transaction_Date),nidFromDate);
    S2A(Date2Str(dhFields.dhLast_Transaction_Date),nidToDate);
    nidThisDiskNumber   := dhFields.dhDisk_Number;
    nidSequenceInSet    := dhFields.dhSequence_In_Set;
    nidNoOfDisksInSet   := dhFields.dhNo_Of_Disks_in_Set;
    nidCRC              := 0;
  end;

  ZipStream := TMemoryStream.Create;
  Try
    ZipStream.Clear;
    ZipStream.Position := 0;
    Zipper := TVclZip.Create( NIL );
    Try
      Zipper.StorePaths := False;
      Zipper.ArchiveStream := ZipStream;
      { We're going to save the data in each format }
      MemoryStream := nil;
      Try
        MemoryStream := SaveToNFStream;
        Zipper.ZipFromStream( MemoryStream, 'DATA' );
      Finally
        MemoryStream.Free;
      end;

      If Assigned( Attachments ) then
      Begin
        For i := 0 to Pred( Attachments.Count ) do
        Begin
          FileStream := TMemoryStream.Create;
          Try
            FileStream.LoadFromFile( Attachments[ i ] );
            FileStream.Position := 0;
            Zipper.ZipFromStream( FileStream, ExtractFileName( Attachments[ i ] ) )
          Finally
            FileStream.Free;
          end;
        end;
      end;
      ZipStream := TMemoryStream( Zipper.ArchiveStream );
      Zipper.ArchiveStream := NIL;
    Finally
      Zipper.Free;
    end;

  { The Zip data is now sitting in the ZipStream TMemoryStream
    We need to read this and encrypt it }

    FileStream := TMemoryStream.Create;

    Try
      FileStream.Clear;
      FileStream.Position := 0;

      CRC := 0;
      UpdateCRC( CRC, ID, Sizeof( ID ) );
      FileStream.Write( ID, Sizeof( ID ) );

      GetMem( Buffer, ChunkSize );
      Try
        ZipStream.Position := 0;
        repeat
          NumRead := ZipStream.Read( Buffer^, ChunkSize );
          if NumRead > 0 then
          begin
            Encrypt( Buffer^, NumRead );
            UpdateCRC( CRC, Buffer^, NumRead );
            NumWritten := FileStream.Write( Buffer^, NumRead );
            if not ( NumWritten = NumRead ) then Raise FHException.Create( 'Error writing to FileStream Memory Stream' );
          end;
        until NumRead < ChunkSize;
      Finally
        FreeMem( Buffer, ChunkSize );
      end;

      FileStream.Position := 0;
      ID.nidCRC := CRC;
      FileStream.Write( ID, Sizeof( ID ) );
      FileStream.Position := 0;
      FileStream.SaveToFile( FileName );
    Finally
      FileStream.Free;
    end;
  Finally
    ZipStream.Free;
  end;
end;
// -----------------------------------------------------------------------------

procedure TNewFormatDisk.ExtractFromStream
    (const FileName: string;
     FileStream: TStream;
     ToProc: FileExtractProc);

Const
  ProcName = 'TNewFormatDisk.ExtractFromStream';
Var
  Files          : TStringList;
  ZipStream      : TMemoryStream;
  UnZipper       : TVclZip;
  DataStream     : TMemoryStream;
  i              : Integer;
  Index          : Integer;
  ID             : NewDiskIDRec;
begin
  (* Profile( ProcName ); *)

  ZipStream := nil;
  try
    ZipStream := GetZipStream( FileStream, ID );

    SetID(ID);

    UnZipper := TVCLZip.Create( NIL );
    Files := TStringList.Create;
    Try
      UnZipper.ArchiveStream := ZipStream;
      UnZipper.ReadZip;
      For i := 0 to Pred( UnZipper.Count ) do
         Files.Add( UnZipper.Filename[ i ] );
      Index := Files.IndexOf( 'DATA' );
      If Index >= 0 then
      Begin
        DataStream := TMemoryStream.Create;
        Try
          UnZipper.UnZipToStream( DataStream, 'DATA' );
          DataStream.Position := 0;
          Self.LoadFromNFStream( DataStream );
        Finally
          DataStream.Free;
        end;
      end
      else
        Raise FHException.CreateFmt( '%s Error: Couldn''t find any data in the file %s', [ ProcName, FileName ] );

      If Assigned(ToProc) then begin
        For i := 0 to Pred( UnZipper.Count ) do
        Begin
          If Files[ i ] <> 'DATA' then
          Begin { it's an attachment file }
            FileStream := TMemoryStream.Create;
            try
              UnZipper.UnZipToStream( FileStream, UnZipper.FullName[ i ] );
              FileStream.Position := 0;
              ToProc(UnZipper.FullName[i],FileStream);
            finally
              FileStream.Free;
            end;
          end;
        end;
      end;
      UnZipper.ArchiveStream := NIL;
    Finally
      Files.Free;
      UnZipper.Free;
    end;
  Finally
    ZipStream.Free;
  end;
end;

function TNewFormatDisk.GetZipStream(FileStream: TStream;
  var ID: NewDiskIDRec): TMemoryStream;
Const
  ChunkSize = 8192;
  ProcName = 'TNewFormatDisk.GetZipStream';
Var
  Buffer     : Pointer;
  CRC        : LongInt;
  SaveCRC    : LongInt;
  ZipStream  : TMemoryStream;
  NumRead    : Integer;
  NumWritten : Integer;
Begin
  (* Profile( ProcName ); *)
  Result := NIL;
  { Generate the File Header Record }
  FileStream.Position := 0;
  FileStream.Read( ID, Sizeof( ID ) );

  if ID.nidFileType <> NFFileType then
     Raise FHException.CreateFmt( '%s ERROR: the file is not a new BankLink format file', [ ProcName ] );
       // Previous version of software should be able to read ne version of file

  SaveCRC  := ID.nidCRC;
  CRC      := 0;
  ID.nidCRC := 0;

  UpdateCRC( CRC, ID, Sizeof( ID ) );

  ZipStream := TMemoryStream.Create;

  GetMem( Buffer, ChunkSize );
  try
     repeat
        NumRead := FileStream.Read( Buffer^, ChunkSize );
        if NumRead > 0 then
        begin
          UpdateCRC( CRC, Buffer^, NumRead );
          Decrypt( Buffer^, NumRead );
          NumWritten := ZipStream.Write( Buffer^, NumRead );
          if not ( NumWritten = NumRead ) then Raise FHException.CreateFmt( '%s ERROR: ZipStream write failed', [ ProcName ] );
        end;
      until NumRead < ChunkSize;
  Finally
     FreeMem( Buffer, ChunkSize );
  end;

  If CRC <> SaveCRC then
       Raise FHException.CreateFmt( '%s ERROR: the file is corrupt - invalid CRC', [ProcName] );

  ZipStream.Position := 0;
  Result := ZipStream;

end;

function  TNewFormatDisk.LoadFromFile( Const FileName : String; Const AttachmentDir : String; Const GetAttachments : Boolean ): TStringList;


Const
  ProcName = 'TNewFormatDisk.LoadFromFile';
Var
  Files          : TStringList;
  ZipStream      : TMemoryStream;
  UnZipper       : TVclZip;
  DataStream     : TMemoryStream;
  FileStream     : TMemoryStream;
  i              : Integer;
  AttachmentName : String;
  Index          : Integer;
  ID             : NewDiskIDRec;
begin
  (* Profile( ProcName ); *)

  Result := NIL;
  ZipStream := nil;
  try
    ZipStream := GetZipStream( FileName, ID );

    SetID(ID);

    UnZipper := TVCLZip.Create( NIL );
    Files := TStringList.Create;
    Try
      UnZipper.ArchiveStream := ZipStream;
      UnZipper.ReadZip;
      For i := 0 to Pred( UnZipper.Count ) do
         Files.Add( UnZipper.Filename[ i ] );
      Index := Files.IndexOf( 'DATA' );
      If Index >= 0 then
      Begin
        DataStream := TMemoryStream.Create;
        Try
          UnZipper.UnZipToStream( DataStream, 'DATA' );
          DataStream.Position := 0;
          Self.LoadFromNFStream( DataStream );
        Finally
          DataStream.Free;
        end;
      end
      else
        Raise FHException.CreateFmt( '%s Error: Couldn''t find any data in the file %s', [ ProcName, FileName ] );

      If GetAttachments then
      Begin
        Result := TStringList.Create;
        For i := 0 to Pred( UnZipper.Count ) do
        Begin
          If Files[ i ] <> 'DATA' then
          Begin { it's an attachment file }
            FileStream := TMemoryStream.Create;
            Try
              UnZipper.UnZipToStream( FileStream, UnZipper.FullName[ i ] );
              FileStream.Position := 0;
              AttachmentName := AttachmentDir + Files[i];
              FileStream.SaveToFile( AttachmentName );
              Result.Add( AttachmentName );
            Finally
              FileStream.Free;
            end;
          end;
        end;
      end;
      UnZipper.ArchiveStream := NIL;
    Finally
      UnZipper.Free;
    end;
  Finally
    ZipStream.Free;
  end;
end;
// -----------------------------------------------------------------------------

procedure TNewFormatDisk.LoadFromUpdateFile(const FileName: string);
const
  ProcName = 'TNewFormatDisk.LoadFromUpdateFile';
var
  FileStream: TMemoryStream;
  InFile: TextFile;
  line,tmpS: string;
begin
  FileStream:= TMemoryStream.Create;
  Try
    FileStream.LoadFromFile( FileName );
    FileStream.Position := 0;
    AssignStream(InFile,FileStream);
    Reset( InFile );
    Readln( InFile, line );          // Read 1st line only - it must be a header
    CloseFile(InFile);
    FileStream.Position := 0;

    if line[1]<>'F' then
      Raise FHException.CreateFmt( '%s ERROR: First line in the file %s is not a file header. This probably is not an update file.', [ ProcName, FileName ] );
    if FieldS( line, 2 )<>NFFileType then
      Raise FHException.CreateFmt( '%s ERROR: Wrong file type in file %s. This is not a BankLink file.', [ ProcName, FileName ] );
    tmpS:=FieldS( line, 3 );
    if tmpS<>NFUpdateStr then
      Raise FHException.CreateFmt( '%s ERROR: Wrong file subtype in file %s. This is not an update file.', [ ProcName, FileName ] );

    EmptyDisk;

    dhFields.dhFile_SubType:=tmpS;
    tmpS:=FieldS( line, 4 );
    If tmpS = NFCountryNZ then
      dhFields.dhCountry_Code := whNewZealand
    else
      If tmpS = NFCountryAU then
        dhFields.dhCountry_Code := whAustralia
    else
      If tmpS = NFCountryUK then
        dhFields.dhCountry_Code := whUnitedKingdom
    else
      Raise FHException.CreateFmt( '%s ERROR: Incorrect country code in file %s.', [ ProcName, FileName ] );

    dhFields.dhVersion := FieldS( line, 5 );
    dhFields.dhClient_Code:='';          // Fields not needed in update file
    dhFields.dhClient_Name:='';
    dhFields.dhDisk_Number:=0;
    dhFields.dhNo_Of_Disks_in_Set:=1;
    dhFields.dhSequence_In_Set:=1;
    dhFields.dhFile_Name:='';
    dhFields.dhFloppy_Desc_NZ_Only:='';

    dhFields.dhCreation_Date := Str2Date( FieldS( line, 9 ) );
    dhFields.dhFirst_Transaction_Date := Str2Date( FieldS( line, 10 ) );
    dhFields.dhLast_Transaction_Date := Str2Date( FieldS( line, 11 ) );

    dhFields.dhTrue_File_Name:=ExtractFileName(FileName);
    dhFields.dhNo_Of_Accounts:=0;
    dhFields.dhNo_Of_Transactions:=0;

    LoadFromNFStream(FileStream);
  finally
    FileStream.Free;
  end
end;
//------------------------------------------------------------------------------

procedure TNewFormatDisk.WriteLabelFile(const FileName: string);
var
  LabelFile: TextFile;
begin
  AssignFile(labelFile,FileName);
  Rewrite(LabelFile);

  Writeln(labelFile,dhFields.dhClient_Name);
  Writeln(labelFile);
  Writeln(labelFile,CorrectFileName(dhFields.dhFile_Name)+' [Disk '+IntToStr(dhFields.dhSequence_In_Set)+' of '+
                    IntToStr(dhFields.dhNo_Of_Disks_in_Set)+']');
  Writeln(labelFile);
  Writeln(labelFile,IntToStr(dhFields.dhNo_Of_Accounts)+' Accounts & '+
                    IntToStr(dhFields.dhNo_Of_Transactions)+' Entries');
  Writeln(labelFile,'From '+Date2Str(dhFields.dhFirst_Transaction_Date)+' to '+
                    Date2Str(dhFields.dhLast_Transaction_Date));
  Writeln(labelFile);
  Writeln(labelFile);

  CloseFile(LabelFile);
end;
//------------------------------------------------------------------------------

function TNewFormatDisk.GetZipStream( Const FileName : String; Var ID : NewDiskIDRec ): TMemoryStream;
Const
  ProcName = 'TNewFormatDisk.GetZipStream';

Var
  FileStream : TMemoryStream;

Begin
  (* Profile( ProcName ); *)
  Result := NIL;
  If not FileExists( FileName ) then
     Raise FHException.CreateFmt( '%s ERROR: the file %s does not exist', [ ProcName, FileName ] );
  { Generate the File Header Record }
  FileStream := TMemoryStream.Create;
  try try
     FileStream.LoadFromFile( FileName );
     Result := GetZipStream(FileStream, ID);
  except
     on E: Exception do
       raise FHException.CreateFmt( '%s ERROR: %s in file %s ', [ProcName, E.Message, FileName]);
  end;
  Finally
    FileStream.Free;
  end;
end;
// -----------------------------------------------------------------------------

procedure TNewFormatDisk.SaveAsText(const FileName: String);

  function MoneyToStr(const aValue: Int64): string;
  begin
    if aValue=Unknown then
      result:='   Unknown'
    else
      result:=Format('%10.2f',[aValue/100]);
  end;

  function QtyToStr(const aValue: Int64): string;
  // Quantities are multiplied by 1000
  begin
    if aValue=Unknown then
      result:='   Unknown'
    else
      result:=Format('%10.3f',[aValue/1000]);
  end;

  function BoolToStr(const aValue: Boolean): string;
  begin
    if aValue then
      result:='T'
    else
      result:='F';
  end;

  function DateToStr(const aValue: integer): string;
  begin
    if aValue=0 then
      result:='------'
    else
      result:=StDateToDateString( 'ddmmyy',aValue,False );
  end;

Const
  BufSize = 8192;
Var
  OutFile : TextFile;
  OutBuf  : Array[ 1..BufSize ] of Byte;
  i, t    : Integer;
  DBA     : TDisk_Bank_Account;
  P       : PDisk_Transaction_Rec;
  tranLine: string;
Begin
  (* Profile( 'TNFDisk.SaveAsText' ); *)

  Assign( OutFile, FileName );
  SetTextBuf( OutFile, OutBuf );
  Rewrite( OutFile );
  Try
    if dhFields.dhCountry_Code = whNewZealand then
      Writeln( OutFile, 'New Zealand data file text dump:' )
    else
      if dhFields.dhCountry_Code = whAustralia then
        Writeln( OutFile, 'Australian data file text dump:' )
    else
      if dhFields.dhCountry_Code = whUnitedKingdom then
        Writeln( OutFile, 'United Kingdom data file text dump:' )
      else
        Writeln( OutFile, 'Unknown country!!!! Text dump:' );
      
    Writeln( OutFile );
    Writeln( OutFile, 'Version            : ', dhFields.dhVersion );
    Writeln( OutFile, 'SubType            : ', dhFields.dhFile_SubType );
    Writeln( OutFile, 'Client Code        : ', dhFields.dhClient_Code );
    Writeln( OutFile, 'Client Name        : ', dhFields.dhClient_Name );
    Writeln( OutFile, 'Creation Date      : ', DateToStr(dhFields.dhCreation_Date) );
    Writeln( OutFile, 'File Name          : ', CorrectFileName(dhFields.dhFile_Name) );
    Writeln( OutFile, 'Floppy Desc        : ', dhFields.dhFloppy_Desc_NZ_Only );
    Writeln( OutFile, 'True File Name     : ', dhFields.dhTrue_File_Name );
    Writeln( OutFile, 'Disk Number        : ', dhFields.dhDisk_Number );
    Writeln( OutFile, 'Disk Seq           : ', dhFields.dhSequence_In_Set );
    Writeln( OutFile, 'No in Set          : ', dhFields.dhNo_Of_Disks_In_Set );
    Writeln( OutFile, 'No of accounts     : ', dhFields.dhNo_Of_Accounts );
    Writeln( OutFile, 'No of transactions : ', dhFields.dhNo_Of_Transactions );
    Writeln( OutFile, 'First Tran Date    : ', DateToStr(dhFields.dhFirst_Transaction_Date) );
    Writeln( OutFile, 'Last Tran Date     : ', DateToStr(dhFields.dhLast_Transaction_Date) );
    Writeln( OutFile );

    Writeln( OutFile );
    Writeln( OutFile, '==========================================================================' );
    Writeln( OutFile );

    For i := dhAccount_List.First to dhAccount_List.Last do
    Begin
      DBA := dhAccount_List.Disk_Bank_Account_At( i );

      Writeln( OutFile );
      Writeln( OutFile, 'Account Number     : ', DBA.dbFields.dbAccount_Number );
      Writeln( OutFile, 'Original Number    : ', DBA.dbFields.dbOriginal_Account_Number );
      Writeln( OutFile, 'Account Name       : ', DBA.dbFields.dbAccount_Name );
      Writeln( OutFile, 'Account ID         : ', DBA.dbFields.dbAccount_LRN );
      Writeln( OutFile, 'File Code          : ', DBA.dbFields.dbFile_Code );
      Writeln( OutFile, 'Cost Code          : ', DBA.dbFields.dbCost_Code );
      Writeln( OutFile, 'Bank ID            : ', DBA.dbFields.dbInstitution_ID );
      Writeln( OutFile, 'Bank Code          : ', DBA.dbFields.dbBank_Prefix );
      Writeln( OutFile, 'Bank Name          : ', DBA.dbFields.dbBank_Name );
      Writeln( OutFile, 'Opening Balance    : '+MoneyToStr(DBA.dbFields.dbOpening_Balance) );
      Writeln( OutFile, 'Closing Balance    : '+MoneyToStr(DBA.dbFields.dbClosing_Balance) );
      Writeln( OutFile, 'Debits Total       : '+MoneyToStr(DBA.dbFields.dbDebit_Total) );
      Writeln( OutFile, 'Credits Total      : '+MoneyToStr(DBA.dbFields.dbCredit_Total) );
      Writeln( OutFile, 'First Tran Date    : ', DateToStr(DBA.dbFields.dbFirst_Transaction_Date) );
      Writeln( OutFile, 'Last Tran Date     : ', DateToStr(DBA.dbFields.dbLast_Transaction_Date) );
      Writeln( OutFile, 'No of trans        : ', DBA.dbFields.dbNo_Of_Transactions );
      Writeln( OutFile, 'Can re-date        : ', BoolToStr(DBA.dbFields.dbCan_Redate_Transactions) );
      Writeln( OutFile, 'Is new             : ', BoolToStr(DBA.dbFields.dbIs_New_Account) );
      Writeln( OutFile, 'Cont. on next disk : ', BoolToStr(DBA.dbFields.dbContinued_On_Next_Disk) );
      Writeln( OutFile, 'Currency           : ', DBA.dbFields.dbCurrency );
      Writeln( OutFile, 'Frequency          : ', DBA.dbFields.dbFrequency_ID );

      Writeln( OutFile );

      if DBA.dbTransaction_List.ItemCount>0 then
      begin
        if dhFields.dhCountry_Code = whNewZealand then
        begin
          Writeln( OutFile, 'ID        E.Date S.Date Typ Reference    Analysis     Particulars  Other Party          OrigBB     Amount   GST Amount   Quantity    Narration');
          Writeln( OutFile, '--------- ------ ------ --- ------------ ------------ ------------ -------------------- ------ ---------- ---------- - ---------- ------------');
        end;
        if dhFields.dhCountry_Code = whAustralia then
        begin
          Writeln( OutFile, 'ID        E.Date S.Date Typ Reference    T.Code D.Code     Amount   GST Amount   Quantity    Narration');
          Writeln( OutFile, '--------- ------ ------ --- ------------ ------ ------ ---------- ---------- - ---------- ------------');
        end;
        if dhFields.dhCountry_Code = whUnitedKingdom then
        begin
          Writeln( OutFile, 'ID        E.Date S.Date Typ Reference    T.Code D.Code     Amount   GST Amount   Quantity    Narration');
          Writeln( OutFile, '--------- ------ ------ --- ------------ ------ ------ ---------- ---------- - ---------- ------------');
        end;
        Writeln( OutFile );
      end;

      For t := DBA.dbTransaction_List.First to DBA.dbTransaction_List.Last do
      Begin
        P := DBA.dbTransaction_List.Disk_Transaction_At( t );

        tranLine:=Format('%9.9d ',[P.dtBankLink_ID]);
        tranLine:=tranLine+DateToStr(P.dtEffective_Date);
        tranLine:=tranLine+' '+DateToStr(P.dtOriginal_Date);
        tranLine:=tranLine+Format(' %3.3d',[P.dtEntry_Type]);
        tranLine:=tranLine+Format(' %-12s',[P.dtReference]);
        if dhFields.dhCountry_Code = whNewZealand then
        begin
          tranLine:=tranLine+Format(' %-12s',[P.dtAnalysis_Code_NZ_Only]);
          tranLine:=tranLine+Format(' %-12s',[P.dtParticulars_NZ_Only]);
          tranLine:=tranLine+Format(' %-20s',[P.dtOther_Party_NZ_Only]);
          tranLine:=tranLine+Format(' %-6s',[P.dtOrig_BB]);
        end;
        if dhFields.dhCountry_Code = whAustralia then
        begin
          tranLine:=tranLine+Format(' %-6s',[P.dtBank_Type_Code_OZ_Only]);
          tranLine:=tranLine+Format(' %-6s',[P.dtDefault_Code_OZ_Only]);
        end;
        tranLine:=tranLine+' '+MoneyToStr(P.dtAmount);
        tranLine:=tranLine+' '+MoneyToStr(P.dtGST_Amount);
        tranLine:=tranLine+' '+BoolToStr(P.dtGST_Amount_Known);
        tranLine:=tranLine+' '+QtyToStr(P.dtQuantity);
        tranLine:=tranLine+' '+P.dtNarration;
        Writeln( OutFile, tranLine );
      end;
    end;
    Writeln( OutFile );
    Writeln( OutFile, '<End of Data>' );
  Finally
    Close( OutFile );
  end;
end;
// -----------------------------------------------------------------------------

procedure TNewFormatDisk.SaveAsExport(const FileName: String);

  function MoneyToStr(const aValue: Int64): string;
  begin
    if aValue=Unknown then
      result:=''
    else
      result:=Trim(Format('%10.2f',[aValue/100]));
  end;

  function QtyToStr(const aValue: Int64): string;
  // Quantities are multiplied by 1000
  begin
    if aValue=Unknown then
      result:=''
    else
      result:=Trim(Format('%10.3f',[aValue/1000]));
  end;

  function DateToStr(const aValue: integer): string;
  begin
    if aValue=0 then
      result:=''
    else
      result:=StDateToDateString( 'dd/mm/yyyy',aValue,False );
  end;

Const
  BufSize = 8192;
Var
  OutFile : TextFile;
  OutBuf  : Array[ 1..BufSize ] of Byte;
  i, t    : Integer;
  DBA     : TDisk_Bank_Account;
  P       : PDisk_Transaction_Rec;
  Line    : string;
  CurrentInstID: integer;
  FileAccCount,FileInstCount,FileTrxCount: integer;
  FileTotalTrx: Int64;
  InstAccCount,InstTrxCount: integer;
  InstTotalTrx: Int64;
  AccTrxCount: integer;
  AccTotalTrx: Int64;
Begin
  (* Profile( 'TNFDisk.SaveAsExport' ); *)

  Assign( OutFile, FileName );
  SetTextBuf( OutFile, OutBuf );
  Rewrite( OutFile );
  Try
    Line:='FH|BANKLINK|'+whCountryCodes[dhFields.dhCountry_Code]+'|'+IntToStr(dhFields.dhDisk_Number)+'|'+DateToStr(dhFields.dhCreation_Date);
    Writeln(OutFile,Line);
    CurrentInstID:=-1;
    FileAccCount:=0;
    FileInstCount:=0;
    FileTrxCount:=0;
    FileTotalTrx:=0;

    InstAccCount:=0;
    InstTrxCount:=0;
    InstTotalTrx:=0;

    For i := dhAccount_List.First to dhAccount_List.Last do
    Begin
      DBA := dhAccount_List.Disk_Bank_Account_At( i );

      if CurrentInstID<>DBA.dbFields.dbInstitution_ID then
      begin   // relies on accounts being ordered by institution
        if CurrentInstID>=0 then
        begin     // finish previous institution
          Line := 'IT|'+
                  IntToStr(InstAccCount) +
                  '|'+
                  IntToStr(InstTrxCount)+
                  '|'+
                  MoneyToStr(InstTotalTrx);

          Writeln(OutFile,Line);
        end;

        Line := 'IH|' +
                whCountryCodes[dhFields.dhCountry_Code]+
                '|'+
                IntToStr(DBA.dbFields.dbInstitution_ID)+
                '|'+
                filterBar(DBA.dbFields.dbBank_Prefix)+
                '|'+
                filterBar(DBA.dbFields.dbBank_Name);

        Writeln(OutFile,Line);
        CurrentInstID:=DBA.dbFields.dbInstitution_ID;
        Inc(FileInstCount);

        InstAccCount:=0;
        InstTrxCount:=0;
        InstTotalTrx:=0;
      end;

      Inc(FileAccCount);
      Inc(InstAccCount);

      (*
      Line:=Format('AH|%10.10d|%s|%s|%s',[DBA.dbFields.dbAccount_LRN,filterBar(DBA.dbFields.dbOriginal_Account_Number),
                                          filterBar(DBA.dbFields.dbAccount_Name),filterBar(DBA.dbFields.dbCurrency)]);
      *)
      Line:=Format('AH|%10.10d|%s|%s|%s|%s|%s',[DBA.dbFields.dbAccount_LRN,filterBar(DBA.dbFields.dbOriginal_Account_Number),
                                                filterBar(DBA.dbFields.dbAccount_Name),filterBar(DBA.dbFields.dbCurrency),
                                                filterBar(DBA.dbFields.dbCost_Code),filterBar(DBA.dbFields.dbFile_Code)]);
      Writeln(OutFile,Line);
      AccTrxCount:=0;
      AccTotalTrx:=0;

      For t := DBA.dbTransaction_List.First to DBA.dbTransaction_List.Last do
      Begin
        P := DBA.dbTransaction_List.Disk_Transaction_At( t );

        Line:=Format('TR|%15.15d|%s|%s|%3.3d|%s|%s|%s|%s|%s|%s|%s|%s|%s',[P.dtBankLink_ID,DateToStr(P.dtEffective_Date),DateToStr(P.dtOriginal_Date),
                                                                         P.dtEntry_Type,
                                                                         MoneyToStr(P.dtAmount),
                                                                         filterBar(P.dtReference),
                                                                         filterBar(P.dtNarration),
                                                                         filterBar(P.dtOther_Party_NZ_Only),
                                                                         filterBar(P.dtParticulars_NZ_Only),
                                                                         filterBar(P.dtAnalysis_Code_NZ_Only),
                                                                         filterBar(P.dtOrig_BB),
                                                                         MoneyToStr(P.dtGST_Amount),QtyToStr(P.dtQuantity)]);
        Writeln(OutFile,Line);
        Inc(AccTrxCount);
        Inc(InstTrxCount);
        Inc(FileTrxCount);
        AccTotalTrx:=AccTotalTrx+P.dtAmount;
        InstTotalTrx:=InstTotalTrx+P.dtAmount;
        FileTotalTrx:=FileTotalTrx+P.dtAmount;
      end;
      Line:='AT|'+IntToStr(AccTrxCount)+'|'+MoneyToStr(AccTotalTrx)+'|'+MoneyToStr(DBA.dbFields.dbClosing_Balance);
      Writeln(OutFile,Line);
    end;
    if CurrentInstID>=0 then
    begin               // finish last institution
      Line:='IT|'+IntToStr(InstAccCount)+'|'+IntToStr(InstTrxCount)+'|'+MoneyToStr(InstTotalTrx);
      Writeln(OutFile,Line);
    end;
    Line:='FT|'+IntToStr(FileInstCount)+'|'+IntToStr(FileAccCount)+'|'+IntToStr(FileTrxCount)+'|'+MoneyToStr(FileTotalTrx);
    Writeln(OutFile,Line);
  Finally
    Close( OutFile );
  end;
end;
// -----------------------------------------------------------------------------

procedure TNewFormatDisk.Validate;
begin
  Inherited;
end;

// -----------------------------------------------------------------------------
{ TUpdateDiskReader }
// -----------------------------------------------------------------------------

function TUpdateDiskReader.CanAddAccount: boolean;
begin
  raise Exception.Create( 'TUpdateDiskReader.CanAddAccount should never be called');
end;
// -----------------------------------------------------------------------------

function TUpdateDiskReader.CanAddTransaction: boolean;
begin
  raise Exception.Create( 'TUpdateDiskReader.CanAddTransaction should never be called');
end;

// -----------------------------------------------------------------------------
procedure TUpdateDiskReader.ExtractFromStreamOF(const FileName: string;
  FileStream: TStream; ToProc: FileExtractProc);
begin
  inherited;
end;

// -----------------------------------------------------------------------------

function TUpdateDiskReader.LoadFromFileOF(const FileName,
  AttachmentDir: String; const GetAttachments: Boolean): TStringList;
begin
  raise Exception.Create( 'TUpdateDiskReader.LoadFromFileOF should never be called');
end;

// -----------------------------------------------------------------------------
procedure TUpdateDiskReader.LoadFromUpdateFile(const FileName: string);
begin
  inherited;
end;

// -----------------------------------------------------------------------------
procedure TUpdateDiskReader.SaveToFileOF(const FileName: String;
  const Attachments: TStringList);
begin
  raise Exception.Create( 'TUpdateDiskReader.SaveToFileOF should never be called');
end;

// -----------------------------------------------------------------------------
procedure TUpdateDiskReader.Validate;
var
  DBA : TDisk_Bank_Account;
  DT  : pDisk_Transaction_Rec;
  NumRead : integer;
  NumInTrailer : integer;
  i            : integer;

  TotalAmount  : Int64;
  ExpectedAmount : Int64;
begin
  //standard validation routines only work for production images
  if dhAccount_List.ItemCount <> 1 then
    Raise FHDataValidationException.Create( 'TUpdateDiskReader.Validate Error: dhAccount_List.ItemCount <> 1');

  DBA := dhAccount_List.Disk_Bank_Account_At( 0);

  //compare no of transaction vs no of transactions for
  NumRead       := DBA.dbTransaction_List.ItemCount;
  NumInTrailer  := DBA.dbFields.dbNo_Of_Transactions;
  If ( NumRead <> NumInTrailer ) then
    Raise FHDataValidationException.CreateFmt( 'TUpdateDiskReader.Validate Error: dhNo_of_Transactions = %d but dbTransaction_List.ItemCount = %d', [ NumInTrailer, NumRead ] );

  //check transaction totals
  TotalAmount := 0;
  for i := DBA.dbTransaction_List.First to DBA.dbTransaction_List.Last do
    TotalAmount := TotalAmount + DBA.dbTransaction_List.Disk_Transaction_At(i)^.dtAmount;

  ExpectedAmount := (DBA.dbFields.dbDebit_Total - DBA.dbFields.dbCredit_Total);

  if TotalAmount <> ExpectedAmount then
    raise  FHDataValidationException.Create( 'TUpdateDiskReader.Validate Error: Transaction Totals do not match ' +
                                             ' Expected ' + inttostr( ExpectedAmount) +
                                             ' Found ' + inttostr( TotalAmount));

  //check date ranges
  for i := DBA.dbTransaction_List.First to DBA.dbTransaction_List.Last do
  begin
    dT := DBA.dbTransaction_List.Disk_Transaction_At(i);
    if (DT^.dtEffective_Date < dhFields.dhFirst_Transaction_Date) then
      raise FHDataValidationException.Create( 'TUpdateDiskReader.Validate Error: Eff Date prior to start date');

    if (DT^.dtEffective_Date > dhFields.dhLast_Transaction_Date) then
      raise FHDataValidationException.Create( 'TUpdateDiskReader.Validate Error: Eff Date after to end date');
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
