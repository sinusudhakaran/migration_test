//------------------------------------------------------------------------------
{
   Title:       ecoding object

   Description: basic TEcClient object that loads a file into memory, provides
                access to the data, and handles saving to a file

   Remarks:

   Author:      Matthew Hopkins Jul 2001

}
//------------------------------------------------------------------------------
unit ecObj;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  classes,
  ecECIO,
  ecDefs,
  CRC32,
  SysUtils,
{$IFDEF ParserDll}
   // The Parser DLL just need to read the Coding_File_Details_Rec fields
   // All the rest is not needed,
   // and is removed to keep the Dll file size under control
{$ELSE}
  ecGlobalTypes,
  ecBankAccountsListObj,
  ecChartListObj,
  ecPayeeListObj,
  ecPayeeObj,
  ecJobObj,
  bkConst,
{$ENDIF}
  IOStream,
  VCLZip,
  FileWrapper,
  ecBankAccountObj;

type
  TEcClient = class
    ecFields          : TECoding_File_Details_Rec;
{$IFDEF ParserDll}
{$ELSE}
    ecBankAccounts : TECBank_Account_List;
    ecChart        : TECChart_List;
    ecPayees_V53   : TECPayee_List_V53;
    ecPayees       : TECPayee_List;
    ecJobs         : TECJob_List;
{$ENDIF}
    constructor Create;
    destructor  Destroy; override;
  private
    FActiveBankAccount: TEcBank_Account;
    procedure OpenFromDataStream(var S : TIOStream);
    function GetZipStream(const Filename: string; const ZipStream: TMemoryStream; aHandle: Cardinal): Boolean;

{$IFDEF ParserDll}
{$ELSE}
    procedure IntegrityCheck;
    procedure WriteFileFromZipStream(const Filename: string; const ZipStream: TMemoryStream);
    procedure SaveToDataStream(var S : TIOStream);
    procedure SetActiveBankAccount(const Value: TEcBank_Account);
{$ENDIF}
  public
    function LoadFromFile(FileName: String; aHandle: Cardinal ): Boolean;
    function GetCurrencySymbol(ecCountry: byte): string;
{$IFDEF ParserDll}
{$ELSE}
    procedure SaveToFile(FileName: String );
    function  GetCurrentCRC : Integer;
    procedure UpdateRefs;
    function SalesTaxNameFromCountry(ecCountry: byte): string;
    function GetAccountDetails(ba: TEcBank_Account; ClientCountry: byte): string;
    property ActiveBankAccount: TEcBank_Account read FActiveBankAccount write SetActiveBankAccount;
{$ENDIF}
  end;

//******************************************************************************
implementation

uses
  Windows,


  ECTokens,
  BkDBExcept,
  CryptX,
  ECCRC,
  ECExcept,
{$IFDEF ParserDll}
{$ELSE}
  Forms,
  ECGlobalConst,
  glConst,
  WinUtils,
  ECUpgrade,
  ecUpgradeHelper,
  ecGlobalVars,
{$ENDIF}
  MoneyDef,
  CRCFileUtils;



const
  BackupExtn       = '.bnb';
  ChunkSize        = 8192;

const
  SInvalidWrapperSize = 'Invalid Wrapper Size in %s';
  SFileStreamWriteError = 'Error writing to file stream %s';

{$IFDEF ParserDll}
  APP_NAME = 'BankLink'; 

{$ENDIF}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TEcClient }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TEcClient.Create;
begin
   Inherited Create;
   FillChar( ecFields, SizeOf( ecFields ), 0 );
   ecFields.ecRecord_Type := tkBegin_ECoding_File_Details;
   ecFields.ecEOR := tkEnd_ECoding_File_Details;
{$IFDEF ParserDll}
{$ELSE}
   //create lists
   ecBankAccounts := TECBank_Account_List.Create;
   ecChart := TECChart_List.Create;
   ecPayees_V53 := TECPayee_List_V53.Create;
   ecPayees := TECPayee_List.Create;
   ecJobs := TECJob_List.Create;
{$ENDIF}
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

