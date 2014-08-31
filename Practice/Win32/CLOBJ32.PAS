unit clObj32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//main client object handles loading and saving of all contained objects
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   Classes,
   bkDefs,
   ioStream,
{$IFDEF ParserDll}
   // The Parser DLL just need to read the client fields
   // All the rest is not needed,
   // and is removed to keep the Dll file size under control
{$ELSE}
   BaList32,
   chList32,
   pyList32,
   maList32,
   dlList32,
   buList32,
   blList32,
   jobobj,
   PayeeObj,
   prObj32,
   CustomHeadingsListObj,
   ExchangeRateList,
   mcDefs,
   AuditMgr,
   RecommendedMems,
{$ENDIF}
   sysutils,
   MoneyDef;

type
  TClientObj = Class
    clFields               : TClient_Rec;
{$IFDEF ParserDll}
{$ELSE}
    clBank_Account_List    : TBank_Account_List;
    clChart                : TChart;
    clPayee_List_V53       : TPayee_List_V53; //retained so that files can be upgraded
    clPayee_List           : TPayee_List;
    clMacro_List           : TMacro_List;
    clDisk_Log             : TDisk_List;
    clBudget_List          : TBudget_List;
    clBalances_List        : TBalances_List;
    clCustom_Headings_List : TNew_Custom_Headings_List;
    clMoreFields           : TMoreClient_Rec;
    clJobs                 : TClient_Job_List;
    clExtra                : TClientExtra_Rec;
    clTPR_Payee_Detail     : TTPR_Payee_Detail;
    clRecommended_Mems     : TRecommended_Mems;
    FAuditTable            : TAuditTable;
    FClientAuditMgr        : TClientAuditManager;
    FOpened                : Boolean;
{$ENDIF}
    clWas_Code             : string;  //store the client code to detect a rename
    clRawStreamSize        : integer; //store stream size on open so can estimate for save
    constructor Create;
    destructor Destroy; override;
  private
{$IFDEF ParserDll}
    procedure ReadFromDataStream( var S : TIOStream);
{$ELSE}
    FExchangeSource: TExchangeSource;
    FLastAuditRecordID: integer;
    FClientCopy: TClientObj;
{$ENDIF}
    procedure LoadFromStream( var s:TIOStream);
    procedure GetZipStreamFromFile(var Filename : String; const ZipStream : TBigMemoryStream);
    procedure GetZipStreamFromStream(var Filename: String;  const stream: TStream; const ZipStream : TBigMemoryStream);
    function GetDataStreamFromZipStream(const FileCode: String; const ZipStream : TBigMemoryStream): TIOStream;

    procedure LogDebugMsg(S: string; Error: Boolean = false);
{$IFDEF ParserDll}
{$ELSE}
    function  GetLongName  : string;

    procedure SaveToStream (var s:TIOStream);
    procedure ClientCopyReload(var S: TIOStream);



    function GetAccountingSystemName: string;
    function GetClientCopy: TClientObj;
    procedure SetAuditInfo(P1, P2: pClient_Rec; var AAuditInfo: TAuditInfo);
    procedure SetExtraAuditInfo(P1, P2: pClientExtra_Rec; var AAuditInfo: TAuditInfo;
                                NewClient: boolean = false);
{$ENDIF}
  public
    procedure Open(FileCode, FileExtension : String);

{$IFDEF ParserDll}
{$ELSE}
    // Used for Books TokenIO
    procedure SaveToDataStream( var S : TIOStream; DefaultSize : integer = 0);
    procedure ReadFromDataStream( var S : TIOStream);
    procedure SimpleRead(FileCode: string; Stream: TStream);


    function SaveClientToStream: TBigMemoryStream;
    property ExchangeSource: TExchangeSource read FExchangeSource;
    property  clExtendedName : string read GetLongName;   //used in reports
    property  clAccountingSystemName : string read GetAccountingSystemName;
    procedure UpdateRefs;
    procedure IntegrityCheck;
    function  AccountCodeCompare( Item1, Item2 : ShortString): integer;
    function  GetCurrentCRC : LongInt;
    function  TestForChange : boolean;
    function  GSTHasBeenSetup: Boolean;
    procedure CommonSave(FileExtension : String; Backup : Boolean);
    procedure Save;
    procedure AutoSave;
    // Utilities

    function HasForeignCurrencyAccounts : Boolean;
    function HasExchangeRates(var ISOCodeText: string;
      const FromDate: integer = 0; const ToDate: integer = MaxInt;
      ForReport: boolean = False; AllBankAccounts: boolean = true): Boolean;
    procedure RefreshExchangeSource(DefaultGST: Boolean = True);
    procedure FillIsoCodeList(ISOCodes: TStrings);
    procedure FillAccountingSystemList(Value: Tstrings);

    { How should we represent money in this country }


    Function FmtMoneyStr: String;                                   { returns '$#,##0.00;-$#,##0.00' }
    Function FmtMoneyStrBrackets: String;                           { returns '$#,##0.00;$(#,##0.00)' }
    Function FmtBalanceStr: String;                                 { returns '$#,##0.00 OD;$#,##0.00 IF;$0.00' }
    Function FmtBalanceStrNoSymbol: String;                         { returns '#,##0.00 OD;#,##0.00 IF;0.00' }
    Function FmtMoneyStrBracketsNoSymbol: String;                   { returns '#,##0.00;(#,##0.00)' }
    Function FmtDrCrStr: String;                                    { returns '$#,##0.00 OD;$#,##0.00 IF;$0.00' }
    Function FmtDrCrStrNoSymbol: String;                            { returns '#,##0.00 OD;#,##0.00 IF;0.00' }

    Function MoneyStrNoSymbol( Const Amount : Money ): String;
    Function MoneyStr( Const Amount : Money ): String;
    Function MoneyStrBrackets( Const Amount : Money ): String;
    Function BalanceStr( Const Amount : Money ): String;
    Function BalanceStrNoSymbol( Const Amount : Money ): String;
    Function DrCrStr( Const Amount : Money ): String;
    Function DrCrStrNoSymbol( Const Amount : Money ): String;
    Function CurrencySymbol: String;
    Function TaxSystemName : String;   { Gst, Vat }
    Function TaxSystemNameUC : String;  { GST, VAT }
    Function ChequeEntryType : Byte;  { 0, 1, 1 }
    Function WithdrawalEntryType : Byte; { 49,9,9 }
    Function DepositEntryType : Byte; { 50,10,10 }
    // ----------------------------------------------------------------------------

    function GetForexISOCodeForContra(AContraCode: string): string;
    function NextAuditRecordID: integer;
    procedure DoAudit(AAuditType: TAuditType; AClientCopy: TClientObj);
    procedure ClientCopyReset;
    property AuditTable: TAuditTable read FAuditTable;
    property ClientAuditMgr: TClientAuditManager read FClientAuditMgr;
    property ClientCopy: TClientObj read GetClientCopy;
    property Opened: Boolean read FOpened write FOpened default false;
{$ENDIF}
  end;

