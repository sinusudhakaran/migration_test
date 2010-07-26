unit XLSBase;

{-----------------------------------------------------------------
    SM Software, 2000-2004

    TXLSFile v.4.0
-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes;

{$IFDEF XLF_D3}
type
  Longword = Cardinal;
{$ENDIF}

{ Include constants }
{$I XLSConst.inc}

type
  {TChangeble}
  TChangeable = class
  protected
    FOnChange: TNotifyEvent;
    procedure DoChange; dynamic;
  public
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  {TProgressEvent}
  TProgressEvent = procedure (ProgressRate: Double) of object;

  {TXLSProcessingState}
  TXLSProcessingState = (psNothing, psReading, psDataFromFile);

  {TTXTFileType}
  TTXTFileType = (txtCSV, txtTab);

  {TReaderOptions}
  TReaderOptions = packed record
    ReadEmptyCells: Boolean;
    ReadRowFormats: Boolean;
    ReadColumnFormats: Boolean;
    ReadFormulas: Boolean;
    RaiseErrorOnReadUnknownFormula: Boolean;
    ReadDrawings: Boolean;
  end;

{$IFNDEF XLF_D2009}
  AnsiChar = Char;
  PAnsiChar = PChar;
{$ENDIF}

function IsValidRow(Row: Integer): Boolean;
function IsValidColumn(Column: Integer): Boolean;

implementation

uses XLSError;

{TChangeble}
procedure TChangeable.DoChange;
begin
  if Assigned(FOnChange) then FOnChange(Self);
end;

function IsValidRow(Row: Integer): Boolean;
begin
  Result:= (Row >= 0) and (Row < Integer(BIFF8_MAXROWS) );
end;

function IsValidColumn(Column: Integer): Boolean;
begin
  Result:= (Column >= 0) and (Column < BIFF8_MAXCOLS );
end;

end.
