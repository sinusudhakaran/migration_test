unit malist32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//List of macros
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses ecollect, IOSTREAM, BKDEFS;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Type
   TMacro_List = Class ( TExtdSortedCollection )
      CONSTRUCTOR    Create;
      FUNCTION       Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      PROCEDURE      FreeItem( Item : Pointer ); override;
   public
      FUNCTION       Macro_At( Index : LongInt ) : pMacro_Rec;
      function       FindCode( ACode : String ): pMacro_Rec;
      function       FindDesc( ACode, ADefault : string ): String;

      PROCEDURE      SaveToFile( Var S : TIOStream );
      PROCEDURE      LoadFromFile( Var S : TIOStream );

      procedure      UpdateCRC(var CRC : LongWord);
   end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
uses BKMAIO, TOKENS, LogUtil, MALLOC, sysutils, StStrS, bkdbExcept,
   bk5Except, bkCRC;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'MALIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Constructor TMacro_List.Create;
const
  ThisMethodName = 'TMacro_List.Create';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION TMacro_List.Compare( Item1, Item2 : pointer ) : integer;
Begin
   result := StStrS.CompStringS(pMacro_Rec(Item1)^.maCode,pMacro_Rec(Item2)^.maCode);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PROCEDURE TMacro_List.FreeItem( Item : Pointer );
const
  ThisMethodName = 'TMacro_List.FreeItem';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   If BKMAIO.IsAMacro_Rec( Item ) then begin
      BKMAIO.Free_Macro_Rec_Dynamic_Fields( pMacro_Rec( Item)^ );
      SafeFreeMem( Item, Macro_Rec_Size );
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

FUNCTION TMacro_List.Macro_At( Index : Longint ) : pMacro_Rec;
const
  ThisMethodName = 'TMacro_List.Macro_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   If BKMAIO.IsAMacro_Rec( P ) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PROCEDURE TMacro_List.SaveToFile( Var S : TIOStream );
const
  ThisMethodName = 'TMacro_List.SaveToFile';
Var
   i   : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   S.WriteToken( tkBeginMacros );

   For i := 0 to Pred(ItemCount ) do BKMAIO.Write_Macro_Rec( Macro_At( i )^, S );

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : %d macros saved',[ThisMethodName, Itemcount]));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

PROCEDURE TMacro_List.LoadFromFile( Var S : TIOStream );
const
  ThisMethodName = 'TMacro_List.LoadFromFile';
Var
   Token : Byte;
   pM    : pMacro_Rec;
   msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Macro :
            Begin
               pM := New_Macro_Rec;

               Read_Macro_Rec ( pM^, S );
               Insert( pM );
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

function TMacro_List.FindCode( ACode : String ): pMacro_Rec;
const
  ThisMethodName = 'TMacro_List.FindCode';
var
  L, H, I, C: Integer;
  pM : pMacro_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   L := 0;
   H := ItemCount - 1;
   if L>H then Exit;
   repeat
      I  := (L + H) shr 1;
      pM := pMacro_Rec(At(i));
      C := STStrS.CompStringS( ACode, pM^.maCode);
      if C > 0 then L := I + 1 else H := I - 1;
   until ( C=0 ) or ( L>H );
   
   if c=0 then begin
      result := pM;
      Exit;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TMacro_List.FindDesc( ACode, ADefault : string ): String;
const
  ThisMethodName = 'TMacro_List.FindDesc';
Var
  pM : pMacro_Rec;  
  
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   pM := FindCode( ACode );
   if Assigned( pM ) then
      Result := pM^.maDescription
   else
      Result := ADefault;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TMacro_List.UpdateCRC(var CRC: LongWord);
var
   i : integer;
begin
   For I := 0 to Pred( itemCount ) do
      BKCRC.UpdateCRC( Macro_At( I )^, CRC);
end;

initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

