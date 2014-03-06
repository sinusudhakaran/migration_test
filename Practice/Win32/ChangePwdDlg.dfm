object dlgChangePwd: TdlgChangePwd
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Enter Password'
  ClientHeight = 170
  ClientWidth = 258
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblCurrent: TLabel
    Left = 23
    Top = 20
    Width = 86
    Height = 13
    Caption = '&Current Password'
    FocusControl = edtCurrent
  end
  object lblNew: TLabel
    Left = 23
    Top = 57
    Width = 70
    Height = 13
    Caption = '&New Password'
    FocusControl = edtNew
  end
  object lblConfirm: TLabel
    Left = 23
    Top = 101
    Width = 86
    Height = 13
    Caption = 'Con&firm Password'
    FocusControl = edtConfirm
  end
  object Label20: TLabel
    Left = 23
    Top = 78
    Width = 115
    Height = 13
    Caption = '(Maximum 8 characters)'
  end
  object edtCurrent: TEdit
    Left = 137
    Top = 16
    Width = 111
    Height = 20
    CharCase = ecUpperCase
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 11
    Font.Name = 'Wingdings'
    Font.Style = []
    MaxLength = 8
    ParentFont = False
    PasswordChar = #376
    TabOrder = 0
  end
  object edtNew: TEdit
    Left = 137
    Top = 53
    Width = 111
    Height = 20
    CharCase = ecUpperCase
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 11
    Font.Name = 'Wingdings'
    Font.Style = []
    MaxLength = 8
    ParentFont = False
    PasswordChar = #376
    TabOrder = 1
  end
  object edtConfirm: TEdit
    Left = 137
    Top = 98
    Width = 111
    Height = 20
    CharCase = ecUpperCase
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 11
    Font.Name = 'Wingdings'
    Font.Style = []
    MaxLength = 8
    ParentFont = False
    PasswordChar = #376
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 94
    Top = 137
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 175
    Top = 137
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
