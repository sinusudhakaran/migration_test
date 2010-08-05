unit ChequeListObj;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// list to hold unpresented items
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   ecdefs, ecBankAccountObj, ecollect, moneyDef;

type
   pChequeInfo = ^tChequeInfo;
   tChequeInfo = record
      psNo          : longInt;
      peDate        : longint;
      ppDate        : longint;
      psTransferred : boolean;     //transferred
      psPtr         : pTransaction_Rec;
   end;

type
   TChequeList = class(TExtdSortedCollection)
      constructor Create;
      function Compare(Item1, Item2 : pointer) : integer; override;
   protected
      procedure FreeItem(Item : Pointer); override;
   public
      function ChequeInfo_At(Index : longint) : pChequeInfo;
   end;


const
   SI_Rec_Size = Sizeof(tChequeInfo);

procedure FindMatchingCheques( BA : TECBank_Account; ChqList : TChequeList );
function  NewChequeInfo(i : integer) : pChequeInfo;
//******************************************************************************
implementation
uses
   sysutils,
   malloc;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function NewChequeInfo(i : integer) : pChequeInfo;
var
  p : pChequeInfo;
begin
  SafeGetMem(p,SI_Rec_Size);
  if p <> nil then
  begin
    FillChar(p^,SI_Rec_Size,#0);
    p^.psNo := i;
  end;
  result := p;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TChequeList.Create;
begin
   inherited Create;
   Duplicates := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChequeList.Compare(Item1, Item2 : pointer) : integer;
var
   P1  : pChequeInfo absolute Item1;
   P2  : pChequeInfo absolute Item2;
Begin
   if p1^.psNo > p2^.psNo then result := -1 else
   if p1^.psNo < p2^.psNo then result := 1 else
   result := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TChequeList.ChequeInfo_At(Index : longint) : pChequeInfo;
var
  p : pointer;
begin
  P := At(index);
  result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TChequeList.FreeItem(Item : pointer);
begin
  SafeFreeMem(Item,SI_Rec_Size);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure FindMatchingCheques( BA : TECBank_Account; ChqList : TChequeList );
//Searchs all transaction in account for transactions with a cheque no
//called by AddUnpresented and AddInitial
Var
   i        : LongInt;
   T        : LongInt;
   Number   : LongInt;
   PSI      : pChequeInfo;
   Transaction : pTransaction_rec;
Begin
   With BA.baTransaction_List do For T := 0 to Pred( itemCount ) do Begin
      Transaction := Transaction_At( T );
      Number := Transaction.txCheque_Number;

      If Number > 0 then With Transaction^ do Begin
         For i := 0 to Pred( ChqList.ItemCount ) do Begin
            PSI := ChqList.ChequeInfo_At(i);
            With PSI^ do If ( psNo = Number ) then Begin
               If ( psPTR = NIL ) then begin{ we haven't found this already }
                  peDate         := txDate_Effective;
                  ppDate         := txDate_Presented;
                  psPTR          := Transaction;
               end;
            end; //with PSI^
         end;
      end;
   end; //with BA.baTransac...
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
