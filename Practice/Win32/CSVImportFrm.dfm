object frmCSVImport: TfrmCSVImport
  Left = 219
  Top = 128
  BorderIcons = []
  Caption = 'Import from CSV'
  ClientHeight = 221
  ClientWidth = 582
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    582
    221)
  PixelsPerInch = 96
  TextHeight = 16
  object lblAccountNo: TLabel
    Left = 23
    Top = 17
    Width = 99
    Height = 16
    Caption = 'Account Number'
  end
  object lblAccountName: TLabel
    Left = 34
    Top = 49
    Width = 88
    Height = 16
    Caption = 'Account Name'
  end
  object Filename: TLabel
    Left = 66
    Top = 97
    Width = 56
    Height = 16
    Caption = 'Filename'
  end
  object Label1: TLabel
    Left = 74
    Top = 143
    Width = 48
    Height = 16
    Caption = 'Account'
  end
  object edtAcctNo: TEdit
    Left = 128
    Top = 16
    Width = 438
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    MaxLength = 60
    ParentFont = False
    TabOrder = 0
  end
  object edtAcctName: TEdit
    Left = 128
    Top = 44
    Width = 438
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    MaxLength = 60
    ParentFont = False
    TabOrder = 1
  end
  object btnImport: TButton
    Left = 379
    Top = 140
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Import'
    Default = True
    TabOrder = 4
    OnClick = btnImportClick
  end
  object btnCancel: TButton
    Left = 497
    Top = 181
    Width = 75
    Height = 25
    Anchors = [akTop, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = btnCancelClick
  end
  object edtFilename: TEdit
    Left = 128
    Top = 96
    Width = 438
    Height = 22
    Anchors = [akLeft, akTop, akRight]
    Color = 8454143
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
  end
  object btnBrowse: TButton
    Left = 541
    Top = 140
    Width = 25
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 3
    OnClick = btnBrowseClick
  end
  object btnExport: TButton
    Left = 298
    Top = 140
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Export'
    TabOrder = 6
    OnClick = btnExportClick
  end
  object cbAccounts: TComboBox
    Left = 128
    Top = 140
    Width = 164
    Height = 24
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 0
    TabOrder = 7
  end
  object btnView: TButton
    Left = 460
    Top = 140
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'View'
    TabOrder = 8
    OnClick = btnViewClick
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.csv'
    Filter = 'CSV Files (*.csv)|*.csv'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 16
    Top = 128
  end
end
