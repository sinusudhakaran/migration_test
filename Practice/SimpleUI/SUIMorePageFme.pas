unit SUIMorePageFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, AdvGlassButton, ExtCtrls, BkExGlassButton;

type
  TfmeSUIMorepage = class(TFrame)
    GridPanel1: TGridPanel;
    gbtnMoreInput: tbkExGlassButton;
    gbtnMoreReports: tbkExGlassButton;
    gbtnFileOptions: tbkExGlassButton;
    gbtnAdvanced: tbkExGlassButton;
    imgTick: TImage;
    procedure CommonButtonKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CommonButtonKeyPress(Sender : TObject; var Key : Char);
    procedure gbtnMoreInputClick(Sender: TObject);
    procedure gbtnMoreReportsClick(Sender: TObject);
    procedure gbtnAdvancedClick(Sender: TObject);
    procedure gbtnFileOptionsClick(Sender: TObject);
  private
    procedure CommonButtonPress(Sender: TObject; var Key: Char);
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent) ; override;
  end;

implementation
uses
  SimpleUIHomepageFrm, SUIFrameHelper;

{$R *.dfm}


constructor TfmeSUIMorepage.Create(AOwner: TComponent);
begin
  inherited;

  SUIFrameHelper.InitButtonsOnGridPanel(GridPanel1, CommonButtonKeyUp, CommonButtonKeyPress, ImgTick.Picture);
end;

procedure TfmeSUIMorepage.gbtnAdvancedClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiAdvancedPage);
end;

procedure TfmeSUIMorepage.gbtnFileOptionsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiFileOptionsPage);
end;

procedure TfmeSUIMorepage.gbtnMoreInputClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiMoreInputpage);
end;

procedure TfmeSUIMorepage.gbtnMoreReportsClick(Sender: TObject);
begin
  SimpleUIHomePageFrm.ChangeHomepageFrame( suiMoreReportsPage);
end;

procedure TfmeSUIMorepage.CommonButtonKeyPress(Sender: TObject; var Key: Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiHomepage);
   end;
end;

procedure TfmeSUIMorepage.CommonButtonKeyUp(Sender: TObject;
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

procedure TfmeSUIMorePage.CommonButtonPress( Sender : TObject; var Key : Char);
begin
   if (Key = #27) then  //if escape then move to parent page
   begin
     Key := #0;
     SimpleUIHomePageFrm.ChangeHomepageFrame( suiHomepage);
   end;
end;

end.
