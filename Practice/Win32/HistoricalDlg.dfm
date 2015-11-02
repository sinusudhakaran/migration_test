object dlgHistorical: TdlgHistorical
  Left = 381
  Top = 274
  ActiveControl = tblHist
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Add Historical Entries'
  ClientHeight = 531
  ClientWidth = 910
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 600
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Scaled = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Shape3: TShape
    Left = 906
    Top = 81
    Width = 1
    Height = 333
    Align = alRight
    Pen.Color = clSilver
    ExplicitLeft = 908
    ExplicitTop = 161
    ExplicitHeight = 274
  end
  object Shape4: TShape
    AlignWithMargins = True
    Left = 3
    Top = 81
    Width = 0
    Height = 333
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alLeft
    Pen.Color = clSilver
    ExplicitTop = 83
    ExplicitHeight = 352
  end
  object Shape7: TShape
    Left = 3
    Top = 81
    Width = 1
    Height = 333
    Align = alLeft
    Pen.Color = clSilver
    ExplicitLeft = 0
    ExplicitTop = 1
    ExplicitHeight = 37
  end
  object Shape8: TShape
    AlignWithMargins = True
    Left = 907
    Top = 81
    Width = 0
    Height = 333
    Margins.Left = 0
    Margins.Top = 0
    Margins.Bottom = 0
    Align = alRight
    Pen.Color = clSilver
    ExplicitLeft = 891
    ExplicitTop = 83
    ExplicitHeight = 352
  end
  object stbHistorical: TStatusBar
    AlignWithMargins = True
    Left = 3
    Top = 510
    Width = 904
    Height = 21
    Margins.Top = 0
    Margins.Bottom = 0
    Panels = <
      item
        Alignment = taCenter
        Text = 'R/A'
        Width = 50
      end
      item
        Text = 'X of XXX'
        Width = 85
      end
      item
        Text = 'XXX - Account Desc'
        Width = 420
      end
      item
        Text = 'Gst  X | $XX.XX'
        Width = 150
      end>
    ParentFont = True
    ParentShowHint = False
    ShowHint = False
    SizeGrip = False
    UseSystemFont = False
  end
  object tblHist: TBKOvcTable
    Left = 4
    Top = 81
    Width = 902
    Height = 333
    Margins.Top = 0
    Margins.Bottom = 0
    LockedCols = 0
    LeftCol = 0
    ActiveCol = 0
    Align = alClient
    BorderStyle = bsNone
    Color = clWindow
    Colors.ActiveUnfocused = clWindow
    Colors.LockedText = clBtnText
    Colors.Editing = clWindow
    Controller = cntController
    GridPenSet.NormalGrid.NormalColor = clSilver
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
    LockedRowsCell = hdrColumnHeadings
    Options = [otoEnterToArrow, otoNoSelection, otoThumbTrack]
    TabOrder = 0
    OnBeginEdit = tblHistBeginEdit
    OnDoneEdit = tblHistDoneEdit
    OnEndEdit = tblHistEndEdit
    OnEnter = tblHistEnter
    OnExit = tblHistExit
    OnGetCellData = tblHistGetCellData
    OnGetCellAttributes = tblHistGetCellAttributes
    OnKeyDown = tblHistKeyDown
    OnMouseDown = tblHistMouseDown
    OnMouseUp = tblHistMouseUp
    CellData = (
      'dlgHistorical.hdrColumnHeadings')
    RowData = (
      30)
    ColData = (
      150
      False
      False)
  end
  object pfHiddenAmount: TOvcPictureField
    Left = 504
    Top = 288
    Width = 89
    Height = 21
    Cursor = crIBeam
    DataType = pftDouble
    CaretOvr.Shape = csBlock
    Controller = cntController
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
    MaxLength = 12
    Options = []
    PictureMask = '#########.##'
    TabOrder = 2
    Visible = False
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object pnlToolbar: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 44
    Width = 904
    Height = 37
    Margins.Top = 0
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    object Shape1: TShape
      Left = 903
      Top = 1
      Width = 1
      Height = 35
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 908
      ExplicitHeight = 37
    end
    object Shape2: TShape
      Left = 0
      Top = 1
      Width = 1
      Height = 35
      Align = alLeft
      Pen.Color = clSilver
      ExplicitHeight = 37
    end
    object Shape5: TShape
      Left = 0
      Top = 0
      Width = 904
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 910
    end
    object Shape6: TShape
      Left = 0
      Top = 36
      Width = 904
      Height = 1
      Align = alBottom
      Pen.Color = clSilver
      ExplicitTop = 40
      ExplicitWidth = 910
    end
    object rztHistorical: TRzToolbar
      Left = 3
      Top = 4
      Width = 849
      Align = alNone
      AutoResize = False
      AutoStyle = False
      Images = AppImages.Coding
      Margin = 0
      ButtonWidth = 70
      ButtonHeight = 26
      ShowButtonCaptions = True
      ShowDivider = False
      TextOptions = ttoCustom
      WrapControls = False
      BorderInner = fsPopup
      BorderOuter = fsNone
      BorderSides = []
      BorderWidth = 0
      GradientColorStyle = gcsCustom
      GradientColorStart = clBtnFace
      TabOrder = 0
      VisualStyle = vsClassic
      ToolbarControls = (
        tbChart
        tbPayee
        tbJob
        tbDissect
        tbSort
        tbRepeat
        tbCopyLine
        tbView
        tbAddCheques
        tbHelpSep
        tbImportTrans
        tbHelp)
      object tbChart: TRzToolButton
        Left = 0
        Top = 1
        Width = 69
        Height = 26
        UseToolbarButtonSize = False
        Action = actChart
      end
      object tbPayee: TRzToolButton
        Left = 69
        Top = 1
        Width = 66
        Height = 26
        UseToolbarButtonSize = False
        Action = actPayees
      end
      object tbDissect: TRzToolButton
        Left = 205
        Top = 1
        Width = 69
        Height = 26
        UseToolbarButtonSize = False
        Action = actDissect
      end
      object tbSort: TRzToolButton
        Left = 274
        Top = 1
        Width = 79
        Height = 26
        DropDownMenu = popSortBy
        ImageIndex = 4
        UseToolbarButtonSize = False
        ToolStyle = tsDropDown
        Caption = 'Sort'
      end
      object tbRepeat: TRzToolButton
        Left = 353
        Top = 1
        Width = 76
        Height = 26
        ImageIndex = 6
        UseToolbarButtonSize = False
        Caption = 'Copy Cell'
        OnClick = tbRepeatClick
      end
      object tbView: TRzToolButton
        Left = 509
        Top = 1
        Width = 79
        Height = 26
        DropDownMenu = popView
        ImageIndex = 8
        UseToolbarButtonSize = False
        ToolStyle = tsDropDown
        Caption = 'View'
      end
      object tbAddCheques: TRzToolButton
        Left = 588
        Top = 1
        Width = 75
        Height = 26
        ImageIndex = 9
        UseToolbarButtonSize = False
        Caption = 'Cheques'
        OnClick = tbAddChequesClick
      end
      object tbHelpSep: TRzSpacer
        Left = 663
        Top = 2
      end
      object tbHelp: TRzToolButton
        Left = 765
        Top = 1
        Width = 75
        Height = 26
        ImageIndex = 10
        UseToolbarButtonSize = False
        Caption = 'Help  '
        OnClick = tbHelpClick
      end
      object tbCopyLine: TRzToolButton
        Left = 429
        Top = 1
        Width = 80
        Height = 26
        ImageIndex = 13
        UseToolbarButtonSize = False
        Caption = 'Copy Line'
        OnClick = tbCopyLineClick
      end
      object tbJob: TRzToolButton
        Left = 135
        Top = 1
        Action = actJob
      end
      object tbImportTrans: TRzToolButton
        Left = 671
        Top = 1
        Width = 94
        Height = 26
        UseToolbarButtonSize = False
        Caption = 'Import Transactions'
        OnClick = tbImportTransClick
      end
    end
  end
  object pnlExtraTitleBar: TRzPanel
    Left = 0
    Top = 0
    Width = 910
    Height = 44
    Align = alTop
    BorderSides = []
    GradientColorStyle = gcsCustom
    GradientColorStop = 10459904
    TabOrder = 4
    VisualStyle = vsGradient
    object lblAcctDetails: TLabel
      Left = 6
      Top = 2
      Width = 206
      Height = 21
      Caption = 'Bank Account Name and No'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ShowAccelChar = False
      Transparent = True
    end
    object lblTransRange: TLabel
      Left = 6
      Top = 26
      Width = 181
      Height = 14
      Caption = 'Coding Range 1/1/90 - 12/12/99'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
    end
    object imgGraphic: TImage
      Left = 677
      Top = 0
      Width = 233
      Height = 44
      Align = alRight
      Anchors = [akTop, akRight]
      AutoSize = True
      Center = True
      ExplicitLeft = 489
      ExplicitTop = 1
      ExplicitHeight = 42
    end
  end
  object pnlBottom: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 414
    Width = 904
    Height = 96
    Margins.Top = 0
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 1
    DesignSize = (
      904
      96)
    object Shape9: TShape
      Left = 903
      Top = 1
      Width = 1
      Height = 95
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 899
      ExplicitTop = 5
      ExplicitHeight = 86
    end
    object Label2: TLabel
      Left = 12
      Top = 6
      Width = 97
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Check Transactions:'
      ExplicitTop = 90
    end
    object lblOpen: TLabel
      Left = 12
      Top = 35
      Width = 158
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = '&Opening Balance from Statement'
    end
    object lblClose: TLabel
      Left = 12
      Top = 65
      Width = 127
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Calculated Closing Balance'
    end
    object Shape11: TShape
      Left = 0
      Top = 1
      Width = 1
      Height = 95
      Align = alLeft
      Pen.Color = clSilver
      ExplicitTop = 5
      ExplicitHeight = 86
    end
    object Shape12: TShape
      Left = 0
      Top = 0
      Width = 904
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnOK: TButton
      Left = 728
      Top = 57
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Post'
      Default = True
      TabOrder = 2
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 809
      Top = 57
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 3
      OnClick = btnCancelClick
    end
    object nfOpeningBal: TOvcNumericField
      Left = 260
      Top = 30
      Width = 130
      Height = 24
      Cursor = crIBeam
      DataType = nftDouble
      Anchors = [akLeft, akBottom]
      AutoSize = False
      CaretOvr.Shape = csBlock
      Controller = cntController
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#########.##'
      TabOrder = 0
      OnChange = nfOpeningBalChange
      OnKeyDown = nfOpeningBalKeyDown
      RangeHigh = {73B2DBB9838916F2FE43}
      RangeLow = {73B2DBB9838916F2FEC3}
    end
    object stClosingBal: TStaticText
      Left = 260
      Top = 63
      Width = 129
      Height = 22
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      BorderStyle = sbsSunken
      Caption = '$0.00'
      TabOrder = 4
      Transparent = False
    end
    object cmbSign: TComboBox
      Left = 396
      Top = 32
      Width = 51
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akBottom]
      ItemHeight = 13
      TabOrder = 1
      OnChange = cmbSignChange
      Items.Strings = (
        'IF'
        'OD')
    end
  end
  object cntController: TOvcController
    EntryCommands.TableList = (
      'Grid'
      True
      (
        113
        0))
    Epoch = 1900
    Left = 578
    Top = 112
  end
  object celRef: TOvcTCString
    MaxLength = 12
    Table = tblHist
    Left = 104
    Top = 112
  end
  object celAnalysis: TOvcTCString
    MaxLength = 12
    Table = tblHist
    Left = 144
    Top = 112
  end
  object celPayee: TOvcTCNumericField
    Adjust = otaCenterLeft
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd, efoTrimBlanks]
    PictureMask = '999999'
    ShowHint = True
    Table = tblHist
    OnKeyDown = celPayeeKeyDown
    OnOwnerDraw = celPayeeOwnerDraw
    Left = 488
    Top = 112
    RangeHigh = {3F420F00000000000000}
    RangeLow = {00000000000000000000}
  end
  object celGstAmt: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '#########.##'
    ShowHint = True
    Table = tblHist
    OnKeyPress = celGstAmtKeyPress
    OnOwnerDraw = celGstAmtOwnerDraw
    Left = 448
    Top = 112
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celQuantity: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '#########.####'
    ShowHint = True
    Table = tblHist
    OnChange = celQuantityChange
    OnExit = celQuantityExit
    Left = 368
    Top = 112
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celNarration: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 200
    ShowHint = True
    Table = tblHist
    UseASCIIZStrings = True
    Left = 312
    Top = 114
  end
  object celAccount: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 10
    ShowHint = True
    Table = tblHist
    OnExit = celAccountExit
    OnKeyDown = celAccountKeyDown
    OnKeyPress = celAccountKeyPress
    OnKeyUp = celAccountKeyUp
    OnOwnerDraw = celAccountOwnerDraw
    Left = 184
    Top = 112
  end
  object hdrColumnHeadings: TOvcTCColHead
    Headings.Strings = (
      'S')
    ShowLetters = False
    Table = tblHist
    Left = 16
    Top = 114
  end
  object pmTable: TPopupMenu
    Images = AppImages.Coding
    Left = 16
    Top = 176
    object mniLookupChart: TMenuItem
      Action = actChart
      Caption = '&Lookup Chart                                             F2'
    end
    object mniLookupPayee: TMenuItem
      Action = actPayees
      Caption = 'Lookup &Payee                                            F3'
    end
    object Jobs1: TMenuItem
      Action = actJob
      Caption = 'Lookup J&ob                                                F5'
    end
    object LookupGSTClass1: TMenuItem
      Action = actGST
      Caption = 'Lookup &GST Class                                      F7'
    end
    object mniDissect: TMenuItem
      Action = actDissect
      Caption = '&Dissect                                                       /'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object ConfigureColumns1: TMenuItem
      Caption = 'C&onfigure Columns'
      OnClick = actConfigureExecute
    end
    object RestoreColumns1: TMenuItem
      Action = actRestore
      Caption = '&Restore Column Defaults '
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object Insertanewline1: TMenuItem
      Caption = 'Insert a New Line                                      Shift+Ins'
      OnClick = Insertanewline1Click
    end
    object CopyContentoftheCellAbove1: TMenuItem
      Caption = 'C&opy Contents of the Cell Above              +'
      ImageIndex = 6
      OnClick = tbRepeatClick
    end
    object Copycontentsofthelineabove1: TMenuItem
      Caption = 'Cop&y Contents of the Line Above             Ctrl+N'
      ImageIndex = 13
      OnClick = tbCopyLineClick
    end
    object ConvertAmount1: TMenuItem
      Caption = 'Con&vert Amount'
      OnClick = ConvertAmount1Click
    end
  end
  object celDate: TOvcTCPictureField
    DataType = pftDate
    PictureMask = 'dd/mm/yy'
    MaxLength = 8
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Epoch = 1970
    Options = [efoForceOvertype]
    Table = tblHist
    OnEnter = celDateEnter
    OnError = celDateError
    OnExit = celDateExit
    Left = 64
    Top = 112
    RangeHigh = {25600D00000000000000}
    RangeLow = {00000000000000000000}
  end
  object celEntryType: TOvcTCComboBox
    Items.Strings = (
      'Cheque'
      'Withdrawl'
      'Deposit'
      'Bank Charges')
    MaxLength = 15
    Style = csDropDownList
    Table = tblHist
    Left = 528
    Top = 112
  end
  object celAmount: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '###,###,###.##'
    ShowHint = True
    Table = tblHist
    OnOwnerDraw = celAmountOwnerDraw
    Left = 224
    Top = 112
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object alHistorical: TActionList
    Images = AppImages.Coding
    Left = 72
    Top = 232
    object actChart: TAction
      Caption = 'Chart'
      ImageIndex = 0
      OnExecute = actChartExecute
    end
    object actPayees: TAction
      Caption = 'Payee'
      ImageIndex = 1
      OnExecute = actPayeesExecute
    end
    object actGST: TAction
      OnExecute = actGSTExecute
    end
    object actDissect: TAction
      Caption = 'Dissect'
      ImageIndex = 3
      OnExecute = actDissectExecute
    end
    object actConfigure: TAction
      Caption = 'C&onfigure Columns'
      OnExecute = actConfigureExecute
    end
    object actRestore: TAction
      Caption = '&Restore Column Defaults'
      OnExecute = actRestoreExecute
    end
    object actJob: TAction
      Caption = 'Job'
      ImageIndex = 18
      OnExecute = actJobExecute
    end
  end
  object popView: TPopupMenu
    Left = 48
    Top = 176
    object mniConfigureCols: TMenuItem
      Action = actConfigure
      GroupIndex = 3
    end
    object mniRestoreCols: TMenuItem
      Action = actRestore
      GroupIndex = 3
    end
  end
  object popSortBy: TPopupMenu
    OnPopup = popSortByPopup
    Left = 80
    Top = 176
    object mniSortByDate: TMenuItem
      Caption = 'By &Date'
      OnClick = mniSortByDateClick
    end
    object mniSortByChequeNumber: TMenuItem
      Caption = 'By &Cheque Number'
      OnClick = mniSortByChequeNumberClick
    end
    object mniSortByReference: TMenuItem
      Caption = 'By &Reference'
      OnClick = mniSortByReferenceClick
    end
    object mniSortByAccountCode: TMenuItem
      Caption = 'By &Account Code'
      OnClick = mniSortByAccountCodeClick
    end
    object mniSortByValue: TMenuItem
      Caption = 'By &Value'
      OnClick = mniSortByValueClick
    end
    object mniSortByNarration: TMenuItem
      Caption = 'By &Narration'
      OnClick = mniSortByNarrationClick
    end
    object mniSortByAltCode: TMenuItem
      Caption = 'By Alt Code'
      OnClick = mniSortByAltCodeClick
    end
  end
  object celGSTCode: TOvcTCString
    MaxLength = 3
    Table = tblHist
    OnKeyDown = celGSTCodeKeyDown
    OnOwnerDraw = celGSTCodeOwnerDraw
    Left = 408
    Top = 112
  end
  object celBalance: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterRight
    Table = tblHist
    UseASCIIZStrings = True
    OnOwnerDraw = celBalanceOwnerDraw
    Left = 624
    Top = 113
  end
  object celPayeeName: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 10
    ShowHint = True
    Table = tblHist
    Left = 216
    Top = 169
  end
  object celDescription: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 10
    ShowHint = True
    Table = tblHist
    Left = 264
    Top = 169
  end
  object celTaxInv: TOvcTCCheckBox
    Adjust = otaCenter
    CellGlyphs.IsDefault = False
    CellGlyphs.BitMap.Data = {
      36070000424D360700000000000036000000280000002A0000000E0000000100
      1800000000000007000000000000000000000000000000000000FF00FFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00FFFFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFFFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFF008000008000FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFF008000008000008000008000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFF008000008000008000008000008000008000FFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFF008000008000FFFFFFFFFFFF008000008000008000FF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFF008000FFFFFFFFFFFFFFFFFFFFFFFF00800000800000
      8000FFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00800000
      8000008000FFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00
      8000008000FFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF008000FFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00FFFFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFFFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000}
    CellGlyphs.GlyphCount = 3
    CellGlyphs.ActiveGlyphCount = 2
    Table = tblHist
    OnKeyUp = celTaxInvKeyUp
    OnMouseUp = celTaxInvMouseUp
    Left = 356
    Top = 178
  end
  object tmrPayee: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrPayeeTimer
    Left = 248
    Top = 232
  end
  object CelJob: TOvcTCString
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxLength = 8
    Table = tblHist
    TableFont = False
    OnOwnerDraw = CelJobOwnerDraw
    Left = 312
    Top = 168
  end
  object CelJobName: TOvcTCString
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxLength = 200
    Table = tblHist
    TableFont = False
    OnOwnerDraw = CelJobOwnerDraw
    Left = 312
    Top = 208
  end
  object celForexAmount: TOvcTCNumericField
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '##########.##'
    Table = tblHist
    OnOwnerDraw = celForexAmountOwnerDraw
    Left = 376
    Top = 256
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celForexRate: TOvcTCNumericField
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '####.####'
    Table = tblHist
    Left = 336
    Top = 256
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {00000000000000000000}
  end
  object celLocalAmount: TOvcTCNumericField
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '##########.##'
    Table = tblHist
    OnOwnerDraw = celLocalAmountOwnerDraw
    Left = 416
    Top = 256
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object CelAltChartCode: TOvcTCString
    MaxLength = 12
    Table = tblHist
    Left = 576
    Top = 168
  end
end
