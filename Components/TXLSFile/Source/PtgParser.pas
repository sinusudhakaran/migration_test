unit PtgParser;

{-----------------------------------------------------------------
    SM Software, 2005-2006

    Ptgs parser

    Rev history:
    2006-02-28  Add: boolean constants (TRUE, FALSE) supported
    2007-10-15  Fix: ParseAttrPtg fixed
    2008-02-22  Add: concat operator added
        
-----------------------------------------------------------------}

{$I XLSFile.inc}

interface

uses Classes, Lists, SysUtils, XLSBase, XLSLinkTable;

type
  TPtgTokenType = (ptgOperator, ptgFunction, ptgUDF, ptgOperand);

  {TPtgToken}
  TPtgToken = packed record
    TokenType: TPtgTokenType;
    Ptg: Byte;
    BinaryData: AnsiString;
    Expression: AnsiString;
    ArgsCount: Integer; // functions stuff
    IgnoreToken: Byte;
  end;
  PPtgToken = ^TPtgToken;

  TPtgTokenProc = procedure (var APtgToken: TPtgToken) of object;

  {TXLSSharedFormula}
  TXLSSharedFormula = packed record
    SheetIndex: Word;
    rwFirst: Word;
    rwLast: Word;
    colFirst: Byte;
    colLast: Byte;
    BinaryData: AnsiString;
  end;
  PXLSSharedFormula = ^TXLSSharedFormula;

  {TXLSSharedFormulas}
  TXLSSharedFormulas = class
  private
    FItems: TList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddSharedFormula(const ASheetIndex: Word; const ABinaryData: AnsiString);
    function GetSharedFormulaData(const ASheetIndex: Word; const ARow: Word;
      const AColumn: Byte): AnsiString;
  end;

  {TPtgParser}
  TPtgParser = class
  protected
    FError: Integer;
    FBinaryData: AnsiString;
    FBaseRow: Word;
    FBaseColumn: Byte;
    FExpression: AnsiString;
    FDebugInfo: AnsiString;
    FTokensList: TList;
    FExpressionStack: TStringStack;
    FSharedFormulas: TXLSSharedFormulas;
    FLinkTable: TXLSLinkTable;
    FOnParsePtgToken: TPtgTokenProc;
    FOnFreePtgToken: TPtgTokenProc;
    procedure ParseTokens;
    procedure BuildExpression;
    procedure ClearTokensList(AList: TList);
    procedure DebugTokensList(AList: TList);
  public
    constructor Create(const ALinkTable: TXLSLinkTable);
    destructor Destroy; override;
    function Parse(const ASheetIndex: Word; const ARow: Word; const AColumn: Byte;
      const AOptions: Word; const ABinaryData: AnsiString): Integer;
    procedure Clear;
    property OnParsePtgToken: TPtgTokenProc read FOnParsePtgToken write FOnParsePtgToken;
    property OnFreePtgToken: TPtgTokenProc read FOnFreePtgToken write FOnFreePtgToken;
    property Expression: AnsiString read FExpression;
    property DebugInfo: AnsiString read FDebugInfo;
    property SharedFormulas: TXLSSharedFormulas read FSharedFormulas;
  end;

implementation

uses XLSFormula, XLSRects, XLSError, Unicode;

{TXLSSharedFormulas}
constructor TXLSSharedFormulas.Create;
begin
  FItems:= TList.Create;
end;

destructor TXLSSharedFormulas.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FItems.Count-1 do
    if Assigned(FItems[I]) then
      Dispose(PXLSSharedFormula(FItems[I]));
  FItems.Destroy;
  inherited;
end;

procedure TXLSSharedFormulas.AddSharedFormula(const ASheetIndex: Word;
  const ABinaryData: AnsiString);
var
  P: PXLSSharedFormula;
  rwFirst: Word;
  rwLast: Word;
  colFirst: Byte;
  colLast: Byte;
  BinaryData: AnsiString;
begin
  New(P);

  rwFirst:= 0;
  rwLast:= 0;
  colFirst:= 0;
  colLast:= 0;
  Move(ABinaryData[1], rwFirst, 2);
  Move(ABinaryData[3], rwLast, 2);
  Move(ABinaryData[5], colFirst, 1);
  Move(ABinaryData[6], colLast, 1);
  BinaryData:= Copy(ABinaryData, 11, Length(ABinaryData) - 10);

  P^.SheetIndex:= ASheetIndex;
  P^.rwFirst:= rwFirst;
  P^.rwLast:= rwLast;
  P^.colFirst:= colFirst;
  P^.colLast:= colLast;
  P^.BinaryData:= BinaryData;

  FItems.Add(P);
