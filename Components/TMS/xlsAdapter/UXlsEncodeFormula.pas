unit UXlsEncodeFormula;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}

interface

uses
  XlsFormulaMessages, XlsMessages, UXlsFormulaParser,
  UFlxStack, UXlsStrings, SysUtils, UXlsBaseRecordLists, UXlsRowColEntries, UFlxMessages;

type
  TParseString= class
  private
    ParsePos: integer;
    Fw: widestring;
    FParsedData: array of byte;
    FParsedArrayData: array of byte;
    MaxErrorLen: integer;
    DirectlyInFormula: string;

    LastRefOp: integer;

    FNameTable: TNameRecordList;
    FCellList: TCellList;

    StackWs: TWhiteSpaceStack;

    Default3DExternSheet: widestring;
    Force3d: boolean; //Named ranges

    function IsNumber(const c: widechar): boolean;
    function IsAlpha(const c: widechar): boolean;
    function IsAZ(const c: widechar): boolean;
    function ATo1(const c: widechar): integer;

    function NextChar: boolean;
    function PeekChar(var c: WideChar): boolean;
    function Peek2Char(var c: WideChar): boolean;
    function PeekCharWs(var c: WideChar): boolean;

    procedure GetNumber;
    procedure GetString;
    procedure GetAlpha;
    procedure GetArray;

    procedure GetFormulaArgs(const Index: integer; var ArgCount: integer);
    procedure GetFormula(const s: string);
    function  GetBool(const s: string): boolean;
    function IsErrorCode(const s: widestring; var b: byte): boolean;
    procedure GetError;
    procedure GetOneReference(var RowAbs, ColAbs: boolean;var Row, Col: integer);
    function  GetReference: boolean;

    procedure Factor;     // [Whitespace]* Function | Number | String | Cell Reference | 3d Ref | (Expression) | NamedRange | Boolean | Err | Array
    procedure RefTerm;    // Factor [ : | ' ' | , Factor]
    procedure NegTerm;    // [-]* RefTerm
    procedure PerTerm;    // NegTerm [%]*
    procedure ExpTerm;    // PerTerm [ ^ PerTerm]*
    procedure MulTerm;    // ExpTerm [ *|/ ExpTerm ]*
    procedure AddTerm;    // MulTerm [ +|- MulTerm]*
    procedure AndTerm;    // AddTerm [ & AddTerm]*
    procedure ComTerm;    // AndTerm [ = | < | > | <= | >= | <>  AndTerm]*
    procedure Expression;

    procedure SkipWhiteSpace;
    procedure UndoSkipWhiteSpace(const SaveParsePos: integer);
    procedure PopWhiteSpace;
    procedure AddParsed(const s: array of byte; const PopWs: boolean=true);
    procedure AddParsedArray(const s: array of byte);
    function FindComTerm(var Ptg: byte): boolean;
    procedure GetGeneric3dRef(const ExternSheet: widestring);
    procedure GetQuotedRef3d;
    procedure GetRef3d(const s: widestring);
    function GetExternSheet(const ExternSheet: widestring): word;
    procedure ConvertLastRefValueType(const RefMode: TFmReturnType);
    function GetLastRefOp: byte;
    class function GetPtgMode(const aptg: byte): TFmReturnType;
    procedure SetLastRefOp(const aptg: byte; const RefMode: TFmReturnType);
    procedure ConvertLastRefValueTypeOnce(const RefMode: TFmReturnType; var First: boolean);
    function IsDirectlyInFormula: boolean;
  public
    constructor Create(const aw: widestring; const aNameTable: TNameRecordList; const aCellList: TCellList);
    constructor CreateExt(const aw: widestring;
      const aNameTable: TNameRecordList; const aCellList: TCellList;
      const aForce3D: Boolean; const aDefault3DExternSheet: WideString;
      const ReturnType: TFmReturnType);

    destructor Destroy; override;
    procedure Parse;

    function TotalSize: integer;
    procedure CopyToPtr(const Ptr: PArrayOfByte; const aPos: integer);
    procedure CopyToPtrNoLen(const Ptr: PArrayOfByte; const destIndex: integer);
  end;

implementation


function GetRealPtg(const PtgBase: word; const ReturnType: TFmReturnType): word;
begin
  case ReturnType of
    fmArray: Result:=PtgBase+$40;
    fmRef  : Result:=PtgBase;
    else     Result:=PtgBase+$20;
  end; //case
end;

{ TParseString }

