unit MemTranSortedList;

//------------------------------------------------------------------------------
interface

uses
  classes,
  MONEYDEF,
  eCollect;

type
  //----------------------------------------------------------------------------
  pMemTranSortedListRec = ^TMemTranSortedListRec;
  TMemTranSortedListRec = Packed Record
    SequenceNo : Integer;
    DateEffective : Integer;
    Account : String[ 20 ];
    Amount : Money;
    Statement_Details : AnsiString;
    CodedBy : Byte;
    Reference : string;
    Analysis : string;
    HasPotentialIssue : boolean;
  end;

const
  BLANK_LINE = -1;
  NO_DATA = -2;
  MemTranSortedListRecSize = Sizeof(TMemTranSortedListRec);

type
  //----------------------------------------------------------------------------
  TMemTranSortedList = class(TExtdSortedCollection)
  private
  protected
    function NewItem() : Pointer;
    procedure FreeItem(Item: Pointer); override;
  public
    constructor Create; override;
    function  Compare(Item1, Item2: Pointer) : integer; override;

    procedure AddItem(aSuggMemSortedItem : TMemTranSortedListRec);
    function GetPRec(aIndex: integer): pMemTranSortedListRec;
  end;

//------------------------------------------------------------------------------
implementation

uses
  BKDbExcept,
  LogUtil,
  Math,
  SysUtils,
  MALLOC;

const
  UnitName = 'MemTranSortedList';
  DebugMe: boolean = false;
  SInsufficientMemory = UnitName + ' Error: Out of memory in TSuggMemSortedList.NewItem';

{ TSuggMemSortedList }
//------------------------------------------------------------------------------
function TMemTranSortedList.NewItem: Pointer;
var
  pSuggMem : pMemTranSortedListRec;
Begin
  SafeGetMem( pSuggMem, MemTranSortedListRecSize );

  If Assigned( pSuggMem ) then
    FillChar( pSuggMem^, MemTranSortedListRecSize, 0 )
  else
    Raise EInsufficientMemory.Create( SInsufficientMemory );

  Result := pSuggMem;
end;

//------------------------------------------------------------------------------
procedure TMemTranSortedList.FreeItem(Item: Pointer);
begin
  pMemTranSortedListRec(Item)^.Statement_Details := '';
  pMemTranSortedListRec(Item)^.Reference := '';
  pMemTranSortedListRec(Item)^.Analysis := '';

  SafeFreeMem(Item, MemTranSortedListRecSize);
end;

//------------------------------------------------------------------------------
constructor TMemTranSortedList.Create;
begin
  inherited;

  Duplicates := true;
end;

//------------------------------------------------------------------------------
function TMemTranSortedList.Compare(Item1, Item2: Pointer): integer;
var
  MemTranItem1, MemTranItem2 : TMemTranSortedListRec;
begin
  MemTranItem1 := pMemTranSortedListRec(Item1)^;
  MemTranItem2 := pMemTranSortedListRec(Item2)^;

  if MemTranItem1.HasPotentialIssue > MemTranItem2.HasPotentialIssue then
    Result := 1
  else if MemTranItem1.HasPotentialIssue < MemTranItem2.HasPotentialIssue then
    Result := -1
  else
    Result := 0;

  if Result = 0 then
    Result := -CompareValue(MemTranItem1.DateEffective, MemTranItem2.DateEffective);

  if Result = 0 then
    Result := -CompareValue(MemTranItem1.SequenceNo, MemTranItem2.SequenceNo);
end;

//------------------------------------------------------------------------------
procedure TMemTranSortedList.AddItem(aSuggMemSortedItem : TMemTranSortedListRec);
var
  NewSuggMem : pMemTranSortedListRec;
begin
  NewSuggMem := NewItem;

  NewSuggMem^.SequenceNo        := aSuggMemSortedItem.SequenceNo;
  NewSuggMem^.DateEffective     := aSuggMemSortedItem.DateEffective;
  NewSuggMem^.Account           := aSuggMemSortedItem.Account;
  NewSuggMem^.Amount            := aSuggMemSortedItem.Amount;
  NewSuggMem^.Statement_Details := aSuggMemSortedItem.Statement_Details;
  NewSuggMem^.CodedBy           := aSuggMemSortedItem.CodedBy;
  NewSuggMem^.Reference         := aSuggMemSortedItem.Reference;
  NewSuggMem^.Analysis          := aSuggMemSortedItem.Analysis;
  NewSuggMem^.HasPotentialIssue := aSuggMemSortedItem.HasPotentialIssue;

  Insert(NewSuggMem);
end;

//------------------------------------------------------------------------------
function TMemTranSortedList.GetPRec(aIndex: integer): pMemTranSortedListRec;
begin
  Result := At(aIndex);
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);

end.
