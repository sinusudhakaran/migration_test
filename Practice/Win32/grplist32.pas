unit grplist32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// List of Groups in admin system
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  ECollect, Classes, syDefs, ioStream, sysUtils;

Type
   tSystem_Group_List = class(TExtdSortedCollection)
      constructor Create;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure   FreeItem( Item : Pointer ); override;
   public
      function    Group_At( Index : LongInt ): pGroup_Rec;
      function    FindName( AName : String ): pGroup_Rec;
      function    FindLRN( ALRN : LongInt ):  pGroup_Rec;

      procedure   SaveToFile(var S : TIOStream );
      procedure   LoadFromFile(var S : TIOStream );
   end;

//******************************************************************************
implementation
uses
   SYGRIO, TOKENS, logutil, MALLOC, StStrS, bkdbExcept,
   bk5Except;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'GRPLIST32';

{ tSystem_Group_List }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Group_List.Compare(Item1, Item2: pointer): integer;
begin
  Compare := StStrS.CompStringS( pGroup_Rec(Item1).grName, pGroup_Rec(Item2).grName );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tSystem_Group_List.Create;
const
  ThisMethodName = 'tSystem_Group_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Group_List.FindName(AName: String): pGroup_Rec;
const
  ThisMethodName = 'tSystem_Group_List.FindCode';
var
  L, H, I, C: Integer;
  pGroup    : pGroup_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName,AName]));

  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;      {no items in list}
  repeat
    I := (L + H) shr 1;
    pGroup := pGroup_Rec(At(i));
    C := StStrS.CompStringS( AName, pGroup^.grName);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     result := pGroup;
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
     exit;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Group_List.FindLRN(ALRN: Integer): pGroup_Rec;
const
  ThisMethodName = 'tSystem_Group_List.FindLRN';
var
   I : LongInt;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, aLRN]));
   result := NIL;
   If (itemCount = 0 ) then Exit;

   For I := 0 to Pred( itemCount ) do
      With Group_At( I )^ do
         If grLRN = ALRN then
         Begin
            result := Group_At( I );
            if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
            exit;
         end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Group_List.FreeItem(Item: Pointer);
const
  ThisMethodName = 'tSystem_Group_List.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  SYGRIO.Free_Group_Rec_Dynamic_Fields( pGroup_Rec( Item)^);
  SafeFreeMem( Item, Group_Rec_Size );
  
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Group_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'tSystem_Group_List.LoadFromFile';
Var
   Token       : Byte;
   US          : pGroup_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Group :
            Begin
               SafeGetMem( US, Group_Rec_Size );
               If not Assigned( US ) then
               Begin
                  Msg := Format( '%s : Unable to Allocate US',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
               Read_Group_Rec ( US^, S );
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
procedure tSystem_Group_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'tSystem_Group_List.SaveToFile';
Var
   i        : LongInt;
   US       : pGroup_Rec;
   USCount  : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   USCount := 0;

   S.WriteToken( tkBeginSystem_Group_List );

   For i := 0 to Pred( itemCount ) do
   Begin
      US := pGroup_Rec( At( i ) );
      SYGRIO.Write_Group_Rec ( US^, S );
      Inc( USCount );
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %d group records were saved',[ThisMethodName,USCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Group_List.Group_At(Index: Integer): pGroup_Rec;
const
  ThisMethodName = 'tSystem_Group_List.Group_At';
Var
   P : Pointer;
Begin
   result := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   If SYGRIO.IsAGroup_Rec(p) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
