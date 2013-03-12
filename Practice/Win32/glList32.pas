unit glList32;

interface

uses
  eCollect, BKDEFS, BKglIO, glObj32, IOSTREAM, Math, SysUtils, TOKENS, LogUtil,
  BKDbExcept,
  StDate,
  bkDateUtils,
  MoneyDef,
  AuditMgr,
  bkConst;

type
  { ----------------------------------------------------------------------------
    TExchange_Gain_Loss_List
  ---------------------------------------------------------------------------- }
  TExchange_Gain_Loss_List = class;

  TExchangeGainLossEntryList = array of TExchange_Gain_Loss;

  TExchange_Gain_Loss_List = class(TExtdSortedCollection)
  private
    fAuditMgr: TClientAuditManager;

  public
    constructor Create(const aAuditMgr: TClientAuditManager);

  protected
    procedure FreeItem(Item: Pointer); override;
    function  FindRecordID(const aRecordID: integer): TExchange_Gain_Loss;

  public
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure SaveToFile(var S: TIOStream);
    procedure LoadFromFile(var S: TIOStream);

    function  Exchange_Gain_Loss_At(Index: integer): TExchange_Gain_Loss;

    { Date is normally the last day of the month
      When an existing entry is found it will be re-used, otherwise a new entry
      will be created.
      The Account Code is stored because it may change at any time.
      Posted Date in the entry will be set to CurrentDate.
    }
    procedure PostEntry(const aDate: TStDate; const aAmount: Money;
                const aAccount: string);

    { Date is normally the last day of the month
      When found the corresponding item will be returned, otherwise the return
      value will be nil.
    }
    function  GetPostedEntry(const aDate: TStDate): TExchange_Gain_Loss;

    function  HasEntryIn(const aMonth: TStDate): boolean;

    function GetEntriesPostedBetween(FromDate, ToDate: TStDate): TExchangeGainLossEntryList;

    // Auditing
    procedure Insert(Item: Pointer); override;
    procedure DoAudit(AGainLossListCopy: TExchange_Gain_Loss_List;
                      AParentID: integer;
                      var AAuditTable: TAuditTable);
    procedure SetAuditInfo(aP1, aP2: TExchange_Gain_Loss; AParentID: integer;
                           var AAuditInfo: TAuditInfo);
    // Item can be nil
    function  GetAs_pRec(Item: TExchange_Gain_Loss): pExchange_Gain_Loss_Rec;
  end;


implementation

const
   UnitName = 'glList32';
   DebugMe: boolean = false;

{ ------------------------------------------------------------------------------
  TExchange_Gain_Loss_List
------------------------------------------------------------------------------ }
constructor TExchange_Gain_Loss_List.Create(const aAuditMgr: TClientAuditManager);
begin
  fAuditMgr := aAuditMgr;

  inherited Create;

  Duplicates := false;
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.Compare(Item1, Item2: Pointer): integer;
var
  Exchange1: TExchange_Gain_Loss;
  Exchange2: TExchange_Gain_Loss;
begin
  Exchange1 := TExchange_Gain_Loss(Item1);
  ASSERT(Assigned(Exchange1));
  Exchange2 := TExchange_Gain_Loss(Item2);
  ASSERT(Assigned(Exchange2));

  result := CompareValue(Exchange1.glFields.glDate, Exchange2.glFields.glDate);
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.FreeItem(Item: Pointer);
var
  P: TExchange_Gain_Loss;
begin
  P := TExchange_Gain_Loss(Item);
  if Assigned(P) then
    P.Free;
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.FindRecordID(const aRecordID: integer
  ): TExchange_Gain_Loss;
var
  i: integer;
begin
  for i := 0 to ItemCount-1 do
  begin
    result := Exchange_Gain_Loss_At(i);

    // Found?
    if (result.glFields.glAudit_Record_ID = aRecordID) then
      exit;
  end;

  result := nil;
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TExchange_Gain_Loss_List.SaveToFile';
var
  i: integer;
  Item: TExchange_Gain_Loss;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  S.WriteToken(tkBeginExchange_Gain_Loss_List);

  for i := 0 to Pred(ItemCount) do
  begin
    Item := Exchange_Gain_Loss_At(i);
    ASSERT(Assigned(Item));
    Item.SaveToFile(S);
  end;

  S.WriteToken(tkEndSection);

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TExchange_Gain_Loss_List.LoadFromFile';
var
  Token: Byte;
  Msg: string;
  P: TExchange_Gain_Loss;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  Token := S.ReadToken;
  While (Token <> tkEndSection) do
  begin
    // Should never happen
    if (Token <> tkBegin_Exchange_Gain_Loss) then
    begin
      Msg := Format('%s : Unknown Token %d', [ThisMethodName, Token]);
      LogUtil.LogMsg(lmError,UnitName, Msg);
      raise ETokenException.CreateFmt('%s - %s', [UnitName, Msg]);
    end;

    // Create, Load and then Insert
    P := TExchange_Gain_Loss.Create;
    try
      P.LoadFromFile(S);
      Insert(P);
    except
      on E: Exception do
      begin
        FreeAndNil(P);
        raise;
      end;
    end;

    Token := S.ReadToken;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends');
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.Exchange_Gain_Loss_At(Index: integer
  ): TExchange_Gain_Loss;