constructor TParseString.Create(const aw: widestring; const aNameTable: TNameRecordList; const aCellList: TCellList);
begin
  inherited Create;
  Fw:= aw;
  ParsePos:=1;
  StackWs:=TWhiteSpaceStack.Create;
  FNameTable:=aNameTable;
  FCellList:=aCellList;
  Force3D := false;
  MaxErrorLen:=Length(fmErrNull);
  if MaxErrorLen<Length(  fmErrDiv0 ) then MaxErrorLen:=Length(fmErrDiv0 );
  if MaxErrorLen<Length(  fmErrValue) then MaxErrorLen:=Length(fmErrValue);
  if MaxErrorLen<Length(  fmErrRef  ) then MaxErrorLen:=Length(fmErrRef  );
  if MaxErrorLen<Length(  fmErrName ) then MaxErrorLen:=Length(fmErrName );
  if MaxErrorLen<Length(  fmErrNum  ) then MaxErrorLen:=Length(fmErrNum  );
  if MaxErrorLen<Length(  fmErrNA   ) then MaxErrorLen:=Length(fmErrNA   );
end;

constructor TParseString.CreateExt(const aw: widestring; const aNameTable: TNameRecordList; const aCellList: TCellList;
                     const aForce3D: Boolean; const aDefault3DExternSheet: WideString; const ReturnType: TFmReturnType);
begin
  Create(aw, aNameTable, aCellList);
  Default3DExternSheet := aDefault3DExternSheet;
  Force3D := aForce3d;
end;

destructor TParseString.Destroy;
begin
  FreeAndNil(StackWs);
  inherited;
end;

function TParseString.GetLastRefOp: byte;
begin
  Result:= FParsedData[LastRefOp];
end;

procedure TParseString.SetLastRefOp(const aptg: byte; const RefMode: TFmReturnType);
var
  newptg: Byte;
begin
  newptg := Byte(aptg);
  if (Byte(aptg) and 96) <> 0 then
  begin
    case RefMode of
      fmRef:
          newptg := Byte((newptg and 159) or 32);
      fmValue:
          newptg := Byte((newptg and 159) or 64);
      fmArray:
          newptg := Byte(newptg or 96);
    end; //case
  end;
  FParsedData[LastRefOp] :=newptg;
end;

class function TParseString.GetPtgMode(const aptg: byte): TFmReturnType;
var
  PtgMode: TFmReturnType;
begin
  PtgMode := fmValue;
  if ((aptg = ptgRange) or (aptg = ptgIsect)) or (aptg = ptgUnion) then PtgMode := fmRef;

  case aptg and 96 of
    32:
      PtgMode := fmRef;
    96:
      PtgMode := fmArray;
  end; //case
  
  Result := PtgMode;
end;

procedure TParseString.ConvertLastRefValueType(const RefMode: TFmReturnType);
var
  aptg: byte;
  PtgMode: TFmReturnType;
begin
  if LastRefOp < 0 then
    raise Exception.Create(ErrInternal);
  
  aptg := GetLastRefOp;
  PtgMode := GetPtgMode(aptg);
  case RefMode of
    fmValue:
    begin
      if PtgMode <> fmArray then
        SetLastRefOp(aptg, fmValue);
    end;
    fmArray:
    begin
      SetLastRefOp(aptg, fmArray);
    end;
  end;
end;

procedure TParseString.ConvertLastRefValueTypeOnce(const RefMode: TFmReturnType; var First: boolean);
begin
  if (First) then ConvertLastRefValueType(RefMode);
  First:=false;
end;

procedure TParseString.GetRef3d(const s: widestring);
var
  c: WideChar;
begin
  c := ' ';
  if not PeekChar(c) or (c <> fmExternalRef) then
    raise Exception.CreateFmt(ErrUnexpectedChar, [c, ParsePos, Fw]);
  NextChar;
  GetGeneric3dRef(s);
end;

procedure TParseString.GetQuotedRef3d;
var
  e: WideChar;
  d: WideChar;
  More: Boolean;
  sq: widestring;
  c: WideChar;
  s: widestring;
begin
  SkipWhiteSpace;
  s := '';
  c := ' ';
  sq := fmSingleQuote;
  if not PeekChar(c) or (c <> sq) then
    raise Exception.CreateFmt(ErrUnexpectedChar, [c, ParsePos, Fw]);
  NextChar;

  repeat
    More := False;
    if PeekChar(c) and (c <> sq) then
    begin
      s:=s+c;
      NextChar;
      More := True;
    end
    else
    begin
      d := ' ';
      e := ' ';
      if PeekChar(d) and (d = sq) and Peek2Char(e) and (e = sq) then
      begin
        s:=s+sq;
        NextChar;
        NextChar;
        More := True;
      end;
    end;
  until not More;
  if not PeekChar(c) or (c <> sq) then
    raise Exception.CreateFmt(ErrUnterminatedString, [Fw]);
  NextChar;
  GetRef3d(s);
end;

procedure TParseString.Factor;
var
  c: widechar;
