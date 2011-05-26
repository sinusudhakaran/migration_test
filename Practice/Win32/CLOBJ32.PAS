unit clObj32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//main client object handles loading and saving of all contained objects
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   Classes, bkDefs, ioStream,
{$IFDEF ParserDll}
   // The Parser DLL just need to read the client fields
   // All the rest is not needed,
   // and is removed to keep the Dll file size under control
{$ELSE}
   BaList32, chList32, pyList32, maList32, dlList32,
   buList32, blList32, jobobj,
   PayeeObj,
   CustomHeadingsListObj, ExchangeRateList, mcDefs, AuditMgr,
{$ENDIF}
   sysutils, MoneyDef;

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
    FAuditTable            : TAuditTable;
    FClientAuditMgr        : TClientAuditManager;
{$ENDIF}
    clWas_Code             : string;  //store the client code to detect a rename
    clRawStreamSize        : integer; //store stream size on open so can estimate for save
    constructor Create;
    destructor Destroy; override;
  private
{$IFDEF ParserDll}
{$ELSE}
    FExchangeSource: TExchangeSource;
    FLastAuditRecordID: integer;
    FClientCopy: TClientObj;
{$ENDIF}
    procedure LoadFromStream( var s:TIOStream);
    procedure GetZipStreamFromFile( const Filename : String; const ZipStream : TBigMemoryStream);
    procedure OpenFromDataStream( var S : TIOStream);
    procedure LogDebugMsg(S: string; Error: Boolean = false);
{$IFDEF ParserDll}
{$ELSE}
    function  GetLongName  : string;
    procedure SaveToDataStream( var S : TIOStream; DefaultSize : integer = 0);
    procedure SaveToStream (var s:TIOStream);
    procedure WriteFileFromZipStream(const Filename: string; const ZipStream: TBigMemoryStream);
    function GetAccountingSystemName: string;
    function GetClientCopy: TClientObj;
    procedure SetAuditInfo(P1, P2: pClient_Rec; var AAuditInfo: TAuditInfo);
    procedure SetExtraAuditInfo(P1, P2: pClientExtra_Rec; var AAuditInfo: TAuditInfo; NewClient: boolean = false);
{$ENDIF}
  public
    procedure Open(FileCode, FileExtension : String);
{$IFDEF ParserDll}
{$ELSE}
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
    procedure AddAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
    property AuditTable: TAuditTable read FAuditTable;
    property ClientAuditMgr: TClientAuditManager read FClientAuditMgr;
    property ClientCopy: TClientObj read GetClientCopy;
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
   Upgrade,
   WinUtils,
   BKDBExcept,
   ovcDate,
   MoneyUtils,
   GenUtils,
   StStrS,
   ForexHelpers,
   GSTUTIL32,
   BKAUDIT,
   bkdateutils,
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
   clBank_Account_List    := TBank_Account_List.Create( Self );
   clChart                := TChart.Create;
   clPayee_List_V53       := TPayee_List_V53.Create;
   clPayee_List           := TPayee_List.Create(FClientAuditMgr);
   clMacro_List           := TMacro_List.Create;
   clDisk_Log             := TDisk_List.Create;
   clBudget_List          := TBudget_List.Create;
   clBalances_List        := TBalances_List.Create;
   clJobs                 := TClient_Job_List.Create;
   clCustom_Headings_List := TNew_Custom_Headings_List.Create;

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

   //Audit table
   FreeAndNil(fAuditTable);
   FreeAndNil(FClientAuditMgr);
{$ENDIF}
   inherited Destroy;
   LogDebugMsg( ThisMethodName + ' Ends');
end;

procedure TClientObj.DoAudit(AAuditType: TAuditType; AClientCopy: TClientObj);
var
  AuditInfo: TAuditInfo;
  clFieldsCopy: TClient_Rec;
  ceFieldsCopy: TClientExtra_Rec;
begin
  AuditInfo.AuditAction := aaNone;
  AuditInfo.AuditType := AAuditType;
{$IFNDEF LOOKUPDLL}
  AuditInfo.AuditUser := Globals.CurrUser.Code;
{$ENDIF}
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
//       COMMON BITS
//
//******************************************************************************

procedure TClientObj.GetZipStreamFromFile(const Filename: String; const ZipStream: TBigMemoryStream);
//read a bk5 file and fills the zip stream provided with a zip file
//removes the wrapper from the bk5 file and then decrypts the remaining file
const
  ChunkSize                = 8192;
  ThisMethodName           = 'GetZipStreamFromFile';
  WrapperSize              = SizeOf( TClientWrapper);
var
  FileStream               : TFileStream;
  Wrapper                  : TClientWrapper;
  Buffer                   : Pointer;
  NumBytesRead             : integer;
  NumBytesWritten          : integer;
