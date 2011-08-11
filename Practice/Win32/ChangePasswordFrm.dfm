object ChangePasswordForm: TChangePasswordForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change Password'
  ClientHeight = 199
  ClientWidth = 351
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  DesignSize = (
    351
    199)
  PixelsPerInch = 96
  TextHeight = 13
  object lblCurrent: TLabel
    Left = 24
    Top = 35
    Width = 86
    Height = 13
    Caption = '&Current Password'
  end
  object lblNew: TLabel
    Left = 24
    Top = 75
    Width = 70
    Height = 13
    Caption = '&New Password'
  end
  object lblConfirm: TLabel
    Left = 24
    Top = 115
    Width = 86
    Height = 13
    Caption = 'Con&firm Password'
  end
  object eCurrent: TEdit
    Left = 160
    Top = 32
    Width = 150
    Height = 21
    MaxLength = 12
    PasswordChar = '*'
    TabOrder = 0
  end
  object eNew: TEdit
    Left = 160
    Top = 72
    Width = 150
    Height = 21
    MaxLength = 12
    PasswordChar = '*'
    TabOrder = 1
  end
  object eNewConfirm: TEdit
    Left = 160
    Top = 112
    Width = 150
    Height = 21
    MaxLength = 12
    PasswordChar = '*'
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 188
    Top = 158
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    ExplicitLeft = 702
    ExplicitTop = 523
  end
  object btnCancel: TButton
    Left = 268
    Top = 158
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    ExplicitLeft = 782
    ExplicitTop = 523
  end
end
