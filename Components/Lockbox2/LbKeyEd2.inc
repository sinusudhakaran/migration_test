{*********************************************************}
{*                  LBKEYED4.INC 2.07                    *}
{*     Copyright (c) 2002 TurboPower Software Co         *}
{*                 All rights reserved.                  *}
{*********************************************************}

  {-Asymmetric key generation dialog}

interface

uses
{$IFDEF MSWINDOWS}
  Windows,
  Controls,
  Forms,
  Dialogs,
  Graphics,
  Buttons,
  ExtCtrls,
  StdCtrls,
  ComCtrls,
  Tabnotbk,
{$ENDIF}

{$IFDEF Version6}
  DesignIntf,
  DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}

{$IFDEF UsingCLX}
  QForms,
  QGraphics,
  QControls,
  QStdCtrls,
  QExtCtrls,
  QComCtrls,
{$ENDIF}
  SysUtils,
  Classes;

type
  TfrmRSAKeys = class(TForm)
    btnClose: TButton;
    Label4: TLabel;
    edtModulus: TEdit;
    Label5: TLabel;
    edtPublicExponent: TEdit;
    Label6: TLabel;
    edtPrivateExponent: TEdit;
    Bevel1: TBevel;
    StatusBar1: TStatusBar;
    Label9: TLabel;
    cbxKeySize: TComboBox;
    Label1: TLabel;
    Label8: TLabel;
    edtIterations: TEdit;
    btnGenerate: TButton;
    btnClear: TButton;
    procedure btnGenRSAKeysClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
  private
    FAbort : Boolean;
    procedure RSACallback(var Abort : Boolean);
  end;

type
  TLbRSAKeyEditor = class(TDefaultEditor)
  public
    procedure ExecuteVerb(Index : Integer);
      override;
    function GetVerb(Index : Integer) : string;
      override;
    function GetVerbCount : Integer;
      override;
  end;

implementation

uses
  LbRSA, LbAsym, LbCipher, LbUtils;

{ == TLbRSAKeyKeyEditor ==================================================== }
procedure TLbRSAKeyEditor.ExecuteVerb(Index : Integer);
begin
  if (Index <> 0) then
    Exit;

  with TfrmRSAKeys.Create(Application) do
    try
      ShowModal;
    finally
      Free;
    end;
end;
{ -------------------------------------------------------------------------- }
function TLbRSAKeyEditor.GetVerb(Index : Integer) : string;
begin
  case Index of
    0 : Result := 'Generate RSA Key Pair';
  else
    Result := '?';
  end;
end;
{ -------------------------------------------------------------------------- }
function TLbRSAKeyEditor.GetVerbCount : Integer;
begin
  Result := 1;
end;

{ == TfrmKeys ============================================================== }
procedure TfrmRSAKeys.btnGenRSAKeysClick(Sender: TObject);
var
  Pub : TLbRSAKey;
  Pri : TLbRSAKey;
begin
  FAbort := False;
  Screen.Cursor := crHourglass;
  btnClearClick(nil);
  StatusBar1.SimpleText := 'Generating key pair, this may take a while';
  Pub := TLbRSAKey.Create(TLbAsymKeySize(cbxKeySize.ItemIndex));
  Pri := TLbRSAKey.Create(TLbAsymKeySize(cbxKeySize.ItemIndex));
  try
    GenerateRSAKeysEx(Pri, Pub, TLbAsymKeySize(cbxKeySize.ItemIndex),
      StrToIntDef(edtIterations.Text, 20), RSACallback);
    edtModulus.Text := Pri.ModulusAsString;
    edtPublicExponent.Text := Pub.ExponentAsString;
    edtPrivateExponent.Text := Pri.ExponentAsString;
  finally
    Pri.Free;
    Pub.Free;
    Screen.Cursor := crDefault;
    StatusBar1.SimpleText := '';
  end;
end;
{ -------------------------------------------------------------------------- }
procedure TfrmRSAKeys.RSACallback(var Abort : Boolean);
begin
  Abort := FAbort;
end;
{ -------------------------------------------------------------------------- }
procedure TfrmRSAKeys.FormCreate(Sender: TObject);
begin
  cbxKeySize.ItemIndex := Ord(aks128);
end;
{ -------------------------------------------------------------------------- }
procedure TfrmRSAKeys.btnCloseClick(Sender: TObject);
begin
  FAbort := True;
end;
{ -------------------------------------------------------------------------- }
procedure TfrmRSAKeys.btnClearClick(Sender: TObject);
begin
  edtModulus.Text := '';
  edtPublicExponent.Text := '';
  edtPrivateExponent.Text := '';
  Application.ProcessMessages;
end;

end.



