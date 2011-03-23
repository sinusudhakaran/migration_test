unit SysObj32;

{--------------------------------------------------}
{        administration/system file object         }
{--------------------------------------------------}
interface

uses
  Classes, syDefs, ioStream,
  sysutils,
  //dialogs,

{$IFDEF ParserDll}
{$ELSE}
  usrList32, cflist32, sysDList32, sbaList32, acList32, amList32,
  grplist32, ctypelist32, ExchangeRateList,mcDefs, sysAudit, AuditMgr,
{$ENDIF}
  moneydef;

type
  TSystemObj = class
      fdFields                   : TPractice_Details_Rec;
{$IFDEF ParserDll}
{$ELSE}
      fdSystem_User_List         : TSystem_User_List;
      fdSystem_Client_File_List  : TSystem_Client_File_List;
      fdSystem_Disk_Log          : TSystem_Disk_Log;
      fdSystem_Bank_Account_List : TSystem_Bank_Account_List;
      fdSystem_File_Access_List  : TSystem_File_Access_List;
      fdSystem_Client_Account_Map: TSystem_Client_Account_Map;
      fdSystem_Group_List        : TSystem_Group_List;
      fdSystem_Client_Type_List  : TSystem_Client_Type_List;
      fCurrencyCode              : string;
      fCurrencyList              : tExchange_Rates_Header_Rec;
      fAuditTable                : tAuditTable;
{$ENDIF}
      constructor Create;
      destructor  Destroy; override;
      procedure LogDebugMsg(S: string; Error: Boolean = false);
  private
      SystemFileName : string;
      SystemBackupName : string;
      SystemDownloadBackupName : string;
      FLastAuditRecordID: integer;
      procedure LoadFromStream( Var S : TIOStream );
{$IFDEF ParserDll}
{$ELSE}
      procedure SaveToStream( Var S : TIOStream );
      procedure UpdateCache;
      function GetCurrencyCode: string;
      procedure SetAuditInfo(P1, P2: pPractice_Details_Rec; var AAuditInfo: TAuditInfo);
{$ENDIF}
  public
      procedure Open(IsEncrypted: Boolean = True);
{$IFDEF ParserDll}
{$ELSE}
      procedure Save(IsEncrypted: Boolean = True);
      procedure DownloadSave;
      procedure OpenAndSnapshot( var aSnapshot : TObject; IsEncrypted: Boolean = True);
      // Common utilities
      function NextAuditRecordID: integer;
      function DualAccountingSystem: Boolean;
      function MoneyStr(const Amount: Money): string;
      property CurrencyCode: string read GetCurrencyCode;
      function HasMultiCurrency: Boolean;
      function HasCurrencyBankAccount(ISOCode: string; AddIfMissing: Boolean = False): Boolean;
      procedure ClearISOCodes(pCF : pClient_File_Rec);
      procedure AddISOCode(pCF : pClient_File_Rec; ISOCode: string);
      procedure AddISOCodes(pCF : pClient_File_Rec; ISOCodes: TStrings);
      procedure SyncCurrenciesToSystemAccounts;
      procedure ForceCurrency(ISO: shortstring; CurType: Byte);
      function NewSystemAccount(AccNumber: string; Delivered: Boolean):pSystem_Bank_Account_Rec;
      procedure DoAudit(APracticeDetails: pPractice_Details_Rec; AAuditType: TAuditType);
      procedure AddAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
      property AuditTable: TAuditTable read FAuditTable;
{$ENDIF}
  end;

  function SystemCopy: TSystemObj;

//******************************************************************************
implementation
uses

{$IFDEF ParserDll}
   clObj32, // Has some Global stuff
{$ELSE}
   globals,
   LogUtil,
   WinUtils,
   bkConst,
   MoneyUtils,
   sySBio,
{$ENDIF}
   BK5Except,
   Tokens,
   CRCFileUtils,
   GlobalCache,
   syfdio,
   bkdbExcept,
   windows,

   StreamUtils,
   KeyUtils,
   LbCipher,
   SYAUDIT,
   SYAUDITUTILS;

const
   UnitName = 'SYSOBJ32';
   BUFFER_SIZE = 8192;
var
   DebugMe : Boolean = false;
   _SystemCopy: TSystemObj;

function SystemCopy: TSystemObj;
begin
  if not Assigned(_SystemCopy) then begin
    _SystemCopy := TSystemObj.Create;
  end;
  Result := _SystemCopy;
end;

procedure TSystemObj.LogDebugMsg(S: string; Error: Boolean = false);
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


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TSystemObj.Create;
const
  ThisMethodName = 'TSystemObj.Create';
