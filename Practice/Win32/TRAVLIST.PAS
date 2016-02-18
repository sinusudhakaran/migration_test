unit TravList;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Build a list of pointers to transactions that allow traversing thru an account, or all accounts
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  bkdefs, glConst, ecollect, bkconst, baObj32, moneydef, repCols,
  TextStream, NewReportObj, glObj32, glList32;

const
   twAllEntries            = 0;  twMin = 0;
   twAllUncoded            = 1;
   twAllNewEntries         = 2;
   twAllNewUncodedEntries  = 3;
   twAllPresentedEntries   = 4;
   twAllUnpresentedEntries = 5;  twMax = 5;

   csByGSTRate             = csMax + 1;

type
  TAccountTypeSet = set of byte;   


type
  TTransType = (ttTransaction, ttDissection, ttExchangeGainLoss);
  
  pTravItem = ^TTravItem;
  TTravItem = packed record
      Ptr       : Pointer;
      TransType : TTransType;
      Key       : ShortString;
   end;

  TTravList = class( TExtdSortedCollection )
      constructor Create; override;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
    protected
      procedure   FreeItem( Item : Pointer ); override;
    public
      function    InsertTransItem(p : pointer; TransType : TTransType; k : shortString) : boolean;
  end;

   TTravEvent = procedure(Sender : TObject);
   //allow the callback procedure to a method of an object
   TTravEventExt = procedure(Sender : TObject) of object;

   TTravManager = class
      constructor Create;
      destructor Destroy; override;
    private
      FOnEnterEntry : TTravEvent;
      FOnExitEntry  : TTravEvent;
      FOnExitAccount: TTravEvent;
      FOnEnterAccount: TTravEvent;
      FOnEnterDissection : TTravEvent;
      FOnBeforeSort : TTravEvent;
      FOnSort       : TTravEvent;
      FOnAfterSort  : TTravEvent;

      SortMethod    : Byte;
      FUseDatePresented: Boolean;
      SelectBy      : Byte;
      TransList      : TTravList;
      FNumOfAccounts: integer;
      FNumOfEntries: integer;
      FNumOfDissect: integer;
      CurrTrans     : pTransaction_Rec;
      CurrAccount   : TBank_Account;
      CurrDissect   : pDissection_Rec;
      CurrExchangeGainLossEntry: pExchange_Gain_Loss_Rec;
      FD1: integer;
      FD2: integer;
      FLastCodePrinted: string;
      FReverseFieldOrder: boolean;
      FIsLastTransaction: boolean;
      FNoTransactions: boolean;
      FOnEnterEntryExt: TTravEventExt;
      FOnExitEntryExt: TTravEventExt;
      FOnEnterDissectionExt: TTravEventExt;
      FOnEnterAccountExt: TTravEventExt;
      FTransactionsTraversed: Boolean;
      FOnEnterExchangeGainLoss: TTravEvent;

      function MakeSortKey (p : pTransaction_Rec): ShortString;
      function IsValidSelection( p : pTransaction_Rec): boolean;
      function MakeGainLossSortKey(GainLossEntry: TExchange_Gain_Loss): String;

      procedure SetNumOfAccounts(const Value: integer);
      procedure SetNumOfEntries(const Value: integer);
      procedure SetNumOfDissect(const Value: integer);
      procedure SetOnAfterSort(const Value: TTravEvent);
      procedure SetOnBeforeSort(const Value: TTravEvent);
      procedure SetOnSort(const Value: TTravEvent);
      procedure SetOnEnterAccount(const Value: TTravEvent);
      procedure SetOnExitAccount(const Value: TTravEvent);
      procedure SetOnEnterDissection(const Value: TTravEvent);
      procedure SetOnEnterDissectionExt(const Value: TTravEventExt);
      procedure SetOnEnterEntry(const Value: TTravEvent);
      procedure SetOnExitEntry(const Value: TTravEvent);
      procedure SetD1(const Value: integer);
      procedure SetD2(const Value: integer);
      procedure SetLastCodePrinted(const Value: string);
      procedure SetReverseFieldOrder(const Value: boolean);
      procedure SetCurrAccount(const Value: TBank_Account);

      procedure TraverseEntry;
      procedure SetSortMethod(const Value: byte);
      procedure SetOnEnterEntryExt(const Value: TTravEventExt);
      procedure SetOnExitEntryExt(const Value: TTravEventExt);
      procedure SetOnEnterAccountExt(const Value: TTravEventExt);
      procedure SetOnEnterExchangeGainLoss(const Value: TTravEvent);
    public
      property D1: integer read FD1 write SetD1;
      property D2: integer read FD2 write SetD2;
      property LastCodePrinted: string read FLastCodePrinted write SetLastCodePrinted;
      property ReverseFieldOrder : boolean read FReverseFieldOrder write SetReverseFieldOrder;

      {actions}
      property OnEnterAccount : TTravEvent read FOnEnterAccount write SetOnEnterAccount;
      property OnEnterAccountExt : TTravEventExt read FOnEnterAccountExt write SetOnEnterAccountExt;
      property OnExitAccount  : TTravEvent read FOnExitAccount write SetOnExitAccount;
      property OnEnterEntry   : TTravEvent read FOnEnterEntry write SetOnEnterEntry;
      property OnEnterEntryExt : TTravEventExt read FOnEnterEntryExt write SetOnEnterEntryExt;
      property OnExitEntry    : TTravEvent read FOnExitEntry write SetOnExitEntry;
      property OnExitEntryExt : TTravEventExt read FOnExitEntryExt write SetOnExitEntryExt;
      property OnEnterDissection : TTravEvent read FOnEnterDissection write SetOnEnterDissection;
      property OnEnterDissectionExt : TTravEventExt read FOnEnterDissectionExt write SetOnEnterDissectionExt;
      property OnEnterExchangeGainLoss: TTravEvent read FOnEnterExchangeGainLoss write SetOnEnterExchangeGainLoss;

      {sorting}
      property OnBeforeSort   : TTravEvent read FOnBeforeSort write SetOnBeforeSort;
      property OnAfterSort    : TTravEvent read FOnAfterSort write SetOnAfterSort;
      property OnSort         : TTravEvent read FOnSort write SetOnSort;

      {selection}
      property SortType : byte read SortMethod write SetSortMethod;
      property UseDatePresented: Boolean read FUseDatePresented write FUseDatePresented;
      property SelectionCriteria : byte read SelectBy write SelectBy;

      property NumOfAccounts : integer read FNumOfAccounts write SetNumOfAccounts;
      property NumOfEntries : integer read FNumOfEntries write SetNumOfEntries;
      property NumOfDissect : integer read FNumOfDissect write SetNumOfDissect;
      property Transaction  : pTransaction_Rec read CurrTrans;
      property Dissection   : pDissection_Rec read CurrDissect;
      property ExchangeGainLossEntry: pExchange_Gain_Loss_Rec read CurrExchangeGainLossEntry;
      property Bank_Account : TBank_Account read CurrAccount write SetCurrAccount;
      property IsLastTransaction: boolean read FIsLastTransaction;
      property NoTransactions: boolean read FNoTransactions;
      property TransactionsTraversed: Boolean read FTransactionsTraversed;

      {procedures }
      procedure TraverseAccount(B : TBank_Account; DateFrom, DateTo : integer);
      procedure TraverseAllAccounts(DateFrom, DateTo : integer); overload;
      procedure TraverseAllAccounts(DateFrom, DateTo: integer; AccountTypeSet : TAccountTypeSet); overload;

      procedure TraverseAllEntries(DateFrom, DateTo  : integer); overload;
      procedure TraverseAllEntries(DateFrom, DateTo  : integer; AccountTypeSet : TAccountTypeSet); overload;

      procedure ClearTotals;
      procedure ClearEvents;
      procedure Clear;      {clear everything}
    end;

