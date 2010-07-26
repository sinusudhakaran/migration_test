unit XLSCellValidation;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0
    Cell validation classes

    Rev history:
    2008-04-17  Cell validations started

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface

uses Classes, XLSBase, XLSRects, XLSFormula, RPNParser, PtgParser;

type
  TCellValidationType =
    ( cvtNone
    , cvtIsInteger
    , cvtIsNumber
    , cvtInList
    , cvtInExplicitList
    , cvtIsDate
    , cvtIsTime
    , cvtTextLength
    , cvtCustomFormula
    );

  TCellValidationErrorStyle =
    ( cveStop
    , cveWarning
    , cveInfo
    );

  TCellValidationOperation =
    ( cvoNone
    , cvoBetween
    , cvoNotBetween
    , cvoEqual
    , cvoNotEqual
    , cvoGT
    , cvoLT
    , cvoGTE
    , cvoLTE
    );

  { TCellValidation }
  TCellValidation = class
  protected
    FValidationType: TCellValidationType;
    FValidationOperation: TCellValidationOperation;
    FErrorStyle: TCellValidationErrorStyle;
    FShowInputMessage: Boolean;
    FShowErrorMessage: Boolean;
    FAllowBlank: Boolean;
    FInCellDropdown: Boolean;
    FInputTitle: WideString;
    FInputMessage: WideString;
    FErrorTitle: WideString;
    FErrorMessage: WideString;
    FExpression1: AnsiString;
    FExpression2: AnsiString;
    FRects: TRangeRects;
  public
    property ValidationType: TCellValidationType read FValidationType write FValidationType;
    property ValidationOperation: TCellValidationOperation read FValidationOperation write FValidationOperation;
    property ErrorStyle: TCellValidationErrorStyle read FErrorStyle write FErrorStyle;
    property AllowBlank: Boolean read FAllowBlank write FAllowBlank;
    property InCellDropdown: Boolean read FInCellDropdown write FInCellDropdown;
    property ShowInputMessage: Boolean read FShowInputMessage write FShowInputMessage;
    property ShowErrorMessage: Boolean read FShowErrorMessage write FShowErrorMessage;
    property InputTitle: WideString read FInputTitle write FInputTitle;
    property InputMessage: WideString read FInputMessage write FInputMessage;
    property ErrorTitle: WideString read FErrorTitle write FErrorTitle;
    property ErrorMessage: WideString read FErrorMessage write FErrorMessage;
    property Expression1: AnsiString read FExpression1 write FExpression1;
    property Expression2: AnsiString read FExpression2 write FExpression2;
    property Rects: TRangeRects read FRects;
    constructor Create;
    destructor Destroy; override;
  end;

  { TCellValidations }
  TCellValidations = class
  protected
    FValidations: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): TCellValidation;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddValidation(
              const ValidationType: TCellValidationType;
              const Operation: TCellValidationOperation;
              const Expression1: AnsiString;
              const Expression2: AnsiString;
              const AllowBlank: Boolean;
              const ShowInputMessage: Boolean;
              const ShowErrorMessage: Boolean;
              const ErrorStyle: TCellValidationErrorStyle;
              const InputTitle: WideString; const InputMessage: WideString;
              const ErrorTitle: WideString;  const ErrorMessage: WideString;
              const AreaRowFrom, AreaRowTo: Word;
              const AreaColumnFrom, AreaColumnTo: Byte
              );
    procedure AddListValidation(
              const ListAreaFormula: AnsiString;
              const AllowBlank: Boolean;
              const InCellDropdown: Boolean;
              const ShowInputMessage: Boolean;
              const ShowErrorMessage: Boolean;
              const ErrorStyle: TCellValidationErrorStyle;
              const InputTitle: WideString; const InputMessage: WideString;
              const ErrorTitle: WideString;  const ErrorMessage: WideString;
              const AreaRowFrom, AreaRowTo: Word;
              const AreaColumnFrom, AreaColumnTo: Byte
              );
    procedure AddExplicitListValidation(
              const ListValues: AnsiString;
              const ListSeparator: AnsiString;
              const AllowBlank: Boolean;
              const InCellDropdown: Boolean;              
              const ShowInputMessage: Boolean;
              const ShowErrorMessage: Boolean;
              const ErrorStyle: TCellValidationErrorStyle;
              const InputTitle: WideString; const InputMessage: WideString;
              const ErrorTitle: WideString;  const ErrorMessage: WideString;
              const AreaRowFrom, AreaRowTo: Word;
              const AreaColumnFrom, AreaColumnTo: Byte
              );
    procedure AddItem(V: TCellValidation);
    property Count: Integer read GetCount;
    property Item[Index: Integer]: TCellValidation read GetItem; default;
  end;

