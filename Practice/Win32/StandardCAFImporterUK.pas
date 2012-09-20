unit StandardCAFImporterUK;

interface

uses
  Windows, SysUtils, CAFImporter, PDFFieldEditor;

type
   ukCAFBulkImportOrder = (ucfAccName, ucfSortCode, ucfAccNum, ucfClientCode, ucfCostCode,
                           ucfBank, ucfBranch, ucfMonth, ucfYear, ucfFreq, ucfProv,
                           ucfAccSig1, ucfAccSig2, ucfAddrLine1, ucfAddrLine2, ucfAddrLine3,
                           ucfAddrLine4, ucfPostCode);

  TStandardCAFSourceHelperUK = class helper for TCAFSource
  strict private
    function TransformMonthValue(aValue: string): string;

    function GetAccountName: String;
    function GetAccountNo: String;
    function GetBank: String;
    function GetBranch: String;
    function GetClientCode: String;
    function GetCostCode: String;
    function GetFrequency: String;
    function GetMonth: String;
    function GetProvisional: String;
    function GetSortCode: String;
    function GetYear: String;
  public
    property AccountName: String read GetAccountName;
    property SortCode: String read GetSortCode;
    property AccountNo: String read GetAccountNo;
    property ClientCode: String read GetClientCode;
    property CostCode: String read GetCostCode;
    property Bank: String read GetBank;
    property Branch: String read GetBranch;
    property Month: String read GetMonth;
    property Year: String read GetYear;
    property Frequency: String read GetFrequency;
    property Provisional: String read GetProvisional;
  end;

  TPDFEditorHelper = class helper for TPDFFieldEdit
  public
    procedure SetFieldValue(const FieldTitle, Value: String);
    procedure LinkFieldByTitle(const TargetField, LinkField: String);
  end;

  TStandardCAFImporterUK = class(TCAFImporter)
  private
    FMultiImport: Boolean;
  protected
    procedure DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String); override;
    procedure DoRecordValidation(Source: TCAFSource); override;
    function GetPDFTemplateFile: String; override;
    function GetMinFieldCount: Integer; override;
    function GetImporterName: String; override;

    // Override this if you want to use a different OutputFile base
    function  GetOutputFileBase: string; virtual;

    procedure Initialize(Source: TCAFSource); override;
    function SupportedFormats: TCAFFileFormats; override;

    property MultiImport: Boolean read FMultiImport;
  end;

implementation

uses
  BKConst, Globals, StrUtils, Math;



procedure TStandardCAFImporterUK.DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String);
var
  ClientCode: string;
begin
  Template.SetFieldValue(ukCAFPracticeCode, AdminSystem.fdFields.fdBankLink_Code);
  Template.SetFieldValue(ukCAFPracticeName, AdminSystem.fdFields.fdPractice_Name_for_Reports);

  Template.SetFieldValue(ukCAFClientCode, Source.ClientCode);

  Template.SetFieldValue(ukCAFNameOfAccount, Source.AccountName);

  Template.SetFieldValue(ukCAFBankCode, Source.SortCode);
  Template.SetFieldValue(ukCAFAccountNumber, Source.AccountNo);

  Template.SetFieldValue(ukCAFBankName, Source.Bank);
  Template.SetFieldValue(ukCAFBranchName, Source.Branch);

  Template.SetFieldValue(ukCAFStartMonth, Source.Month);

  if Length(Source.Year) = 4 then
  begin
    Template.SetFieldValue(ukCAFStartYear, RightStr(Source.Year, 2));
  end
  else
  begin
    Template.SetFieldValue(ukCAFStartYear, Source.Year);
  end;

  Template.SetFieldValue(ukCAFCostCode, Source.CostCode);

  if CompareText(Trim(Source.Provisional), 'Y') = 0 then
  begin
    Template.SetFieldValue(ukCAFSupplyProvisionalAccounts, 'Yes');
  end;

  if CompareText(Trim(Source.Frequency), 'M') = 0 then
  begin
    Template.SetFieldValue(ukCAFMonthly, 'Yes');
    Template.SetFieldValue(ukCAFWeekly, 'No');
    Template.SetFieldValue(ukCAFDaily, 'No');
  end
  else
  if CompareText(Trim(Source.Frequency), 'W') = 0 then
  begin
    Template.SetFieldValue(ukCAFWeekly, 'Yes');
    Template.SetFieldValue(ukCAFMonthly, 'No');
    Template.SetFieldValue(ukCAFDaily, 'No');
  end
  else
  begin
    Template.SetFieldValue(ukCAFDaily, 'Yes');
    Template.SetFieldValue(ukCAFMonthly, 'No');
    Template.SetFieldValue(ukCAFWeekly, 'No');
  end;

  // Determine OutputFile (override GetOutputFileBase for different filenames)
  OutputFile := GetOutputFileBase;
  if MultiImport then
  begin
    ClientCode := Trim(Source.ClientCode);
    if (ClientCode <> '') then
      OutputFile := OutputFile + ' ' + ClientCode;
    OutputFile := OutputFile + ' ' + IntToStr(CAFCount + 1);
  end;
  OutputFile := OutputFile + '.PDF';
end;

procedure TStandardCAFImporterUK.Initialize(Source: TCAFSource);
begin
  //Skip the field names row
  if CompareText(Trim(Source.AccountName), 'Account Name') = 0 then
  begin
    FMultiImport := Source.Count - 1 > 1;

    Source.Next;
  end
  else
  begin
    FMultiImport := Source.Count > 1;
  end;
