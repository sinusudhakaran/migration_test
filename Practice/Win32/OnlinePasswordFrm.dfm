object frmOnlinePassword: TfrmOnlinePassword
  Left = 0
  Top = 0
  ActiveControl = edtPassword
  BorderStyle = bsDialog
  Caption = 'BankLink Online Password'
  ClientHeight = 154
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
    Top = 90
    Width = 46
    Height = 13
    Caption = 'Password'
  end
  object Label2: TLabel
    Left = 16
    Top = 8
    Width = 369
    Height = 37
    AutoSize = False
    Caption = 
      'Practice is unable to authenticate with BankLink Online because ' +
      'your Practice password does not match your BankLink Online passw' +
      'ord.'
    WordWrap = True
  end
  object Label3: TLabel
    Left = 16
    Top = 49
    Width = 369
    Height = 30
    Caption = 
      'To continue please enter your BankLink Online password.  This wi' +
      'll also update your Practice password.'
    WordWrap = True
  end
  object Button1: TButton
    Left = 230
    Top = 119
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 310
    Top = 119
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edtPassword: TEdit
    Left = 96
    Top = 87
    Width = 289
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
  end
end