{ Internal helper procedures }
function CellValidationToDVData(V: TCellValidation; Parser: TXLSFormulaParser): AnsiString;
procedure DVDataToCellValidation(const DVData: AnsiString;
  var V: TCellValidation;
  Parser: TPtgParser;
  ASheetIndex: Word;
  RaiseErrorOnReadUnknownFormula: Boolean);

implementation
uses SysUtils
   , Unicode
   , Streams
   , XLSError
   , XLSStrUtil
   {$IFDEF XLF_D2009}
   , AnsiStrings
   {$ENDIF}
   ;

{ TCellValidation }
constructor TCellValidation.Create;
begin
  FRects:= TRangeRects.Create;
  FValidationType:= cvtNone;
  FValidationOperation:= cvoNone;
  FErrorStyle:= cveStop;
  FAllowBlank:= True;
  FInCellDropdown:= True;
  FShowInputMessage:= True;
  FShowErrorMessage:= True;
  FInputTitle:= '';
  FInputMessage:= '';
  FErrorTitle:= '';
  FErrorMessage:= '';
  FExpression1:= '';
  FExpression2:= '';
end;

destructor TCellValidation.Destroy;
begin
  FRects.Destroy;
  inherited;
end;

{ TCellValidations }
constructor TCellValidations.Create;
begin
  FValidations:= TList.Create;
end;

destructor TCellValidations.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FValidations.Count - 1 do
    if Assigned(FValidations[I]) then
      TCellValidation(FValidations[I]).Destroy;

  FValidations.Destroy;

  inherited;
end;

procedure TCellValidations.AddValidation(
              const ValidationType: TCellValidationType;
              const Operation: TCellValidationOperation;
              const Expression1: AnsiString;
              const Expression2: AnsiString;
              const AllowBlank: Boolean;
              const ShowInputMessage: Boolean;
              const ShowErrorMessage: Boolean;
              const ErrorStyle: TCellValidationErrorStyle;
              const InputTitle: WideString; const InputMessage: WideString;
              const ErrorTitle: WideString;  const ErrorMessage: WideString;
              const AreaRowFrom, AreaRowTo: Word;
              const AreaColumnFrom, AreaColumnTo: Byte
              );
var
  V: TCellValidation;
begin
  V:= TCellValidation.Create;

  if (ValidationType = cvtInList) then
    raise Exception.Create('Use AddListValidation method for list validations.');

  if (ValidationType = cvtInExplicitList) then
    raise Exception.Create('Use AddExplicitListValidation method for list validations.');

  V.ValidationType       := ValidationType;
  V.ValidationOperation  := Operation;
  V.ErrorStyle           := ErrorStyle;
  V.AllowBlank           := AllowBlank;
  V.ShowInputMessage     := ShowInputMessage;
  V.ShowErrorMessage     := ShowErrorMessage;
  V.InputTitle           := InputTitle;
  V.InputMessage         := InputMessage;
  V.ErrorTitle           := ErrorTitle;
  V.ErrorMessage         := ErrorMessage;
  V.Expression1          := Expression1;
  V.Expression2          := Expression2;
  V.Rects.AddRect(AreaRowFrom, AreaRowTo, AreaColumnFrom, AreaColumnTo);

  FValidations.Add(Pointer(V));
end;

procedure TCellValidations.AddListValidation(
              const ListAreaFormula: AnsiString;
              const AllowBlank: Boolean;
              const InCellDropdown: Boolean;
              const ShowInputMessage: Boolean;
              const ShowErrorMessage: Boolean;
              const ErrorStyle: TCellValidationErrorStyle;
              const InputTitle: WideString; const InputMessage: WideString;
              const ErrorTitle: WideString;  const ErrorMessage: WideString;
              const AreaRowFrom, AreaRowTo: Word;
              const AreaColumnFrom, AreaColumnTo: Byte
              );
var
  V: TCellValidation;
