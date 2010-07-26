unit CheqCollectionObj;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// List Object holding Cheque Records consisting of ChequeNo.
// This object is used by the Historical Data Entry form for checking for duplicatesin
// existing cheque Nos when entering new cheque number into a transaction.
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
uses
   ECollect,
   SysUtils,
   Classes,
   StStrL;

//Record type used to store the ChequeNo.
type
   TCheque = record
      ChequeNo : LongInt;
   end;
   pCheque = ^TCheque;

type
   TChequesList = class(TExtdSortedCollection)
      constructor Create;
      function Compare(Item1, Item2 : pointer) : integer; override;
   private
      function ChqCompare(aChequeNo: integer; Item2: pointer): integer;
   protected
      procedure FreeItem(Item : Pointer); override;
   public
      function  Cheque_At(Index : integer) : pCheque;
      procedure InsChequeRec(aChequeNo: Integer);
      function  FindCheque( aChequeNo : integer) : pCheque;
      function  ChequeIsThere( aChequeNo : integer) : boolean;
   end;

function New_Cheque_Rec : pCheque;

implementation

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TChequesList.Create;
begin
   inherited Create;
   Duplicates := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChequesList.Compare(Item1, Item2 : pointer) : integer;
var
   P1  : pCheque absolute Item1;
   P2  : pCheque absolute Item2;
Begin
   If P1^.ChequeNo < P2^.ChequeNo then Result := -1 else
   If P1^.ChequeNo > P2^.ChequeNo then Result := 1 else
   Result := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChequesList.ChqCompare( aChequeNo : integer; Item2 : pointer) : integer;
begin
   if aChequeNo < pCheque( Item2)^.ChequeNo then result := -1 else
   if aChequeNo > pCheque( Item2)^.ChequeNo then result := 1 else
   result := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TChequesList.FreeItem(Item: Pointer);
begin
   FreeMem( Item, SizeOf( TCheque ));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TChequesList.InsChequeRec(aChequeNo : LongInt);
// Insert a new cheque
var
   p : pCheque;
begin
   p := New_Cheque_Rec;
   with p^ do begin
      ChequeNo := aChequeNo;
   end;
   Self.Insert(p);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChequesList.Cheque_At(Index: integer): pCheque;
begin
   result := At(Index);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function New_Cheque_Rec : pCheque;
var
   p : pCheque;
begin
   GetMem( p, SizeOf( TCheque));
   result := p;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChequesList.ChequeIsThere(aChequeNo: integer): boolean;
begin
   result := FindCheque( aChequeNo ) <> nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChequesList.FindCheque(aChequeNo: integer): pCheque;
//binary search to find cheque no
var
  L, H, I, C: Integer;
  pCh       : pCheque;
begin
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin {no items in list}
     Exit;
  end;
  repeat
    I := (L + H) shr 1;
    pCh := Cheque_At(i);
    C := ChqCompare( aChequeNo, pCh);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     result := pCh;
     Exit;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
