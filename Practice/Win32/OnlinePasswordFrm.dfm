object frmOnlinePassword: TfrmOnlinePassword
  Left = 0
  Top = 0
  ActiveControl = edtPassword
  BorderStyle = bsDialog
  Caption = 'BankLink Online Password'
  ClientHeight = 273
  ClientWidth = 422
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
    Top = 106
    Width = 55
    Height = 16
    Caption = 'Password'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblOnlineCaption01: TLabel
    Left = 16
    Top = 8
    Width = 398
    Height = 73
    AutoSize = False
    Caption = 
      'Practice is unable to authenticate with BankLink Online because ' +
      'your Practice password does not match your BankLink Online passw' +
      'ord.'#13#13'Enter your BankLink Online password here then click OK:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object lblOnlineCaption02: TLabel
    Left = 16
    Top = 148
    Width = 398
    Height = 69
    AutoSize = False
    Caption = 
      'If required, you can request a temporary password to be sent to ' +
      '%s using the Reset button below.'#13#13'Contact BankLink Support if yo' +
      'u require assistance.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object btnOk: TButton
    Left = 258
    Top = 240
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 339
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Cancel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 3
  end
  object edtPassword: TEdit
    Left = 96
    Top = 103
    Width = 318
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    PasswordChar = '*'
    TabOrder = 0
  end
  object btnResetPassword: TButton
    Left = 177
    Top = 240
    Width = 75
    Height = 25
    Caption = 'Reset'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 1
    OnClick = btnResetPasswordClick
  end
end