begin
  if PeekCharWs(c) then
  begin
    if ord(c)>255 then raise Exception.CreateFmt(ErrUnexpectedChar, [char(c), ParsePos, Fw]);
    if IsNumber(c) then GetNumber else
    if c= fmOpenParen then
    begin
      SkipWhiteSpace;
      NextChar;

			DirectlyInFormula := DirectlyInFormula + '0';
			try
        Expression;
      finally
				Delete(DirectlyInFormula, Length(DirectlyInFormula), 1);
      end;

      if not (PeekCharWs(c)) or (c<>fmCloseParen) then raise Exception.CreateFmt(ErrMissingParen, [Fw]);
      SkipWhiteSpace;
      NextChar;
      PopWhiteSpace;
      AddParsed([ptgParen]);
    end
    else if c=fmStr then GetString
    else if c=fmOpenArray then GetArray
    else if c=fmErrStart then GetError
    else if not GetReference then
      if IsAlpha(c) then GetAlpha
      else if c=fmSingleQuote then GetQuotedRef3d();
  end
  else
    raise Exception.CreateFmt(ErrUnexpectedEof, [Fw]);
end;

function TParseString.IsDirectlyInFormula: boolean;
begin
  if (Length(DirectlyInFormula) <=0) then Result:= false
  else
  begin
    Result := DirectlyInFormula[Length(DirectlyInFormula)]='1';
  end;
end;

procedure TParseString.RefTerm;
// Factor [ : | ' ' | , Factor]
var
  c: widechar;
  b: byte;
  First: boolean;
begin
  First:=true;
  Factor;
  //Pending: see how to fix intersect (on popwhitespace, if there are two references, is an intersect).
  //Union is only valid if we are not inside a function. For example A2:A3,B5 is ok. But HLookup(0,A2:A3,B5,1, true) is not ok.

  while PeekCharWS(c) and (((c=fmUnion) and not IsDirectlyInFormula)   or (c=fmRangeSep) {or (c=fmIntersect)}) do
  begin
	  ConvertLastRefValueTypeOnce(fmRef, First);
    SkipWhiteSpace;
    NextChar;
    Factor;
	  ConvertLastRefValueType(fmRef);

    if (c=fmUnion) then b:=ptgUnion else
    if (c=fmRangeSep) then b:=ptgRange else
    if (c=fmIntersect) then b:=ptgIsect else
    raise Exception.Create(ErrInternal);
    AddParsed(b);
  end;
end;

procedure TParseString.NegTerm;
//[-]* RefTerm
var
  c: widechar;
  i: integer;
  s: string;
begin
  s:='';
  while PeekCharWs(c) and ((c=fmMinus) or (c=fmPlus))do
  begin
    SkipWhiteSpace;
    NextChar;
    s:=s+c;
  end;
  RefTerm;
  if Length(s)>0 then
  begin
    ConvertLastRefValueType(fmValue);
    for i:=1 to Length(s) do
      if (s[i] = fmMinus) then AddParsed([ptgUminus]) else AddParsed([ptgUplus]);
  end;
end;

procedure TParseString.PerTerm;
// NegTerm [%]*
var
  c: widechar;
  First: boolean;
begin
  First:=true;
  NegTerm;
  while PeekCharWs(c) and (c=fmPercent) do
  begin
	  ConvertLastRefValueTypeOnce(fmValue, First);
    SkipWhiteSpace;
    NextChar;
    AddParsed([ptgPercent]);
  end;
end;

procedure TParseString.ExpTerm;
// PerTerm [ ^ PerTerm]*
var
  c: widechar;
  First: boolean;
begin
  First:=true;
  PerTerm;
  while PeekCharWs(c) and (c=fmPower) do
  begin
	  ConvertLastRefValueTypeOnce(fmValue, First);
    SkipWhiteSpace;
    NextChar;
    PerTerm;
	  ConvertLastRefValueType(fmValue);
    AddParsed([ptgPower]);
  end;
end;

procedure TParseString.MulTerm;
// ExpTerm [ *|/ ExpTerm ]*
var
  c: widechar;
  First: boolean;
begin
  First:=true;
  ExpTerm;
  while PeekCharWs(c) and ((c=fmMul) or (c=fmDiv)) do
  begin
	  ConvertLastRefValueTypeOnce(fmValue, First);
    SkipWhiteSpace;
    NextChar;
    ExpTerm;
	  ConvertLastRefValueType(fmValue);
    if (c=fmMul) then AddParsed([ptgMul]) else AddParsed([ptgDiv]);
  end;
end;

procedure TParseString.AddTerm;
// MulTerm [ +|- MulTerm]*
var
  c: widechar;
  First: boolean;
begin
  First:=true;
  MulTerm;
  while PeekCharWs(c) and ((c=fmPlus) or (c=fmMinus)) do
  begin
	  ConvertLastRefValueTypeOnce(fmValue, First);
    SkipWhiteSpace;
    NextChar;
    MulTerm;
	  ConvertLastRefValueType(fmValue);
    if (c=fmPlus) then AddParsed([ptgAdd]) else AddParsed([ptgSub]);
  end;
end;

procedure TParseString.AndTerm;
// AddTerm [ & AddTerm]*
var
  c: widechar;
  First: boolean;
