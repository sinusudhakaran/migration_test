unit teList32;
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

  //----------------------------------------------------------------------------
  TTransaction_Extra_List = class(TExtdSortedCollection)
  private
    FLastSeq      : integer;
//DN    FClient       : TObject;
//DN    FBank_Account : TObject;
//DN    FAuditMgr     : TClientAuditManager;
    FLoading      : boolean;

//DN    function FindRecordID(ARecordID: integer):  pTransaction_Extra_Rec;
//DN    procedure SetClient(const Value: TObject);
//DN    procedure SetBank_Account(const Value: TObject);
//DN    procedure SetAuditMgr(const Value: TClientAuditManager);
  protected
    procedure FreeItem(Item : Pointer); override;
  public
    constructor Create(*( AClient, ABank_Account: TObject; AAuditMgr: TClientAuditManager )*); reintroduce; overload; virtual;
    destructor Destroy; override;
    function Compare(Item1,Item2 : Pointer): Integer; override;
    procedure Insert(Item:Pointer); override;
    procedure Insert_Transaction_Extra_Rec((*var *)p: pTransaction_Extra_Rec );

    procedure LoadFromFile(var S : TIOStream);
    procedure SaveToFile(var S: TIOStream);
    function Transaction_Extra_At(Index : longint) : pTransaction_Extra_Rec;
//DN    function GetTransCoreID_At(Index : longint) : int64;
//DN    function FindTransactionFromECodingUID( UID : integer) : pTransaction_Extra_Rec;
//DN    function FindTransactionFromMatchId(UID: integer): pTransaction_Extra_Rec;
    function SearchUsingDateandTranSeqNo(aDate_Effective, aTranSeqNo : integer; var aIndex: integer): Boolean;
//DN    function SearchUsingTypeDateandTranSeqNo(aType : Byte; aDate_Effective, aTranSeqNo : integer; var aIndex: integer): Boolean;
//DN    function SearchByTransactionCoreID(aCore_Transaction_ID, aCore_Transaction_ID_High: integer; var aIndex: integer): Boolean;
//DN    function TransactionCoreIDExists(aCore_Transaction_ID, aCore_Transaction_ID_High: integer): Boolean;


    function New_Transaction_Extra : pTransaction_Extra_Rec;

    // Effective date
    // Note: returns 0 zero or first/last date of Effective Date
    function FirstEffectiveDate : LongInt;
    function LastEffectiveDate : LongInt;

    // Presented date
//DN    function FirstPresDate : LongInt;
//DN    function LastPresDate : LongInt;

    procedure UpdateCRC(var CRC : Longword);
//DN    procedure DoAudit(ATransactionListCopy: TTransaction_Extra_List; AParentID: integer;
//DN                      AAccountType: byte; var AAuditTable: TAuditTable);
//DN    procedure DoDissectionAudit(ATransaction, ATransactionCopy: pTransaction_Extra_Rec;
//DN                                AAccountType: byte;
//DN                                var AAuditTable: TAuditTable);
//DN    procedure SetAuditInfo(P1, P2: pTransaction_Extra_Rec; AParentID: integer;
//DN                           var AAuditInfo: TAuditInfo);
//DN    procedure SetDissectionAuditInfo(P1, P2: pDissection_Rec; AParentID: integer;
//DN                                     var AAuditInfo: TAuditInfo);
//DN    function GetIndexPRec(aIndex: integer): pTran_Suggested_Index_Rec;

    property LastSeq : integer read FLastSeq;
//DN    property TxnClient: TObject read FClient write SetClient;
//DN    property TxnBankAccount: TObject read FBank_Account write SetBank_Account;
//DN    property AuditMgr: TClientAuditManager read FAuditMgr write SetAuditMgr;

//DN    property Tran_Suggested_Index : TTran_Suggested_Index read fTran_Suggested_Index;
  end;

  procedure Dispose_Transaction_Extra_Rec(p: pTransaction_Extra_Rec);

//------------------------------------------------------------------------------
implementation

uses
  Math,
  TransactionUtils,
//  bktxio,
//  bkdsio,
  bkteio,
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
  UnitName = 'TELIST32';
  SInsufficientMemory = UnitName + ' Error: Out of memory in %s.NewItem';


