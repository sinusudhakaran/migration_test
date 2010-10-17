unit SUIStdReportsFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIStdReports = class(TFrame)
    GridPanel1: TGridPanel;
    gbtnBankRec: tbkExGlassButton;
    gbtnCashflow: tbkExGlassButton;
    gbtnPL: tbkExGlassButton;
    gbtnGSTReport: tbkExGlassButton;
    imgTick: TImage;
    gbtnGSTAudit: tbkExGlassButton;
    gbtnGraph: tbkExGlassButton;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender: TObject; var Key : Char);
    procedure gbtnBankRecClick(Sender: TObject);
    procedure gbtnCashflowClick(Sender: TObject);
    procedure gbtnPLClick(Sender: TObject);
    procedure gbtnGSTReportClick(Sender: TObject);
    procedure gbtnGSTAuditClick(Sender: TObject);
    procedure gbtnGraphClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent) ; override;
  end;

implementation
uses
  SimpleUIHomepageFrm, SUIFrameHelper, Globals, bkConst;

{$R *.dfm}


constructor TfmeSUIStdReports.Create(AOwner: TComponent);
begin
  inherited;
  SUIFrameHelper.InitButtonsOnGridPanel(GridPanel1, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);

  gbtnGSTReport.ButtonCaption := 'GST return';
  if Assigned( Globals.MyClient) then
  begin
    case MyClient.clFields.clCountry of
       whAustralia  : begin
          gbtnGSTReport.ButtonCaption :=  'Business/ instalment activity statement';
       end;
       whUK : gbtnGSTReport.ButtonCaption := 'VAT return';
    end;
  end;
end;

procedure TfmeSUIStdReports.gbtnBankRecClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcBankRecSummary_Cur);
end;

procedure TfmeSUIStdReports.gbtnCashflowClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcCashflowAct_Cur);
end;

procedure TfmeSUIStdReports.gbtnGraphClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGraphs_Cur);
end;

procedure TfmeSUIStdReports.gbtnGSTAuditClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGSTAuditreport_Cur);
end;

procedure TfmeSUIStdReports.gbtnGSTReportClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGSTReturn_Cur);
end;

procedure TfmeSUIStdReports.gbtnPLClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcProfitAndLossAct_Cur);
end;

procedure TfmeSUIStdReports.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiHomePage);
   end;
end;

procedure TfmeSUIStdReports.CommonButtonKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
   if Key = VK_RIGHT then
   begin
     Key := 0;
     //force app to move to next items in tab order
     Self.SelectNext(TWinControl(Sender),true,true);
   end;

   if Key = VK_LEFT then
   begin
     Key := 0;
     //force app to move to next items in tab order
     Self.SelectNext(TWinControl(Sender),false,true);
   end;
end;

end.