end;

function TXLSSharedFormulas.GetSharedFormulaData(const ASheetIndex: Word;
  const ARow: Word; const AColumn: Byte): AnsiString;
var
  I: Integer;
  P: PXLSSharedFormula;
begin
  Result:= '';
  for I:= 0 to FItems.Count-1 do
  begin
    P:= PXLSSharedFormula(FItems[I]);
    if    ( P^.SheetIndex = ASheetIndex )
      and ( P^.rwFirst <= ARow ) and ( P^.rwLast >= ARow )
      and ( P^.colFirst <= AColumn ) and ( P^.colLAst >= AColumn ) then
    begin
      Result:= P^.BinaryData;
      Break;
    end;
  end;
end;

{TPtgParser}
constructor TPtgParser.Create(const ALinkTable: TXLSLinkTable);
begin
  FError:= 0;
  FExpression:= '';
  FTokensList:= TList.Create;
  FExpressionStack:= TStringStack.Create;
  FSharedFormulas:= TXLSSharedFormulas.Create;
  FLinkTable:= ALinkTable;
end;

destructor TPtgParser.Destroy;
begin
  Clear;

  FTokensList.Destroy;
  FExpressionStack.Destroy;
  FSharedFormulas.Destroy;
  inherited;
end;

procedure TPtgParser.Clear;
begin
  ClearTokensList(FTokensList);
end;

procedure TPtgParser.ClearTokensList(AList: TList);
var
  I: Integer;
begin
  for I:= 0 to AList.Count-1 do
    if Assigned(AList[I]) then
    begin
      if Assigned(OnFreePtgToken) then
        OnFreePtgToken(PPtgToken(AList[I])^);
      Dispose(PPtgToken(AList[I]));
    end;
  AList.Clear;
end;

procedure TPtgParser.DebugTokensList(AList: TList);
var
  I: Integer;
begin
  for I:= 0 to AList.Count-1 do
    if Assigned(AList[I]) then
      FDebugInfo:= FDebugInfo + PPtgToken(AList[I])^.Expression + #13#10;
end;

function TPtgParser.Parse(const ASheetIndex: Word;
  const ARow: Word; const AColumn: Byte;
  const AOptions: Word; const ABinaryData: AnsiString): Integer;
begin
  { Initialize parsing options }
  Result:= 0;
  FError:= 0;
  FDebugInfo:= '';
  FExpression:= '';
  FBaseRow:= ARow;
  FBaseColumn:= AColumn;

  { Is shared formula }
  if (AOptions and $08) <> 0 then
  begin
    FBinaryData:= SharedFormulas.GetSharedFormulaData(ASheetIndex, ARow, AColumn);
    if (FBinaryData = '') then
      FBinaryData:= ABinaryData;
  end
  else
    FBinaryData:= ABinaryData;

  { Clear all structures }
  Clear;
  { Extract tokens }
  ParseTokens;
  if FError <> 0 then
  begin
    Result:= FError;
    Exit;
  end;

  { Build tokens to expression }
  BuildExpression;
end;

