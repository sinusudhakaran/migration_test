unit SelectInstitutionfrm;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls;

type
  TfrmSelectInstitution = class(TForm)
    Label1: TLabel;
    cmbInstitution: TComboBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnCancelClick(Sender: TObject);
    procedure cmbInstitutionChange(Sender: TObject);
  private
    fSelectedInstitution : integer;
  protected
    procedure FillInstCombo;
  public
    function Execute : integer;

    property SelectedInstitution : integer read fSelectedInstitution write fSelectedInstitution;
  end;

  function PickCAFInstitution(w_PopupParent: Forms.TForm; aCountry : integer) : integer;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  bkConst;

//------------------------------------------------------------------------------
function PickCAFInstitution(w_PopupParent: Forms.TForm; aCountry : integer) : integer;
var
  frmSelectInstitution: TfrmSelectInstitution;
begin
  if not aCountry = whUK then
    Exit;

  frmSelectInstitution := TfrmSelectInstitution.Create(Application);
  try
    //Required for the proper handling of the window z-order so that a modal window does not show-up behind another window
    frmSelectInstitution.PopupParent := w_PopupParent;
    frmSelectInstitution.PopupMode := pmExplicit;
    //BKHelpSetUp(ClientDetails, BKH_Editing_client_details);

    Result := frmSelectInstitution.Execute;
  finally
    FreeAndNil(frmSelectInstitution);
  end;
end;

//------------------------------------------------------------------------------
function TfrmSelectInstitution.Execute: integer;
begin
  FillInstCombo;

  ShowModal;

  Result := SelectedInstitution;
end;

//------------------------------------------------------------------------------
procedure TfrmSelectInstitution.FillInstCombo;
var
  InstIndex : integer;
begin
  cmbInstitution.Clear;

  // First element is for none so don't show
  for InstIndex := 1 to istMax do
    cmbInstitution.AddItem(istUKNames[InstIndex], nil);

  cmbInstitution.ItemIndex := 0;
  SelectedInstitution := istUKNormal;
end;

//------------------------------------------------------------------------------
procedure TfrmSelectInstitution.cmbInstitutionChange(Sender: TObject);
begin
  SelectedInstitution := cmbInstitution.ItemIndex+1;
end;

//------------------------------------------------------------------------------
procedure TfrmSelectInstitution.btnCancelClick(Sender: TObject);
begin
  SelectedInstitution := istUKNone;
  ModalResult := mrCancel;
end;

//------------------------------------------------------------------------------
procedure TfrmSelectInstitution.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    //VK_RETURN:
    //  btnOK.Click;
    VK_ESCAPE:
      btnCancel.Click;
  end;
end;

end.
