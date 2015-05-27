unit trxList32;
//------------------------------------------------------------------------------
// Transaction List Object
//------------------------------------------------------------------------------

interface

uses
  classes,
  bkdefs,
  ecollect,
  iostream,
  AuditMgr;

type
  //----------------------------------------------------------------------------
  pTran_Suggested_Index_Rec = ^TTran_Suggested_Index_Rec;
  TTran_Suggested_Index_Rec = Packed Record
    tiType                : Byte;
    tiCoded_By            : Byte;
    tiSuggested_Mem_State : Byte;
    tiDate_Effective      : integer;
    tiTran_Seq_No         : integer;
    tiAccount             : String[ 20 ];
    tiStatement_Details   : AnsiString;
  end;

const
  Tran_Suggested_Index_Rec_Size = Sizeof(TTran_Suggested_Index_Rec);

type
  //----------------------------------------------------------------------------
  TTran_Suggested_Index = class(TExtdSortedCollection)
  private
    fSortForSave : boolean;
  protected
    function NewItem() : Pointer;
    procedure FreeItem(Item: Pointer); override;
  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure FreeTheItem(Item: Pointer);

    property SortForSave : boolean read fSortForSave write fSortForSave;
  end;

  //----------------------------------------------------------------------------
  TTransaction_List = class(TExtdSortedCollection)
  private
    FLastSeq      : integer;
    FClient       : TObject;
    FBank_Account : TObject;
    FAuditMgr     : TClientAuditManager;
    FLoading      : boolean;

    fTran_Suggested_Index : TTran_Suggested_Index;

    function FindRecordID(ARecordID: integer):  pTransaction_Rec;
    function FindDissectionRecordID(ATransaction: pTransaction_Rec;
                                    ARecordID: integer): pDissection_Rec;
    procedure SetClient(const Value: TObject);
    procedure SetBank_Account(const Value: TObject);
    procedure SetAuditMgr(const Value: TClientAuditManager);
  protected
    procedure FreeItem(Item : Pointer); override;
  public
    constructor Create( AClient, ABank_Account: TObject; AAuditMgr: TClientAuditManager ); reintroduce; overload; virtual;
    destructor Destroy; override;
    function Compare(Item1,Item2 : Pointer): Integer; override;
    procedure Insert(Item:Pointer); override;
    procedure Insert_Transaction_Rec(var p: pTransaction_Rec; NewAuditID: Boolean = True);

    procedure LoadFromFile(var S : TIOStream);
    procedure SaveToFile(var S: TIOStream);
    function Transaction_At(Index : longint) : pTransaction_Rec;
    function GetTransCoreID_At(Index : longint) : int64;
    function FindTransactionFromECodingUID( UID : integer) : pTransaction_Rec;
    function FindTransactionFromMatchId(UID: integer): pTransaction_Rec;
    function SearchUsingDateandTranSeqNo(aDate_Effective, aTranSeqNo : integer; var aIndex: integer): Boolean;
    function SearchUsingTypeDateandTranSeqNo(aType : Byte; aDate_Effective, aTranSeqNo : integer; var aIndex: integer): Boolean;
    function New_Transaction : pTransaction_Rec;

    // Effective date
    // Note: returns 0 zero or first/last date of Effective Date
    function FirstEffectiveDate : LongInt;
    function LastEffectiveDate : LongInt;

    // Presented date
    function FirstPresDate : LongInt;
    function LastPresDate : LongInt;

    procedure UpdateCRC(var CRC : Longword);
    procedure DoAudit(ATransactionListCopy: TTransaction_List; AParentID: integer;
                      AAccountType: byte; var AAuditTable: TAuditTable);
    procedure DoDissectionAudit(ATransaction, ATransactionCopy: pTransaction_Rec;
                                AAccountType: byte;
                                var AAuditTable: TAuditTable);
    procedure SetAuditInfo(P1, P2: pTransaction_Rec; AParentID: integer;
                           var AAuditInfo: TAuditInfo);
    procedure SetDissectionAuditInfo(P1, P2: pDissection_Rec; AParentID: integer;
                                     var AAuditInfo: TAuditInfo);
    function GetIndexPRec(aIndex: integer): pTran_Suggested_Index_Rec;

    property LastSeq : integer read FLastSeq;
    property TxnClient: TObject read FClient write SetClient;
    property TxnBankAccount: TObject read FBank_Account write SetBank_Account;
    property AuditMgr: TClientAuditManager read FAuditMgr write SetAuditMgr;

    property Tran_Suggested_Index : TTran_Suggested_Index read fTran_Suggested_Index;
  end;

  procedure Dispose_Transaction_Rec(p: pTransaction_Rec);
  procedure Dump_Dissections(var p : pTransaction_Rec; AAuditIDList: TList = nil);
  procedure AppendDissection( T : pTransaction_Rec; D : pDissection_Rec;
                             AClientAuditManager: TClientAuditManager = nil );