{$IFDEF ParserDll}
   var  // So we don't need Globals or WinUtils
     DataDir : string;
     SAV_EXTN : string  = '.SAV';
     FILEEXTN : string  = '.BK5';
     SYSFILENAME : string = 'system.db';
     ShortAppName : string = 'BankLink';
     function BKFileExists(Filename: string): Boolean;
{$ELSE}
{$ENDIF}

//******************************************************************************
implementation
uses
   ClientWrapper,
   bkclio,
   tokens,
   crcFileUtils,
   bkcrc,
   cryptx,
   windows,
   IniSettings,

{$IFDEF ParserDll}
{$ELSE}
   baObj32,
   budobj32,
   BKceIO,
   LogUtil,
   Software,
   globals,
   GLConst,
   bkConst,
   bkbuio,
   bkmcio,
   bkprio,
   Upgrade,
   WinUtils,
   BKDBExcept,
   ovcDate,
   MoneyUtils,
   GenUtils,
   StStrS,
   ForexHelpers,
   GSTUTIL32,
   WebUtils,
{$ENDIF}
   bk5Except,
   VclZip;

const
  UnitName  = 'CLOBJ32';
  BUFFER_SIZE = 8192;

const
  SFileNotFoundError = 'Error: the file %s does not exist';

  SInvalidWrapperSize = 'Invalid Wrapper Size in %s';
  SInvalidSignature = 'Invalid File Signature in %s';
  SInvalidVersion = 'Invalid Version in %s. You must be running version %s or later to open this file';
  SCRCError = 'Invalid CRC in %s';
  SZipStreamWriteError = 'Error writing to zip stream';
  SFileStreamWriteError = 'Error writing to file stream %s';

var
  DebugMe     : Boolean = false;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TClientObj.Create;
const
  ThisMethodName = 'TClientObj.Create';
begin
   LogDebugMsg(ThisMethodName + ' Begins' );
   inherited Create;
   FillChar(clFields,SizeOf(clFields),0);
   clFields.clRecord_Type := tkBegin_Client;
   clFields.clEOR         := tkEnd_Client;
   clWas_Code             := '';
{$IFDEF ParserDll}
{$ELSE}
   //Audit table
   FLastAuditRecordID := 0;
   FClientAuditMgr        := TClientAuditManager.Create(Self);
   FAuditTable            := TAuditTable.Create(FClientAuditMgr);

   FillChar(clMoreFields,SizeOf(clMoreFields),0);
   clMoreFields.mcRecord_Type := tkBegin_MoreClient;
   clMoreFields.mcEOR         := tkEnd_MoreClient;

   FillChar(clExtra,SizeOf(clExtra),0);
   clExtra.ceRecord_Type := tkBegin_ClientExtra;
   clExtra.ceEOR         := tkEnd_ClientExtra;

   {create all the rest, must be read in order!}
   clBank_Account_List    := TBank_Account_List.Create( Self, FClientAuditMgr );
   clChart                := TChart.Create(FClientAuditMgr);
   clPayee_List_V53       := TPayee_List_V53.Create;
   clPayee_List           := TPayee_List.Create(FClientAuditMgr);
   clMacro_List           := TMacro_List.Create;
   clDisk_Log             := TDisk_List.Create;
   clBudget_List          := TBudget_List.Create;
   clBalances_List        := TBalances_List.Create;
   clJobs                 := TClient_Job_List.Create;
   clCustom_Headings_List := TNew_Custom_Headings_List.Create(FClientAuditMgr);
   clTPR_Payee_Detail     := TTPR_Payee_Detail.Create;
   clRecommended_Mems     := TRecommended_Mems.Create(clBank_Account_List);

   //Exchange rate source
   FExchangeSource := TExchangeSource.Create;
{$ENDIF}
   LogDebugMsg(ThisMethodName + ' Ends');
end;

{$IFNDEF ParserDLL}

function TClientObj.CurrencySymbol: String;
begin
  Result := whCurrencySymbols[ clFields.clCountry ];
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.DepositEntryType: Byte;
begin
  Result := whDepositEntryType[ clFields.clCountry ];
end;

{$ENDIF}

destructor TClientObj.Destroy;
const
   ThisMethodName = 'TClientObj.Destroy';
begin
   LogDebugMsg( ThisMethodName + ' Begins');
   //free all the rest
   BKCLIO.Free_Client_Rec_Dynamic_Fields( clFields);
{$IFDEF ParserDll}
{$ELSE}
   FreeAndNil(FExchangeSource);

   clBank_Account_List.Free;
   clChart.Free;
   clPayee_List_V53.Free;
   clPayee_List.Free;
   clMacro_List.Free;
   clBudget_List.Free;
   clBalances_List.Free;
   clCustom_Headings_List.Free;
   clDisk_Log.Free;
   clJobs.Free;
   BKMCIO.Free_MoreClient_Rec_Dynamic_Fields(clMoreFields);
   BKCEIO.Free_ClientExtra_Rec_Dynamic_Fields (clExtra);
   FreeAndNil(clTPR_Payee_Detail);
   FreeAndNil(clRecommended_Mems);

   //Audit table
   FreeAndNil(fAuditTable);
   FreeAndNil(FClientAuditMgr);
   //Delete audit copy if assigned
   if Assigned(FClientCopy) then
     FreeAndNil(FClientCopy);
{$ENDIF}
   inherited Destroy;
   LogDebugMsg( ThisMethodName + ' Ends');
end;

{$IFNDEF ParserDll}
procedure TClientObj.DoAudit(AAuditType: TAuditType; AClientCopy: TClientObj);
var
  AuditInfo: TAuditInfo;
  clFieldsCopy: TClient_Rec;
  ceFieldsCopy: TClientExtra_Rec;
begin
  AuditInfo.AuditAction := aaNone;
  AuditInfo.AuditType := AAuditType;
  AuditInfo.AuditUser := ClientAuditMgr.CurrentUserCode;
  //Client
  AuditInfo.AuditRecord := New_Client_Rec;
  try
    clFieldsCopy := AClientCopy.clFields;
    SetAuditInfo(@clFields, @clFieldsCopy, AuditInfo);
    if (AuditInfo.AuditAction <> aaNone) then
      AuditTable.AddAuditRec(AuditInfo);
  finally
    Dispose(AuditInfo.AuditRecord);
  end;
  //Client Extra
  AuditInfo.AuditAction := aaNone;
  AuditInfo.AuditRecord := New_ClientExtra_Rec;
  try
    ceFieldsCopy := AClientCopy.clExtra;
    SetExtraAuditInfo(@clExtra, @ceFieldsCopy, AuditInfo, (clFieldsCopy.clName = ''));
    if (AuditInfo.AuditAction <> aaNone) then
      AuditTable.AddAuditRec(AuditInfo);
  finally
    Dispose(AuditInfo.AuditRecord);
  end;
