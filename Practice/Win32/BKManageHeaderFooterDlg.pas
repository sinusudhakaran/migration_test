unit BKManageHeaderFooterDlg;

interface

uses
  classes,
  wpManHeadFoot;

type
  TWPManageHeaderFooterDlg = class(wpManHeadFoot.TWPManageHeaderFooterDlg)
  private
    FManHeadFoot: TWPManageHeaderFooter;
    procedure OnHeaderFooterPopup(Sender: TObject);
  public
    constructor Create(aOwner : TComponent);  override;
    destructor Destroy; override;
    function Execute: Boolean; override;
    procedure Close; override;
  end;





implementation

uses
   Forms,
   Menus,
   SysUtils;


procedure TWPManageHeaderFooterDlg.Close;
begin
  if FManHeadFoot <> nil then begin
    FManHeadFoot.Close;
    FreeAndNil(FManHeadFoot);
  end;
end;

constructor TWPManageHeaderFooterDlg.Create(aOwner: TComponent);
begin
  inherited Create(AOwner);

  FManHeadFoot := nil;
end;

destructor TWPManageHeaderFooterDlg.Destroy;
begin
  FreeAndNil(FManHeadFoot);
  inherited Destroy;
end;

function TWPManageHeaderFooterDlg.Execute: Boolean;
begin
  //Can control header footer dialog here
  if FManHeadFoot = nil then
    FManHeadFoot := TWPManageHeaderFooter.Create(Self);
  FManHeadFoot.Caption := 'Manage Headers and Footers';
  FManHeadFoot.WPRichText := EditBox;
  FManHeadFoot.PossibleRanges := PossibleRanges;
  FManHeadFoot.OptionsBut.Visible := False;
  FManHeadFoot.Position := poScreenCenter;
  FManHeadFoot.AddHeader.Caption := 'Add &Header';
  FManHeadFoot.AddFooter.Caption := 'Add &Footer';
  FManHeadFoot.GotoBody.Caption := 'Goto &Body';
  FManHeadFoot.CloseButton.Caption := '&Close';

  //Capitalise popup menu items
  FManHeadFoot.PopupMenu1.OnPopup := OnHeaderFooterPopup;

  FManHeadFoot.Show;
  if FCreateAndFreeDialog then
    FreeAndNil(FManHeadFoot)
  else
    FManHeadFoot.Show;
  Result := True;
end;

procedure TWPManageHeaderFooterDlg.OnHeaderFooterPopup(Sender: TObject);
  var
  i: integer;
  MenuItem: TMenuItem;
begin
  inherited;

  for i := 0 to FManHeadFoot.PopupMenu1.Items.Count - 1 do begin
    MenuItem := FManHeadFoot.PopupMenu1.Items[i];
    if MenuItem.Caption[1] in ['a'..'z'] then
      MenuItem.Caption := UpperCase(MenuItem.Caption[1]) +
                          Copy(MenuItem.Caption, 2, Length(MenuItem.Caption));
  end;
end;




end.
