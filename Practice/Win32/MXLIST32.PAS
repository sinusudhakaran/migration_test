unit mxList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// list object for holding memorised entries in the client file
// object is included as part of the bank account
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   bkdefs, ecollect, iostream;

type
   TMemorised_Transaction_List_V53 = class(TExtdSortedCollection)
      mxFirst               : Array[0..255] of pMemorised_Transaction_Rec;
      mxLast                : Array[0..255] of pMemorised_Transaction_Rec;
      LastSeq               : integer;

      constructor Create; override;
      function Compare(Item1,Item2 : Pointer): Integer; override;
   protected
      procedure FreeItem(Item : Pointer); override;
   private
      procedure Resequence;
   public
      procedure Insert(Item:Pointer); override;
      procedure Insert_Memorised_Transaction_Rec(var m : pMemorised_Transaction_rec);
      function  Memorised_Transaction_At(Index : longint) : pMemorised_Transaction_rec;
      procedure SwapItems(m1 : pMemorised_Transaction_Rec; m2: pMemorised_Transaction_Rec);

      procedure LoadFromFile(var S : TIOStream);
      procedure SaveToFile(var S: TIOStream);
      procedure UpdateLinks;
      procedure DumpMasters;


      procedure UpdateCRC( var CRC : Longword);
      function  GetCurrentCRC : LongWord;
   end;

//******************************************************************************
implementation
uses
   bkmxio, tokens, LogUtil, malloc, sysUtils, bkcrc,
   bkdbExcept,
   bk5Except;

const
   DebugMe : boolean = false;
   UnitName = 'MXLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TMemorised_Transaction_List_V53.Create;
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   LastSeq := 0;

   FillChar(mxFirst,Sizeof(mxFirst),0);
   FillChar(mxLast,Sizeof(mxLast),0);
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.FreeItem(Item: Pointer);
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.FreeItem';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   BKMXIO.Free_Memorised_Transaction_Rec_Dynamic_Fields( pMemorised_Transaction_Rec( Item)^ );
   malloc.SafeFreeMem(Item, Memorised_transaction_rec_size);

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' End' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.Insert( Item : pointer );
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.Insert';
var
   Msg : string;
begin
   Msg := Format( '%s : Called Direct', [ ThisMethodName] );
   LogUtil.LogMsg(lmError, UnitName, Msg );
   raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMemorised_Transaction_List_V53.Memorised_Transaction_At( Index : Longint ) : pMemorised_Transaction_Rec;
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.Memorised_Transaction_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   If BKMXIO.IsAMemorised_Transaction_Rec( P ) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.SaveToFile( Var S : TIOStream );
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.SaveToFile';
Var
   i   : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   S.WriteToken( tkBeginMemorisedEntries );
   For i := 0 to Pred( ItemCount ) do
      BKMXIO.Write_Memorised_Transaction_Rec ( Memorised_Transaction_At( i )^, S );
   S.WriteToken( tkEndSection );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : %d memorised transactions saved',[ThisMethodName,itemcount]));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.LoadFromFile( Var S : TIOStream );
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.LoadFromFile';
Var
   Token       : Byte;
   pMX         : pMemorised_Transaction_Rec;
   msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Memorised_Transaction :
            Begin
               pMX := New_Memorised_Transaction_Rec;

               Read_Memorised_Transaction_Rec ( pMX^, S );
               Insert_Memorised_Transaction_Rec( pMX );
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

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMemorised_Transaction_List_V53.Compare( Item1, Item2 : pointer ) : integer;
Begin
   // We want to put the master MX at the start of the list so they get accessed last

   If pMemorised_Transaction_Rec(Item1)^.mxFrom_Master_List and not ( pMemorised_Transaction_Rec(Item2)^.mxFrom_Master_List ) then Compare := -1 else
   If pMemorised_Transaction_Rec(Item2)^.mxFrom_Master_List and not ( pMemorised_Transaction_Rec(Item1)^.mxFrom_Master_List ) then Compare := 1 else
   If pMemorised_Transaction_Rec(Item1)^.mxSequence_No < pMemorised_Transaction_Rec(Item2)^.mxSequence_No then Compare := -1 else
   If pMemorised_Transaction_Rec(Item1)^.mxSequence_No > pMemorised_Transaction_Rec(Item2)^.mxSequence_No then Compare := 1 else
   Compare := 0;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.Insert_Memorised_Transaction_Rec( Var M : pMemorised_Transaction_Rec );
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.Insert_Memorised_Transaction_Rec';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   If BKMXIO.IsAMemorised_Transaction_Rec( M ) then
   Begin
      Inc( LastSeq );
      M^.mxSequence_No := LastSeq;
      Inherited Insert( M );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.UpdateLinks;
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.UpdateLinks';
Var
   i : LongInt;
   pMX : pMemorised_Transaction_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   FillChar( mxFirst, Sizeof( mxFirst ), 0 );
   FillChar( mxLast, Sizeof( mxLast ), 0 );

   For i := Pred( ItemCount ) downto 0 do
   Begin
      pMX := pMemorised_Transaction_Rec( At( i ) );
      With pMX^ do
      Begin
         mxNext := NIL;
         If mxFirst[ mxType ] = NIL then mxFirst[ mxType ] := pMX;

         If mxLast[ mxType ]<>NIL then
            mxLast[ mxType ]^.mxNext := pMX;

         mxLast[ mxType ] := pMX;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.Resequence;
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.Resequence';
var
  i :integer;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  for i := 1 to ItemCount do
    pMemorised_Transaction_Rec(At(i-1))^.mxSequence_No := i;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.SwapItems(m1,
  m2: pMemorised_Transaction_Rec);
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.SwapItems';
var
  AtIndex : integer;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if m1.mxSequence_No  < m2.mxSequence_No then
   begin
     Delete(m2);
     AtIndex := IndexOf(m1);
     AtInsert(AtIndex,m2);
     Resequence;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.DumpMasters;
//remove any memorisations that were copied from the Master Memorisations
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.DumpMasters';
var
   i   : LongInt;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   For i := Pred( itemCount ) downto 0 do
      With Memorised_Transaction_At( i )^ do
         If mxFrom_Master_List then AtFree( i );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMemorised_Transaction_List_V53.GetCurrentCRC: LongWord;
//returns a crc value for the memorised entries list
const
  ThisMethodName = 'TMemorised_Transaction_List_V53.GetCurrentCRC';
var
  CRC   : LongWord;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  CRC := 0;
  UpdateCRC( CRC);
  result := CRC;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TMemorised_Transaction_List_V53.UpdateCRC(var CRC: Longword);
var
  i     : integer;
begin
  For I := 0 to Pred( ItemCount ) do
     BKCRC.UpdateCRC( Memorised_Transaction_At( I )^, CRC);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