procedure TPtgParser.ParseTokens;
var
  CurentPosition: Integer;
  Ptg: Byte;
  BinaryData: AnsiString;
  PToken: PPtgToken;
  AddBase: Boolean;

  { Operator }
  procedure ParseOperatorPtg;
  begin
    PToken^.TokenType:= ptgOperator;
    PToken^.BinaryData:= '';

    case PToken^.Ptg of
      FMLA_PTG_ADD:    PToken^.Expression:= '+';
      FMLA_PTG_SUB:    PToken^.Expression:= '-';
      FMLA_PTG_MUL:    PToken^.Expression:= '*';
      FMLA_PTG_DIV:    PToken^.Expression:= '/';
      FMLA_PTG_LT:     PToken^.Expression:= '<';
      FMLA_PTG_LE:     PToken^.Expression:= '<=';
      FMLA_PTG_EQ:     PToken^.Expression:= '=';
      FMLA_PTG_GE:     PToken^.Expression:= '>=';
      FMLA_PTG_GT:     PToken^.Expression:= '>';
      FMLA_PTG_NE:     PToken^.Expression:= '<>';
      FMLA_PTG_PAREN:  PToken^.Expression:= '';
      FMLA_PTG_CONCAT: PToken^.Expression:= '&';
      FMLA_PTG_RANGE:  PToken^.Expression:= ':';
    end;
  end;

  { Function }
  procedure ParseFunctionPtg;
  var
    FunctionCode: Integer;
    FunctionName: AnsiString;
    ArgsCount: Byte;
    I: Integer;
  begin
    PToken^.TokenType:= ptgFunction;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 3);

    ArgsCount:= Byte(PToken^.BinaryData[1]);
    FunctionCode:= 0;
    Move(PToken^.BinaryData[2], FunctionCode, 2);
    FunctionName:= '';
    for I:= 0 to FMLA_FUNCTIONS_COUNT - 1 do
    begin
      if (FmlaFunctions[I].Code = FunctionCode) then
      begin
        FunctionName:= FmlaFunctions[I].Name;
        Break;
      end;
    end;

    if (FunctionCode = FMLA_FUNCTION_UDF) then
    begin
      //FunctionName:= '<UDF>';
      PToken^.TokenType:= ptgUDF;
    end;

    if (FunctionName = '') then
    begin
      FError:= -1;
      Exit;
    end;
    
    PToken^.Expression:= FunctionName;
    PToken^.ArgsCount:= ArgsCount;
  end;

  { Function with fixed number of arguments }
  procedure ParseFunctionFixedPtg;
  var
    FunctionCode: Integer;
    FunctionName: AnsiString;
    ArgsCount: Integer;
    I: Integer;
  begin
    PToken^.TokenType:= ptgFunction;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 2);

    FunctionCode:= 0;
    ArgsCount:= -1;
    Move(PToken^.BinaryData[1], FunctionCode, 2);
    FunctionName:= '';
    for I:= 0 to FMLA_FUNCTIONS_COUNT - 1 do
    begin
      if (FmlaFunctions[I].Code = FunctionCode) then
      begin
        FunctionName:= FmlaFunctions[I].Name;
        ArgsCount:= FmlaFunctions[I].ArgsCount;
        Break;
      end;
    end;

    if (ArgsCount < 0) or (FunctionName = '') then
    begin
      FError:= -1;
      Exit;
    end;

    PToken^.Expression:= FunctionName;
    PToken^.ArgsCount:= ArgsCount;
  end;

  { Ref }
  procedure ParseRefPtg;
  var
    Row: Integer;
    Column: Integer;
    RelativeFlags: Byte;
    RowPrefix, ColumnPrefix: AnsiString;
    AbsoluteRow, AbsoluteColumn: Boolean;
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 4);

    Row:= 0;
    Column:= 0;
    RelativeFlags:= 0;
    Move(PToken^.BinaryData[1], Row, 2);
    Move(PToken^.BinaryData[3], Column, 1);
    Move(PToken^.BinaryData[4], RelativeFlags, 1);

    AbsoluteRow:= ((RelativeFlags and $80) = 0);
    AbsoluteColumn:= ((RelativeFlags and $40) = 0);

    if AddBase then
    begin
      if not AbsoluteRow then Row:= (Row + FBaseRow) and $FFFF;
      if not AbsoluteColumn then Column:= (Column + FBaseColumn) and $FF;
    end;

    if AbsoluteRow then RowPrefix:= '$' else RowPrefix:= '';
    if AbsoluteColumn then ColumnPrefix:= '$' else ColumnPrefix:= '';
    PToken^.Expression:= ColumnPrefix + ColIndexToColName(Column)
                       + RowPrefix + AnsiString(IntToStr(Row + 1));
  end;

  { Ref N }
  procedure ParseRefNPtg;
  begin
    AddBase:= True;
    ParseRefPtg;
    AddBase:= False;
  end;

  { Area }
  procedure ParseAreaPtg;
  var
    RowFrom, RowTo: Integer;
    ColumnFrom, ColumnTo: Integer;
    RelativeFlagsFrom, RelativeFlagsTo: Byte;
    RowPrefixFrom, RowPrefixTo, ColumnPrefixFrom, ColumnPrefixTo: AnsiString;
    AbsoluteRowFrom, AbsoluteRowTo, AbsoluteColumnFrom, AbsoluteColumnTo: Boolean;    
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 8);

    RowFrom:= 0;
    RowTo:= 0;
    ColumnFrom:= 0;
    ColumnTo:= 0;
    RelativeFlagsFrom:= 0;
    RelativeFlagsTo:= 0;
    Move(PToken^.BinaryData[1], RowFrom, 2);
    Move(PToken^.BinaryData[3], RowTo, 2);
    Move(PToken^.BinaryData[5], ColumnFrom, 1);
    Move(PToken^.BinaryData[6], RelativeFlagsFrom, 1);
    Move(PToken^.BinaryData[7], ColumnTo, 1);
    Move(PToken^.BinaryData[8], RelativeFlagsTo, 1);

    AbsoluteRowFrom:= ((RelativeFlagsFrom and $80) = 0);
    AbsoluteColumnFrom:= ((RelativeFlagsFrom and $40) = 0);
    AbsoluteRowTo:= ((RelativeFlagsTo and $80) = 0);
    AbsoluteColumnTo:= ((RelativeFlagsTo and $40) = 0);

    if AddBase then
    begin
      if not AbsoluteRowFrom then RowFrom   := (RowFrom + FBaseRow) and $FFFF;
      if not AbsoluteRowTo   then RowTo     := (RowTo + FBaseRow) and $FFFF;
      if not AbsoluteColumnFrom then ColumnFrom:= (ColumnFrom + FBaseColumn) and $FF;
      if not AbsoluteColumnTo   then ColumnTo  := (ColumnTo   + FBaseColumn) and $FF;
    end;

    if AbsoluteRowFrom then RowPrefixFrom:= '$' else RowPrefixFrom:= '';
    if AbsoluteColumnFrom then ColumnPrefixFrom:= '$' else ColumnPrefixFrom:= '';
    if AbsoluteRowTo then RowPrefixTo:= '$' else RowPrefixTo:= '';
    if AbsoluteColumnTo then ColumnPrefixTo:= '$' else ColumnPrefixTo:= '';

    PToken^.Expression:= ColumnPrefixFrom + ColIndexToColName(ColumnFrom) +
                         RowPrefixFrom + AnsiString(IntToStr(RowFrom + 1)) + ':' +
                         ColumnPrefixTo + ColIndexToColName(ColumnTo) +
                         RowPrefixTo + AnsiString(IntToStr(RowTo + 1));
  end;

  { Area N }
  procedure ParseAreaNPtg;
  begin
    AddBase:= True;
    ParseAreaPtg;    
    AddBase:= False;
  end;

  { 3d ref }
  procedure Parse3dRefPtg;
  var
    Row: Integer;
    Column: Byte;
    XTIIndex: Integer;
    RelativeFlags: Byte;
    RowPrefix, ColumnPrefix: AnsiString;
    AreaName: WideString;
    Par: TXLSLinkParameters;    
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 6);

    Row:= 0;
    Column:= 0;
    XTIIndex:= 0;
    RelativeFlags:= 0;
    Move(PToken^.BinaryData[1], XTIIndex, 2);
    Move(PToken^.BinaryData[3], Row, 2);
    Move(PToken^.BinaryData[5], Column, 1);
    Move(PToken^.BinaryData[6], RelativeFlags, 1);

    { Get area name }
    Par.ExternSheetIndex:= XTIIndex;
    Par.LinkType:= tlSheet;
    FLinkTable.CompileLinkText(Par);
    AreaName:= Par.LinkText;

    if (RelativeFlags and $80) = 0 then RowPrefix:= '$' else RowPrefix:= '';
    if (RelativeFlags and $40) = 0 then ColumnPrefix:= '$' else ColumnPrefix:= '';

    PToken^.Expression:= AnsiString(AreaName) + '!' +
                         ColumnPrefix + ColIndexToColName(Column) +
                         RowPrefix + AnsiString(IntToStr(Row + 1));
  end;

  { 3d area }
  procedure Parse3dAreaPtg;
  var
    RowFrom, RowTo: Integer;
    ColumnFrom, ColumnTo: Byte;
    XTIIndex: Integer;
    RelativeFlagsFrom, RelativeFlagsTo: Byte;
    RowPrefixFrom, RowPrefixTo, ColumnPrefixFrom, ColumnPrefixTo: AnsiString;
    AreaName: WideString;
    Par: TXLSLinkParameters;
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 10);

    RowFrom:= 0;
    RowTo:= 0;
    ColumnFrom:= 0;
    ColumnTo:= 0;
    XTIIndex:= 0;
    RelativeFlagsFrom:= 0;
    RelativeFlagsTo:= 0;
    Move(PToken^.BinaryData[1], XTIIndex, 2);
    Move(PToken^.BinaryData[3], RowFrom, 2);
    Move(PToken^.BinaryData[5], RowTo, 2);
    Move(PToken^.BinaryData[7], ColumnFrom, 1);
    Move(PToken^.BinaryData[8], RelativeFlagsFrom, 1);
    Move(PToken^.BinaryData[9], ColumnTo, 1);
    Move(PToken^.BinaryData[10], RelativeFlagsTo, 1);

    if (RelativeFlagsFrom and $80) = 0 then RowPrefixFrom:= '$' else RowPrefixFrom:= '';
    if (RelativeFlagsFrom and $40) = 0 then ColumnPrefixFrom:= '$' else ColumnPrefixFrom:= '';
    if (RelativeFlagsTo and $80) = 0 then RowPrefixTo:= '$' else RowPrefixTo:= '';
    if (RelativeFlagsTo and $40) = 0 then ColumnPrefixTo:= '$' else ColumnPrefixTo:= '';

    { Get area name }
    Par.ExternSheetIndex:= XTIIndex;
    Par.LinkType:= tlSheet;
    FLinkTable.CompileLinkText(Par);
    AreaName:= Par.LinkText;

    PToken^.Expression:= AnsiString(AreaName) + '!' +
                         ColumnPrefixFrom + ColIndexToColName(ColumnFrom) +
                         RowPrefixFrom + AnsiString(IntToStr(RowFrom + 1)) + ':' +
                         ColumnPrefixTo + ColIndexToColName(ColumnTo) +
                         RowPrefixTo + AnsiString(IntToStr(RowTo + 1));
  end;

  { Name }
  procedure ParseName;
  var
    NameIndex: Integer;
    AreaName: WideString;
    Par: TXLSLinkParameters;
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 4);

    NameIndex:= 0;
    Move(PToken^.BinaryData[1], NameIndex, 2);

    { Get area name }
    Par.NameIndex:= NameIndex - 1; // NameIndes was 1-based
    Par.LinkType:= tlName;
    FLinkTable.CompileLinkText(Par);
    AreaName:= Par.LinkText;

    PToken^.Expression:= AnsiString(AreaName);
  end;

  { External name }
  procedure ParseExternalName;
  var
    XTIIndex: Integer;
    NameIndex: Integer;
    AreaName: WideString;
    Par: TXLSLinkParameters;
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 6);

    NameIndex:= 0;
    Move(PToken^.BinaryData[1], XTIIndex, 2);    
    Move(PToken^.BinaryData[3], NameIndex, 2);

    { Get area name }
    Par.ExternSheetIndex:= XTIIndex;
    Par.NameIndex:= NameIndex - 1; // name index was 1-based
    Par.LinkType:= tlExternalName;
    FLinkTable.CompileLinkText(Par);
    AreaName:= Par.LinkText;

    PToken^.Expression:= AnsiString(AreaName);
  end;

  { Int }
  procedure ParseIntPtg;
  var
    I: Integer;
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 2);
    I:= 0;
    Move(PToken^.BinaryData[1], I, 2);
    PToken^.Expression:= AnsiString(IntToStr(I));
  end;

  { Boolean }
  procedure ParseBoolPtg;
  var
    B: Byte;
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 1);
    B:= 0;
    Move(PToken^.BinaryData[1], B, 1);
    if (B = 1) then
      PToken^.Expression:= 'TRUE'
    else
      PToken^.Expression:= 'FALSE';    
  end;

  { Number }
  procedure ParseNumberPtg;
  var
    D: Double;
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, SizeOf(Double));
    D:= 0;
    Move(PToken^.BinaryData[1], D, SizeOf(Double));
    PToken^.Expression:= AnsiString(FloatToStr(D));
  end;

  { String }
  procedure ParseStringPtg;
  var
    StringLen: Byte;
    UnicodeFlag: Byte;
    S: AnsiString;
  begin
    PToken^.TokenType:= ptgOperand;

    S:= '';
    UnicodeFlag:= 0;
    StringLen:= Byte(FBinaryData[CurentPosition + 1]);
    if ( StringLen <> 0 ) then
    begin
      UnicodeFlag:= (Byte(FBinaryData[CurentPosition + 2]) and $01);
      if UnicodeFlag = 1 then
        StringLen:= StringLen * 2;
    end;
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, StringLen + 2);

    if ( StringLen <> 0 ) then
    begin
      S:= Copy(PToken^.BinaryData, 3, StringLen);
      if UnicodeFlag = 1 then
      begin
        S:= ANSIWideStringToString(S);
      end;
    end;
    PToken^.Expression:= '"' + S + '"';
  end;

  { ptgAttr }
  procedure ParseAttrPtg;
  var
    Options: Byte;
  begin
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 3);
    Options:= Byte(PToken^.BinaryData[1]);

    { Ignore some sub-tokens }
    if   ( (Options and $40) <> 0 )  // space
      or ( (Options and $02) <> 0 )  // optimized IF function
      or ( (Options and $08) <> 0 )  // goto
      or ( (Options and $01) <> 0 )  // volatile function
      then
    begin
      PToken^.IgnoreToken:= 1;
      Exit;
    end;

    { Optimized SUM function - function with 1 argument }
    if ( (Options and $10) <> 0 ) then
    begin
      PToken^.TokenType:= ptgFunction;
      PToken^.ArgsCount:= 1;
      PToken^.Expression:= 'SUM';
      Exit;
    end;

    { Else error }
    FError:= -1;
  end;

  { ptgMemFunc }
  procedure ParseMemFunc;
  begin
    PToken^.BinaryData:= Copy(FBinaryData, CurentPosition + 1, 2);
    PToken^.IgnoreToken:= 1;
  end;

  { ptgMissArg }
  procedure ParseMissingArg;
  begin
    PToken^.TokenType:= ptgOperand;
    PToken^.BinaryData:= '';
    PToken^.Expression:= '';
  end;