{    TTravManagerWithReport = class(TTravManager)
      public
         OpBalAtBank       : Money;
         ClBalAtBank       : Money;
         OpBalInSystem     : Money;
         ClBalInSystem     : Money;
         CRTotal           : Money;
         DRTotal           : Money;
         C1                : TReportColumn;
         C2                : TReportColumn;
         ReportJob : TBKReportPrinter;
    end;
}
    TTravManagerWithNewReport = class(TTravManager)
      public
         OpBalAtBank       : Money;
         ClBalAtBank       : Money;
         OpBalInSystem     : Money;
         ClBalInSystem     : Money;
         CRTotal           : Money;
         DRTotal           : Money;
         C1                : TReportColumn;
         C2                : TReportColumn;
         ReportJob         : TBKReport;
    end;

    TTravManagerForExport = class(TTravManager)
      public
         ExportStream       : TTextfileStream;
         NoOfEntries        : integer;
         Contra             : Money;
         CrValue            : Money;
         DrValue            : Money;
         LineCount          : integer;
         AccountToTraverse  : TBank_Account;
         JnlNumber          : integer;
         TotalAmount        : Money;      {ca systems}
         TotalGST           : Money;      {ca systems}
         TotalQty           : Money;      {ca systems}
         SPCD               : Integer;    {ca systems}
         DCount             : integer;    {cash manager, concept}
         CodeLength         : integer;
         SequenceNo         : integer;
         TransNBR           : integer;

         GSTTotals          : Array[0..MAX_GST_CLASS] of Money;  //sol6
         RemoveGST          : Boolean;                           //sol6
      end;
