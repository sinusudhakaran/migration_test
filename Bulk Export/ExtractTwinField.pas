unit ExtractTwinField;

interface

uses
  ExtractCommon,
  Windows,
  Graphics;

function GetExtractVersion: Integer; stdcall;
procedure procInitDllApplication(ApplicationHandle : HWnd; BaseFont: TFont); stdcall;
function DoBulkExport(var Session: TExtractSession): Integer; stdcall;
function GetExtractType(Index: integer; var EType: ExtractType): Boolean; stdcall;

implementation

uses
  Dialogs,
  ExtractHelpers,
  Controls,
  frmCSVConfig,
  Forms,
  SysUtils,
  Classes,
  StDateSt,
  StrUtils;

const
  BasicTwinField = 0;

  keySeparateClientFiles = 'SeparateClientFiles';
  keyExtractPath = 'ExtractPath';

  EPOCH = 1970;

var // General Extract vars
  MyFont: TFont;
  OutputFile: Text;
  OutputFileName: string;
  FilePerClient: Boolean;

  //SCVExport Specific
  CurrentClientCode: string;
  CurrentAccount: string;
  CurrentContra: string;

var
  FExtractFieldHelper: TExtractFieldHelper;
  FExportLines: TStringList;

{$REGION 'Internal methods'}
function ExtractFieldHelper: TExtractFieldHelper;
begin
  if not Assigned(FExtractFieldHelper) then
  begin
    FExtractFieldHelper := TExtractFieldHelper.Create;
  end;

  Result := FExtractFieldHelper;
end;

function TrapException (var Session: TExtractSession; value: ProcBulkExport):Integer; stdcall;
begin  // Helper to trap any IO or other exeptions
  try
    Result := Value(Session);
  except
    on E: exception do
    begin
      Result := er_Abort;
      Session.Data := PChar(E.Message);
    end;
  end;
end;

function GetPrivateProfileText(anApp, AKey, Default, Inifile: string; bufsize: Integer = 400): string;
var LB: PChar;
begin
  Result := Default;
  
  if (Length(IniFile) = 0) or (Length(AnApp) = 0) or (Length(AKey) = 0) then
  begin
    Exit;
  end;

  GetMem(LB, bufsize);
  
  try
     GetPrivateProfileString(pchar(AnApp),pChar(AKey),pchar(Default),LB,bufsize,Pchar(IniFile));
     
     Result := string(LB);
  finally
     FreeMem(LB,bufsize);
  end;
end;

function CleanTextField(const Value: string): string;
begin
  Result := ExtractFieldHelper.ReplaceQuotesAndCommas(ExtractFieldHelper.RemoveQuotes(Value));
end;

function FindExtractPath(Session: TExtractSession): string;
begin
   // Does not have a default, so I know if it has been set
  Result := '';

  if Session.IniFile <> nil then
  begin
    case Session.Index of
      0 : Result :=  GetPrivateProfileText(TwinField,'ExtractPath', '', string(Session.IniFile));
    end;
  end;
end;

function GetExtractPath(Session: TExtractSession): string;
begin
   // Forces a default, so we have a strarting point
  Result := FindExtractPath(Session);

  if Result = '' then
  begin
    Result := ExtractFilePath(Application.ExeName) + 'Export.csv';
  end;
end;

function DoSimpleConfig (var Session: TExtractSession): Integer; stdcall;
var
  ldlg: TCSVConfig;
begin
  Result := er_Cancel; // Cancel by default

  ldlg := TCSVConfig.Create(nil);

  try
    if Assigned(MyFont) then
    begin
      ldlg.Font.Assign(MyFont);
    end;

    ldlg.Caption :='Twinfield CSV Setup';
    ldlg.eFilename.Text := GetExtractPath(Session);
    ldlg.ckSeparate.Checked := Bool(GetPrivateProfileInt(TwinField, keySeparateClientFiles, 0, Session.IniFile));

    if ldlg.ShowModal = mrOK then
    begin
      WritePrivateProfileString(TwinField, KeyExtractPath, PChar(ldlg.eFilename.Text), Session.IniFile);
      WritePrivateProfilestring(TwinField, KeySeparateClientFiles, PChar(IntToStr(Integer(ldlg.ckSeparate.Checked))), Session.IniFile);

      Result := er_OK; // Extract path is set..
    end;
  finally
    ldlg.Free;
  end;