begin
  V:= TCellValidation.Create;

  V.ValidationType       := cvtInList;
  V.ValidationOperation  := cvoNone;
  V.ErrorStyle           := ErrorStyle;
  V.AllowBlank           := AllowBlank;
  V.InCellDropdown       := InCellDropdown;
  V.ShowInputMessage     := ShowInputMessage;
  V.ShowErrorMessage     := ShowErrorMessage;
  V.InputTitle           := InputTitle;
  V.InputMessage         := InputMessage;
  V.ErrorTitle           := ErrorTitle;
  V.ErrorMessage         := ErrorMessage;
  V.Expression1          := ListAreaFormula;
  V.Expression2          := '';
  V.Rects.AddRect(AreaRowFrom, AreaRowTo, AreaColumnFrom, AreaColumnTo);

  FValidations.Add(Pointer(V));
end;

procedure TCellValidations.AddExplicitListValidation(
          const ListValues: AnsiString;
          const ListSeparator: AnsiString;
          const AllowBlank: Boolean;
          const InCellDropdown: Boolean;
          const ShowInputMessage: Boolean;
          const ShowErrorMessage: Boolean;
          const ErrorStyle: TCellValidationErrorStyle;
          const InputTitle: WideString; const InputMessage: WideString;
          const ErrorTitle: WideString;  const ErrorMessage: WideString;
          const AreaRowFrom, AreaRowTo: Word;
          const AreaColumnFrom, AreaColumnTo: Byte
          );
var
  V: TCellValidation;
  S: AnsiString;
begin
  {$IFDEF XLF_D2009}
  S:= AnsiStrings.StringReplace(ListValues, ListSeparator, FMLA_ARG_SEPARATOR, [rfReplaceAll]);
  {$ELSE}
  S:= StringReplace(ListValues, ListSeparator, FMLA_ARG_SEPARATOR, [rfReplaceAll]);
  {$ENDIF}

  V:= TCellValidation.Create;

  V.ValidationType       := cvtInExplicitList;
  V.ValidationOperation  := cvoNone;
  V.ErrorStyle           := ErrorStyle;
  V.AllowBlank           := AllowBlank;
  V.InCellDropdown       := InCellDropdown;
  V.ShowInputMessage     := ShowInputMessage;
  V.ShowErrorMessage     := ShowErrorMessage;
  V.InputTitle           := InputTitle;
  V.InputMessage         := InputMessage;
  V.ErrorTitle           := ErrorTitle;
  V.ErrorMessage         := ErrorMessage;
  V.Expression1          := S;
  V.Expression2          := '';
  V.Rects.AddRect(AreaRowFrom, AreaRowTo, AreaColumnFrom, AreaColumnTo);

  FValidations.Add(Pointer(V));
end;

function TCellValidations.GetCount: Integer;
begin
  Result:= FValidations.Count;
end;

function TCellValidations.GetItem(Index: Integer): TCellValidation;
begin
  Result:= TCellValidation(FValidations[Index]);
end;

procedure TCellValidations.AddItem(V: TCellValidation);
begin
  FValidations.Add(Pointer(V));
end;


{ Internal helper procedures }
function CellValidationToDVData(V: TCellValidation; Parser: TXLSFormulaParser): AnsiString;
var
  Stm: TEasyStream;
  Options: Longword;
  I: Integer;
  BaseRow: Word;
  BaseColumn: Byte;

  procedure StmWriteMessageString(Msg: WideString);
  var
    W: Word;
  begin
    if (Msg <> '') then
    begin
      W:= Length(Msg);
      Stm.Size:= Stm.Size + 3 + W * 2;
      Stm.WriteWord(W);
      Stm.WriteByte(1); // Unicode
      Stm.WriteBytes(@Msg[1], W * 2);
    end
    else
    begin
      Stm.Size:= Stm.Size + 4;
      Stm.WriteByte(1);
      Stm.WriteByte(0);
      Stm.WriteWord(0);
    end;
  end;

  procedure StmWriteExpression(Expression: AnsiString);
  var
    S: AnsiString;
    W: Word;
  begin
    S:= Trim(Expression);

    if (S <> '') then
    begin
      { Convert explicit list to quoted string }
      if (V.ValidationType = cvtInExplicitList) then
      begin
        if (S[1] <> '"') then S:= '"' + S;
        if (S[Length(S)] <> '"') then S:= S + '"';
      end;

      { save all other references as relative areas }
      S:= Parser.ParseForSharedFormula(S, BaseRow, BaseColumn);
    end;

    W:= Length(S);
    Stm.Size:= Stm.Size + 4 + W;
    Stm.WriteWord(W);
    Stm.WriteWord(0);
    if (W > 0) then
      Stm.WriteBytes(@S[1], W);
  end;

