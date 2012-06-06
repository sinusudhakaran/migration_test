unit CsvParser;

interface

uses
  Classes, Contnrs;

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

  TDelimitedFile = class;
  
  TDelimitedField = class
  private
    FOwner: TDelimitedFile;
    FIndex: Integer;
    FFieldName: String;

    function GetValue(RowIndex: Integer): String;
  public
    constructor Create(Owner: TDelimitedFile; const FieldName: String; Index: Integer);

    property FieldName: String read FFieldName;

    property Values[RowIndex: Integer]: String read GetValue;
  end;

  TDelimitedFile = class
  private
    type
      TRow = class
      private
        FValues: array of String;
        
        function GetValue(Index: Integer): String;
        procedure SetValue(Index: Integer; const Value: String);
      public
        constructor Create(ColumnCount: Integer);
        destructor Destroy; override;
        
        property Values[Index: Integer] : String read GetValue write SetValue;
      end;

  private
    FFields: TObjectList;
    FRows: TObjectList;
    FDelimiter: Char;
    
    function GetFieldCount: Integer;
    function GetRowCount: Integer;
    procedure SetDelimited(const Value: Char);
    function GetValue(Row, Column: Integer): String;
  public
    constructor Create;
    destructor Destroy; override;

    procedure LoadFromFile(const FileName: String; FirstRowIsHeader: Boolean); virtual;

    procedure Clear;

    function FieldExists(const FieldName: String): Boolean;
    
    function FieldByName(const FieldName: String): TDelimitedField;

    property Delimited: Char read FDelimiter write SetDelimited;
    
    property FieldCount: Integer read GetFieldCount;
    property RowCount: Integer read GetRowCount;
    property Values[Row, Column: Integer]: String read GetValue;
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


{ TDelimitedFile }

procedure TDelimitedFile.Clear;
begin
  FFields.Clear;
  FRows.Clear;
end;

constructor TDelimitedFile.Create;
begin
  FFields := TObjectList.Create(True);
  FRows := TObjectList.Create(True);

  FDelimiter := ',';
end;

destructor TDelimitedFile.Destroy;
begin
  FFields.Free;
  FRows.Free;
  
  inherited;
end;

function TDelimitedFile.GetFieldCount: Integer;
begin
  Result := FFields.Count;
end;

function TDelimitedFile.GetRowCount: Integer;
begin
  Result := FRows.Count;
end;

function TDelimitedFile.GetValue(Row, Column: Integer): String;
begin
  Result := TRow(FRows[Row]).Values[Column];
end;

procedure TDelimitedFile.LoadFromFile(const FileName: String; FirstRowIsHeader: Boolean);
var
  FileLines: TStringList;
  FileLine: TStringList;
  ValuesRow: Integer;
  Index: Integer;
  IIndex: Integer;
  Row: TRow;
begin
  Clear;
  
  FileLines := TStringList.Create;

  try
    FileLines.LoadFromFile(FileName);

    if FileLines.Count > 0 then
    begin
      FileLine := TStringList.Create;

      try
        FileLine.Delimiter := FDelimiter;
        FileLine.StrictDelimiter := True;
        
        if FirstRowIsHeader then
        begin
          FileLine.DelimitedText := FileLines[0];

          for Index := 0 to FileLine.Count - 1 do
          begin
            FFields.Add(TDelimitedField.Create(Self, FileLine[Index], Index));
          end;

          ValuesRow := 1;
        end
        else
        begin
          ValuesRow := 0;
        end;

        for Index := ValuesRow to FileLines.Count - 1 do
        begin
          if Trim(FileLines[Index]) <> '' then
          begin
            FileLine.DelimitedText := FileLines[Index];

            Row := TRow.Create(FileLine.Count);

            try
              for IIndex := 0 to FileLine.Count - 1 do
              begin
                Row.Values[IIndex] := FileLine[IIndex];
              end;

              FRows.Add(Row);
            except
              Row.Free;

              raise;
            end;
          end;
        end;
      finally
        FileLine.Free;
      end;
    end;
  finally
    FileLines.Free;
  end;
end;

procedure TDelimitedFile.SetDelimited(const Value: Char);
begin
  FDelimiter := Value;
end;

function TDelimitedFile.FieldByName(const FieldName: String): TDelimitedField;
var
  Index: Integer;
begin
  Result := nil;
  
  for Index := 0 to FFields.Count - 1 do
  begin
    if CompareText(TDelimitedField(FFields[Index]).FieldName, FieldName) = 0 then
    begin
      Result := TDelimitedField(FFields[Index]);

      Break;
    end;
  end;
end;

function TDelimitedFile.FieldExists(const FieldName: String): Boolean;
var
  Index: Integer;
begin
  Result := False;
  
  for Index := 0 to FFields.Count - 1 do
  begin
    if CompareText(TDelimitedField(FFields[Index]).FieldName, FieldName) = 0 then
    begin
      Result := True;

      Break;
    end;
  end;
end;

{ TDelimitedFile.TRow }

constructor TDelimitedFile.TRow.Create(ColumnCount: Integer);
begin
  SetLength(FValues, ColumnCount);
end;

destructor TDelimitedFile.TRow.Destroy;
begin
  SetLength(FValues, 0);
  
  inherited;
end;

function TDelimitedFile.TRow.GetValue(Index: Integer): String;
begin
  Result := FValues[Index];
end;

procedure TDelimitedFile.TRow.SetValue(Index: Integer; const Value: String);
begin
  FValues[Index] := Value;
end;

{ TDelimitedField }

constructor TDelimitedField.Create(Owner: TDelimitedFile; const FieldName: String; Index: Integer);
begin
  FOwner := Owner;
  FIndex := Index;
  FFieldName := FieldName;
end;

function TDelimitedField.GetValue(RowIndex: Integer): String;
begin
  Result := FOwner.Values[RowIndex, FIndex]; 
end;

end.
