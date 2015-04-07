object FrmChartExporttoMYOBCashBook: TFrmChartExporttoMYOBCashBook
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 
    'Export {ClientCode}'#39's Chart of Accounts to MYOB Essentials Cashb' +
    'ook'
  ClientHeight = 316
  ClientWidth = 652
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
    652
    316)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 488
    Top = 283
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
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 569
    Top = 283
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
  end
  object pnlMain: TPanel
    Left = 8
    Top = 8
    Width = 636
    Height = 269
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelKind = bkFlat
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object lblExportText: TLabel
      Left = 20
      Top = 16
      Width = 591
      Height = 16
      Caption = 
        'Export MYOB BankLink Practice chart of accounts to .CSV file for' +
        ' import into MYOB Essentials Cashbook.'
      FocusControl = edtSaveEntriesTo
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblClosingBalanceDate: TLabel
      Left = 75
      Top = 158
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
      Left = 20
      Top = 216
      Width = 86
      Height = 16
      Caption = 'Save Entries to'
      FocusControl = edtSaveEntriesTo
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object btnToFolder: TSpeedButton
      Left = 585
      Top = 212
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = btnToFolderClick
    end
    object radExportFullChart: TRadioButton
      Left = 56
      Top = 66
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
      Top = 66
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
      Top = 116
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
    object edtSaveEntriesTo: TEdit
      Left = 112
      Top = 214
      Width = 467
      Height = 19
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
    end
    object dteClosingBalanceDate: TOvcPictureField
      Left = 208
      Top = 155
      Width = 105
      Height = 22
      Cursor = crIBeam
      DataType = pftDate
      AutoSize = False
      CaretOvr.Shape = csBlock
      Controller = OvcController
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
      MaxLength = 10
      Options = [efoCaretToEnd]
      ParentFont = False
      PictureMask = 'DD/mm/yyyy'
      TabOrder = 3
      OnDblClick = dteClosingBalanceDateDblClick
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'Comma Separated (CSV)|*.CSV'
    Title = 'Save Entries to'
    Left = 456
    Top = 280
  end
  object OvcController: TOvcController
    EntryCommands.TableList = (
      'Default'
      True
      ()
      'WordStar'
      False
      ()
      'Grid'
      False
      ())
    Epoch = 1900
    Left = 424
    Top = 280
  end
end
