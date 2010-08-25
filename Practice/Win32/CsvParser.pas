unit CsvParser;

interface

uses
  Classes;

type
  TCsvParser = class;  // Forward declaration
  TParserStateClass = class of TCsvParserState;


  TCsvParserState = class(TObject)
  private
    FParser : TCsvParser;

    procedure ChangeState(NewState : TParserStateClass);
    procedure AddCharToCurrField(Ch : Char);
    procedure AddCurrFieldToList;
  public
    constructor Create(AParser : TCsvParser);

    procedure ProcessChar(Ch : AnsiChar;Pos : Integer); virtual; abstract;
  end;


  TCsvParserFieldStartState = class(TCsvParserState)
  private
  public
    procedure ProcessChar(Ch : AnsiChar;Pos : Integer); override;
  end;


  TCsvParserScanFieldState = class(TCsvParserState)
  private
  public
    procedure ProcessChar(Ch : AnsiChar;Pos : Integer); override;
  end;


  TCsvParserScanQuotedState = class(TCsvParserState)
  private
  public
    procedure ProcessChar(Ch : AnsiChar;Pos : Integer); override;
  end;


  TCsvParserEndQuotedState = class(TCsvParserState)
  private
  public
    procedure ProcessChar(Ch : AnsiChar;Pos : Integer); override;
  end;


  TCsvParserGotErrorState = class(TCsvParserState)
  private
  public
    procedure ProcessChar(Ch : AnsiChar;Pos : Integer); override;
  end;


  TCsvParser = class(TObject)
  private
    FState           : TCsvParserState;
    // Cache state objects for greater performance
    FFieldStartState : TCsvParserFieldStartState;
    FScanFieldState  : TCsvParserScanFieldState;
    FScanQuotedState : TCsvParserScanQuotedState;
    FEndQuotedState  : TCsvParserEndQuotedState;
    FGotErrorState   : TCsvParserGotErrorState;
    // Fields used during parsing
    FCurrField       : string;
    FFieldList       : TStrings;

    function  GetState : TParserStateClass;
    procedure SetState(const Value : TParserStateClass);
  protected
    procedure AddCharToCurrField(Ch : Char);
    procedure AddCurrFieldToList;

    property State : TParserStateClass read GetState write SetState;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure ExtractFields(const s : string;AFieldList : TStrings);
  end;


implementation

uses
  SysUtils;

{ TCsvParser }

constructor TCsvParser.Create;
begin
  inherited Create;
  FFieldStartState := TCsvParserFieldStartState.Create(Self);
  FScanFieldState  := TCsvParserScanFieldState.Create(Self);
  FScanQuotedState := TCsvParserScanQuotedState.Create(Self);
  FEndQuotedState  := TCsvParserEndQuotedState.Create(Self);
  FGotErrorState   := TCsvParserGotErrorState.Create(Self);
end;


destructor TCsvParser.Destroy;
begin
  FFieldStartState.Free;
  FScanFieldState.Free;
  FScanQuotedState.Free;
  FEndQuotedState.Free;
  FGotErrorState.Free;
  inherited;
end;


function TCsvParser.GetState : TParserStateClass;
begin
  Result := TParserStateClass(FState.ClassType);
end;


procedure TCsvParser.SetState(const Value : TParserStateClass);
begin
  if Value = TCsvParserFieldStartState then begin
    FState := FFieldStartState;
  end else if Value = TCsvParserScanFieldState then begin
    FState := FScanFieldState;
  end else if Value = TCsvParserScanQuotedState then begin
    FState := FScanQuotedState;
  end else if Value = TCsvParserEndQuotedState then begin
    FState := FEndQuotedState;
  end else if Value = TCsvParserGotErrorState then begin
    FState := FGotErrorState;
  end;
end;


procedure TCsvParser.ExtractFields(const s : string;AFieldList : TStrings);
  var
    i  : Integer;
    Ch : AnsiChar;
begin
  FFieldList := AFieldList;
  Assert(Assigned(FFieldList),'FieldList not assigned');
  // Initialize by clearing the string list, and starting in FieldStart state
  FFieldList.Clear;
  State      := TCsvParserFieldStartState;
  FCurrField := '';

  // Read through all the characters in the string
  for i := 1 to Length(s) do begin
    // Get the next character
    Ch := s[i];
    FState.ProcessChar(Ch,i);
  end;

  // If we are in the ScanQuoted or GotError state at the end
  // of the string, there was a problem with a closing quote
  if (State = TCsvParserScanQuotedState) or
     (State = TCsvParserGotErrorState) then begin
    raise Exception.Create('Missing closing quote');
  end;

  // If the current field is not empty, add it to the list
  if (FCurrField <> '') then begin
    AddCurrFieldToList;
  end;
end;


procedure TCsvParser.AddCharToCurrField(Ch : Char);
begin
  FCurrField := FCurrField + Ch;
end;


procedure TCsvParser.AddCurrFieldToList;
begin
  FFieldList.Add(FCurrField);
  // Clear the field in preparation for collecting the next one
  FCurrField := '';
end;


{ TCsvParserState }

constructor TCsvParserState.Create(AParser : TCsvParser);
begin
  inherited Create;
  FParser := AParser;
end;


procedure TCsvParserState.ChangeState(NewState : TParserStateClass);
begin
  FParser.State := NewState;
end;


procedure TCsvParserState.AddCharToCurrField(Ch : Char);
begin
  FParser.AddCharToCurrField(Ch);
end;


procedure TCsvParserState.AddCurrFieldToList;
begin
  FParser.AddCurrFieldToList;
end;


{ TCsvParserFieldStartState }

procedure TCsvParserFieldStartState.ProcessChar(Ch : AnsiChar;Pos : Integer);
begin
  case Ch of
    '"' : ChangeState(TCsvParserScanQuotedState);
    ',' : AddCurrFieldToList;
  else
    AddCharToCurrField(Ch);
    ChangeState(TCsvParserScanFieldState);
  end;
end;


{ TCsvParserScanFieldState }

procedure TCsvParserScanFieldState.ProcessChar(Ch : AnsiChar;Pos : Integer);
begin
  if (Ch = ',') then begin
    AddCurrFieldToList;
    ChangeState(TCsvParserFieldStartState);
  end else begin
    AddCharToCurrField(Ch);
  end;
end;


{ TCsvParserScanQuotedState }

procedure TCsvParserScanQuotedState.ProcessChar(Ch : AnsiChar;Pos : Integer);
begin
  if (Ch = '"') then begin
    ChangeState(TCsvParserEndQuotedState);
  end else begin
    AddCharToCurrField(Ch);
  end;
end;


{ TCsvParserEndQuotedState }

procedure TCsvParserEndQuotedState.ProcessChar(Ch : AnsiChar;Pos : Integer);
begin
  if (Ch = ',') then begin
    AddCurrFieldToList;
    ChangeState(TCsvParserFieldStartState);
  end else begin
    ChangeState(TCsvParserGotErrorState);
  end;
end;


{ TCsvParserGotErrorState }

procedure TCsvParserGotErrorState.ProcessChar(Ch : AnsiChar;Pos : Integer);
begin
  raise Exception.Create(Format('Error in line at position %d',[Pos]));
end;


end.