//------------------------------------------------------------------------------
implementation

uses
  Math,
  TransactionUtils,
  bktxio,
  bkdsio,
  tokens,
  LogUtil,
  malloc,
  SysUtils,
  bkdbExcept,
  bk5Except,
  bkcrc,
  bkconst,
  BKAudit,
  GenUtils,
  bkDateUtils,
  baObj32,
  SuggestedMems,
  BKUTIL32;

const
  DebugMe : boolean = false;
  UnitName = 'TRXLIST32';
  SInsufficientMemory = UnitName + ' Error: Out of memory in TTran_Suggested_Index.NewItem';

{ TTran_Suggested_Index }
//------------------------------------------------------------------------------
function TTran_Suggested_Index.NewItem: Pointer;
var
  P : pTran_Suggested_Index_Rec;
Begin
  SafeGetMem( P, Tran_Suggested_Index_Rec_Size );

  If Assigned( P ) then
    FillChar( P^, Tran_Suggested_Index_Rec_Size, 0 )
  else
    Raise EInsufficientMemory.Create( SInsufficientMemory );

  Result := P;
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Index.FreeItem(Item: Pointer);
begin
  pTran_Suggested_Index_Rec(Item)^.tiAccount := '';
  pTran_Suggested_Index_Rec(Item)^.tiStatement_Details := '';

  SafeFreeMem(Item, Tran_Suggested_Index_Rec_Size);
end;

//------------------------------------------------------------------------------
procedure TTran_Suggested_Index.FreeTheItem(Item: Pointer);
begin
  DelFreeItem(Item);
end;

//------------------------------------------------------------------------------
constructor TTran_Suggested_Index.Create;
begin
  inherited;

  SortForSave := false;
  Duplicates := false;
end;

//------------------------------------------------------------------------------
function TTran_Suggested_Index.Compare(Item1, Item2: Pointer): integer;
begin
  if fSortForSave then
  begin
    if pTran_Suggested_Index_Rec(Item1)^.tiDate_Effective < pTran_Suggested_Index_Rec(Item2)^.tiDate_Effective then result := -1 else
    if pTran_Suggested_Index_Rec(Item1)^.tiDate_Effective > pTran_Suggested_Index_Rec(Item2)^.tiDate_Effective then result := 1 else
    if pTran_Suggested_Index_Rec(Item1)^.tiTran_Seq_No    < pTran_Suggested_Index_Rec(Item2)^.tiTran_Seq_No then result := -1 else
    if pTran_Suggested_Index_Rec(Item1)^.tiTran_Seq_No    > pTran_Suggested_Index_Rec(Item2)^.tiTran_Seq_No then result := 1 else
    result := 0;
  end
  else
  begin
    Result := CompareValue(pTran_Suggested_Index_Rec(Item1)^.tiType,
                           pTran_Suggested_Index_Rec(Item2)^.tiType);

    if Result <> 0 then
      Exit;

    Result := CompareValue(pTran_Suggested_Index_Rec(Item1)^.tiDate_Effective,
                           pTran_Suggested_Index_Rec(Item2)^.tiDate_Effective);

    if Result <> 0 then
      Exit;

    Result := CompareValue(pTran_Suggested_Index_Rec(Item1)^.tiTran_Seq_No,
                           pTran_Suggested_Index_Rec(Item2)^.tiTran_Seq_No);
  end;
end;