end;
{$ENDIF}

{$IFNDEF ParserDll}

function TClientObj.DrCrStr(const Amount: Money): String;
begin
  Result := MoneyUtils.DrCrStr( Amount, clExtra.ceLocal_Currency_Code );
end;

function TClientObj.DrCrStrNoSymbol(const Amount: Money): String;
begin
  Result := MoneyUtils.DrCrStrNoSymbol( Amount );
end;

function TClientObj.FmtBalanceStr: String;
begin
  Result := MoneyUtils.FmtBalanceStr( clExtra.ceLocal_Currency_Code );
end;

function TClientObj.FmtBalanceStrNoSymbol: String;
begin
  Result := MoneyUtils.FmtBalanceStrNoSymbol;
end;

function TClientObj.FmtDrCrStr: String;
begin
  Result := MoneyUtils.FmtDrCrStr( clExtra.ceLocal_Currency_Code );
end;

function TClientObj.FmtDrCrStrNoSymbol: String;
begin
  Result := MoneyUtils.FmtDrCrStrNoSymbol;
end;

function TClientObj.FmtMoneyStr: String;
begin
  Result := MoneyUtils.FmtMoneyStr( clExtra.ceLocal_Currency_Code );
end;

function TClientObj.FmtMoneyStrBrackets: String;
begin
  Result := MoneyUtils.FmtMoneyStrBrackets( clExtra.ceLocal_Currency_Code );
end;

function TClientObj.FmtMoneyStrBracketsNoSymbol: String;
begin
  Result := MoneyUtils.FmtMoneyStrBracketsNoSymbol;
end;

{$ENDIF}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TClientObj.LoadFromStream(var s : TIOStream);
const
  ThisMethodName = 'TClientObj.LoadFromStream';
var
  Token : byte;
{$IFDEF ParserDll}
{$ELSE}
  Msg   : String;
{$ENDIF}
begin
  LogDebugMsg( ThisMethodName + ' Begins');
  Token := s.ReadToken;
  While (Token <> tkEndSection) do
  begin
    case Token of
       tkBegin_Client            : Read_Client_Rec(clFields,s);
{$IFDEF ParserDll}
       else Break; //Where are done..
    end;
{$ELSE}
       tkLastAuditRecordID       : FLastAuditRecordID := S.ReadIntegerValue;
       tkBeginBankAccountList    : clBank_Account_List.LoadFromFile( S );
       tkBeginChart              : clChart.LoadFromFile( S );
       tkBeginPayees             : clPayee_List_V53.LoadFromFile( S );
       tkBeginPayeesList         : clPayee_List.LoadFromFile( S);
       tkBeginMacros             : clMacro_List.LoadFromFile( S );
       tkBeginDiskList           : clDisk_Log.LoadFromFile( S );
       tkBeginBudgetList         : clBudget_List.LoadFromFile( S );
       tkBeginBalancesList       : clBalances_List.LoadFromFile( S );
       tkBeginCustomHeadingsListEx : clCustom_Headings_List.LoadFromFile( S);
       tkBegin_MoreClient        : Read_MoreClient_Rec(clMoreFields,s);
       tkBeginJobList            : clJobs.LoadFromFile(S);
       tkBegin_ClientExtra       : Read_ClientExtra_Rec (clExtra,s);
       tkBeginExchangeRateHeader : FExchangeSource.LoadFromStream( S );
       tkBeginSystem_Audit_Trail_List  : fAuditTable.LoadFromStream(S);
       tkBegin_TPR_Payer_Detail  : clTPR_Payee_Detail.LoadFromFile(S);
       tkBeginRecommended_Mems   : clRecommended_Mems.LoadFromFile(S);
    else
       begin { Should never happen }
          Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
          LogDebugMsg(Msg, True);
          raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
       end;
    end;
{$EndIf}
    Token := S.ReadToken;
  end;

  LogDebugMsg( ThisMethodName + ' Ends');
end;

//******************************************************************************
//
//       COMMON BITS I.E ParserDll and normal
//
//******************************************************************************



function TClientObj.GetDataStreamFromZipStream(const FileCode: String;
  const ZipStream: TBigMemoryStream): TIOstream;
var
   savFilename : string;
   UnZipper : TVCLZip;
   MemNeeded : Integer;
   I: Integer;
begin
    Result := TIOStream.Create;

    //unzip the zip stream
    Result.Clear;
    ZipStream.Position  := 0;
    savFilename := FileCode + Sav_Extn;

    try
        UnZipper := TVCLZip.Create( nil);
        try
          UnZipper.ArchiveStream := ZipStream;
          UnZipper.ReadZip;

          //figure out how much memory is needed so we can pre allocate it
          MemNeeded := 0;
          for i := 0 to UnZipper.Count - 1 do
            if UnZipper.Filename[ i] = SavFilename then
              MemNeeded := UnZipper.UnCompressedSize[ i];

          Result.Size := MemNeeded;
          Result.Position := 0;

          //store data stream size so we can use it to estimate the file size
          //needed to save
          clRawStreamSize := Result.Size;

          Unzipper.UnzipToStream( Result, savFilename);
        finally
          UnZipper.Free;
        end;
      except
        on e : exception do
          raise ECompressionFailure.Create( 'Error decompressing from ' + FileCode + ' - ' +
                                            E.Message + ' [' + E.Classname + ']');
      end;

end;

procedure TClientObj.GetZipStreamFromFile(var Filename: String; const ZipStream: TBigMemoryStream);

var
  FileStream               : TFileStream;

begin
  FileStream := TFileStream.Create( filename, fmOpenRead or fmShareDenyWrite);
  try
    GetZipStreamFromStream(Filename, FileStream, ZipStream);
  finally
    FileStream.Free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientObj.GetZipStreamFromStream(var Filename: String; const stream: TStream;
  const ZipStream: TBigMemoryStream);

//read a bk5 file and fills the zip stream provided with a zip file
//removes the wrapper from the bk5 file and then decrypts the remaining file
const
  ChunkSize                = 8192;
  ThisMethodName           = 'GetZipStreamFromFile';
  WrapperSize              = SizeOf( TClientWrapper);
var
  Wrapper                  : TClientWrapper;
  Buffer                   : Pointer;
  NumBytesRead             : integer;
  NumBytesWritten          : integer;

