unit SUIProfitReportsPageFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIProfitReportsPage = class(TFrame)
    pnlButtonHolder: TGridPanel;
    gbtnPLActual: tbkExGlassButton;
    gbtnPLActBud: tbkExGlassButton;
    gbtnPLActBudVar: tbkExGlassButton;
    gbtnPL12Act: tbkExGlassButton;
    imgTick: TImage;
    gbtnPL12Bud: tbkExGlassButton;
    gbtnPL12ActBud: tbkExGlassButton;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender : TObject; var Key : Char);
    procedure gbtnPLActBudClick(Sender: TObject);
    procedure gbtnPLActualClick(Sender: TObject);
    procedure gbtnPLActBudVarClick(Sender: TObject);
    procedure gbtnPL12ActClick(Sender: TObject);
    procedure gbtnPL12BudClick(Sender: TObject);
    procedure gbtnPL12ActBudClick(Sender: TObject);
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


constructor TfmeSUIProfitReportsPage.Create(AOwner: TComponent);
begin
  inherited;

  SUIFrameHelper.InitButtonsOnGridPanel(pnlButtonHolder, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
end;

procedure TfmeSUIProfitReportsPage.gbtnPL12ActBudClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcPL12AB);
end;

procedure TfmeSUIProfitReportsPage.gbtnPL12ActClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcPL12A);
end;

procedure TfmeSUIProfitReportsPage.gbtnPL12BudClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcPL12B);
end;

procedure TfmeSUIProfitReportsPage.gbtnPLActBudClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcPLAB);
end;

procedure TfmeSUIProfitReportsPage.gbtnPLActBudVarClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcPLABV);
end;

procedure TfmeSUIProfitReportsPage.gbtnPLActualClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcPLA);
end;

procedure TfmeSUIProfitReportsPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMoreReportsPage);
   end;
end;

procedure TfmeSUIProfitReportsPage.CommonButtonKeyUp(Sender: TObject;
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
