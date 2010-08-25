unit dlgAddFavourite;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, OSFont;

type
  TAddFavouriteDlg = class(TForm)
    btnCancel: TButton;
    btnSave: TButton;
    Panel1: TPanel;
    lblTitle: TLabel;
    Label2: TLabel;
    EName: TEdit;
    Label1: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private
    FTitle: string;
    FName: string;
    procedure SetReportName(const Value: string);
    procedure SetReportTitle(const Value: string);
    function GetReportName: string;
    { Private declarations }
  public
    property ReportName: string read GetReportName write SetReportName;
    property ReportTitle: string read FTitle write SetReportTitle;
    { Public declarations }
  end;


function GetNewFavouriteName(ATitle: string; var AName: string): Boolean;


implementation

{$R *.dfm}

uses
  bkXPThemes,
  GlConst,
  ubatchBase;

function GetNewFavouriteName(ATitle: string; var AName: string): Boolean;
begin
   Result := False;

   with TAddFavouriteDlg.Create(nil) do try
      ReportTitle := ATitle;
      ReportName := BatchReports.NewName(ReportTitle);

      if Showmodal = mrOK then begin
         AName := ReportName;
         Result := True;
      end;
   finally
      Free;
   end;
end;


procedure TAddFavouriteDlg.btnCancelClick(Sender: TObject);
begin
   modalResult := mrcancel;
end;

// Prompted version
procedure TAddFavouriteDlg.btnSaveClick(Sender: TObject);
begin
   if ReportName < ' ' then begin
      if MessageDlg('Please enter a valid name.', mtError, [mbOK, mbCancel], 0) = idCancel then
         ModalResult := mrCancel
      else
         EName.SetFocus;

   end else if Assigned(Batchreports.FindReportName(ReportName)) then begin
      if MessageDlg('A favourite named'#10'"'+ ReportName + '"'#10'already exists.'#10 +
                    'Please enter a different name.', mtError, [mbOK, mbCancel], 0) = idCancel then
         ModalResult := mrCancel
      else
         EName.SetFocus;
   end else
      Modalresult := mrOK;
end;


(*
procedure TAddFavouriteDlg.btnSaveClick(Sender: TObject);
// Unprompted, Automatic version
begin
   if ReportName < ' ' then begin
      EName.Text := FName;
   end;
   ReportName := Batchreports.NewName(ReportName);
   Modalresult := mrOK;
end;
*)

procedure TAddFavouriteDlg.FormCreate(Sender: TObject);
begin
   ThemeForm(Self);
end;

procedure TAddFavouriteDlg.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
  VK_ESCAPE : begin
         Key := 0;
         Modalresult := mrCancel;
      end;
  end;
end;

procedure TAddFavouriteDlg.FormShow(Sender: TObject);
begin
   EName.SetFocus;
end;

function TAddFavouriteDlg.GetReportName: string;
begin
   Result := Trim(EName.Text);
end;


procedure TAddFavouriteDlg.SetReportName(const Value: string);
begin
   EName.Text := Value;
   FName := Value;
end;

procedure TAddFavouriteDlg.SetReportTitle(const Value: string);
begin
  lblTitle.Caption :=
  'A ' + Value + ' report will be added to this client''s Favourite Reports list with the selected settings.';
  FTitle := Value;
end;

end.