{ TTransaction_List }
//------------------------------------------------------------------------------
procedure Dispose_Dissection_Rec(p : PDissection_Rec);
const
  ThisMethodName = 'Dispose_Dissection_Rec';
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if (BKDSIO.IsADissection_Rec( P ) )  then
  begin
    BKDSIO.Free_Dissection_Rec_Dynamic_Fields( p^);
    MALLOC.SafeFreeMem( P, Dissection_Rec_Size );
  end;

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------
procedure Dispose_Transaction_Rec(p: pTransaction_Rec);
const
  ThisMethodName = 'Dispose_Transaction_Rec';
Var
   This : pDissection_Rec;
   Next : pDissection_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if ( BKTXIO.IsATransaction_Rec( P ) )  then With P^ do
   Begin
      This := pDissection_Rec( txFirst_Dissection );
      While ( This<>NIL ) do
      Begin
         Next := pDissection_Rec( This^.dsNext );
         Dispose_Dissection_Rec( This );
         This := Next;
      end;

      BKTXIO.Free_Transaction_Rec_Dynamic_Fields( P^);
      MALLOC.SafeFreeMem( P, Transaction_Rec_Size );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------
procedure Dump_Dissections(var p : pTransaction_Rec; AAuditIDList: TList = nil);
const
  ThisMethodName = 'Dump_Dissections';
Var
   This : pDissection_Rec;
   Next : pDissection_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if ( BKTXIO.IsATransaction_Rec( P ) )  then With P^ do
   Begin
      This := pDissection_Rec( txFirst_Dissection );
      While ( This<>NIL ) do
      Begin
         Next := pDissection_Rec( This^.dsNext );

         //Save audit ID's for reuse when dissections are edited
         if Assigned(AAuditIDList) then
            AAuditIDList.Add(Pointer(This^.dsAudit_Record_ID));

         Dispose_Dissection_Rec( This );
         This := Next;
      end;
      P^.txFirst_Dissection := NIL;
      P^.txLast_Dissection := NIL;
      P^.txAccount := '';
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------

Procedure AppendDissection( T : pTransaction_Rec; D : pDissection_Rec;
  AClientAuditManager: TClientAuditManager);
const
  ThisMethodName = 'AppendDissection';
Var
   Seq : Integer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Seq := 0;
   If T^.txLast_Dissection<>NIL then Seq := T^.txLast_Dissection^.dsSequence_No;
   Inc( Seq );
   With D^ do
   Begin
      dsTransaction  := T;
      dsSequence_No  := Seq;
      dsNext         := NIL;
      dsClient       := T.txClient;
      dsBank_Account := T.txBank_Account;
      if Assigned(AClientAuditManager) then
        dsAudit_Record_ID := AClientAuditManager.NextAuditRecordID;
   end;
   With T^ do
   Begin
      If ( txFirst_Dissection = NIL ) then txFirst_Dissection := D;
      If ( txLast_Dissection<>NIL ) then txLast_Dissection^.dsNext := D;
      txLast_Dissection := D;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
function TTransaction_List.Compare(Item1, Item2 : pointer): integer;
begin
  if pTransaction_Rec(Item1)^.txDate_Effective < pTransaction_Rec(Item2)^.txDate_Effective then result := -1 else
  if pTransaction_Rec(Item1)^.txDate_Effective > pTransaction_Rec(Item2)^.txDate_Effective then result := 1 else
  if pTransaction_Rec(Item1)^.txSequence_No    < pTransaction_Rec(Item2)^.txSequence_No then result := -1 else
  if pTransaction_Rec(Item1)^.txSequence_No    > pTransaction_Rec(Item2)^.txSequence_No then result := 1 else
  result := 0;
end;
//------------------------------------------------------------------------------
procedure TTransaction_List.Insert(Item:Pointer);
const
  ThisMethodName = 'TTransaction_List.Insert';
var
  Msg : string;
begin
  Msg := Format( '%s : Called Direct', [ ThisMethodName] );
  LogUtil.LogMsg(lmError, UnitName, Msg );
  raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
end;
//------------------------------------------------------------------------------
procedure TTransaction_List.FreeItem(Item : Pointer);
begin
  Dispose_Transaction_Rec(pTransaction_Rec(item));