begin
  First:=true;
  AddTerm;
  while PeekCharWs(c) and (c=fmAnd) do
  begin
	  ConvertLastRefValueTypeOnce(fmValue, First);
    SkipWhiteSpace;
    NextChar;
    AddTerm;
	  ConvertLastRefValueType(fmValue);
    AddParsed([ptgConcat]);
  end;
end;

function TParseString.FindComTerm(var Ptg: byte): boolean;
var
  c,d:widechar;
  s: widestring;
  One: boolean;
begin
  Result:= PeekCharWs(c) and ((c=fmEQ) or (c=fmLT) or (c=fmGT));
  if Result then
  begin
    One:=true;
    SkipWhiteSpace; //Already granted we will add a ptg
    NextChar;
    if PeekChar(d)and((d=fmEQ) or (d=fmGT)) then
    begin
      s:=c; s:=s+d; One:=False;
      if s = fmGE then begin; NextChar; Ptg:=ptgGE; end else
      if s = fmLE then begin; NextChar; Ptg:=ptgLE; end else
      if s = fmNE then begin; NextChar; Ptg:=ptgNE; end else
      One:=True;
    end;
    If One then
      if c= fmEQ then Ptg:=ptgEQ else
      if c= fmLT then Ptg:=ptgLT else
      if c= fmGT then Ptg:=ptgGT else
      raise Exception.Create(ErrInternal);
  end;
end;

procedure TParseString.ComTerm;
// AndTerm [ = | < | > | <= | >= | <>  AndTerm]*
var
  c: widechar;
  Ptg: byte;
  First: boolean;
begin
  First:=true;
  AndTerm;
  while PeekCharWs(c) and FindComTerm(Ptg) do
  begin
    //no NextChar or SkipWhitespace here. It is added by FindComTerm
	  ConvertLastRefValueTypeOnce(fmValue, First);
    AndTerm;
	  ConvertLastRefValueType(fmValue);
    AddParsed([Ptg]);
  end;
end;

procedure TParseString.Expression;
begin
  ComTerm;
end;

procedure TParseString.GetNumber;
var
  c: widechar;
  d: double;
  w: word;
  ab: array[0..7] of byte;
  start: integer;
begin
  SkipWhiteSpace;
  start:=ParsePos;
  while PeekChar(c) and (IsNumber(c)or (c=fmFormulaDecimal)) do NextChar;
  if PeekChar(c) and ((c='e')or (c='E')) then //numbers like 1e+23
  begin
    NextChar;
    if PeekChar(c) and ((c=fmPlus)or (c=fmMinus)) then NextChar;
    while PeekChar(c) and IsNumber(c) do NextChar; //no decimals allowed here
  end;

  d:=fmStrToFloat(copy(FW, start, ParsePos-Start));

  if (round(d)=d) and (d<=$FFFF)and (d>=0) then
  begin
    w:=round(d);
    AddParsed([ptgInt, lo(w), hi(w)]);
  end else
  begin
    move(d, ab[0], length(ab));
    AddParsed([ptgNum, ab[0], ab[1], ab[2], ab[3], ab[4], ab[5], ab[6], ab[7]]);
  end;
end;

procedure TParseString.GetString;
var
  c,d,e: widechar;
  s: widestring;
  Xs: TExcelString;
  St: array of byte;
  More: boolean;
begin
  s:='';
  SkipWhiteSpace;
  if not PeekChar(c) or (c<>fmStr) then raise Exception.Create(ErrNotAString);
  NextChar;

  repeat
    More:=false;
    if PeekChar(c) and (c<>fmStr) then
    begin
      s:=s+c;
      NextChar;
      More:=true;
    end
    else
    begin
      if PeekChar(d) and (d=fmStr) and Peek2Char(e) and (e=fmStr) then
      begin
        s:=s+fmStr;
        NextChar;
        NextChar;
        More:=true;
      end;
    end;
   until not more;

   if not PeekChar(c) then raise Exception.CreateFmt(ErrUnterminatedString,[Fw]);
   NextChar;

   Xs:=TExcelString.Create(1,s);
   try
     SetLength(St, Xs.TotalSize+1);
     St[0]:=ptgStr;
     Xs.CopyToPtr(PArrayOfByte(St),1);
     AddParsed(St);
   finally
     FreeAndNil(Xs);
   end; //finally
end;

procedure TParseString.GetAlpha;
// Possibilities:
{ 1 -> Formula - We know by the "(" at the end
  2 -> Boolean - We just see if text is "true" or "false"
  3 -> Error   - No, we already cached this
  4 -> Reference - Look if it is one of the strings between A1..IV65536 (and $A$1) As it might start with $, we don't look at it here.
  5 -> 3d Ref    - Search for a '!'  As it migh start with "'" we don't look at it here.
  6 -> Named Range - if it isn't anything else...
}
var
  Start: integer;
  s: string; //no need for widestring
  c: widechar;
