unit ueList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// list to hold unpresented items
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   bkdefs, baobj32, ecollect, moneyDef, stdate, BkConst;

type
   pUE = ^tUE;
   tUE = Record
      Number      : LongInt;
      Issued      : TStDate;
      Presented   : TStDate;
      Amount      : Money;
      Code        : Bk5CodeStr;
      Ptr         : pTransaction_Rec;
      Sequence    : LongInt;
   end;

   pSeqInfo = ^tSeqInfo;
   tSeqInfo = record
      psNo          : longInt;
      peDate        : longint;
      ppDate        : longint;
      psTransferred : boolean;     //transferred
      psFound       : boolean;
      psPtr         : pTransaction_Rec;
   end;

type
   TUEList = class(TExtdSortedCollection)
      constructor Create; override;
      function Compare(Item1, Item2 : pointer) : integer; override;

   protected
      procedure FreeItem(Item : Pointer); override;

   public
      function UEItem_At(Index : longint) : pUE;
      function FindUEByNumberAndAmount(ANumber : LongInt; AnAmount : Money ): pUE;
      function FindUEByNumber(ANumber : LongInt ): pUE;
      function FindUEByPtr(APtr : pTransaction_Rec ): pUE;
      function FindUEByAmount(AnAmount : Money ): pUE;
   end;

type
   TSeqList = class(TExtdSortedCollection)
      constructor Create; override;
      function Compare(Item1, Item2 : pointer) : integer; override;
   protected
      procedure FreeItem(Item : Pointer); override;
   public
      function SeqInfo_At(Index : longint) : pSeqInfo;
      function FindCheque( ChequeNumber : integer) : pSeqInfo;
   end;

const
   UE_Rec_Size = SizeOf(tUE);
   SI_Rec_Size = Sizeof(tSeqInfo);

function MakeUEList( BA : TBank_Account) : tUEList;
function NewSeqInfo(i : integer) : pSeqInfo;

//******************************************************************************
implementation
uses
   LogUtil, sysutils, math, malloc;

const
   DebugMe : boolean = FALSE;
   UnitName = 'UELIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tUEList.Create;
const
  ThisMethodName = 'tUEList.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tUElist.Compare(Item1, Item2 : pointer) : integer;
const
  ThisMethodName = 'tUEList.Compare';
var
   P1  : pUE absolute Item1;
   P2  : pUE absolute Item2;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   If P1^.Number < P2^.Number then Result := -1 else
   If P1^.Number > P2^.Number then Result := 1 else
   If P1^.Sequence < P2^.Sequence then Result := -1 else
   if P1^.Sequence > P2^.Sequence then Result := 1 else
   Result := 0;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tUEList.UEItem_At(Index : longint) : pUE;
var
  p : pointer;
begin
  P := At(index);
  result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function NewUE : pUE;
const
  ThisMethodName = 'NewUE';
var
  r : pUE;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  SafeGetMem(r,UE_Rec_Size);
  result := r;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TUEList.FreeItem(Item : pointer);
const
  ThisMethodName = 'tUEList.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  SafeFreeMem(Item,UE_Rec_Size);
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TUEList.FindUEByNumber(ANumber : longint) : PUE;
const
  ThisMethodName = 'tUEList.FindUEByNumber';
var
  i : integer;
  p : pUE;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
  result := nil;
  for i := 0 to Pred(ItemCount) do
  begin
    p := UEItem_At(i);
    if p^.Number = ANumber then
    begin
      result := p;
      exit;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TUEList.FindUEByNumberAndAmount(ANumber : LongInt; AnAmount : Money ): pUE;
const
  ThisMethodName = 'tUEList.FindUEByNumberAndAmount';
var
  i : integer;
  p : pUE;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d  $ %f',[ThisMethodName,aNumber, anAmount]));

  result := nil;
  for i := 0 to Pred(ItemCount) do
  begin
    p := UEItem_At(i);
    if (p^.Number = ANumber) and (p^.Amount = AnAmount) then
    begin
      result := p;
      if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
      exit;
    end;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TUEList.FindUEByPtr(APtr : pTransaction_Rec ): pUE;
const
  ThisMethodName = 'tUEList.FindUEByPtr';
var
  i : integer;
  p : pUE;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %p',[ThisMethodName,aPtr]));

  result := nil;
  for i := 0 to Pred(ItemCount) do
  begin
    p := UEItem_At(i);
    if p^.Ptr = APtr then
    begin
      result := p;
      exit;
      if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
    end;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TUEList.FindUEByAmount(AnAmount : Money ): pUE;
const
  ThisMethodName = 'tUEList.FindUEByAmount';
var
  i : integer;
  p : pUE;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %f',[ThisMethodName,AnAmount]));

  result := nil;
  for i := 0 to Pred(ItemCount) do
  begin
    p := UEItem_At(i);
    if p^.Amount = AnAmount then
    begin
      result := p;
      if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
      exit;
    end;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MakeUEList( BA : TBank_Account) : tUEList;
const
  ThisMethodName = 'MakeUEList';
var
  i : integer;
  p : pUE;
  aUEList : tUEList;
  t : pTransaction_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  aUEList := tUEList.Create;
  with aUEList do
    with BA.baTransaction_List do for i:= 0 to pred(itemCount) do
    begin
      t := Transaction_At(i);
      with t^ do if txDate_Presented = 0 then
      begin
         p := NewUE;
         p^.Number       := txCheque_Number;
         p^.Issued       := txDate_Effective;
         p^.Presented    := 0;
         p^.Amount       := txAmount;
         p^.Code         := txAccount;
         p^.Ptr          := t;
         p^.Sequence     := txSequence_No;
         aUEList.Insert(p);
      end;
    end;

  if aUEList.ItemCount = 0 then
  begin
    aUEList.Free;
    aUEList := nil;
  end;
  Result := aUEList;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//-------------- SeqInfo cheque List ------------------
function NewSeqInfo(i : integer) : pSeqInfo;
const
  ThisMethodName = 'NewSeqInfo';
var
  p : pSeqInfo;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  SafeGetMem(p,SI_Rec_Size);
  if p <> nil then
  begin
    FillChar(p^,SI_Rec_Size,#0);
    p^.psNo := i;
  end;
  result := p;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tSeqList.Create;
const
  ThisMethodName = 'tSeqList.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSeqList.Compare(Item1, Item2 : pointer) : integer;
const
  ThisMethodName = 'tSeqList.Create';
var
   P1  : pSeqInfo absolute Item1;
   P2  : pSeqInfo absolute Item2;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if p1^.psNo > p2^.psNo then result := -1 else
   if p1^.psNo < p2^.psNo then result := 1 else
   result := 0;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSeqList.SeqInfo_At(Index : longint) : pSeqInfo;
var
  p : pointer;
begin
  P := At(index);
  result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSeqList.FreeItem(Item : pointer);
const
  ThisMethodName = 'tSeqList.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  SafeFreeMem(Item,SI_Rec_Size);
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSeqList.FindCheque(ChequeNumber: integer): pSeqInfo;
//do a binary search to find the specified cheq
var
  L, H, I, C: Integer;
  pCh       : pSeqInfo;
begin
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then
  begin
     //no items in list
     Exit;
  end;

  repeat
    I := (L + H) shr 1;
    pCh := pSeqInfo(At(i));
    C :=   CompareValue( ChequeNumber, pCH^.psNo);
    if C > 0 then
      L := I + 1
    else
      H := I - 1;
  until (c=0) or (L>H);

  if c=0 then
  begin
     result := pCh;
     Exit;
  end;
end;

initialization
   DebugMe := DebugUnit(UnitName);
end.
