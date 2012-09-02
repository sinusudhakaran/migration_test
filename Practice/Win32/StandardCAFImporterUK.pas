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
    function FieldByTitle(const FieldTitle: String): TPDFFormFieldItem;
  end;

  TStandardCAFImporterUK = class(TCAFImporter)
  private
    FMultiImport: Boolean;
  protected
    procedure DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String); override;
    procedure DoRecordValidation(Source: TCAFSource); override;
    procedure DoFieldValidation(Source: TCAFSource); override;
    function GetPDFTemplateFile: String; override;

    procedure Initialize(Source: TCAFSource); override;
    function SupportedFormats: TCAFFileFormats; override;
    
    property MultiImport: Boolean read FMultiImport;
  end;

implementation

uses
  BKConst, Globals;

procedure TStandardCAFImporterUK.DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String);
begin
  Template.FieldByTitle(ukCAFPracticeCode).Value := AdminSystem.fdFields.fdBankLink_Code;
  Template.FieldByTitle(ukCAFPracticeName).Value := AdminSystem.fdFields.fdPractice_Name_for_Reports;
                                                                        
  Template.FieldByTitle(ukCAFClientCode).Value := Source.ClientCode;

  Template.FieldByTitle(ukCAFNameOfAccount).Value := Source.AccountName;
  Template.FieldByTitle(ukCAFAccountNumber).Value := Source.AccountNo;
  Template.FieldByTitle(ukCAFBankName).Value := Source.Bank;
  Template.FieldByTitle(ukCAFBranchName).Value := Source.Branch;
  Template.FieldByTitle(ukCAFStartMonth).Value := Source.Month;
  Template.FieldByTitle(ukCAFStartYear).Value := Source.Year;

  Template.FieldByTitle(ukCAFCostCode).Value := Source.CostCode;

  if CompareText(Trim(Source.Provisional), 'Y') = 0 then
  begin
    Template.FieldByTitle(ukCAFSupplyProvisionalAccounts).Value := 'Yes';
  end;

  if CompareText(Trim(Source.Frequency), 'M') = 0 then
  begin
    Template.FieldByTitle(ukCAFMonthly).Value := 'Yes';
  end
  else
  if CompareText(Trim(Source.Frequency), 'W') = 0 then
  begin
    Template.FieldByTitle(ukCAFWeekly).Value := 'Yes';
  end
  else
  begin
    Template.FieldByTitle(ukCAFDaily).Value := 'Yes';
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

procedure TStandardCAFImporterUK.DoFieldValidation(Source: TCAFSource);
begin
  if Source.FieldCount < 11 then
  begin
    AddError('Fields', 'The file does not contain enough fields'); 
  end;
end;

procedure TStandardCAFImporterUK.DoRecordValidation(Source: TCAFSource);
begin
  if (Trim(Source.AccountName) = '') and (Trim(Source.SortCode) = '') and (Trim(Source.AccountNo) = '') then
  begin
    AddImportError(Source, 'You must enter the name of the account or the sort code or the account number.');
  end;

  if ContainsSymbols(Trim(Source.ClientCode)) then
  begin
    AddImportError(Source, 'The client code can only contain alpha numeric characters.');
  end;

  if ContainsSymbols(Trim(Source.CostCode)) then
  begin
    AddImportError(Source, 'The cost code can only contain alpha numeric characters.');
  end;

  if (Trim(Source.Month) = '') and (Trim(Source.Year) <> '') then
  begin
    AddImportError(Source, 'You must choose a starting month.');
  end
  else
  if CompareText(Source.Month, 'ASAP') <> 0 then
  begin
    if not IsLongMonthName(Trim(Source.Month)) then
    begin
      AddImportError(Source, 'You must enter a valid starting month.');
    end;
  end;

  if (Trim(Source.Year) = '') then
  begin
    if (CompareText(Source.Month, 'ASAP') <> 0) then
    begin
      AddImportError(Source, 'You must enter a valid starting year.');
    end;
  end
  else
  begin
    if Length(Trim(Source.Year)) = 2 then
    begin
      if not IsNumber(Source.Year) then
      begin
        AddImportError(Source, 'You must enter a valid starting year.');
      end;
    end
    else
    begin
      AddImportError(Source, 'You must enter a valid starting year.');
    end;
  end;
end;

function TStandardCAFImporterUK.GetPDFTemplateFile: String;
begin
  Result := istUKTemplateFileNames[istUKNormal];
end;

{ TStandardCAFSourceHelperUK }

function TStandardCAFSourceHelperUK.GetAccountName: String;
begin
  Result := ValueByIndex(0);
end;

function TStandardCAFSourceHelperUK.GetAccountNo: String;
begin
  Result := ValueByIndex(2);
end;

function TStandardCAFSourceHelperUK.GetBank: String;
begin
  Result := ValueByIndex(7);
end;

function TStandardCAFSourceHelperUK.GetBranch: String;
begin
  Result := ValueByIndex(8);
end;

function TStandardCAFSourceHelperUK.GetClientCode: String;
begin
  Result := ValueByIndex(5);
end;

function TStandardCAFSourceHelperUK.GetCostCode: String;
begin
  Result := ValueByIndex(6);
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
  Result := ValueByIndex(1);
end;

function TStandardCAFSourceHelperUK.GetYear: String;
begin
  Result := ValueByIndex(10);
end;

{ TPDFEditorHelper }

function TPDFEditorHelper.FieldByTitle(const FieldTitle: String): TPDFFormFieldItem;
begin
  Result := PDFFormFields.GetFieldByTitle(FieldTitle);

  if Result = nil then
  begin
    raise Exception.Create(Format('Field %s not found', [FieldTitle])); 
  end;
end;

end.
