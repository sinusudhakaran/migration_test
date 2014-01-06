unit ctypelist32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// List of Client Types in admin system
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  ECollect, Classes, syDefs, ioStream, sysUtils;

Type
   tSystem_Client_Type_List = class(TExtdSortedCollection)
      constructor Create; override;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure   FreeItem( Item : Pointer ); override;
   public
      function    Client_Type_At( Index : LongInt ): pClient_Type_Rec;
      function    FindName( AName : String ): pClient_Type_Rec;
      function    FindLRN( ALRN : LongInt ):  pClient_Type_Rec;

      procedure   SaveToFile(var S : TIOStream );
      procedure   LoadFromFile(var S : TIOStream );
   end;

//******************************************************************************
implementation
uses
   SYCTIO, TOKENS, logutil, MALLOC, StStrS, bkdbExcept,
   bk5Except;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'CTYPELIST32';

{ tSystem_Client_Type_List }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Client_Type_List.Compare(Item1, Item2: pointer): integer;
begin
  Compare := StStrS.CompStringS( pClient_Type_Rec(Item1).ctName, pClient_Type_Rec(Item2).ctName );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tSystem_Client_Type_List.Create;
const
  ThisMethodName = 'tSystem_Client_Type_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Client_Type_List.FindName(AName: String): pClient_Type_Rec;
const
  ThisMethodName = 'tSystem_Client_Type_List.FindCode';
var
  L, H, I, C: Integer;
  pClientType : pClient_Type_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName,AName]));

  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;      {no items in list}
  repeat
    I := (L + H) shr 1;
    pClientType := pClient_Type_Rec(At(i));
    C := StStrS.CompStringS( AName, pClientType^.ctName);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     result := pClientType;
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
     exit;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Client_Type_List.FindLRN(ALRN: Integer): pClient_Type_Rec;
const
  ThisMethodName = 'tSystem_Client_Type_List.FindLRN';
var
   I : LongInt;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, aLRN]));
   result := NIL;
   If (itemCount = 0 ) then Exit;

   For I := 0 to Pred( itemCount ) do
      With Client_Type_At( I )^ do
         If ctLRN = ALRN then
         Begin
            result := Client_Type_At( I );
            if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
            exit;
         end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Client_Type_List.FreeItem(Item: Pointer);
const
  ThisMethodName = 'tSystem_Client_Type_List.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  SYCTIO.Free_Client_Type_Rec_Dynamic_Fields( pClient_Type_Rec( Item)^);
  SafeFreeMem( Item, Client_Type_Rec_Size );
  
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Client_Type_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'tSystem_Client_Type_List.LoadFromFile';
Var
   Token       : Byte;
   US          : pClient_Type_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Client_Type :
            Begin
               SafeGetMem( US, Client_Type_Rec_Size );
               If not Assigned( US ) then
               Begin
                  Msg := Format( '%s : Unable to Allocate US',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
               Read_Client_Type_Rec ( US^, S );
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
procedure tSystem_Client_Type_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'tSystem_Client_Type_List.SaveToFile';
Var
   i        : LongInt;
   US       : pClient_Type_Rec;
   USCount  : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   USCount := 0;

   S.WriteToken( tkBeginSystem_Client_Type_List );

   For i := 0 to Pred( itemCount ) do
   Begin
      US := pClient_Type_Rec( At( i ) );
      SYCTIO.Write_Client_Type_Rec ( US^, S );
      Inc( USCount );
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %d groupclient type records were saved',[ThisMethodName,USCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Client_Type_List.Client_Type_At(Index: Integer): pClient_Type_Rec;
const
  ThisMethodName = 'tSystem_Client_Type_List.Client_Type_At';
Var
   P : Pointer;
Begin
   result := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   If SYCTIO.IsAClient_Type_Rec(p) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
