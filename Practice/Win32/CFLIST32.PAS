unit cfList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//admin system list of client file info
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  ECollect,Classes, syDefs, ioStream, sysUtils;

Type
   tSystem_Client_File_List = class(TExtdSortedCollection)
      constructor Create;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure   FreeItem( Item : Pointer ); override;
   public
      procedure   SaveToFile(var S : TIOStream );
      procedure   LoadFromFile(var S : TIOStream );
      function    Client_File_At( Index : LongInt ): pClient_File_Rec;
      function    FindCode( ACode : String ): pClient_File_Rec;
      function    FindLRN( LRN : LongInt ): pClient_File_Rec;
   end;

//******************************************************************************
implementation
uses
   SYCFIO, TOKENS, LogUtil, STStrS, MALLOC, bkdbExcept,
   bk5except;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'CFLIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// tSystem_Client_File_List
function tSystem_Client_File_List.Client_File_At(Index: Integer): pClient_File_Rec;
const
  ThisMethodName = 'TSystem_Client_File_List.File_At';
var
   p : pointer;
begin
   Client_File_At := NIL;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   If SYCFIO.IsAClient_File_Rec ( P ) then 
      Client_File_At := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Client_File_List.Compare(Item1, Item2: pointer): integer;
begin
   Compare := STStrS.CompStringS(pClient_File_Rec(Item1).cfFile_Code,pClient_File_Rec(Item2).cfFile_Code);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tSystem_Client_File_List.Create;
const
  ThisMethodName = 'TSystem_Client_File_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Client_File_List.FindCode(ACode: String): pClient_File_Rec;
const
  ThisMethodName = 'TSystem_Client_File_List.FindCode';
var
  L, H, I, C: Integer;
  pcf       : pClient_File_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName, ACode]));
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : No Items',[ThisMethodName]));
    exit;      {no items in list}
  end;

  repeat
    I := (L + H) shr 1;
    pcf := pClient_File_Rec(At(i));
    C := STStrS.CompStringS(ACode, pcf^.cfFile_Code);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
    result := pcf;
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
    exit;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Client_File_List.FindLRN(LRN: LongInt): pClient_File_Rec;
const
  ThisMethodName = 'TSystem_Client_File_List.FindLRN';
var
  I: Integer;
  pcf: pClient_File_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, LRN]));
  result := nil;
  for i := 0 to Pred(ItemCount) do
  begin
    pcf := pClient_File_Rec(At(i));
    if pcf^.cfLRN = LRN then
    begin
      result := pcf;
      Break;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Client_File_List.FreeItem(Item: Pointer);
const
  ThisMethodName = 'TSystem_Client_File_List.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  SYCFIO.Free_Client_File_Rec_Dynamic_Fields( pClient_File_Rec( Item)^ );
  SafeFreeMem( Item, Client_File_Rec_Size );

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Client_File_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_Client_File_List.LoadFromFile';
Var
   Token       : Byte;
   CF          : pClient_File_Rec;
   msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Client_File :
            Begin
               MALLOC.SafeGetMem( CF, Client_File_Rec_Size );
               If not Assigned( CF ) then
               Begin
                  Msg := Format( '%s : Unabled to Allocate CF',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
               Read_Client_File_Rec ( CF^, S );
               Insert( CF );
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
procedure tSystem_Client_File_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_Client_File_List.SaveToFile';
Var
   i        : LongInt;
   CF       : pClient_File_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   S.WriteToken( tkBeginSystem_Client_File_List );

   For i := 0 to Pred( itemCount ) do
   Begin
      CF := pClient_File_Rec( At( i ) );
      SYCFIO.Write_Client_File_Rec ( CF^, S );
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : %d records saved',[ThisMethodName,itemCount]));
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
