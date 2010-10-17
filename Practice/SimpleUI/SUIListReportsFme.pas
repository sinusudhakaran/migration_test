unit SUIListReportsFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIListReportsPage = class(TFrame)
    gpnlButtonHolder: TGridPanel;
    gbtnListBank: tbkExGlassButton;
    imgTick: TImage;
    gbtnListChart: tbkExGlassButton;
    gbtnListPayee: tbkExGlassButton;
    gbtnListJobs: tbkExGlassButton;
    gbtnListJournals: tbkExGlassButton;
    gbtnListMems: tbkExGlassButton;
    gbtnListMissingCheques: tbkExGlassButton;
    gbtnListEntries: tbkExGlassButton;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender : TObject; var Key : Char);
    procedure gbtnListBankClick(Sender: TObject);
    procedure gbtnListChartClick(Sender: TObject);
    procedure gbtnListPayeeClick(Sender: TObject);
    procedure gbtnListJobsClick(Sender: TObject);
    procedure gbtnListJournalsClick(Sender: TObject);
    procedure gbtnListMemsClick(Sender: TObject);
    procedure gbtnListMissingChequesClick(Sender: TObject);
    procedure gbtnListEntriesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent) ; override;
  end;

implementation
uses
  SimpleUIHomepageFrm, SUIFrameHelper;

{$R *.dfm}


constructor TfmeSUIListReportsPage.Create(AOwner: TComponent);
begin
  inherited;

  SUIFrameHelper.InitButtonsOnGridPanel(gpnlButtonHolder, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
end;

procedure TfmeSUIListReportsPage.gbtnListMissingChequesClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcListMissingCheques);
end;

procedure TfmeSUIListReportsPage.gbtnListJournalsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcListJournals);
end;

procedure TfmeSUIListReportsPage.gbtnListMemsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcListMissingCheques);
end;

procedure TfmeSUIListReportsPage.gbtnListPayeeClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcListPayees);
end;

procedure TfmeSUIListReportsPage.gbtnListChartClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcListChart);
end;

procedure TfmeSUIListReportsPage.gbtnListBankClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcListBankAccounts);
end;

procedure TfmeSUIListReportsPage.gbtnListEntriesClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcListEntries);
end;

procedure TfmeSUIListReportsPage.gbtnListJobsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcListJobs);
end;

procedure TfmeSUIListReportsPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMoreReportsPage);
   end;
end;

procedure TfmeSUIListReportsPage.CommonButtonKeyUp(Sender: TObject;
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

   {if Key = VK_ESCAPE then
   begin
     Key := 0;
     //go back to parent page
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMoreReportsPage);
   end;}
end;

end.