begin
   //check the crc
    try
      CrcFileUtils.CheckEmbeddedCRC( Stream);
    except
      On e : exception do
        raise EFileCRCFailure.Create( e.Message + ' [' + e.classname + ']');
    end;


    //reposition the cursor to the front of the file and read the wrapper
    Stream.Position := 0;
    NumBytesRead        := Stream.Read( Wrapper, WrapperSize);
    if NumBytesRead <> WrapperSize then
      raise EFileAccess.CreateFmt( SInvalidWrapperSize, [ Filename]);

    //make sure this is a banklink file
    if ( Wrapper.wSignature <> BankLink_Signature) then
      raise EFileAccess.CreateFmt ( SInvalidSignature, [ Filename]);

    //check the file structure version no
    if ( Wrapper.wVersion > BKDEFS.BK_FILE_VERSION) then
      raise EIncorrectVersion.CreateFmt( SInvalidVersion, [ Filename, Wrapper.wVersion_Reqd_Str]);

    if length(Filename) = 0 then
       Filename := Wrapper.wCode;

    //read the remainder of the stream into the zip stream, decrypt as we go
    //preset the size to avoid reallocations
    ZipStream.Clear;
    ZipStream.Position   := 0;
    ZipStream.Size := ( Stream.Size - WrapperSize);

    GetMem( Buffer, ChunkSize);
    try
      repeat
        NumBytesRead := Stream.Read( Buffer^, ChunkSize);
        if NumBytesRead > 0 then
        begin
          Decrypt( Buffer^, NumBytesRead);
          NumBytesWritten := ZipStream.Write( Buffer^, NumBytesRead);

          if ( NumBytesWritten <> NumBytesRead) then
            raise EFileAccess.Create( SZipStreamWriteError);
        end;
      until ( NumBytesRead < ChunkSize);
    finally
      FreeMem( Buffer, ChunkSize);
    end;

    ZipStream.Position := 0;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TClientObj.ReadFromDataStream(var S: TIOStream);
var
  CRC : LongWord;
begin
  try
    CheckEmbeddedCRC( S);
  except
    On e : exception do
      raise EFileCRCFailure.Create( e.Message + ' [' + e.classname + ']');
  end;

  S.Position := 0;
  S.Read( CRC, Sizeof( LongWord ) );
  Self.LoadFromStream( S);

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TClientObj.Open(FileCode, FileExtension : String);
const
  ThisMethodName = 'TClientObj.Open';
var
  bk5filename      : string;
  SavFilename      : string;  //name of internal file in zip
  DataStream       : TIOStream;
  ZipStream        : TBigMemoryStream;
 // UnZipper         : TVCLZip;
 // MemNeeded        : integer;
 // i                : integer;
begin
  LogDebugMsg( ThisMethodName + ' starts');
  Assert( SizeOf( TClientWrapper) = 240, 'Wrapper size error');

  //construct filename and make sure it exists
  bk5filename := DataDir + FileCode + FileExtension;
  if not BKFileExists( bk5filename) then
    raise EFileAccess.CreateFmt( SFileNotFoundError, [ bk5filename]);

  //read the file
  ZipStream := TBigMemoryStream.Create;
  try
    GetZipStreamFromFile( bk5filename, ZipStream);

    DataStream := self.GetDataStreamFromZipStream(FileCode,ZipStream);

    try
      //read values from data stream
      ReadFromDataStream( DataStream );
  {$IFNDEF ParserDll}
      ClientCopyReload(DataStream);
  {$ENDIF}


  {$IFDEF ParserDll}
        // Realy only interested in
        // Practice Name and Code
  {$ELSE}
        UpdateRefs;
        UpgradeClientToLatestVersion( Self);
        //Update local country code to the base currency if it's not already set
        if clExtra.ceLocal_Currency_Code = '' then
          clExtra.ceLocal_Currency_Code := whCurrencyCodes[clFields.clCountry];
        //update temporary fields
        With clFields do
        Begin
           clFile_Save_Required       := FALSE;
           clTime_of_Last_Save        := CurrentTime;
           clUse_Minus_As_Lookup_Key  := clChart.UseMinusAsLookup;
           clUppercase_Codes          := not clChart.AllowLowerCase;
           clCurrent_CRC              := GetCurrentCRC;
           clCRC_After_Loading        := clCurrent_CRC;
           clCRC_at_Last_Save         := clCurrent_CRC;
           clLast_Auto_Save_CRC       := clCurrent_CRC;
           clTemp_Old_Download_From   := clDownload_From;
        end;

        ReadMemorisationINI(clFields.clCode);

        if MEMSINI_SupportOptions = meiResetMems then
        begin
          MEMSINI_SupportOptions := meiFullfunctionality;
          if Assigned(clRecommended_Mems) then
            clRecommended_Mems.ResetAll;
          WriteMemorisationINI_WithLock(clFields.clCode);
        end;

        FOpened := true;
  {$ENDIF}
    finally
      FreeAndNil( DataStream);
    end;
  finally
    FreeAndNil( ZipStream);
  end;

  LogDebugMsg( ThisMethodName + ' ends');
end;



// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientObj.LogDebugMsg(S: string; Error: Boolean = false);
begin
{$IFDEF ParserDll}
   // We Dont realy use this, but stops me having to add so many switches...
{$ELSE}
  if Error then
     LogUtil.LogMsg(lmError, Unitname, S)
  else
     if DebugMe then
        LogUtil.LogMsg(lmDebug, Unitname, S);
{$ENDIF}
end;


{$IFNDEF ParserDll}


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientObj.SimpleRead(FileCode: string; Stream: TStream);
var
   ZipStream : TBigMemoryStream;
   DataStream: TIOStream; 
begin
   //read the file
  ZipStream := TBigMemoryStream.Create;
  try
    GetZipStreamFromStream( FileCode,Stream, ZipStream);

    DataStream := self.GetDataStreamFromZipStream(FileCode,ZipStream);
    try
      //read values from data stream
      ReadFromDataStream( DataStream );
      UpdateRefs;
      UpgradeClientToLatestVersion( Self);
      //Update local country code to the base currency if it's not already set
      if clExtra.ceLocal_Currency_Code = '' then
        clExtra.ceLocal_Currency_Code := whCurrencyCodes[clFields.clCountry];
      //update temporary fields
      With clFields do
      Begin
        clFile_Save_Required       := FALSE;
        clTime_of_Last_Save        := CurrentTime;
        clUse_Minus_As_Lookup_Key  := clChart.UseMinusAsLookup;
        clUppercase_Codes          := not clChart.AllowLowerCase;
        clCurrent_CRC              := GetCurrentCRC;
        clCRC_After_Loading        := clCurrent_CRC;
        clCRC_at_Last_Save         := clCurrent_CRC;
        clLast_Auto_Save_CRC       := clCurrent_CRC;
        clTemp_Old_Download_From   := clDownload_From;
      end;
    finally
      FreeAndNil(DataStream);
    end;
  finally
    FreeAndNil(ZipStream);
  end;
end;



function TClientObj.MoneyStr(const Amount: Money): String;
begin
  Result := MoneyUtils.MoneyStr( Amount, clExtra.ceLocal_Currency_Code );
end;

