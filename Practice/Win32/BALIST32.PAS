unit BaList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Bank Account List Object
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
   ECollect,Classes, bkDefs, ioStream, sysUtils, baObj32, AuditMgr;

type
  THasExchangeGainLossCodes = procedure(BankAccount: TBank_Account; var Continue: Boolean);

  TBank_Account_List = class(TExtdSortedCollection)
  protected
    procedure FreeItem(Item : Pointer); override;
  private
    fLoading: Boolean;
    fClient: TObject; // Owner
    fAuditMgr: TClientAuditManager; //Audit Manager
//    function FindRecordID(ARecordID: integer):  TBank_Account;
  public
    constructor Create( Owner : TObject; AAuditMgr: TClientAuditManager );
    function Compare(Item1,Item2 : Pointer): Integer; override;
    function FindRecordID(ARecordID: integer):  TBank_Account;
    procedure LoadFromFile(var S : TIOStream);
    procedure SaveToFile(var S: TIOStream);
    function Bank_Account_At(Index : longint) : TBank_Account;
    function FindCode(ACode: String): TBank_Account;
    function Get_Journal_Account( Journal_Type : Byte ): TBank_Account;
    function New_Journal_Account( Journal_Type : Byte ): TBank_Account;
    function FindAccountFromECodingUID( UID : integer) : TBank_Account;
    procedure Insert( Item : Pointer ); override;
    procedure UpdateCRC(var CRC : LongWord);
    procedure DoAudit(ABankAccountListCopy: TBank_Account_List;
                      AParentID: integer; var AAuditTable: TAuditTable);
    procedure SetAuditInfo(P1, P2: pBank_Account_Rec; AParentID: integer;
                           var AAuditInfo: TAuditInfo);
                           
    function IsExchangeGainLossCode(const Code: String): Boolean;
 end;

//******************************************************************************
implementation
uses
   clObj32,
   LogUtil,
   tokens,
   bkbaio,
   bkconst,
   bkdbExcept,
   bk5Except,
   CountryUtils,
   BKAUDIT;

const
   UnitName = 'BALIST32';
var
   DebugMe : Boolean = false;

function TBank_Account_List.Compare(Item1,Item2:Pointer):integer;
begin
   result := CompareStr(TBank_Account(Item1).baFields.baBank_Account_Number,TBank_Account(Item2).baFields.baBank_Account_Number);
end;