begin
  FileStream := TFileStream.Create( filename, fmOpenRead or fmShareDenyWrite);
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
    NumBytesRead        := FileStream.Read( Wrapper, WrapperSize);
    if NumBytesRead <> WrapperSize then
      raise EFileAccess.CreateFmt( SInvalidWrapperSize, [ Filename]);

    //make sure this is a banklink file
    if ( Wrapper.wSignature <> BankLink_Signature) then
      raise EFileAccess.CreateFmt ( SInvalidSignature, [ Filename]);

    //check the file structure version no
    if ( Wrapper.wVersion > BKDEFS.BK_FILE_VERSION) then
      raise EIncorrectVersion.CreateFmt( SInvalidVersion, [ Filename, Wrapper.wVersion_Reqd_Str]);

    //read the remainder of the stream into the zip stream, decrypt as we go
    //preset the size to avoid reallocations
    ZipStream.Clear;
    ZipStream.Position   := 0;
    ZipStream.Size := ( FileStream.Size - WrapperSize);

    GetMem( Buffer, ChunkSize);
    try
      repeat
        NumBytesRead := FileStream.Read( Buffer^, ChunkSize);
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
  finally
    FileStream.Free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TClientObj.OpenFromDataStream(var S: TIOStream);
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
{$IFNDEF ParserDll}
  //Reload client copy DB
  FreeAndNil(FClientCopy); //Delete current copy
  S.Position := 0;
  S.Read( CRC, Sizeof( LongWord ) );
  ClientCopy.LoadFromStream(S);
{$ENDIF}
end;

{$IFNDEF ParserDll}
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
{$ENDIF}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TClientObj.Open(FileCode, FileExtension : String);
const
  ThisMethodName = 'TClientObj.Open';
var
  bk5filename      : string;
  SavFilename      : string;  //name of internal file in zip
  DataStream       : TIOStream;
  ZipStream        : TBigMemoryStream;
  UnZipper         : TVCLZip;
  MemNeeded        : integer;
  i                : integer;
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
    DataStream := TIOStream.Create;
    try
      //unzip the zip stream
      DataStream.Clear;
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

          DataStream.Size := MemNeeded;
          DataStream.Position := 0;

          //store data stream size so we can use it to estimate the file size
          //needed to save
          clRawStreamSize := DataStream.Size;

          Unzipper.UnzipToStream( DataStream, savFilename);
        finally
          UnZipper.Free;
        end;
      except
        on e : exception do
          raise ECompressionFailure.Create( 'Error decompressing from ' + savFilename + ' - ' +
                                            E.Message + ' [' + E.Classname + ']');
      end;

      //read values from data stream
      OpenFromDataStream( DataStream );


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

// From WinUtils
function BKFileExists(Filename: string): Boolean;
begin
  Result := GetFileAttributes(PChar(FileName)) <> $FFFFFFFF;
end;

{$ELSE}

//******************************************************************************
//
//       'Normal' (NON Parser DLL) BITS
//
//******************************************************************************



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
   S.WriteToken( tkEndSection );
   LogDebugMsg(ThisMethodName + ' Ends' );
end;

procedure TClientObj.SetAuditInfo(P1, P2: pClient_Rec; var AAuditInfo: TAuditInfo);
begin
  if Client_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then begin
    if P2.clName = '' then
      AAuditInfo.AuditAction := aaAdd
    else
      AAuditInfo.AuditAction := aaChange;
    AAuditInfo.AuditRecordID := 0; //Root
    AAuditInfo.AuditParentID := -1; //No parent
    AAuditInfo.AuditRecordType := tkBegin_Client;
  end;
end;

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
  //Audit
  FClientAuditMgr.DoAudit;
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
  //Reload client copy DB after save
  FreeAndNil(FClientCopy); //Delete current copy
  S.Position := 0;
  S.Read( CRC, Sizeof( LongWord ) );
  ClientCopy.LoadFromStream(S);
{$ENDIF}  
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TClientObj.WithdrawalEntryType: Byte;
begin
  Result := whWithdrawalEntryType[ clFields.clCountry ];
end;

procedure TClientObj.WriteFileFromZipStream( const Filename : string; const ZipStream : TBigMemoryStream);
const
  ChunkSize                = 8192;
  ThisMethodName           = 'WriteFileFromZipStream';
  WrapperSize              = SizeOf( TClientWrapper);
var
  BK5FileStream            : TBigMemoryStream;
  Wrapper                  : TClientWrapper;
  Buffer                   : Pointer;
  NumBytesRead             : integer;
  NumBytesWritten          : integer;
