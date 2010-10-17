unit SUIBankRecReportsFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIBankRecReportsPage = class(TFrame)
    pnlButtonHolder: TGridPanel;
    gbtnBankRecSummary: tbkExGlassButton;
    gbtnBankRecDet: tbkExGlassButton;
    imgTick: TImage;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender: TObject; var Key: Char);
    procedure gbtnBankRecDetClick(Sender: TObject);
    procedure gbtnBankRecSummaryClick(Sender: TObject);
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


constructor TfmeSUIBankRecReportsPage.Create(AOwner: TComponent);
begin
  inherited;

  SUIFrameHelper.InitButtonsOnGridPanel(pnlButtonHolder, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
end;

procedure TfmeSUIBankRecReportsPage.gbtnBankRecDetClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcBankRecDet);
end;

procedure TfmeSUIBankRecReportsPage.gbtnBankRecSummaryClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcBankRecSum);
end;

procedure TfmeSUIBankRecReportsPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMoreReportsPage);
   end;
end;

procedure TfmeSUIBankRecReportsPage.CommonButtonKeyUp(Sender: TObject;
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