//******************************************************************************
implementation
uses
  Globals,
  LogUtil,
  malloc,
  sysutils,
  StStrS,
  bkDateUtils,
  bkutil32,
  BK5Except,
  GenUtils;

const
  UnitName = 'TRAVLIST';
  DebugMe : Boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TTravList }
function TTravList.Compare(Item1, Item2: pointer): integer;
begin
   result := StStrS.CompStringS(pTravItem(Item1)^.Key, pTravItem(Item2)^.Key);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TTravList.Create;
const
  ThisMethodName = 'TTravList.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravList.FreeItem(Item: Pointer);
const
  ThisMethodName = 'TTravList.FreeItem';
Var
   P   : PTravItem;
   Len : Word;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := PTravItem( Item );
   If ( P <> nil ) then
   Begin
      Len := Ord( P^.Key[0] ) + Sizeof( Char ) + Sizeof( Boolean ) + Sizeof( LongInt );
      SafeFreeMem( P, Len );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TTravList.InsertTransItem(p: pointer; TransType: TTransType; k: shortString) : boolean;
const
  ThisMethodName = 'TTravList.InsertTransItem';
Var
   Pt : PTravItem;
   Len : Word;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   result := false;

   Len := Ord(K[0]) + Sizeof(Char) + Sizeof(TTransType) + Sizeof(Pointer);
   SafeGetMem( Pt , Len );

   If Pt<>NIL then
   Begin
      Pt^.Ptr   := P;
      Pt^.TransType := TransType;
      Pt^.Key   := K;
      Insert(Pt);
      result := true;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TTravManager }
procedure TTravManager.Clear;
const
  ThisMethodName = 'TTravManager.Clear';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   ClearTotals;
   ClearEvents;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.ClearEvents;
begin
   FOnEnterEntry         := nil;
   FOnEnterEntryExt      := nil;
   FOnExitEntry          := nil;
   FOnExitEntryExt       := nil;
   FOnExitAccount        := nil;
   FOnEnterAccount       := nil;
   FOnEnterAccountExt    := nil;
   FOnEnterDissection    := nil;
   FOnEnterDissectionExt := nil;
   FOnBeforeSort         := nil;
   FOnSort               := nil;
   FOnAfterSort          := nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.ClearTotals;
begin
   FNumofAccounts := 0;
   FnumofEntries  := 0;
   FnumofDissect  := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TTravManager.Create;
const
  ThisMethodName = 'TTravManager.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;

   D1 := 0;
   D2 := MaxInt;

   LastCodePrinted := '';
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TTravManager.Destroy;
begin
   inherited Destroy;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TTravManager.IsValidSelection(p: pTransaction_Rec): boolean;
const
  ThisMethodName = 'TTravManager.IsValidSelection';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := false;
   With p^ do Case SelectBy of
      twAllEntries            : result := TRUE;
      twAllUncoded            : result := IsUncoded( p );
      twAllNewEntries         : result := ( txDate_Transferred = 0 );
      twAllNewUncodedEntries  : result := ( txDate_Transferred = 0 ) and (IsUncoded(p) );
      twAllPresentedEntries   : result := ( txDate_Presented<>0 );
      twAllUnpresentedEntries : result := ( txDate_Presented = 0 );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TTravManager.MakeGainLossSortKey(GainLossEntry: TExchange_Gain_Loss): String;
var
  Key: String;