begin
  Stm:= TEasyStream.Create;

  try
    { Options }
    Options:= 0;

    case V.ValidationType of
      cvtNone:           Options:= 0;
      cvtIsInteger:      Options:= 1;
      cvtIsNumber:       Options:= 2;
      cvtInList:         Options:= 3;
      cvtInExplicitList: Options:= $83;
      cvtIsDate:         Options:= 4;
      cvtIsTime:         Options:= 5;
      cvtTextLength:     Options:= 6;
      cvtCustomFormula:  Options:= 7;
    end;

    case V.ErrorStyle of
      cveStop:    Options:= Options or (0 shl 4);
      cveWarning: Options:= Options or (1 shl 4);
      cveInfo:    Options:= Options or (2 shl 4);
    end;

    case V.ValidationOperation of
      cvoBetween:    Options:= Options or (0 shl 20);
      cvoNotBetween: Options:= Options or (1 shl 20);
      cvoEqual:      Options:= Options or (2 shl 20);
      cvoNotEqual:   Options:= Options or (3 shl 20);
      cvoGT:         Options:= Options or (4 shl 20);
      cvoLT:         Options:= Options or (5 shl 20);
      cvoGTE:        Options:= Options or (6 shl 20);
      cvoLTE:        Options:= Options or (7 shl 20);
    end;

    if V.AllowBlank then Options:= Options or $100;
    if (not V.InCellDropdown) then Options:= Options or $200;
    if V.ShowInputMessage then Options:= Options or $40000;
    if V.ShowErrorMessage then Options:= Options or $80000;

    Stm.Size:= Stm.Size + 4;
    Stm.WriteDWord(Options);

    { Messages }
    StmWriteMessageString(V.InputTitle);
    StmWriteMessageString(V.ErrorTitle);
    StmWriteMessageString(V.InputMessage);
    StmWriteMessageString(V.ErrorMessage);

    { Get base cell }
    if (V.Rects.RectsCount > 0) then
    begin
      BaseRow:= V.Rects.Rect[0].RowFrom;
      BaseColumn:= V.Rects.Rect[0].ColumnFrom;
    end
    else
    begin
      BaseRow:= 0;
      BaseColumn:= 0;
    end;

    { Expressions }
    StmWriteExpression(V.Expression1);
    StmWriteExpression(V.Expression2);

    { Area }
    Stm.Size:= Stm.Size + 2;
    Stm.WriteWord(V.Rects.RectsCount);
    for I:= 0 to V.Rects.RectsCount - 1 do
    begin
      Stm.Size:= Stm.Size + 8;
      Stm.WriteWord(Word(V.Rects.Rect[I].RowFrom));
      Stm.WriteWord(Word(V.Rects.Rect[I].RowTo));
      Stm.WriteWord(Word(V.Rects.Rect[I].ColumnFrom));
      Stm.WriteWord(Word(V.Rects.Rect[I].ColumnTo));
    end;

    { Get result }
    SetLength(Result, Stm.Size);
    Stm.Position:= 0;
    Stm.ReadString(Result, Stm.Size);
    
  finally
    Stm.Destroy;
  end;  
end;

procedure DVDataToCellValidation(const DVData: AnsiString;
  var V: TCellValidation;
  Parser: TPtgParser;
  ASheetIndex: Word;
  RaiseErrorOnReadUnknownFormula: Boolean);
