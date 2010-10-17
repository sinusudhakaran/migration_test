unit SUIJournalsFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIJournalsPage = class(TFrame)
    gpnlButtonHolder: TGridPanel;
    gbtnAddCash: tbkExGlassButton;
    gbtnAddAccrual: tbkExGlassButton;
    gbtnViewCash: tbkExGlassButton;
    gbtnViewAccrual: tbkExGlassButton;
    imgTick: TImage;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender : TObject; var Key : Char);
    procedure gbtnAddCashClick(Sender: TObject);
    procedure gbtnAddAccrualClick(Sender: TObject);
    procedure gbtnViewCashClick(Sender: TObject);
    procedure gbtnViewAccrualClick(Sender: TObject);
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


constructor TfmeSUIJournalsPage.Create(AOwner: TComponent);
begin
  inherited;

  SUIFrameHelper.InitButtonsOnGridPanel(gpnlButtonHolder, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
end;

procedure TfmeSUIJournalsPage.gbtnAddAccrualClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcAddAccrualJnl);
end;

procedure TfmeSUIJournalsPage.gbtnAddCashClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcAddCashJnl);
end;

procedure TfmeSUIJournalsPage.gbtnViewAccrualClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcViewAccrualJnl);
end;

procedure TfmeSUIJournalsPage.gbtnViewCashClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcViewCashJnl);
end;

procedure TfmeSUIJournalsPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMoreInputPage);
   end;
end;

procedure TfmeSUIJournalsPage.CommonButtonKeyUp(Sender: TObject;
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