destructor TEcClient.Destroy;
begin
{$IFDEF ParserDll}
{$ELSE}
   //free lists
   ecBankAccounts.Free;
   ecChart.Free;
   ecPayees_V53.Free;
   ecPayees.Free;
   ecJobs.Free;
{$ENDIF}
   //free fields
   ecECIO.Free_ECoding_File_Details_Rec_Dynamic_Fields( ecFields);
   inherited Destroy;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TEcClient.GetZipStream( const Filename : string; const ZipStream : TMemoryStream; aHandle: Cardinal): Boolean;
const
  ThisMethodName = 'TEcClient.GetZipStream';
  SOpenError     = 'ECOBJ Error: Open failed %s';
var
  FileStream : TFileStream;
  Wrapper    : TWrapper;
  sMsg       : String;
  Buffer     : Pointer;

  NumRead    : integer;
  NumWritten : integer;
begin
  Result := True;
  //load file from disk
  FileStream := TFileStream.Create( filename, fmOpenRead);
  try
    //check the crc
    try
      CrcFileUtils.CheckEmbeddedCRC( FileStream);
    except
      On e : exception do
        raise EFileCRCFailure.Create( e.Message + ' [' + e.classname + ']');
    end;

    //reposition the cursor to the front of the file and read the wrapper
    FileStream.Position := 0;
    NumRead             := FileStream.Read( Wrapper, SizeOf( Wrapper));
    if NumRead <> SizeOf( Wrapper) then
      raise EWrapperError.CreateFmt( SInvalidWrapperSize, [ Filename]);

    //check file signature
    if ( Wrapper.wSignature <> FileWrapper.ECODINGFILE_SIGNATURE) then
    begin
       sMsg := Format( 'Invalid File Signature %s', [ FileName]);
       raise EWrapperError.CreateFmt( SOpenError,[ sMsg]);
    end;
    //check file version no
{$IFDEF ParserDll}
{$ELSE}
    if ( Wrapper.wVersion > ECDEFS.EC_FILE_VERSION) then
    begin
       if (aHandle <> 0) and (Application.MessageBox(
                    'A later version of ' + APP_NAME +
                    ' is required to open this file.'#13#13 +
                    'Would you like to check for a later version now?',
                    'Check for Updates',
                    MB_ICONQUESTION + MB_YESNO + MB_DEFBUTTON1) = IDYES) then
       begin
         case ecUpgradeHelper.CheckForUpgrade_BNotes('', Wrapper.wCountry, aHandle, False) of
          upShutdown:
            begin
              ApplicationMustShutdownForUpdate := True;
              Result := False;
              exit;
            end;
          upCancel:
            begin
              sMsg := Format( 'Version mismatch : Expected %d  Found %d.', [ ECDEFS.EC_FILE_VERSION, Wrapper.wVersion]);
              raise EIncorrectVersion.Create( sMsg);
            end;
          end;
       end
       else
       begin
         sMsg := Format( 'Version mismatch : Expected %d  Found %d.', [ ECDEFS.EC_FILE_VERSION, Wrapper.wVersion]);
         raise EIncorrectVersion.Create( sMsg);
       end;
    end
    else
{$ENDIF}
    if Wrapper.wVersion < 5 then
       // Update_server was Added to the wrapper (Rather than use the spare bytes)
       // Later this was converted to wPracticeName (same size)
       // Eitherway, if the file is older we have to move back a bit..
       FileStream.Position := FileStream.Position - SizeOf(Wrapper.wUpdateServer);

    //read remainder of the file into the zipfilestream
    ZipStream.Clear;
    ZipStream.Position := 0;

    GetMem( Buffer, ChunkSize );
    try
      repeat
        NumRead := FileStream.Read( Buffer^, ChunkSize );
        if NumRead > 0 then
        begin
          Decrypt( Buffer^, NumRead );
          NumWritten := ZipStream.Write( Buffer^, NumRead );
          if not ( NumWritten = NumRead ) then
            raise EECodingException.CreateFmt( '%s ERROR: ZipStream write failed', [ ThisMethodName ] );
        end;
      until NumRead < ChunkSize;
    finally
      FreeMem( Buffer, ChunkSize );
    end;

    ZipStream.Position := 0;
  finally
    FileStream.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TEcClient.LoadFromFile( FileName : String; aHandle: Cardinal ): Boolean;