begin
  //update the wrapper
  FillChar( Wrapper, WrapperSize, #0);
  Wrapper.wCRC       := 0;  //will be updated later
  with Wrapper, clFields do
  begin
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
  end;

  //create file
  BK5FileStream := TBigMemoryStream.Create;
  try
    //Preset Expected Size
    BK5FileStream.Clear;
    BK5FileStream.Size := ZipStream.Size + WrapperSize;
    Bk5FileStream.Position := 0;

    //write out wrapper
    NumBytesWritten := BK5FileStream.Write( Wrapper, WrapperSize);
    if NumBytesWritten <> WrapperSize then
      raise EFileAccess.CreateFmt( SInvalidWrapperSize, [ Filename]);

    //copy data from zip stream to file stream, encrypt as we go
    GetMem( Buffer, ChunkSize);
    try
      ZipStream.Position := 0;
      repeat
        NumBytesRead := ZipStream.Read( Buffer^, ChunkSize);
        if NumBytesRead > 0 then
        begin
          CryptX.Encrypt( Buffer^, NumBytesRead);
          NumBytesWritten := BK5FileStream.Write( Buffer^, NumBytesRead);

          if NumBytesWritten <> NumBytesRead then
            raise EFileAccess.CreateFmt( sFileStreamWriteError, [ Filename]);
        end;
      until ( NumBytesRead =0);
    finally
      FreeMem( Buffer, ChunkSize);
    end;

    EmbedCRC( BK5FileStream);
    BK5FileStream.SaveToFile( Filename);
  finally
    BK5FileStream.Free;
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

procedure TClientObj.CommonSave(FileExtension : String; Backup : Boolean);
const
  ThisMethodName = 'TClientObj.CommonSave';
var
  Bk5Filename : string;
  BakFilename : string;
  SavFilename : string;
  TmpFilename : string;

  DataStream  : TIOStream;
  ZipStream   : TBigMemoryStream;
  Zipper      : TVCLZip;
begin
  LogDebugMsg( ThisMethodName + ' Starts');

  //check file integrity
  Self.IntegrityCheck;

  //set file names
  Bk5Filename := DataDir + clFields.clCode + FileExtension;
  BakFilename := DataDir + clFields.clCode + Globals.BACKUPEXTN;
  TmpFilename := DataDir + clFields.clCode + Globals.TmpExtn;
  SavFilename := clFields.clCode + Globals.SAV_EXTN;

  //update fields in client file
  clFields.clFile_Version := BKDEFS.BK_FILE_VERSION;

  //write values to data stream
  DataStream := TIOStream.Create;
  try
    //save raw stream, estimate size based on load size + 256K
    SaveToDataStream( DataStream, clRawStreamSize + $40000);
    //store for next save
    clRawStreamSize := DataStream.Size;

    //compress and encrypt data stream
    ZipStream := TBigMemoryStream.Create;
    try
      Zipper := TVCLZip.Create( nil);
      try
        try
          Zipper.ArchiveStream := ZipStream;
          Zipper.ZipFromStream( DataStream, SavFilename);
        except
          on e : exception do
            raise ECompressionFailure.Create( 'Error compressing into ' + savFilename + ' - ' +
                                              E.Message + ' [' + E.Classname + ']');
        end;
      finally
        Zipper.Free;
      end;

      //can now do away with the data stream as it is no longer used
      //do this to reduce memory usage
      FreeAndNil( DataStream);

      //now save to file
      WriteFileFromZipStream( TmpFilename, ZipStream);

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
    finally
      ZipStream.Free;
    end;
  finally
    DataStream.Free;
  end;
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

procedure TClientObj.AddAuditValues(AAuditRecord: TAudit_Trail_Rec;
  var Values: string);
var
//  i: integer;
//  PW: string;
  ARecord: Pointer;
  Token, idx: byte;
begin
  ARecord := AAuditRecord.atAudit_Record;
  if ARecord = nil then Exit;


  case AAuditRecord.atAudit_Record_Type of
    tkBegin_Client:
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
            //Code
            22: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 21),
                                              tClient_Rec(ARecord^).clCode, Values);
            //Name
            23: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 22),
                                              tClient_Rec(ARecord^).clName, Values);
            //Address_L1
            24: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 23),
                                              tClient_Rec(ARecord^).clAddress_L1, Values);
            //Address_L2
            25: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 24),
                                              tClient_Rec(ARecord^).clAddress_L2, Values);
            //Address_L3
            26: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 25),
                                              tClient_Rec(ARecord^).clAddress_L3, Values);
            //Contact_Name
            27: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 26),
                                              tClient_Rec(ARecord^).clContact_Name, Values);
            //Phone_No
            28: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 27),
                                              tClient_Rec(ARecord^).clPhone_No, Values);
            //Fax_No
            29: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 28),
                                              tClient_Rec(ARecord^).clFax_No, Values);
      //    FAuditNamesArray[20,29] := 'File_Password';
      //    FAuditNamesArray[20,30] := 'Practice_Name';
            //Practice_Name
            31: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 30),
                                              tClient_Rec(ARecord^).clPractice_Name, Values);
            //Staff_Member_Name
            32: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 31),
                                              tClient_Rec(ARecord^).clStaff_Member_Name, Values);
            //Practice_EMail_Address
            33: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 32),
                                              tClient_Rec(ARecord^).clPractice_EMail_Address, Values);
            //Staff_Member_EMail_Address
            34: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 33),
                                              tClient_Rec(ARecord^).clStaff_Member_EMail_Address, Values);
            //Client_EMail_Address
            35: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 34),
                                              tClient_Rec(ARecord^).clClient_EMail_Address, Values);
      //    FAuditNamesArray[20,35] := 'Country';
      //    FAuditNamesArray[20,36] := 'File_Name';
      //    FAuditNamesArray[20,37] := 'File_Type';
      //    FAuditNamesArray[20,38] := 'File_Version';
      //    FAuditNamesArray[20,39] := 'File_Save_Count';
      //    FAuditNamesArray[20,40] := 'BankLink_Connect_Password';
      //    FAuditNamesArray[20,41] := 'PIN_Number';
      //    FAuditNamesArray[20,42] := 'Old_Restrict_Analysis_Codes';
            //Financial_Year_Starts
            44: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 43),
                                              BkDate2Str(tClient_Rec(ARecord^).clFinancial_Year_Starts), Values);
    //    FAuditNamesArray[20,44] := 'Report_Start_Date';
    //    FAuditNamesArray[20,45] := 'Reporting_Period';
      //    FAuditNamesArray[20,46] := 'Old_Send_Reports_To';
    //    FAuditNamesArray[20,47] := 'Send_Coding_Report';
    //    FAuditNamesArray[20,48] := 'Send_Chart_of_Accounts';
    //    FAuditNamesArray[20,49] := 'Send_Unpresented_Cheque_List';
    //    FAuditNamesArray[20,50] := 'Send_Payee_List';
    //    FAuditNamesArray[20,51] := 'Send_Payee_Report';
    //    FAuditNamesArray[20,52] := 'Short_Name';
    //    FAuditNamesArray[20,53] := 'Long_Name';
    //    FAuditNamesArray[20,54] := 'GST_Number';
    //    FAuditNamesArray[20,55] := 'GST_Period';
      //    FAuditNamesArray[20,56] := 'GST_Start_Month';
      //    FAuditNamesArray[20,57] := 'GST_Applies_From';
      //    FAuditNamesArray[20,58] := 'GST_Class_Names';
      //    FAuditNamesArray[20,59] := 'GST_Class_Types';
      //    FAuditNamesArray[20,60] := 'GST_Account_Codes';
      //    FAuditNamesArray[20,61] := 'GST_Rates';
      //    FAuditNamesArray[20,62] := 'GST_Basis';
      //    FAuditNamesArray[20,63] := 'GST_on_Presentation_Date';
      //    FAuditNamesArray[20,64] := 'GST_Excludes_Accruals';
      //    FAuditNamesArray[20,65] := 'GST_Inclusive_Cashflow';
      //    FAuditNamesArray[20,66] := 'Accounting_System_Used';
      //    FAuditNamesArray[20,67] := 'Account_Code_Mask';
      //    FAuditNamesArray[20,68] := 'Load_Client_Files_From';
      //    FAuditNamesArray[20,69] := 'Save_Client_Files_To';
      //    FAuditNamesArray[20,70] := 'Chart_Is_Locked';
      //    FAuditNamesArray[20,71] := 'Chart_Last_Updated';
      //    FAuditNamesArray[20,72] := 'Coding_Report_Style';
      //    FAuditNamesArray[20,73] := 'Coding_Report_Sort_Order';
      //    FAuditNamesArray[20,74] := 'Coding_Report_Entry_Selection';
      //    FAuditNamesArray[20,75] := 'Coding_Report_Blank_Lines';
      //    FAuditNamesArray[20,76] := 'Coding_Report_Rule_Line';
      //    FAuditNamesArray[20,77] := 'Coding_Report_New_Page';
      //    FAuditNamesArray[20,78] := 'Old_Division_Names';
      //    FAuditNamesArray[20,79] := 'CF_Headings';
      //    FAuditNamesArray[20,80] := 'PR_Headings';
      //    FAuditNamesArray[20,81] := 'Magic_Number';
      //    FAuditNamesArray[20,82] := 'Exception_Options';
      //    FAuditNamesArray[20,83] := 'Period_Start_Date';
      //    FAuditNamesArray[20,84] := 'Period_End_Date';
      //    FAuditNamesArray[20,85] := 'FRS_Print_Chart_Codes';
      //    FAuditNamesArray[20,86] := 'BankLink_Code';
            //BankLink_Code
            87: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 86),
                                              tClient_Rec(ARecord^).clBankLink_Code, Values);
      //    FAuditNamesArray[20,87] := 'Disk_Sequence_No';
      //    FAuditNamesArray[20,88] := 'Staff_Member_LRN';
      //    FAuditNamesArray[20,89] := 'Suppress_Check_for_New_TXns';
            //Download_From
            91: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 90),
                                              dlNames[tClient_Rec(ARecord^).clDownload_From], Values);
            //Last_Batch_Number
            92: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 91),
                                              tClient_Rec(ARecord^).clLast_Batch_Number, Values);
      //    FAuditNamesArray[20,92] := 'Old_GST_Class_Codes';
      //    FAuditNamesArray[20,93] := 'Division_Code_List';
      //    FAuditNamesArray[20,94] := 'SB_Export_As';
      //    FAuditNamesArray[20,95] := 'SB_Upload_To';
      //    FAuditNamesArray[20,96] := 'Coding_Report_Print_TI';
      //    FAuditNamesArray[20,97] := 'V31_GST_Format_Used';
      //    FAuditNamesArray[20,98] := 'Email_Scheduled_Reports';
      //    FAuditNamesArray[20,99] := 'OLD_BAS_Special_Accounts';
      //    FAuditNamesArray[20,100] := 'GST_Class_Codes';
      //    FAuditNamesArray[20,101] := 'Tax_Ledger_Code';
      //    FAuditNamesArray[20,102] := 'EOY_Locked_SB_Only';
      //    FAuditNamesArray[20,103] := 'BAS_Field_Number';
      //    FAuditNamesArray[20,104] := 'BAS_Field_Source';
      //    FAuditNamesArray[20,105] := 'BAS_Field_Account_Code';
      //    FAuditNamesArray[20,106] := 'BAS_Field_Balance_Type';
      //    FAuditNamesArray[20,107] := 'BAS_Field_Percent';
      //    FAuditNamesArray[20,108] := 'GST_Business_Percent';
      //    FAuditNamesArray[20,109] := 'BAS_Calculation_Method';
      //    FAuditNamesArray[20,110] := 'BAS_Dont_Print_Calc_Sheet';
      //    FAuditNamesArray[20,111] := 'BAS_PAYG_Withheld_Period';
      //    FAuditNamesArray[20,112] := 'Fax_Scheduled_Reports';
      //    FAuditNamesArray[20,113] := 'Graph_Headings';
      //    FAuditNamesArray[20,114] := 'Notes';
      //    FAuditNamesArray[20,115] := 'Cheques_Expire_When';
      //    FAuditNamesArray[20,116] := 'Show_Notes_On_Open';
      //    FAuditNamesArray[20,117] := 'ECoding_Entry_Selection';
      //    FAuditNamesArray[20,118] := 'ECoding_Dont_Send_Chart';
      //    FAuditNamesArray[20,119] := 'ECoding_Dont_Send_Payees';
      //    FAuditNamesArray[20,120] := 'ECoding_Dont_Show_Quantity';
      //    FAuditNamesArray[20,121] := 'ECoding_Last_File_No';
      //    FAuditNamesArray[20,122] := 'ECoding_Last_File_No_Imported';
      //    FAuditNamesArray[20,123] := 'ECoding_Export_Scheduled_Reports';
      //    FAuditNamesArray[20,124] := 'Email_Report_Format';
      //    FAuditNamesArray[20,125] := 'BAS_PAYG_Instalment_Period';
      //    FAuditNamesArray[20,126] := 'BAS_Include_FBT_WET_LCT';
      //    FAuditNamesArray[20,127] := 'BAS_Last_GST_Option';
      //    FAuditNamesArray[20,128] := 'BAS_Last_PAYG_Instalment_Option';
      //    FAuditNamesArray[20,129] := 'ECoding_Default_Password';
      //    FAuditNamesArray[20,130] := 'ECoding_Import_Options';
      //    FAuditNamesArray[20,131] := 'ECoding_Last_Import_Dir';
      //    FAuditNamesArray[20,132] := 'ECoding_Last_Export_Dir';
      //    FAuditNamesArray[20,133] := 'Coding_Report_Show_OP';
      //    FAuditNamesArray[20,134] := 'FRS_Show_Quantity';
      //    FAuditNamesArray[20,135] := 'Cflw_Cash_On_Hand_Style';
      //    FAuditNamesArray[20,136] := 'CSV_Export_Scheduled_Reports';
      //    FAuditNamesArray[20,137] := 'FRS_Show_YTD';
      //    FAuditNamesArray[20,138] := 'FRS_Show_Variance';
      //    FAuditNamesArray[20,139] := 'FRS_Compare_Type';
      //    FAuditNamesArray[20,140] := 'FRS_Reporting_Period_Type';
      //    FAuditNamesArray[20,141] := 'FRS_Report_Style';
      //    FAuditNamesArray[20,142] := 'Reporting_Year_Starts';
      //    FAuditNamesArray[20,143] := 'FRS_Report_Detail_Type';
      //    FAuditNamesArray[20,144] := 'FRS_Prompt_User_to_use_Budgeted_figures';
      //    FAuditNamesArray[20,145] := 'Balance_Sheet_Headings';
      //    FAuditNamesArray[20,146] := 'Last_Financial_Year_Start';
      //    FAuditNamesArray[20,147] := '520_Reference_Fix_Run';
      //    FAuditNamesArray[20,148] := 'Tax_Interface_Used';
      //    FAuditNamesArray[20,149] := 'Save_Tax_Files_To';
      //    FAuditNamesArray[20,150] := 'Journal_Processing_Period';
      //    FAuditNamesArray[20,151] := 'Last_Disk_Image_Version';
      //    FAuditNamesArray[20,152] := 'Practice_Web_Site';
      //    FAuditNamesArray[20,153] := 'Practice_Phone';
      //    FAuditNamesArray[20,154] := 'Practice_Logo';
      //    FAuditNamesArray[20,155] := 'Web_Site_Login_URL';
      //    FAuditNamesArray[20,156] := 'Staff_Member_Direct_Dial';
      //    FAuditNamesArray[20,157] := 'Contact_Details_To_Show';
      //    FAuditNamesArray[20,158] := 'ECoding_Dont_Allow_UPIs';
      //    FAuditNamesArray[20,159] := 'ECoding_Dont_Show_Account';
      //    FAuditNamesArray[20,160] := 'ECoding_Dont_Show_Payees';
      //    FAuditNamesArray[20,161] := 'ECoding_Dont_Show_GST';
      //    FAuditNamesArray[20,162] := 'ECoding_Dont_Show_TaxInvoice';
      //    FAuditNamesArray[20,163] := 'Scheduled_File_Attachments';
      //    FAuditNamesArray[20,164] := 'Scheduled_Coding_Report_Style';
      //    FAuditNamesArray[20,165] := 'Scheduled_Coding_Report_Sort_Order';
      //    FAuditNamesArray[20,166] := 'Scheduled_Coding_Report_Entry_Selection';
      //    FAuditNamesArray[20,167] := 'Scheduled_Coding_Report_Blank_Lines';
      //    FAuditNamesArray[20,168] := 'Scheduled_Coding_Report_Rule_Line';
      //    FAuditNamesArray[20,169] := 'Scheduled_Coding_Report_New_Page';
      //    FAuditNamesArray[20,170] := 'Scheduled_Coding_Report_Print_TI';
      //    FAuditNamesArray[20,171] := 'Scheduled_Coding_Report_Show_OP';
      //    FAuditNamesArray[20,172] := 'Scheduled_Client_Note_Message';
      //    FAuditNamesArray[20,173] := 'Custom_Contact_Name';
      //    FAuditNamesArray[20,174] := 'Custom_Contact_EMail_Address';
      //    FAuditNamesArray[20,175] := 'Custom_Contact_Phone';
      //    FAuditNamesArray[20,176] := 'Empty_Journals_Removed';
      //    FAuditNamesArray[20,177] := 'Highest_Manual_Account_No';
      //    FAuditNamesArray[20,178] := 'Contact_Details_Edit_Date';
      //    FAuditNamesArray[20,179] := 'Contact_Details_Edit_Time';
      //    FAuditNamesArray[20,180] := 'Copy_Narration_Dissection';
      //    FAuditNamesArray[20,181] := 'Client_CC_EMail_Address';
      //    FAuditNamesArray[20,182] := 'BAS_Report_Format';
      //    FAuditNamesArray[20,183] := 'WebX_Export_Scheduled_Reports';
      //    FAuditNamesArray[20,184] := 'ECoding_WebSpace';
      //    FAuditNamesArray[20,185] := 'Last_ECoding_Account_UID';
      //    FAuditNamesArray[20,186] := 'Web_Export_Format';
            //Mobile_No
            188: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 187),
                                               tClient_Rec(ARecord^).clMobile_No, Values);
      //    FAuditNamesArray[20,188] := 'Ledger_Report_Summary';
      //    FAuditNamesArray[20,189] := 'Ledger_Report_Show_Notes';
      //    FAuditNamesArray[20,190] := 'Ledger_Report_Show_Quantities';
      //    FAuditNamesArray[20,191] := 'Ledger_Report_Show_Non_Trf';
      //    FAuditNamesArray[20,192] := 'Ledger_Report_Show_Inactive_Codes';
      //    FAuditNamesArray[20,193] := 'Ledger_Report_Bank_Contra';
      //    FAuditNamesArray[20,194] := 'Ledger_Report_GST_Contra';
      //    FAuditNamesArray[20,195] := 'Ledger_Report_Show_Balances';
      //    FAuditNamesArray[20,196] := 'File_Read_Only';
      //    FAuditNamesArray[20,197] := 'CheckOut_Scheduled_Reports';
      //    FAuditNamesArray[20,198] := 'Exclude_From_Scheduled_Reports';
      //    FAuditNamesArray[20,199] := 'Ledger_Report_Show_Gross_And_GST';
      //    FAuditNamesArray[20,200] := 'Salutation';
      //    FAuditNamesArray[20,201] := 'External_ID';
      //    FAuditNamesArray[20,202] := 'System_LRN';
      //    FAuditNamesArray[20,203] := 'Business_Products_Scheduled_Reports';
      //    FAuditNamesArray[20,204] := 'Business_Products_Report_Format';
      //    FAuditNamesArray[20,205] := 'Coding_Report_Wrap_Narration';
      //    FAuditNamesArray[20,206] := 'Ledger_Report_Wrap_Narration';
      //    FAuditNamesArray[20,207] := 'Scheduled_Coding_Report_Wrap_Narration';
      //    FAuditNamesArray[20,208] := 'Force_Offsite_Check_Out';
            //Disable_Offsite_Check_Out
            210: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 209),
                                               tClient_Rec(ARecord^).clDisable_Offsite_Check_Out, Values);
      //    FAuditNamesArray[20,210] := 'Alternate_Extract_ID';
      //    FAuditNamesArray[20,211] := 'Use_Alterate_ID_for_extract';
      //    FAuditNamesArray[20,212] := 'Last_Use_Date';
      //    FAuditNamesArray[20,213] := 'Use_Basic_Chart';
      //    FAuditNamesArray[20,214] := 'Group_Name';
            //Group_Name
            215: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 214),
                                               tClient_Rec(ARecord^).clGroup_Name, Values);
            //Client_Type_Name
            216: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_Client, 215),
                                               tClient_Rec(ARecord^).clClient_Type_Name, Values);
      //    FAuditNamesArray[20,216] := 'BAS_Include_Fuel';
      //    FAuditNamesArray[20,217] := 'Profit_Report_Show_Percentage';
      //    FAuditNamesArray[20,218] := 'ECoding_Send_Superfund';
      //    FAuditNamesArray[20,219] := 'Group_LRN';
      //    FAuditNamesArray[20,220] := 'Client_Type_LRN';
      //    FAuditNamesArray[20,221] := 'Spare_Byte_1';
      //    FAuditNamesArray[20,222] := 'Spare_Byte_2';
      //    FAuditNamesArray[20,223] := 'Practice_Code';
      //    FAuditNamesArray[20,224] := 'CashJ_Column_Order';
      //    FAuditNamesArray[20,225] := 'CashJ_Column_Width';
      //    FAuditNamesArray[20,226] := 'CashJ_Column_is_Hidden';
      //    FAuditNamesArray[20,227] := 'CashJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,228] := 'CashJ_Sort_Order';
      //    FAuditNamesArray[20,229] := 'AcrlJ_Column_Order';
      //    FAuditNamesArray[20,230] := 'AcrlJ_Column_Width';
      //    FAuditNamesArray[20,231] := 'AcrlJ_Column_is_Hidden';
      //    FAuditNamesArray[20,232] := 'AcrlJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,233] := 'AcrlJ_Sort_Order';
      //    FAuditNamesArray[20,234] := 'StockJ_Column_Order';
      //    FAuditNamesArray[20,235] := 'StockJ_Column_Width';
      //    FAuditNamesArray[20,236] := 'StockJ_Column_is_Hidden';
      //    FAuditNamesArray[20,237] := 'StockJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,238] := 'StockJ_Sort_Order';
      //    FAuditNamesArray[20,239] := 'YrEJ_Column_Order';
      //    FAuditNamesArray[20,240] := 'YrEJ_Column_Width';
      //    FAuditNamesArray[20,241] := 'YrEJ_Column_is_Hidden';
      //    FAuditNamesArray[20,242] := 'YrEJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,243] := 'YrEJ_Sort_Order';
      //    FAuditNamesArray[20,244] := 'gstJ_Column_Order';
      //    FAuditNamesArray[20,245] := 'gstJ_Column_Width';
      //    FAuditNamesArray[20,246] := 'gstJ_Column_is_Hidden';
      //    FAuditNamesArray[20,247] := 'gstJ_Column_is_Not_Editable';
      //    FAuditNamesArray[20,248] := 'gstJ_Sort_Order';
      //    FAuditNamesArray[20,249] := 'Favourite_Report_XML';
      //    FAuditNamesArray[20,250] := 'All_EditMode_CES';
      //    FAuditNamesArray[20,251] := 'All_EditMode_DIS';
      //    FAuditNamesArray[20,252] := 'TFN';
      //    FAuditNamesArray[20,253] := 'All_EditMode_Journals';
      //    FAuditNamesArray[20,254] := 'Budget_Column_Width';
          end;
          inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
    tkBegin_ClientExtra :
      begin
        Idx := 0;
        Token := AAuditRecord.atChanged_Fields[idx];
        while Token <> 0 do begin
          case Token of
