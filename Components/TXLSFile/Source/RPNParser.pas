unit RPNParser;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    Reverse Polish Notation (RPN) Expression parser
    &
    Formula parser

    RPN parser history:
    2004-02-18  Fix: use Dispose (but not FreeMem) to free PToken 
    2005-04-10  Add: Arg separator forces operators stack processing
    2006-04-19  Fix: Free orphan tokens
    2006-10-03  Fix: Compare priority as >= when analyze operators' stack
    2006-11-17  Fix: Recognize quoted names    

    Formula parser history:
    2005-03-12  3D refs added
                Fix: use Dispose (but not FreeMem) to free PToken
    2005-04-10  Add: logical operands and functions added
    2005-10-09  Add: more statistics functions added
    2006-02-28  Add: boolean constants (TRUE, FALSE) supported     
    2006-08-30  Fix: Priority changed for * operator
                Add: new functions added
    2007-12-12  FREQUENCY function added
    2008-09-27  Add: Missing arguments added
    
-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses
    Classes
  , Lists
  , XLSBase
  , XLSFormula
  , XLSRects
  , HList
  , XLSLinkTable;

type
  TTokenType = (ttOperator, ttFunction, ttOperand, ttArgSeparator);

  { TToken }
  TToken = packed record
    TokenType     : TTokenType;
    TokenSubtype  : Integer;
    Value         : AnsiString;
    Priority      : Integer;
    ArgCounter    : Integer;
    BraceCounter  : Integer;
    HaveArgs      : Boolean;
    RefRequired   : Boolean; // ref required in cell reference
    SubtreeTokens : Integer; // tokens in subtree
    Data          : Pointer;
    RawData       : AnsiString;  // parsed raw data
  end;
  PToken = ^TToken;

  TOperator = String;
  TFunction = String;

  TTokenProc = procedure (var AToken: TToken) of object;

  { TRPNParser }
  TRPNParser = class
  protected
    FExpression: AnsiString;
    FSeparators: TAnsiStringList;
    FArgSeparator: AnsiChar;
    FStringQuote: AnsiChar;
    FNameQuote: AnsiChar;
    FInTokensList: TList;
    FOutTokensList: TList;
    FOperatorsStack: TStack;
    FFunctionsStack: TStack;

    FOnParseToken: TTokenProc;
    FOnFreeToken: TTokenProc;
    procedure ParseTokens;
    procedure RearrangeTokens;
    procedure FreeToken(P: PToken);
    procedure ClearTokensList(AList: TList);
    procedure ClearTokensStack(AStack: TStack);
    function GetOutToken(Ind: Integer): PToken;
    function GetOutTokensCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Parse(const AExpression: AnsiString;
      ASeparators: TAnsiStringList;
      AStringQuote: AnsiChar);
    procedure Clear;
    property OnParseToken: TTokenProc read FOnParseToken write FOnParseToken;
    property OnFreeToken: TTokenProc read FOnFreeToken write FOnFreeToken;
    property OutToken[Ind: Integer]: PToken read GetOutToken;
    property OutTokensCount: Integer read GetOutTokensCount;
  end;

  {TXLSFormulaParser}
  TXLSFormulaParser = class
  private
    FBaseRow: Word;
    FBaseColumn: Byte;
    FSharedFormulaParse: Boolean;
  protected
    FFormula: AnsiString;
    FParser: TRPNParser;
    FOperators: TAnsiStringList;
    FSeparators: TAnsiStringList;
    FFunctions: THashedStringList;
    FLinkTable: TXLSLinkTable;
    procedure FreeTokenData(var AToken: TToken);
    procedure GetTokenPrior(var AToken: TToken);
    procedure ParseToken(var AToken: TToken);
    function GetNumberString(ANumber: Double): AnsiString;
    function GetBoolString(ABool: Byte): AnsiString;
    function GetStringString(AString: AnsiString): AnsiString;
    function GetCellString(const ALinkParam: TXLSLinkParameters; const RefRequired: Boolean): AnsiString;
    function GetAreaString(const ALinkParam: TXLSLinkParameters; const RefRequired: Boolean): AnsiString;
    function Get3DCellString(const ALinkParam: TXLSLinkParameters; const RefRequired: Boolean): AnsiString;
    function Get3DAreaString(const ALinkParam: TXLSLinkParameters): AnsiString;
    function GetNameString(const ALinkParam: TXLSLinkParameters): AnsiString;
    function GetExternalNameString(const ALinkParam: TXLSLinkParameters): AnsiString;
    function GetOperatorString(AOperator: AnsiString): AnsiString;
    function GetFunctionString(const AFunction: AnsiString;
      const AArgsCount: Integer; const RefRequired: Boolean): AnsiString;
    function InternalParse(const AFormula: AnsiString): AnsiString;
  public
    constructor Create(const ALinkTable: TXLSLinkTable);
    destructor Destroy; override;
    function Parse(const AFormula: AnsiString): AnsiString;
    function ParseForSharedFormula(const AFormula: AnsiString; ABaseRow: Word;
      ABaseColumn: Byte): AnsiString;
  end;

  {TXLSXFormulaParser}
  TXLSXFormulaParser = class
  protected
    FFormula: AnsiString;
    FLinkTable: TXLSLinkTable;
  public
    constructor Create(const ALinkTable: TXLSLinkTable);
    destructor Destroy; override;
    function Parse(const AFormula: WideString): WideString;
  end;

  PDouble = ^Double;
  PByte = ^Byte;
  PWord = ^Word;

  
