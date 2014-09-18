object frmBudget: TfrmBudget
  Left = 309
  Top = 235
  ActiveControl = tblBudget
  Caption = 'Enter Budget - <Budget Name>'
  ClientHeight = 453
  ClientWidth = 770
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Scaled = False
  Visible = True
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object stsDissect: TStatusBar
    Left = 0
    Top = 434
    Width = 770
    Height = 19
    Panels = <
      item
        Text = '1 of 100'
        Width = 75
      end
      item
        Text = '309 - Bank Charges'
        Width = 200
      end>
    ParentFont = True
    UseSystemFont = False
  end
  object tblBudget: TOvcTable
    Left = 0
    Top = 44
    Width = 770
    Height = 390
    LockedCols = 0
    LeftCol = 0
    ActiveCol = 3
    Align = alClient
    Color = clWindow
    Colors.Editing = clWindow
    Controller = DissectController
    Ctl3D = False
    GridPenSet.NormalGrid.NormalColor = clBtnShadow
    GridPenSet.NormalGrid.Style = psSolid
    GridPenSet.NormalGrid.Effect = geVertical
    GridPenSet.LockedGrid.NormalColor = clBtnShadow
    GridPenSet.LockedGrid.Style = psSolid
    GridPenSet.LockedGrid.Effect = ge3D
    GridPenSet.CellWhenFocused.NormalColor = clBlack
    GridPenSet.CellWhenFocused.Style = psSolid
    GridPenSet.CellWhenFocused.Effect = geNone
    GridPenSet.CellWhenUnfocused.NormalColor = clBlack
    GridPenSet.CellWhenUnfocused.Style = psDash
    GridPenSet.CellWhenUnfocused.Effect = geNone
    LockedRowsCell = tblHeader
    Options = [otoNoRowResizing, otoTabToArrow, otoEnterToArrow, otoNoSelection]
    ParentCtl3D = False
    PopupMenu = popBudget
    TabOrder = 0
    OnActiveCellChanged = tblBudgetActiveCellChanged
    OnActiveCellMoving = tblBudgetActiveCellMoving
    OnBeginEdit = tblBudgetBeginEdit
    OnDoneEdit = tblBudgetDoneEdit
    OnEndEdit = tblBudgetEndEdit
    OnEnteringRow = tblBudgetEnteringRow
    OnExit = tblBudgetExit
    OnGetCellData = tblBudgetGetCellData
    OnGetCellAttributes = tblBudgetGetCellAttributes
    OnMouseDown = tblBudgetMouseDown
    OnUserCommand = tblBudgetUserCommand
    CellData = (
      'frmBudget.tblHeader'
      'frmBudget.ColAccount'
      'frmBudget.ColDesc'
      'frmBudget.ColTotal'
      'frmBudget.ColMonth1'
      'frmBudget.ColMonth2'
      'frmBudget.ColMonth3'
      'frmBudget.ColMonth4'
      'frmBudget.ColMonth5'
      'frmBudget.ColMonth6'
      'frmBudget.ColMonth7'
      'frmBudget.ColMonth8'
      'frmBudget.ColMonth9'
      'frmBudget.ColMonth10'
      'frmBudget.ColMonth11'
      'frmBudget.ColMonth12')
    RowData = (
      22)
    ColData = (
      78
      False
      True
      'frmBudget.ColAccount'
      179
      False
      True
      'frmBudget.ColDesc'
      90
      False
      True
      'frmBudget.ColTotal'
      90
      False
      True
      'frmBudget.ColMonth1'
      90
      False
      True
      'frmBudget.ColMonth2'
      90
      False
      True
      'frmBudget.ColMonth3'
      90
      False
      True
      'frmBudget.ColMonth4'
      90
      False
      True
      'frmBudget.ColMonth5'
      90
      False
      True
      'frmBudget.ColMonth6'
      90
      False
      True
      'frmBudget.ColMonth7'
      90
      False
      True
      'frmBudget.ColMonth8'
      90
      False
      True
      'frmBudget.ColMonth9'
      90
      False
      True
      'frmBudget.ColMonth10'
      90
      False
      True
      'frmBudget.ColMonth11'
      90
      False
      True
      'frmBudget.ColMonth12')
  end
  object ExtraTitleBar: TRzPanel
    Left = 0
    Top = 0
    Width = 770
    Height = 44
    Align = alTop
    BorderSides = []
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    GradientColorStyle = gcsCustom
    GradientColorStop = 10459904
    ParentFont = False
    TabOrder = 2
    VisualStyle = vsGradient
    object lblDetails: TLabel
      Left = 7
      Top = 2
      Width = 60
      Height = 23
      Caption = 'Budget'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clCaptionText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
    end
    object lblStart: TLabel
      Left = 9
      Top = 27
      Width = 56
      Height = 13
      Caption = '01/01/2003'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
    end
    object lblAllExclude: TLabel
      Left = 104
      Top = 27
      Width = 109
      Height = 13
      Alignment = taRightJustify
      Caption = 'All figures exclude GST'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
    end
    object lblReminderNote: TLabel
      Left = 255
      Top = 27
      Width = 266
      Height = 13
      Alignment = taRightJustify
      Caption = 'Figures should normally be entered as positive amounts'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
    end
    object lblname: TLabel
      Left = 103
      Top = 2
      Width = 360
      Height = 24
      AutoSize = False
      Caption = 'lblname'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ShowAccelChar = False
      Transparent = True
      OnClick = lblnameClick
    end
    object edtName: TEdit
      Left = 103
      Top = 2
      Width = 355
      Height = 20
      TabStop = False
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 40
      ParentFont = False
      TabOrder = 0
      Text = 'BudgetName'
      Visible = False
      OnChange = edtNameChange
      OnEnter = edtNameEnter
      OnExit = edtNameExit
      OnKeyPress = edtNameKeyPress
    end
    object rgGST: TRadioGroup
      Left = 552
      Top = 0
      Width = 218
      Height = 44
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Anchors = [akRight]
      Columns = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemIndex = 0
      Items.Strings = (
        'GST Exclusive'
        'GST Inclusive')
      ParentFont = False
      TabOrder = 1
      OnClick = rgGSTClick
    end
  end
  object DissectController: TOvcController
    EntryCommands.TableList = (
      'Grid'
      True
      ())
    Epoch = 1900
    Left = 264
    Top = 184
  end
  object tblHeader: TOvcTCColHead
    Headings.Strings = (
      'Account'
      'Description'
      'Total'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12')
    ShowLetters = False
    Table = tblBudget
    Left = 264
    Top = 152
  end
  object ColAccount: TOvcTCString
    MaxLength = 10
    Table = tblBudget
    Left = 304
    Top = 152
  end
  object ColMonth1: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 344
    Top = 152
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth5: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 472
    Top = 152
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth12: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 512
    Top = 192
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth9: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 408
    Top = 184
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth10: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 440
    Top = 184
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth11: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 472
    Top = 184
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth3: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 408
    Top = 152
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth4: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 440
    Top = 152
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth6: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 496
    Top = 160
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth8: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 376
    Top = 184
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth7: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 344
    Top = 184
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColMonth2: TOvcTCNumericField
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    OnOwnerDraw = ColMonthOwnerDraw
    Left = 376
    Top = 152
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ColDesc: TOvcTCString
    MaxLength = 10
    Table = tblBudget
    Left = 304
    Top = 184
  end
  object popBudget: TPopupMenu
    Images = AppImages.Budgets
    Left = 272
    Top = 240
    object mniChartLookup: TMenuItem
      Caption = 'Chart &Lookup                        F2'
      ImageIndex = 9
      OnClick = mniChartLookupClick
    end
    object mniAverage: TMenuItem
      Caption = '&Average                                  Ctrl+A'
      ImageIndex = 3
      OnClick = mniAverageClick
    end
    object mniCopy: TMenuItem
      Caption = '&Copy                                       Ctrl+K'
      ImageIndex = 1
      OnClick = mniCopyClick
    end
    object mniIncreaseDecrease: TMenuItem
      Caption = '&Increase/Decrease                  *'
      ImageIndex = 6
      OnClick = mniIncreaseDecreaseClick
    end
    object mniSplit: TMenuItem
      Caption = '&Split                                         Ctrl+T'
      ImageIndex = 2
      OnClick = mniSplitClick
    end
    object mniGenerate: TMenuItem
      Caption = '&Generate                                 Ctrl+G'
      ImageIndex = 0
      OnClick = mniGenerateClick
    end
    object mniSmooth: TMenuItem
      Caption = 'Sm&ooth                                   Ctrl+M'
      ImageIndex = 4
      OnClick = mniSmoothClick
    end
    object mniEnterQuantity: TMenuItem
      Caption = 'Enter Quantity                        ='
      OnClick = mniEnterQuantityClick
    end
    object mniEnterPercentage: TMenuItem
      Caption = 'Enter Percentage                    +'
      OnClick = mniEnterPercentageClick
    end
    object mniClear: TMenuItem
      Caption = 'Clear'
      ImageIndex = 5
      object mniClearColumn: TMenuItem
        Caption = 'Clear Col&umn'
        OnClick = mniClearColumnClick
      end
      object mniClearRow: TMenuItem
        Caption = 'Clear Ro&w'
        OnClick = mniClearRowClick
      end
      object mniClearAll: TMenuItem
        Action = ActClearAll
        Caption = 'Clear &All    Ctrl+O'
      end
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mniHideUnused: TMenuItem
      Caption = '&Hide Unused Rows                Alt+Z'
      ImageIndex = 7
      OnClick = mniHideUnusedClick
    end
    object mniShowAll: TMenuItem
      Caption = '&Show All Rows                       Alt+A'
      ImageIndex = 8
      OnClick = mniShowAllClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mniEnterBalance: TMenuItem
      Caption = '&Enter opening balance         Ctrl+B'
      OnClick = mniEnterBalanceClick
    end
    object AutocalculateGST1: TMenuItem
      Action = actAutoCalculateGST
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object mniImport: TMenuItem
      Caption = 'Import'
      ImageIndex = 11
      OnClick = mniImportClick
    end
    object mniExport: TMenuItem
      Caption = 'Export'
      ImageIndex = 10
      OnClick = mniExportClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object mniLockLeftmost: TMenuItem
      Caption = 'Loc&k leftmost columns'
      OnClick = mniLockLeftmostClick
    end
    object Restoredefaultcolumnwidths1: TMenuItem
      Caption = '&Restore default column widths'
      OnClick = Restoredefaultcolumnwidths1Click
    end
  end
  object ColTotal: TOvcTCNumericField
    Access = otxNormal
    Adjust = otaCenterRight
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = 'i,iii,iii,iii'
    Table = tblBudget
    Left = 480
    Top = 232
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object ALBudget: TActionList
    Left = 376
    Top = 280
    object ActClearAll: TAction
      Caption = 'Clear &All'
      OnExecute = ActClearAllExecute
    end
    object ActClearColumn: TAction
      Caption = 'Clear &Column'
      OnExecute = ActClearColumnExecute
    end
    object ActClearRow: TAction
      Caption = 'Clear &Row'
      OnExecute = ActClearRowExecute
    end
    object actAutoCalculateGST: TAction
      Caption = 'Auto-calculate GST'
      OnExecute = actAutoCalculateGSTExecute
      OnUpdate = actAutoCalculateGSTUpdate
    end
  end
  object popClearItems: TPopupMenu
    Images = AppImages.Budgets
    Left = 272
    Top = 280
    object miClearColumn: TMenuItem
      Action = ActClearColumn
    end
    object miClearRow: TMenuItem
      Action = ActClearRow
    end
    object miClearAll: TMenuItem
      Action = ActClearAll
      Caption = 'Clear &All    Ctrl+O'
    end
  end
  object tmrUnusedRows: TTimer
    Enabled = False
    Interval = 1
    OnTimer = tmrUnusedRowsTimer
    Left = 488
    Top = 344
  end
end
