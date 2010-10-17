unit SUIAdvancedPageFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIAdvancedPage = class(TFrame)
    gpnlButtonHolder: TGridPanel;
    gbtnChart: tbkExGlassButton;
    imgTick: TImage;
    gbtnPayees: tbkExGlassButton;
    gbtnMems: tbkExGlassButton;
    gbtnJobs: tbkExGlassButton;
    gbtnHDE: tbkExGlassButton;
    gbtnEmailSupport: tbkExGlassButton;
    gbtnSystemSettings: tbkExGlassButton;
    gbtnChangePeriod: tbkExGlassButton;
    gbtnDivisions: tbkExGlassButton;
    gbtnConfigGST: tbkExGlassButton;
    gbtnEOY: tbkExGlassButton;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender: TObject; var Key: Char);
    procedure gbtnChartClick(Sender: TObject);
    procedure gbtnPayeesClick(Sender: TObject);
    procedure gbtnMemsClick(Sender: TObject);
    procedure gbtnJobsClick(Sender: TObject);
    procedure gbtnHDEClick(Sender: TObject);
    procedure gbtnConfigGSTClick(Sender: TObject);
    procedure gbtnSystemSettingsClick(Sender: TObject);
    procedure gbtnEmailSupportClick(Sender: TObject);
    procedure gbtnRestoreClick(Sender: TObject);
    procedure gbtnEOYClick(Sender: TObject);
    procedure gbtnChangePeriodClick(Sender: TObject);
    procedure gbtnDivisionsClick(Sender: TObject);
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


constructor TfmeSUIAdvancedPage.Create(AOwner: TComponent);
begin
  inherited;

  SUIFrameHelper.InitButtonsOnGridPanel(gpnlButtonHolder, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
end;

procedure TfmeSUIAdvancedPage.gbtnChartClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcMaintainChart);
end;

procedure TfmeSUIAdvancedPage.gbtnConfigGSTClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcGSTDetails);
end;

procedure TfmeSUIAdvancedPage.gbtnDivisionsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcMaintainDiv);
end;

procedure TfmeSUIAdvancedPage.gbtnEmailSupportClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcEmailSupport);
end;

procedure TfmeSUIAdvancedPage.gbtnEOYClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcYearEnd);
end;

procedure TfmeSUIAdvancedPage.gbtnHDEClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcHDE);
end;

procedure TfmeSUIAdvancedPage.gbtnJobsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcMaintainJob);
end;

procedure TfmeSUIAdvancedPage.gbtnMemsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcMaintainMems);
end;

procedure TfmeSUIAdvancedPage.gbtnPayeesClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcMaintainPayees);
end;

procedure TfmeSUIAdvancedPage.gbtnRestoreClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcOffsiteRestore);
end;

procedure TfmeSUIAdvancedPage.gbtnSystemSettingsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcSystemOptions);
end;

procedure TfmeSUIAdvancedPage.gbtnChangePeriodClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcChangePeriod);
end;

procedure TfmeSUIAdvancedPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMorePage);
   end;
end;

procedure TfmeSUIAdvancedPage.CommonButtonKeyUp(Sender: TObject;
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
