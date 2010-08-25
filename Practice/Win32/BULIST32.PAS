unit buList32;
// Budget List
INTERFACE
USES
  eCollect, BUDOBJ32, IOSTREAM;

Type
   TBudget_List = class( TExtdSortedCollection )
      CONSTRUCTOR    Create;
      FUNCTION       Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      PROCEDURE      FreeItem( Item : Pointer ); override;
   public
      PROCEDURE      SaveToFile( Var S : TIOStream );
      PROCEDURE      LoadFromFile( Var S : TIOStream );
      FUNCTION       Budget_At( Index : LongInt ): TBudget;
      function       Find_Name( const aName : string) : TBudget;

      procedure      UpdateCRC(var CRC : Longword);
   end;

//******************************************************************************
IMPLEMENTATION

USES
   BKBUIO, TOKENS, LogUtil, sysutils, bkdbExcept,
   BKCRC;

CONST
   UnitName = 'BULIST32';
   DebugMe : Boolean = FALSE;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Constructor TBudget_List.Create;
const
   ThisMethodName = 'TBudget_List.Create';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION TBudget_List.Compare( Item1, Item2 : pointer ) : integer;
const
   ThisMethodName = 'TBudget_List.Compare';
Var
   P1 : TBudget;
   P2 : TBudget;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   p1 := TBudget(Item1);
   p2 := TBudget(Item2);

   If P1.buFields.buStart_Date < P2.buFields.buStart_Date then Compare := -1 else
   If P1.buFields.buStart_Date > P2.buFields.buStart_Date then Compare := 1 else
   If P1.buFields.buName < P2.buFields.buName then Compare := -1 else
   If P1.buFields.buName > P2.buFields.buName then Compare := 1 else
   Compare := 0;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBudget_List.FreeItem( Item : Pointer );
const
   ThisMethodName = 'TBudget_List.FreeItem';
var p : TBudget;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := TBudget( Item );
   If Assigned( P ) then P.Free;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION TBudget_List.Budget_At( Index : LongInt ): TBudget;
Begin
   Budget_At := TBudget( At( Index ) );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBudget_List.SaveToFile( Var S : TIOStream );
const
   ThisMethodName = 'TBudget_List.SaveToFile';
Var
   i  : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   S.WriteToken( tkBeginBudgetList );
   For i := 0 to Pred( ItemCount ) do Budget_At( i ).SaveToFile( S );
   S.WriteToken( tkEndSection );
   If DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format( '%d bank accounts were saved.', [ ItemCount ] ) );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBudget_List.LoadFromFile( Var S : TIOStream );
const
   ThisMethodName = 'TBudget_List.LoadFromFile';
var
   Token    : Byte;
   P        : TBudget;
   Msg      : String;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do Begin
      Case Token of
         tkBegin_Budget_Header :
            Begin
               P := TBudget.Create;
               If not Assigned( P ) then Begin
                  Msg := Format( '%s : Unable to Allocate P', [ThisMethodName] );
                  LogUtil.LogMsg(lmError,UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [UnitName, Msg] );
               end;
               P.LoadFromFile( S );
               Insert( P );
            end;
         else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ThisMethodName, Token] );
            LogUtil.LogMsg(lmError,UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [UnitName, Msg] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBudget_List.UpdateCRC(var CRC: Longword);
var
   i : integer;
begin
   for i := 0 to Pred( itemCount) do
      Budget_At( i).UpdateCRC( CRC);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBudget_List.Find_Name(const aName: string): TBudget;
var
  i : integer;
  Budget : TBudget;
begin
  result := nil;
  for i := 0 to Pred( itemCount) do begin
     Budget := Budget_At(i);
     if Budget.buFields.buName = aName then begin
        result := Budget;
        Exit;
     end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.

