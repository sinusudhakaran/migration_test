object EditUserPassword: TEditUserPassword
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Change Password'
  ClientHeight = 211
  ClientWidth = 476
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
    Width = 102
    Height = 16
    Caption = 'Current Password'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblNewPassword: TLabel
    Left = 16
    Top = 52
    Width = 84
    Height = 16
    Caption = 'New Password'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblConfirmPassword: TLabel
    Left = 16
    Top = 82
    Width = 104
    Height = 16
    Caption = 'Confirm Password'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LblPasswordValidation: TLabel
    Left = 16
    Top = 140
    Width = 449
    Height = 16
    Caption = 
      '(Your password must be 8 to 12 characters long and include at le' +
      'ast one digit)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object edtOldPassword: TEdit
    Left = 136
    Top = 20
    Width = 245
    Height = 21
    CharCase = ecUpperCase
    MaxLength = 12
    PasswordChar = #376
    TabOrder = 0
  end
  object edtNewPassword: TEdit
    Left = 136
    Top = 51
    Width = 244
    Height = 21
    CharCase = ecUpperCase
    MaxLength = 12
    PasswordChar = #376
    TabOrder = 1
  end
  object chkOnlineAndPracticeSamePass: TCheckBox
    Left = 16
    Top = 113
    Width = 373
    Height = 17
    Caption = 'Set your BankLink Online password to be the same as above'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object btnOk: TButton
    Left = 300
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Ok'
    Default = True
    TabOrder = 4
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 390
    Top = 176
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object edtConfirmPassword: TEdit
    Left = 136
    Top = 81
    Width = 245
    Height = 21
    CharCase = ecUpperCase
    MaxLength = 12
    PasswordChar = #376
    TabOrder = 2
  end
end
