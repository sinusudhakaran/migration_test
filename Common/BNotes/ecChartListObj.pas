unit ecChartListObj;
//------------------------------------------------------------------------------
{
   Title:       Chart List Object

   Description: Holds list of accounts

   Remarks:

   Author:      Matthew Hopkins  Aug 01

}
//------------------------------------------------------------------------------

interface
uses
   ecdefs, iostream, ecollect;

type
  TECChart_List = class (TExtdSortedCollection)
    constructor Create;
    function Compare( Item1, Item2 : pointer ): Integer; override;
  protected
    procedure FreeItem( Item : Pointer ); override;
  public
    function  Account_At( Index : integer ): pAccount_Rec;
    function  AddMaskCharToCode( Const Code, Mask : String; Var MaskChar : Char): Boolean;
    function  AllowLowerCase: Boolean;
    function  CanCodeTo( Const ACode : ShortString ): Boolean;
    function  CanPressEnterNow( Const ACode : ShortString ): Boolean;
    function  CodeIsThere( Const ACode : ShortString ): Boolean;
//    function EnterQuantity( Const ACode : ShortString ): Boolean;
    function  FindCode( Const ACode : ShortString ): pAccount_Rec;
    function  FindDesc( Const ACode : ShortString ): ShortString;
    function  GSTClass( Const ACode : ShortString ): Byte;
//    function HasGSTClasses: Boolean;
    procedure LoadFromFile( Var S : TIOStream );
    function  MaxCodeLength: Integer;
    procedure SaveToFile( Var S : TIOStream );
    function SearchClosestCode(const ACode: ShortString): pAccount_Rec;
    function  SearchforCode( Const ACode : ShortString ): Integer;
    procedure UpdateCRC( Var CRC : LongWord );
    function  CanUseMinusAsLookup: Boolean;
    function  CountBasicItems: Integer;
  end;



//******************************************************************************
implementation
uses
   malloc,
   ecchio,
   EcTokens,
   EcExcept,
   BkDBExcept,
   ecCRC,
   StStrs;

const
   SUnknownToken       = 'chList Error: Unknown token %d';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TECChart_List }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.Account_At(Index: integer): pAccount_Rec;
var
  P: Pointer;
begin
  Result := nil;
  P := At( Index );
  if EcChio.IsAAccount_Rec( P ) then
     Result := P;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.AddMaskCharToCode(const Code, Mask: String; var MaskChar: Char): Boolean;
var
  TestNextKey: ShortString;
  ActualNextKey: ShortString;
  Len: Byte;
  NewLen: Byte;
  pCh: PAccount_Rec;
begin
  If ItemCount = 0 then begin
     Result := FALSE;
     exit;
  end;
  Result := False;
  Len := Length( Code );
  If ( Len < Length( Mask ) ) and ( Mask[ Len+1 ] <> '#' ) then begin
     NewLen   := Len + 1;
     MaskChar := Mask[ NewLen ];
     TestNextKey    := Code + MaskChar;
     ActualNextKey  := TestNextKey;
     pCh := SearchClosestCode( TestNextKey ); If not Assigned( pCh ) then exit;
     ActualNextKey   := pCh^.chAccount_Code;
     If ( Copy( ActualNextKey, 1, NewLen ) = TestNextKey ) then
        Result := TRUE;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.AllowLowerCase: Boolean;
var
  I: Integer;
  p: Word;
begin
  Result := false;
  for i := 0 to Pred( itemCount ) do With Account_At( I )^ do begin
     for p := 1 to Length( chAccount_Code ) do
        If ( chAccount_Code[p] in [ 'a'..'z' ] ) then begin
           Result := true;
           exit;
        end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.CanCodeTo(const ACode: ShortString): Boolean;
var
  pCh: pAccount_Rec;
begin
  If ItemCount = 0 then begin
     Result := True;
     exit;
  end;
  Result := False;
  pCh := FindCode( ACode );
  If Assigned( pCH ) then
     Result := pCh^.chPosting_Allowed;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.CanPressEnterNow(const ACode: ShortString): Boolean;
var
  pCh, nCh: pAccount_Rec;
  NextCode: ShortString;
  i: Integer;
begin
  Result := FALSE;
  pCh := FindCode( ACode );
  If Assigned( pCh ) then begin
     i := Succ( IndexOf( pCh ) );
     If i < ItemCount then begin
        nCh := Account_At( i );
        NextCode := nCh^.chAccount_Code;
        NextCode[0] := Chr( Length( ACode ) );
        If ( NextCode = ACode ) then exit;
     end;
     Result := pCh^.chPosting_Allowed;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.CodeIsThere(const ACode: ShortString): Boolean;