begin
  LogDebugMsg(ThisMethodName + ' Begins' );
  inherited Create;
  systemFileName := DATADIR + SYSFILENAME;
  FillChar( fdFields, Sizeof( fdFields ), 0 );
  fdFields.fdRecord_Type := tkBegin_Practice_Details;
  fdFields.fdEOR := tkEnd_Practice_Details;
  FLastAuditRecordID := 0;
  if fdFields.fdAudit_Record_ID = 0 then
    fdFields.fdAudit_Record_ID := NextAuditRecordID;
{$IFDEF ParserDll}
  systemBackupName := '';
  systemDownloadBackupName := '';
{$ELSE}
  systemBackupName := DATADIR + SYSBACKNAME;
  systemDownloadBackupName := DATADIR + SYSSAVEDNAME;

  {create lists}
  fdSystem_User_List         := TSystem_User_List.Create;
  fdSystem_Client_File_List  := TSystem_Client_File_List.Create;
  fdSystem_Disk_Log          := TSystem_Disk_Log.Create;
  fdSystem_Bank_Account_List := TSystem_Bank_Account_List.Create;
  fdSystem_File_Access_List  := TSystem_File_Access_List.Create;
  fdSystem_Client_Account_Map:= TSystem_Client_Account_Map.Create;
  fdSystem_Group_List        := TSystem_Group_List.Create;
  fdSystem_Client_Type_List  := TSystem_Client_Type_List.Create;
  fAuditTable                := TAuditTable.Create;
  fillChar(fCurrencyList, Sizeof(fCurrencyList), 0);
{$ENDIF}  
  LogDebugMsg(ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

destructor TSystemObj.Destroy;
const
  ThisMethodName = 'TSystemObj.Destroy';
begin
  LogDebugMsg(ThisMethodName + ' Begins' );
{$IFDEF ParserDll}
{$ELSE}
  {free lists}
  FreeAndNil(fdSystem_Bank_Account_List);
  FreeAndNil(fdSystem_Disk_Log);
  FreeAndNil(fdSystem_Client_File_List);
  FreeAndNil(fdSystem_User_List);
  FreeAndNil(fdSystem_File_Access_List);
  FreeAndNil(fdSystem_Client_Account_Map);
  FreeAndNil(fdSystem_Group_List);
  FreeAndNil(fdSystem_Client_Type_List);
  FreeAndNil(fAuditTable);
{$ENDIF}  
  {free dynamic fields}
  SYFDIO.Free_Practice_Details_Rec_Dynamic_Fields( fdFields);

  inherited Destroy;
  LogDebugMsg(ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystemObj.LoadFromStream(var S: TIOStream);
const
   ThisMethodName = 'TSystemObj.LoadFromStream';
Var
   Token : Byte;
   Msg   : String;
Begin
   LogDebugMsg(ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   begin
      case Token of
         tkBegin_Practice_Details        : Read_Practice_Details_Rec( fdFields, S );
{$IFDEF ParserDll}
         else Break; // Im Done..
      end;
      Token := S.ReadToken;
   end;
{$ELSE}
         tkLastAuditRecordID             : FLastAuditRecordID := S.ReadIntegerValue;
         tkBeginSystem_Disk_Log          : fdSystem_Disk_Log.LoadFromFile( S );
         tkBeginSystem_Client_File_List  : fdSystem_Client_File_List.LoadFromFile( S );
         tkBeginSystem_User_List         : fdSystem_User_List.LoadFromFile( S );
         tkBeginSystem_Bank_Account_List : fdSystem_Bank_Account_List.LoadFromFile( S );
         tkBeginSystem_Access_List       : fdSystem_File_Access_List.LoadFromFile( S );
         tkBeginSystem_Client_Account_Map : fdSystem_Client_Account_Map.LoadFromFile( S );
         tkBeginSystem_Group_List        : fdSystem_Group_List.LoadFromFile( S );
         tkBeginSystem_Client_Type_List  : fdSystem_Client_Type_List.LoadFromFile( S );
         tkBeginExchangeRateHeader       : ReadCurrencyList(fCurrencyList,S);
         tkBeginSystem_Audit_Trail_List  : fAuditTable.LoadFromStream(S);
         else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            LogDebugMsg(Msg, True );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
{$ENDIF}
    //check file version no, may not always get here if the structure has changed
    //because an Unknown token exception will be raised first.  This check will catch
    //any storage format changes.
   if ( fdFields.fdFile_Version > SYDEFS.SY_FILE_VERSION) then begin
      Msg := Format( 'The Admin File cannot be opened by this version of %s. '+
                     'Please upgrade to the latest version or contact Support for further details. (%d)',
                     [ ShortAppName, fdFields.fdFile_Version ]);
      LogDebugMsg(Msg, True );
      raise EIncorrectVersion.Create( Msg);
   end;

   LogDebugMsg(ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TSystemObj.Open(IsEncrypted: Boolean = True);
const
   ThisMethodName = 'TSystemObj.Open';
Var
   S : TIOStream;
   CRC : LongInt;
   Key : TKey128;
Begin
   LogDebugMsg(ThisMethodName + ' Begins' );
   S := TIOStream.Create;
   try
      if not IsEncrypted then
        S.LoadFromFile( SystemFilename)
      else
      begin
        S.Free;
        Key := KeyUtils.GetKey128( 1 );
        S := ReadStreamFromEncryptedFile( SystemFilename, Key );
        if not Assigned(S) then // maybe unencrypted
        begin
          S := TIOStream.Create;
          S.LoadFromFile( SystemFilename);
        end;
      end;

      CheckEmbeddedCRC( S);
      S.Position := 0;
      S.Read( CRC, Sizeof( LongInt ) );
      LoadFromStream( S );
      //Reload system copy DB
      FreeAndNil(_SystemCopy); //Delete current copy
      S.Position := 0;
      S.Read( CRC, Sizeof( LongInt ) );
      SystemCopy.LoadFromStream(S);

{$IFDEF ParserDll}
{$ELSE}
      UpdateCache;
{$ENDIF}
   finally
      S.Free;
   end;
  LogDebugMsg(ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{$IFDEF ParserDll}
{$ELSE}

procedure TSystemObj.SaveToStream(var S: TIOStream);
const
   ThisMethodName = 'TSystemObj.SaveToStream';
begin
   LogDebugMsg(ThisMethodName + ' Begins' );
   S.WriteIntegerValue(tkLastAuditRecordID, FLastAuditRecordID);
   Write_Practice_Details_Rec ( fdFields, S );
   {write lists}
   fdSystem_User_List.SaveToFile( S );
   fdSystem_Client_File_List.SaveToFile( S );
   fdSystem_Disk_Log.SaveToFile( S );
   fdSystem_Bank_Account_List.SaveToFile( S );
   fdSystem_File_Access_List.SaveToFile( S );
   fdSystem_Client_Account_Map.SaveToFile( S );
   fdSystem_Group_List.SaveToFile( S );
   fdSystem_Client_Type_List.SaveToFile( S );
   WriteCurrencyList(fCurrencyList, S);
   fAuditTable.SaveToStream( S );

   LogDebugMsg(ThisMethodName + ' Ends' );
end;

procedure TSystemObj.SetAuditInfo(P1, P2: pPractice_Details_Rec;
  var AAuditInfo: TAuditInfo);
begin
  if Practice_Details_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then begin
    AAuditInfo.AuditAction := aaChange;
    AAuditInfo.AuditRecordID := P1.fdAudit_Record_ID;
    AAuditInfo.AuditParentID := -1; //No parent
    AAuditInfo.AuditRecordType := tkBegin_Practice_Details;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TSystemObj.DualAccountingSystem: Boolean;
begin
    Result :=  (fdFields.fdCountry = whAustralia)
           and (fdFields.fdAccounting_System_Used <> asNone)
           and (fdFields.fdSuperfund_System <> asNone);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TSystemObj.Save(IsEncrypted: Boolean = True);
const
   ThisMethodName = 'TSystemObj.Save';
Var
   S : TIOStream;
   L : LongInt;
   Key : TKey128;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   //update file version no
   fdFields.fdFile_Version := SYDEFS.SY_FILE_VERSION;

   If BKFileExists( SystemFileName ) then
   Begin
      If BKFileExists( SystemBackupName ) then SysUtils.DeleteFile( SystemBackupName );
      SysUtils.RenameFile( SystemFileName, SystemBackupName );
   end;

   S := TIOStream.Create;
   try
      //Audit
      SystemAuditMgr.DoAudit;
      //Save
      L := 0;
      S.Write( L, Sizeof( LongInt ) ); { Leave space for the CRC }
      SaveToStream( S );
      EmbedCRC( S);
      //Reload system copy DB after save
      FreeAndNil(_SystemCopy); //Delete current copy
      S.Position := 0;
      S.Read( L, Sizeof( LongInt ) );
      SystemCopy.LoadFromStream(S);
      //Save to file
      if not IsEncrypted then
        S.SaveToFile( SystemFilename)
      else
      begin
        Key := KeyUtils.GetKey128( 1 );
        WriteStreamToEncryptedFile( S, SystemFilename, Key );
      end;
   finally
      S.Free;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TSystemObj.DoAudit(APracticeDetails: pPractice_Details_Rec; AAuditType: TAuditType);
var
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditAction := aaNone;
  AuditInfo.AuditType := AAuditType;
  AuditInfo.AuditUser := Globals.CurrUser.Code;
  AuditInfo.AuditRecord := New_Practice_Details_Rec;
  try
    SetAuditInfo(@fdFields, APracticeDetails, AuditInfo);
    if (AuditInfo.AuditAction <> aaNone) then
      AuditTable.AddAuditRec(AuditInfo);
  finally
    Dispose(AuditInfo.AuditRecord);
  end;
end;

procedure TSystemObj.DownloadSave;
const
   ThisMethodName = 'TSystemObj.DownloadSave';
begin
  LogDebugMsg(ThisMethodName + ' Begins' );
  CopyFile(Pchar(SystemFileName),PChar(SystemDownloadBackupName),false);
  LogDebugMsg(ThisMethodName + ' Ends' );
end;



// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TSystemObj.OpenAndSnapshot( var aSnapshot: TObject; IsEncrypted: Boolean = True);
const
   ThisMethodName = 'TSystemObj.OpenAndSnapshot';
Var
   S : TIOStream;
   CRC : LongInt;
   Key : TKey128;
Begin
   S := TIOStream.Create;
   try
      if not IsEncrypted then
        S.LoadFromFile( SystemFilename)
      else
      begin
        S.Free;
        Key := KeyUtils.GetKey128( 1 );
        S := ReadStreamFromEncryptedFile( SystemFilename, Key );
        if not Assigned(S) then // maybe unencrypted
        begin
          S := TIOStream.Create;
          S.LoadFromFile( SystemFilename);
        end;
      end;
      CheckEmbeddedCRC( S);
      //reposition a front of stream and read off crc
      S.Position := 0;
      S.Read( CRC, Sizeof( LongInt ) );
      LoadFromStream( S );

      //now use the stream to populate a copy of the admin system
      if Assigned( aSnapshot) then
        FreeAndNil( aSnapshot);
      //reposition a front of stream and read off crc
      aSnapShot := TSystemObj.Create;
      S.Position := 0;
      S.Read( CRC, Sizeof( LongInt ) );
      TSystemObj(aSnapshot).LoadFromStream( S);

      UpdateCache;
   finally
      S.Free;
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TSystemObj.UpdateCache;
begin
  //updated cached admin fields
  GlobalCache.cache_Country := Self.fdFields.fdCountry;
end;


function TSystemObj.MoneyStr(const Amount: Money): string;
begin
    Result := MoneyUtils.MoneyStr( Amount, CurrencyCode );
end;

function TSystemObj.GetCurrencyCode: string;
begin
   if fCurrencyCode = '' then
      fCurrencyCode := whCurrencyCodes[ fdFields.fdCountry ];
   Result := fCurrencyCode;
end;

function TSystemObj.HasMultiCurrency: Boolean;
var i: Integer;
    pBankAccount: pSystem_Bank_Account_Rec;
    SysCur: string[3];
begin
  Result := true;
  SysCur := GetCurrencyCode;
  for i:= 0 to fdSystem_Bank_Account_List.ItemCount-1 do begin
    pBankAccount := fdSystem_Bank_Account_List.System_Bank_Account_At(i);
      if (pBankAccount.sbCurrency_Code <> SysCur)
      and (pBankAccount.sbCurrency_Code > '') then
         Exit;
         // Could check a bit more, i.e deleted of offsite
         // But eitherway it is no longer obvious that it is not relevant
  end;
  Result := False;
end;

function TSystemObj.HasCurrencyBankAccount(ISOCode: string; AddIfMissing: Boolean): Boolean;
var
  i, j: integer;
  pCF : pClient_File_Rec;
begin
  Result := False;
  for i := 0 to Pred(fdSystem_Client_File_List.ItemCount) do begin
    pCF := fdSystem_Client_File_List.Client_File_At(i);
    if Assigned(pCF) then begin
      for j := Low(pCF.cfISO_Codes) to High(pCF.cfISO_Codes) do begin
        if (pCF.cfISO_Codes[j] = ISOCode) then begin
          Result := True;
          Exit;
        end;
      end;
      //Still here - then mustn't be in the list
      if AddIfMissing then
        for j := Low(pCF.cfISO_Codes) to High(pCF.cfISO_Codes) do begin
          if (pCF.cfISO_Codes[j] = '') then begin
            pCF.cfISO_Codes[j] := ISOCode;
            Exit;
          end;
        end;
    end;
  end;
end;

procedure TSystemObj.ClearISOCodes(pCF : pClient_File_Rec);
var
  i: integer;
begin
  //Clear the array
  if Assigned(pCF) then
    for i := Low(pCF.cfISO_Codes) to High(pCF.cfISO_Codes) do
      pCF.cfISO_Codes[i] := '';
end;

procedure TSystemObj.AddAuditValues(AAuditRecord: TAudit_Trail_Rec; var Values: string);
var
  i: integer;
  PW: string;
  ARecord: Pointer;
  Token, idx: byte;
begin
  ARecord := AAuditRecord.atAudit_Record;
  if ARecord = nil then Exit;

  Idx := 0;
  Token := AAuditRecord.atChanged_Fields[idx];
  while Token <> 0 do begin
    case Token of
      //Name
      12: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 11),
                                       tPractice_Details_Rec(ARecord^).fdPractice_Name_for_Reports, Values);
      //Phone
      77: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 76),
                                       tPractice_Details_Rec(ARecord^).fdPractice_Phone, Values);
      //Email
      13: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 12),
                                   tPractice_Details_Rec(ARecord^).fdPractice_EMail_Address, Values);
      //Website
      76: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 75),
                                   tPractice_Details_Rec(ARecord^).fdPractice_Web_Site, Values);
      //Logo
      78: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 77),
                                   tPractice_Details_Rec(ARecord^).fdPractice_Logo_Filename, Values);
      //Secure Code
      31: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 30),
                                   tPractice_Details_Rec(ARecord^).fdBankLink_Code, Values);
      //Last Download Processed
      32: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 31),
                                   tPractice_Details_Rec(ARecord^).fdDisk_Sequence_No, Values);
      //Accounting system
      14: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 13),
                                   suNames[tPractice_Details_Rec(ARecord^).fdAccounting_System_Used], Values);
      //GST Names
      20: GST_Class_Names_Audit_Values(TGST_Class_Names_Array(tPractice_Details_Rec(ARecord^).fdGST_Class_Names), Values);
      //GST Rates
      23: GST_Rates_Audit_Values(TGST_Rates_Array(tPractice_Details_Rec(ARecord^).fdGST_Rates), Values);

      //***System Options

      //Bulk_Export_Enabled
      69: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 68),
                                   tPractice_Details_Rec(ARecord^).fdBulk_Export_Enabled, Values);
      //Bulk_Export_Code
      71: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 70),
                                   tPractice_Details_Rec(ARecord^).fdBulk_Export_Code, Values);
      //Updates_Pending
      150: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 149),
                                   tPractice_Details_Rec(ARecord^).fdUpdates_Pending, Values);
      //Update_Server_For_Offsites
      151: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 150),
                                   tPractice_Details_Rec(ARecord^).fdUpdate_Server_For_Offsites, Values);
      //Login_Bitmap_Filename
      126: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 125),
                                   tPractice_Details_Rec(ARecord^).fdLogin_Bitmap_Filename, Values);
      //Force_Login
      125: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 124),
                                   tPractice_Details_Rec(ARecord^).fdForce_Login, Values);
      //Auto_Print_Sched_Rep_Summary
      127: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 126),
                                   tPractice_Details_Rec(ARecord^).fdAuto_Print_Sched_Rep_Summary, Values);
      //Ignore_Quantity_In_Download
      128: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 127),
                                   tPractice_Details_Rec(ARecord^).fdIgnore_Quantity_In_Download, Values);
      //Replace_Narration_With_Payee
      147: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 146),
                                   tPractice_Details_Rec(ARecord^).fdReplace_Narration_With_Payee, Values);
      //Collect_Usage_Data
      152: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 151),
                                   tPractice_Details_Rec(ARecord^).fdCollect_Usage_Data, Values);
      //Auto_Retrieve_New_Transactions
      163: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 162),
                                   tPractice_Details_Rec(ARecord^).fdAuto_Retrieve_New_Transactions, Values);
      //Maximum_Narration_Extract
      140: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 139),
                                   tPractice_Details_Rec(ARecord^).fdMaximum_Narration_Extract, Values);
      //System_Report_Password
      160: begin
             for i := 1 to Length(tPractice_Details_Rec(ARecord^).fdSystem_Report_Password) do
               PW := PW + '*';
             SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 159),
                                     PW, Values);
           end;
      //Coding_Font
      164: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 163),
                                   tPractice_Details_Rec(ARecord^).fdCoding_Font, Values);
      //Copy_Dissection_Narration
      131: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 130),
                                   tPractice_Details_Rec(ARecord^).fdCopy_Dissection_Narration, Values);
      //Use_Xlon_Chart_Order
      133: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 132),
                                   tPractice_Details_Rec(ARecord^).fdUse_Xlon_Chart_Order, Values);

      //Extract_Multiple_Accounts_PA
      134: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 133),
                                   tPractice_Details_Rec(ARecord^).fdExtract_Multiple_Accounts_PA, Values);
      //Extract_Journal_Accounts_PA
      135: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 134),
                                   tPractice_Details_Rec(ARecord^).fdExtract_Journal_Accounts_PA, Values);
      //Extract_Quantity
      136: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 135),
                                   tPractice_Details_Rec(ARecord^).fdExtract_Quantity, Values);
      //Extract_Quantity_Decimal_Places
      158: SystemAuditMgr.AddAuditValue(SYAuditNames.GetAuditFieldName(tkBegin_Practice_Details, 157),
                                   tPractice_Details_Rec(ARecord^).fdExtract_Quantity_Decimal_Places, Values);

