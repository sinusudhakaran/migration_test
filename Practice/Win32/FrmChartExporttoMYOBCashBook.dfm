object FrmChartExporttoMYOBCashBook: TFrmChartExporttoMYOBCashBook
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Export {ClientCode}'#39's Chart of Accounts to Cashbook'
  ClientHeight = 335
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
    335)
  PixelsPerInch = 96
  TextHeight = 13
  object grpMain: TGroupBox
    Left = 8
    Top = 8
    Width = 499
    Height = 288
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      499
      288)
    object lblSaveEntriesTo: TLabel
      Left = 28
      Top = 239
      Width = 86
      Height = 16
      Anchors = [akLeft, akBottom]
      Caption = 'Save Entries to'
      FocusControl = edtSaveEntriesTo
      ExplicitTop = 228
    end
    object btnToFolder: TSpeedButton
      Left = 443
      Top = 235
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      Anchors = [akRight, akBottom]
      OnClick = btnToFolderClick
      ExplicitLeft = 490
      ExplicitTop = 224
    end
    object lblExportText: TLabel
      Left = 28
      Top = 32
      Width = 365
      Height = 16
      Caption = 'Export MYOB BankLink Practice chart of accounts to .CSV file for'
      FocusControl = edtSaveEntriesTo
    end
    object lblClosingBalanceDate: TLabel
      Left = 74
      Top = 178
      Width = 119
      Height = 16
      Caption = 'Closing Balance Date'
      FocusControl = edtSaveEntriesTo
    end
    object edtSaveEntriesTo: TEdit
      Left = 120
      Top = 237
      Width = 317
      Height = 22
      Anchors = [akLeft, akRight, akBottom]
      Ctl3D = False
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
    end
    object dteClosingBalanceDate: TOvcPictureField
      Left = 207
      Top = 178
      Width = 105
      Height = 20
      Cursor = crIBeam
      DataType = pftDate
      AutoSize = False
      BorderStyle = bsNone
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
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
      PictureMask = 'DD/mm/yy'
      TabOrder = 3
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object radExportFullChart: TRadioButton
      Left = 56
      Top = 80
      Width = 113
      Height = 17
      Caption = 'Export Full Chart'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object radExportBasicChart: TRadioButton
      Left = 228
      Top = 80
      Width = 131
      Height = 17
      Caption = 'Export Basic Chart'
      TabOrder = 1
    end
    object chkIncludeClosingBalances: TCheckBox
      Left = 56
      Top = 128
      Width = 169
      Height = 17
      Caption = 'Include closing balances'
      TabOrder = 2
      OnClick = chkIncludeClosingBalancesClick
    end
  end
  object btnOk: TButton
    Left = 351
    Top = 302
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
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 432
    Top = 302
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
    TabOrder = 2
  end
  object SaveDialog: TSaveDialog
    Filter = 'CSV Files (*.CSV)|*.CSV'
    Title = 'Save Entries to'
    Left = 320
    Top = 304
  end
end