var
  P: Pointer;
Begin
  P := At(Index);

  result := TExchange_Gain_Loss(P);
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.PostEntry(const aDate: TStDate;
  const aAmount: Money; const aAccount: string);
var
  Item: TExchange_Gain_Loss;
begin
  Item := GetPostedEntry(aDate);

  // Need to create new item?
  if not Assigned(Item) then
  begin
    Item := TExchange_Gain_Loss.Create;
    Insert(Item);
  end;
  ASSERT(assigned(Item));

  // Increase the ID (only from here, not Insert)
  if Assigned(fAuditMgr) then
    Item.glFields.glAudit_Record_ID := fAuditMgr.NextAuditRecordID;

  // Set fields
  with Item.glFields do
  begin
    glDate := aDate;
    glAmount := aAmount;
    glAccount := aAccount;
    glPosted_Date := CurrentDate;
  end;
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.GetEntriesPostedBetween(FromDate, ToDate: TStDate): TExchangeGainLossEntryList;
var
  Index: Integer;
  Entry: TExchange_Gain_Loss;
  Count: Integer;
begin
  SetLength(Result, 0);

  Count := 0;
  
  for Index := 0 to ItemCount - 1 do
  begin
    Entry := Exchange_Gain_Loss_At(Index);

    if (Entry.glFields.glDate >= FromDate) and (Entry.glFields.glDate <= ToDate) then
    begin
      SetLength(Result, Count + 1);

      Result[Count] := Entry;

      Inc(Count);
    end;
  end;
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.GetPostedEntry(const aDate: TStDate
  ): TExchange_Gain_Loss;
var
  i: integer;
begin
  for i := 0 to ItemCount-1 do
  begin
    result := Exchange_Gain_Loss_At(i);
    ASSERT(Assigned(result));

    // Found?
    if (result.glFields.glDate = aDate) then
      exit;
  end;

  result := nil;
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.HasEntryIn(const aMonth: TStDate): boolean;
var
  dtLastDay: TStDate;
  Entry: TExchange_Gain_Loss;
begin
  dtLastDay := GetLastDayOfMonth(aMonth);
  Entry := GetPostedEntry(dtLastDay);
  result := assigned(Entry);
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.Insert(Item: Pointer);
begin
  // Note: do not change the Audit Record ID from here

  inherited Insert(Item);
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.DoAudit(
  AGainLossListCopy: TExchange_Gain_Loss_List; AParentID: integer;
  var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: TExchange_Gain_Loss;
  AuditInfo: TAuditInfo;
begin
  AuditInfo.AuditType := arExchangeGainLoss;
  AuditInfo.AuditUser := fAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Exchange_Gain_Loss;

  //Adds, changes
  for I := 0 to Pred(ItemCount) do
  begin
    P1 := Items[i];
    P2 := AGainLossListCopy.FindRecordID(P1.glFields.glAudit_Record_ID);
    AuditInfo.AuditRecord := New_Exchange_Gain_Loss_Rec;
    try
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then
        AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
  end;

  //Deletes
  if Assigned(AGainLossListCopy) then
  begin
    for i := 0 to AGainLossListCopy.ItemCount - 1 do
    begin
      P2 := AGainLossListCopy.Items[i];
      P1 := FindRecordID(P2.glFields.glAudit_Record_ID);
      AuditInfo.AuditRecord := New_Exchange_Gain_Loss_Rec;
      try
        SetAuditInfo(P1, P2, AParentID, AuditInfo);
        if (AuditInfo.AuditAction = aaDelete) then
          AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
    end;
  end;
end;

{------------------------------------------------------------------------------}
procedure TExchange_Gain_Loss_List.SetAuditInfo(aP1, aP2: TExchange_Gain_Loss;
  AParentID: integer; var AAuditInfo: TAuditInfo);
var
  P1, P2: pExchange_Gain_Loss_Rec;
begin
  P1 := GetAs_pRec(aP1);
  P2 := GetAs_pRec(aP2);

  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditOtherInfo :=
    Format('%s=%s', ['Record Type', 'Exchange Gain/Loss']) +
    VALUES_DELIMITER +
    Format('%s=%d', ['ParentID', AParentID]);
  AAuditInfo.AuditParentID := AParentID;

  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.glAudit_Record_ID;
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.glAudit_Record_ID;
    if Exchange_Gain_Loss_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.glAudit_Record_ID;
    P1.glAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKGLIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Exchange_Gain_Loss_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

{------------------------------------------------------------------------------}
function TExchange_Gain_Loss_List.GetAs_pRec(Item: TExchange_Gain_Loss
  ): pExchange_Gain_Loss_Rec;
begin
  if Assigned(Item) then
    result := Item.As_pRec
  else
    result := nil;
end;

{------------------------------------------------------------------------------}
initialization
  DebugMe := DebugUnit(UnitName);


end.