//   tkfdCountry                          = 15 ;
//   tkfdLoad_Client_Files_From           = 16 ;
//   tkfdSave_Client_Files_To             = 17 ;
//   tkfdShort_Name                       = 18 ;
//   tkfdLong_Name                        = 19 ;
//   tkfdGST_Class_Types                  = 21 ;
//   tkfdGST_Account_Codes                = 22 ;
//   tkfdGST_Applies_From                 = 24 ;
//   tkfdDate_of_Last_Entry_Received      = 25 ;
//   tkfdPrint_Reports_Up_To              = 26 ;
//   tkfdSpare_Boolean_3                  = 27 ;
//   tkfdPrint_Staff_Member_Header_Page   = 28 ;
//   tkfdPrint_Client_Header_Page         = 29 ;
//   tkfdPIN_Number                       = 30 ;
//   tkfdMagic_Number                     = 33 ;
//   tkfdCoding_Report_Style              = 34 ;
//   tkfdCoding_Report_Sort_Order         = 35 ;
//   tkfdCoding_Report_Entry_Selection    = 36 ;
//   tkfdCoding_Report_Blank_Lines        = 37 ;
//   tkfdCoding_Report_Rule_Line          = 38 ;
//   tkfdBank_Account_LRN_Counter         = 39 ;
//   tkfdUser_LRN_Counter                 = 40 ;
//   tkfdTransaction_LRN_Counter          = 41 ;
//   tkfdClient_File_LRN_Counter          = 42 ;
//   tkfdBankLink_Connect_Password        = 43 ;
//   tkfdOld_GST_Class_Codes              = 44 ;
//   tkfdAccount_Code_Mask                = 45 ;
//   tkfdFile_Version                     = 46 ;
//   tkfdSched_Rep_Email_Subject          = 47 ;
//   tkfdOld_Sched_Rep_Email_Line1        = 48 ;
//   tkfdOld_Sched_Rep_Email_Line2        = 49 ;
//   tkfdOLD_BAS_Special_Accounts         = 50 ;
//   tkfdGST_Class_Codes                  = 51 ;
//   tkfdBAS_Field_Number                 = 52 ;
//   tkfdBAS_Field_Source                 = 53 ;
//   tkfdBAS_Field_Account_Code           = 54 ;
//   tkfdBAS_Field_Balance                = 55 ;
//   tkfdSched_Rep_Include_Email          = 56 ;
//   tkfdSched_Rep_Email_Only             = 57 ;
//   tkfdSched_Rep_Include_Printer        = 58 ;
//   tkfdSched_Rep_Include_Fax            = 59 ;
//   tkfdSched_Rep_Send_Fax_Off_Peak      = 60 ;
//   tkfdEnhanced_Software_Options        = 61 ;
//   tkfdSched_Rep_Include_ECoding        = 62 ;
//   tkfdSched_Rep_Cover_Page_Name        = 63 ;
//   tkfdSched_Rep_Cover_Page_Subject     = 64 ;
//   tkfdSched_Rep_Cover_Page_Message     = 65 ;
//   tkfdSched_Rep_Email_Message          = 66 ;
//   tkfdDownload_Report_Options          = 67 ;
//   tkfdDownload_Report_Hide_Deleted     = 68 ;
//   tkfdSpare_Byte_0                     = 70 ;
//   tkfdSched_Rep_Include_CSV_Export     = 72 ;
//   tkfdTax_Interface_Used               = 73 ;
//   tkfdSave_Tax_Files_To                = 74 ;
//   tkfdLast_Disk_Image_Version          = 75 ;
//   tkfdSched_Rep_Print_Custom_Doc_GUID  = 79 ;
//   tkfdSched_Rep_Print_Custom_Doc       = 80 ;
//   tkfdLast_ChargeFile_Date             = 81 ;
//   tkfdAudit_Record_ID                  = 82 ;
//   tkfdSched_Rep_Fax_Custom_Doc_GUID    = 83 ;
//   tkfdSched_Rep_Fax_Custom_Doc         = 84 ;
//   tkfdSpare_Text_3                     = 85 ;
//   tkfdSched_Rep_Email_Custom_Doc_GUID  = 86 ;
//   tkfdSched_Rep_Email_Custom_Doc       = 87 ;
//   tkfdSpare_Text_5                     = 88 ;
//   tkfdSched_Rep_Books_Custom_Doc_GUID  = 89 ;
//   tkfdSched_Rep_Books_Custom_Doc       = 90 ;
//   tkfdSpare_Integer_3                  = 91 ;
//   tkfdSpare_Integer_4                  = 92 ;
//   tkfdSched_Rep_Notes_Custom_Doc_GUID  = 93 ;
//   tkfdSched_Rep_Notes_Custom_Doc       = 94 ;
//   tkfdSpare_Text_8                     = 95 ;
//   tkfdSched_Rep_WebNotes_Custom_Doc_GUID = 96 ;
//   tkfdSched_Rep_WebNotes_Custom_Doc    = 97 ;
//   tkfdSpare_Integer_5                  = 98 ;
//   tkfdSpare_Integer_6                  = 99 ;
//   tkfdSpare_Text_10                    = 100 ;
//   tkfdSpare_Byte_7                     = 101 ;
//   tkfdSpare_Text_11                    = 102 ;
//   tkfdSpare_Text_12                    = 103 ;
//   tkfdSpare_Byte_8                     = 104 ;
//   tkfdSpare_Text_13                    = 105 ;
//   tkfdSpare_Text_14                    = 106 ;
//   tkfdSpare_Byte_9                     = 107 ;
//   tkfdSpare_Integer_7                  = 108 ;
//   tkfdSpare_Integer_8                  = 109 ;
//   tkfdSched_Rep_WebNotes_Subject       = 110 ;
//   tkfdSpare_Byte_10                    = 111 ;
//   tkfdSched_Rep_webNotes_Message       = 112 ;
//   tkfdSpare_Byte_11                    = 113 ;
//   tkfdSched_Rep_Header_Message         = 114 ;
//   tkfdSched_Rep_BNotes_Subject         = 115 ;
//   tkfdSched_Rep_BNotes_Message         = 116 ;
//   tkfdSpare_Boolean_4                  = 117 ;
//   tkfdTask_Tracking_Prompt_Type        = 118 ;
//   tkfdSpare_Bool_1                     = 119 ;
//   tkfdSpare_Bool_2                     = 120 ;
//   tkfdSpare_Integer_9                  = 121 ;
//   tkfdSched_Rep_Fax_Transport          = 122 ;
//   tkfdSched_Rep_Include_WebX           = 123 ;
//   tkfdWeb_Export_Format                = 124 ;
//   tkfdSpare_Boolean_1                  = 129 ;
//   tkfdspare_Boolean_2                  = 130 ;
//   tkfdRound_Cashflow_Reports           = 132 ;
//   tkfdReports_New_Page                 = 137 ;
//   tkfdPrint_Merge_Report_Summary       = 138 ;
//   tkfdEmail_Merge_Report_Summary       = 139 ;
//   tkfdSched_Rep_Include_CheckOut       = 141 ;
//   tkfdSched_Rep_CheckOut_Subject       = 142 ;
//   tkfdSched_Rep_CheckOut_Message       = 143 ;
//   tkfdSched_Rep_Include_Business_Products = 144 ;
//   tkfdSched_Rep_Business_Products_Subject = 145 ;
//   tkfdSched_Rep_Business_Products_Message = 146 ;
//   tkfdLast_Export_Charges_Saved_To     = 148 ;
//   tkfdManual_Account_XML               = 149 ;
//   tkfdFixed_Charge_Increase            = 153 ;
//   tkfdPercentage_Charge_Increase       = 154 ;
//   tkfdFixed_Dollar_Amount              = 155 ;
//   tkfdDistributed_Dollar_Amount        = 156 ;
//   tkfdPercentage_Increase_Amount       = 157 ;
//   tkfdExport_Charges_Remarks           = 159 ;
//   tkfdPrint_Reports_From               = 161 ;
//   tkfdHighest_Date_Ever_Downloaded     = 162 ;
//   tkfdSort_Reports_Option              = 165 ;
//   tkfdSpare_Byte_12                    = 166 ;
//   tkfdGroup_LRN_Counter                = 167 ;
//   tkfdClient_Type_LRN_Counter          = 168 ;
//   tkfdTAX_Applies_From                 = 169 ;
//   tkfdTAX_Rates                        = 170 ;
//   tkfdSuperfund_System                 = 171 ;
//   tkfdSuperfund_Code_Mask              = 172 ;
//   tkfdLoad_Client_Super_Files_From     = 173 ;
//   tkfdSave_Client_Super_Files_To       = 174 ;
//   tkfdSort_Reports_By                  = 175 ;
//   tkfdSet_Fixed_Dollar_Amount          = 176 ;
//   tkfdPrint_Group_Header_Page          = 177 ;
//   tkfdPrint_Client_Type_Header_Page    = 178 ;
//   tkfdPractice_Management_System       = 179 ;
//   tkfdAutomatic_Task_Creation_Flags    = 180 ;
//   tkfdAutomatic_Task_Reminder_Delay    = 181 ;
//   tkfdAutomatic_Task_Closing_Flags     = 182 ;


    end;
    inc(Idx);
    Token := AAuditRecord.atChanged_Fields[idx];
  end;
