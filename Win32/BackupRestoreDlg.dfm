object dlgBackupRestore: TdlgBackupRestore
  Left = 417
  Top = 324
  BorderStyle = bsDialog
  Caption = 'Backup Options'
  ClientHeight = 122
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    525
    122)
  PixelsPerInch = 96
  TextHeight = 16
  object btnFolder: TSpeedButton
    Left = 492
    Top = 24
    Width = 25
    Height = 24
    Hint = 'Click to Select a Folder'
    OnClick = btnFolderClick
  end
  object Label8: TLabel
    Left = 16
    Top = 28
    Width = 95
    Height = 16
    Caption = '&Backup Directory'
    FocusControl = edtDir
  end
  object edtDir: TEdit
    Left = 152
    Top = 24
    Width = 339
    Height = 24
    BorderStyle = bsNone
    TabOrder = 0
    Text = 'edtDir'
  end
  object btnOk: TButton
    Left = 363
    Top = 91
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    ExplicitLeft = 368
  end
  object btnCancel: TButton
    Left = 443
    Top = 91
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    ExplicitLeft = 448
  end
  object chkOverwrite: TCheckBox
    Left = 152
    Top = 58
    Width = 249
    Height = 17
    Caption = 'O&verwrite existing backup(s)'
    TabOrder = 3
    Visible = False
  end
end