procedure Dispose_Transaction_Extra_Rec(p: pTransaction_Extra_Rec);
const
  ThisMethodName = 'Dispose_Transaction_Extra_Rec';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if ( BKTEIO.IsATransaction_Extra_Rec( P ) )  then With P^ do
   Begin
      BKTEIO.Free_Transaction_Extra_Rec_Dynamic_Fields( P^);
      MALLOC.SafeFreeMem( P, Transaction_Extra_Rec_Size );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;


{ TTransaction_Extra_List }
//------------------------------------------------------------------------------
function TTransaction_Extra_List.Compare(Item1, Item2 : pointer): integer;
begin
  if pTransaction_Extra_Rec(Item1)^.teDate_Effective < pTransaction_Extra_Rec(Item2)^.teDate_Effective then result := -1 else
  if pTransaction_Extra_Rec(Item1)^.teDate_Effective > pTransaction_Extra_Rec(Item2)^.teDate_Effective then result := 1 else
  if pTransaction_Extra_Rec(Item1)^.teSequence_No    < pTransaction_Extra_Rec(Item2)^.teSequence_No then result := -1 else
  if pTransaction_Extra_Rec(Item1)^.teSequence_No    > pTransaction_Extra_Rec(Item2)^.teSequence_No then result := 1 else
  result := 0;
end;
//------------------------------------------------------------------------------
procedure TTransaction_Extra_List.Insert(Item:Pointer);
const
  ThisMethodName = 'TTransaction_Extra_List.Insert';
var
  Msg : string;
begin
  Msg := Format( '%s : Called Direct', [ ThisMethodName] );
  LogUtil.LogMsg(lmError, UnitName, Msg );
  raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
end;
//------------------------------------------------------------------------------
procedure TTransaction_Extra_List.FreeItem(Item : Pointer);
begin
  Dispose_Transaction_Extra_Rec(pTransaction_Extra_Rec(item));
end;
//------------------------------------------------------------------------------
procedure TTransaction_Extra_List.Insert_Transaction_Extra_Rec( (*var *)p: pTransaction_Extra_Rec );
const
  ThisMethodName = 'TTransaction_Extra_List.Insert_Transaction_Extra_Rec';

Begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  If BKTEIO.IsATransaction_Extra_Rec( P ) then
  Begin
    Inc( FLastSeq );
//DN    P^.teSequence_No  := FLastSeq;

    Inherited Insert( P );
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------
procedure TTransaction_Extra_List.LoadFromFile(var S : TIOStream);
const
  ThisMethodName = 'TTransaction_Extra_List.LoadFromFile';
Var
   Token              : Byte;
   pTransaction_Extra : pTransaction_Extra_Rec;
   pDS         : pDissection_Rec;
   msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   FLoading := True;
//DN   fTran_Suggested_Index.SortingOn := false;
//DN   fTran_Transaction_Code_Index.SortingOn := false;
   try
//DN     if (fBank_Account is TBank_Account) then
//DN       TBank_Account(fBank_Account).baFields.baSuggested_UnProcessed_Count := 0;

     pTransaction_Extra := NIL;
     Token := S.ReadToken;
     While ( Token <> tkEndSection ) do
     Begin
        Case Token of
           tkBegin_Transaction_Extra :
              Begin
                 pTransaction_Extra := New_Transaction_Extra_Rec;
                 Read_Transaction_Extra_Rec ( pTransaction_Extra^, S );
                 Insert_Transaction_Extra_Rec( pTransaction_Extra );
              end;

//DN           tkBegin_Dissection :
//DN              Begin
//DN                 pDS := New_Dissection_Rec;
//DN                 Read_Dissection_Rec ( pDS^, S );
//DN                 AppendDissection( pTX, pDS );
//DN              end;

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
//DN     fTran_Suggested_Index.SortingOn := true;
//DN     fTran_Suggested_Index.Sort();

//DN     fTran_Transaction_Code_Index.SortingOn := true;
//DN     fTran_Transaction_Code_Index.Sort();
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TTransaction_Extra_List.New_Transaction_Extra: pTransaction_Extra_Rec;
begin
  // Create a Transaction Rec with Object references
  // so we can call Helper Methods on it
  // before it is inserted into the list.
  Result := BKTEIO.New_Transaction_Extra_Rec;
//DN  Result.txBank_Account := fBank_Account;
//DN  Result.txClient  := fClient;

  ClearSuperFundFields(Result);
end;

//------------------------------------------------------------------------------
procedure TTransaction_Extra_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TTransaction_Extra_List.SaveToFile';
Var
   i   : LongInt;
   pTransaction_Extra : pTransaction_Extra_Rec;