begin
  if SortMethod = csDateEffective then
  begin
    Result := LongToKey(GainLossEntry.glFields.glDate) +
              LongToKey(GainLossEntry.glFields.glTemp_Bank_Seq) +
              LongToKey(TransList.ItemCount + 1);
  end
  else
  begin
    Key := GainLossEntry.glFields.glAccount;

    if UseXlonSort then
    begin
      Key := FormatCodeForXlonSort(Key);
    end;

    while Length(Key) < MaxBK5CodeLen do
    begin
      Key := Key + ' ';
    end;

    Result :=
      Key +
      LongToKey(GainLossEntry.glFields.glDate) +
      LongToKey(TransList.ItemCount + 1);
  end;
end;

function TTravManager.MakeSortKey(p: pTransaction_Rec): ShortString;
{ Can now return a String up to 32 characters long }
const
  ThisMethodName = 'TTravManager.MakeSortKey';
Var
   Code   : Bk5CodeStr;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With P^ do
   Begin
      Case SortMethod of
         csDateEffective : MakeSortKey := LongToKey( txDate_Effective ) +
                                          LongToKey( txBank_Seq ) +
                                          LongToKey ( txSequence_No );

         csChequeNumber  :
            Begin
               Case MyClient.clFields.clCountry of
                  whNewZealand :
                     Begin
                        Case txType of
                           0, 3..9 :
                             Result := //LongToKey( txBank_Seq ) +
                                       ByteToKey( 1 ) +
                                       LongToKey( txCheque_Number ) +
                                       LongToKey( txDate_Effective ) +
                                       LongToKey ( txSequence_No );
                           else
                             Result := LongToKey( txBank_Seq ) +
                                       LongToKey( txDate_Effective ) +
                                       LongToKey ( txSequence_No );

                        end; { of Case txType }
                     end;
                  whAustralia,
                  whUK :
                     Begin
                        Case txType of
                           1 :
                             Result :=
                               //LongToKey( txBank_Seq ) +
                               ByteToKey( 1 ) +
                               LongToKey( txCheque_Number ) +
                               LongToKey( txDate_Effective ) +
                               LongToKey ( txSequence_No );
                           else
                             Result := LongToKey( txBank_Seq ) +
                                       LongToKey( txDate_Effective ) +
                                       LongToKey ( txSequence_No );
                        end; { of Case txType }
                     end;
               end; { of Case fdCountry }

            end;

         csReference : begin
              Code := GetFormattedReference(p);
              while Length(Code) < MaxBK5CodeLen do // Make sure are all the same length (weight)
                 Code := Code + ' ';
              Result := LongToKey( txBank_Seq ) +
                        Code +
                        LongToKey( txDate_Effective ) +
                        LongToKey ( txSequence_No );
            end;
         csDatePresented : MakeSortKey :=
                              LongToKey( txBank_Seq ) +
                              LongToKey( txDate_Presented ) +
                              LongToKey ( txSequence_No );

         csAccountCode   :
            Begin
               Code := txAccount;
               if UseXlonSort then
                 Code := FormatCodeForXlonSort(txAccount);
               If ( txFirst_Dissection<>NIL ) then Code := 'þ';
               While Length( Code ) < MaxBK5CodeLen Do Code := Code + ' ';
               MakeSortKey := Code + { !! 42.50 }
                  LongToKey( txDate_Effective ) +
                  LongToKey( txBank_Seq ) +
                  LongToKey( txSequence_No );
            end;

         csByValue       :
            Begin
               MakeSortKey :=  LongToKey( txBank_Seq ) +
                               LongToKey( Trunc( txAmount ) ) +
                               LongToKey( txDate_Effective ) +
                               LongToKey( txSequence_No );
            end;

         csByGSTRate :
            Begin
               MakeSortKey := ByteToKey( txGST_Class ) +
                              LongToKey( txBank_Seq ) +
                              LongToKey( txDate_Effective ) +
                              LongToKey( txSequence_No );
            end;

         csByNarration :
            Begin
               Code := Uppercase(Copy(txGL_Narration,1,MaxBk5CodeLen));
               While Length( Code ) < MaxBK5CodeLen Do Code := Code + ' ';

               MakeSortKey := LongToKey( txBank_Seq ) +
                              Code +
                              LongToKey( txDate_Effective ) +
                              LongToKey( txSequence_No ); {22}
            end;

         csByOtherParty :
            Begin
               Code := UpperCase(Copy(txOther_Party,1,MaxBK5CodeLen));
               While Length( Code ) < MaxBK5CodeLen Do Code := Code + ' ';

               MakeSortKey := LongToKey( txBank_Seq ) +
                              Code +
                              LongToKey( txDate_Effective ) +
                              LongToKey( txSequence_No ); {22}
            end;
         csDateAndReference :
          begin
              Code := GetFormattedReference(p);
              while Length(Code) < MaxBK5CodeLen do // Make sure are all the same length (weight)
                 Code := Code + ' ';
              Result := LongToKey( txBank_Seq ) +
                        LongToKey( txDate_Effective ) +
                        Code +
                        LongToKey ( txSequence_No );
          end
      else
         begin
            //in the unlikely event of an unknown sort code sort by date
            MakeSortKey := LongToKey( txBank_Seq ) +
                           LongToKey( txDate_Effective ) +
                           LongToKey ( txSequence_No );
         end;
      end; { of Case }
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetNumOfAccounts(const Value: integer);
begin
  FNumOfAccounts := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetNumOfDissect(const Value: integer);
