unit XLSError;

{-----------------------------------------------------------------
    SM Software, 2000-2008

    TXLSFile v.4.0
-----------------------------------------------------------------}

interface
uses SysUtils;

type
  {TEXLSErrorCode}
  TXLSErrorCode = (
    EXLS_NOERROR,
    EXLS_NOTENOUGHBUFFER,
    EXLS_STREAMNOTFOUND,
    EXLS_BADCELLVALUE,
    EXLS_BADCELLPROPERTY,
    EXLS_BADROWCOL,
    EXLS_BADSHEETNAME,
    EXLS_BADSHEETNAMELENGTH,
    EXLS_BADFORMULA,
    EXLS_BADFORMULAFUNCTION,
    EXLS_FMLASTRINGTOOLONG,
    EXLS_INVALIDNAME,
    EXLS_NOSHEETS,
    EXLS_UNKNOWNFORMULA,
    EXLS_INVALIDLINKTABLE,
    EXLS_INVALIDDRAWING,
    EXLS_INVALIDHLINK
  );

  {EXLSError}
  EXLSError = class(Exception)
  private
    FErrorCode: TXLSErrorCode;
  public
    constructor Create(ACode: TXLSErrorCode);
    constructor CreateFmt(ACode: TXLSErrorCode; const Args: array of const);
    constructor CreateWithText(ACode: TXLSErrorCode; const Text: AnsiString);
    property ErrorCode: TXLSErrorCode read FErrorCode;
  end;

const
  EXLSErrors: array [TXLSErrorCode] of AnsiString = (
   '',
   'Buffer size is too small.',
   'Stream not found: %s. File format is not Excel 97 or higher.',
   'Invalid cell value or type.',
   'Invalid cell property value.',
   'Invalid row or column number.',
   'Invalid or duplicated sheet name.',
   'Sheet name must have a length 1..255.',
   'Invalid formula.',
   'Invalid function in formula: %s.',
   'String constants in formula must have a length 0..255.',
   'Invalid range name: %s.',
   'There are no sheets in the workbook.',
   'Formula not recognized.',
   'Invalid data. Error in link table.',
   'Invalid data. Error in drawing stream.',
   'Invalid data. Error in hyperlink.'
  );

implementation

{EXLSError}
constructor EXLSError.Create(ACode: TXLSErrorCode);
begin
  FErrorCode:= ACode;
  inherited Create(String(EXLSErrors[ACode]));
end;

constructor EXLSError.CreateFmt(ACode: TXLSErrorCode;
  const Args: array of const);
begin
  FErrorCode:= ACode;
  inherited CreateFmt(String(EXLSErrors[ACode]), Args);
end;

constructor EXLSError.CreateWithText(ACode: TXLSErrorCode; const Text: AnsiString);
begin
  FErrorCode:= ACode;
  inherited Create(String(EXLSErrors[ACode]) + ' ' + String(Text));
end;

end.
