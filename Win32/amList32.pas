unit amList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// List of account client mapping
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  ECollect, Classes, syDefs, ioStream, sysUtils;

Type
   TSystem_Client_Account_Map = class(TExtdSortedCollection)
      CurrentRecord: LongInt;
      constructor Create;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure   FreeItem( Item : Pointer ); override;
   public
      function    Client_Account_Map_At( Index : LongInt ): pClient_Account_Map_Rec;
      function    FindLRN( ALRN, CLRN : LongInt ): pClient_Account_Map_Rec;
      function    FindIndexOf(ALRN, CLRN: LongInt): Integer;
      function    FindFirstClient(ALRN: LongInt): pClient_Account_Map_Rec;
      function    FindNextClient(ALRN: LongInt): pClient_Account_Map_Rec;
      procedure   FindEnd;
      procedure   SaveToFile(var S : TIOStream );
      procedure   LoadFromFile(var S : TIOStream );
   end;

//******************************************************************************
implementation
uses
   SYAMIO, TOKENS, logutil, MALLOC, StStrS, bkdbExcept, bk5Except;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'AMLIST32';

{ tSystem_Client_Account_Map }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Client_Account_Map.Compare(Item1, Item2: pointer): integer;
var
  a1, a2, c1, c2: Integer;
begin
  a1 := pClient_Account_Map_Rec(Item1).amAccount_LRN;
  a2 := pClient_Account_Map_Rec(Item2).amAccount_LRN;
  c1 := pClient_Account_Map_Rec(Item1).amClient_LRN;
  c2 := pClient_Account_Map_Rec(Item2).amClient_LRN;
  if a1 < a2 then
    Compare := -1
  else if (a1 = a2) and (c1 = c2) then
    Compare := 0
  else // a1 > a2
    Compare := 1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TSystem_Client_Account_Map.Create;
const
  ThisMethodName = 'TSystem_Client_Account_Map.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   CurrentRecord := -1;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Client_Account_Map.FindLRN(ALRN, CLRN: LongInt): pClient_Account_Map_Rec;
const
  ThisMethodName = 'TSystem_Client_Account_Map.FindLRN';
var
   I : LongInt;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, aLRN]));
   result := nil;
   If (itemCount = 0 ) then Exit;

   For I := 0 to Pred( itemCount ) do
      With Client_Account_Map_At( I )^ do
         If (ALRN = amAccount_LRN) and (CLRN = amClient_LRN) then
         Begin
            result := Client_Account_Map_At( I );
            if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
            exit;
         end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Client_Account_Map.FindIndexOf(ALRN, CLRN: LongInt): Integer;
const
  ThisMethodName = 'TSystem_Client_Account_Map.FindIndexOf';
var
   I : LongInt;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, aLRN]));
   result := -1;
   If (itemCount = 0 ) then Exit;

   For I := 0 to Pred( itemCount ) do
      With Client_Account_Map_At( I )^ do
         If (ALRN = amAccount_LRN) and (CLRN = amClient_LRN) then
         Begin
            result := I;
            if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
            exit;
         end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Client_Account_Map.FindFirstClient(ALRN: LongInt): pClient_Account_Map_Rec;
const
  ThisMethodName = 'TSystem_Client_Account_Map.FindFirstClient';
var
  L, H, I, C: Integer;
  pM        : pClient_Account_Map_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
  FindEnd;
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : No Items',[ThisMethodName]));
    exit;      {no items in list}
  end;

  repeat
    I := (L + H) shr 1;
    pM := pClient_Account_Map_Rec(At(i));
    if ALRN < pM.amAccount_LRN then
      C := -1
    else if ALRN = pM.amAccount_LRN then
      C := 0
    else // i1 > i2
      C := 1;
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);

  if c=0 then
  begin
    // is this first or is there more before?
    while (i > 0) and (pClient_Account_Map_Rec(At(i - 1)).amAccount_LRN = ALRN) do
      Dec(i);
    result := pClient_Account_Map_Rec(At(i));
    CurrentRecord := i;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Client_Account_Map.FindNextClient(ALRN: LongInt): pClient_Account_Map_Rec;
const
  ThisMethodName = 'TSystem_Client_Account_Map.FindNextClient';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
  result := nil;
  // is the next record matching
  Inc(CurrentRecord);
  if (CurrentRecord < ItemCount) and (pClient_Account_Map_Rec(At(CurrentRecord)).amAccount_LRN = ALRN) then
    Result := pClient_Account_Map_Rec(At(CurrentRecord));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystem_Client_Account_Map.FindEnd;
const
  ThisMethodName = 'TSystem_Client_Account_Map.FindEnd';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
  CurrentRecord := -1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystem_Client_Account_Map.FreeItem(Item: Pointer);
const
  ThisMethodName = 'TSystem_Client_Account_Map.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  SYAMIO.Free_Client_Account_Map_Rec_Dynamic_Fields( pClient_Account_Map_Rec( Item)^);
  SafeFreeMem( Item, Client_Account_Map_Rec_Size );

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystem_Client_Account_Map.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_Client_Account_Map.LoadFromFile';
Var
   Token       : Byte;
   pM          : pClient_Account_Map_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Client_Account_Map :
            Begin
               SafeGetMem( pM, Client_Account_Map_Rec_Size );
               If not Assigned( pM ) then
               Begin
                  Msg := Format( '%s : Unable to Allocate pM',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
               Read_Client_Account_Map_Rec ( pM^, S );
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
procedure TSystem_Client_Account_Map.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_Client_Account_Map.SaveToFile';
Var
   i        : LongInt;
   pM       : pClient_Account_Map_Rec;
   MCount   : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   MCount := 0;

   S.WriteToken( tkBeginSystem_Client_Account_Map );

   For i := 0 to Pred( itemCount ) do
   Begin
      pM := pClient_Account_Map_Rec( At( i ) );
      SYAMIO.Write_Client_Account_Map_Rec ( pM^, S );
      Inc( MCount );
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format('%s : %d client account map records were saved',[ThisMethodName,MCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystem_Client_Account_Map.Client_Account_Map_At(Index: LongInt): pClient_Account_Map_Rec;
const
  ThisMethodName = 'TSystem_Client_Account_Map.Client_Account_Map_At';
Var
   P : Pointer;
Begin
   result := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   If SYAMIO.IsAClient_Account_Map_Rec(p) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
end.
