unit ecTransactionListObj;
//------------------------------------------------------------------------------
{
   Title:       Transaction List Object

   Description:

   Remarks:

   Author:      Matthew Hopkins  Aug 01

}
//------------------------------------------------------------------------------

interface
uses
   ecdefs, ecollect, iostream;

type
  TECTransaction_List = class (TExtdSortedCollection)
    lastSeq: Integer;
    constructor Create;
    function  Compare(Item1,Item2 : Pointer): Integer; override;
  protected
    procedure FreeItem(Item : Pointer); override;
  public
    procedure Insert(Item : Pointer); override;
    procedure Insert_Transaction_Rec(var p: pTransaction_Rec);
    procedure LoadFromFile(var S : TIOStream);
    procedure SaveToFile(var S: TIOStream);
    function  Transaction_At(Index : Integer): pTransaction_Rec;
    procedure UpdateCRC(Var CRC : LongWord);
  end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Procedures for appending and deleting transactions and dissections
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure Dispose_Transaction_Rec( P: pTransaction_Rec );
procedure Dump_Dissections( P : pTransaction_Rec );
procedure AppendDissection( Var T : pTransaction_Rec; Var D : pDissection_Rec );

//******************************************************************************
implementation
uses
   malloc,
   ectxio,
   ecdsio,
   EcTokens,
   EcExcept,
   BkDBExcept,
   ecCRC;


const
   SUnknownToken = 'txList Error: Unknown token %d';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Dispose_Dissection_Rec( P : PDissection_Rec );
begin
   If (ECDSIO.IsADissection_Rec( P ) ) then begin
      ECDSIO.Free_Dissection_Rec_Dynamic_Fields( p^);
      MALLOC.SafeFreeMem( P, Dissection_Rec_Size );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Dispose_Transaction_Rec( P: pTransaction_Rec );
Var
   This : pDissection_Rec;
   Next : pDissection_Rec;
begin
   if ( ectxio.IsATransaction_Rec( P ) )  then With P^ do begin
      This := pDissection_Rec( txFirst_Dissection );
      While ( This<>nil ) do begin
         Next := pDissection_Rec( This^.dsNext );
         Dispose_Dissection_Rec( This );
         This := Next;
      end;
      ectxio.Free_Transaction_Rec_Dynamic_Fields( P^);
      MALLOC.SafeFreeMem( P, Transaction_Rec_Size );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure Dump_Dissections( P : pTransaction_Rec );
Var
   This : pDissection_Rec;
   Next : pDissection_Rec;
begin
   if ( ectxio.IsATransaction_Rec( P ) )  then With P^ do begin
      This := pDissection_Rec( txFirst_Dissection );
      While ( This<>nil ) do begin
         Next := pDissection_Rec( This^.dsNext );
         Dispose_Dissection_Rec( This );
         This := Next;
      end;
      P^.txFirst_Dissection := nil;
      P^.txLast_Dissection := nil;
      P^.txAccount := '';
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure AppendDissection( Var T : pTransaction_Rec; Var D : pDissection_Rec );
Var
   Seq : Integer;
begin
   Seq := 0;
   If T^.txLast_Dissection <> nil then Seq := T^.txLast_Dissection^.dsAuto_Sequence_No;
   Inc( Seq );
   With D^ do begin
      dsTransaction  := T;
      dsAuto_Sequence_No  := Seq;
      dsNext         := nil;
   end;
   With T^ do begin
      If ( txFirst_Dissection = nil ) then txFirst_Dissection := D;
      If ( txLast_Dissection <> nil ) then txLast_Dissection^.dsNext := D;
      txLast_Dissection := D;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TECTransaction_List }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECTransaction_List.Compare(Item1, Item2: Pointer): Integer;
var
  p1: pTransaction_Rec Absolute Item1;
  p2: pTransaction_Rec Absolute Item2;
begin
  if p1^.txDate_Effective < p2^.txDate_Effective then result := -1 else
  if p1^.txDate_Effective > p2^.txDate_Effective then result := 1 else
  if p1^.txAuto_Sequence_No    < p2^.txAuto_Sequence_No then result := -1 else
  if p1^.txAuto_Sequence_No    > p2^.txAuto_Sequence_No then result := 1 else
  result := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TECTransaction_List.Create;
begin
  inherited Create;
  Duplicates := false;
  LastSeq := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECTransaction_List.FreeItem(Item: Pointer);
begin
  Dispose_Transaction_Rec( pTransaction_Rec( item ) );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECTransaction_List.Insert(Item: Pointer);
begin
  raise EInvalidCall.Create( 'txList Error: Insert called directly' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECTransaction_List.Insert_Transaction_Rec( var p: pTransaction_Rec);
begin
  If ectxio.IsATransaction_Rec( P ) then Begin
     Inc( LastSeq );
     P^.txAuto_Sequence_No := LastSeq;
     Inherited Insert( P );
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECTransaction_List.LoadFromFile(var S: TIOStream);
var
  Token: Byte;
  pTX: pTransaction_Rec;
  pDS: pDissection_Rec;
begin
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
           Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
     end; { of Case }
     Token := S.ReadToken;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECTransaction_List.SaveToFile(var S: TIOStream);
var
  i: LongInt;
  pTX: pTransaction_Rec;
  pDS: pDissection_Rec;
begin
  S.WriteToken( tkBeginEntries );

  For i := 0 to Pred( ItemCount ) do
  Begin
     pTX := Transaction_At( i );
     ectxio.Write_Transaction_Rec ( pTX^, S );

     pDS := pTX^.txFirst_Dissection;
     While pDS<>NIL do
     Begin
        ecdsio.Write_Dissection_Rec ( pDS^, S );
        pDS := pDS^.dsNext;
     end;
  end;
  S.WriteToken( tkEndSection );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECTransaction_List.Transaction_At( Index: Integer): pTransaction_Rec;
var
  P: Pointer;
begin
  result := nil;
  P := At( Index );
  If EcTxio.IsATransaction_Rec( P ) then
     result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECTransaction_List.UpdateCRC(var CRC: LongWord);
var
  T: Integer;
  Transaction: pTransaction_Rec;
  Dissection: pDissection_Rec;
begin
  For T := 0 to Pred( ItemCount ) do
  Begin
     Transaction := Transaction_At( T );
     ECCRC.UpdateCRC( Transaction^, CRC );
     With Transaction^ do
     Begin
        Dissection := txFirst_Dissection;
        While Dissection<>NIL do With Dissection^ do
        Begin
           ECCRC.UpdateCRC( Dissection^, CRC );
           Dissection := Dissection^.dsNext;
        end;
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
