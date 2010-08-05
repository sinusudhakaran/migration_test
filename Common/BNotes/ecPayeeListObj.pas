unit ecPayeeListObj;
//------------------------------------------------------------------------------
{
   Title:       Payee List Object

   Description:

   Remarks:

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface
uses
   ecDefs, ioStream, eCollect;

type
  TECPayee_List_V53 = class (TExtdSortedCollection)
    constructor Create;
    function Compare( Item1, Item2 : pointer ): Integer; override;
  protected
    procedure FreeItem( Item : Pointer ); override;
  public
    function  Find_Payee_Name( Const AName: ShortString ): pPayee_Rec;
    function  Find_Payee_Number( Const ANumber: LongInt ): pPayee_Rec;
    function  Get_New_Payee_Number: LongInt;
    procedure LoadFromFile( Var S : TIOStream );
    function  Payee_At( Index : LongInt ): pPayee_Rec;
    procedure SaveToFile( Var S : TIOStream );
    function  Search_Payee_Name( Const AName: ShortString ): pPayee_Rec;
    procedure UpdateCRC(var CRC: LongWord);
  end;

//******************************************************************************
implementation
uses
   malloc,
   ecpyio,
   EcTokens,
   EcExcept,
   BkDBExcept,
   ecCRC,
   StStrs,
   SysUtils;


const
   SUnknownToken       = 'pyList Error: Unknown token %d';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TECPayee_List }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECPayee_List_V53.Compare(Item1, Item2: pointer): Integer;
begin
  result := StStrS.CompStringS(pPayee_Rec(Item1)^.pyName,pPayee_Rec(Item2)^.pyName);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TECPayee_List_V53.Create;
begin
  inherited Create;
  Duplicates := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECPayee_List_V53.Find_Payee_Name(const AName: ShortString): pPayee_Rec;
var
  i: LongInt;
begin
  Result := NIL;
  for i := 0 to Pred( ItemCount ) do
     if Payee_At( i )^.pyName = AName then begin
        Result := Payee_At( i );
        exit;
     end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECPayee_List_V53.Find_Payee_Number(const ANumber: Integer): pPayee_Rec;
var
  i: LongInt;
begin
  Result := nil;
  for i := 0 to Pred( ItemCount ) do
     if Payee_At( i )^.pyNumber = ANumber then begin
        Result := Payee_At( i );
        exit;
     end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Get_New_Payee_Number
//
// Find the highest payee number, then add 1 and return it.
//
function TECPayee_List_V53.Get_New_Payee_Number: LongInt;
var
  i : Integer;
begin
  Result := -1;
  for i := 0 to ItemCount - 1 do
  begin
    if (Payee_At( i )^.pyNumber > Result) then
      Result := Payee_At( i )^.pyNumber;
  end;
  if (Result <> -1) then
    Result := Result + 1;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECPayee_List_V53.FreeItem(Item: Pointer);
begin
  if EcPyio.IsAPayee_Rec( Item ) then begin
     EcPyio.Free_Payee_Rec_Dynamic_Fields( pPayee_Rec( Item)^);
     SafeFreeMem( Item, Payee_Rec_Size );
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECPayee_List_V53.LoadFromFile(var S: TIOStream);
var
  Token: Byte;
  pM: pPayee_Rec;
begin
  Token := S.ReadToken;
  while ( Token <> tkEndSection ) do begin
     case Token of
        tkbegin_Payee : begin
              pM := New_Payee_Rec;
              Read_Payee_Rec ( pM^, S );
              Insert( pM );
           end;
        else
           Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
     end; { of Case }
     Token := S.ReadToken;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECPayee_List_V53.Payee_At(Index: Integer): pPayee_Rec;
var
  P: Pointer;
begin
  result := nil;
  P := At( Index );
  if EcPyio.IsAPayee_Rec( P ) then
     result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECPayee_List_V53.SaveToFile(var S: TIOStream);
var
  i: Integer;
begin
  S.WriteToken( tkbeginPayees );
  for i := 0 to Pred( ItemCount ) do EcPyio.Write_Payee_Rec( Payee_At( i )^, S );
  S.WriteToken( tkEndSection );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECPayee_List_V53.Search_Payee_Name( const AName: ShortString): pPayee_Rec;
var
  UName: ShortString;

     function I_Match( P : pPayee_Rec ): Boolean;
     var
        TempString : ShortString;
     begin
        TempString := UpperCase( Copy( P^.pyName, 1, Length( UName ) ) );
        Result     := ( TempString = Uname );
     end;

  Var
     i : LongInt;

begin
  Result := nil;

  UName := UpperCase( AName );

  for i := 0 to Pred( ItemCount ) do
     if I_Match( Payee_At( i ) ) then begin
        result := Payee_At( i );
        exit;
     end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECPayee_List_V53.UpdateCRC( Var CRC : LongWord );
var
  I: Integer;
begin
  for I := 0 to Pred( ItemCount ) do
     ECCRC.UpdateCRC( Payee_At( I )^, CRC );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
