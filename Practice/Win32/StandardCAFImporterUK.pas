unit StandardCAFImporterUK;

interface

uses
  Windows, SysUtils, CAFImporter, PDFFieldEditor;

type
  TStandardCAFSourceHelperUK = class helper for TCAFSource
  strict private
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
    
    procedure Initialize(Source: TCAFSource); override;
    function SupportedFormats: TCAFFileFormats; override;
    
    property MultiImport: Boolean read FMultiImport;
  end;

implementation

uses
  BKConst, Globals, StrUtils, Math;

procedure TStandardCAFImporterUK.DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String);
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
  Template.SetFieldValue(ukCAFStartYear, Source.Year);

  Template.SetFieldValue(ukCAFCostCode, Source.CostCode);

  if CompareText(Trim(Source.Provisional), 'Y') = 0 then
  begin
    Template.SetFieldValue(ukCAFSupplyProvisionalAccounts, 'Yes');
  end;

  if CompareText(Trim(Source.Frequency), 'M') = 0 then
  begin
    Template.SetFieldValue(ukCAFMonthly, 'Yes');
  end
  else
  if CompareText(Trim(Source.Frequency), 'W') = 0 then
  begin
    Template.SetFieldValue(ukCAFWeekly, 'Yes');
  end
  else
  begin
    Template.SetFieldValue(ukCAFDaily, 'Yes');
  end;

  if FMultiImport then
  begin
    OutputFile := Format('Customer Authority Form%s.PDF', [IntToStr(CAFCount + 1)]);
  end
  else
  begin
    OutputFile := 'Customer Authority Form.PDF';
  end;
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
    if Length(Trim(Source.Year)) = 2 then
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

function TStandardCAFImporterUK.GetMinFieldCount: Integer;
begin
  Result := 11;  
end;

function TStandardCAFImporterUK.GetPDFTemplateFile: String;
begin
  Result := istUKTemplateFileNames[istUKNormal];
end;

{ TStandardCAFSourceHelperUK }

function TStandardCAFSourceHelperUK.GetAccountName: String;
begin
  Result := LeftStr(ValueByIndex(0), 60);
end;

function TStandardCAFSourceHelperUK.GetAccountNo: String;
begin
  Result := LeftStr(ValueByIndex(2), 22);
end;

function TStandardCAFSourceHelperUK.GetBank: String;
begin
  Result := LeftStr(ValueByIndex(7), 60);
end;

function TStandardCAFSourceHelperUK.GetBranch: String;
begin
  Result := LeftStr(ValueByIndex(8), 60);
end;

function TStandardCAFSourceHelperUK.GetClientCode: String;
begin
  Result := LeftStr(ValueByIndex(5), 8);
end;

function TStandardCAFSourceHelperUK.GetCostCode: String;
begin
  Result := LeftStr(ValueByIndex(6), 8);
end;

function TStandardCAFSourceHelperUK.GetFrequency: String;
begin
  Result := ValueByIndex(11);
end;

function TStandardCAFSourceHelperUK.GetMonth: String;
begin
  Result := ValueByIndex(9);
end;

function TStandardCAFSourceHelperUK.GetProvisional: String;
begin
  Result := ValueByIndex(12);
end;

function TStandardCAFSourceHelperUK.GetSortCode: String;
begin
  Result := LeftStr(ValueByIndex(1), 8);
end;

function TStandardCAFSourceHelperUK.GetYear: String;
begin
  Result := ValueByIndex(10);
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