begin
  Result := FindCode( ACode ) <> nil;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.Compare(Item1, Item2: pointer): Integer;
begin
  Result := STStrS.CompStringS(pAccount_Rec(Item1)^.chAccount_Code, pAccount_Rec(Item2)^.chAccount_Code);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TECChart_List.Create;
begin
  inherited Create;
  Duplicates := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.FindCode(const ACode: ShortString): pAccount_Rec;
var
  L, H, I, C: Integer;
  pCh: pAccount_Rec;
begin
  result := nil;

  L := 0;
  H := ItemCount - 1;
  if L>H then exit; {no items in list}

  repeat
    I := (L + H) shr 1;
    pCh := Account_At( i );
    C := STStrS.CompStringS(ACode, pCh^.chAccount_Code);
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);

  if c=0 then result := pCh;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.FindDesc(const ACode: ShortString): ShortString;
var
  pCh: pAccount_Rec;
begin
  Result := '';
  pCh := FindCode( ACode );
  If Assigned( pCH ) then Result := pCh^.chAccount_Description;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECChart_List.FreeItem(Item: Pointer);
begin
  EcChio.Free_Account_Rec_Dynamic_Fields( pAccount_Rec( Item )^ );
  SafeFreeMem( Item, Account_Rec_Size );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.GSTClass(const ACode: ShortString): Byte;
var
  pCh: pAccount_Rec;
begin
  Result := 0;
  pCh := FindCode( ACode );
  If Assigned( pCH ) then Result := pCh^.chGST_Class;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECChart_List.LoadFromFile(var S: TIOStream);
var
  Token: Byte;
  pCH: pAccount_Rec;
begin
  Token := S.ReadToken;
  While ( Token <> tkEndSection ) do begin
     Case Token of
        tkbegin_Account :
           begin
              pCh := New_Account_Rec;
              Read_Account_Rec ( pCH^, S );
              Insert( pCH );
           end;
        else
           Raise ETokenException.CreateFmt( SUnknownToken, [ Token ] );
     end; { of Case }
     Token := S.ReadToken;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.MaxCodeLength: Integer;
var
  I: Integer;
  ThisL: Integer;
begin
  Result := 0;
  for i := 0 to Pred( ItemCount ) do With Account_At( I )^ do begin
     ThisL := Length( chAccount_Code );
     if ThisL > Result then Result := ThisL;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECChart_List.SaveToFile(var S: TIOStream);
var
  i: Integer;
begin
  S.WriteToken( tkbeginChart );
  for i := 0 to Pred( ItemCount ) do
    EcChio.Write_Account_Rec( Account_At( i )^, S );
  S.WriteToken( tkEndSection );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.SearchClosestCode(const ACode: ShortString): pAccount_Rec;
var
  L, H, I, C: Integer;
  pCh: pAccount_Rec;
begin
  Result := nil;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;
  repeat
    I := (L + H) shr 1;
    pCh := Account_At( i );
    C := STStrS.CompStringS( ACode, pCh^.chAccount_Code );
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);

  if c=0 then
  begin
    result := pCh;  {found it}
    Exit;
  end;

  { Do we have a partial match? }

  if length( ACode ) > 0 then
  begin
     If Copy( pCh^.chAccount_Code, 1, length( ACode ) ) = ACode then
     begin
        result := pCh;
        Exit;
     end;
  end;

  { OK, no match so just return the next account }

  Inc( i );
  if I < ItemCount then Result := Account_At( i );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.SearchforCode(const ACode: ShortString): Integer;
var
  L, H, I, C: Integer;
  pCh: pAccount_Rec;
begin
  result := 0;
  L := 0;
  H := ItemCount - 1;
  if L>H then exit;

  repeat
    I := (L + H) shr 1;
    pCh := Account_At( i );
    C := STStrS.CompStringS( ACode, pCh^.chAccount_Code );
    if C > 0 then L := I + 1 else H := I - 1;
  until (c=0) or (L>H);
  if c<>0 then Inc(i);
  if i=ItemCount then Dec(i);
  result := i;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TECChart_List.UpdateCRC(var CRC: LongWord);
var
  I: Integer;
begin
  for I := 0 to Pred( ItemCount ) do ECCRC.UpdateCRC( Account_At( I )^, CRC );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.CanUseMinusAsLookup: Boolean;
var
  i: Integer;
begin
  Result := TRUE;
  for i := 0 to Pred( ItemCount ) do With Account_At( i )^ do
  begin
     If Pos( '-', chAccount_Code )>0 then
     begin
        Result := FALSE;
        Break;
     end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TECChart_List.CountBasicItems: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Pred( ItemCount ) do
    if not Account_At( i )^.chHide_In_Basic_Chart then
      Inc(Result);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