//    FAuditNamesArray[40,41] := 'TAX_Applies_From';
//    FAuditNamesArray[40,42] := 'TAX_Rates';
            //List_Entries_Sort_Order
            40: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, 43),
                                             tClientExtra_Rec(ARecord^).ceList_Entries_Sort_Order, Values);
//    FAuditNamesArray[40,44] := 'List_Entries_Include';
//    FAuditNamesArray[40,45] := 'List_Entries_Two_Column';
//    FAuditNamesArray[40,46] := 'List_Entries_Show_Balance';
//    FAuditNamesArray[40,47] := 'List_Entries_Show_Notes';
//    FAuditNamesArray[40,48] := 'List_Entries_Wrap_Narration';
//    FAuditNamesArray[40,49] := 'List_Entries_Show_Other_Party';
//    FAuditNamesArray[40,50] := 'Book_Gen_Finance_Reports';
            //Book_Gen_Finance_Reports
            51: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, 50),
                                             tClientExtra_Rec(ARecord^).ceBook_Gen_Finance_Reports, Values);
//    FAuditNamesArray[40,51] := 'FRS_Print_NP_Chart_Code_Titles';
//    FAuditNamesArray[40,52] := 'FRS_NP_Chart_Code_Detail_Type';
            //Allow_Client_Unlock_Entries
            54: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, 53),
                                             tClientExtra_Rec(ARecord^).ceAllow_Client_Unlock_Entries, Values);
            //Allow_Client_Edit_Chart
            55: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, 54),
                                             tClientExtra_Rec(ARecord^).ceAllow_Client_Edit_Chart, Values);
