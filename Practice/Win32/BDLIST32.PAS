unit bdList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// budget detail lines list
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE USES BKDEFS, ecollect, IOSTREAM;

Type
   TBudget_Detail_List = class(TExtdSortedCollection)
      CONSTRUCTOR    Create; override;
      FUNCTION       Compare( Item1, Item2 : pointer ) : integer; override;
   protected
   public
      PROCEDURE      FreeItem( Item : Pointer ); override;
      PROCEDURE      SaveToFile( Var S : TIOStream );
      PROCEDURE      LoadFromFile( Var S : TIOStream );
      FUNCTION       Budget_Detail_At( Index : LongInt ): pBudget_Detail_Rec;
      function       FindLineByCode( ACode : String ): pBudget_Detail_Rec;

      procedure      UpdateCRC(var CRC : LongWord);
   end;

//******************************************************************************
IMPLEMENTATION
USES
   BKBDIO, TOKENS, LogUtil, MALLOC, sysutils, StStrS, bkdbExcept,
   bk5Except, bkCRC;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'BDLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Constructor TBudget_Detail_List.Create;
const
  ThisMethodName = 'TBudget_Detail_List.Create';
Begin                   { Sorted, AllowDups }
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION TBudget_Detail_List.Compare( Item1, Item2 : pointer ) : integer;
Begin
   result := StStrS.CompStringS(pBudget_Detail_rec(Item1)^.bdAccount_Code, pBudget_Detail_Rec(Item2)^.bdAccount_Code);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBudget_Detail_List.FreeItem( Item : Pointer );
const
  ThisMethodName = 'TBudget_Detail_List.FreeItem';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if BKBDIO.IsABudget_Detail_Rec( Item ) then begin
      BKBDIO.Free_Budget_Detail_Rec_Dynamic_Fields( pBudget_Detail_Rec( Item)^ );
      SafeFreeMem( Item, Budget_Detail_Rec_Size );
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
FUNCTION TBudget_Detail_List.Budget_Detail_At( Index : LongInt ): pBudget_Detail_Rec;
const
  ThisMethodName = 'TBudget_Detail_List.Budget_Detail_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   If BKBDIO.IsABudget_Detail_Rec( P ) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBudget_Detail_List.SaveToFile( Var S : TIOStream );
const
  ThisMethodName = 'TBudget_Detail_List.SaveToFile';
Var
   i        : LongInt;
   pBD      : pBudget_Detail_Rec;

   function SaveMe: Boolean;
   var Period   : Integer;
   begin
      Result := True;
      for Period := 1 to 12 do begin
        if pBD^.bdBudget[Period] <> 0 then
           Exit;
        if pBD^.bdQty_Budget[Period] <> 0 then
           Exit;
      end;
      Result := False
   end;


Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   S.WriteToken( tkBeginBudget );

   For i := 0 to Pred( itemCount ) do
   Begin
      pBD := pBudget_Detail_Rec( At( i ) );
      If SaveMe then
         Write_Budget_Detail_Rec ( pBD^, S );
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROCEDURE TBudget_Detail_List.LoadFromFile( Var S : TIOStream );
const
  ThisMethodName = 'TBudget_Detail_List.LoadFromFile';
Var
   Token       : Byte;
   pBD         : pBudget_Detail_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Budget_Detail :
            Begin
               pBD := New_Budget_Detail_Rec;

               Read_Budget_Detail_Rec ( pBD^, S );
               Insert( pBD );
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
function TBudget_Detail_List.FindLineByCode(ACode: String): pBudget_Detail_Rec;
const
  ThisMethodName = 'TBudget_Detail_List.FindLineByCode';
var
  L, H, I, C: Integer;
  pBD       : pBudget_Detail_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName, aCode]));
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : No Items',[ThisMethodName]));
    exit;
  end;

  repeat
    I := (L + H) shr 1;
    pBD := pBudget_Detail_Rec(At(i));
    C := STStrS.CompStringS(ACode, pBD.bdAccount_Code);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     result := pBD;
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
     exit;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBudget_Detail_List.UpdateCRC(var CRC: LongWord);
var
   i : integer;
begin
   for i := 0 to Pred( itemcount) do
      BKCRC.UpdateCRC( Budget_Detail_At( i)^, CRC);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
  DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
