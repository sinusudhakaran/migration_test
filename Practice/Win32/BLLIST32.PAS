unit blList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//balances list file
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

INTERFACE USES eCollect, IOSTREAM, BKDEFS;

Type
   tBalances_List = class(TExtdSortedCollection)
      CONSTRUCTOR    Create;
      FUNCTION       Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      PROCEDURE      FreeItem( Item : Pointer ); override;
   public
      FUNCTION       Balances_At( Index : LongInt ) : pBalances_Rec;
      PROCEDURE      SaveToFile( Var S : TIOStream );
      PROCEDURE      LoadFromFile( Var S : TIOStream );

      procedure      UpdateCRC(var CRC : LongWord);
   end;

//******************************************************************************
IMPLEMENTATION
USES
   BKBLIO, TOKENS, LogUtil, MALLOC, SysUtils, bkdbExcept,
   bk5Except, bkcrc, bkfsio;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'BLLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Constructor TBalances_List.Create;
const
  ThisMethodName = 'TBalances_List.Create';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION TBalances_List.Compare( Item1, Item2 : pointer ) : integer;
Var
   P1 : pBalances_Rec;
   P2 : pBalances_Rec;
Begin
   P1 := pBalances_Rec(Item1);
   P2 := pBalances_Rec(Item2);

   If P1^.blGST_Period_Starts < P2^.blGST_Period_Starts then Compare := -1 else
   If P1^.blGST_Period_Starts > P2^.blGST_Period_Starts then Compare := 1 else
   If P1^.blGST_Period_Ends < P2^.blGST_Period_Ends then Compare := -1 else
   If P1^.blGST_Period_Ends > P2^.blGST_Period_Ends then Compare := 1 else
   Compare := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBalances_List.FreeItem( Item : Pointer );
const
  ThisMethodName = 'TBalances_List.FreeItem';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   BKBLIO.Free_Balances_Rec_Dynamic_Fields( pBalances_Rec( Item)^ );
   SafeFreeMem( Item, Balances_Rec_Size );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION TBalances_List.Balances_At( Index : Longint ) : pBalances_Rec;
const
  ThisMethodName = 'TBalances_List.Balances_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   If BKBLIO.IsABalances_Rec( P ) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBalances_List.SaveToFile( Var S : TIOStream );
const
  ThisMethodName = '';
Var
   i   : LongInt;
   p   : pFuel_Sheet_Rec;
   b   : pBalances_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   S.WriteToken( tkBeginBalancesList );

   For i := 0 to Pred( ItemCount ) do
   begin
     b := Balances_At( i );
     BKBLIO.Write_Balances_Rec( b^, S );
     p := b.blFirst_Fuel_Sheet;
     while Assigned(p) do
     begin
       BKFSIO.Write_Fuel_Sheet_Rec(p^, S);
       p := p.fsNext;
     end;
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s :%d balance records saved',[ThisMethodName,ItemCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBalances_List.LoadFromFile( Var S : TIOStream );
const
  ThisMethodName = 'TBalances_List.LoadFromFile';
Var
   Token : Byte;
   pM    : pBalances_Rec;
   pF    : pFuel_Sheet_Rec;
   msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   pM := nil;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Balances :
            Begin
               pM := New_Balances_Rec;

               Read_Balances_Rec ( pM^, S );
               Insert( pM );
            end;
         tkBegin_Fuel_Sheet :
            Begin
              pF := New_Fuel_Sheet_Rec;

              Read_Fuel_Sheet_Rec ( pF^, S );
              pF.fsNext := nil;
              if not Assigned(pM.blFirst_Fuel_Sheet) then
                pM.blFirst_Fuel_Sheet := pF
              else
                pM.blLast_Fuel_Sheet.fsNext := pF;
              pM.blLast_Fuel_Sheet := pF;
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
procedure tBalances_List.UpdateCRC(var CRC: LongWord);
var
   i : integer;
begin
   for i := 0 to Pred( itemCount) do
      BKCRC.UpdateCRC( Balances_At(i)^, CRC);
end;

initialization
  DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.