end;
//------------------------------------------------------------------------------
procedure TTransaction_List.Insert_Transaction_Rec(var p: pTransaction_Rec;
  NewAuditID: Boolean = True);
const
  ThisMethodName = 'TTransaction_List.Insert_Transaction_Rec';
var
  NewTran_Suggested_Index_Rec : pTran_Suggested_Index_Rec;
Begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  If BKTXIO.IsATransaction_Rec( P ) then
  Begin
    Inc( FLastSeq );
    P^.txSequence_No  := FLastSeq;
    P^.txBank_Account := fBank_Account;
    P^.txClient       := fClient;

    if (fBank_Account is TBank_Account) and
       (not (TBank_Account(fBank_Account).IsAJournalAccount)) then
    begin
      NewTran_Suggested_Index_Rec := fTran_Suggested_Index.NewItem;
      NewTran_Suggested_Index_Rec^.tiType                := P^.txType;
      NewTran_Suggested_Index_Rec^.tiDate_Effective      := P^.txDate_Effective;
      NewTran_Suggested_Index_Rec^.tiTran_Seq_No         := P^.txSequence_No;
      NewTran_Suggested_Index_Rec^.tiStatement_Details   := P^.txStatement_Details;
      NewTran_Suggested_Index_Rec^.tiAccount             := P^.txAccount;
      NewTran_Suggested_Index_Rec^.tiSuggested_Mem_State := P^.txSuggested_Mem_State;
      NewTran_Suggested_Index_Rec^.tiCoded_By            := P^.txCoded_By;

      SuggestedMem.UpdateAccountWithTransInsert(TBank_Account(fBank_Account),
                                                NewTran_Suggested_Index_Rec,
                                                ((not FLoading) and NewAuditID));

      fTran_Suggested_Index.Insert(NewTran_Suggested_Index_Rec);
    end;

    //Get next audit ID for new transactions
    if (not FLoading) and Assigned(fAuditMgr) and NewAuditID then
      P^.txAudit_Record_ID := fAuditMgr.NextAuditRecordID;

    Inherited Insert( P );
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------
procedure TTransaction_List.LoadFromFile(var S : TIOStream);
const
  ThisMethodName = 'TTransaction_List.LoadFromFile';
Var
   Token       : Byte;
   pTX         : pTransaction_Rec;
   pDS         : pDissection_Rec;
   msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   FLoading := True;
   fTran_Suggested_Index.SortingOn := false;
   try
     if (fBank_Account is TBank_Account) then
       TBank_Account(fBank_Account).baFields.baSuggested_UnProcessed_Count := 0;

     pTX := NIL;
     Token := S.ReadToken;
     While ( Token <> tkEndSection ) do
     Begin
        Case Token of
           tkBegin_Transaction :
              Begin
                 pTX := New_Transaction_Rec;
                 Read_Transaction_Rec ( pTX^, S );
                 Insert_Transaction_Rec( pTX );
              end;

           tkBegin_Dissection :
              Begin
                 pDS := New_Dissection_Rec;
                 Read_Dissection_Rec ( pDS^, S );
                 AppendDissection( pTX, pDS );
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
   finally
     FLoading := False;
     fTran_Suggested_Index.SortingOn := true;
     fTran_Suggested_Index.Sort();
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TTransaction_List.New_Transaction: pTransaction_Rec;
begin
  // Create a Transaction Rec with Object references
  // so we can call Helper Methods on it
  // before it is inserted into the list.
  Result := BKTXIO.New_Transaction_Rec;
  Result.txBank_Account := fBank_Account;
  Result.txClient  := fClient;

  ClearSuperFundFields(Result);
end;

