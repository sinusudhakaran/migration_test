object frmExportBudget: TfrmExportBudget
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Export Budget'
  ClientHeight = 152
  ClientWidth = 525
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    525
    152)
  PixelsPerInch = 96
  TextHeight = 13
  object lblFilename: TLabel
    Left = 12
    Top = 12
    Width = 98
    Height = 16
    Caption = 'Export Budget To'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object btnToFile: TSpeedButton
    Left = 492
    Top = 8
    Width = 25
    Height = 24
    Hint = 'Click to Select a Folder'
    Anchors = [akTop, akRight]
    ParentShowHint = False
    ShowHint = True
    OnClick = btnToFileClick
    ExplicitLeft = 478
  end
  object btnOk: TButton
    Left = 364
    Top = 119
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = btnOkClick
    ExplicitTop = 103
  end
  object btnCancel: TButton
    Left = 445
    Top = 119
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 5
    ExplicitTop = 103
  end
  object edtBudgetFile: TEdit
    Left = 116
    Top = 8
    Width = 372
    Height = 24
    Hint = 'Enter the filename to export to'
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object chkIncludeUnusedChartCodes: TCheckBox
    Left = 12
    Top = 46
    Width = 239
    Height = 17
    Caption = 'Include Unused Chart Codes'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 1
  end
  object chkIncludeNonPostingChartCodes: TCheckBox
    Left = 12
    Top = 69
    Width = 239
    Height = 17
    Caption = 'Include Non-Posting Chart Codes'
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    State = cbChecked
    TabOrder = 2
  end
  object ckPrefix: TCheckBox
    Left = 12
    Top = 93
    Width = 301
    Height = 17
    Hint = 
      'Adds a Prefix Acc_ to allow account codes to display correctly i' +
      'n Excel'
    Caption = 'Add account prefix '#39'Acc_'#39
    Checked = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    State = cbChecked
    TabOrder = 3
  end
  object SaveTextFileDialog: TSaveTextFileDialog
    DefaultExt = 'csv'
    Filter = 'CSV Files (*.csv)|*.csv'
    Left = 488
    Top = 40
  end
end
