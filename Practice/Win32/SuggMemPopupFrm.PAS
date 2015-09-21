unit SuggMemPopupFrm;

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
  TeCanvas,
  RzButton,
  StdCtrls,
  ovcbase,
  ovcspeed,
  RzBmpBtn,
  ExtCtrls,
  osfont;

type
  //----------------------------------------------------------------------------
  TfrmSuggMemPopup = class(TForm)
    Image1: TImage;
    btnHide: TRzShapeButton;
    btnLater: TRzShapeButton;
    btnCreate: TRzShapeButton;
    lblLine1: TLabel;
    lblLine2: TLabel;
    lblLine3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnLaterClick(Sender: TObject);
    procedure btnCreateClick(Sender: TObject);
  private
    fOnHideClick   : TNotifyEvent;
    fOnLaterClick  : TNotifyEvent;
    fOnCreateClick : TNotifyEvent;
  public
    property OnHideClick   : TNotifyEvent read fOnHideClick write fOnHideClick;
    property OnLaterClick  : TNotifyEvent read fOnLaterClick write fOnLaterClick;
    property OnCreateClick : TNotifyEvent read fOnCreateClick write fOnCreateClick;
  end;

  //----------------------------------------------------------------------------
  function SuggMemPopup(aOwner: TCustomForm) : TfrmSuggMemPopup;
  procedure FreeSuggestedMemForm();

implementation
{$R *.dfm}

var
  frmSuggMemPopup: TfrmSuggMemPopup;

//------------------------------------------------------------------------------
function SuggMemPopup(aOwner: TCustomForm) : TfrmSuggMemPopup;
begin
  if not Assigned(frmSuggMemPopup) then
  begin
    frmSuggMemPopup := TfrmSuggMemPopup.create(aOwner);
    frmSuggMemPopup.Visible := false;
    frmSuggMemPopup.PopupParent := aOwner;
  end;

  Result := frmSuggMemPopup;
end;

//------------------------------------------------------------------------------
procedure FreeSuggestedMemForm();
begin
  FreeAndNil(frmSuggMemPopup);
end;

//------------------------------------------------------------------------------
{ TfrmSuggMemPopup }
procedure TfrmSuggMemPopup.btnHideClick(Sender: TObject);
begin
  if assigned(fOnHideClick) then
    fOnHideClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TfrmSuggMemPopup.btnLaterClick(Sender: TObject);
begin
  if assigned(fOnLaterClick) then
    fOnLaterClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TfrmSuggMemPopup.btnCreateClick(Sender: TObject);
begin
  if assigned(fOnCreateClick) then
    fOnCreateClick(Sender);
end;

//------------------------------------------------------------------------------
procedure TfrmSuggMemPopup.FormCreate(Sender: TObject);
begin
  SystemParametersInfo(SPI_SETDRAGFULLWINDOWS, 0, nil, 0); {Disable drag showing}
end;

//------------------------------------------------------------------------------
initialization
begin
  frmSuggMemPopup := nil;
end;

//------------------------------------------------------------------------------
finalization
begin
  //FreeAndNil(frmSuggMemPopup);
end;

end.