const
  ThisMethodName = 'TEcClient.LoadFromFile';
var
  FileIsReadOnly         : boolean;
  Attributes             : integer;
  ZipStream              : TMemoryStream;
  DataStream             : TIOStream;
  UnZipper               : TVCLZip;
begin
  Result := True;
  //test read only flag
  FileIsReadOnly := false;
  Attributes     := FileGetAttr( Filename);
  if (Attributes <> -1) then
  begin
     if (Attributes and faReadOnly) <> 0 then
     begin
        //current file is read only, clear read only flag so can rename
        FileIsReadOnly := true;
     end;
  end;

  //read the file and get the zip stream
  ZipStream := TMemoryStream.Create;
  try
    if GetZipStream( Filename, ZipStream, aHandle) then
    begin
      DataStream := TIOStream.Create;
      try
        //unzip the zip stream
        DataStream.Clear;
        DataStream.Position := 0;
        ZipStream.Position  := 0;

        UnZipper := TVCLZip.Create( nil);
        try
          UnZipper.ArchiveStream := ZipStream;
          UnZipper.ReadZip;
          Unzipper.UnzipToStreamByIndex( DataStream, 0);
        finally
          UnZipper.Free;
        end;

        //reposition
        DataStream.Position := 0;

        //read field values from tokenised data stream
        Self.OpenFromDataStream( DataStream);
{$IFDEF ParserDll}
{$ELSE}
        ECUpgrade.UpgradeClientToLatestVersion( Self);
{$ENDIF}
        //update temp files in file
        ecFields.ecFilename              := Filename;
        ecFields.ecFile_Opened_Read_Only := FileIsReadOnly;
      finally
        FreeAndNil( DataStream);
      end;
    end
    else
      Result := False;
  finally
    FreeAndNil( ZipStream);
  end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TEcClient.OpenFromDataStream(var S : TIOStream);
var
  Token: Byte;
  CRC: LongWord;
begin
  //read the crc
  S.Position := 0;
  S.Read(CRC, SizeOf(CRC));

  //if the crc is zero, it indicates that the file did not have a crc calculated
  //for it previously.
  if (CRC <> 0) then
  begin
    try
      CrcFileUtils.CheckEmbeddedCRC( S);
    except
      On e : exception do
        raise EFileCRCFailure.Create( e.Message + ' [' + e.classname + ']');
    end;
  end;

  S.Position := 0;
  S.Read(CRC, SizeOf(CRC));
  Token := S.ReadToken;
  While (Token <> tkEndSection) do
  begin
    case Token of
       tkBegin_ECoding_File_Details  : Read_ECoding_File_Details_Rec( ecFields, S );
{$IFDEF ParserDll}
       else  break;
    end;
    Token := S.ReadToken;
  end;
{$ELSE}
       tkBeginBankAccountList        : ecBankAccounts.LoadFromFile( S);
       tkBeginChart                  : ecChart.LoadFromFile( S);
       tkBeginPayees                 : ecPayees_V53.LoadFromFile( S);
       tkBeginPayeesList             : ecPayees.LoadFromFile( S);
       tkBeginJobsList               : ecJobs.LoadFromFile(S);
    else
       Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
    end;
    Token := S.ReadToken;
  end;
{$ENDIF}
end;


{$IFDEF ParserDll}
{$ELSE}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TEcClient.SalesTaxNameFromCountry(ecCountry: byte): string;
begin
  case ecCountry of
    whNewZealand, whAustralia : Result := 'GST';
    whUK                      : Result := 'VAT';
  end;
end;

procedure TEcClient.SaveToDataStream(var S: TIOStream);
var
  CRC : LongWord;
begin
  CRC := 0;
  S.Write( CRC, Sizeof( CRC ) );
  ecECIO.Write_ECoding_File_Details_Rec ( ecFields, S );
  ecBankAccounts.SaveToFile(S);
  ecChart.SaveToFile(S);
  ecPayees.SaveToFile(S);
  ecJobs.SaveToFile(S);
  S.WriteToken( tkEndSection );
  EmbedCRC( S);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


procedure TEcClient.SaveToFile(FileName: String);
const
  ThisMethodName = 'TEcClient.SaveToFile';
  ChunkSize      = 8192;
