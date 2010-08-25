unit trxList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Transaction List Object
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   classes, bkdefs, ecollect, iostream;

type
   TTransaction_List = class(TExtdSortedCollection)
      lastSeq : integer;

 //     constructor Create; Overload;
      Constructor Create( AClient, ABank_Account : TObject ); // Overload;
      function Compare(Item1,Item2 : Pointer): Integer; override;
   protected
      procedure FreeItem(Item : Pointer); override;
   private
   public
      fClient       : TObject;
      fBank_Account : TObject;
      procedure Insert(Item:Pointer); override;
      procedure Insert_Transaction_Rec(var p: pTransaction_Rec);
      procedure LoadFromFile(var S : TIOStream);
      procedure SaveToFile(var S: TIOStream);
      function  Transaction_At(Index : longint) : pTransaction_Rec;
      function  FindTransactionFromECodingUID( UID : integer) : pTransaction_Rec;
      function  FindTransactionFromMatchId(UID: integer): pTransaction_Rec;
      function New_Transaction : pTransaction_Rec;

      function  FirstPresDate : LongInt;
      function  LastPresDate : LongInt;

      procedure UpdateCRC(var CRC : Longword);
   end;

   procedure Dispose_Transaction_Rec(p: pTransaction_Rec);
   procedure Dump_Dissections(var p : pTransaction_Rec);
   procedure AppendDissection( T : pTransaction_Rec; D : pDissection_Rec );

//******************************************************************************
implementation
uses
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
   bkconst;

const
   DebugMe : boolean = false;
   UnitName = 'TRXLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Dispose_Dissection_Rec(p : PDissection_Rec);
const
  ThisMethodName = 'Dispose_Dissection_Rec';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   If (BKDSIO.IsADissection_Rec( P ) )  then begin
      BKDSIO.Free_Dissection_Rec_Dynamic_Fields( p^);
      MALLOC.SafeFreeMem( P, Dissection_Rec_Size );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Dump_Dissections(var p : pTransaction_Rec);
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
         Dispose_Dissection_Rec( This );
         This := Next;
      end;
      P^.txFirst_Dissection := NIL;
      P^.txLast_Dissection := NIL;
      P^.txAccount := '';
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure AppendDissection( T : pTransaction_Rec; D : pDissection_Rec );

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
   end;
   With T^ do
   Begin
      If ( txFirst_Dissection = NIL ) then txFirst_Dissection := D;
      If ( txLast_Dissection<>NIL ) then txLast_Dissection^.dsNext := D;
      txLast_Dissection := D;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(*
constructor TTransaction_List.Create;
const
  ThisMethodName = 'TTransaction_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   LastSeq := 0;
   fClient := NIL;
   fBank_Account := NIL;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
*)
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TTransaction_List.Compare(Item1, Item2 : pointer): integer;
begin
    if pTransaction_Rec(Item1)^.txDate_Effective < pTransaction_Rec(Item2)^.txDate_Effective then result := -1 else
    if pTransaction_Rec(Item1)^.txDate_Effective > pTransaction_Rec(Item2)^.txDate_Effective then result := 1 else
    if pTransaction_Rec(Item1)^.txSequence_No    < pTransaction_Rec(Item2)^.txSequence_No then result := -1 else
    if pTransaction_Rec(Item1)^.txSequence_No    > pTransaction_Rec(Item2)^.txSequence_No then result := 1 else
    result := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTransaction_List.FreeItem(Item : Pointer);
//Dispose Transaction has debug and error handling
begin
   Dispose_Transaction_Rec(pTransaction_Rec(item));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTransaction_List.Insert_Transaction_Rec(var p: pTransaction_Rec);
const
  ThisMethodName = 'TTransaction_List.Insert_Transaction_Rec';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   If BKTXIO.IsATransaction_Rec( P ) then
   Begin
      Inc( LastSeq );
      P^.txSequence_No  := LastSeq;
      P^.txBank_Account := fBank_Account;
      P^.txClient       := fClient;
      Inherited Insert( P );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TTransaction_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TTransaction_List.SaveToFile';
Var
   i   : LongInt;
   pTX : pTransaction_Rec;
   pDS : pDissection_Rec;
   TXCount  : LongInt;
   DSCount  : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   TXCount := 0;
   DSCount := 0;

   S.WriteToken( tkBeginEntries );

   For i := 0 to Pred( ItemCount ) do
   Begin
      pTX := Transaction_At( i );
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

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %d transactions %d dissection saved',[ThisMethodName, txCount, dsCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TTransaction_List.Create(AClient, ABank_Account: TObject);
begin
  inherited Create;
  Duplicates := false;
  LastSeq := 0;
  fClient := AClient;
  fBank_Account := ABank_Account;
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

initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