implementation
uses
    SysUtils
  , XLSError
  , Unicode
  {$IFDEF XLF_D2009}
  , AnsiStrings
  {$ENDIF}
  ;

{TRPNParser}
constructor TRPNParser.Create;
begin
  FInTokensList:= TList.Create;
  FOutTokensList:= TList.Create;
  FOperatorsStack:= TStack.Create;
  FFunctionsStack:= TStack.Create;
end;

destructor TRPNParser.Destroy;
begin
  Clear;
  FInTokensList.Destroy;
  FOutTokensList.Destroy;
  FOperatorsStack.Destroy;
  FFunctionsStack.Destroy;
  inherited;
end;

procedure TRPNParser.Clear;
begin
  ClearTokensList(FInTokensList);
  ClearTokensList(FOutTokensList);
  ClearTokensStack(FOperatorsStack);
  ClearTokensStack(FFunctionsStack);
end;

procedure TRPNParser.FreeToken(P: PToken);
begin
  if Assigned(P) then
  begin
    if Assigned(OnFreeToken) then
      OnFreeToken(P^);
    Dispose(P);
  end;
end;

procedure TRPNParser.ClearTokensList(AList: TList);
var
  I: integer;
begin
  for I:= 0 to AList.Count-1 do
    FreeToken(PToken(AList[I]));

  AList.Clear;
end;

procedure TRPNParser.ClearTokensStack(AStack: TStack);
var
  P: PToken;
begin
  while AStack.Count>0 do
  begin
    P:= AStack.Pop;
    FreeToken(P);
  end;
end;

function TRPNParser.GetOutToken(Ind: Integer): PToken;
begin
  result:= PToken(FOutTokensList[Ind]);
end;

function TRPNParser.GetOutTokensCount: Integer;
begin
  result:= FOutTokensList.Count;
end;

procedure TRPNParser.Parse(const AExpression: AnsiString;
  ASeparators: TAnsiStringList; AStringQuote: AnsiChar);
