object FrmChartExportMapGSTClass: TFrmChartExportMapGSTClass
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Map GST Class'
  ClientHeight = 463
  ClientWidth = 788
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
    788
    463)
  PixelsPerInch = 96
  TextHeight = 13
  object grpMain: TGroupBox
    Left = 0
    Top = -5
    Width = 786
    Height = 429
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentColor = False
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      786
      429)
    object lblGstRemapFile: TLabel
      Left = 12
      Top = 12
      Width = 118
      Height = 16
      Caption = 'GST class remap file'
      FocusControl = edtGstReMapFile
    end
    object edtGstReMapFile: TEdit
      Left = 136
      Top = 10
      Width = 574
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      Ctl3D = False
      Enabled = False
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object btnSave: TButton
      Left = 627
      Top = 40
      Width = 69
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Save'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnSaveClick
    end
    object btnSaveAs: TButton
      Left = 702
      Top = 40
      Width = 81
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Save As'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = btnSaveAsClick
    end
    object btnBrowse: TButton
      Left = 716
      Top = 9
      Width = 67
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Browse'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnBrowseClick
    end
    object tblGSTReMap: TOvcTable
      Left = 3
      Top = 71
      Width = 780
      Height = 356
      ActiveRow = 2
      RowLimit = 21
      LockedCols = 0
      LeftCol = 0
      ActiveCol = 0
      Anchors = [akLeft, akTop, akRight, akBottom]
      BorderStyle = bsNone
      Color = clWindow
      Colors.ActiveUnfocused = clWindow
      Colors.ActiveUnfocusedText = clWindowText
      Colors.Editing = clWindow
      Controller = OvcController
      GridPenSet.NormalGrid.NormalColor = clBtnShadow
      GridPenSet.NormalGrid.Style = psSolid
      GridPenSet.NormalGrid.Effect = geVertical
      GridPenSet.LockedGrid.NormalColor = clBtnShadow
      GridPenSet.LockedGrid.Style = psSolid
      GridPenSet.LockedGrid.Effect = ge3D
      GridPenSet.CellWhenFocused.NormalColor = clBlack
      GridPenSet.CellWhenFocused.Style = psSolid
      GridPenSet.CellWhenFocused.Effect = geBoth
      GridPenSet.CellWhenUnfocused.NormalColor = clBlack
      GridPenSet.CellWhenUnfocused.Style = psClear
      GridPenSet.CellWhenUnfocused.Effect = geBoth
      LockedRowsCell = colHeader
      Options = [otoNoRowResizing, otoEnterToArrow]
      TabOrder = 4
      OnGetCellData = tblGSTReMapGetCellData
      OnGetCellAttributes = tblGSTReMapGetCellAttributes
      CellData = (
        'FrmChartExportMapGSTClass.colHeader'
        'FrmChartExportMapGSTClass.colCashBookGSTDropDown'
        'FrmChartExportMapGSTClass.colClassDescription'
        'FrmChartExportMapGSTClass.colID')
      RowData = (
        22)
      ColData = (
        50
        False
        True
        'FrmChartExportMapGSTClass.colID'
        350
        False
        True
        'FrmChartExportMapGSTClass.colClassDescription'
        350
        False
        True
        'FrmChartExportMapGSTClass.colCashBookGSTDropDown')
    end
  end
  object btnOk: TButton
    Left = 624
    Top = 430
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 705
    Top = 430
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
  object SaveDlg: TSaveDialog
    DefaultExt = '*.csv'
    Filter = 'CSV file *.csv|*.csv'
    FilterIndex = 0
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 584
    Top = 496
  end
  object OpenDlg: TOpenDialog
    Filter = 'Remap File|*.cht|CSV File|*.csv'
    Left = 552
    Top = 496
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
    Left = 32
    Top = 432
  end
  object colCashBookGSTDropDown: TOvcTCComboBox
    DropDownCount = 10
    Items.Strings = (
      'Income'
      'Expenditure'
      'Exempt'
      'Zero Rated')
    MaxLength = 15
    Style = csOwnerDrawFixed
    Table = tblGSTReMap
    OnChange = colCashBookGSTDropDownChange
    Left = 128
    Top = 432
  end
  object colID: TOvcTCString
    Access = otxReadOnly
    MaxLength = 60
    Table = tblGSTReMap
    Left = 64
    Top = 432
  end
  object colClassDescription: TOvcTCString
    Access = otxReadOnly
    MaxLength = 60
    Table = tblGSTReMap
    Left = 96
    Top = 432
  end
  object colHeader: TOvcTCColHead
    Headings.Strings = (
      'ID'
      'Class Description'
      'MYOB Essentials Cashbook GST class'
      '')
    ShowLetters = False
    Table = tblGSTReMap
    Top = 432
  end
end