end;

function DoCompare(List: TStringList; Index1, Index2: Integer): Integer;
var
  FieldsA: TStringList;
  FieldsB: TStringList;
begin
  FieldsA := TStringList.Create;

  try
    FieldsA.Delimiter := ',';
    FieldsA.StrictDelimiter := True;

    FieldsB := TStringList.Create;

    try
      FieldsB.Delimiter := ',';
      FieldsB.StrictDelimiter := True;

      FieldsA.CommaText := List[Index1];
      FieldsB.CommaText := List[Index2];

      Result := CompareText(FieldsA[6] + FieldsA[7] + FieldsA[0], FieldsB[6] + FieldsB[7] + FieldsB[0]);
    finally
      FieldsB.Free;
    end;
  finally
    FieldsA.Free;
  end;
end;

procedure OpenOutputFile(const Filename:string);
begin
  Assign(OutputFile, Filename);

  Rewrite(OutputFile);

  FExportLines.Clear;
end;

procedure CloseOutputFile;
var
  Index: Integer;
begin
  FExportLines.CustomSort(DoCompare);
  
  for Index := 0 to FExportLines.Count - 1 do
  begin
    Writeln(Outputfile, FExportLines[Index]);
  end;

  CloseFile(OutputFile);
end;

function SessionStart(var Session: TExtractSession): Integer; stdcall;
var
  Path: string;
begin
  Result := er_OK;

  FExportLines := TStringList.Create;
  FExportLines.Delimiter := '|';
  FExportLines.StrictDelimiter := True;

  OutputFileName := FindExtractPath(Session);

  Path := ExtractFilePath(OutputFileName);

  while (Path = '') or (not DirectoryExists(Path)) or (OutputFileName = '') do
  begin
    if DoSimpleConfig(Session) = er_OK then
    begin
      OutputFileName := FindExtractPath(Session);
      Path := ExtractFilePath(OutputFileName);
    end
    else
    begin
      Result := er_Cancel; //Can't continue without a valid path
      Exit;
    end;
  end;

  if OutputFileName > '' then
  begin
    FilePerClient := Bool(GetPrivateProfileInt(TwinField, keySeparateClientFiles, 0, Session.IniFile));

    if not FilePerClient then
    begin
      OpenOutputFile(OutputFileName);
    end;
  end
  else
  begin
    Result := er_Cancel; // User must have canceled
  end;
end;

function SessionEnd(var Session: TExtractSession): Integer; stdcall;
begin
  try
    if (TTextRec(OutPutFile).Mode <> 0) and (TTextRec(OutPutFile).Mode <> fmClosed) then
    begin
      CloseOutputFile; // SavetyNet..

      FExportLines.Free;
    end;
  except
    // I tryed...
  end;

  Result := er_OK;
end;

function ClientStart(var Session: TExtractSession): Integer; stdcall;
begin
  ExtractFieldHelper.SetFields(Session.Data);

  CurrentClientCode := CleanTextField(ExtractFieldHelper.GetField(f_Code));

  if FilePerClient then
  begin
    OutputFileName := ExtractFilePath(OutputFileName) + ExtractFieldHelper.RemoveQuotes(CurrentClientCode) + '.csv';

    OpenOutputFile(OutputFileName);
  end;

  Result := er_OK;
end;

function ClientEnd (var Session: TExtractSession): Integer; stdcall;
begin
  if FilePerClient then
  begin
    CloseOutputFile;
  end;

  Result := er_OK;
end;


function AccountStart(var Session: TExtractSession): Integer; stdcall;
begin
  ExtractFieldHelper.SetFields(Session.Data);

  CurrentAccount := CleanTextField(ExtractFieldHelper.GetField(f_Number));
  CurrentContra := CleanTextField(ExtractFieldHelper.GetField(f_ContraCode));

  Result := er_OK;
end;


procedure WriteSimpleFields(var Session: TExtractSession);

  function IsDebitAmount(AmountStr: String): Boolean;
  begin
    if AmountStr <> '' then
    begin
      if AmountStr[1] = '-' then
      begin
        Result := False;
      end
      else
      begin
        Result := True;
      end;
    end
    else
    begin
      Result := True;
    end;
  end;