begin
  SkipWhiteSpace;
  start:=ParsePos;
  while PeekChar(c) and ( IsAlpha(c) or IsNumber(c) or (c='.')or (c=':')) do NextChar;
  s:=UpperCase(copy(FW, start, ParsePos-Start));

  if PeekChar(c) and (c=fmOpenParen) then GetFormula(s) else
  if PeekChar(c) and (c=fmExternalRef) then GetRef3d(s) else
  if not GetBool(s) then
  raise Exception.CreateFmt(ErrUnexpectedId,[s,Fw]);


end;

function TParseString.GetBool(const s: string): boolean;
var
  b: byte;
begin
  if s=fmTrue then b:=1 else
  if s=fmFalse then b:=0 else
  begin
    Result:=false;
    exit;
  end;

  AddParsed([ptgBool, b]);
  Result:=true;
end;

procedure TParseString.GetOneReference(var RowAbs, ColAbs: boolean;var  Row, Col: integer);
var
  c,d: widechar;
begin
  RowAbs:=false; ColAbs:=false;
  if PeekChar(c) and (c=fmAbsoluteRef) then
  begin
    ColAbs:=true;
    NextChar;
  end;
  Col:=0;
  if PeekChar(c) and IsAZ(c) then
  begin
    NextChar;
    if PeekChar(d) and IsAZ(d) then
    begin
      NextChar;
      Col:=ATo1(d)+ATo1(c)*ATo1('Z');
    end
    else Col:=ATo1(c);
  end;

  if PeekChar(c) and (c=fmAbsoluteRef) then
  begin
    RowAbs:=true;
    NextChar;
  end;

  Row:=0;
  while PeekChar(c) and IsNumber(c) and (Row<=Max_Rows+1) do
  begin
    NextChar;
    Row:=Row*10+(ord(c)-ord('0'));
  end;

end;

function TParseString.GetExternSheet(const ExternSheet: widestring): word;
var
  i: integer;
  SheetName: string;
  Sheet1, Sheet2: integer;
begin
  i:= pos (fmRangeSep, ExternSheet);
  if (i>0) then SheetName:=Copy(ExternSheet,1, i-1) else SheetName:=ExternSheet;

  if not FCellList.FindSheet(SheetName, Sheet1) then raise Exception.CreateFmt(ErrInvalidSheet, [SheetName]);

  if (i>0) then
  begin
    SheetName:=Copy(ExternSheet,i+1, Length(ExternSheet));
    if not FCellList.FindSheet(SheetName, Sheet2) then raise Exception.CreateFmt(ErrInvalidSheet, [SheetName]);
  end
    else Sheet2:=Sheet1;

  Result:=FCellList.AddExternSheet(Sheet1, Sheet2);
end;

procedure TParseString.GetGeneric3dRef(const ExternSheet: widestring);
var
  grBit1: Integer;
  rw1: Integer;
  grBit2: Integer;
  rw2: Integer;
  c: WideChar;
  Col2: Integer;
  Row2: Integer;
  ColAbs2: Boolean;
  RowAbs2: Boolean;
  Col1: Integer;
  Row1: Integer;
  ESheet: word;
  ColAbs1: Boolean;
  RowAbs1: Boolean;
begin
  RowAbs1 := False;
  ColAbs1 := False;
  Row1 := 0;
  Col1 := 0;
  RowAbs2 := False;
  ColAbs2 := False;
  Row2 := 0;
  Col2 := 0;

  ESheet:=GetExternSheet(ExternSheet);

  GetOneReference(RowAbs1, ColAbs1, Row1, Col1);
  if (Row1 > Max_Rows + 1) or (Row1 <= 0) or (Col1 <= 0) or (Col1 > Max_Columns + 1) then
    raise Exception.CreateFmt(ErrUnexpectedId, [IntToStr(Row1)+ ', '+ IntToStr(Col1), Fw]);
  c := ' ';
  if PeekChar(c) and (c = fmRangeSep) then
  begin
    NextChar;
    GetOneReference(RowAbs2, ColAbs2, Row2, Col2);
    if (Row2 > Max_Rows + 1) or (Row2 <= 0) or (Col2 <= 0) or (Col2 > Max_Columns + 1) then
      raise Exception.CreateFmt(ErrUnexpectedChar, [c, ParsePos, Fw]);
    rw1 := Row1 - 1;
    grBit1 := (Col1 - 1) and $FF;
    if not RowAbs1 then
      grBit1 := (grBit1 or $8000);
    if not ColAbs1 then
      grBit1 := (grBit1 or $4000);
    rw2 := Row2 - 1;
    grBit2 := (Col2 - 1) and $FF;
    if not RowAbs2 then
      grBit2 := (grBit2 or $8000);
    if not ColAbs2 then
      grBit2 := (grBit2 or $4000);

    AddParsed([GetRealPtg(ptgArea3d,fmRef) ,lo(ESheet), hi(ESheet), lo(Rw1), hi(Rw1), lo(Rw2), hi(Rw2), lo(grBit1), hi(grBit1), lo(grBit2), hi(grBit2)]);
  end
  else
  begin
    rw1 := Row1 - 1;
    grBit1 := (Col1 - 1) and $FF;
    if not RowAbs1 then
      grBit1 := (grBit1 or $8000);
    if not ColAbs1 then
      grBit1 := (grBit1 or $4000);
    AddParsed([GetRealPtg(ptgRef3d,fmRef) ,lo(ESheet), hi(ESheet), lo(Rw1), hi(Rw1), lo(grBit1), hi(grBit1)]);
  end;