//------------------------------------------------------------------------------
procedure TTransaction_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TTransaction_List.SaveToFile';
Var
   i   : LongInt;
   pTX : pTransaction_Rec;
   pDS : pDissection_Rec;
   TXCount  : LongInt;
   DSCount  : LongInt;

   IsNotAJournalAccount : boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   TXCount := 0;
   DSCount := 0;

   IsNotAJournalAccount := true;
   if (fBank_Account is TBank_Account) and
      (TBank_Account(fBank_Account).IsAJournalAccount) then
     IsNotAJournalAccount := false;

   if IsNotAJournalAccount then
   begin
     fTran_Suggested_Index.SortForSave := true;
     fTran_Suggested_Index.Sort();
   end;

   S.WriteToken( tkBeginEntries );

   For i := 0 to Pred( ItemCount ) do
   Begin
      pTX := Transaction_At( i );

      if IsNotAJournalAccount then
        pTx^.txSuggested_Mem_State := self.GetIndexPRec(i)^.tiSuggested_Mem_State;

      pTx^.txLRN_NOW_UNUSED := 0;   //clear any obsolete data

      BKTXIO.Write_Transaction_Rec ( pTX^, S );
      Inc( TXCount );

      pDS := pTX^.txFirst_Dissection;
      While pDS<>NIL do
      Begin
         BKDSIO.Write_Dissection_Rec ( pDS^, S );
         Inc( DSCount );
         pDS := pDS^.dsNext;
      end;
   end;
   S.WriteToken( tkEndSection );

   if IsNotAJournalAccount then
   begin
     fTran_Suggested_Index.SortForSave := false;
     fTran_Suggested_Index.Sort();
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %d transactions %d dissection saved',[ThisMethodName, txCount, dsCount]));
end;

