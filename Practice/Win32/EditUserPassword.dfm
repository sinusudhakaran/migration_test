object EditUserPassword: TEditUserPassword
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Change Password'
  ClientHeight = 171
  ClientWidth = 324
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
    Left = 8
    Top = 18
    Width = 65
    Height = 13
    Caption = '&Old Password'
  end
  object lblNewPassword: TLabel
    Left = 8
    Top = 48
    Width = 70
    Height = 13
    Caption = '&New Password'
  end
  object lblConfirmPassword: TLabel
    Left = 8
    Top = 78
    Width = 86
    Height = 13
    Caption = '&Confirm Password'
  end
  object edtOldPassword: TEdit
    Left = 101
    Top = 18
    Width = 215
    Height = 21
    PasswordChar = '#'
    TabOrder = 0
  end
  object edtNewPassword: TEdit
    Left = 100
    Top = 45
    Width = 215
    Height = 21
    PasswordChar = '#'
    TabOrder = 1
  end
  object chkOnlineAndPracticeSamePass: TCheckBox
    Left = 8
    Top = 106
    Width = 318
    Height = 17
    Caption = 'Set your BankLink Online password to be the same as above'
    TabOrder = 3
  end
  object btnOk: TButton
    Left = 151
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 4
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 241
    Top = 136
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object edtConfirmPassword: TEdit
    Left = 101
    Top = 76
    Width = 215
    Height = 21
    PasswordChar = '#'
    TabOrder = 2
  end
end
