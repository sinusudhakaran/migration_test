object frmOnlinePassword: TfrmOnlinePassword
  Left = 0
  Top = 0
  ActiveControl = edtPassword
  BorderStyle = bsDialog
  Caption = 'BankLink Online Password'
  ClientHeight = 249
  ClientWidth = 399
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 185
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object Label2: TLabel
    Left = 16
    Top = 8
    Width = 369
    Height = 153
    AutoSize = False
    Caption = 
      'Practice is unable to authenticate with BankLink Online because ' +
      'your Practice password does not match your BankLink Online passw' +
      'ord.'#13#13'You must enter your temporary password in order to complet' +
      'e this process. This would have been sent to you via email from ' +
      'BankLink.'#13#13'Contact BankLink Support if you require assistance.'
    WordWrap = True
  end
  object Button1: TButton
    Left = 230
    Top = 214
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 310
    Top = 214
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edtPassword: TEdit
    Left = 96
    Top = 182
    Width = 289
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
  end
end
