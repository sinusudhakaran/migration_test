unit HSBCCAFImporterUK;

interface

uses
  Windows, SysUtils, CAFImporter, PDFFieldEditor, StandardCAFImporterUK;

type
  THSBCCAFSourceHelperUK = class helper(TStandardCAFSourceHelperUK) for TCAFSource
  strict private
    function GetAddressLine1: String;
    function GetAddressLine2: String;
    function GetAddressLine3: String;
    function GetAddressLine4: String;
    function GetPostCode: String;
    function GetAccountSignatory1: String;
    function GetAccountSignatory2: String;
  public
    property AccountSignatory1: String read GetAccountSignatory1;
    property AccountSignatory2: String read GetAccountSignatory2;
    property AddressLine1: String read GetAddressLine1;
    property AddressLine2: String read GetAddressLine2;
    property AddressLine3: String read GetAddressLine3;
    property AddressLine4: String read GetAddressLine4;
    property PostCode: String read GetPostCode;
  end;

  THSBCCAFImporterUK = class(TStandardCAFImporterUK)
  protected
    procedure DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String); override;
    function GetPDFTemplateFile: String; override;
    function GetMinFieldCount: Integer; override;
    function GetImporterName: String; override;
    function GetOutputFileBase: string; override;
    
    class procedure SetupLinkedFields(Template: TPdfFieldEdit); static;
  end;

implementation

uses
  BKConst, StrUtils, bkTemplates;
  
procedure THSBCCAFImporterUK.DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String);
begin
  SetupLinkedFields(Template);

  inherited;

  Template.SetFieldValue(ukCAFBankName, 'HSBC');

  Template.SetFieldValue(ukCAFHSBCAccountSign1, Uppercase(Source.AccountSignatory1));
  Template.SetFieldValue(ukCAFHSBCAccountSign2, Uppercase(Source.AccountSignatory2));

  Template.SetFieldValue(ukCAFHSBCAddressLine1, Source.AddressLine1);
  Template.SetFieldValue(ukCAFHSBCAddressLine2, Source.AddressLine2);
  Template.SetFieldValue(ukCAFHSBCAddressLine3, Source.AddressLine3);
  Template.SetFieldValue(ukCAFHSBCAddressLine4, Source.AddressLine4);

  Template.SetFieldValue(ukCAFHSBCPostalCode, Source.PostCode);

  // Note:
  // The OutputFile is determined in StandardCAFImportedUK
  // (Also see GetOutputFileBase below)
end;

function THSBCCAFImporterUK.GetImporterName: String;
begin
  Result := 'HSBC UK';
end;

function THSBCCAFImporterUK.GetMinFieldCount: Integer;
begin
  Result := 18;
end;

function THSBCCAFImporterUK.GetPDFTemplateFile: String;
begin
  Result := TTemplates.UKCafTemplates[istUKHSBC];
end;

function THSBCCAFImporterUK.GetOutputFileBase: string;
begin
  Result := 'HSBC Customer Authority Form';
end;

class procedure THSBCCAFImporterUK.SetupLinkedFields(Template: TPdfFieldEdit);
begin
  Template.LinkFieldByTitle(ukCAFNameOfAccount, ukCAFNameOfAccount2);
  Template.LinkFieldByTitle(ukCAFNameOfAccount, ukCAFNameOfAccount3);
  Template.LinkFieldByTitle(ukCAFNameOfAccount, ukCAFNameOfAccount4);
  Template.LinkFieldByTitle(ukCAFNameOfAccount, ukCAFNameOfAccount5);

  Template.LinkFieldByTitle(ukCAFClientCode, ukCAFClientCode2);
  
  Template.LinkFieldByTitle(ukCAFBankCode, ukCAFBankCode2);
  Template.LinkFieldByTitle(ukCAFBankCode, ukCAFBankCode3);
  
  Template.LinkFieldByTitle(ukCAFAccountNumber, ukCAFAccountNumber2);
  Template.LinkFieldByTitle(ukCAFAccountNumber, ukCAFAccountNumber3);

  Template.LinkFieldByTitle(ukCAFCostCode, ukCAFCostCode2);
  
  Template.LinkFieldByTitle(ukCAFBankName, ukCAFBankName2);

  Template.LinkFieldByTitle(ukCAFBranchName, ukCAFBranchName2);
  Template.LinkFieldByTitle(ukCAFBranchName, ukCAFBranchName3);

  Template.LinkFieldByTitle(ukCAFStartMonth, ukCAFStartMonth2);
  
  Template.LinkFieldByTitle(ukCAFStartYear, ukCAFStartYear2);

  Template.LinkFieldByTitle(ukCAFPracticeName, ukCAFPracticeName2);
  
  Template.LinkFieldByTitle(ukCAFPracticeCode, ukCAFPracticeCode2);

  Template.LinkFieldByTitle(ukCAFSupplyProvisionalAccounts, ukCAFSupplyProvisionalAccounts2);

  Template.LinkFieldByTitle(ukCAFMonthly, ukCAFMonthly2);


  Template.LinkFieldByTitle(ukCAFWeekly, ukCAFWeekly2);

  Template.LinkFieldByTitle(ukCAFDaily, ukCAFDaily2);

  Template.LinkFieldByTitle(ukCAFHSBCAccountSign1, ukCAFHSBCAccountSign1_2);
  Template.LinkFieldByTitle(ukCAFHSBCAccountSign1, ukCAFHSBCAccountSign1_3);
  
  Template.LinkFieldByTitle(ukCAFHSBCAccountSign2, ukCAFHSBCAccountSign2_2);
  Template.LinkFieldByTitle(ukCAFHSBCAccountSign2, ukCAFHSBCAccountSign2_3);

  Template.LinkFieldByTitle(ukCAFHSBCAddressLine1, ukCAFHSBCAddressLine1_2);
  Template.LinkFieldByTitle(ukCAFHSBCAddressLine2, ukCAFHSBCAddressLine2_2);
  Template.LinkFieldByTitle(ukCAFHSBCAddressLine3, ukCAFHSBCAddressLine3_2);
  Template.LinkFieldByTitle(ukCAFHSBCAddressLine4, ukCAFHSBCAddressLine4_2);

  Template.LinkFieldByTitle(ukCAFHSBCPostalCode, ukCAFHSBCPostalCode2);
end;

{ TCAFSourceHelper }
function THSBCCAFSourceHelperUK.GetAccountSignatory1: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfAccSig1)), 60);
end;

function THSBCCAFSourceHelperUK.GetAccountSignatory2: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfAccSig2)), 60);
end;

function THSBCCAFSourceHelperUK.GetAddressLine1: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfAddrLine1)), 60);
end;

function THSBCCAFSourceHelperUK.GetAddressLine2: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfAddrLine2)), 60);
end;

function THSBCCAFSourceHelperUK.GetAddressLine3: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfAddrLine3)), 60);
end;

function THSBCCAFSourceHelperUK.GetAddressLine4: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfAddrLine4)), 60);
end;

function THSBCCAFSourceHelperUK.GetPostCode: String;
begin
  Result := LeftStr(ValueByIndex(ord(ucfPostCode)), 8);
end;

end.