begin
  FNumOfDissect := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetNumOfEntries(const Value: integer);
begin
  FNumOfEntries := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnAfterSort(const Value: TTravEvent);
begin
  FOnAfterSort := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnBeforeSort(const Value: TTravEvent);
begin
  FOnBeforeSort := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnEnterAccount(const Value: TTravEvent);
begin
  FOnEnterAccount := Value;
end;
procedure TTravManager.SetOnEnterAccountExt(const Value: TTravEventExt);
begin
  FOnEnterAccountExt := Value;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnEnterDissection(const Value: TTravEvent);
begin
  FOnEnterDissection := Value;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnEnterDissectionExt(const Value: TTravEventExt);
begin
  FOnEnterDissectionExt := Value;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnEnterEntry(const Value: TTravEvent);
begin
  FOnEnterEntry := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnEnterEntryExt(const Value: TTravEventExt);
begin
  FOnEnterEntryExt := Value;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnExitEntryExt(const Value: TTravEventExt);
begin
  FOnExitEntryExt := Value;
end;

procedure TTravManager.SetOnEnterExchangeGainLoss(const Value: TTravEvent);
begin
  FOnEnterExchangeGainLoss := Value;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnExitAccount(const Value: TTravEvent);
begin
  FOnExitAccount := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnExitEntry(const Value: TTravEvent);
begin
  FOnExitEntry := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetOnSort(const Value: TTravEvent);
begin
  FOnSort := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.TraverseAccount(B: TBank_Account; DateFrom, DateTo: integer);
const
  ThisMethodName = 'TTravManager.TraverseAccount';
