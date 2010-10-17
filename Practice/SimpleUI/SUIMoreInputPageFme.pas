unit SUIMoreInputPageFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIMoreInputPage = class(TFrame)
    GridPanel1: TGridPanel;
    gbtnCodeStatements: tbkExGlassButton;
    gbtnEnterJnls: tbkExGlassButton;
    gbtnBudgets: tbkExGlassButton;
    gBtnOpeningBal: tbkExGlassButton;
    imgTick: TImage;
    gbtnBankAccounts: tbkExGlassButton;
    gbtnMDE: tbkExGlassButton;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender : TObject; var Key : Char);
    procedure gbtnEnterJnlsClick(Sender: TObject);
    procedure gbtnCodeStatementsClick(Sender: TObject);
    procedure gbtnBudgetsClick(Sender: TObject);
    procedure gBtnOpeningBalClick(Sender: TObject);
    procedure gbtnBankAccountsClick(Sender: TObject);
    procedure gbtnMDEClick(Sender: TObject);
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


constructor TfmeSUIMoreInputPage.Create(AOwner: TComponent);
begin
  inherited;

  SUIFrameHelper.InitButtonsOnGridPanel(GridPanel1, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
end;

procedure TfmeSUIMoreInputPage.gbtnBankAccountsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcMaintainBankAccounts);
end;

procedure TfmeSUIMoreInputPage.gbtnBudgetsClick(Sender: TObject);
begin
SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcBudgets);
end;

procedure TfmeSUIMoreInputPage.gbtnCodeStatementsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand(sui_mcCoding);
end;

procedure TfmeSUIMoreInputPage.gbtnEnterJnlsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiJournalsPage);
end;

procedure TfmeSUIMoreInputPage.gbtnMDEClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcMDE);
end;

procedure TfmeSUIMoreInputPage.gBtnOpeningBalClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcOpeningBalances);
end;

procedure TfmeSUIMoreInputPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMorepage);
   end;
end;

procedure TfmeSUIMoreInputPage.CommonButtonKeyUp(Sender: TObject;
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
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMorePage);
   end; }
end;

end.