function TClientObj.MoneyStrBrackets(const Amount: Money ): String;
begin
  Result := MoneyUtils.MoneyStrBrackets( Amount, clExtra.ceLocal_Currency_Code );
end;

function TClientObj.MoneyStrNoSymbol(const Amount: Money): String;
begin
  Result := MoneyUtils.MoneyStrNoSymbol( Amount );
end;

function TClientObj.NextAuditRecordID: integer;
begin
  Inc(FLastAuditRecordID);
  Result := FLastAuditRecordID;
end;

{$ENDIF}

{$IFDEF ParserDll}

//******************************************************************************
//
//       Parser DLL Only
//
//******************************************************************************


// From WinUtils
function BKFileExists(Filename: string): Boolean;
begin
  Result := GetFileAttributes(PChar(FileName)) <> $FFFFFFFF;
end;

{$ELSE}

//******************************************************************************
//
//       'Normal Only ' (NON Parser DLL) BITS
//
//******************************************************************************

procedure TClientObj.RefreshExchangeSource(DefaultGST: Boolean = True);
var
  LExchangeRates: TExchangeRateList;
begin
  //Refresh exchange rate source
  if Assigned(AdminSystem) then begin
    //Books Secure Client file exchange rates do not get updated
    if HasForeignCurrencyAccounts and (clFields.clDownload_From = dlAdminSystem) then begin
      LExchangeRates := GetExchangeRates;
      try
        ExchangeSource.Assign(LExchangeRates.FindSource('Master'));
        if DefaultGST then
          ApplyDefaultGST(False);
      finally
        LExchangeRates.Free;
      end;
    end;
  end;
end;


procedure TClientObj.FillAccountingSystemList(Value: Tstrings);
var I: Integer;
begin
   Value.BeginUpdate;
   try
      Value.Clear;
      with ClFields do case clCountry of

      whNewZealand: begin
            for I := snMin to snMax do
              if (not Software.ExcludeFromAccSysList(clCountry, I))
              or (I = clAccounting_System_Used) then
                 Value.AddObject(snNames[I], TObject(I));
         end;

      whAustralia: begin
            for I := saMin to saMax do
               if (not Software.ExcludeFromAccSysList(clCountry, I))
               or (I = clAccounting_System_Used) then
                  Value.AddObject(saNames[I], TObject(I));
         end;

      end;
   finally
      Value.EndUpdate;
   end;
end;

procedure TClientObj.FillIsoCodeList(ISOCodes: TStrings);
var
  i: integer;
  BA: TBank_Account;
begin
  if not Assigned(ISOCodes) then Exit;

  ISOCodes.Clear;
  for i := 0 to Pred(clBank_Account_List.ItemCount) do begin
    BA := clBank_Account_List.Bank_Account_At(i);
    if Assigned(BA) then begin
      if ISOCodes.IndexOf(BA.baFields.baCurrency_Code) = -1 then
        ISOCodes.Add(BA.baFields.baCurrency_Code);
    end;
  end;
  TStringList(ISOCodes).Sort;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientObj.SaveToStream(var s:TIOStream);
const
  ThisMethodName = 'TClientObj.SaveToStream';
begin
   LogDebugMsg( ThisMethodName + ' Begins' );
   S.WriteIntegerValue(tkLastAuditRecordID, FLastAuditRecordID);
   BKCLIO.Write_Client_Rec ( clFields, S );
   {write components}
   clBank_Account_List.SaveToFile( S );
   clChart.SaveToFile( S );
   clPayee_List.SaveToFile( S);
   clMacro_List.SaveToFile( S );
   clDisk_Log.SaveToFile( S );
   clBudget_List.SaveToFile( S );
   clBalances_List.SaveToFile( S );
   clCustom_Headings_List.SaveToFile( S);
   BKMCIO.Write_MoreClient_Rec( clMoreFields, S );
   clJobs.SaveToFile(S);
   BKCEIO.Write_ClientExtra_Rec(clExtra,S);
   FExchangeSource.SaveToStream( S );
   fAuditTable.SaveToStream( S );
   clTPR_Payee_Detail.SaveToFile( S );
   clRecommended_Mems.SaveToFile(S);
   S.WriteToken( tkEndSection );
   LogDebugMsg(ThisMethodName + ' Ends' );
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientObj.SetAuditInfo(P1, P2: pClient_Rec; var AAuditInfo: TAuditInfo);
var
  i: integer;
begin
  if Client_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then begin
    if P2.clName = '' then
      AAuditInfo.AuditAction := aaAdd
    else begin
      AAuditInfo.AuditAction := aaChange;
      //Save GST/VAT class code so that field changed to blank or zero get shown in audit
      for i := Low(P1.clGST_Class_Codes) to High(P1.clGST_Class_Codes) do
        if P1.clGST_Class_Codes[i] <> '' then
          pClient_Rec(AAuditInfo.AuditRecord).clGST_Class_Codes[i] := P1.clGST_Class_Codes[i];
      //Save the original class code in case the row was deleted
      for i := Low(P2.clGST_Class_Codes) to High(P2.clGST_Class_Codes) do
        if (P2.clGST_Class_Codes[i] <> '') and (P1.clGST_Class_Codes[i] = '') then
          //Set to space so it still shows in the Audit Report
          pClient_Rec(AAuditInfo.AuditRecord).clGST_Class_Codes[i] := ' ';
    end;
    AAuditInfo.AuditRecordID := 0; //Root
    AAuditInfo.AuditParentID := -1; //No parent
    AAuditInfo.AuditRecordType := tkBegin_Client;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientObj.SetExtraAuditInfo(P1, P2: pClientExtra_Rec;
  var AAuditInfo: TAuditInfo; NewClient: boolean = false);
begin
  if ClientExtra_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then begin
    AAuditInfo.AuditAction := aaChange;
    if NewClient then
      AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := 0; //Root
    AAuditInfo.AuditParentID := -1; //No parent
    AAuditInfo.AuditRecordType := tkBegin_ClientExtra;
  end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientObj.UpdateRefs;
const
  ThisMethodName = 'TClientObj.UpdateRefs';
Var
   B  : LongInt;
