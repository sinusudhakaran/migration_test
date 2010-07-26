unit usrlist32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// List of Users in admin system
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  ECollect, Classes, syDefs, ioStream, sysUtils;

Type
   tSystem_User_List = class(TExtdSortedCollection)
      constructor Create;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure   FreeItem( Item : Pointer ); override;
   public
      function    User_At( Index : LongInt ): pUser_Rec;
      function    FindCode( ACode : String ): pUser_Rec;
      function    FindLRN( ALRN : LongInt ):  pUser_Rec;

      procedure   SaveToFile(var S : TIOStream );
      procedure   LoadFromFile(var S : TIOStream );
   end;

//******************************************************************************
implementation
uses
   SYUSIO, TOKENS, logutil, MALLOC, StStrS, bkdbExcept,
   bk5Except;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'USRLIST32';

{ tSystem_User_List }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_User_List.Compare(Item1, Item2: pointer): integer;
begin
  Compare := StStrS.CompStringS( pUser_Rec(Item1).usCode, pUser_Rec(Item2).usCode );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tSystem_User_List.Create;
const
  ThisMethodName = 'TSystem_User_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_User_List.FindCode(ACode: String): pUser_Rec;
const
  ThisMethodName = 'TSystem_User_List.FindCode';
var
  L, H, I, C: Integer;
  pUser       : pUser_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName,ACode]));

  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;      {no items in list}
  repeat
    I := (L + H) shr 1;
    pUser := pUser_Rec(At(i));
    C := StStrS.CompStringS( ACode, pUser^.usCode);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     result := pUser;
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
     exit;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_User_List.FindLRN(ALRN: Integer): pUser_Rec;
const
  ThisMethodName = 'TSystem_User_List';
var
   I : LongInt;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, aLRN]));
   result := NIL;
   If (itemCount = 0 ) then Exit;

   For I := 0 to Pred( itemCount ) do
      With User_At( I )^ do
         If usLRN = ALRN then
         Begin
            result := User_At( I );
            if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
            exit;
         end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_User_List.FreeItem(Item: Pointer);
const
  ThisMethodName = 'TSystem_User_List.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  SYUSIO.Free_User_Rec_Dynamic_Fields( pUser_Rec( Item)^);
  SafeFreeMem( Item, User_Rec_Size );
  
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_User_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_User_List.LoadFromFile';
Var
   Token       : Byte;
   US          : pUser_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_User :
            Begin
               SafeGetMem( US, User_Rec_Size );
               If not Assigned( US ) then
               Begin
                  Msg := Format( '%s : Unable to Allocate US',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
               Read_User_Rec ( US^, S );
               Insert( US );
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
procedure tSystem_User_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_User_List.SaveToFile';
Var
   i        : LongInt;
   US       : pUser_Rec;
   USCount  : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   USCount := 0;

   S.WriteToken( tkBeginSystem_User_List );

   For i := 0 to Pred( itemCount ) do
   Begin
      US := pUser_Rec( At( i ) );
      SYUSIO.Write_User_Rec ( US^, S );
      Inc( USCount );
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %d user records were saved',[ThisMethodName,USCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_User_List.User_At(Index: Integer): pUser_Rec;
const
  ThisMethodName = 'TSystem_User_List.User_At';
Var
   P : Pointer;
Begin
   result := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   If SYUSIO.IsAUser_Rec(p) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
