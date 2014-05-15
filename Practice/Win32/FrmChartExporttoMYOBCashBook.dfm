object FrmChartExporttoMYOBCashBook: TFrmChartExporttoMYOBCashBook
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Export {ClientCode}'#39's Chart of Accounts to Cashbook'
  ClientHeight = 317
  ClientWidth = 515
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    515
    317)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 351
    Top = 284
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
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
    ExplicitTop = 303
  end
  object btnCancel: TButton
    Left = 432
    Top = 284
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
    TabOrder = 1
    ExplicitTop = 303
  end
  object pnlMain: TPanel
    Left = 8
    Top = 8
    Width = 499
    Height = 270
    BevelKind = bkFlat
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    DesignSize = (
      495
      266)
    object lblExportText: TLabel
      Left = 20
      Top = 16
      Width = 365
      Height = 16
      Caption = 'Export MYOB BankLink Practice chart of accounts to .CSV file for'
      FocusControl = edtSaveEntriesTo
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblClosingBalanceDate: TLabel
      Left = 77
      Top = 161
      Width = 119
      Height = 16
      Caption = 'Closing Balance Date'
      FocusControl = edtSaveEntriesTo
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblSaveEntriesTo: TLabel
      Left = 28
      Top = 211
      Width = 86
      Height = 16
      Anchors = [akLeft, akBottom]
      Caption = 'Save Entries to'
      FocusControl = edtSaveEntriesTo
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ExplicitTop = 215
    end
    object btnToFolder: TSpeedButton
      Left = 456
      Top = 207
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      Anchors = [akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = btnToFolderClick
      ExplicitLeft = 460
      ExplicitTop = 211
    end
    object radExportFullChart: TRadioButton
      Left = 56
      Top = 64
      Width = 113
      Height = 17
      Caption = 'Export Full Chart'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      TabStop = True
    end
    object radExportBasicChart: TRadioButton
      Left = 228
      Top = 64
      Width = 131
      Height = 17
      Caption = 'Export Basic Chart'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
    object chkIncludeClosingBalances: TCheckBox
      Left = 56
      Top = 112
      Width = 169
      Height = 17
      Caption = 'Include closing balances'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = chkIncludeClosingBalancesClick
    end
    object dteClosingBalanceDate: TOvcPictureField
      Left = 215
      Top = 161
      Width = 105
      Height = 20
      Cursor = crIBeam
      DataType = pftDate
      AutoSize = False
      CaretOvr.Shape = csBlock
      ControlCharColor = clRed
      DecimalPlaces = 0
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Epoch = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
      ParentFont = False
      PictureMask = 'DD/mm/yy'
      TabOrder = 3
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object edtSaveEntriesTo: TEdit
      Left = 120
      Top = 209
      Width = 330
      Height = 22
      Anchors = [akLeft, akRight, akBottom]
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentCtl3D = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      ExplicitTop = 213
      ExplicitWidth = 334
    end
  end
  object SaveDialog: TSaveDialog
    Filter = 'CSV Files (*.CSV)|*.CSV'
    Title = 'Save Entries to'
    Left = 320
    Top = 280
  end
end
