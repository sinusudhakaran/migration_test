unit SUIFileOptionsFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeFileOptionsPage = class(TFrame)
    gpnlButtonHolder: TGridPanel;
    gbtnFileDetails: tbkExGlassButton;
    gbtnOpen: tbkExGlassButton;
    gbtnCheckIn: tbkExGlassButton;
    gbtnCheckOut: tbkExGlassButton;
    imgTick: TImage;
    gbtnSaveAs: tbkExGlassButton;
    gbtnAbandonChanges: tbkExGlassButton;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender : TObject; var Key : Char);
    procedure gbtnFileDetailsClick(Sender: TObject);
    procedure gbtnOpenClick(Sender: TObject);
    procedure gbtnCheckInClick(Sender: TObject);
    procedure gbtnCheckOutClick(Sender: TObject);
    procedure gbtnSaveAsClick(Sender: TObject);
    procedure gbtnAbandonChangesClick(Sender: TObject);
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


constructor TfmeFileOptionsPage.Create(AOwner: TComponent);
begin
  inherited;

  SUIFrameHelper.InitButtonsOnGridPanel(gpnlButtonHolder, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
end;

procedure TfmeFileOptionsPage.gbtnAbandonChangesClick(Sender: TObject);
begin
SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcAbandon);
end;

procedure TfmeFileOptionsPage.gbtnCheckInClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcCheckIn);
end;

procedure TfmeFileOptionsPage.gbtnCheckOutClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcCheckOut);
end;

procedure TfmeFileOptionsPage.gbtnFileDetailsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcClientDetails);
end;

procedure TfmeFileOptionsPage.gbtnOpenClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcOpenFile);
end;

procedure TfmeFileOptionsPage.gbtnSaveAsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.DoSimpleUICommand( sui_mcSaveAs);
end;

procedure TfmeFileOptionsPage.CommonButtonKeyPress(Sender: TObject;
  var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiMorePage);
   end;
end;

procedure TfmeFileOptionsPage.CommonButtonKeyUp(Sender: TObject;
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
