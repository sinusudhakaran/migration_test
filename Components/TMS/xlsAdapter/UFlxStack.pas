unit UFlxStack;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
interface
uses Classes, Sysutils;
type
  TStringStack=class
  private
    FList: array of WideString;
    FListCount: integer;
  public
    constructor Create;
    destructor Destroy; override;

    function Count: Integer;
    function AtLeast(ACount: Integer): Boolean;
    procedure Push(const s: widestring); virtual;
    procedure Pop(var s: widestring);
    procedure Peek(var s: widestring);
  end;

  TFormulaStack=class (TStringStack)
  public
    FmSpaces, FmPreSpaces, FmPostSpaces: string ;
    procedure Push(const s: widestring); override;
  end;

  TWhiteSpace=record
    Count: byte;
    Kind: byte;
  end;

  TWhiteSpaceStack=class
  private
    FList: array of TWhiteSpace;
    FListCount: integer;
  public
    constructor Create;
    destructor Destroy; override;

    function Count: Integer;
    function AtLeast(ACount: Integer): Boolean;
    procedure Push(const s: TWhiteSpace); virtual;
    procedure Pop(var s: TWhiteSpace);
    procedure Peek(var s: TWhiteSpace);
  end;

implementation
resourcestring
  ErrEmptyStack='String Stack is empty';
  ErrEmptyWsStack='WhiteSpace Stack is empty';

{ TStringStack }

function TStringStack.AtLeast(ACount: Integer): Boolean;
begin
  Result := FListCount >= ACount;
end;

function TStringStack.Count: Integer;
begin
  Result := FListCount;
end;

constructor TStringStack.Create;
begin
  inherited Create;
  FListCount:=0;
end;

destructor TStringStack.Destroy;
begin
  inherited Destroy;
end;

procedure TStringStack.Peek(var s: widestring);
begin
  if (FListCount-1<0) or (FListCount-1>=Length(FList)) then raise Exception.Create(ErrEmptyStack);
  s := FList[FListCount-1];
end;

procedure TStringStack.Pop(var s: widestring);
begin
  Peek(s);
  if FListCount<=0 then raise Exception.Create(ErrEmptyStack);
  Dec(FListCount);
end;

procedure TStringStack.Push(const s: widestring);
begin
  if FListCount>=Length(FList) then SetLength(FList, Length(FList)+10);
  FList[FListCount]:=s;
  inc(FListCount);
end;

{ TFormulaStack }

procedure TFormulaStack.Push(const s: widestring);
begin
  inherited;
  FmSpaces:='';
  FmPreSpaces:='';
  FmPostSpaces:='';
end;


{ TWhiteSpaceStack }

function TWhiteSpaceStack.AtLeast(ACount: Integer): Boolean;
begin
  Result := FListCount >= ACount;
end;

function TWhiteSpaceStack.Count: Integer;
begin
  Result := FListCount;
end;

constructor TWhiteSpaceStack.Create;
begin
  inherited Create;
  FListCount:=0;
end;

destructor TWhiteSpaceStack.Destroy;
begin
  inherited Destroy;
end;

procedure TWhiteSpaceStack.Peek(var s: TWhiteSpace);
begin
  if (FListCount-1<0) or (FListCount-1>=Length(FList)) then raise Exception.Create(ErrEmptyWsStack);
  s := FList[FListCount-1];
end;

procedure TWhiteSpaceStack.Pop(var s: TWhiteSpace);
begin
  Peek(s);
  if FListCount<=0 then raise Exception.Create(ErrEmptyStack);
  Dec(FListCount);
end;

procedure TWhiteSpaceStack.Push(const s: TWhiteSpace);
begin
  if FListCount>=Length(FList) then SetLength(FList, Length(FList)+10);
  FList[FListCount]:=s;
  inc(FListCount);
end;


end.