constructor TBank_Account_List.Create(Owner: TObject; AAuditMgr: TClientAuditManager);
const
  ThisMethodName = 'TBank_Account_List.Create';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  inherited Create;
  Duplicates := false;
  fClient := Owner;
  fAuditMgr := AAuditMgr;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure TBank_Account_List.DoAudit(ABankAccountListCopy: TBank_Account_List;
  AParentID: integer;  var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pBank_Account_Rec;
  AuditInfo: TAuditInfo;
  BankAccount: TBank_Account;
  B1, B2: TBank_Account;
begin
  //  AuditInfo.AuditType := - depends on bank account type
  AuditInfo.AuditUser := FAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Bank_Account;
  //Adds, changes
  for i := 0 to Pred(ItemCount) do begin
    P1 := @TBank_Account(Items[i]).baFields;
    AuditInfo.AuditType := FAuditMgr.GetBankAccountAuditType(P1^.baAccount_Type);
    P2 := nil;
    BankAccount := nil;
    if Assigned(ABankAccountListCopy) then //Sub list - may not be assigned
      BankAccount := ABankAccountListCopy.FindRecordID(P1.baAudit_Record_ID);
    if Assigned(BankAccount) then
      P2 := @BankAccount.baFields;
    AuditInfo.AuditRecord := New_Bank_Account_Rec;
    try
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
  //Deletes
  if Assigned(ABankAccountListCopy) then begin //Sub list - may not be assigned
    for i := 0 to ABankAccountListCopy.ItemCount - 1 do begin
      P2 := @TBank_Account(ABankAccountListCopy.Items[i]).baFields;
      AuditInfo.AuditType := FAuditMgr.GetBankAccountAuditType(P2^.baAccount_Type);      
      BankAccount := FindRecordID(P2.baAudit_Record_ID);
      P1 := nil;
      if Assigned(BankAccount) then
        P1 := @BankAccount.baFields;
      AuditInfo.AuditRecord := New_Bank_Account_Rec;
      try
        SetAuditInfo(P1, P2, AParentID, AuditInfo);
        if (AuditInfo.AuditAction = aaDelete) then
          AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
    end;
  end;

  //Audit bank account child lists
  for i := 0 to Pred(itemCount) do begin
    B1 := Items[i];
    B2 := nil;
    if Assigned(ABankAccountListCopy) then
      B2 := ABankAccountListCopy.FindRecordID(B1.baFields.baAudit_Record_ID);
    if Assigned(B1) then
      B1.DoAudit(B2, AAuditTable)
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account_List.FreeItem(Item : Pointer);
const
  ThisMethodName = 'TBank_Account_List.FreeItem';
var
  p : TBank_Account;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   p := TBank_Account(Item);
   p.Free;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account_List.Bank_Account_At(Index : longInt) : TBank_Account;
const
  ThisMethodName = 'TBank_Account_List.Bank_Account_At';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := TBank_Account(At(Index));
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account_List.FindCode(ACode: String): TBank_Account;
const
  ThisMethodName = 'TBank_Account_List.FindCode';
var
  L, H, I, C: Integer;
  p  : TBank_Account;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName,aCode]));
  Result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : No items',[ThisMethodName]));
     exit;      {no items in list}
  end;

  repeat
    I := (L + H) shr 1;
    p := Bank_Account_At(i);
    C := CompareStr(ACode, p.baFields.baBank_Account_Number);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     Result := p;
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
     exit;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not found',[ThisMethodName]));
end;

function TBank_Account_List.FindRecordID(ARecordID: integer): TBank_Account;
var
  i : integer;
begin
  Result := nil;
  if (ItemCount = 0) then Exit;

  for i := 0 to Pred(ItemCount) do
    if Bank_Account_At(i).baFields.baAudit_Record_ID = ARecordID then begin
      Result := Bank_Account_At(i);
      Exit;
    end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account_List.LoadFromFile(var s : TIOStream);
const
  ThisMethodName = 'TBank_Account_List.LoadFromFile';
