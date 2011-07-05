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
  usrList32, cflist32, sysDList32, sbaList32, acList32, amList32, peList32,
  grplist32, ctypelist32, ExchangeRateList, mcDefs, AuditMgr,
  SystemMemorisationList,
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
      fCurrencyList              : TExchange_Rates_Header_Rec;
      fAuditTable                : TAuditTable;
      fSystem_Memorisation_List  : TSystem_Memorisation_List;
      fSystem_Provisional_List   : TSystem_Provisional_Entries_Log;
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
      procedure SystemCopyReload(var S: TIOStream);
{$ENDIF}
{$IFDEF BK_UNITTESTINGON}
      procedure SetSystemFileName(const Value: string);
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
      property AuditTable: TAuditTable read FAuditTable;
      property SystemMemorisationList: TSystem_Memorisation_List read FSystem_Memorisation_List;
{$ENDIF}
{$IFDEF BK_UNITTESTINGON}
      property TestSystemFileName: string read SystemFileName write SetSystemFileName;
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
{$IFDEF ParserDll}
  systemBackupName := '';
  systemDownloadBackupName := '';
{$ELSE}
  if fdFields.fdAudit_Record_ID = 0 then
    fdFields.fdAudit_Record_ID := NextAuditRecordID;
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
  fAuditTable                := TAuditTable.Create(SystemAuditMgr);
  fSystem_Memorisation_List  := TSystem_Memorisation_List.Create;
  fSystem_Provisional_List   := TSystem_Provisional_Entries_Log.Create;
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
  FreeAndNil(fSystem_Provisional_List);
  FreeAndNil(fdSystem_Bank_Account_List);
  FreeAndNil(fdSystem_Disk_Log);
  FreeAndNil(fdSystem_Client_File_List);
  FreeAndNil(fdSystem_User_List);
  FreeAndNil(fdSystem_File_Access_List);
  FreeAndNil(fdSystem_Client_Account_Map);
  FreeAndNil(fdSystem_Group_List);
  FreeAndNil(fdSystem_Client_Type_List);
  FreeAndNil(fAuditTable);
  FreeAndNil(fSystem_Memorisation_List);
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
         tkBeginSystem_Memorisation_List : fSystem_Memorisation_List.LoadFromStream(S);
         tkBeginSystem_Provisional_Entries_Log : fSystem_Provisional_List.LoadFromFile(S);
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
{$IFDEF ParserDll}
{$ELSE}
      SystemCopyReload(S);
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
   fSystem_Memorisation_List.SaveToStream( S );
   fAuditTable.SaveToStream( S );
   fSystem_Provisional_List.SaveToFile( S );

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

{$IFDEF BK_UNITTESTINGON}
procedure TSystemObj.SetSystemFileName(const Value: string);
begin
  SystemFileName := Value;
end;
{$ENDIF}

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
      //Restricted auditing to UK
      if (fdFields.fdCountry = whUK) then
        SystemAuditMgr.DoAudit;
      //Save
      L := 0;
      S.Write( L, Sizeof( LongInt ) ); { Leave space for the CRC }
      SaveToStream( S );
      EmbedCRC( S);
      SystemCopyReload(S);
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
  AuditInfo.AuditUser := SystemAuditMgr.CurrentUserCode;
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

procedure TSystemObj.SystemCopyReload(var S: TIOStream);
begin
  //Restricted auditing to UK
  if (fdFields.fdCountry <> whUK) then Exit;

  FreeAndNil(_SystemCopy); //Delete current copy
  S.Seek(SizeOf(LongInt), soFromBeginning);
  SystemCopy.LoadFromStream(S);
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

