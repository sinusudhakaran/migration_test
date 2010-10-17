unit SUIGSTReportsPageFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIGSTReportsPage = class(TFrame)
    pnlButtonHolder: TGridPanel;
    gbtnGSTReturn: tbkExGlassButton;
    gbtnGSTAudit: tbkExGlassButton;
    gbtnGSTSummary: tbkExGlassButton;
    gbtnGSTdetails: tbkExGlassButton;
    imgTick: TImage;
    gbtnAnnualReturn: tbkExGlassButton;
    gbtnGSTAnnualReport: tbkExGlassButton;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender : TObject; var Key : Char);
    procedure gbtnGSTAuditClick(Sender: TObject);
    procedure gbtnGSTReturnClick(Sender: TObject);
    procedure gbtnGSTSummaryClick(Sender: TObject);
    procedure gbtnGSTdetailsClick(Sender: TObject);
    procedure gbtnAnnualReturnClick(Sender: TObject);
    procedure gbtnGSTAnnualReportClick(Sender: TObject);
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


constructor TfmeSUIGSTReportsPage.Create(AOwner: TComponent);
begin
  inherited;

  SUIFrameHelper.InitButtonsOnGridPanel(pnlButtonHolder, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);

  //set label on GST button
  gbtnGSTReturn.ButtonCaption := 'GST return';
  gbtnAnnualReturn.Visible := false;
  gbtnGSTAnnualReport.Visible := false;

  if Assigned( Globals.MyClient) then
  begin
    case MyClient.clFields.clCountry of
       whAustralia  : begin
          gbtnGSTReturn.ButtonCaption :=  'Business/ instalment activity statement';
          gbtnAnnualReturn.Visible := true;
          gbtnGSTAnnualReport.Visible := true;
       end;
       whUK : gbtnGSTReturn.ButtonCaption := 'VAT return';
    end;
  end;
end;

procedure TfmeSUIGSTReportsPage.gbtnAnnualReturnClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGSTAnnualReturnAU);
end;

procedure TfmeSUIGSTReportsPage.gbtnGSTAnnualReportClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGSTAnnualReportAU);
end;

procedure TfmeSUIGSTReportsPage.gbtnGSTAuditClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGSTAuditR);
end;

procedure TfmeSUIGSTReportsPage.gbtnGSTdetailsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGSTDetailsR);
end;

procedure TfmeSUIGSTReportsPage.gbtnGSTReturnClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGSTReturnR);
end;

procedure TfmeSUIGSTReportsPage.gbtnGSTSummaryClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGSTSummaryR);
end;

procedure TfmeSUIGSTReportsPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMoreReportsPage);
   end;
end;

procedure TfmeSUIGSTReportsPage.CommonButtonKeyUp(Sender: TObject;
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
