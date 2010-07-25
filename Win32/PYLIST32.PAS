unit pyList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Payee List Object
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   Ecollect, bkdefs, iostream;

type
   TPayee_List_V53 = class(TExtdSortedCollection)   //used by version 5.3 or earlier
      constructor Create;
      function Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure FreeItem( Item : Pointer ); override; 
   public
      function  Payee_At( Index : LongInt ): pPayee_Rec;
      function  Find_Payee_Name( CONST AName: String ): pPayee_Rec;
      procedure LoadFromFile( Var S : TIOStream );

   //functions below not used since bk5.3
      //function  Find_Payee_Number( CONST ANumber: LongInt ): pPayee_Rec;
      //function  Search_Payee_Name( CONST AName : ShortString ): pPayee_Rec;
      //procedure SaveToFile( Var S : TIOStream );
      //procedure UpdateCRC(var CRC : Longword);
   end;

//******************************************************************************
implementation
uses
   BKPYIO, TOKENS, LogUtil, MALLOC, sysutils, StStrS, bkdbExcept,
   bk5Except, bkcrc;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'PYLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Constructor TPayee_List_V53.Create;
const
  ThisMethodName = 'TPayee_List_V53.Create';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TPayee_List_V53.Compare( Item1, Item2 : pointer ) : integer;
Begin
   result := StStrS.CompStringS(pPayee_Rec(Item1)^.pyName,pPayee_Rec(Item2)^.pyName);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TPayee_List_V53.FreeItem( Item : Pointer );
const
  ThisMethodName = 'TPayee_List_V53.FreeItem';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   If BKPYIO.IsAPayee_Rec( Item ) then begin
      BKPYIO.Free_Payee_Rec_Dynamic_Fields( pPayee_Rec( Item)^ );
      SafeFreeMem( Item, Payee_Rec_Size );
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TPayee_List_V53.Payee_At( Index : Longint ) : pPayee_Rec;
const
  ThisMethodName = 'TPayee_List_V53.Payee_At';
Var
   P : Pointer;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := nil;
   P := At( Index );
   If BKPYIO.IsAPayee_Rec( P ) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{procedure TPayee_List_V53.SaveToFile( Var S : TIOStream );
const
  ThisMethodName = 'TPayee_List_V53.SaveToFile';
Var
   i   : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   S.WriteToken( tkBeginPayees );
   For i := 0 to Pred( ItemCount ) do BKPYIO.Write_Payee_Rec( Payee_At( i )^, S );
   S.WriteToken( tkEndSection );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : %d payees were saved',[ThisMethodName, ItemCount]));
end;}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TPayee_List_V53.LoadFromFile( Var S : TIOStream );
const
  ThisMethodName = 'TPayee_List_V53.LoadFromFile';
Var
   Token : Byte;
   pM    : pPayee_Rec;
   msg   : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Payee :
            Begin
               pM := New_Payee_Rec;
               Read_Payee_Rec ( pM^, S );
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
{function TPayee_List_V53.Find_Payee_Number( CONST ANumber: LongInt ): pPayee_Rec;
const
  ThisMethodName = 'TPayee_List_V53.Find_Payee_Number';
Var
   i : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, aNumber]));
   result := NIL;

   For i := 0 to Pred( ItemCount ) do
      If Payee_At( i )^.pyNumber = ANumber then
      Begin
         result := Payee_At( i );
         if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
         exit;
      end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not found',[ThisMethodName]));
end;}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TPayee_List_V53.Find_Payee_Name( CONST AName: String ): pPayee_Rec;
const
  ThisMethodName = 'TPayee_List_V53.Find_Payee_Name';
Var
   i : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName,AName]));
   result := NIL;

   For i := 0 to Pred( ItemCount ) do
      If Payee_At( i )^.pyName = AName then
      Begin
         result := Payee_At( i );
         if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
         exit;
      end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{function TPayee_List_V53.Search_Payee_Name( CONST AName: ShortString ): pPayee_Rec;
const
  ThisMethodName = 'TPayee_List_V53.Search_Payee_Name';
var
   UName : ShortString;

   //- - - - - - - - - - - - - - - - - - - - - - -
   function I_Match( P : pPayee_Rec ): Boolean;
   var
     TempString : ShortString;
   Begin
      TempString := UpperCase(Copy(p^.pyName, 1, Length(UName)));
      Result     := (TempString = Uname);
   end;

Var
   i : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName,aName]));
   UName := UpperCase( AName );
   result := NIL;

   For i := 0 to Pred( ItemCount ) do
      If I_Match( Payee_At( i ) ) then
      Begin
         result := Payee_At( i );
         if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
         exit;
      end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not found',[ThisMethodName]));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TPayee_List_V53.UpdateCRC(var CRC: Longword);
var
   I : integer;
begin
   For I := 0 to Pred( itemCount ) do Begin
      BKCRC.UpdateCRC( Payee_At( i)^, CRC);
   end;
end;}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
  DebugMe := DebugUnit(UnitName);

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