var
  ZipStream      : TMemoryStream;
  DataStream     : TIOStream;
  Zipper         : TVCLZip;
  TempFilename   : String;
  BackupFilename : String;
begin
  //test file integrity
  IntegrityCheck;

  DataStream := TIOStream.Create;
  try
    //create the data stream
    DataStream.Clear;
    SaveToDataStream(DataStream);

    //zip the data stream
    ZipStream := TMemoryStream.Create;
    try
      ZipStream.Clear;
      ZipStream.Position  := 0;
      DataStream.Position := 0;

      Zipper := TVCLZip.Create( nil);
      try
        Zipper.ArchiveStream := ZipStream;
        Zipper.ZipFromStream(DataStream, Filename);
      finally
        Zipper.Free;
        FreeAndNil( DataStream);
      end;

      TempFilename := ChangeFileExt(Filename, '.bnt');
      WriteFileFromZipStream(TempFilename, ZipStream);

      BackupFilename := ChangeFileExt( Filename, BackupExtn);

      // Backup the previous .TRF file to .BNB
      if BKFileExists( Filename ) then
      begin
        if BKFileExists( BackupFilename ) then
          WinUtils.RemoveFile( BackupFilename);

         WinUtils.RenameFileEx( Filename, BackupFilename );
      end;

      // Rename the new .TMP file as .
      if BKFileExists( Filename ) then
        WinUtils.RemoveFile( Filename );

      WinUtils.RenameFileEx( TempFilename, Filename );

      //save file name
      ecFields.ecFilename := Filename;

    finally
      FreeAndNil( ZipStream);
    end;
  finally
    FreeAndNil( DataStream);
  end;
end;

procedure TEcClient.SetActiveBankAccount(const Value: TEcBank_Account);
begin
  FActiveBankAccount := Value;
end;

function TEcClient.GetAccountDetails(ba: TEcBank_Account; ClientCountry: byte): string;
begin
  Result := ba.bafields.baBank_Account_Number + '   ' +
            ba.baFields.baBank_Account_Name;
  if (whCurrencyCodes[ClientCountry]<>ba.baFields.baCurrency_Code) then
    Result := Result + '   ' +
              ba.baFields.baCurrency_Code + ' ' +
              ba.baFields.baCurrency_Symbol;
end;

function TEcClient.GetCurrencySymbol(ecCountry: byte): string;
begin
  case ecCountry of
    whUK                      : Result := '£';
    whNewZealand, whAustralia : Result := '$';
    else Result := '$';
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TEcClient.GetCurrentCRC: Integer;
var
   CRC : LongWord;
begin
   CRC := 0;
   ecCRC.UpdateCRC( ecFields, CRC);
   ecBankAccounts.UpdateCRC( CRC);
   ecChart.UpdateCRC( CRC);
   //ecPayees_V53.UpdateCRC( CRC);
   ecPayees.UpdateCRC( CRC);
   ecJobs.UpdateCRC(CRC);
   result := LongInt( CRC);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TEcClient.UpdateRefs;
var
   B  : LongInt;
begin
   with ecBankAccounts do
      for B := 0 to Pred( ItemCount ) do
         with Bank_Account_At( B ) do begin
            baFields.baNumber := B;
            UpdateSequenceNumbers;  //txBank_Seq := baFields.baNumber
         end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TEcClient.IntegrityCheck;
var
   T        : Integer;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   procedure RaiseIntegrityException( FailureReason : string );
   var Msg : string;
   begin
      Msg := 'Failure '+ FailureReason+'  Trx='+IntToStr(T);
      Raise EIntegrityFailure.Create( Msg);
   end;

var
   B             : Integer;
   Dissect_Total : Money;
   This          : pDissection_Rec;
   i             : Integer;
   LastCode      : string[40];
   LastEffDate   : Longint;