//DN   pDS : pDissection_Rec;
   TXCount  : LongInt;
//DN   DSCount  : LongInt;

   IsNotAJournalAccount : boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   TXCount := 0;
//DN   DSCount := 0;

//DN   IsNotAJournalAccount := true;
//DN   if (fBank_Account is TBank_Account) and
//DN      (TBank_Account(fBank_Account).IsAJournalAccount) then
//DN     IsNotAJournalAccount := false;

//DN   if IsNotAJournalAccount then
//DN   begin
//DN     fTran_Suggested_Index.SortForSave := true;
//DN     fTran_Suggested_Index.Sort();
//DN
//DN     fTran_Transaction_Code_Index.Sort();
//DN   end;

   S.WriteToken( tkBeginEntries );

   For i := 0 to Pred( ItemCount ) do
   Begin
      pTransaction_Extra := Transaction_Extra_At( i );

//DN      if IsNotAJournalAccount then
//DN        pTx^.txSuggested_Mem_State := self.GetIndexPRec(i)^.tiSuggested_Mem_State;

//DN      pTransEXtra^.txLRN_NOW_UNUSED := 0;   //clear any obsolete data

      BKTEIO.Write_Transaction_Extra_Rec ( pTransaction_Extra^, S );
      Inc( TXCount );

