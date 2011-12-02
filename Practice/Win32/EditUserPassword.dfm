object EditUserPassword: TEditUserPassword
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Change Password'
  ClientHeight = 175
  ClientWidth = 397
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblOldPassword: TLabel
    Left = 16
    Top = 21
    Width = 65
    Height = 13
    Caption = '&Old Password'
  end
  object lblNewPassword: TLabel
    Left = 16
    Top = 52
    Width = 70
    Height = 13
    Caption = '&New Password'
  end
  object lblConfirmPassword: TLabel
    Left = 16
    Top = 82
    Width = 86
    Height = 13
    Caption = '&Confirm Password'
  end
  object edtOldPassword: TEdit
    Left = 144
    Top = 18
    Width = 245
    Height = 21
    CharCase = ecUpperCase
    PasswordChar = #376
    TabOrder = 0
  end
  object edtNewPassword: TEdit
    Left = 144
    Top = 49
    Width = 244
    Height = 21
    CharCase = ecUpperCase
    PasswordChar = #376
    TabOrder = 1
  end
  object chkOnlineAndPracticeSamePass: TCheckBox
    Left = 16
    Top = 113
    Width = 373
    Height = 17
    Caption = 'Set your BankLink Online password to be the same as above'
    TabOrder = 3
  end
  object btnOk: TButton
    Left = 224
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 4
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 314
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object edtConfirmPassword: TEdit
    Left = 144
    Top = 79
    Width = 245
    Height = 21
    CharCase = ecUpperCase
    PasswordChar = #376
    TabOrder = 2
  end
end