end;

procedure TSystemObj.AddISOCode(pCF : pClient_File_Rec; ISOCode: string);
var
  i: integer;
begin
  //Add currency to AdminSystem list if it doesn't exist
  ForceCurrency(ISOCode, ct_User);

  //Add an ISO code to Client File Rec
  for i := Low(pCF.cfISO_Codes) to High(pCF.cfISO_Codes) do begin
    if (pCF.cfISO_Codes[i] = ISOCode) then
      Exit; //Already exists
    if (pCF.cfISO_Codes[i] = '') then begin
      pCF.cfISO_Codes[i] := ISOCode;
      Exit;
    end;
  end;
end;

procedure TSystemObj.AddISOCodes(pCF : pClient_File_Rec; ISOCodes: TStrings);
var
  i: integer;
begin
  ClearISOCodes(pCF);
  for i := 0 to ISOCodes.Count - 1 do
    AddISOCode(pCF, ISOCodes[i]);
end;

procedure TSystemObj.ForceCurrency(ISO: shortstring; CurType: Byte);
var c: Integer;
begin
   for C := low(fCurrencyList .ehISO_Codes) to high(fCurrencyList.ehISO_Codes) do
      if SameText(fCurrencyList.ehISO_Codes[C],ISO) then begin
         fCurrencyList.ehCur_Type[C] := CurType;
         Exit; // Im done..
      end else if fCurrencyList.ehISO_Codes[C] = '' then begin
         fCurrencyList.ehISO_Codes[C] := Uppercase(ISO);
         fCurrencyList.ehCur_Type[C] := CurType;
         Exit;
      end;