procedure TTransaction_List.SetAuditInfo(P1, P2: pTransaction_Rec;
  AParentID: integer; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := AParentID;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Transaction']) +
                               VALUES_DELIMITER +
                               Format('%s=%d', ['ParentID', AParentID]);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.txAudit_Record_ID;
    AAuditInfo.AuditOtherInfo :=
      AAuditInfo.AuditOtherInfo + VALUES_DELIMITER +
      Format('%s=%s',[BKAuditNames.GetAuditFieldName(tkBegin_Transaction, 166), BkDate2Str(P2.txDate_Presented)]) +
      VALUES_DELIMITER +
      Format('%s=%s',[BKAuditNames.GetAuditFieldName(tkBegin_Transaction, 169), Money2Str(P2.txAmount)]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.txAudit_Record_ID;
    if Transaction_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.txAudit_Record_ID;
    P1.txAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKTXIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Transaction_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;

procedure TTransaction_List.SetAuditMgr(const Value: TClientAuditManager);
begin
  FAuditMgr := Value;
end;

procedure TTransaction_List.SetBank_Account(const Value: TObject);
begin
  FBank_Account := Value;
end;

procedure TTransaction_List.SetClient(const Value: TObject);
begin
  FClient := Value;
end;

procedure TTransaction_List.SetDissectionAuditInfo(P1, P2: pDissection_Rec;
  AParentID: integer; var AAuditInfo: TAuditInfo);
begin
  AAuditInfo.AuditAction := aaNone;
  AAuditInfo.AuditParentID := AParentID;
  AAuditInfo.AuditOtherInfo := Format('%s=%s', ['RecordType','Dissection']) +
                               VALUES_DELIMITER +
                               Format('%s=%d', ['ParentID', AParentID]);
  if not Assigned(P1) then begin
    //Delete
    AAuditInfo.AuditAction := aaDelete;
    AAuditInfo.AuditRecordID := P2.dsAudit_Record_ID;
    AAuditInfo.AuditOtherInfo :=
      AAuditInfo.AuditOtherInfo + VALUES_DELIMITER +
      //Save Account and Amount
      Format('%s=%s',[BKAuditNames.GetAuditFieldName(tkBegin_Dissection, 183), P2.dsAccount]) +
      VALUES_DELIMITER +
      Format('%s=%s',[BKAuditNames.GetAuditFieldName(tkBegin_Dissection, 184), Money2Str(P2.dsAmount)]);
  end else if Assigned(P2) then begin
    //Change
    AAuditInfo.AuditRecordID := P1.dsAudit_Record_ID;
    if Dissection_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.dsAudit_Record_ID;
    P1.dsAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKDSIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Dissection_Rec(P1, AAuditInfo.AuditRecord);
  end;

end;

//------------------------------------------------------------------------------
function TTransaction_List.Transaction_At(Index : longint) : pTransaction_Rec;
const
  ThisMethodName = 'TTransaction_List.Transaction_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   If BKTXIO.IsATransaction_Rec( P ) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
function TTransaction_List.GetIndexPRec(aIndex: integer): pTran_Suggested_Index_Rec;
begin
  Result := fTran_Suggested_Index.At(aIndex);
end;

//------------------------------------------------------------------------------
function TTransaction_List.GetTransCoreID_At(Index : longint) : int64;
begin
  Result := BKUTIL32.GetTransCoreID(Transaction_At(Index));
end;

//------------------------------------------------------------------------------
function TTransaction_List.FirstEffectiveDate : LongInt;
var
  i: integer;
  Transaction: TTransaction_Rec;
begin
  result := 0;

  for i := 0 to ItemCount-1 do
  begin
    Transaction := Transaction_At(i)^;

    if (i = 0) then
      result := Transaction.txDate_Effective
    else
      result := Min(result, Transaction.txDate_Effective);
  end;
end;

//------------------------------------------------------------------------------
function TTransaction_List.LastEffectiveDate : LongInt;
var
  i: integer;
  Transaction: TTransaction_Rec;
begin
  result := 0;

  for i := 0 to ItemCount-1 do
  begin
    Transaction := Transaction_At(i)^;

    if (i = 0) then
      result := Transaction.txDate_Effective
    else
      result := Max(result, Transaction.txDate_Effective);
  end;
end;

//------------------------------------------------------------------------------
function TTransaction_List.FirstPresDate : LongInt;
//returns 0 if no transactions or the first Date of Presentation
const
  ThisMethodName = 'TTransaction_List.FirstDate';
var
  i: integer;
  TransRec: TTransaction_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  Result := 0;
  for i := 0 to Pred(itemCount) do begin
    TransRec := Transaction_At(i)^;
    if (Result = 0) or
       ((Result > 0) and (TransRec.txDate_Presented < Result)
                     and (TransRec.txDate_Presented > 0)) then
      Result := TransRec.txDate_Presented;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------
function TTransaction_List.LastPresDate : LongInt;
//returns 0 if no transactions or the highest Date of Presentation
const
  ThisMethodName = 'TTransaction_List.LastDate';
var
  i: integer;
  TransRec: TTransaction_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  Result := 0;
  for i := 0 to Pred(itemCount) do begin
    TransRec := Transaction_At( I )^;
    if (Result < TransRec.txDate_Presented) then
      Result := TransRec.txDate_Presented;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
procedure TTransaction_List.UpdateCRC(var CRC: Longword);
var
  T: Integer;
  Transaction: pTransaction_Rec;
  Dissection: pDissection_Rec;
begin
  For T := 0 to Pred( ItemCount ) do Begin
     Transaction := Transaction_At( T );
     BKCRC.UpdateCRC( Transaction^, CRC );
     With Transaction^ do Begin
        Dissection := txFirst_Dissection;
        While Dissection<>NIL do With Dissection^ do Begin
           BKCRC.UpdateCRC( Dissection^, CRC );
           Dissection := Dissection^.dsNext;
        end;
     end;
  end;
end;

//------------------------------------------------------------------------------
constructor TTransaction_List.Create(AClient, ABank_Account: TObject; AAuditMgr: TClientAuditManager);
begin
  inherited Create;

  fTran_Suggested_Index := TTran_Suggested_Index.Create;
  FLoading := False;
  Duplicates := false;
  FLastSeq := 0;
  FClient := AClient;
  FBank_Account := ABank_Account;
  FAuditMgr := AAuditMgr;
end;

destructor TTransaction_List.Destroy;
begin
  FreeAndNil(fTran_Suggested_Index);
  inherited;
end;

//------------------------------------------------------------------------------
procedure TTransaction_List.DoAudit(ATransactionListCopy: TTransaction_List;
  AParentID: integer; AAccountType: byte; var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pTransaction_Rec;
  AuditInfo: TAuditInfo;
  ProvDateStr: string;
  T1, T2: pTransaction_Rec;
begin
  //Note: AuditType is dependant on the type of bank account
  AuditInfo.AuditUser := FAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Transaction;
  //Adds, changes
  for i := 0 to Pred(ItemCount) do begin
    P1 := Items[i];
    P2 := nil;
    if Assigned(ATransactionListCopy) then
      P2 := ATransactionListCopy.FindRecordID(P1.txAudit_Record_ID);
    AuditInfo.AuditRecord := New_Transaction;
    try
      AuditInfo.AuditType := FAuditMgr.GetTransactionAuditType(P1^.txSource, AAccountType);
      SetAuditInfo(P1, P2, AParentID, AuditInfo);
      if AuditInfo.AuditAction in [aaAdd, aaChange] then begin
        //Add provisional info
        if (AuditInfo.AuditAction = aaAdd) and (P1.txSource = orProvisional) then begin
          if (P1^.txTemp_Prov_Date_Time = 0) then
            ProvDateStr := 'UNKNOWN'
          else
            ProvDateStr := FormatDateTime('dd/MM/yy hh:mm:ss', P1^.txTemp_Prov_Date_Time);
          AuditInfo.AuditOtherInfo := Format('%s%sEntered By=%s%sEntered At=%s',
                                             [AuditInfo.AuditOtherInfo,
                                              VALUES_DELIMITER,
                                              P1^.txTemp_Prov_Entered_By,
                                              VALUES_DELIMITER,
                                              ProvDateStr]);
        end;
        AAuditTable.AddAuditRec(AuditInfo);
      end;
    finally
      Dispose(AuditInfo.AuditRecord);
    end;
  end;
  //Deletes
  if Assigned(ATransactionListCopy) then begin //Sub list - may not be assigned
    for i := 0 to ATransactionListCopy.ItemCount - 1 do begin
      P2 := ATransactionListCopy.Items[i];
      AuditInfo.AuditType := FAuditMgr.GetTransactionAuditType(P2^.txSource, AAccountType);
      P1 := FindRecordID(P2.txAudit_Record_ID);
      AuditInfo.AuditRecord := New_Transaction;
      try
        SetAuditInfo(P1, P2, AParentID, AuditInfo);
        if (AuditInfo.AuditAction = aaDelete) then
          AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
    end;
  end;

  //Dissections
  for i := 0 to Pred(itemCount) do begin
    T1 := Items[i];
    T2 := nil;
    if Assigned(ATransactionListCopy) then
      T2 := ATransactionListCopy.FindRecordID(T1.txAudit_Record_ID);
    if Assigned(T1) then
      DoDissectionAudit(T1, T2, AAccountType, AAuditTable)
  end;
end;

procedure TTransaction_List.DoDissectionAudit(ATransaction,
  ATransactionCopy: pTransaction_Rec; AAccountType: byte; var AAuditTable: TAuditTable);
var
  P1, P2: pDissection_Rec;
  AuditInfo: TAuditInfo;
begin
  //Note: AuditType is dependant on the type of bank account
  AuditInfo.AuditUser := FAuditMgr.CurrentUserCode;
  AuditInfo.AuditRecordType := tkBegin_Dissection;
  //Adds, changes
  if Assigned(ATransaction) then begin
    P1 := ATransaction.txFirst_Dissection;
    while (P1 <> nil) do begin
      P2 := nil;
      if Assigned(ATransactionCopy) then
        P2 := FindDissectionRecordID(ATransactionCopy, P1.dsAudit_Record_ID);
      AuditInfo.AuditRecord := New_Dissection_Rec;
      try
        AuditInfo.AuditType := FAuditMgr.GetTransactionAuditType(ATransaction^.txSource, AAccountType);
        SetDissectionAuditInfo(P1, P2, ATransaction.txAudit_Record_ID , AuditInfo);
        if AuditInfo.AuditAction in [aaAdd, aaChange] then
          AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
      P1 := P1^.dsNext;
    end;
  end;
  //Deletes
  if Assigned(ATransactionCopy) then begin //Sub list - may not be assigned
    P2 := ATransactionCopy.txFirst_Dissection;
    while P2 <> nil do begin
      AuditInfo.AuditType := FAuditMgr.GetTransactionAuditType(ATransactionCopy.txSource, AAccountType);
      P1 := nil;
      if Assigned(ATransaction) then
        P1 := FindDissectionRecordID(ATransaction, P2.dsAudit_Record_ID);
      AuditInfo.AuditRecord := New_Dissection_Rec;
      try
        SetDissectionAuditInfo(P1, P2, ATransactionCopy.txAudit_Record_ID, AuditInfo);
        if (AuditInfo.AuditAction = aaDelete) then
          AAuditTable.AddAuditRec(AuditInfo);
      finally
        Dispose(AuditInfo.AuditRecord);
      end;
      P2 := P2^.dsNext;
    end;
  end;
end;

function TTransaction_List.FindDissectionRecordID(
  ATransaction: pTransaction_Rec; ARecordID: integer): pDissection_Rec;
var
  Dissection: pDissection_Rec;
begin
  Result := nil;
  if Assigned(ATransaction) then begin
    Dissection := ATransaction.txFirst_Dissection;
    while Dissection <> nil do begin
      if Dissection.dsAudit_Record_ID = ARecordID then begin
        Result := Dissection;
        Break;
      end;
      Dissection := Dissection.dsNext;
    end;
  end;
end;

function TTransaction_List.FindRecordID(ARecordID: integer): pTransaction_Rec;
var
  i : integer;
begin
  Result := nil;
  if (ItemCount = 0) then Exit;

  for i := 0 to Pred(ItemCount) do
    if Transaction_At(i).txAudit_Record_ID = ARecordID then begin
      Result := Transaction_At(i);
      Exit;
    end;
end;

function TTransaction_List.FindTransactionFromECodingUID(
  UID: integer): pTransaction_Rec;
var
  T: Integer;
  Transaction: pTransaction_Rec;
begin
  result := nil;
  for T := First to Last do
  begin
    Transaction := Transaction_At( T );
    if Transaction.txECoding_Transaction_UID = UID then
    begin
      result := Transaction;
      exit;
    end;
  end;
end;

function TTransaction_List.FindTransactionFromMatchId(
  UID: integer): pTransaction_Rec;
var
  T: Integer;
  Transaction: pTransaction_Rec;
begin
  result := nil;
  for T := First to Last do
  begin
    Transaction := Transaction_At( T );
    if (Transaction.txMatched_Item_ID = UID) and (Transaction.txUPI_State in [upReversedUPC, upReversedUPD, upReversedUPW]) then
    begin
      result := Transaction;
      exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TTransaction_List.SearchUsingDateandTranSeqNo(aDate_Effective, aTranSeqNo : integer; var aIndex: integer): Boolean;
var
  Top, Bottom, Index, CompRes : Integer;
begin
  Result := False;
  Top := 0;
  Bottom := FCount - 1;
  while Top <= Bottom do
  begin
    Index := ( Top + Bottom ) shr 1;

    CompRes := CompareValue(aDate_Effective, pTransaction_Rec(At(Index))^.txDate_Effective);
    if CompRes = 0 then
      CompRes := CompareValue(aTranSeqNo, pTransaction_Rec(At(Index))^.txSequence_No);

    if CompRes > 0 then
      Top := Index + 1
    else
    begin
      Bottom := Index - 1;
      if CompRes = 0 then
      begin
        Result := True;
        aIndex := Index;
        Exit;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TTransaction_List.SearchUsingTypeDateandTranSeqNo(aType: Byte; aDate_Effective, aTranSeqNo: integer; var aIndex: integer): Boolean;
var
  SearchpTran_Suggested_Index_Rec : pTran_Suggested_Index_Rec;
begin
  SearchpTran_Suggested_Index_Rec := fTran_Suggested_Index.NewItem;
  try
    SearchpTran_Suggested_Index_Rec^.tiType := aType;
    SearchpTran_Suggested_Index_Rec^.tiDate_Effective := aDate_Effective;
    SearchpTran_Suggested_Index_Rec^.tiTran_Seq_No := aTranSeqNo;
    Result := fTran_Suggested_Index.Search(SearchpTran_Suggested_Index_Rec, aIndex);
  finally
    fTran_Suggested_Index.FreeItem(SearchpTran_Suggested_Index_Rec);
  end;
end;

//------------------------------------------------------------------------------
initialization
   DebugMe := DebugUnit(UnitName);

end.