end;

function TParseString.GetReference: boolean;
var
  RowAbs1, ColAbs1,RowAbs2, ColAbs2: boolean;
  Row1, Col1, Row2, Col2: integer;
  rw1, grBit1: word;
  rw2, grBit2: word;
  c: widechar;
  SaveParsePos: integer;
  ESheet: word;
begin
  Result:=false;
  SaveParsePos:=ParsePos;
  SkipWhiteSpace;

  GetOneReference(RowAbs1, ColAbs1, Row1, Col1);
  if (Row1>Max_Rows+1) or (Row1<=0) or (Col1<=0) or (Col1>Max_Columns+1) then
  begin
    UndoSkipWhiteSpace(SaveParsePos);
    exit;
  end;

  if PeekChar(c) and (c=fmRangeSep) then
  begin
    NextChar;
    GetOneReference(RowAbs2, ColAbs2, Row2, Col2);
    if (Row2>Max_Rows+1) or (Row2<=0) or (Col2<=0) or (Col2>Max_Columns+1) then
      raise Exception.CreateFmt(ErrUnexpectedChar, [char(c), ParsePos, Fw]);

    rw1:=Row1-1;
    grBit1:=(Col1-1) and $FF;
    if not RowAbs1 then grBit1:=grBit1 or $8000;
    if not ColAbs1 then grBit1:=grBit1 or $4000;

    rw2:=Row2-1;
    grBit2:=(Col2-1) and $FF;
    if not RowAbs2 then grBit2:=grBit2 or $8000;
    if not ColAbs2 then grBit2:=grBit2 or $4000;

    if Force3D then
    begin
      ESheet:=GetExternSheet(Default3DExternSheet);
      grBit1 := grbit1 and not $0C000;
      grBit2 := grbit2 and not $0C000;
      AddParsed([GetRealPtg(ptgArea3d,fmRef) ,lo(ESheet), hi(ESheet), lo(Rw1), hi(Rw1), lo(Rw2), hi(Rw2), lo(grBit1), hi(grBit1), lo(grBit2), hi(grBit2)]);
    end
    else
    begin
      AddParsed([GetRealPtg(ptgArea,fmRef) , lo(Rw1), hi(Rw1), lo(Rw2), hi(Rw2), lo(grBit1), hi(grBit1), lo(grBit2), hi(grBit2)]);
    end;
  end else
  begin
    rw1:=Row1-1;
    grBit1:=(Col1-1) and $FF;
    if not RowAbs1 then grBit1:=grBit1 or $8000;
    if not ColAbs1 then grBit1:=grBit1 or $4000;

    if Force3D then
    begin
      ESheet:=GetExternSheet(Default3DExternSheet);
      grBit1 := grbit1 and not $0C000;
      AddParsed([GetRealPtg(ptgRef3d,fmRef) ,lo(ESheet), hi(ESheet), lo(Rw1), hi(Rw1), lo(grBit1), hi(grBit1)]);
    end
    else
    begin
      AddParsed([GetRealPtg(ptgRef,fmRef) , lo(Rw1), hi(Rw1), lo(grBit1), hi(grBit1)]);
    end;
  end;
  Result:=true;
end;

function TParseString.IsErrorCode(const s: widestring; var b: byte): boolean;
begin
  Result:=true;
  if s= fmErrNull  then b:=fmiErrNull else
  if s= fmErrDiv0  then b:=fmiErrDiv0 else
  if s= fmErrValue then b:=fmiErrValue else
  if s= fmErrRef   then b:=fmiErrRef else
  if s= fmErrName  then b:=fmiErrName else
  if s= fmErrNum   then b:=fmiErrNum else
  if s= fmErrNA    then b:=fmiErrNA else Result:=false;
end;

procedure TParseString.GetError;
var
  b: byte;
  Start: integer;
  s: widestring;
  c: widechar;
begin
  SkipWhiteSpace;
  start:=ParsePos;

  while PeekChar(c) do
  begin
    NextChar;
    s:=WideUpperCase98(copy(FW, start, ParsePos-Start));
    if IsErrorCode(s, b) then
    begin
      AddParsed([ptgErr, b]);
      exit;
    end;

    if Length(s)>MaxErrorLen then break;
  end;

  raise Exception.CreateFmt(ErrUnexpectedId,[s,Fw]);

