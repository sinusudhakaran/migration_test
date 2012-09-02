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
  private
    FCAFCount: Integer;
    FMultiImport: Boolean;
  protected
    procedure DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String); override;
    procedure DoFieldValidation(Source: TCAFSource); override;
    function GetPDFTemplateFile: String; override;
  end;

implementation

uses
  BKConst;
  
procedure THSBCCAFImporterUK.DoImportAsPDF(Source: TCAFSource; Template: TPdfFieldEdit; out OutputFile: String);
begin
  inherited;
  
  Template.FieldByTitle(ukCAFHSBCAccountSign1).Value := Source.AccountSignatory1;
  Template.FieldByTitle(ukCAFHSBCAccountSign2).Value := Source.AccountSignatory2;                  
                  
  Template.FieldByTitle(ukCAFHSBCAddressLine1).Value := Source.AddressLine1;
  Template.FieldByTitle(ukCAFHSBCAddressLine2).Value := Source.AddressLine2;
  Template.FieldByTitle(ukCAFHSBCAddressLine3).Value := Source.AddressLine3;
  Template.FieldByTitle(ukCAFHSBCAddressLine4).Value := Source.AddressLine4;
                         
  Template.FieldByTitle(ukCAFHSBCPostalCode).Value := Source.PostCode;

  if MultiImport then
  begin
    OutputFile := Format('Customer Authority Form%s%s.PDF', [Source.ClientCode, IntToStr(CAFCount + 1)]);
  end;
end;

function THSBCCAFImporterUK.GetPDFTemplateFile: String;
begin
  Result := istUKTemplateFileNames[istUKHSBC];
end;

procedure THSBCCAFImporterUK.DoFieldValidation(Source: TCAFSource);
begin
  if Source.FieldCount < 18 then
  begin
    AddError('Fields', 'The file does not contain enough fields'); 
  end;
end;

{ TCAFSourceHelper }

function THSBCCAFSourceHelperUK.GetAccountSignatory1: String;
begin
  Result := ValueByIndex(3);
end;

function THSBCCAFSourceHelperUK.GetAccountSignatory2: String;
begin
  Result := ValueByIndex(4);
end;

function THSBCCAFSourceHelperUK.GetAddressLine1: String;
begin
  Result := ValueByIndex(13);
end;

function THSBCCAFSourceHelperUK.GetAddressLine2: String;
begin
  Result := ValueByIndex(14);
end;

function THSBCCAFSourceHelperUK.GetAddressLine3: String;
begin
  Result := ValueByIndex(15);
end;

function THSBCCAFSourceHelperUK.GetAddressLine4: String;
begin
  Result := ValueByIndex(16);
end;

function THSBCCAFSourceHelperUK.GetPostCode: String;
begin
  Result := ValueByIndex(17);
end;

end.