begin
  FExpression:= AExpression;
  FSeparators:= ASeparators;
  FStringQuote:= AStringQuote;
  FNameQuote:= '''';

  ParseTokens;
  RearrangeTokens;
end;

procedure TRPNParser.ParseTokens;
var
  I: integer;
  SToken, SOperator: AnsiString;
  P: PToken;
  InString: boolean;
  InName: boolean;

  procedure AddToken;
  begin
    {$IFDEF XLF_D2009}
    SToken:= AnsiStrings.Trim(SToken);
    {$ELSE}
    SToken:= Trim(SToken);
    {$ENDIF}
    if (SToken <> '') then
    begin
      New(P);
      P^.Value:= SToken;
      SToken:= '';
      FInTokensList.Add(P);
      if Assigned(OnParseToken) then
        OnParseToken(P^);
    end;
  end;

begin
  I:= 1;
  SToken:= '';
  InString:= false;
  InName:= false;

  { Here assume that operators may be of 1 or 2 characters length }
  while (I <= Length(FExpression)) do
  begin
    if     (FSeparators.IndexOf(FExpression[I]) >= 0)
       and (not InString)
       and (not InName)
       then
    begin
      { Add previous token }
      AddToken;

      { Start parsing operator or separator token }
      SToken:= FExpression[I];

      { Try 2-characters operator }
      SOperator:= SToken;
      if (I + 1 <= Length(FExpression)) then
      begin
        SOperator:= SOperator + FExpression[I + 1];
        if (FSeparators.IndexOf(SOperator) >= 0) then
        begin
          SToken:= SOperator;
          Inc(I);
        end;
      end;

      { Catch empty argument }
      if (I + 1 <= Length(FExpression)) then
      begin
        if (    (SToken = FMLA_ARG_SEPARATOR)
            and (FExpression[I + 1] in [')', FMLA_ARG_SEPARATOR])
           ) then
        begin
          AddToken;
          SToken:= '<MISARG>';
        end;
      end;

      AddToken;
    end
    else
    begin
      if (FExpression[I] = ' ') then
      begin
        SToken:= SToken + FExpression[I];
      end
      else if (FExpression[I] = FStringQuote) then
      begin
        SToken:= SToken + FExpression[I];
        if (not InName) then
        begin
          if InString then
            AddToken;
          InString:= not InString;
        end  
      end
      else if (FExpression[I] = FNameQuote) then
      begin
        SToken:= SToken + FExpression[I];
        if (not InString) then
          InName:= not InName;
      end
      else if (FExpression[I] = ':')
         and (not InString)
         and (not InName)
         and (SToken = '') // Previous token completely processed
         then
      begin
        SToken:= FExpression[I];
        AddToken;      
      end
      else
        SToken:= SToken + FExpression[I];
    end;

    Inc(I);
  end;

  AddToken;
end;

procedure TRPNParser.RearrangeTokens;
var
  I: Integer;
  P: PToken;
  POperator: PToken;
  PFunction: PToken;

  procedure PreprocessUDFTokens;
  var
    I: Integer;
    Token, NextToken, NewUDF, NewSeparator: PToken;
  begin
    I:= 0;
    while (I < FInTokensList.Count - 1) do
    begin
      Token:= PToken(FInTokensList[I]);
      NextToken:= PToken(FInTokensList[I + 1]);

      { replace "<NAME>(" with "<UDF>(<NAME>" }
      if (   (Token^.TokenType = ttOperand)
         and (Token^.TokenSubtype = FMLA_TOKEN_EXT_NAME)
         and (NextToken^.TokenType = ttOperator)
         and (NextToken^.Value = '(')
         ) then
      begin
        { Create new UDF token }
        New(NewUDF);
        NewUDF^.Value:= '<UDF>';
        NewUDF^.TokenType:= ttFunction;
        { Create new separator token }
        New(NewSeparator);
        NewSeparator^.Value:= FMLA_ARG_SEPARATOR;
        NewSeparator^.TokenType:= ttArgSeparator;

        { Swap }
        FInTokensList[I]:= NextToken;
        FInTokensList[I + 1]:= Token;

        { Insert UDF token }
        FInTokensList.Insert(I, NewUDF);

        { Insert separator token }
        if ( I + 3 <  FInTokensList.Count) then
        begin
          if (PToken(FInTokensList[I + 3])^.Value <> ')') then
            FInTokensList.Insert(I + 3, NewSeparator);
        end;
      end;

      I:= I + 1;
    end;  
  end;

  procedure ProcessOperatorsStack(AOperator: PToken);
  begin
    if (AOperator.TokenType = ttArgSeparator) then
    begin
      { arg separator forces operators stack processing until '(',
        but do not Pop this '(' }
      while (FOperatorsStack.Count > 0) do
      begin
        POperator:= FOperatorsStack.Peek;
        if (POperator^.Value = '(') then
          break
        else
        begin
          POperator:= FOperatorsStack.Pop;
          FOutTokensList.Add(POperator);
        end;
      end;
    end
    else
    if (AOperator^.Value = ')') then
    begin
      { ')' forces operators stack processing until '(', and Pop this '(' }
      while (FOperatorsStack.Count > 0) do
      begin
        POperator:= FOperatorsStack.Pop;
        if (POperator^.Value = '(') then
        begin
          FreeToken(POperator);
          break;
        end
        else
          FOutTokensList.Add(POperator)
      end;
    end
    else
    begin
      while (FOperatorsStack.Count > 0) do
      begin
        POperator:= FOperatorsStack.Peek;
        if (POperator^.Priority >= AOperator^.Priority) then
        begin
          POperator:= FOperatorsStack.Pop;
          FOutTokensList.Add(POperator);
        end
        else
          break;
      end;
      FOperatorsStack.Push(AOperator);
    end;
  end;

  procedure CalcTokensSubtree;
  var
    TokenIndex, SubtokenIndex, SubtokenWeight, Arity: Integer;
    Token, Subtoken, PrevSubtoken: PToken;

    procedure ProcessSubtree;
    var
      I: Integer;
    begin
      PrevSubtoken:= Token;
      SubtokenIndex:= TokenIndex;
      for I:= 1 to Arity do
      begin
        SubtokenIndex:= SubtokenIndex - PrevSubtoken^.SubtreeTokens;
        if (SubtokenIndex < 0) then Exit;
        Subtoken:= PToken(FOutTokensList[SubtokenIndex]);
        SubtokenWeight:= Subtoken^.SubtreeTokens;
        Token^.SubtreeTokens:= Token^.SubtreeTokens + SubtokenWeight;
        PrevSubtoken:= Subtoken;
      end;
    end;

  begin
    for TokenIndex:= 0 to FOutTokensList.Count - 1 do
    begin
      Token:= PToken(FOutTokensList[TokenIndex]);
      Token^.SubtreeTokens:= 1;
      case Token^.TokenType of
        ttOperator:
          begin
            Arity:= 2;
            ProcessSubtree;            
          end;
        ttFunction:
          begin
            Arity:= Token^.ArgCounter + 1;
            ProcessSubtree;
          end;
      end;
    end;
  end;

  procedure ProcessReferenceSubexpressions;
  var
    TokenIndex, SubtokenIndex: Integer;
    Token, Subtoken: PToken;
  begin
    for TokenIndex:= 0 to FOutTokensList.Count - 1 do
    begin
      Token:= PToken(FOutTokensList[TokenIndex]);
      
      { Process colon operator }
      if (Token^.TokenType = ttOperator) then
        if Token^.Value[1] = ':' then
        begin
          for SubtokenIndex:= TokenIndex downto TokenIndex - Token^.SubtreeTokens + 1 do
          begin
            Subtoken:= PToken(FOutTokensList[SubtokenIndex]);
            Subtoken^.RefRequired:= True;
          end;
        end;
    end;
  end;

begin
  { modify tokens for UDFs }
  PreprocessUDFTokens;

  { main rearrange cycle }
  for I:= 0 to FInTokensList.Count-1 do
  begin
    P:= PToken(FInTokensList[I]);
    FInTokensList[I]:= nil;
    case P^.TokenType of
      ttOperand:
        begin
          FOutTokensList.Add(P);
          if FFunctionsStack.Count>0 then
          begin
            PFunction:= FFunctionsStack.Peek;
            PFunction^.HaveArgs:= True;
          end;
        end;
      ttFunction:
        begin
          if FFunctionsStack.Count>0 then
          begin
            PFunction:= FFunctionsStack.Peek;
            PFunction^.HaveArgs:= True;
          end;
          FFunctionsStack.Push(P);
          P^.ArgCounter:= 0;
          P^.BraceCounter:= 0;
          P^.HaveArgs:= False;
        end;
      ttArgSeparator:
        begin
          if FFunctionsStack.Count>0 then
          begin
            PFunction:= FFunctionsStack.Peek;
            Inc(PFunction^.ArgCounter);
          end;
          ProcessOperatorsStack(P);
          FreeToken(P);          
        end;
      ttOperator:
        begin
          case P^.Value[1] of
            '(':
              begin
                FOperatorsStack.Push(P);
                if FFunctionsStack.Count>0 then
                begin
                  PFunction:= FFunctionsStack.Peek;
                  Inc(PFunction^.BraceCounter);
                end;
              end;
            ')':
              begin
                ProcessOperatorsStack(P);
                if FFunctionsStack.Count>0 then
                begin
                  PFunction:= FFunctionsStack.Peek;
                  Dec(PFunction^.BraceCounter);
                  if PFunction^.BraceCounter = 0 then
                  begin
                    PFunction:= FFunctionsStack.Pop;
                    FOutTokensList.Add(PFunction);
                    FreeToken(P);
                  end
                  else
                    FOutTokensList.Add(P);
                end
                else
                  FOutTokensList.Add(P);
              end;
            else
              ProcessOperatorsStack(P);
          end;
        end;
    end;
  end;

  { move residual operators from stack }
  while (FOperatorsStack.Count > 0) do
  begin
    POperator:= FOperatorsStack.Pop;
    FOutTokensList.Add(POperator);
  end;

  { move residual functions from stack }
  while (FFunctionsStack.Count > 0) do
  begin
    PFunction:= FFunctionsStack.Pop;
    FOutTokensList.Add(PFunction);
  end;

  { process reference subexpressions }
  CalcTokensSubtree;
  ProcessReferenceSubexpressions;
end;

{TXLSFormulaParser}
constructor TXLSFormulaParser.Create(const ALinkTable: TXLSLinkTable);
var
  I: Integer;
begin
  FBaseRow:= 0;
  FBaseColumn:= 0;
  FSharedFormulaParse:= False;

  FOperators:= TAnsiStringList.Create;
  for I:= 0 to FMLA_OPERATORS_COUNT-1 do
    FOperators.Add(FmlaOperators[I]);
  FOperators.Add(FMLA_ARG_SEPARATOR);

  FSeparators:= TAnsiStringList.Create;
  for I:= 0 to FMLA_OPERATORS_COUNT-1 do
  begin
    if (FmlaOperators[I] <> ':') then
      FSeparators.Add(FmlaOperators[I]);
  end;
  FSeparators.Add(FMLA_ARG_SEPARATOR);

  FFunctions:= THashedStringList.Create(7);
  for I:= 0 to FMLA_FUNCTIONS_COUNT-1 do
    FFunctions.Add(FmlaFunctions[I].Name);

  FParser:= TRPNParser.Create;
  FParser.OnParseToken:= ParseToken;
  FParser.OnFreeToken:= FreeTokenData;

  FLinkTable:= ALinkTable;
end;

destructor TXLSFormulaParser.Destroy;
begin
  FOperators.Destroy;
  FSeparators.Destroy;
  FFunctions.Destroy;
  FParser.Destroy;
  inherited;
end;

procedure TXLSFormulaParser.FreeTokenData(var AToken: TToken);
begin
  if AToken.TokenType = ttOperand then
    case AToken.TokenSubtype of
      FMLA_TOKEN_NUMBER   : Dispose(PDouble(AToken.Data));
      FMLA_TOKEN_BOOL     : Dispose(PByte(AToken.Data));
      FMLA_TOKEN_CELL,
      FMLA_TOKEN_AREA,
      FMLA_TOKEN_3D_CELL,
      FMLA_TOKEN_3D_AREA,
      FMLA_TOKEN_NAME,
      FMLA_TOKEN_EXT_NAME,
      FMLA_TOKEN_EXT_CELL,
      FMLA_TOKEN_EXT_AREA : Dispose(PXLSLinkParameters(AToken.Data));
    end;
end;

procedure TXLSFormulaParser.GetTokenPrior(var AToken: TToken);
begin
  case AToken.TokenType of
    ttOperator:
      case AToken.Value[1] of
        '(': AToken.Priority:= 20;
        ')': AToken.Priority:= 30;
        '=',
        '<',
        '>': AToken.Priority:= 35;
        ':': AToken.Priority:= 36;
        '+',
        '-',
        '&': AToken.Priority:= 40;
        '*': AToken.Priority:= 45;
        '/': AToken.Priority:= 50;
      end;
  end;
end;

procedure TXLSFormulaParser.ParseToken(var AToken: TToken);
var
  PNumber: PDouble;
  PBool: PByte;
  PLinkParam: PXLSLinkParameters;
  E: Extended;
  S: AnsiString;

  function StrToFloatVar(const S: AnsiString; var Num: Extended): Boolean;
  begin
    Result:= TextToFloat(PAnsiChar(S), Num, fvExtended);
  end;

begin
  AToken.RefRequired:= False;

  {try arg separator }
  if (AToken.Value = FMLA_ARG_SEPARATOR) then
  begin
    AToken.TokenType:= ttArgSeparator;
    Exit;
  end;

  {try operator}
  if (FOperators.IndexOf(AnsiUpperCase(AToken.Value)) >=0) then
  begin
    AToken.TokenType:= ttOperator;
    GetTokenPrior(AToken);
    Exit;
  end;

  {try number}
  New(PNumber);
  if StrToFloatVar(AToken.Value, E) then
  begin
    PNumber^:= E;
    AToken.TokenType:= ttOperand;
    AToken.TokenSubtype:= FMLA_TOKEN_NUMBER;
    AToken.Data:= PNumber;
    Exit;
  end
  else
    Dispose(PNumber);

  {try string}
  if (AToken.Value[1] = FMLA_STRING_QUOTE) and
    (AToken.Value[Length(AToken.Value)] = FMLA_STRING_QUOTE) then
  begin
    AToken.TokenType:= ttOperand;
    AToken.TokenSubtype:= FMLA_TOKEN_STRING;
    Exit;
  end;

  {try boolean}
  new(PBool);
  if   (AnsiUpperCase(Trim(AToken.Value)) = 'FALSE')
    or (AnsiUpperCase(Trim(AToken.Value)) = 'TRUE') then
  begin
    AToken.TokenType:= ttOperand;
    AToken.TokenSubtype:= FMLA_TOKEN_BOOL;
    if (AnsiUpperCase(Trim(AToken.Value)) = 'TRUE') then
      PBool^:= 1
    else
      PBool^:= 0;
    AToken.Data:= PBool;
    Exit;
  end
  else
    Dispose(PBool);

  {try empty argument}
  if (AToken.Value = '<MISARG>') then
  begin
    AToken.TokenType:= ttOperand;
    AToken.TokenSubtype:= FMLA_TOKEN_MISARG;
    Exit;
  end;

  {try function}
  S:= AnsiUpperCase(AToken.Value);
  if (FFunctions.IndexByKey(S) >=0) then
  begin
    AToken.TokenType:= ttFunction;
    Exit;
  end;

  {try cell, area, 3d, name, external name}
  New(PLinkParam);
  PLinkParam^.LinkText:= WideString(AToken.Value);
  if FLinkTable.ParseLinkText(PLinkParam^) then
  begin
    AToken.TokenType:= ttOperand;
    AToken.Data:= PLinkParam;
    case PLinkParam^.LinkType of
      tlLocalRef      : AToken.TokenSubtype:= FMLA_TOKEN_CELL;
      tlLocalRect     : AToken.TokenSubtype:= FMLA_TOKEN_AREA;
      tl3dRef         : AToken.TokenSubtype:= FMLA_TOKEN_3D_CELL;
      tl3dRect        : AToken.TokenSubtype:= FMLA_TOKEN_3D_AREA;
      tlName          : AToken.TokenSubtype:= FMLA_TOKEN_NAME;
      tlExternalName  : AToken.TokenSubtype:= FMLA_TOKEN_EXT_NAME;
      tlExternal3dRef : AToken.TokenSubtype:= FMLA_TOKEN_EXT_CELL;
      tlExternal3dRect: AToken.TokenSubtype:= FMLA_TOKEN_EXT_AREA;
    end;
    Exit;
  end
  else
    Dispose(PLinkParam);

  {token not recognized}
  raise EXLSError.Create(EXLS_BADFORMULA);
end;

function TXLSFormulaParser.GetNumberString(ANumber: Double): AnsiString;
begin
  result:= StringOfChar(AnsiChar(#0), SizeOf(Double) + 1);
  result[1]:= AnsiChar(FMLA_PTG_NUM);
  Move(ANumber, result[2], SizeOf(Double));
end;

function TXLSFormulaParser.GetBoolString(ABool: Byte): AnsiString;
begin
  result:= AnsiSTring(#0#0);
  result[1]:= AnsiChar(FMLA_PTG_BOOL);
  result[2]:= AnsiChar(ABool);
end;

function TXLSFormulaParser.GetStringString(AString: AnsiString): AnsiString;
var
  S, UString: AnsiString;
  L: Byte;
begin
  {trim quotes}
  S:= Copy(AString, 2, Length(AString)-2);

  {max string constant lenth in Excel formula is 255}
  if Length(S)>255 then
    raise EXLSError.Create(EXLS_FMLASTRINGTOOLONG);

  {always use unicode strings}
  L:= Length(S);
  UString:= StringToANSIWideString(S);
  result:= StringOfChar(AnsiChar(#0), L*2 + 3);
  result[1]:= AnsiChar(FMLA_PTG_STR);
  result[2]:= AnsiChar(L);
  result[3]:= AnsiChar(1);
  if (L > 0) then
    Move(UString[1], result[4], L*2);
end;

function TXLSFormulaParser.GetCellString(const ALinkParam: TXLSLinkParameters;
  const RefRequired: Boolean): AnsiString;
var
  RelativeFlags: Byte;
  Ptg: Byte;
  ARow: Word;
  AColumn: Word;
begin
  RelativeFlags:= 0;
  if (not ALinkParam.ColumnFromIsAbsolute) then RelativeFlags:= RelativeFlags or $40;
  if (not ALinkParam.RowFromIsAbsolute)    then RelativeFlags:= RelativeFlags or $80;

  ARow:= ALinkParam.RowFrom;
  AColumn:= ALinkParam.ColumnFrom;
  if RefRequired then
    Ptg:= FMLA_PTG_REF_REF
  else
    Ptg:= FMLA_PTG_REF;

  if FSharedFormulaParse
     { not absolute reference }
     and not (RelativeFlags = 0)
  then
  begin
    if ((RelativeFlags and $80) <> 0) then ARow:= ARow - FBaseRow;
    if ((RelativeFlags and $40) <> 0) then AColumn:= AColumn - FBaseColumn;
    if RefRequired then
      Ptg:= FMLA_PTG_N_REF_REF
    else
      Ptg:= FMLA_PTG_N_REF_VAL;
  end;

  result:= StringOfChar(AnsiChar(#0), 5);
  result[1]:= AnsiChar(Ptg);
  PWord(@result[2])^:= ARow;
  PWord(@result[4])^:= AColumn;
  result[5]:= AnsiChar(RelativeFlags);
end;

function TXLSFormulaParser.GetAreaString(const ALinkParam: TXLSLinkParameters;
  const RefRequired: Boolean): AnsiString;
var
  RelativeFlagsFrom, RelativeFlagsTo: Byte;
  ARowFrom, ARowTo: Word;
  AColumnFrom, AColumnTo: Word;
  CellPtg, AreaPtg: Byte;
begin
  RelativeFlagsFrom:= 0;
  RelativeFlagsTo:= 0;

  if (not ALinkParam.ColumnFromIsAbsolute) then RelativeFlagsFrom:= RelativeFlagsFrom or $40;
  if (not ALinkParam.RowFromIsAbsolute)    then RelativeFlagsFrom:= RelativeFlagsFrom or $80;
  if (not ALinkParam.ColumnToIsAbsolute) then RelativeFlagsTo:= RelativeFlagsTo or $40;
  if (not ALinkParam.RowToIsAbsolute)    then RelativeFlagsTo:= RelativeFlagsTo or $80;

  ARowFrom:= ALinkParam.RowFrom;
  ARowTo:= ALinkParam.RowTo;
  AColumnFrom:= ALinkParam.ColumnFrom;
  AColumnTo:= ALinkParam.ColumnTo;

  if RefRequired then
    CellPtg:= FMLA_PTG_REF_REF
  else
    CellPtg:= FMLA_PTG_REF;
  AreaPtg:= FMLA_PTG_AREA;

  if FSharedFormulaParse
     { not absolute reference  }
     and not ( (RelativeFlagsFrom = 0) and (RelativeFlagsTo = 0) )
  then
  begin
    if ((RelativeFlagsFrom and $80) <> 0) then ARowFrom:= ARowFrom - FBaseRow;
    if ((RelativeFlagsTo and $80) <> 0)   then ARowTo  := ARowTo - FBaseRow;
    if ((RelativeFlagsFrom and $40) <> 0) then AColumnFrom:= AColumnFrom - FBaseColumn;
    if ((RelativeFlagsTo and $40) <> 0)   then AColumnTo:= AColumnTo - FBaseColumn;

    if RefRequired then
      CellPtg:= FMLA_PTG_N_REF_REF
    else
      CellPtg:= FMLA_PTG_N_REF_VAL;
    AreaPtg:= FMLA_PTG_N_AREA_REF;
  end;

  {if area contains 1 cell}
  if ((ARowFrom = ARowTo) and (AColumnFrom = AColumnTo)) then
  begin
    result:= StringOfChar(AnsiChar(#0), 5);
    result[1]:= AnsiChar(CellPtg);
    PWord(@result[2])^:= ARowFrom;
    result[4]:= AnsiChar(AColumnFrom);
    result[5]:= AnsiChar(RelativeFlagsFrom);
  end
  else
  begin
    result:= StringOfChar(AnsiChar(#0), 9);
    result[1]:= AnsiChar(AreaPtg);
    PWord(@result[2])^:= ARowFrom;
    PWord(@result[4])^:= ARowTo;
    result[6]:= AnsiChar(AColumnFrom);
    result[8]:= AnsiChar(AColumnTo);
    result[7]:= AnsiChar(RelativeFlagsFrom);
    result[9]:= AnsiChar(RelativeFlagsTo);
  end;
end;

function TXLSFormulaParser.Get3DCellString(const ALinkParam: TXLSLinkParameters;
  const RefRequired: Boolean): AnsiString;
var
  XTIIndex: Word;
  RelativeFlags: Byte;
  Ptg: Byte;
begin
  XTIIndex:= ALinkParam.ExternSheetIndex;

  if RefRequired then
    Ptg:= FMLA_PTG_3DREF_REF
  else
    Ptg:= FMLA_PTG_3DREF;
    
  result:= StringOfChar(AnsiChar(#0), 7);
  result[1]:= AnsiChar(Ptg);
  Move(XTIIndex, result[2], 2);

  PWord(@result[4])^:= ALinkParam.RowFrom;
  PByte(@result[6])^:= ALinkParam.ColumnFrom;

  RelativeFlags:= 0;
  if (not ALinkParam.ColumnFromIsAbsolute) then RelativeFlags:= RelativeFlags or $40;
  if (not ALinkParam.RowFromIsAbsolute)    then RelativeFlags:= RelativeFlags or $80;
  result[7]:= AnsiChar(RelativeFlags);
end;

function TXLSFormulaParser.Get3DAreaString(const ALinkParam: TXLSLinkParameters): AnsiString;
var
  XTIIndex: Word;
  RelativeFlagsFrom, RelativeFlagsTo: Byte;
begin
  XTIIndex:= ALinkParam.ExternSheetIndex;

  result:= StringOfChar(AnsiChar(#0), 11);
  result[1]:= AnsiChar(FMLA_PTG_3DAREA);
  Move(XTIIndex, result[2], 2);

  PWord(@result[4])^:= ALinkParam.RowFrom;
  PWord(@result[6])^:= ALinkParam.RowTo;
  PWord(@result[8])^:= ALinkParam.ColumnFrom;
  PWord(@result[10])^:= ALinkParam.ColumnTo;

  RelativeFlagsFrom:= 0;
  RelativeFlagsTo:= 0;

  if (not ALinkParam.ColumnFromIsAbsolute) then RelativeFlagsFrom:= RelativeFlagsFrom or $40;
  if (not ALinkParam.RowFromIsAbsolute)    then RelativeFlagsFrom:= RelativeFlagsFrom or $80;
  if (not ALinkParam.ColumnToIsAbsolute) then RelativeFlagsTo:= RelativeFlagsTo or $40;
  if (not ALinkParam.RowToIsAbsolute)    then RelativeFlagsTo:= RelativeFlagsTo or $80;

  result[9]:= AnsiChar(RelativeFlagsFrom);
  result[11]:= AnsiChar(RelativeFlagsTo);
end;

function TXLSFormulaParser.GetNameString(const ALinkParam: TXLSLinkParameters): AnsiString;
var
  NameIndex: Word;
begin
  NameIndex:= ALinkParam.NameIndex;

  result:= StringOfChar(AnsiChar(#0), 5);
  result[1]:= AnsiChar(FMLA_PTG_NAME);
  Move(NameIndex, result[2], 2);
end;

function TXLSFormulaParser.GetExternalNameString(const ALinkParam: TXLSLinkParameters): AnsiString;
var
  XTIIndex, NameIndex: Word;
begin
  XTIIndex:= ALinkParam.ExternSheetIndex;
  NameIndex:= ALinkParam.NameIndex;

  result:= StringOfChar(AnsiChar(#0), 7);
  result[1]:= AnsiChar(FMLA_PTG_NAMEX);
  Move(XTIIndex, result[2], 2);
  Move(NameIndex, result[4], 2);
end;

function TXLSFormulaParser.GetOperatorString(AOperator: AnsiString): AnsiString;
begin
  if      (AOperator = '+')  then Result:= AnsiChar(FMLA_PTG_ADD)
  else if (AOperator = '-')  then Result:= AnsiChar(FMLA_PTG_SUB)
  else if (AOperator = '*')  then Result:= AnsiChar(FMLA_PTG_MUL)
  else if (AOperator = '/')  then Result:= AnsiChar(FMLA_PTG_DIV)
  else if (AOperator = '(')  then Result:= AnsiChar(FMLA_PTG_PAREN)
  else if (AOperator = ')')  then Result:= AnsiChar(FMLA_PTG_PAREN)
  else if (AOperator = '<')  then Result:= AnsiChar(FMLA_PTG_LT)
  else if (AOperator = '<=') then Result:= AnsiChar(FMLA_PTG_LE)
  else if (AOperator = '=')  then Result:= AnsiChar(FMLA_PTG_EQ)
  else if (AOperator = '>=') then Result:= AnsiChar(FMLA_PTG_GE)
  else if (AOperator = '>')  then Result:= AnsiChar(FMLA_PTG_GT)
  else if (AOperator = '<>') then Result:= AnsiChar(FMLA_PTG_NE)
  else if (AOperator = '&')  then Result:= AnsiChar(FMLA_PTG_CONCAT)
  else if (AOperator = ':')  then Result:= AnsiChar(FMLA_PTG_RANGE)
  ;
end;

function TXLSFormulaParser.GetFunctionString(const AFunction: AnsiString;
  const AArgsCount: Integer; const RefRequired: Boolean): AnsiString;
var
  I: Integer;
  FunctionCode: Integer;
  S: AnsiString;
  Ptg: Byte;
begin
  if RefRequired then
    Ptg:= FMLA_PTG_FUNC_REF
  else
    Ptg:= FMLA_PTG_FUNC;

  result:= StringOfChar(AnsiChar(#0), 4);
  result[1]:= AnsiChar(Ptg);
  Move(AArgsCount, result[2], 1);

  {get func code}
  FunctionCode:= -1;
  S:= AnsiUpperCase(AFunction);
  I:= FFunctions.IndexByKey(S);
  if (I >= 0) then
    FunctionCode:= FmlaFunctions[I].Code
  else
    raise EXLSError.CreateFmt(EXLS_BADFORMULAFUNCTION, [AFunction]);

  Move(FunctionCode, result[3], 2);
end;

function TXLSFormulaParser.InternalParse(const AFormula: AnsiString): AnsiString;
var
  I: Integer;
  W: Word;
  S: AnsiString;
  Token: PToken;
  TokenIndex: Integer;
  RefRequired: Boolean;
begin
  Result:= '';
  FFormula:= Trim(AFormula);
  if (FFormula = '') then
    Exit;
  if (FFormula[1] = '=') then
    FFormula:= Copy(FFormula, 2, Length(FFormula));

  FParser.Clear;
  FParser.Parse(FFormula, FSeparators, FMLA_STRING_QUOTE);

  for I:= 0 to FParser.OutTokensCount-1 do
  begin
    Token:= FParser.OutToken[I];
    case Token^.TokenType of
      ttOperand:
        begin
          case Token^.TokenSubtype of
            FMLA_TOKEN_NUMBER:
              S:= GetNumberString(PDouble(Token^.Data)^);
            FMLA_TOKEN_CELL:
              S:= GetCellString(PXLSLinkParameters(Token^.Data)^, Token^.RefRequired);
            FMLA_TOKEN_3D_CELL:
              S:= Get3DCellString(PXLSLinkParameters(Token^.Data)^, Token^.RefRequired);
            FMLA_TOKEN_AREA:
              S:= GetAreaString(PXLSLinkParameters(Token^.Data)^, Token^.RefRequired);
            FMLA_TOKEN_3D_AREA:
              S:= Get3DAreaString(PXLSLinkParameters(Token^.Data)^);
            FMLA_TOKEN_NAME:
              S:= GetNameString(PXLSLinkParameters(Token^.Data)^);
            FMLA_TOKEN_EXT_NAME:
              S:= GetExternalNameString(PXLSLinkParameters(Token^.Data)^);
            FMLA_TOKEN_EXT_CELL:
              S:= Get3DCellString(PXLSLinkParameters(Token^.Data)^, Token^.RefRequired);
            FMLA_TOKEN_EXT_AREA:
              S:= Get3DAreaString(PXLSLinkParameters(Token^.Data)^);
            FMLA_TOKEN_STRING:
              S:= GetStringString(Token^.Value);
            FMLA_TOKEN_BOOL:
              S:= GetBoolString(PByte(Token^.Data)^);
            FMLA_TOKEN_MISARG:
              S:= AnsiChar(FMLA_PTG_MISARG);  
          end;
        end;
      ttOperator:
        S:= GetOperatorString(Token^.Value);
      ttFunction:
        begin
          if Token^.HaveArgs then
            S:= GetFunctionString(Token^.Value, Token^.ArgCounter + 1, Token^.RefRequired)
          else
            S:= GetFunctionString(Token^.Value, 0, Token^.RefRequired);
         end;
    end;

    Token^.RawData:= S;
  end;

  { Mark reference subexpressions }
  I:= 0;
  W:= 0;
  TokenIndex:= 0;
  RefRequired:= False;
  while (I < FParser.OutTokensCount) do
  begin
    Token:= FParser.OutToken[I];
    if Token^.RefRequired then
    begin
      W:= W + Length(Token^.RawData);
      if (not RefRequired) then
      begin
        RefRequired:= True;
        TokenIndex:= I;
      end;
    end;

    if RefRequired and (not Token^.RefRequired) then
    begin
      S:= AnsiChar(FMLA_PTG_MEMFUNC) + #0#0;
      Move(W, S[2], 2);
      FParser.OutToken[TokenIndex]^.RawData:= S + FParser.OutToken[TokenIndex]^.RawData;
      RefRequired:= False;
      W:= 0;
    end;
    I:= I + 1;
  end;

  { Compile result }
  for I:= 0 to FParser.OutTokensCount-1 do
    Result:= Result + FParser.OutToken[I]^.RawData;
end;

function TXLSFormulaParser.Parse(const AFormula: AnsiString): AnsiString;
begin
  { Clear relative parsing flags }
  FBaseRow:= 0;
  FBaseColumn:= 0;
  FSharedFormulaParse:= False;
  try
    Result:= InternalParse(AFormula);
  except
    raise EXLSError.CreateWithText(EXLS_BADFORMULA, AFormula);
  end;
end;

function TXLSFormulaParser.ParseForSharedFormula(const AFormula: AnsiString; ABaseRow: Word;
  ABaseColumn: Byte): AnsiString;
begin
  { Set relative parsing flags }
  FBaseRow:= ABaseRow;
  FBaseColumn:= ABaseColumn;
  FSharedFormulaParse:= True;
  try
    Result:= InternalParse(AFormula);
  except
    raise EXLSError.CreateWithText(EXLS_BADFORMULA, AFormula);
  end;
end;

{TXLSXFormulaParser}
constructor TXLSXFormulaParser.Create(const ALinkTable: TXLSLinkTable);
begin
  FLinkTable:= ALinkTable;
end;

destructor TXLSXFormulaParser.Destroy;
begin
  inherited;
end;

function TXLSXFormulaParser.Parse(const AFormula: WideString): WideString;
var
  DocumentIndex, DocumentIndexToWrite: Integer;
  DocumentName: WideString;
  Wc: WideChar;
  I, FormulaLen: Integer;
  InString: Boolean;
  InName: Boolean;
begin
  Result:= AFormula;

  { replace external documents with indexes }
  if (Pos('!', Result) > 0) and (Pos('.', Result) > 0) then
  begin
    DocumentIndexToWrite:= 0;
    for DocumentIndex:= 0 to FLinkTable.DocumentsCount - 1 do
    begin
      if FLinkTable.Document[DocumentIndex].IsExternal then
      begin
        DocumentIndexToWrite:= DocumentIndexToWrite + 1;
        DocumentName:= FLinkTable.Document[DocumentIndex].DocumentName;

        { replace [name] with [index] }
        Result:= WideStringReplace(
                     Result
                   , '[' + DocumentName + ']'
                   , '[' + IntToStr(DocumentIndexToWrite) + ']'
                   );

        { replace name with [index] }
        Result:= WideStringReplace(
                     Result
                   , DocumentName
                   , '[' + IntToStr(DocumentIndexToWrite) + ']'
                   );
      end;
    end;
  end;

  { set arguments separator to comma }
  InString:= False;
  InName:= False;
  FormulaLen:= Length(Result);
  for I:= 1 to FormulaLen do
  begin
    Wc:= Result[I];
    if Wc = '"' then
      InString:= not InString;
    if Wc = '''' then
      if not InString
        then InName:= not InName;
    { replace ; with , }    
    if Wc = ';' then
      if (not InString) and (not InName) then
        Result[I]:= ',';
  end;

end;

end.
