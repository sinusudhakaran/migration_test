unit AccountValidationErrorDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  OSFont;

//------------------------------------------------------------------------------
type
  TfrmAccountValidationError = class(TForm)
    lblText: TLabel;
    btnOK: TButton;
    Image1: TImage;
    memDetails: TMemo;
    lblDetails: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure btnMoreClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
  public
    procedure SetDetails(aInstitutionName, aAccountNumber, aCoreError : string);
    procedure ReSizeControls();
  end;

  //----------------------------------------------------------------------------
  procedure ShowAccountValidationError(aInstitutionName, aAccountNumber, aCoreError : string);

//------------------------------------------------------------------------------
implementation
{$R *.DFM}

uses
  bkXPThemes,
  Globals,
  ImagesFrm;

const
  MAX_WIDTH = 500;
  MIN_WIDTH = 300;
  MIN_HEIGHT = 130;
  MARGIN = 10;
  INSTITUON_MSG = 'Institution (%s) and Account Number (%s) appear to be invalid. ' + #13#10 +
                  'Please enter valid details or, if the details ' +                  'you entered are correct, select Other from the Instituion list ' +                  'to continue.';


//------------------------------------------------------------------------------
procedure ShowAccountValidationError(aInstitutionName, aAccountNumber, aCoreError : string);
var
  AccValErrorForm : TfrmAccountValidationError;
begin
  AccValErrorForm := TfrmAccountValidationError.Create(Application.MainForm);
  try
    AccValErrorForm.SetDetails(aInstitutionName, aAccountNumber, aCoreError);
    AccValErrorForm.ReSizeControls();

    AccValErrorForm.ShowModal;
  finally
    FreeAndNil(AccValErrorForm);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmAccountValidationError.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  Image1.Picture := AppImages.ErrorBmp.Picture;
end;

//------------------------------------------------------------------------------
procedure TfrmAccountValidationError.ReSizeControls;
var
  CapHeight : integer;
  MinHeight : integer;
begin
  CapHeight := GetSystemMetrics(SM_CYCAPTION)+ GetSystemMetrics(SM_CYEDGE);
  lblText.Left :=  Image1.Left +  Image1.Width + MARGIN;

  if ( lblText.Height+Margin) < ( Image1.height) then
    MinHeight :=  Image1.Height + MARGIN
  else
    MinHeight :=  lblText.ClientHeight + 2 * MARGIN;

  Height := CapHeight + MinHeight +  btnOK.Height + 2 * MARGIN;
  Height := Height + (memDetails.Top + memDetails.Height + MARGIN) - lblDetails.Top;

  lblDetails.Left := lblText.Left;
  memDetails.Left := lblDetails.Left;
end;

//------------------------------------------------------------------------------
procedure TfrmAccountValidationError.btnOKClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
procedure TfrmAccountValidationError.btnMoreClick(Sender: TObject);
begin
   // AppHelpForm.ShowHelp(AppHELPFILENAME,helpContext);
end;

//------------------------------------------------------------------------------
procedure TfrmAccountValidationError.SetDetails(aInstitutionName, aAccountNumber, aCoreError: string);
begin
  lblText.caption := Format(INSTITUON_MSG, [aInstitutionName, aAccountNumber]);
  memDetails.Lines.Add(aCoreError);
end;

end.