Var
   SortKey        : String[33];
   i              : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   FTransactionsTraversed := False;
   
   D1 := DateFrom;
   D2 := DateTo;

   With B do
   Begin
      Bank_Account := B;

      If Assigned(FOnEnterAccount) then FOnEnterAccount(Self);
      If Assigned(FOnEnterAccountExt) then FOnEnterAccountExt(Self);      

      If ( SortMethod = csDateEffective ) then With baTransaction_List do
      Begin (* Don't bother sorting them, they are in index order *)
         For i := 0 to Pred( itemCount ) do
         Begin
            CurrTrans := Transaction_At( i );
            With CurrTrans^ do
            Begin
               If ( txDate_Effective >= DateFrom ) and
                  ( txDate_Effective <= DateTo ) then
               Begin
                  If IsValidSelection(CurrTrans) then
                  begin
                    TraverseEntry;

                    FTransactionsTraversed := True;
                  end;
               end;
            end;
         end;

         FNoTransactions := ItemCount = 0;
      end
      else With baTransaction_List do
      Begin
         If Assigned(FOnBeforeSort) then FOnBeforeSort(Self);

         TransList  := TTravList.Create;
         try
           For i := 0 to Pred( ItemCount ) do
           Begin
              CurrTrans := Transaction_At( i );
              With CurrTrans^ do
              Begin
                if ((FUseDatePresented)     and (CompareDates(txDate_Presented, DateFrom, DateTo)= Within))
                or ((not FUseDatePresented) and (CompareDates(txDate_Effective, DateFrom, DateTo)= Within))
                 then
                 Begin
                    If IsValidSelection(CurrTrans) then
                    Begin
                       If Assigned(FOnSort) then FOnSort(Self);

                       If ( SortMethod in [ csAccountCode, csByGSTRate ] ) and
                          ( Assigned( FOnEnterDissection) or Assigned( FOnEnterDissectionExt)) and
                          ( txFirst_Dissection<>NIL ) then
                       Begin
                          CurrDissect := txFirst_Dissection;
                          While CurrDissect<>NIL do With CurrDissect^ do
                          Begin
                             dsTransaction := CurrTrans;
                             Case SortMethod of
                                csAccountCode :
                                   Begin
                                      SortKey := dsAccount;
                                      if UseXlonSort then
                                        SortKey := FormatCodeForXlonSort(dsAccount);
                                      While Length( SortKey ) < MaxBK5CodeLen Do SortKey := SortKey + ' ';
                                      SortKey := SortKey + LongToKey( txDate_Effective )
                                                         + LongToKey( txSequence_No )
                                                         + LongToKey( dsSequence_No )
                                                         + 'D';
                                   end;

                                csByGSTRate :
                                   Begin
                                      SortKey := ByteToKey( dsGST_Class ) +
                                                 LongToKey( txDate_Effective ) +
                                                 LongToKey( txSequence_No ) +
                                                 LongToKey( dsSequence_No );
                                   end;
                             end; { of Case }

                             if debugme then
                             begin
                                LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName + ' Adding Dissection SortKey' + SortKey);
                             end;

                             TransList.InsertTransItem(CurrDissect, ttDissection, SortKey);

                             CurrDissect := CurrDissect^.dsNext;
                          end;
                       end
                       else
                       Begin
                          SortKey := MakeSortKey(CurrTrans) + ' ';
                          if debugme then
                          begin
                             LogUtil.LogMsg( lmDebug, UnitName, ThisMethodName + ' Adding Transaction SortKey'  + SortKey);
                          end;
                          TransList.InsertTransItem(CurrTrans,ttTransaction,SortKey);
                       end;
                    end; { of SelectMe( Transaction ) }
                 end; { Date Within Range }
              end; { Scope of Transaction^ }
           end; { bcCount }
           If Assigned(FOnAfterSort) then FOnAfterSort(Self);

           FNoTransactions := (TransList.ItemCount = 0);
           For i:=0 to Pred(TransList.ItemCount) do
           Begin
              FIsLastTransaction := (i = Pred(TransList.ItemCount));
              With PTravItem(TransList.At(i))^ do
              Begin
                 case TransType of
                   ttTransaction:
                   Begin
                      CurrTrans := Ptr;
                      TraverseEntry;

                      FTransactionsTraversed := True;
                   end;

                   ttDissection:
                   Begin
                      CurrDissect := Ptr;
                      CurrTrans   := CurrDissect^.dsTransaction;

                      if Assigned(FOnEnterDissection) then
                        FOnEnterDissection(Self);
                      if Assigned(FOnEnterDissectionExt) then
                        FOnEnterDissectionExt(Self);
                   end;
                 end;
              end;
           end;
         finally
           TransList.Free;
         end;
      end;

      if Assigned(FOnEnterExchangeGainLoss) then
      begin
        FOnEnterExchangeGainLoss(Self);
      end;

      Inc(FNumOfAccounts );

      If (Assigned(FOnExitAccount)) then FOnExitAccount(Self);
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TTravManager.TraverseEntry;
const
  ThisMethodName = 'TTravManager.TraverseEntry';
Var
   DissectTotal   : Money;
   Msg            : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   With CurrTrans^, CurrDissect^ do
   Begin

      If Assigned(FOnEnterEntry) then FOnEnterEntry(Self);
      If Assigned(FOnEnterEntryExt) then FOnEnterEntryExt(Self);

      If ( txFirst_Dissection <> nil) and
         (Assigned(FOnEnterDissection) or Assigned(FOnEnterDissectionExt)) then
      Begin
         DissectTotal := 0;
         CurrDissect := txFirst_Dissection;
         While (CurrDissect <> nil) do With CurrDissect^ do
         Begin
            if Assigned(FOnEnterDissection) then
              FOnEnterDissection(Self);
            if Assigned(FOnEnterDissectionExt) then
              FOnEnterDissectionExt(Self);

            DissectTotal := DissectTotal + dsAmount;
            Inc(FNumOfDissect);
            CurrDissect := dsNext;
         end;

         if ( DissectTotal <> txAmount ) then
         Begin
            Msg := ' Total of Dissection Lines does not match the Transaction Total! ';
            LogUtil.LogError( UnitName, ThisMethodName + ' : ' + Msg);
            Raise EDataIntegrity.CreateFmt('%s - %s : %s',
              [UnitName, ThisMethodName, Msg] );
         end;

      end;
      if (Assigned(FOnExitEntry)) then FOnExitEntry(Self);
      if (Assigned(FOnExitEntryExt)) then FOnExitEntryExt(Self);
      Inc( FNumOfEntries );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TTravManager.TraverseAllAccounts(DateFrom, DateTo: integer);
