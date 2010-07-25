unit contradlg;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Buttons, OvcABtn, OvcBase, OvcISLB, OvcTCEdt,
  OvcTCBmp, OvcTCGly, OvcTCmmn, OvcTCell, OvcTCStr, OvcTCHdr, OvcTable,
  OSFont;

type
  TdlgContra = class(TForm)
    lblMessage: TLabel;
    Label2: TLabel;
    btnOK: TButton;
    btnClose: TButton;
    txtCode: TEdit;
    sbtnChart: TSpeedButton;
    lblContraDesc: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnListClick(Sender: TObject);
    procedure txtCodeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure sbtnChartClick(Sender: TObject);
    procedure txtCodeChange(Sender: TObject);
    procedure txtCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FCode : string;
    okPressed : boolean;
    removingMask : boolean;

    procedure DoList;
  public
    { Public declarations }
    property Code : string read FCode;
    function Execute(title, msg : string) : boolean;
  end;

  function GetContra(title, msg : string; var Code : string) : boolean;

//******************************************************************************
implementation
{$R *.DFM}

uses
  AccountLookupFrm,
  bkConst,
  bkDefs,
  bkMaskUtils,
  bkXPThemes,
  Globals,
  imagesFrm,
  StdHints;

//------------------------------------------------------------------------------
function TdlgContra.Execute(title,msg : string) :boolean;
begin
  FCode := '';
  txtCode.text := '';

  okPressed := false;
  result := false;

  lblMessage.Caption := msg;
  Self.Caption := title;
  Self.ShowModal;
  if okpressed then
  begin
    FCode := txtCode.text;
    result := true;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgContra.btnCloseClick(Sender: TObject);
begin
   close;
end;
//------------------------------------------------------------------------------
procedure TdlgContra.btnOKClick(Sender: TObject);
begin
   okPressed := true;
   close;
end;
//------------------------------------------------------------------------------
procedure tdlgContra.DoList;
var s : string;
begin
   s := txtCode.text;
   if PickAccount(s) then txtCode.text := s;
   txtCode.Refresh;
end;
//------------------------------------------------------------------------------
procedure TdlgContra.btnListClick(Sender: TObject);
begin
end;
//------------------------------------------------------------------------------
procedure TdlgContra.txtCodeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 113) or ((key=40) and (Shift = [ssAlt])) then
     DoList;
end;
//------------------------------------------------------------------------------
function GetContra(title, msg : string; var Code : string) : boolean;
var
  MyDlg : TdlgContra;
begin
  result := false;
  Code   := '';

  MyDlg := TdlgContra.Create(Application.MainForm);
  try
     if MyDlg.Execute(title,msg) then
     begin
        Code := trim(MyDlg.Code);
        Result := Code <> '';
     end;
  finally
     MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgContra.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  removingMask      := false;
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,sbtnChart.Glyph);
  SetUpHelp;
  txtCode.MaxLength := MaxBK5CodeLen;
  lblContraDesc.Caption := '';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgContra.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   txtCode.Hint     :=
                    'Enter the Contra Account Code to use for this Bank Account|' +
                    'Enter the Contra Account Code from the Chart of Accounts which corresponds to this Bank Account';
                    
   sbtnChart.Hint   := STDHINTS.ChartLookupHint;
end;
//------------------------------------------------------------------------------
procedure TdlgContra.sbtnChartClick(Sender: TObject);
begin
  DoList;
  txtCode.setFocus;
end;
//------------------------------------------------------------------------------
procedure TdlgContra.txtCodeChange(Sender: TObject);
var
  pAcct   : pAccount_Rec;
  S       : string;
  IsValid : boolean;
begin
  bkMaskUtils.CheckForMaskChar(txtCode,RemovingMask);

  if MyClient.clChart.ItemCount = 0 then
    Exit;

  s       := Trim( txtCode.Text);
  pAcct   := MyClient.clChart.FindCode( S);
  IsValid := Assigned( pAcct) and
             (pAcct^.chAccount_Type = atBankAccount) and
             pAcct^.chPosting_Allowed;

  if Assigned( pAcct) then
    lblContraDesc.Caption := pAcct^.chAccount_Description
  else
    lblContraDesc.Caption := '';

  if (S = '') or ( IsValid) then begin
    txtCode.Font.Color := clWindowText;
    txtCode.Color      := clWindow;
  end
  else begin
    txtCode.Font.Color := clWhite;
    txtCode.Color      := clRed;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgContra.txtCodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_back then bkMaskUtils.CheckRemoveMaskChar(txtCode,RemovingMask);
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.