var
  TransactionType: Integer;
  TransactionCode: String;
  AccountSortCode: String;
  BankAccountCode: String;
  TransactionDate: Integer;
  DebitCreditChar: String;
  TransactionAmount: String;
begin
  if CurrentAccount = '' then
  begin
    Exit;
  end;

  with ExtractFieldHelper do
  begin
    BankAccountCode := ReplaceStr(RemoveQuotes(CurrentAccount), 'M', '');

    TransactionDate := DateStringToStDate('dd/mm/yyyy', GetField(f_Date), EPOCH);

    TransactionAmount := GetField(f_Amount, '0.00');

    TransactionType := StrToIntDef(GetField(f_TransType), 0);

    if IsDebitAmount(TransactionAmount) then
    begin
      DebitCreditChar := 'D';
    end
    else
    begin
      DebitCreditChar := 'C';

      TransactionAmount := Copy(TransactionAmount, 2, Length(TransactionAmount));
    end;
      
    if TransactionType = 1 then
    begin
      TransactionCode := 'CHQ';
    end
    else
    if DebitCreditChar = 'D' then
    begin
      TransactionCode := 'DBT';
    end
    else
    begin
      TransactionCode := 'CDT';
    end;

    AccountSortCode := Copy(BankAccountCode, 1, 6);
    BankAccountCode := Copy(BankAccountCode, 7, Length(BankAccountCode)); 

    FExportLines.Add(
      StDateToDateString('yyyymmdd', TransactionDate, False) + ',' +
      TransactionAmount + ',' +
      TransactionCode + ',' +
      CleanTextField(GetField(f_Narration)) + ',' +
      DebitCreditChar + ',' +
      'F' + ',' +
      AccountSortCode + ',' +
      BankAccountCode);
  end;
end;

function Transaction(var Session: TExtractSession): Integer; stdcall;
begin
  ExtractFieldHelper.SetFields(Session.Data);

  case Session.Index of
    0:  WriteSimpleFields(Session);
  end;

  Result := er_OK;
end;

{$ENDREGION}

{$REGION 'Exportable methods'}
function GetExtractVersion: Integer; stdcall;
begin
  Result :=  Version_1;
end;

procedure procInitDllApplication(ApplicationHandle : HWnd; BaseFont: TFont); stdcall;
begin
  if ApplicationHandle <> 0 then
  begin
    Application.Handle := ApplicationHandle;
  end;
  
  if Assigned(BaseFont) then
  begin
    if not assigned(MyFont) then
    begin
      MyFont := TFont.Create;
    end;

    // cannot use assign because the class is not the same.
    MyFont.Name :=  BaseFont.Name;
    MyFont.Height := BaseFont.Height;
  end;
end;

function DoBulkExport(var Session: TExtractSession): Integer; stdcall;
begin
  Result := er_NotImplemented; // Do not fail u

  case Session.ExtractFunction of
    ef_SessionStart  : Result := TrapException(Session, SessionStart);

    ef_SessionEnd    : Result := TrapException(Session, SessionEnd);

    ef_ClientStart   :Result := TrapException(Session, ClientStart);
    ef_ClientEnd     :Result := TrapException(Session, ClientEnd);
    ef_AccountStart  :Result := TrapException(Session, AccountStart);

    ef_Transaction   :Result := TrapException(Session, Transaction);
    ef_Dissection    :Result := TrapException(Session, Transaction);

    ef_CanConfig    : case Session.Index of
                         0: Result := er_OK;
                       end;
    ef_DoConfig     : case Session.Index of
                         0: Result := DoSimpleConfig(Session);
                       end;
  end;
end;

function GetExtractType(Index: integer; var EType: ExtractType): Boolean; stdcall;
begin
  Result := False;

  case Index of
    BasicTwinField :
    begin
      EType.Index := BasicTwinField;
      EType.Code  := TwinField;
      EType.Description := 'Twinfield CSV';
      EType.ExtractClass := ClassBase;
      Result := True;
    end;
  end;
end;
{$ENDREGION}

end.