(*//DN      pDS := pTransEXtra^.txFirst_Dissection;
      While pDS<>NIL do
      Begin
         BKDSIO.Write_Dissection_Rec ( pDS^, S );
         Inc( DSCount );
         pDS := pDS^.dsNext;
      end;
//DN *)
   end;
   S.WriteToken( tkEndSection );

(*//DN   if IsNotAJournalAccount then
   begin
//DN     fTran_Suggested_Index.SortForSave := false;
//DN     fTran_Suggested_Index.Sort();

//DN     fTran_Transaction_Code_Index.Sort();
   end;
//DN *)

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
//DN   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %d transactions %d dissection saved',[ThisMethodName, txCount, dsCount]));
end;


(*//DN
procedure TTransaction_Extra_List.SetAuditInfo(P1, P2: pTransaction_Extra_Rec;
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
    if Transaction_Extra_Rec_Delta(P1, P2, AAuditInfo.AuditRecord, AAuditInfo.AuditChangedFields) then
      AAuditInfo.AuditAction := aaChange;
  end else begin
    //Add
    AAuditInfo.AuditAction := aaAdd;
    AAuditInfo.AuditRecordID := P1.txAudit_Record_ID;
    P1.txAudit_Record_ID := AAuditInfo.AuditRecordID;
    BKTEIO.SetAllFieldsChanged(AAuditInfo.AuditChangedFields);
    Copy_Transaction_Extra_Rec(P1, AAuditInfo.AuditRecord);
  end;
end;
//DN *)

//DNprocedure TTransaction_Extra_List.SetAuditMgr(const Value: TClientAuditManager);
//DNbegin
//DN  FAuditMgr := Value;
//DNend;
//DN
//DNprocedure TTransaction_Extra_List.SetBank_Account(const Value: TObject);
//DNbegin
//DN  FBank_Account := Value;
//DNend;

//DNprocedure TTransaction_Extra_List.SetClient(const Value: TObject);
//DNbegin
//DN  FClient := Value;
//DNend;

(*
procedure TTransaction_Extra_List.SetDissectionAuditInfo(P1, P2: pDissection_Rec;
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

function TTransaction_Extra_List.TransactionCoreIDExists(aCore_Transaction_ID,
  aCore_Transaction_ID_High: integer): Boolean;
var
  aIndex : integer;
begin
  result := SearchByTransactionCoreID(aCore_Transaction_ID, aCore_Transaction_ID_High, aIndex);
end;
*)

function TTransaction_Extra_List.Transaction_Extra_At(Index : longint) : pTransaction_Extra_Rec;
const
  ThisMethodName = 'TTransaction_Extra_List.Transaction_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   if ( Index < First ) or (Index > Last ) then // Not found exit returning nil
     exit;
   P := At( Index );
   If BKTEIO.IsATransaction_Extra_Rec( P ) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
(*
//------------------------------------------------------------------------------
function TTransaction_Extra_List.GetIndexPRec(aIndex: integer): pTran_Suggested_Index_Rec;
begin
  Result := fTran_Suggested_Index.At(aIndex);
end;
*)

//------------------------------------------------------------------------------
//DNfunction TTransaction_Extra_List.GetTransCoreID_At(Index : longint) : int64;
//DNbegin
//DN  Result := BKUTIL32.GetTransCoreID(Transaction_At(Index));
//DNend;

//------------------------------------------------------------------------------
function TTransaction_Extra_List.FirstEffectiveDate : LongInt;
var
  i: integer;
  pTransaction_Extra: pTransaction_Extra_Rec;
begin
  result := 0;

  for i := 0 to ItemCount-1 do
  begin
    pTransaction_Extra := Transaction_Extra_At(i);

    if (i = 0) then
      result := pTransaction_Extra^.teDate_Effective
    else
      result := Min(result, pTransaction_Extra^.teDate_Effective);
  end;
end;

//------------------------------------------------------------------------------
function TTransaction_Extra_List.LastEffectiveDate : LongInt;
var
  i: integer;
  pTransaction_Extra: pTransaction_Extra_Rec;
begin
  result := 0;

  for i := 0 to ItemCount-1 do
  begin
    pTransaction_Extra := Transaction_Extra_At(i);

    if (i = 0) then
      result := pTransaction_Extra^.teDate_Effective
    else
      result := Max(result, pTransaction_Extra^.teDate_Effective);
  end;
end;

(*//DN
//------------------------------------------------------------------------------
//DN
function TTransaction_Extra_List.FirstPresDate : LongInt;
//returns 0 if no transactions or the first Date of Presentation
const
  ThisMethodName = 'TTransaction_Extra_List.FirstDate';
var
  i: integer;
  TransRec: tTransaction_Extra_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  Result := 0;
  for i := 0 to Pred(itemCount) do begin
    TransRec := Transaction_At(i)^;
    if (Result = 0) or
       ((Result > 0) and (TransRec.teDate_Presented < Result)
                     and (TransRec.txDate_Presented > 0)) then
      Result := TransRec.txDate_Presented;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
function TTransaction_Extra_List.LastPresDate : LongInt;
//returns 0 if no transactions or the highest Date of Presentation
const
  ThisMethodName = 'TTransaction_Extra_List.LastDate';
var
  i: integer;
  TransRec: tTransaction_Extra_Rec;
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
//DN *)


//------------------------------------------------------------------------------
procedure TTransaction_Extra_List.UpdateCRC(var CRC: Longword);
var
  T: Integer;
  pTransaction_Extra: pTransaction_Extra_Rec;
//DN  Dissection: pDissection_Rec;
begin
  For T := 0 to Pred( ItemCount ) do Begin
     pTransaction_Extra := Transaction_Extra_At( T );
     BKCRC.UpdateCRC( pTransaction_Extra^, CRC );
//DN     With Transaction^ do Begin
//DN        Dissection := txFirst_Dissection;
//DN        While Dissection<>NIL do With Dissection^ do Begin
//DN           BKCRC.UpdateCRC( Dissection^, CRC );
//DN           Dissection := Dissection^.dsNext;
//DN        end;
//DN     end;
  end;
end;

//------------------------------------------------------------------------------
constructor TTransaction_Extra_List.Create; //DN(AClient, ABank_Account: TObject; AAuditMgr: TClientAuditManager);
begin
  inherited Create;

  FLoading := False;
  Duplicates := false;
  FLastSeq := 0;
//DN  FClient := AClient;
//DN  FBank_Account := ABank_Account;
//DN  FAuditMgr := AAuditMgr;
end;

destructor TTransaction_Extra_List.Destroy;
begin
  inherited;
end;

//------------------------------------------------------------------------------
(* //DN
procedure TTransaction_Extra_List.DoAudit(ATransactionListCopy: TTransaction_Extra_List;
  AParentID: integer; AAccountType: byte; var AAuditTable: TAuditTable);
var
  i: integer;
  P1, P2: pTransaction_Extra_Rec;
  AuditInfo: TAuditInfo;
  ProvDateStr: string;
  T1, T2: pTransaction_Extra_Rec;
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
//DN    if Assigned(T1) then
//DN      DoDissectionAudit(T1, T2, AAccountType, AAuditTable)
  end;
end;
//DN *)
(* //DN
procedure TTransaction_Extra_List.DoDissectionAudit(ATransaction,
  ATransactionCopy: pTransaction_Extra_Rec; AAccountType: byte; var AAuditTable: TAuditTable);
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
//DN *)

(* //DN
function TTransaction_Extra_List.FindRecordID(ARecordID: integer): pTransaction_Extra_Rec;
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
//DN *)

(*//DN
function TTransaction_Extra_List.FindTransactionFromECodingUID(
  UID: integer): pTransaction_Extra_Rec;
var
  T: Integer;
  Transaction: pTransaction_Extra_Rec;
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

function TTransaction_Extra_List.FindTransactionFromMatchId(
  UID: integer): pTransaction_Extra_Rec;
var
  T: Integer;
  Transaction: pTransaction_Extra_Rec;
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
function TTransaction_Extra_List.SearchByTransactionCoreID(aCore_Transaction_ID,
  aCore_Transaction_ID_High: integer; var aIndex: integer): Boolean;
var
  SearchTran_Transaction_Code_Index_Rec : pTran_Transaction_Code_Index_Rec;

begin
  SearchTran_Transaction_Code_Index_Rec := fTran_Transaction_Code_Index.NewItem;
  try
    if assigned( SearchTran_Transaction_Code_Index_Rec ) then
      SearchTran_Transaction_Code_Index_Rec^.tiCoreTransactionID     :=
        CombineInt32ToInt64( aCore_Transaction_ID_High, aCore_Transaction_ID);
    Result := fTran_Transaction_Code_Index.Search(SearchTran_Transaction_Code_Index_Rec, aIndex);
  finally
    fTran_Transaction_Code_Index.FreeItem( SearchTran_Transaction_Code_Index_Rec );
  end;
end;
//DN *)

function TTransaction_Extra_List.SearchUsingDateandTranSeqNo(aDate_Effective, aTranSeqNo : integer; var aIndex: integer): Boolean;
var
  Top, Bottom, Index, CompRes : Integer;
begin
  Result := False;
  Top := 0;
  Bottom := FCount - 1;
  while Top <= Bottom do
  begin
    Index := ( Top + Bottom ) shr 1;

    CompRes := CompareValue(aDate_Effective, pTransaction_Extra_Rec(At(Index))^.teDate_Effective);
    if CompRes = 0 then
      CompRes := CompareValue(aTranSeqNo, pTransaction_Extra_Rec(At(Index))^.teSequence_No);

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

(*
//------------------------------------------------------------------------------
function TTransaction_Extra_List.SearchUsingTypeDateandTranSeqNo(aType: Byte; aDate_Effective, aTranSeqNo: integer; var aIndex: integer): Boolean;
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
*)

(* //DN
//------------------------------------------------------------------------------
{ TTran_Transaction_Code_Index }
function TTran_Transaction_Code_Index.Compare(Item1, Item2: Pointer): integer;
begin
  result := 0;
  if assigned( Item1 ) then begin // Then assume for the moment Item2 is not assigned
    result := 1;
    if assigned( Item2 ) then     // Ok Item2 is assigned, safe to compare
      Result := CompareValue( pTran_Transaction_Code_Index_Rec( Item1 )^.tiCoreTransactionID,
          pTran_Transaction_Code_Index_Rec( Item2 )^.tiCoreTransactionID );
  end;
end;

constructor TTran_Transaction_Code_Index.Create;
begin
  inherited;

  Duplicates := true;
end;

procedure TTran_Transaction_Code_Index.FreeItem(Item: Pointer);
begin
  fillchar( pTran_Transaction_Code_Index_Rec(Item)^, Tran_Transaction_Code_Index_Rec_Size, #0);

  SafeFreeMem(Item, Tran_Transaction_Code_Index_Rec_Size);
  Item := nil;
end;

procedure TTran_Transaction_Code_Index.FreeTheItem(Item: Pointer);
begin
  DelFreeItem(Item);
end;

function TTran_Transaction_Code_Index.NewItem: Pointer;
var                                  
  P : pTran_Transaction_Code_Index_Rec;
Begin
  SafeGetMem( P, Tran_Transaction_Code_Index_Rec_Size );

  If Assigned( P ) then
    FillChar( P^, Tran_Transaction_Code_Index_Rec_Size, 0 )
  else
    Raise EInsufficientMemory.CreateFmt( SInsufficientMemory, [ 'TTran_Transaction_Code_Index' ] );

  Result := P;

end;
//DN *)
initialization
   DebugMe := DebugUnit(UnitName);

end.