Begin
   LogDebugMsg( ThisMethodName + ' Begins' );
   With clBank_Account_List do
      For B := 0 to Pred( ItemCount ) do
         With Bank_Account_At( B ) do
         begin
            baFields.baNumber := B;
            UpdateSequenceNumbers;  //Bank_Account.
         end;
   LogDebugMsg( ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{$IFNDEF ParserDll}
function TClientObj.GetClientCopy: TClientObj;
begin
  if not Assigned(FClientCopy) then begin
    FClientCopy := TClientObj.Create;
  end;
  Result := FClientCopy;
end;
{$ENDIF}

Function TClientObj.GetCurrentCRC : LongInt;
const
   ThisMethodName = 'TClientObj.GetCurrentCRC';
var
   CRC         : LongWord;
Begin
   LogDebugMsg( ThisMethodName+' Begins');
   CRC := 0;

   BKCRC.UpdateCRC( clFields, CRC);
   clBank_Account_List.UpdateCRC( CRC);
   clChart.UpdateCRC( CRC);
   clPayee_List.UpdateCRC( CRC);
   clMacro_List.UpdateCRC( CRC);
   clBalances_List.UpdateCRC( CRC);
   clDisk_Log.UpdateCRC( CRC);
   clBudget_List.UpdateCRC( CRC);
   clCustom_Headings_List.UpdateCRC( CRC);
   BKCRC.UpdateCRC( clMoreFields, CRC);
   BKCRC.UpdateCRC( clExtra, CRC);
   If DebugMe then LogUtil.LogMsg( lmDebug, UnitName, Format( '%s  %s CRC=%d', [ThisMethodName, clFields.clCode, CRC] ));

   Result := LongInt( CRC );
   LogDebugMsg( ThisMethodName+' Ends');
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TClientObj.GetForexISOCodeForContra(AContraCode: string): string;
  var
  i: integer;
  ba : TBank_Account;
begin
  Result := '';
  for i := 0 to clBank_Account_List.ItemCount - 1 do begin
    ba := TBank_Account(clBank_Account_List.Bank_Account_At(i));
    if Assigned(ba) then begin
      if (ba.baFields.baContra_Account_Code = AContraCode) then begin
        if ba.IsAForexAccount then begin
          Result := ba.baFields.baCurrency_Code;
          Break;
        end;
      end;
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.TaxSystemName: String;
begin
  Result := whTaxSystemNames[ clFields.clCountry ];
end;

function TClientObj.TaxSystemNameUC: String;
begin
  Result := whTaxSystemNamesUC[ clFields.clCountry ];
end;

function TClientObj.TestForChange : boolean;
const
   ThisMethodName = 'TClientObj.TestForChange';
begin
   LogDebugMsg( ThisMethodName+' Begins');
   result := false;
   if clFields.clFile_Save_Required then exit;

   with clFields do
   begin
      clCurrent_CRC := GetCurrentCRC;
      If ( clCurrent_CRC <> clCRC_at_Last_Save ) then
      Begin
         clFile_Save_Required := TRUE;
         result := true;
      end;
   end;
   LogDebugMsg( ThisMethodName+' Ends');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.GetLongName: string;
begin
  result := clFields.clCode+' : '+clFields.clName;
  if clFields.clFile_Read_Only then
    result := result + ' (READ-ONLY)';
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.GSTHasBeenSetup: Boolean;
Var i : Integer;
Begin
  Result := False;
  With clFields do
  Begin
     For i := 1 to MAX_GST_CLASS do if clGST_Class_Codes[ i ] <> '' then
     Begin
        Result := True;
        exit;
     end;
  end;
end;

function TClientObj.HasForeignCurrencyAccounts: Boolean;
Var
  I : LongInt;
Begin
  Result := False;
  With clBank_Account_List do
    for I := 0 to Pred( itemCount ) do
      If Bank_Account_At( I ).IsAForexAccount then
        Result := True;
End;

function TClientObj.HasExchangeRates(var ISOCodeText: string;
      const FromDate: integer = 0; const ToDate: integer = MaxInt;
      ForReport: boolean = False; AllBankAccounts: boolean = true): Boolean;
var
  i: integer;
  BA: TBank_Account;
begin
  //Checks if all transaction have exchange rates for either all bank accounts, or
  //only the bank accounts selected for a report. If ForReport then the calculated
  //base amount is stored in a temp field in the transaction - for both Forex and
  //Base currency bank accounts. The temp field is then used by the traverse mgr
  //to calculate account totals.
  //If exchange rates are missing then ISOCodeText is populated with the ISO codes.
  RefreshExchangeSource;
  ISOCodeText := '';
  Result := True;
  for i := clBank_Account_List.First to clBank_Account_List.Last do begin
    BA := clBank_Account_List.Bank_Account_At(i);
    if AllBankAccounts or (ForReport and BA.baFields.baTemp_Include_In_Report) then begin
      if not BA.HasExchangeRates(FromDate, ToDate, ForReport) then begin
        if (ISOCodeText = '') then
          ISOCodeText := BA.baFields.baCurrency_Code
        else begin
          if Pos(BA.baFields.baCurrency_Code, ISOCodeText) = 0 then begin
            if Pos(' and ', ISOCodeText) > 0 then
              ISOCodeText := StringReplace(ISOCodeText, ' and ', ', ', [rfReplaceAll]);
            ISOCodeText := ISOCodeText + ' and ' + UpperCase(BA.baFields.baCurrency_Code);
          end;
        end;
      end;
    end;
  end;
  if (ISOCodeText <> '') then
    Result := False;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TClientObj.IntegrityCheck;
const
   ThisMethodName = 'IntegrityCheck';
var
   I: Integer;
   procedure RaiseIntegrityException( FailureReason : string );
   var Msg : string;
   begin
      Msg := 'Failure '+ FailureReason+'  index='+IntToStr(I);
      LogDebugMsg( ThisMethodName + ' : ' + Msg, True );
      raise EDataIntegrity.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
   end;

var
   B        : Integer;
   Dissect_Total : Money;
   This: pDissection_Rec;
   Tran: tTransaction_Rec; // for debug...
   LastCode     : string[40];
   LastEffDate  : Longint;

   //MinValid date and MaxValid date have been moved to
   //globals.pas so that can use in validation of entered dates

begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if clFields.clRecord_Type <> tkBegin_Client then begin
      RaiseIntegrityException('clRecord_Type');
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if clFields.clEOR <> tkEnd_Client then Begin
      RaiseIntegrityException('clEOR');
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if clMoreFields.mcRecord_Type <> tkBegin_MoreClient then begin
      RaiseIntegrityException('clRecord_Type');
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if clMoreFields.mcEOR <> tkEnd_MoreClient then Begin
      RaiseIntegrityException('clEOR');
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if clTPR_Payee_Detail.As_pRec.prRecord_Type <> tkBegin_TPR_Payer_Detail then
   begin
     RaiseIntegrityException('clRecord_Type');
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   if clTPR_Payee_Detail.As_pRec.prEOR <> tkEnd_TPR_Payer_Detail then
   begin
     RaiseIntegrityException('prEOR');
   end;

   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   LastCode := '';
   with clBank_Account_List do Begin
      for B := 0 to Pred( ItemCount ) do begin
         with Bank_Account_At( B ), baFields do begin
            If baBank_Account_Number < LastCode then Begin
               RaiseIntegrityException('Bank Account Sequence');
            end;
            LastCode := baBank_Account_Number;

            baMemorisations_List.CheckIntegrity;

            LastEffDate := 0;
            with baTransaction_List do begin
               for I := 0 to Pred( ItemCount ) do begin
                  Tran := Transaction_At(I)^;
                  with tran do begin

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

                     if ( txFirst_Dissection <> NIL ) then begin
                        Dissect_Total := 0;
                        This := txFirst_Dissection;
                        while This<>NIL do with This^ do begin
                           Dissect_Total := Dissect_Total + dsAmount;
                           This := dsNext;
                        end;
                        If tran.txAmount <> Dissect_Total then Begin
                           RaiseIntegrityException('Dissection Total');
                        end;
                     end;

                     if ( txFirst_Dissection <> NIL ) then begin
                        Dissect_Total := 0;
                        This := txFirst_Dissection;
                        while This<>NIL do with This^ do begin
//                           Dissect_Total := Dissect_Total + dsForeign_Currency_Amount;
                           Dissect_Total := Dissect_Total + This^.Local_Amount;
                           This := dsNext;
                        end;
//                        If tran.txForeign_Currency_Amount <> Dissect_Total then Begin
                        If tran.Local_Amount <> Dissect_Total then Begin
                           RaiseIntegrityException('Foreign Currency Dissection Total');
                        end;
                     end;
                  end;
               end;
            end; //with baTransaction_List
         end; //with bankAccount
      end;
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   LastCode := '';
   with clChart do Begin
      for i := 0 to Pred( ItemCount ) do with Account_At( i )^ do Begin
         if STStrS.CompStringS(chAccount_Code , LastCode)  < 0 then Begin
            RaiseIntegrityException(Format('Chart Sequence, %s < %s',[chAccount_Code, LastCode]));
         end;
         LastCode := chAccount_Code;
      end;
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   clPayee_List.CheckIntegrity;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   with clMacro_List do for i := 0 to Pred( ItemCount ) do with Macro_At( i )^ do;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   with clDisk_Log do for i := 0 to Pred( ItemCount ) do with Disk_Log_At( i )^ do;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   with clBudget_List do Begin
      for i := 0 to Pred( ItemCount ) do Begin
         with Budget_At( i ) do Begin
            if buFields.buRecord_Type <> tkBegin_Budget_Header then Begin
               RaiseIntegrityException('buRecord_Type');
            end;
            if buFields.buEOR <> tkEnd_Budget_Header then Begin
               RaiseIntegrityException('buEOR');
            end;
            with buDetail do for B := 0 to Pred( ItemCount ) do with Budget_Detail_At( B )^ do;
         end;
      end;
   end;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   with clBalances_List do for i := 0 to Pred( ItemCount ) do with Balances_At( i )^ do;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   //check custom headings list
   clCustom_Headings_List.CheckIntegrity;
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  LogDebugMsg( ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TClientObj.SaveToDataStream(var S: TIOStream; DefaultSize : integer = 0);
var
  CRC : LongWord;
begin
{$IFNDEF ParserDll}
  //*** Flag Audit ***
  //Can't select which bank accounts to audit yet - so all
  //need to be checked on client save.
  FClientAuditMgr.Country := clFields.clCountry;   
  FClientAuditMgr.FlagAudit(arClientBankAccounts);
  //Restricted auditing to UK
  if (clFields.clCountry = whUK) then
    FClientAuditMgr.DoAudit;
{$ENDIF}
  //Save
  S.Clear;
  S.Size := DefaultSize;
  S.Position := 0;
  CRC := 0;
  S.Write( CRC, SizeOf( CRC));
  Self.SaveToStream( S);
  S.Size := S.Position;
  EmbedCRC( S);
{$IFNDEF ParserDll}
  ClientCopyReload(S);
{$ENDIF}

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.WithdrawalEntryType: Byte;
begin
  Result := whWithdrawalEntryType[ clFields.clCountry ];
end;

function TClientObj.SaveClientToStream: TBigMemoryStream;
const
  ChunkSize                = 8192;
  ThisMethodName           = 'SaveClientToStream';
  WrapperSize              = SizeOf( TClientWrapper);
var
  Wrapper                  : TClientWrapper;
  Buffer                   : Pointer;
  NumBytesRead             : integer;
  NumBytesWritten          : integer;
  DataStream               : TIOStream;
  ZipStream                : TBigMemoryStream;
  Zipper                   : TVCLZip;
  SavFilename              : string;
begin
  Result := nil;

  Self.IntegrityCheck;

  //update fields in client file
  clFields.clFile_Version := BKDEFS.BK_FILE_VERSION;

  SavFilename := clFields.clCode + Sav_Extn;
  //write values to data stream
  ZipStream := nil;
  DataStream := TIOStream.Create;
  try
    //save raw stream, estimate size based on load size + 256K
    SaveToDataStream( DataStream, clRawStreamSize + $40000);
    //store for next save
    clRawStreamSize := DataStream.Size;

    //compress and encrypt data stream
    ZipStream := TBigMemoryStream.Create;

    Zipper := TVCLZip.Create( nil);
    try try
        Zipper.ArchiveStream := ZipStream;
        Zipper.ZipFromStream( DataStream, SavFilename);
    except
       on e : exception do
          raise ECompressionFailure.Create( 'Error compressing into ' + savFilename + ' - ' +
                                              E.Message + ' [' + E.Classname + ']');
    end;
    finally
       //can now do away with the data stream as it is no longer used
       //do this to reduce memory usage
       FreeAndNil(Zipper);
       FreeAndNil(DataStream);
    end;

    //update the wrapper
    FillChar( Wrapper, WrapperSize, #0);
    Wrapper.wCRC       := 0;  //will be updated later
    with Wrapper, clFields do begin
       wCountry           := clCountry;
       wCode              := clCode;
       wName              := clName;
       wVersion           := clFile_Version;
       wOldPassword       := '';  //Case 9444. Clear old password and just used the hashed one for the wrapper;
       wPwdHash           := CreatePasswordHash(clFile_Password);
       (*  Disabled for now, see case 1743
       if wVersion > 122 then // If can be removed after debugging..
          cryptx.Encrypt(wPassword,Sizeof(wPassword));
       *)
       wVersion_Reqd_Str  := BKDEFS.BK_FILE_VERSION_STR;
       wSave_Count        := clFile_Save_Count;
       wDate_Stored       := CurrentDate;
       wTime_Stored       := CurrentTime;
       wMagic_Number      := clMagic_Number;
       wReport_Start_Date := clReport_Start_Date;
       wReporting_Period  := clReporting_Period;
       wRead_Only         := clFile_Read_Only;
       wSignature         := BankLink_Signature;
       wUpdateServer      := '';
       wFileTransferMethod := clExtra.ceFile_Transfer_Method;
    end;

    //create result
    Result := TBigMemoryStream.Create;

    //Preset Expected Size
    Result.Clear;
    Result.Size := ZipStream.Size + WrapperSize;
    Result.Position := 0;

    //write out wrapper
    NumBytesWritten := Result.Write( Wrapper, WrapperSize);
    if NumBytesWritten <> WrapperSize then
      raise EFileAccess.CreateFmt( SInvalidWrapperSize, [ clFields.clCode]);

    //copy data from zip stream to file stream, encrypt as we go
    GetMem( Buffer, ChunkSize);
    try
      ZipStream.Position := 0;
      repeat
        NumBytesRead := ZipStream.Read( Buffer^, ChunkSize);
        if NumBytesRead > 0 then
        begin
          CryptX.Encrypt( Buffer^, NumBytesRead);
          NumBytesWritten := Result.Write( Buffer^, NumBytesRead);

          if NumBytesWritten <> NumBytesRead then
            raise EFileAccess.CreateFmt( sFileStreamWriteError, [  clFields.clCode]);
        end;
      until ( NumBytesRead =0);
    finally
      FreeMem( Buffer, ChunkSize);
    end;

    EmbedCRC( Result);
    // BK5FileStream.SaveToFile( Filename);
    Result.Position := 0;
  finally
      FreeAndNil(ZipStream);
  end;

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.BalanceStr(const Amount: Money): String;
begin
  Result := MoneyUtils.BalanceStr( Amount, clExtra.ceLocal_Currency_Code );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.BalanceStrNoSymbol(const Amount: Money): String;
begin
  Result := MoneyUtils.BalanceStrNoSymbol( Amount );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.ChequeEntryType: Byte;
begin
  Result := whChequeEntryType[ clFields.clCountry ];
end;

{$IFNDEF ParserDll}
procedure TClientObj.ClientCopyReload(var S: TIOStream);
begin
  FClientAuditMgr.Country := clFields.clCountry;

  //Restricted auditing to UK
  if (clFields.clCountry <> whUK) then Exit;

  //Reload client copy DB
  FreeAndNil(FClientCopy); //Delete current copy
  S.Seek(Sizeof(LongWord), soFromBeginning);
  ClientCopy.LoadFromStream(S);
end;
{$ENDIF}

procedure TClientObj.ClientCopyReset;
var
  S: TIOStream;
  CRC: longword;
begin
  //This should only be done after a client file upgrade
  //so that existing data is not audited.
  S := TIOStream.Create;
  try
    S.Write(CRC, SizeOf(CRC));
    Self.SaveToStream(S);
{$IFNDEF ParserDll}    
    ClientCopyReload(S);
{$ENDIF}
  finally
    S.Free;
  end;
end;

procedure TClientObj.CommonSave(FileExtension : String; Backup : Boolean);
const
  ThisMethodName = 'TClientObj.CommonSave';
var
  Bk5Filename : string;
  BakFilename : string;
  SavFilename : string;
  TmpFilename : string;


  FileStream : TBigMemoryStream;

begin
  LogDebugMsg( ThisMethodName + ' Starts');

  //check file integrity


  //set file names
  Bk5Filename := DataDir + clFields.clCode + FileExtension;
  BakFilename := DataDir + clFields.clCode + Globals.BACKUPEXTN;
  TmpFilename := DataDir + clFields.clCode + Globals.TmpExtn;
  SavFilename := clFields.clCode + Globals.SAV_EXTN;

  FileStream := SaveClientToStream;
  try

      //now save to file
      FileStream.SaveToFile( TmpFilename);

  finally
    FileStream.Free;
  end;


  //Backup the previous .BK5 file to .BAK
  if (Backup) and BKFileExists( BK5FileName ) then
  begin
     if BKFileExists( BakFileName ) then
        WinUtils.RemoveFile( BakFilename);

     WinUtils.RenameFileEx( Bk5FileName, BakFileName );
  end;

  //Rename the new .TMP file as .BK5.
  if BKFileExists( BK5FileName ) then
     WinUtils.RemoveFile( BK5FileName );

  WinUtils.RenameFileEx( TmpFileName, BK5FileName );

  LogDebugMsg( ThisMethodName + ' Ends');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientObj.Save;
const
  ThisMethodName = 'TClientObj.Save';
begin
  LogDebugMsg( ThisMethodName + ' Starts');

  Inc( Self.clFields.clFile_Save_Count);
  // - - - - - - - - - - - - - - - - -
  CommonSave(Globals.FileExtn, True);
  // - - - - - - - - - - - - - - - - -
  Self.clFields.clFile_Save_Required := false;
  Self.clFields.clCurrent_CRC        := GetCurrentCRC;
  Self.ClFields.clCRC_at_Last_Save   := Self.clFields.clCurrent_CRC;

  LogDebugMsg( ThisMethodName + ' Ends');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.AccountCodeCompare(Item1, Item2: ShortString): integer;
var
  AccntRec1, AccntRec2: pAccount_Rec;
begin
  if UseXlonSort then
    Result := XlonSort( UpperCase(Item1), UpperCase(Item2))
  else begin
    AccntRec1 := clChart.FindCode(Item1);
    AccntRec2 := clChart.FindCode(Item2);
    if Assigned(AccntRec1) and Assigned(AccntRec2) then
      Result := clChart.Compare( AccntRec1, AccntRec2)
    else
      Result := StStrS.CompStringS( UpperCase(Item1), UpperCase(Item2));
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TClientObj.AutoSave;
const
  ThisMethodName = 'TClientObj.AutoSave';
begin
  LogDebugMsg( ThisMethodName + ' Starts');

  //increment the file save if this is the first auto save
  if Self.clFields.clLast_Auto_Save_CRC = Self.clFields.clCRC_After_Loading then
    Inc( Self.clFields.clFile_Save_Count);
  // - - - - - - - - - - - - - - - - -
  CommonSave(Globals.AutoSaveExtn, False);
  // - - - - - - - - - - - - - - - - -
  Self.clFields.clCurrent_CRC        := GetCurrentCRC;
  Self.ClFields.clLast_Auto_Save_CRC := Self.clFields.clCurrent_CRC;

  LogDebugMsg( ThisMethodName + ' Ends');
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function TClientObj.GetAccountingSystemName: string;
begin
  result := '';
  case clFields.clCountry of
    whNewZealand : begin
      if clFields.clAccounting_System_Used in [snMin..snMax] then
        result := snNames[ clFields.clAccounting_System_Used];
    end;

    whAustralia : begin
      if clFields.clAccounting_System_Used in [saMin..saMax] then
        result := saNames[ clFields.clAccounting_System_Used];
    end;

    whUK : begin
      if clFields.clAccounting_System_Used in [suMin..suMax] then
        result := suNames[ clFields.clAccounting_System_Used];
    end;
  end;
end;

{$ENDIF}

initialization
{$IFDEF ParserDll}
   DataDir := ExtractFilePath(ParamStr(0));
{$ELSE}
   DebugMe := DebugUnit(UnitName);
{$ENDIF}
end.