end;

function TStandardCAFImporterUK.SupportedFormats: TCAFFileFormats;
begin
  Result := [cafPDF];
end;

procedure TStandardCAFImporterUK.DoRecordValidation(Source: TCAFSource);
begin
  if (Trim(Source.AccountName) = '') and (Trim(Source.SortCode) = '') and (Trim(Source.AccountNo) = '') then
  begin
    AddRecordValidationError(Source, 'You must enter the name of the account or the sort code or the account number.');
  end;

  if ContainsSymbols(Trim(Source.ClientCode)) then
  begin
    AddRecordValidationError(Source, 'The client code can only contain alpha numeric characters.');
  end;

  if ContainsSymbols(Trim(Source.CostCode)) then
  begin
    AddRecordValidationError(Source, 'The cost code can only contain alpha numeric characters.');
  end;

  if (Trim(Source.Month) = '') and (Trim(Source.Year) <> '') then
  begin
    AddRecordValidationError(Source, 'You must choose a starting month.');
  end
  else
  if CompareText(Source.Month, 'ASAP') <> 0 then
  begin
    if not IsLongMonthName(Trim(Source.Month)) then
    begin
      AddRecordValidationError(Source, 'You must enter a valid starting month.');
    end;
  end;

  if (Trim(Source.Year) = '') then
  begin
    if (CompareText(Source.Month, 'ASAP') <> 0) then
    begin
      AddRecordValidationError(Source, 'You must enter a valid starting year.');
    end;
  end
  else
  begin
    if Length(Trim(Source.Year)) in[2,4] then
    begin
      if not IsNumber(Source.Year) then
      begin
        AddRecordValidationError(Source, 'You must enter a valid starting year.');
      end;
    end
    else
    begin
      AddRecordValidationError(Source, 'You must enter a valid starting year.');
    end;
  end;
end;

function TStandardCAFImporterUK.GetImporterName: String;
begin
  Result := 'Standard/Other UK';
end;

function TStandardCAFImporterUK.GetMinFieldCount: Integer;
begin
  Result := 11;
end;

function TStandardCAFImporterUK.GetPDFTemplateFile: String;
begin
  Result := istUKTemplateFileNames[istUKNormal];
end;

function TStandardCAFImporterUK.GetOutputFileBase: string;
begin
  Result := 'Customer Authority Form';
end;

{ TStandardCAFSourceHelperUK }
function TStandardCAFSourceHelperUK.TransformMonthValue(aValue: string): string;
var
  ErrorIndex : integer;
  ValInt : integer;
  MonthIndex : integer;

  procedure IntegerMonth(Value: Integer);
  begin
    if (Value in [1..12]) then
      Result := LongMonthnames[Value]
    else
      Result := '';
  end;
begin
  if (aValue = '') or (Uppercase(aValue) = 'ASAP') then
  begin
    Result := aValue;
    Exit;
  end;

  Val(aValue,ValInt,ErrorIndex);
  if (ErrorIndex = 0) then
  begin
    // Seems to be a valid number..
    IntegerMonth(ValInt);
  end
  else
  begin
    // Test the text..
    for MonthIndex := 1 to 12 do
    begin
      if Sametext(ShortMonthNames[MonthIndex], aValue) then
      begin
        Result := LongMonthnames[MonthIndex];
        Exit;
      end
      else if Sametext(LongMonthNames[MonthIndex], aValue) then
      begin
        Result := aValue;
        Exit;
      end;
    end;
    Result := '';
  end
end;

function TStandardCAFSourceHelperUK.GetAccountName: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfAccName)), 60);
end;

function TStandardCAFSourceHelperUK.GetAccountNo: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfAccNum)), 22);
end;

function TStandardCAFSourceHelperUK.GetBank: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfBank)), 60);
end;

function TStandardCAFSourceHelperUK.GetBranch: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfBranch)), 60);
end;

function TStandardCAFSourceHelperUK.GetClientCode: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfClientCode)), 8);
end;

function TStandardCAFSourceHelperUK.GetCostCode: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfCostCode)), 8);
end;

function TStandardCAFSourceHelperUK.GetFrequency: String;
begin
  Result := ValueByIndex(ord(ucfFreq));
end;

function TStandardCAFSourceHelperUK.GetMonth: String;
begin
  Result := TransformMonthValue(ValueByIndex(ord(ucfMonth)));
end;

function TStandardCAFSourceHelperUK.GetProvisional: String;
begin
  Result := ValueByIndex(ord(ucfProv));
end;

function TStandardCAFSourceHelperUK.GetSortCode: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfSortCode)), 8);
end;

function TStandardCAFSourceHelperUK.GetYear: String;
begin
  Result := ValueByIndex(ord(ucfYear));
end;

{ TPDFEditorHelper }

procedure TPDFEditorHelper.LinkFieldByTitle(const TargetField, LinkField: String);
var
  Field: TPDFFormFieldItem;
begin
  Field := PDFFormFields.GetFieldByTitle(TargetField);

  if Field <> nil then
  begin
    Field.AddLinkFieldByTitle(LinkField); 
  end;
end;

procedure TPDFEditorHelper.SetFieldValue(const FieldTitle, Value: String);
var
  Field: TPDFFormFieldItem;
begin
  Field := PDFFormFields.GetFieldByTitle(FieldTitle);

  if Field <> nil then
  begin
    Field.Value := Value;
  end;
end;

end.
