unit BGLForeignTaxFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ovcbase, ovcef, ovcpb, ovcnf, StdCtrls;

type
  TfmeBGLForeignTax = class(TFrame)
    lblForeignIncomeTaxOffset: TLabel;
    nfForeignIncomeTaxOffset: TOvcNumericField;
    lpForeignIncomeTaxOffset: TLabel;
    lblAUFrankingCreditsFromNZCompany: TLabel;
    nfAUFrankingCreditsFromNZCompany: TOvcNumericField;
    lpAUFrankingCreditsFromNZCompany: TLabel;
    lblTFNAmountsWithheld: TLabel;
    nfTFNAmountsWithheld: TOvcNumericField;
    lpTFNAmountsWithheld: TLabel;
    lblNonResidentWithholdingTax: TLabel;
    nfNonResidentWithholdingTax: TOvcNumericField;
    lpNonResidentWithholdingTax: TLabel;
    lblLICDeductions: TLabel;
    nfLICDeductions: TOvcNumericField;
    lpLICDeductions: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