begin
  AddBase:= False;
  CurentPosition:= 1;
  BinaryData:= '';

  while (CurentPosition <= Length(FBinaryData)) do
  begin
    Ptg:= Byte(FBinaryData[CurentPosition]);
    New(PToken);
    PToken^.Ptg:= Ptg;
    PToken^.IgnoreToken:= 0;

    case Ptg of
      FMLA_PTG_ADD,
      FMLA_PTG_SUB,
      FMLA_PTG_MUL,
      FMLA_PTG_DIV,
      FMLA_PTG_LT,
      FMLA_PTG_LE,
      FMLA_PTG_EQ,
      FMLA_PTG_GE,
      FMLA_PTG_GT,
      FMLA_PTG_NE,
      FMLA_PTG_PAREN,
      FMLA_PTG_CONCAT,
      FMLA_PTG_RANGE:      ParseOperatorPtg;

      FMLA_PTG_MEMFUNC:    ParseMemFunc;

      FMLA_PTG_MISARG:     ParseMissingArg;

      FMLA_PTG_FUNC,
      FMLA_PTG_FUNC_REF,
      FMLA_PTG_FUNC_ARR:   ParseFunctionPtg;
      
      FMLA_PTG_FUNCF,
      FMLA_PTG_FUNCF_REF,
      FMLA_PTG_FUNCF_ARR:  ParseFunctionFixedPtg;

      FMLA_PTG_ATTR:       ParseAttrPtg;

      FMLA_PTG_REF_VAL,
      FMLA_PTG_REF_REF,
      FMLA_PTG_REF_ARR:    ParseRefPtg;

      FMLA_PTG_N_REF_VAL,
      FMLA_PTG_N_REF_REF,
      FMLA_PTG_N_REF_ARR:  ParseRefNPtg;

      FMLA_PTG_AREA_VAL,
      FMLA_PTG_AREA_REF,
      FMLA_PTG_AREA_ARR:   ParseAreaPtg;

      FMLA_PTG_N_AREA_VAL,
      FMLA_PTG_N_AREA_REF,
      FMLA_PTG_N_AREA_ARR: ParseAreaNPtg;

      FMLA_PTG_3DREF_VAL,
      FMLA_PTG_3DREF_REF,
      FMLA_PTG_3DREF_ARR:  Parse3dRefPtg;

      FMLA_PTG_3DAREA_VAL,
      FMLA_PTG_3DAREA_REF,
      FMLA_PTG_3DAREA_ARR: Parse3dAreaPtg;

      FMLA_PTG_NAME,
      FMLA_PTG_NAME_VAL,
      FMLA_PTG_NAME_ARR:   ParseName;

      FMLA_PTG_NAMEX,
      FMLA_PTG_NAMEX_VAL,
      FMLA_PTG_NAMEX_ARR:  ParseExternalName;

      FMLA_PTG_INT:        ParseIntPtg;
      FMLA_PTG_NUM:        ParseNumberPtg;
      FMLA_PTG_STR:        ParseStringPtg;
      FMLA_PTG_BOOL:       ParseBoolPtg;
      else
        { Ptg not recognized }
        begin
          FError:= -1;
          Break;
        end;
    end;

    if FError <> 0 then
    begin
      Dispose(PToken);
      Exit;
    end;

    { Shift current position }
    CurentPosition:= CurentPosition + 1 + Length(PToken^.BinaryData);

    { Add new token to list }
    if (PToken^.IgnoreToken = 0) then
      FTokensList.Add(PToken)
    else
      Dispose(PToken);
  end;

