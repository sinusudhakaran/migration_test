unit DeleteRequestfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcpf,
  OsFont, ExtCtrls;

type
  TfrmDeleteRequest = class(TForm)
    EAccounts: TMemo;
    Prequest: TPanel;
    Label1: TLabel;
    EDate: TOvcPictureField;
    pTop: TPanel;
    CheckBox: TCheckBox;
    pBottom: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    PRequestText: TPanel;
    lProcessed: TLabel;
    PDeleteText: TPanel;
    LDelete: TLabel;
    LDownload: TLabel;
    Image1: TImage;
    lCharges: TLabel;
    procedure EDateDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure EDateChange(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
  private
    FDoRequest: boolean;
    function Validate: Boolean;
    procedure SetDoRequest(const Value: boolean);
    procedure DoRebranding();
  public
    property DoRequest: boolean read FDoRequest write SetDoRequest;
  end;



implementation

{$R *.dfm}

uses
  Imagesfrm,
  bkdateutils,
  InfoMoreFrm,
  BKHelp,
  bkXPThemes,
  GenUtils,
  stDate,
  bkBranding,
  bkProduct,
  bkConst;


procedure TfrmDeleteRequest.btnOKClick(Sender: TObject);

begin
   if Validate then
      ModalResult := mrOK;
end;

procedure TfrmDeleteRequest.CheckBoxClick(Sender: TObject);
begin
   if FDoRequest then begin
       PDeleteText.Visible := CheckBox.Checked;
   end else begin
       pRequest.Visible := CheckBox.Checked;
       PRequestText.Visible := CheckBox.Checked;
   end;

end;

procedure TfrmDeleteRequest.DoRebranding;
begin
  LDelete.Caption := 'You should only mark accounts as deleted if the account is ' +
                     'no longer with ' + BRAND_FULL_NAME + '.';
end;

procedure TfrmDeleteRequest.EDateChange(Sender: TObject);
begin
   //Validate; makes it too hard to get the date right...
end;

procedure TfrmDeleteRequest.EDateDblClick(Sender: TObject);
var ld: Integer;
begin
   if sender is TOVcPictureField then begin
      ld := TOVcPictureField(Sender).AsStDate;
      PopUpCalendar(TEdit(Sender),ld);
      TOVcPictureField(Sender).AsStDate := ld;
   end;
end;

procedure TfrmDeleteRequest.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  EDate.AsStDate := CurrentDate;
  Image1.Picture := AppImages.InfoBmp.Picture;

  DoRebranding();
end;

procedure TfrmDeleteRequest.SetDoRequest(const Value: boolean);
begin
  FDoRequest := Value;
  if FDoRequest then begin
     self.Caption := 'Send Delete Request';
     CheckBox.Caption := 'Mark accounts as deleted';
     pRequest.Visible := True;
     PRequestText.Visible := True;
  end else begin
     self.Caption := 'Mark Accounts as Deleted';
     CheckBox.Caption := 'Send delete request';
     PDeleteText.Visible := True;
  end;
  CheckBoxClick(nil);
end;

function TfrmDeleteRequest.Validate: Boolean;
var ld: Integer;
begin
   Result := False;
   ld := EDate.AsStDate;
   if ld < CurrentDate then begin
      HelpfulInfoMsg('Deletions cannot be retrospective,'#13'please enter later date',0);
      EDate.AsSTDate := CurrentDate;
      EDate.SetFocus;
      Exit;
   end;
   Result := True;
end;

end.