end;

function FindFormula(const s: widestring; var Index: integer): boolean;
var
  i:integer;
begin
  //Pending: optimize this to be binary search
  for i:=low(FuncNameArray) to High(FuncNameArray) do
    if FuncNameArray[i].Name=s then
    begin
      Result:=true;
      Index:=i;
      exit;
    end;
  Result:=False;
end;

function FuncParamType(const Index: integer; Position: integer): TFmReturnType;
begin
	if (Position+1 > Length(FuncNameArray[Index].ParamType) - 1) then Position := Length(FuncNameArray[Index].ParamType)-1;
	case (FuncNameArray[Index].ParamType[Position+1]) of
			'A': Result:= fmArray;
			'R': Result:= fmRef;
			'V': Result:= fmValue;
			'-': Result:= fmValue; //Missing Arg.
      else 	raise Exception.Create(ErrInternal);
  end; //case
end;

procedure TParseString.GetFormulaArgs(const Index: integer; var ArgCount: integer);
var
  c: Widechar;
begin
  ArgCount:=0;
  NextChar; //skip parenthesis
  while PeekChar(c) and (c<> fmCloseParen) do
  begin
    Expression;

    if PeekCharWs(c) then
      if c=fmFunctionSep then NextChar else
      if c<> fmCloseParen then raise Exception.CreateFmt(ErrUnexpectedChar, [char(c), ParsePos, Fw]);

			ConvertLastRefValueType(FuncParamType(Index, ArgCount));

    inc(argCount);
  end;

  if not PeekChar(c) then raise Exception.CreateFmt(ErrMissingParen, [Fw]);
  NextChar;

  if (ArgCount < FuncNameArray[Index].MinArgCount) or (ArgCount > FuncNameArray[Index].MaxArgCount) then
    raise Exception.CreateFmt(ErrInvalidNumberOfParams,[FuncNameArray[Index].Name, FuncNameArray[Index].MinArgCount,ArgCount]);
end;

procedure TParseString.GetFormula(const s: string);
var
  Index, ArgCount: integer;
  Ptg: byte;
begin
  if not FindFormula(s, Index) then
    raise Exception.CreateFmt(ErrFunctionNotFound,[s,Fw]);

			DirectlyInFormula := DirectlyInFormula + '1';
			try
			  GetFormulaArgs(Index, Argcount);
      finally
				Delete(DirectlyInFormula, Length(DirectlyInFormula), 1);
      end;

  if FuncNameArray[Index].MinArgCount <> FuncNameArray[Index].MaxArgCount then
  begin
    Ptg:=GetRealPtg(ptgFuncVar, FuncNameArray[Index].ReturnType);
    AddParsed([Ptg, ArgCount, lo(FuncNameArray[Index].Index), hi(FuncNameArray[Index].Index)]);
  end else
  begin
    Ptg:=GetRealPtg(ptgFunc, FuncNameArray[Index].ReturnType);
    AddParsed([Ptg, lo(FuncNameArray[Index].Index), hi(FuncNameArray[Index].Index)]);
  end;

end;

procedure TParseString.GetArray;
var
  Rows, Cols: integer;
  c: widechar;
begin
  raise exception.Create('Writing array formulas is not yet supported');
  SkipWhiteSpace;
  Rows:=1; Cols:=1;
  if not PeekChar(c) or (c<>fmOpenArray) then raise Exception.CreateFmt(ErrUnexpectedChar, [char(c), ParsePos, Fw]);
  NextChar;
  while PeekChar(c) and (c<>fmCloseArray) do
  begin
    NextChar;
    if c=fmArrayRowSep then inc(Rows) else
    if c=fmArrayColSep then inc(Cols);
  end;
  AddParsedArray([lo(Cols-1), lo(Rows-1), hi(Rows-1)]);
  //pending: add the data to array.


  if not PeekChar(c) then raise Exception.CreateFmt(ErrMissingParen, [Fw]);

  AddParsed([ptgArray, 0, 0, 0, 0, 0, 0, 0]);
end;

function TParseString.NextChar: boolean;
begin
  Result:=ParsePos<=Length(Fw);
  if Result then
  begin
    inc(ParsePos);
    if ParsePos>1024 then raise Exception.CreateFmt(ErrFormulaTooLong,[Fw]);
  end;
end;

function TParseString.PeekChar(var c: WideChar): boolean;
begin
  Result:=ParsePos<=Length(Fw);
  if Result then
  begin
    c:=Fw[ParsePos];
  end;
end;

function TParseString.Peek2Char(var c: WideChar): boolean;
begin
  Result:=ParsePos+1<=Length(Fw);
  if Result then
  begin
    c:=Fw[ParsePos+1];
  end;
end;

function TParseString.PeekCharWs(var c: WideChar): boolean;
var
  aParsePos: integer;