end;

procedure TPtgParser.BuildExpression;
var
  CurrentToken: Integer;
  PToken: PPtgToken;

  procedure ProcessOperandToken;
  begin
    { Add operand to stack }
    FExpressionStack.Push(PToken^.Expression);
  end;

  procedure ProcessOperatorToken;
  var
    AExpression, AExpression2 : AnsiString;
  begin
    case PToken^.Ptg of
      FMLA_PTG_PAREN:
        begin
          { Get one operand }
          AExpression:= FExpressionStack.Pop;
          { Add braces }
          AExpression:= '(' + AExpression + ')';
          { and add new operand to stack}
          FExpressionStack.Push(AExpression);
        end;
      else
        begin
          { All other operators are binary }
          { Get 2 operands }
          AExpression:= FExpressionStack.Pop;
          AExpression2:= FExpressionStack.Pop;
          { Apply binary operator }
          AExpression:= AExpression2 + PToken^.Expression + AExpression;
          { and add new operand to stack}
          FExpressionStack.Push(AExpression);
        end;
    end;
  end;

  procedure ProcessFunctionToken;
  var
    AExpression, AArgumentExpression: AnsiString;
    I: Integer;
  begin
    AExpression:= '';
    { Build arguments list }
    for I:= 0 to PToken^.ArgsCount - 1 do
    begin
      AArgumentExpression:= FExpressionStack.Pop;
      if (I = 0) then
        AExpression:= AArgumentExpression
      else
        AExpression:= AArgumentExpression + FMLA_ARG_SEPARATOR + AExpression;
    end;
    { Apply function }
    AExpression:= PToken^.Expression + '(' + AExpression + ')';
    { and add new operand to stack}
    FExpressionStack.Push(AExpression);
  end;

  procedure ProcessUDFFunctionToken;
  var
    AExpression, AFuncExpression, AArgumentExpression: AnsiString;
    I: Integer;
  begin
    AExpression:= '';
    AFuncExpression:= '';

    { Build arguments list }
    for I:= 0 to PToken^.ArgsCount - 1 do
    begin
      AArgumentExpression:= FExpressionStack.Pop;

      if (I = (PToken^.ArgsCount - 1)) then
        { Last argument is a function name }
        AFuncExpression:= AArgumentExpression
      else if (I = 0) then
        AExpression:= AArgumentExpression
      else
        AExpression:= AArgumentExpression + FMLA_ARG_SEPARATOR + AExpression;
    end;
    { Apply function }
    AExpression:= AFuncExpression + '(' + AExpression + ')';
    { and add new operand to stack}
    FExpressionStack.Push(AExpression);
  end;

begin
  FExpressionStack.Clear;

  for CurrentToken:= 0 to FTokensList.Count - 1 do
  begin
    PToken:= PPtgToken(FTokensList[CurrentToken]);
    case PToken^.TokenType of
      ptgOperator: ProcessOperatorToken;
      ptgFunction: ProcessFunctionToken;
      ptgUDF     : ProcessUDFFunctionToken;
      ptgOperand:  ProcessOperandToken;
    end;
  end;

  if FExpressionStack.Count > 0 then
    FExpression:= FExpressionStack[0];

  FExpressionStack.Clear;
end;

end.
