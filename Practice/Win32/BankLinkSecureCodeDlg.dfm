object frmBankLinkSecureCode: TfrmBankLinkSecureCode
  Left = 0
  Top = 0
  ActiveControl = edtSecureCode
  BorderStyle = bsDialog
  Caption = 'Enter BankLink Secure Code'
  ClientHeight = 99
  ClientWidth = 320
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 27
    Width = 105
    Height = 13
    Caption = 'BankLink Secure Code'
  end
  object Button1: TButton
    Left = 154
    Top = 64
    Width = 75
    Height = 25
    Caption = '&OK'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 236
    Top = 64
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edtSecureCode: TEdit
    Left = 158
    Top = 24
    Width = 153
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 0
  end
end