//    FAuditNamesArray[40,55] := 'ECoding_Dont_Send_Jobs';
//    FAuditNamesArray[40,56] := 'Custom_Coding_Report_XML';
//    FAuditNamesArray[40,57] := 'Custom_Coding_Report';
//    FAuditNamesArray[40,58] := 'Coding_Report_Column_Line';
//    FAuditNamesArray[40,59] := 'Scheduled_Custom_CR_XML';
//    FAuditNamesArray[40,60] := 'Budget_Include_Quantities';
//    FAuditNamesArray[40,61] := 'Scheduled_CR_Column_Line';
//    FAuditNamesArray[40,62] := 'Custom_Ledger_Report';
//    FAuditNamesArray[40,63] := 'Custom_Ledger_Report_XML';
//    FAuditNamesArray[40,64] := 'Local_Currency_Code';
            //Block_Client_Edit_Mems
            66: FClientAuditMgr.AddAuditValue(BKAuditNames.GetAuditFieldName(tkBegin_ClientExtra, 65),
                                              tClientExtra_Rec(ARecord^).ceBlock_Client_Edit_Mems, Values);
//    FAuditNamesArray[40,66] := 'Send_Custom_Documents';
//    FAuditNamesArray[40,67] := 'Send_Custom_Documents_List';
//    FAuditNamesArray[40,68] := 'List_Payees_Detailed';
//    FAuditNamesArray[40,69] := 'List_Payees_SortBy';
//    FAuditNamesArray[40,70] := 'List_Payees_Rule_Line';
//    FAuditNamesArray[40,71] := 'Custom_SFLedger_Titles';
//    FAuditNamesArray[40,72] := 'SUI_Period_Start';
//    FAuditNamesArray[40,73] := 'SUI_Period_End';
//    FAuditNamesArray[40,74] := 'Audit_Record_ID';
//    FAuditNamesArray[40,75] := 'SUI_Step_Done';
//    FAuditNamesArray[40,76] := 'Send_Job_List';
          end;
          inc(Idx);
          Token := AAuditRecord.atChanged_Fields[idx];
        end;
      end;
  end;
end;

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
