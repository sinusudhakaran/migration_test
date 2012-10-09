unit SUIMoreReportsPageFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIMoreReportsPage = class(TFrame)
    gpnlButtonHolder: TGridPanel;
    gbtnCoding: tbkExGlassButton;
    imgTick: TImage;
    gbtnLedger: tbkExGlassButton;
    gbtnPayee: tbkExGlassButton;
    gbtnJobs: tbkExGlassButton;
    gbtnCashflow: tbkExGlassButton;
    gbtnPL: tbkExGlassButton;
    gbtnTrialBalance: tbkExGlassButton;
    gbtnGST: tbkExGlassButton;
    gbtnLists: tbkExGlassButton;
    gbtnBankRec: tbkExGlassButton;
    gbtnGraphs: tbkExGlassButton;
    gbtnTaxablePayements: tbkExGlassButton;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender : TObject; var Key : Char);
    procedure gbtnCashflowClick(Sender: TObject);
    procedure gbtnPLClick(Sender: TObject);
    procedure gbtnGSTClick(Sender: TObject);
    procedure gbtnListsClick(Sender: TObject);
    procedure gbtnBankRecClick(Sender: TObject);
    procedure gbtnCodingClick(Sender: TObject);
    procedure gbtnLedgerClick(Sender: TObject);
    procedure gbtnPayeeClick(Sender: TObject);
    procedure gbtnJobsClick(Sender: TObject);
    procedure gbtnGraphsClick(Sender: TObject);
    procedure gbtnTrialBalanceClick(Sender: TObject);
    procedure gbtnTaxablePayementsClick(Sender: TObject);
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


constructor TfmeSUIMoreReportsPage.Create(AOwner: TComponent);
begin
  inherited;

  gbtnTaxablePayements.Visible := False;
  
  if Assigned(MyClient) then
  begin
    if MyClient.clFields.clCountry = whAustralia then
    begin
      gbtnTaxablePayements.Visible := True;
    end;
  end;

  SUIFrameHelper.InitButtonsOnGridPanel(gpnlButtonHolder, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
  
  SUIFrameHelper.ArrangeButtonsOnGridPanel(gpnlButtonHolder);
end;

procedure TfmeSUIMoreReportsPage.gbtnBankRecClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiBankRecReportsPage);
end;

procedure TfmeSUIMoreReportsPage.gbtnCashflowClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiCashflowReportsPage);
end;

procedure TfmeSUIMoreReportsPage.gbtnCodingClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcCodingReport);
end;

procedure TfmeSUIMoreReportsPage.gbtnGraphsClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcGraphsR);
end;

procedure TfmeSUIMoreReportsPage.gbtnGSTClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiGSTReportsPage);
end;

procedure TfmeSUIMoreReportsPage.gbtnJobsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcJobsReport);
end;

procedure TfmeSUIMoreReportsPage.gbtnLedgerClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcLedgerReport);
end;

procedure TfmeSUIMoreReportsPage.gbtnListsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiListReportsPage);
end;

procedure TfmeSUIMoreReportsPage.gbtnPayeeClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcPayeeReport);
end;

procedure TfmeSUIMoreReportsPage.gbtnPLClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiProfitReportsPage);
end;

procedure TfmeSUIMoreReportsPage.gbtnTaxablePayementsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcTaxablePayments);
end;

procedure TfmeSUIMoreReportsPage.gbtnTrialBalanceClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcTrialBalanceReport);
end;

procedure TfmeSUIMoreReportsPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMorepage);
   end;
end;

procedure TfmeSUIMoreReportsPage.CommonButtonKeyUp(Sender: TObject;
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
