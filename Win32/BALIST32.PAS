unit BaList32;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Bank Account List Object
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   ECollect,Classes, bkDefs, ioStream, sysUtils, baObj32;
type
   TBank_Account_List = class(TExtdSortedCollection)
      constructor Create; Overload;
      constructor Create( Owner : TObject ); Overload;
      function Compare(Item1,Item2 : Pointer): Integer; override;
   protected
      procedure FreeItem(Item : Pointer); override;
   private
     fLoading : Boolean;
     fClient  : TObject; // Owner
   public
      procedure LoadFromFile(var S : TIOStream);
      procedure SaveToFile(var S: TIOStream);
      function  Bank_Account_At(Index : longint) : TBank_Account;
      function  FindCode(ACode: String): TBank_Account;
      function  Get_Journal_Account( Journal_Type : Byte ): TBank_Account;
      function  New_Journal_Account( Journal_Type : Byte ): TBank_Account;
      function  FindAccountFromECodingUID( UID : integer) : TBank_Account;
      procedure Insert( Item : Pointer ); override;
      procedure UpdateCRC(var CRC : LongWord);
   end;

//******************************************************************************
implementation
uses
   clObj32,
   LogUtil,
   tokens,
   bkbaio,
   bkconst,
   bkdbExcept,
   bk5Except,
   CountryUtils;

const
   UnitName = 'BALIST32';   
var
   DebugMe : Boolean = false;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TBank_Account_List.Create;
const
  ThisMethodName = 'TBank_Account_List.Create';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;
   Duplicates := false;
   fClient := NIL;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account_List.Compare(Item1,Item2:Pointer):integer;
begin
   result := CompareStr(TBank_Account(Item1).baFields.baBank_Account_Number,TBank_Account(Item2).baFields.baBank_Account_Number);
end;

constructor TBank_Account_List.Create(Owner: TObject);
begin
  Inherited Create;
  Duplicates := false;
  fClient := Owner;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account_List.FreeItem(Item : Pointer);
const
  ThisMethodName = 'TBank_Account_List.FreeItem';
var
  p : TBank_Account;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   p := TBank_Account(Item);
   p.Free;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account_List.Bank_Account_At(Index : longInt) : TBank_Account;
const
  ThisMethodName = 'TBank_Account_List.Bank_Account_At';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   result := TBank_Account(At(Index));
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account_List.FindCode(ACode: String): TBank_Account;
const
  ThisMethodName = 'TBank_Account_List.FindCode';
var
  L, H, I, C: Integer;
  p  : TBank_Account;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %s',[ThisMethodName,aCode]));
  Result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then begin
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : No items',[ThisMethodName]));
     exit;      {no items in list}
  end;

  repeat
    I := (L + H) shr 1;
    p := Bank_Account_At(i);
    C := CompareStr(ACode, p.baFields.baBank_Account_Number);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then begin
     Result := p;
     if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
     exit;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not found',[ThisMethodName]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account_List.LoadFromFile(var s : TIOStream);
const
  ThisMethodName = 'TBank_Account_List.LoadFromFile';
Var
   Token    : Byte;
   P        : TBank_Account;
   msg      : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   fLoading := True;
   Token := S.ReadToken;
   While ( Token <> tkEndSection ) do
   Begin
      Case Token of
         tkBegin_Bank_Account :
            Begin
               P := TBank_Account.Create;
               If not Assigned( P ) then
               Begin
                  Msg := Format( '%s : Unable to allocate P',[ThisMethodName]);
                  LogUtil.LogMsg(lmError, UnitName, Msg );
                  raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
               end;
               P.baClient := fClient;
               P.baTransaction_List.fClient := fClient;
               P.baTransaction_List.fBank_Account := P;
               P.LoadFromFile( S );
               Insert( P );
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
   fLoading := False;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account_List.SaveToFile(var s :TIOStream);
const
  ThisMethodName = 'TBank_Account_List.SaveToFile';
Var
   i  : LongInt;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   S.WriteToken( tkBeginBankAccountList );
   For i := 0 to Pred( ItemCount ) do Bank_Account_At( i ).SaveToFile( S );
   S.WriteToken( tkEndSection );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : %d bank accounts saved',[ThisMethodName,itemCount]));
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account_List.Get_Journal_Account(Journal_Type: Byte): TBank_Account;
const
  ThisMethodName = 'TBank_Account_List.Get_Journal_Account';
Var
   i : LongInt;
   B : TBank_Account;
   Msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Called with %d',[ThisMethodName, Journal_Type]));

   Result := nil;
   If not ( Journal_Type in [ btBank+1..btMax ] ) then
   Begin
      Msg := Format( '%s : Journal Type out of Range %d ', [ ThisMethodName, Journal_Type] );
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
   end;

   For i := 0 to Pred( itemCount ) do
   Begin
      B := Bank_Account_At( i );
      With B.baFields do
      Begin
         If ( baAccount_Type = Journal_Type ) then
         Begin
           Result := B;
           if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Found',[ThisMethodName]));
           exit;
         end;
      end;
   end;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,Format('%s : Not Found',[ThisMethodName]));
end;

procedure TBank_Account_List.Insert(Item: Pointer);
const
  ThisMethodName = 'TBank_Account_List.Insert';
Var
  B : TBank_Account;
  Msg : String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  B := TBank_Account( Item );
  B.baClient := fClient;
  B.baTransaction_List.fClient := fClient;
  B.baTransaction_List.fBank_Account := B;

  if not fLoading then
  Begin
    if B.baFields.baCurrency_Code = '' then
    Begin
      Msg := Format( '%s : Currency Code is required', [ ThisMethodName ] );
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
    End;
  End;

  inherited Insert( Item );
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account_List.New_Journal_Account(Journal_Type: Byte): TBank_Account;
const
  ThisMethodName = 'TBank_Account_List.New_Journal_Account';
var
   msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   If not ( Journal_Type in [ btBank+1..btMax ] ) then
   Begin
      Msg := Format( '%s : Journal Type out of Range %d ', [ ThisMethodName, Journal_Type] );
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
   end;

   If Get_Journal_Account( Journal_Type )<>NIL then
   Begin
      Msg := Format( '%s : Account Type already exists %d ', [ ThisMethodName, Journal_Type] );
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInvalidCall.CreateFmt( '%s - %s', [ UnitName, Msg ] );
   end;

   Result := TBank_Account.Create;
   With Result.baFields do
   Begin

      baCurrent_Balance  := 0;
      baAccount_Type := Journal_Type;
      baDesktop_Super_Ledger_ID := -1;

      if Journal_Type = btStockJournals  then
         baBank_Account_Number :=  'Stock/Adjustment Jnl' //Name is too long as a number
      else
         baBank_Account_Number := btNames[Journal_Type];

       baBank_Account_Name  :=  btNames[Journal_Type];
       baCurrency_Code := TClientOBJ(fClient).clExtra.ceLocal_Currency_Code;
   end;
   Insert(Result);


   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account_List.UpdateCRC(var CRC: LongWord);
var
   B: TBank_Account;
   I: Integer;
begin
   for i := 0 to Pred( ItemCount ) do begin
      B := Bank_Account_At( i );
      B.UpdateCRC( CRC );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TBank_Account_List.FindAccountFromECodingUID(
  UID: integer): TBank_Account;
var
  i : integer;
  ba : TBank_Account;
begin
  result := nil;
  for i := Self.First to Self.Last do
  begin
    ba := Bank_Account_At(i);
    if ba.baFields.baECoding_Account_UID = UID then
    begin
      result := ba;
      exit;
    end;
  end;
end;

initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