begin
  aParsePos:= ParsePos;
  while (aParsePos<=Length(Fw)) and (Fw[aParsePos] =' ') do begin inc(aParsePos); end;

  Result:=aParsePos<=Length(Fw);
  if Result then
  begin
    c:=Fw[aParsePos];
  end;

end;

procedure TParseString.SkipWhiteSpace;
var
  Ws: TWhitespace;
  c: widechar;
begin
  Ws.Count:=0;
  while PeekChar(c) and (c =' ') do begin NextChar; if (Ws.Count<255) then inc(Ws.Count); end;

  if ParsePos<=Length(Fw) then
  begin
    c:=Fw[ParsePos];
    if (c=fmOpenParen) then  Ws.Kind:=attr_bitFPreSpace else
    if (c=fmCloseParen) then  Ws.Kind:=attr_bitFPostSpace
    else Ws.Kind:= attr_bitFSpace;
    StackWs.Push(Ws);
  end;

end;

procedure TParseString.UndoSkipWhiteSpace(const SaveParsePos: integer);
var
  Ws: TWhiteSpace;
begin
  StackWs.Pop(Ws);
  ParsePos:=SaveParsePos;
end;

procedure TParseString.Parse;
var
  c: widechar;
  Ptr: PArrayOfByte;
begin
  LastRefOp := -1;
  DirectlyInFormula := '';
  SetLength(FParsedData,0);
  SetLength(FParsedArrayData,0);
  if not PeekChar(c) or (c<>fmStartFormula) then raise Exception.CreateFmt(ErrFormulaStart,[Fw]);
  NextChar;
  Expression;

	ConvertLastRefValueType(fmValue);

  if PeekChar(c) then raise Exception.CreateFmt(ErrUnexpectedChar,[char(c), ParsePos, Fw]);
  if StackWs.Count<>0 then raise Exception.Create(ErrInternal);

  //Try to decode what we encoded
  //something like "= >" will be encoded nicely, but will crash when decoded

  GetMem(Ptr, TotalSize);
  try
    CopyToPtr(Ptr, 0);
    try
      RPNToString(Ptr, 2, FNameTable, FCellList);
    except
      raise Exception.CreateFmt(ErrFormulaInvalid,[Fw]);
    end;
  finally
    FreeMem(Ptr);
  end; //finally
end;

procedure TParseString.PopWhiteSpace;
var
  Ws: TWhiteSpace;
begin
  StackWs.Pop(Ws);
  if Ws.Count>0 then
    AddParsed([ptgAttr,$40,Ws.Kind, Ws.Count], false);
end;


procedure TParseString.AddParsed(const s: array of byte; const PopWs: boolean=true);
begin
  if Length(s)= 0 then exit;
  if (s[0] <> ptgParen) and (s[0] <> ptgAttr) then //Those are "transparent" for reference ops.
  begin
		LastRefOp := Length(FParsedData);
	end;

  if PopWs then PopWhiteSpace;
  SetLength(FParsedData, Length(FParsedData)+ Length(s));
  move(s[0], FParsedData[Length(FParsedData)-Length(s)], Length(s));
end;

procedure TParseString.AddParsedArray(const s: array of byte);
begin
  if Length(s)= 0 then exit;
  SetLength(FParsedArrayData, Length(FParsedArrayData)+ Length(s));
  move(s[0], FParsedArrayData[Length(FParsedArrayData)-Length(s)], Length(s));
end;

function TParseString.TotalSize: integer;
begin
  Result:=2+Length(FParsedData)+Length(FParsedArrayData);
end;

procedure TParseString.CopyToPtr(const Ptr: PArrayOfByte; const aPos: integer);
var
  w: word;
begin
  w:=Length(FParsedData)+Length(FParsedArrayData);
  Move(w,ptr[aPos],2);
  Move(FParsedData[0],ptr[aPos+2], Length(FParsedData));
  Move(FParsedArrayData[0],ptr[aPos+Length(FParsedData)+2], Length(FParsedArrayData));
end;

procedure TParseString.CopyToPtrNoLen(const Ptr: PArrayOfByte; const destIndex: integer);
begin
  Move(FParsedData[0],ptr[destIndex], Length(FParsedData));
  Move(FParsedArrayData[0],ptr[destIndex+Length(FParsedData)], Length(FParsedArrayData));
end;

function TParseString.IsNumber(const c: widechar): boolean;
begin
  Result:=(ord(c)<255) and (char(c) in ['0'..'9'])
end;

function TParseString.IsAlpha(const c: widechar): boolean;
begin
  Result:=(ord(c)<255) and (char(c) in ['A'..'Z','_','\','a'..'z'])
end;

function TParseString.IsAZ(const c: widechar): boolean;
begin
  Result:=(ord(c)<255) and (char(c) in ['A'..'Z','a'..'z'])
end;

function TParseString.ATo1(const c: widechar): integer;
begin
  Result:= ord(UpCase(char(c)))-Ord('A')+1;
end;

end.
