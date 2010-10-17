unit SUICashflowReportsPageFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUICashflowReportsPage = class(TFrame)
    gpnlButtonHolder: TGridPanel;
    gbtnCFActual: tbkExGlassButton;
    imgTick: TImage;
    gbtnCFActualBudget: tbkExGlassButton;
    gbtnCFActBudVar: tbkExGlassButton;
    gbtnCFDateToDate: tbkExGlassButton;
    gbtnCF12Act: tbkExGlassButton;
    gbtnCF12Bud: tbkExGlassButton;
    gbtnCF12ActBud: tbkExGlassButton;
    gbtnCFBudRem: tbkExGlassButton;
    gbtnCFThisYear: tbkExGlassButton;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender : TObject; var Key : Char);
    procedure gbtnCFActualClick(Sender: TObject);
    procedure gbtnCFActualBudgetClick(Sender: TObject);
    procedure gbtnCFActBudVarClick(Sender: TObject);
    procedure gbtnCFDateToDateClick(Sender: TObject);
    procedure gbtnCF12ActClick(Sender: TObject);
    procedure gbtnCF12BudClick(Sender: TObject);
    procedure gbtnCF12ActBudClick(Sender: TObject);
    procedure gbtnCFBudRemClick(Sender: TObject);
    procedure gbtnCFThisYearClick(Sender: TObject);
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


constructor TfmeSUICashflowReportsPage.Create(AOwner: TComponent);
begin
  inherited;
  SUIFrameHelper.InitButtonsOnGridPanel(gpnlButtonHolder, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
end;

procedure TfmeSUICashflowReportsPage.gbtnCF12ActBudClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCF12AB);
end;

procedure TfmeSUICashflowReportsPage.gbtnCF12ActClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCF12A);
end;

procedure TfmeSUICashflowReportsPage.gbtnCF12BudClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCF12B);
end;

procedure TfmeSUICashflowReportsPage.gbtnCFActBudVarClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCFABV);
end;

procedure TfmeSUICashflowReportsPage.gbtnCFActualBudgetClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCFAB);
end;

procedure TfmeSUICashflowReportsPage.gbtnCFActualClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCFA);
end;

procedure TfmeSUICashflowReportsPage.gbtnCFBudRemClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCFBudRem);
end;

procedure TfmeSUICashflowReportsPage.gbtnCFDateToDateClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCFDateToDate);
end;

procedure TfmeSUICashflowReportsPage.gbtnCFThisYearClick(Sender: TObject);
begin
   SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcThisYearLastYear);
end;

procedure TfmeSUICashflowReportsPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMoreReportsPage);
   end;
end;

procedure TfmeSUICashflowReportsPage.CommonButtonKeyUp(Sender: TObject;
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