var
  Stm: TEasyStream;
  Options: Longword;
  Msg: WideString;
  Expression1, Expression2: AnsiString;
  BaseRow: Word;
  BaseColumn: Byte;

  procedure StmReadMessageString(var Msg: WideString);
  var
    W: Word;
    B: Byte;
    S: AnsiString;
  begin
    Stm.ReadWord(W);
    if (W = 0) then Exit;
    Stm.ReadByte(B);
    SetLength(Msg, W);

    if ((B and 1) <> 0) then
      Stm.ReadBytes(@Msg[1], W * 2)
    else
    begin
      SetLength(S, W);
      Stm.ReadString(S, W);
      { Excel uses #0 char for empty messages}
      if (S = #0) then S:= '';
      Msg:= StringToWideString(S);
    end;
  end;

  procedure StmReadExpression(var Expression: AnsiString);
  var
    W: Word;
    S: AnsiString;
  begin
    Expression:= '';

    { formula len }
    Stm.ReadWord(W);
    { ignore 2 bytes }
    Stm.SkipBytes(2);
    if (W = 0) then Exit;

    SetLength(S, W);
    Stm.ReadString(S, W);

    { Do not parse here }
    Expression:= S;
  end;

  function ParseExpression(Expression: AnsiString): AnsiString;
  var
    ParserResult: Integer;
  begin
    Result:= '';
    if (Expression = '') then Exit;
    
    try
      ParserResult:= Parser.Parse(ASheetIndex, BaseRow, BaseColumn, 0, Expression);
      if (ParserResult = 0) then
        Result := Parser.Expression;
    except
      ParserResult:= -1;
    end;

    if (ParserResult <> 0) then
    begin
      if RaiseErrorOnReadUnknownFormula then
        raise EXLSError.Create(EXLS_UNKNOWNFORMULA);
    end;

    { Remove quotes from explicit list }
    if (V.ValidationType = cvtInExplicitList) then
    begin
      if (Result <> '') then
        if (Result[1] = '"') then Result:= Copy(Result, 2, Length(Result) - 1);
      if (Result <> '') then
        if (Result[Length(Result)] = '"') then Result:= Copy(Result, 1, Length(Result) - 1);

    end;
  end;

  procedure StmReadArea;
  var
    RectsCount: Word;
    RowFrom, RowTo, ColumnFrom, ColumnTo: Word;
    I: Integer;
  begin
    { rects count }
    Stm.ReadWord(RectsCount);
    for I:= 0 to RectsCount - 1 do
    begin
      Stm.ReadWord(RowFrom);
      Stm.ReadWord(RowTo);
      Stm.ReadWord(ColumnFrom);
      Stm.ReadWord(ColumnTo);

      V.Rects.AddRect(RowFrom, RowTo, ColumnFrom, ColumnTo);

      { Get first range's top left cell }
      if (I = 0) then
      begin
        BaseRow:= RowFrom;
        BaseColumn:= ColumnFrom;
      end;
    end;
  end;

begin
  if (DVData = '') then Exit;

  Stm:= TEasyStream.Create;

  try
    Stm.WriteBytes(@DVData[1], Length(DVData));
    Stm.Position:= 0;

    Stm.ReadDWord(Options);

    case (Options and $07) of
      0: V.ValidationType:= cvtNone;
      1: V.ValidationType:= cvtIsInteger;
      2: V.ValidationType:= cvtIsNumber;
      3: V.ValidationType:= cvtInList;
      4: V.ValidationType:= cvtIsDate;
      5: V.ValidationType:= cvtIsTime;
      6: V.ValidationType:= cvtTextLength;
      7: V.ValidationType:= cvtCustomFormula;
    end;

    if (   (V.ValidationType = cvtInList)
       and ((Options and $80) <> 0)
       ) then
      V.ValidationType:= cvtInExplicitList;

    case ((Options shr 4) and $03) of
      0: V.ErrorStyle:= cveStop;
      1: V.ErrorStyle:= cveWarning;
      2: V.ErrorStyle:= cveInfo;
    end;

    case ((Options shr 20) and $07) of
      0: V.ValidationOperation:= cvoBetween;
      1: V.ValidationOperation:= cvoNotBetween;
      2: V.ValidationOperation:= cvoEqual;
      3: V.ValidationOperation:= cvoNotEqual;
      4: V.ValidationOperation:= cvoGT;
      5: V.ValidationOperation:= cvoLT;
      6: V.ValidationOperation:= cvoGTE;
      7: V.ValidationOperation:= cvoLTE;
    end;

    V.AllowBlank:= ((Options and $100) <> 0);
    V.InCellDropdown:= ((Options and $200) = 0);
    V.ShowInputMessage:=  (( Options and $40000) <> 0);
    V.ShowErrorMessage:=  (( Options and $80000) <> 0);

    { Messages }           
    StmReadMessageString(Msg);
    V.InputTitle:= Msg;
    StmReadMessageString(Msg);
    V.ErrorTitle:= Msg;
    StmReadMessageString(Msg);
    V.InputMessage:= Msg;
    StmReadMessageString(Msg);
    V.ErrorMessage:= Msg;

    { Expressions }
    StmReadExpression(Expression1);
    StmReadExpression(Expression2);

    { Area }
    StmReadArea;

    { Parse expressions }
    V.Expression1:= ParseExpression(Expression1);
    V.Expression2:= ParseExpression(Expression2);

  finally
    Stm.Destroy;
  end;
end;

end.