end;

procedure TSystemObj.SyncCurrenciesToSystemAccounts;
var
   I: Integer;
begin
   ForceCurrency(CurrencyCode,ct_Base);
   for I := fdSystem_Bank_Account_List.First to fdSystem_Bank_Account_List.Last do
      with fdSystem_Bank_Account_List.System_Bank_Account_At(I)^ do
         if sbCurrency_Code <> CurrencyCode then
            ForceCurrency(sbCurrency_Code,ct_System);
end;



function TSystemObj.NewSystemAccount(AccNumber: string; Delivered: Boolean):pSystem_Bank_Account_Rec;
begin
    Result := AdminSystem.fdSystem_Bank_Account_List.FindCode(AccNumber);//Savety net
    if Assigned(Result) then
       Exit; //Im done..
    Result := sySBio.New_System_Bank_Account_Rec;
    Result.sbAccount_Number := AccNumber;
    // Is fillchared to zero, so ..
    // Set some obvious defaults
    Result.sbCurrency_Code := whCurrencyCodes[fdFields.fdCountry];
    if Delivered then begin
       Result.sbCurrent_Balance := UNKNOWN;
       Result.sbNew_This_Month  := True;
       Result.sbAttach_Required := True;
       Result.sbBankLink_Code := fdFields.fdBankLink_Code;
    end else begin
       Result.sbAccount_Type := sbtOffsite;
    end;
    Inc(fdFields.fdBank_Account_LRN_Counter);
    Result.sbLRN := AdminSystem.fdFields.fdBank_Account_LRN_Counter;
    //insert new bank account in the list of accounts in the admin system
    fdSystem_Bank_Account_List.Insert(Result);
end;


function TSystemObj.NextAuditRecordID: integer;
begin
  Inc(FLastAuditRecordID);
  Result := FLastAuditRecordID;
end;

initialization
   DebugMe := DebugUnit(UnitName);
finalization
   FreeAndNil(_SystemCopy);
{$ENDIF}
end.