const
  ThisMethodName = 'TTravManager.TraverseAllAccounts';
Var
   i : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   MyClient.UpdateRefs; { Update our reference numbers }

   D1 := DateFrom;
   D2 := DateTo;

   With MyClient.clBank_Account_List do For i := 0 to Pred( ItemCount ) do
     TraverseAccount(Bank_Account_At(i), Datefrom, DateTo );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TTravManager.TraverseAllAccounts(DateFrom, DateTo: integer; AccountTypeSet : TAccountTypeSet);
//this version of the routine only traverses accounts of a specified type
const
  ThisMethodName = 'TTravManager.TraverseAllAccounts';
Var
   i : LongInt;
   ba : TBank_Account;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   MyClient.UpdateRefs; { Update our reference numbers }

   D1 := DateFrom;
   D2 := DateTo;

   with MyClient.clBank_Account_List do begin
     for i := 0 to Pred( ItemCount ) do begin
       ba := Bank_Account_At(i);
       if ba.baFields.baAccount_Type in AccountTypeSet then
         TraverseAccount(Ba, Datefrom, DateTo );
     end;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TTravManager.TraverseAllEntries(DateFrom, DateTo: integer);
const
  ThisMethodName = 'TTravManager.TraverseAllEntries';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   //just call the overloaded procedure with empty account type set
   TraverseAllEntries( DateFrom, DateTo, [] );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.TraverseAllEntries(DateFrom, DateTo: integer; AccountTypeSet: TAccountTypeSet);
//overload version allows you to select account types
const
  ThisMethodName = 'TTravManager.TraverseAllEntriesEx';
