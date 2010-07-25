unit SBAList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//System Bank Accounts List
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  ECollect,Classes, syDefs, ioStream, sysUtils;

Type
   tSystem_Bank_Account_List = class(TExtdSortedCollection)
      constructor Create;
      function    Compare( Item1, Item2 : pointer ) : integer; override;
   protected
      procedure   FreeItem( Item : Pointer ); override;
   public
      function    System_Bank_Account_At( Index : LongInt ): pSystem_Bank_Account_Rec;
      function    FindCode( ACode : String ): pSystem_Bank_Account_Rec;
      function    FindLRN(LRN: LongInt): pSystem_Bank_Account_Rec;
      function    NewAccountsCount: Integer;
      function    UnAttachedAccounts: Integer;
      function    InactiveAccounts: Integer;
      function    ChargingAccountsCount: Integer;
      procedure   SaveToFile(var S : TIOStream );
      procedure   LoadFromFile(var S : TIOStream );
   end;

//******************************************************************************
implementation
uses
   SYSBIO, TOKENS, LogUtil, MALLOC, StStrS, bkdbExcept,
   bk5except;

CONST
   DebugMe : Boolean = FALSE;
   UnitName = 'SBALIST32';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ tSystem_Bank_Account_List }
function tSystem_Bank_Account_List.ChargingAccountsCount: Integer;
var i: Integer;
    pBankAccount: pSystem_Bank_Account_Rec;
begin
  result := 0;
  for i:= 0 to self.ItemCount-1 do begin
    pBankAccount := pSystem_Bank_Account_Rec(At(i));
    if NOT(pBankAccount.sbNo_Charge_Account) then
      result := result+1;
  end;
end;

function tSystem_Bank_Account_List.Compare(Item1, Item2: pointer): integer;
begin
   Compare := STStrS.CompStringS(pSystem_Bank_Account_Rec(Item1).sbAccount_Number, pSystem_Bank_Account_Rec(Item2).sbAccount_Number);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor tSystem_Bank_Account_List.Create;
const
  ThisMethodName = 'TSystem_Bank_Account_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Bank_Account_List.FindCode(ACode: String): pSystem_Bank_Account_Rec;
const
  ThisMethodName = 'TSystem_Bank_Account_List.FindCode';
var
  L, H, I, C: Integer;
  pBa       : pSystem_Bank_Account_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
  result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : No Items',[ThisMethodName]));
    exit;      {no items in list}
  end;

  repeat
    I := (L + H) shr 1;
    pBa := pSystem_Bank_Account_Rec(At(i));
    C := STStrS.CompStringS(ACode, pba^.sbAccount_Number);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);

  if c=0 then result := pBa;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Bank_Account_List.FindLRN(LRN: LongInt): pSystem_Bank_Account_Rec;
const
  ThisMethodName = 'TSystem_Bank_Account_List.FindLRN';
var
  I: Integer;
  pBa: pSystem_Bank_Account_Rec;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
  result := nil;
  for i := 0 to Pred(ItemCount) do
  begin
    pBa := pSystem_Bank_Account_Rec(At(i));
    if pBA^.sbLRN = LRN then
    begin
      result := pBA;
      Break;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Bank_Account_List.FreeItem(Item: Pointer);
const
  ThisMethodName = 'TSystem_Bank_Account_List.FreeItem';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  SYSBIO.Free_System_Bank_Account_Rec_Dynamic_Fields( pSystem_Bank_Account_Rec( Item)^);
  SafeFreeMem( Item, System_Bank_Account_Rec_Size );

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Bank_Account_List.LoadFromFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_Bank_Account_List.LoadFromFile';
Var
   Token       : Byte;
   SB          : pSystem_Bank_Account_Rec;
   Msg         : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_System_Bank_Account :
            Begin
               MALLOC.SafeGetMem( SB, System_Bank_Account_Rec_Size );
               If not Assigned( SB ) then
               Begin
                  Msg := Format( '%s : Unable to Allocate SB',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
               Read_System_Bank_Account_Rec ( SB^, S );
               Insert( SB );
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


function tSystem_Bank_Account_List.NewAccountsCount: Integer;
var i: Integer;
    pBankAccount: pSystem_Bank_Account_Rec;
begin
  result := 0;
  for i:= 0 to self.ItemCount-1 do begin
    pBankAccount := pSystem_Bank_Account_Rec(At(i));
    if pBankAccount.sbNew_This_Month
    and pBankAccount.sbAttach_Required
    and not(pBankAccount.sbMark_As_Deleted) then
      result := result+1;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure tSystem_Bank_Account_List.SaveToFile(var S: TIOStream);
const
  ThisMethodName = 'TSystem_Bank_Account_List.SaveToFile';
Var
   i        : LongInt;
   SB       : pSystem_Bank_Account_Rec;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   S.WriteToken( tkBeginSystem_Bank_Account_List );

   For i := 0 to Pred( itemCount ) do
   Begin
      SB := pSystem_Bank_Account_Rec( At( i ) );
      SYSBIO.Write_System_Bank_Account_Rec ( SB^, S );
   end;

   S.WriteToken( tkEndSection );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : %d account records saved',[ThisMethodName,ItemCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Bank_Account_List.System_Bank_Account_At(Index: Integer): pSystem_Bank_Account_Rec;
const
  ThisMethodName = 'TSystem_Bank_Account_List.System_Bank_Account_At';
Var
   P : Pointer;
Begin
   System_Bank_Account_At := nil;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   P := At( Index );
   If SYSBIO.IsASystem_Bank_Account_Rec(p) then
      result := P;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Bank_Account_List.UnAttachedAccounts: Integer;
var i: Integer;
    pBankAccount: pSystem_Bank_Account_Rec;
begin
  Result := 0;
  for i:= 0 to self.Last do begin
    pBankAccount := pSystem_Bank_Account_Rec(At(i));
    if pBankAccount.sbAttach_Required
    and not(pBankAccount.sbMark_As_Deleted) then
      Inc(Result)
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function tSystem_Bank_Account_List.InactiveAccounts: Integer;
var i: Integer;
    pBankAccount: pSystem_Bank_Account_Rec;
begin
  Result := 0;
  for i:= 0 to self.Last do begin
    pBankAccount := pSystem_Bank_Account_Rec(At(i));
    if pBankAccount.sbInActive
    and not(pBankAccount.sbMark_As_Deleted) then
      Inc(Result)
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
  DebugMe := DebugUnit(UnitName);

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
