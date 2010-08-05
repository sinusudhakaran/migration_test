unit ecBankAccountsListObj;
//------------------------------------------------------------------------------
{
   Title:       ECBankAccountsList

   Description: ECoding Bank Accounts List

   Remarks:     Holds a list of bank account objects

   Author:      Matthew Hopkins  Jul 2001

}
//------------------------------------------------------------------------------

interface
uses
   ecBankAccountObj, ecollect, iostream;

type
   TECBank_Account_List = class(TExtdSortedCollection)
      constructor Create;
      function Compare(Item1,Item2 : Pointer): Integer; override;
   protected
      procedure FreeItem(Item : Pointer); override;
   private

   public
      procedure LoadFromFile(var S : TIOStream);
      procedure SaveToFile(var S: TIOStream);
      function  Bank_Account_At(Index : longint) : TECBank_Account;
      function  FindCode(ACode: String): TECBank_Account;
      procedure UpdateCRC( var CRC : LongWord);
   end;

//******************************************************************************
implementation
uses
   StStrS,
   ECTokens,
   ECBAIO,
   BkDBExcept;

{ TECBank_Account_List }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECBank_Account_List.Bank_Account_At( Index: Integer): TEcBank_Account;
begin
   Result := TECBank_Account( At( Index ) );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECBank_Account_List.Compare(Item1, Item2: Pointer): Integer;
var
  P1: TECBank_Account Absolute Item1;
  P2: TECBank_Account Absolute Item2;
begin
  Result := StStrS.CompStringS( P1.baFields.baBank_Account_Number, P2.baFields.baBank_Account_Number );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TECBank_Account_List.Create;
begin
  inherited Create;
  Duplicates := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECBank_Account_List.FindCode(ACode: String): TEcBank_Account;
var
  L, H, I, C: Integer;
  P: TECBank_Account;
begin
  Result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;

  repeat
    I := (L + H) shr 1;
    P := Bank_Account_At( i );
    C := STStrS.CompStringS( ACode, P.baFields.baBank_Account_Number );
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c=0 then Result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECBank_Account_List.FreeItem(Item: Pointer);
var
  P: TECBank_Account;
begin
  P := TECBank_Account( Item );
  P.Free;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECBank_Account_List.LoadFromFile(var S: TIOStream);
var
  Token: Byte;
  P: TECBank_Account;
begin
  Token := S.ReadToken;
  While ( Token <> tkEndSection ) do
  Begin
     Case Token of
        tkBegin_Bank_Account_Details :
           Begin
              P := TECBank_Account.Create;
              P.LoadFromFile( S );
              Insert( P );
           end;
        else
           Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
     end; { of Case }
     Token := S.ReadToken;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECBank_Account_List.SaveToFile(var S: TIOStream);
var
  I: Integer;
begin
  S.WriteToken( tkBeginBankAccountList );
  For i := 0 to Pred( ItemCount ) do Bank_Account_At( i ).SaveToFile( S );
  S.WriteToken( tkEndSection );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECBank_Account_List.UpdateCRC(var CRC: LongWord);
var
  B: TECBank_Account;
  I: Integer;
begin
  For i := 0 to Pred( ItemCount ) do
  Begin
     B := Bank_Account_At( i );
     B.UpdateCRC( CRC );
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