Var
   B, T, I     : LongInt;
   SortKey     : String[40];
   Key         : Bk5CodeStr;
   ExchangeGainLossEntries: TExchangeGainLossEntryList;
   GainLossIndex: Integer;
   GainLossEntry: TExchange_Gain_Loss;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   MyClient.UpdateRefs; { Update our reference numbers }

   D1 := DateFrom;
   D2 := DateTo;

   TransList := TTravList.Create;
   try
     With MyClient.clBank_Account_List do For B := 0 to Pred(ItemCount) do
     Begin
        Bank_Account := Bank_Account_At( B );

        if ( AccountTypeSet = [] ) or ( Bank_Account.baFields.baAccount_Type in AccountTypeSet) then
        begin
          With Bank_Account, baFields do
          Begin
             With baTransaction_List do for T := 0 to Pred( ItemCount ) do
             Begin
                CurrTrans := Transaction_At( T );
                With CurrTrans^ do
                   If ( txDate_Effective >= DateFrom) and
                      ( txDate_Effective <= DateTo ) and isValidSelection(CurrTrans) then
                Begin
                   If Assigned(FOnSort) then FOnSort(Self);

                   If ( SortMethod in [ csAccountCode, csByGSTRate ] ) and
                      ( Assigned(FOnEnterDissection) or Assigned(FOnEnterDissectionExt)) and
                      ( Assigned( txFirst_Dissection ) ) then
                   Begin
                      CurrDissect := txFirst_Dissection;
                      While CurrDissect<>NIL do With CurrDissect^ do
                      Begin
                         Case SortMethod of
                            csAccountCode :
                               Begin
                                  Key := dsAccount;
                                  if UseXlonSort then
                                    Key := FormatCodeForXlonSort(dsAccount);
                                  While Length( Key ) < MaxBK5CodeLen Do Key := Key + ' ';
                                  SortKey :=  Key + { !! 42.50 }
                                              LongToKey( txDate_Effective ) +
                                              LongToKey( baNumber ) +
                                              LongToKey( txSequence_No ) +
                                              LongToKey( dsSequence_No );
                               end;

                            csByGSTRate :
                               Begin
                                  SortKey :=  ByteToKey( dsGST_Class ) +
                                              LongToKey( baNumber ) +
                                              LongToKey( txDate_Effective ) +
                                              LongToKey( txSequence_No ) +
                                              LongToKey( dsSequence_No );
                               end;
                         end; { of Case }

                         TransList.InsertTransItem(CurrDissect,ttDissection,SortKey);
                         CurrDissect := dsNext;
                      end;
                   end
                   else
                   Begin
                     SortKey := MakeSortKey(CurrTrans);
                     TransList.InsertTransItem(CurrTrans,ttTransaction,SortKey);
                   end;
                end;
             end;

             ExchangeGainLossEntries := Bank_Account.baExchange_Gain_Loss_List.GetEntriesPostedBetween(DateFrom, DateTo);

             for GainLossIndex := 0 to Length(ExchangeGainLossEntries) - 1 do
             begin
               GainLossEntry := ExchangeGainLossEntries[GainLossIndex];

               GainLossEntry.glFields.glTemp_Bank_Seq := Bank_Account.baFields.baNumber;

               SortKey := MakeGainLossSortKey(GainLossEntry);

               TransList.InsertTransItem(GainLossEntry.As_pRec, ttExchangeGainLoss, SortKey); 
             end;             
          end;
        end;  //if account in selection
     end;

     With TransList do For I := 0 to Pred(itemCount) do
     Begin
        With PTravItem(At(I))^ do
        Begin
           case TransType of
             ttTransaction:
             Begin
                CurrTrans := pTransaction_Rec( Ptr );

                Bank_Account := NIL;
                With MyClient.clBank_Account_List do For B := 0 to Pred(ItemCount) do
                  With Bank_Account_At( B ) do begin
                    If ( baFields.baNumber = CurrTrans^.txBank_Seq) and
                       (( AccountTypeSet = [] ) or ( baFields.baAccount_Type in AccountTypeSet)) then
                    Begin
                      Bank_Account := Bank_Account_At( B );
                      Break;
                    end;
                  end;

                TraverseEntry;
             end;

             ttDissection:
             Begin
                CurrDissect := pDissection_Rec( Ptr );
                CurrTrans   := CurrDissect^.dsTransaction;
                Bank_Account := NIL;
                With MyClient.clBank_Account_List do For B := 0 to Pred( itemCount ) do
                  With Bank_Account_At( B ) do begin
                    If ( baFields.baNumber = CurrTrans^.txBank_Seq) and
                       (( AccountTypeSet = []) or ( baFields.baAccount_Type in AccountTypeSet)) then
                    Begin
                      Bank_Account := Bank_Account_At( B );
                      Break;
                    end;
                  end;

                if Assigned(FOnEnterDissection) then
                  FOnEnterDissection(Self);
                if Assigned(FOnEnterDissectionExt) then
                  FOnEnterDissectionExt(Self);
             end;

             ttExchangeGainLoss:
             begin
               CurrExchangeGainLossEntry := pExchange_Gain_Loss_Rec(Ptr);

               Bank_Account := NIL;
               With MyClient.clBank_Account_List do For B := 0 to Pred( itemCount ) do
                 With Bank_Account_At( B ) do begin
                   If ( baFields.baNumber = CurrExchangeGainLossEntry.glTemp_Bank_Seq ) and
                      (( AccountTypeSet = []) or ( baFields.baAccount_Type in AccountTypeSet)) then
                   Begin
                     Bank_Account := Bank_Account_At( B );
                     Break;
                   end;
                 end;

               if Assigned(FOnEnterExchangeGainLoss) then
               begin
                 FOnEnterExchangeGainLoss(Self);
               end;             
             end;
           end;
        end;
     end;
   finally
      TransList.Free;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetD1(const Value: integer);
begin
  FD1 := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetD2(const Value: integer);
begin
  FD2 := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetLastCodePrinted(const Value: string);
begin
  FLastCodePrinted := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetReverseFieldOrder(const Value: boolean);
begin
  FReverseFieldOrder := Value;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetSortMethod(const Value: byte);
begin
   SortMethod := Value;
   FUseDatePresented := SortMethod = csDatePresented;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTravManager.SetCurrAccount(const Value: TBank_Account);
begin
   FReverseFieldOrder := False;
   CurrAccount := value;
   if Assigned(CurrAccount) then
   Begin
      if MyClient.clFields.clCountry = whNewZealand then
      Begin
         FReverseFieldOrder := GenUtils.ReverseFields( CurrAccount.baFields.baBank_Account_Number );
      end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{procedure TTravManager.SetCodeInfo(const Value: TCalcTotals);
begin
  FCodeInfo := Value;
end;
}
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
  DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