Var
   Token    : Byte;
   P        : TBank_Account;
   msg      : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   fLoading := True;
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Bank_Account :
            Begin
               P := TBank_Account.Create(fClient);
               If not Assigned( P ) then
               Begin
                  Msg := Format( '%s : Unable to allocate P',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
//               P.baClient := fClient;
               P.baTransaction_List.TxnClient := fClient;
               P.baTransaction_List.TxnBankAccount := P;
               P.LoadFromFile( S );
               Insert( P );
            end;
         else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            LogUtil.LogMsg(lmError, UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
   fLoading := False;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account_List.SaveToFile(var s :TIOStream);
const
  ThisMethodName = 'TBank_Account_List.SaveToFile';
Var
   i  : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   S.WriteToken( tkBeginBankAccountList );
   For i := 0 to Pred( ItemCount ) do Bank_Account_At( i ).SaveToFile( S );
   S.WriteToken( tkEndSection );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : %d bank accounts saved',[ThisMethodName,itemCount]));
end;

procedure TBank_Account_List.SetAuditInfo(P1, P2: pBank_Account_Rec;
  AParentID: integer; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := AParentID;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Client Bank Account']);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.baAudit_Record_ID;
    AAuditInfo.AuditOtherInfo :=
      AAuditInfo.AuditOtherInfo + VALUES_DELIMITER +
      Format('%s=%s',[BKAuditNames.GetAuditFieldName(tkBegin_Bank_Account, 152), P2.baBank_Account_Number]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.baAudit_Record_ID;
    if Bank_Account_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.baAudit_Record_ID;
    P1.baAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKBAIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Bank_Account_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account_List.Get_Journal_Account(Journal_Type: Byte): TBank_Account;
const
  ThisMethodName = 'TBank_Account_List.Get_Journal_Account';
Var
   i : LongInt;
   B : TBank_Account;
   Msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, Journal_Type]));

   Result := nil;
   If not ( Journal_Type in [ btBank+1..btMax ] ) then
   Begin
      Msg := Format( '%s : Journal Type out of Range %d ', [ ThisMethodName, Journal_Type] );
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
   end;

   For i := 0 to Pred( itemCount ) do
   Begin
      B := Bank_Account_At( i );
      With B.baFields do
      Begin
         If ( baAccount_Type = Journal_Type ) then
         Begin
           Result := B;
           if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
           exit;
         end;
      end;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;

procedure TBank_Account_List.Insert(Item: Pointer);
const
  ThisMethodName = 'TBank_Account_List.Insert';
Var
  B : TBank_Account;
  Msg : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  B := TBank_Account( Item );
//  B.baClient := fClient;
  B.baTransaction_List.AuditMgr := fAuditMgr;
  B.baTransaction_List.TxnClient := fClient;
  B.baTransaction_List.TxnBankAccount := B;

  if not fLoading then
  Begin
    if B.baFields.baCurrency_Code = '' then
    Begin
      Msg := Format( '%s : Currency Code is required', [ ThisMethodName ] );
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
    End;
    //FAuditMgr is not assigned for ResyncClient temporary bank account list
    if Assigned(FAuditMgr) then begin
      //Some manual bank accounts are re-inserted after the account number has
      //been edited to keep the correct order.
      if (not B.IsManual) or (B.baFields.baAudit_Record_ID = 0) then
        //Get next audit ID for new bank accounts
        B.baFields.baAudit_Record_ID := FAuditMgr.NextAuditRecordID;
    end;
  End;

  inherited Insert( Item );
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TBank_Account_List.IsExchangeGainLossCode(const Code: String): Boolean;
var
  Index: Integer;
begin
  Result := False;
  
  for Index := 0 to ItemCount - 1 do
  begin
    if (Bank_Account_At(Index).baFields.baExchange_Gain_Loss_Code = Code) then
    begin
      Result := True;

      Break;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account_List.New_Journal_Account(Journal_Type: Byte): TBank_Account;
const
  ThisMethodName = 'TBank_Account_List.New_Journal_Account';
var
   msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   If not ( Journal_Type in [ btBank+1..btMax ] ) then
   Begin
      Msg := Format( '%s : Journal Type out of Range %d ', [ ThisMethodName, Journal_Type] );
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
   end;

   If Get_Journal_Account( Journal_Type )<>NIL then
   Begin
      Msg := Format( '%s : Account Type already exists %d ', [ ThisMethodName, Journal_Type] );
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
   end;

   Result := TBank_Account.Create(fClient);
   With Result.baFields do
   Begin

      baCurrent_Balance  := 0;
      baAccount_Type := Journal_Type;
      baDesktop_Super_Ledger_ID := -1;

      if Journal_Type = btStockJournals  then
         baBank_Account_Number :=  'Stock/Adjustment Jnl' //Name is too long as a number
      else
         baBank_Account_Number := Localise(TClientOBJ(fClient).clFields.clCountry,
                                           btNames[Journal_Type]);

       baBank_Account_Name  :=  Localise(TClientOBJ(fClient).clFields.clCountry,
                                         btNames[Journal_Type]);
       baCurrency_Code := TClientOBJ(fClient).clExtra.ceLocal_Currency_Code;
   end;
   Insert(Result);


   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account_List.UpdateCRC(var CRC: LongWord);
var
   B: TBank_Account;
   I: Integer;
begin
   for i := 0 to Pred( ItemCount ) do begin
      B := Bank_Account_At( i );
      B.UpdateCRC( CRC );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TBank_Account_List.FindAccountFromECodingUID(
  UID: integer): TBank_Account;
var
  i : integer;
  ba : TBank_Account;
begin
  result := nil;
  for i := Self.First to Self.Last do
  begin
    ba := Bank_Account_At(i);
    if ba.baFields.baECoding_Account_UID = UID then
    begin
      result := ba;
      exit;
    end;
  end;
end;

initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