begin
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check ecFields
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if ecFields.ecRecord_Type <> tkBegin_ECoding_File_Details then begin
      RaiseIntegrityException('ecRecord_Type');
   end;
   if ecFields.ecEOR <> tkEnd_ECoding_File_Details then Begin
      RaiseIntegrityException('ecEOR');
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check Bank Account Order, Transaction Dates, Dissection Totals
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   LastCode := '';
   with ecBankAccounts do Begin
      for B := 0 to Pred( ItemCount ) do begin
         with Bank_Account_At( B ), baFields do begin
            If baBank_Account_Number < LastCode then Begin
               RaiseIntegrityException('Bank Account Sequence');
            end;
            LastCode := baBank_Account_Number;

            LastEffDate := 0;
            with baTransaction_List do begin
               for T := 0 to Pred( ItemCount ) do begin
                  with Transaction_At( T )^ do begin
                     //Transaction dates
                     If txDate_Effective < LastEffDate then Begin
                        RaiseIntegrityException('Entry Date Sequence');
                     end;
                     If txDate_Effective < MinValidDate then Begin //01-01-1990
                        RaiseIntegrityException('Entry Date Prior to MinValidDate');
                     end;
                     If txDate_Effective > MaxValidDate then Begin //31-12-2040
                        RaiseIntegrityException('Entry Date Exceeds MaxValidDate');
                     end;
                     LastEffDate := txDate_Effective;
                     //Dissection totals
                     if ( txFirst_Dissection <> NIL ) then begin
                        Dissect_Total := 0;
                        This := txFirst_Dissection;
                        while This<>NIL do with This^ do begin
                           Dissect_Total := Dissect_Total + dsAmount;
                           This := dsNext;
                        end;
                        If txAmount <> Dissect_Total then Begin
                           RaiseIntegrityException('Dissection Total');
                        end;
                     end;
                  end;
               end;
            end; //with baTransaction_List
         end; //with bankAccount
      end;
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check Chart Codes
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      LastCode := '';
   with ecChart do Begin
      for i := 0 to Pred( ItemCount ) do with Account_At( i )^ do Begin
         if ( chAccount_Code < LastCode ) then Begin
            RaiseIntegrityException('Chart Sequence');
         end;
         LastCode := chAccount_Code;
      end;
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check Payee List
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ecPayees.CheckIntegrity;
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   // Check Job List
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ecJobs.CheckIntegrity;
   //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TEcClient.WriteFileFromZipStream(const Filename: string;
  const ZipStream: TMemoryStream);
var
  Wrapper         : TWrapper;
  Buffer          : Pointer;
  ECFileStream    : TMemoryStream;
  NumBytesRead    : Integer;
  NumBytesWritten : integer;
begin
  //encrypt and wrap file
  FillChar( Wrapper, SizeOf( Wrapper), #0);
  Wrapper.wCRC           := 0;
  Wrapper.wVersion       := ECDEFS.EC_FILE_VERSION;
  Wrapper.wSignature     := FileWrapper.ECODINGFILE_SIGNATURE;
  Wrapper.wCountry       := ecFields.ecCountry;
  Wrapper.wCode          := ecFields.ecCode;
  Wrapper.wName          := ecFields.ecName;
  Wrapper.wMagic_Number  := ecFields.ecMagic_Number;
  Wrapper.wUpdateServer  := '';

  //create file
  ECFileStream := TMemoryStream.Create;
  try
    //write out wrapper
    NumBytesWritten := ECFileStream.Write( Wrapper, SizeOf( Wrapper));
    if NumBytesWritten <> SizeOf( Wrapper) then
      raise EWrapperError.CreateFmt( SInvalidWrapperSize, [ Filename]);

    //copy data from zip stream to file stream, encrypt as we go
    GetMem( Buffer, ChunkSize);
    try
      ZipStream.Position := 0;
      repeat
        NumBytesRead := ZipStream.Read( Buffer^, ChunkSize);
        if NumBytesRead > 0 then
        begin
          CryptX.Encrypt( Buffer^, NumBytesRead);
          NumBytesWritten := ECFileStream.Write( Buffer^, NumBytesRead);

          if NumBytesWritten <> NumBytesRead then
            raise Exception.CreateFmt( sFileStreamWriteError, [ Filename]);
        end;
      until ( NumBytesRead =0);
    finally
      FreeMem( Buffer, ChunkSize);
    end;

    EmbedCRC( ECFileStream);
    ECFileStream.SaveToFile( Filename);
  finally
    ECFileStream.Free;
  end;
end;

{$ENDIF}

end.
