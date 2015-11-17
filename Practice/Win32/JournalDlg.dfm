object dlgJournal: TdlgJournal
  Left = 306
  Top = 201
  ActiveControl = tblJournal
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Enter Journal'
  ClientHeight = 511
  ClientWidth = 799
  Color = clBtnFace
  Constraints.MinHeight = 240
  Constraints.MinWidth = 800
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Shape7: TShape
    AlignWithMargins = True
    Left = 3
    Top = 88
    Width = 1
    Height = 321
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alLeft
    Pen.Color = clSilver
    ExplicitLeft = 0
    ExplicitTop = 98
    ExplicitHeight = 311
  end
  object Shape8: TShape
    AlignWithMargins = True
    Left = 795
    Top = 88
    Width = 1
    Height = 321
    Margins.Left = 0
    Margins.Top = 0
    Margins.Bottom = 0
    Align = alRight
    Pen.Color = clSilver
    ExplicitLeft = 734
    ExplicitTop = 98
    ExplicitHeight = 311
  end
  object stbJournal: TStatusBar
    AlignWithMargins = True
    Left = 3
    Top = 489
    Width = 793
    Height = 21
    Margins.Top = 0
    Margins.Bottom = 0
    Panels = <
      item
        Alignment = taCenter
        Text = 'C'
        Width = 200
      end
      item
        Text = '1 of 100'
        Width = 75
      end
      item
        Text = '309 - Bank Charges'
        Width = 250
      end
      item
        Text = 'Reversal dated dd/mm/yy'
        Width = 180
      end>
    ParentFont = True
    UseSystemFont = False
    OnMouseUp = stbJournalMouseUp
  end
  object tblJournal: TOvcTable
    Left = 4
    Top = 88
    Width = 791
    Height = 321
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    LockedCols = 0
    LeftCol = 0
    ActiveCol = 0
    Align = alClient
    BorderStyle = bsNone
    Color = clWindow
    Colors.ActiveUnfocused = clWindow
    Colors.ActiveUnfocusedText = clWindowText
    Colors.Editing = clWindow
    Controller = JournalController
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
    LockedRowsCell = hdrColumnHeadings
    Options = [otoEnterToArrow, otoNoSelection, otoThumbTrack]
    TabOrder = 1
    OnKeyDown = tblJournalKeyDown
    OnMouseDown = tblJournalMouseDown
    OnMouseUp = tblJournalMouseUp
    OnTopLeftCellChanging = tblJournalTopLeftCellChanging
    CellData = (
      'dlgJournal.hdrColumnHeadings')
    RowData = (
      21)
    ColData = (
      65
      False
      False)
  end
  object pnlTranDetails: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 793
    Height = 85
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      793
      85)
    object Shape1: TShape
      Left = 3
      Top = 20
      Width = 786
      Height = 30
      Anchors = [akLeft, akTop, akRight]
      Brush.Color = clWindow
      Shape = stRoundRect
      ExplicitWidth = 789
    end
    object Label1: TLabel
      Left = 47
      Top = 2
      Width = 23
      Height = 13
      Caption = 'Date'
      Transparent = True
    end
    object lbJournalType: TLabel
      Left = 113
      Top = 2
      Width = 62
      Height = 13
      Caption = 'Journal Type'
      Transparent = True
    end
    object btnChart: TSpeedButton
      Left = 3
      Top = 56
      Width = 80
      Height = 22
      Caption = 'Chart'
      Flat = True
      OnClick = btnChartClick
    end
    object lblStatus: TLabel
      Left = 433
      Top = 61
      Width = 73
      Height = 13
      Alignment = taCenter
      Caption = ' This journal... '
      Color = clHighlight
      ParentColor = False
      Visible = False
    end
    object btnPayee: TSpeedButton
      Left = 89
      Top = 56
      Width = 80
      Height = 22
      Caption = 'Payee'
      Flat = True
      OnClick = btnPayeeClick
    end
    object imgStatus: TImage
      Left = 16
      Top = 24
      Width = 20
      Height = 20
      Center = True
      Transparent = True
    end
    object lblDate: TLabel
      Left = 47
      Top = 28
      Width = 44
      Height = 13
      Caption = '13/11/01'
      Transparent = True
    end
    object lblJournalType: TLabel
      Left = 113
      Top = 28
      Width = 69
      Height = 13
      Caption = 'lblJournalType'
      Transparent = True
    end
    object sbtnSuper: TSpeedButton
      Left = 261
      Top = 56
      Width = 80
      Height = 22
      Caption = 'Super'
      Flat = True
      OnClick = sbtnSuperClick
    end
    object btnView: TRzToolButton
      Left = 347
      Top = 56
      Width = 80
      Height = 22
      DropDownMenu = popView
      ImageIndex = 8
      Images = AppImages.Coding
      ShowCaption = True
      UseToolbarButtonSize = False
      UseToolbarShowCaption = False
      ToolStyle = tsDropDown
      Caption = 'View'
    end
    object BtnJob: TSpeedButton
      Left = 175
      Top = 56
      Width = 80
      Height = 22
      Caption = 'Job'
      Flat = True
      OnClick = BtnJobClick
    end
    object Shape2: TShape
      Left = 0
      Top = 84
      Width = 793
      Height = 1
      Align = alBottom
      Pen.Color = clSilver
      ExplicitWidth = 799
    end
    object Shape4: TShape
      Left = 0
      Top = 0
      Width = 793
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 799
    end
    object Shape5: TShape
      Left = 0
      Top = 1
      Width = 1
      Height = 83
      Align = alLeft
      Pen.Color = clSilver
      ExplicitHeight = 93
    end
    object Shape6: TShape
      Left = 792
      Top = 1
      Width = 1
      Height = 83
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 728
      ExplicitHeight = 93
    end
    object Panel2: TPanel
      Left = 587
      Top = 53
      Width = 202
      Height = 25
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        202
        25)
      object tbPrevious: TRzToolButton
        Left = 3
        Top = 0
        Width = 95
        DropDownMenu = popPrevious
        ImageIndex = 1
        Images = AppImages.Misc
        ShowCaption = True
        UseToolbarButtonLayout = False
        UseToolbarButtonSize = False
        UseToolbarShowCaption = False
        ToolStyle = tsDropDown
        Anchors = [akTop, akRight]
        Caption = '&Back'
        PopupMenu = popPrevious
        OnClick = tbPreviousClick
        ExplicitLeft = 75
      end
      object tbNext: TRzToolButton
        Left = 104
        Top = 0
        Width = 95
        DropDownMenu = popNext
        ImageIndex = 2
        Images = AppImages.Misc
        Layout = blGlyphRight
        ShowCaption = True
        UseToolbarButtonLayout = False
        UseToolbarButtonSize = False
        UseToolbarShowCaption = False
        ToolStyle = tsDropDown
        Anchors = [akTop, akRight]
        Caption = '&Forward'
        PopupMenu = popNext
        OnClick = tbNextClick
        ExplicitLeft = 176
      end
    end
  end
  object pfHiddenAmount: TOvcPictureField
    Left = 527
    Top = 293
    Width = 89
    Height = 24
    Cursor = crIBeam
    DataType = pftDouble
    CaretOvr.Shape = csBlock
    Controller = JournalController
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
    MaxLength = 16
    Options = []
    ParentFont = False
    PictureMask = '#,###,###,###.##'
    TabOrder = 2
    Visible = False
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object pBottom: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 409
    Width = 793
    Height = 80
    Margins.Top = 0
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    DesignSize = (
      793
      80)
    object lblTotalLabel: TLabel
      Left = 8
      Top = 10
      Width = 31
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Total :'
      ExplicitTop = 6
    end
    object lblTotal: TLabel
      Left = 45
      Top = 6
      Width = 116
      Height = 17
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = '$0.00'
    end
    object lblTaxSystem: TLabel
      Left = 8
      Top = 29
      Width = 26
      Height = 13
      Caption = 'GST :'
    end
    object lblGST: TLabel
      Left = 77
      Top = 29
      Width = 84
      Height = 17
      Alignment = taRightJustify
      AutoSize = False
      Caption = '$0.00'
    end
    object Shape3: TShape
      Left = 0
      Top = 0
      Width = 793
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 799
    end
    object Shape9: TShape
      Left = 0
      Top = 1
      Width = 1
      Height = 79
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Pen.Color = clSilver
      ExplicitTop = 98
      ExplicitHeight = 311
    end
    object Shape10: TShape
      Left = 792
      Top = 1
      Width = 1
      Height = 79
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 734
      ExplicitTop = 98
      ExplicitHeight = 311
    end
    object chkProcessOnExit: TCheckBox
      Left = 175
      Top = 6
      Width = 230
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Generate Automatic Journals'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = chkProcessOnExitClick
    end
    object cbRepeat: TCheckBox
      Left = 175
      Top = 29
      Width = 230
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'And repeat Standing Journals until'
      TabOrder = 1
      OnClick = cbRepeatClick
    end
    object cmbReverseWhen: TComboBox
      Left = 411
      Top = 6
      Width = 165
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akBottom]
      ItemHeight = 13
      TabOrder = 2
    end
    object eDateUntil: TOvcPictureField
      Left = 411
      Top = 33
      Width = 68
      Height = 20
      Cursor = crIBeam
      DataType = pftDate
      Anchors = [akLeft, akBottom]
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      Controller = JournalController
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
      AfterEnter = eDateUntilAfterEnter
      OnDblClick = eDateUntilDblClick
      OnKeyDown = eDateUntilKeyDown
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object btnClear: TButton
      Left = 8
      Top = 52
      Width = 75
      Height = 25
      Caption = '&Clear'
      TabOrder = 4
      OnClick = btnClearClick
    end
    object btnOK: TButton
      Left = 630
      Top = 49
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      ModalResult = 1
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 711
      Top = 49
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
    end
    object BtnCal: TButton
      Left = 480
      Top = 33
      Width = 21
      Height = 20
      Caption = '...'
      TabOrder = 7
      OnClick = BtnCalClick
    end
  end
  object pnlLine: TPanel
    Left = 0
    Top = 510
    Width = 799
    Height = 1
    Align = alBottom
    TabOrder = 5
  end
  object JournalController: TOvcController
    EntryCommands.TableList = (
      'Grid'
      True
      ())
    Epoch = 1900
    Left = 536
    Top = 152
  end
  object hdrColumnHeadings: TOvcTCColHead
    Headings.Strings = (
      'None')
    ShowLetters = False
    Table = tblJournal
    Left = 160
    Top = 214
  end
  object celAccount: TOvcTCString
    MaxLength = 10
    Table = tblJournal
    OnExit = celAccountExit
    OnKeyDown = celAccountKeyDown
    OnKeyPress = celAccountKeyPress
    OnKeyUp = celAccountKeyUp
    OnOwnerDraw = celAccountOwnerDraw
    Left = 248
    Top = 152
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
    Table = tblJournal
    OnKeyPress = celAmountKeyPress
    OnOwnerDraw = celAmountOwnerDraw
    Left = 336
    Top = 152
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
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
    PictureMask = '###,###,###.##'
    Table = tblJournal
    OnChange = celGstAmtChange
    OnKeyPress = celGstAmtKeyPress
    OnOwnerDraw = celGstAmtOwnerDraw
    Left = 400
    Top = 152
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
    PictureMask = '###,###,###.####'
    Table = tblJournal
    OnChange = celQuantityChange
    OnExit = celQuantityExit
    Left = 432
    Top = 152
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celNarration: TOvcTCString
    AutoAdvanceChar = True
    MaxLength = 40
    Table = tblJournal
    Left = 464
    Top = 152
  end
  object popGST: TPopupMenu
    Left = 152
    Top = 152
    object mniRecalcGST: TMenuItem
      Caption = '&Recalculate GST'
      OnClick = mniRecalcGSTClick
    end
  end
  object celJnlLineType: TOvcTCComboBox
    AcceptActivationClick = False
    DropDownCount = 3
    MaxLength = 15
    Style = csDropDownList
    Table = tblJournal
    OnOwnerDraw = celJnlLineTypeOwnerDraw
    Left = 496
    Top = 152
  end
  object celMoneyIn: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [efoCaretToEnd]
    PictureMask = '###,###,###.##'
    TableFont = False
    Left = 336
    Top = 184
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celMoneyOut: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [efoCaretToEnd]
    PictureMask = '###,###,###.##'
    TableFont = False
    Left = 336
    Top = 216
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celGSTCode: TOvcTCString
    MaxLength = 3
    OnOwnerDraw = celGSTCodeOwnerDraw
    Left = 368
    Top = 152
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
    Left = 448
    Top = 185
    RangeHigh = {3F420F00000000000000}
    RangeLow = {00000000000000000000}
  end
  object popPrevious: TPopupMenu
    Left = 524
    Top = 84
    object Previousjournal1: TMenuItem
      Caption = 'Back'
      OnClick = tbPreviousClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Back1month1: TMenuItem
      Caption = 'Back to Previous Month end'
      OnClick = Back1month1Click
    end
    object Back2months1: TMenuItem
      Caption = 'Back 2 Months'
      OnClick = Back2months1Click
    end
    object Back3months1: TMenuItem
      Caption = 'Back 3 Months'
      OnClick = Back3months1Click
    end
    object Back5months1: TMenuItem
      Caption = 'Back 5 Months'
      OnClick = Back5months1Click
    end
    object Back6months1: TMenuItem
      Caption = 'Back 6 Months'
      OnClick = Back6months1Click
    end
    object Back11months1: TMenuItem
      Caption = 'Back 11 Months'
      OnClick = Back11months1Click
    end
  end
  object popNext: TPopupMenu
    Left = 556
    Top = 84
    object Nextjournal1: TMenuItem
      Caption = 'Forward'
      OnClick = tbNextClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Forward1month1: TMenuItem
      Caption = 'Forward to Next Month end'
      OnClick = Forward1month1Click
    end
    object Forward2months1: TMenuItem
      Caption = 'Forward 2 Months'
      OnClick = Forward2months1Click
    end
    object Forward3months1: TMenuItem
      Caption = 'Forward 3 Months'
      OnClick = Forward3months1Click
    end
    object Forward5months1: TMenuItem
      Caption = 'Forward 5 Months'
      OnClick = Forward5months1Click
    end
    object Forward6months1: TMenuItem
      Caption = 'Forward 6 Months'
      OnClick = Forward6months1Click
    end
    object Forward11months1: TMenuItem
      Caption = 'Forward 12 Months'
      OnClick = Forward11months1Click
    end
  end
  object popJournal: TPopupMenu
    Images = AppImages.Coding
    Left = 192
    Top = 152
    object LookupChart1: TMenuItem
      Caption = '&Lookup Chart                                         F2'
      ImageIndex = 0
      OnClick = LookupChart1Click
    end
    object LookupPayee1: TMenuItem
      Caption = 'Lookup &Payee                                        F3'
      ImageIndex = 1
      OnClick = LookupPayee1Click
    end
    object LookupJobF51: TMenuItem
      Caption = 'Lookup J&ob                                            F5'
      ImageIndex = 18
      OnClick = BtnJobClick
    end
    object LookupGSTClass1: TMenuItem
      Caption = 'Lookup &GST Class                                  F7'
      OnClick = LookupGSTClass1Click
    end
    object EditSuperFields1: TMenuItem
      Caption = 'Edit &Superfund Details                          F11'
      ImageIndex = 11
      OnClick = EditSuperFields1Click
    end
    object ClearSuperfundDetails1: TMenuItem
      Caption = 'Clear Superfund Details'
      OnClick = ClearSuperfundDetails1Click
    end
    object Sep1: TMenuItem
      Caption = '-'
    end
    object GotoNextUncoded1: TMenuItem
      Caption = 'Goto &Next Uncoded                               F8'
      ImageIndex = 5
      OnClick = GotoNextUncoded1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Configurecoulmns1: TMenuItem
      Caption = '&Configure Columns'
      OnClick = mniConfigureColsClick
    end
    object Restorecolumndefaultas1: TMenuItem
      Caption = '&Restore Column Defaults'
      OnClick = mniRestoreColsClick
    end
    object Sep2: TMenuItem
      Caption = '-'
    end
    object Insertanewline1: TMenuItem
      Caption = '&Insert a New Line                                   Shift+Ins'
      OnClick = Insertanewline1Click
    end
    object CopyContentoftheCellAbove1: TMenuItem
      Caption = 'C&opy Contents of the Cell Above           +'
      ImageIndex = 6
      OnClick = CopyContentoftheCellAbove1Click
    end
    object Amount1: TMenuItem
      Caption = 'Amount'
      object AmountApplyRemainingAmount1: TMenuItem
        Caption = 'Appl&y Remaining Amount            ='
        OnClick = AmountApplyRemainingAmount1Click
      end
      object AmountGrossupfromGSTAmount1: TMenuItem
        Caption = '&Gross-up from GST Amount         *'
        OnClick = AmountGrossupfromGSTAmount1Click
      end
      object AmountGrossupfromNetAmount1: TMenuItem
        Caption = 'G&ross-up from Net Amount         @'
        OnClick = AmountGrossupfromNetAmount1Click
      end
    end
  end
  object CelReference: TOvcTCString
    MaxLength = 12
    Table = tblJournal
    Left = 296
    Top = 152
  end
  object popView: TPopupMenu
    OnPopup = popViewPopup
    Left = 96
    Top = 184
    object EditCodesOnly1: TMenuItem
      Caption = 'Edit A&ccounts and Amounts Only'
      OnClick = EditCodesOnly1Click
    end
    object EditAllColumns1: TMenuItem
      Caption = 'E&dit All Columns'
      OnClick = EditAllColumns1Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object mniConfigureCols: TMenuItem
      Caption = 'C&onfigure Columns'
      GroupIndex = 3
      OnClick = mniConfigureColsClick
    end
    object mniRestoreCols: TMenuItem
      Caption = '&Restore Column Defaults'
      GroupIndex = 3
      OnClick = mniRestoreColsClick
    end
  end
  object celDescription: TOvcTCString
    Adjust = otaCenterLeft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxLength = 10
    ShowHint = True
    TableFont = False
    Left = 240
    Top = 257
  end
  object celPayeeName: TOvcTCString
    Adjust = otaCenterLeft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    MaxLength = 10
    ShowHint = True
    TableFont = False
    Left = 432
    Top = 289
  end
  object tmrPayee: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrPayeeTimer
    Left = 376
    Top = 112
  end
  object celJob: TOvcTCString
    AutoAdvanceChar = True
    MaxLength = 40
    Table = tblJournal
    Left = 392
    Top = 192
  end
  object CelJobName: TOvcTCString
    AutoAdvanceChar = True
    MaxLength = 40
    Table = tblJournal
    Left = 392
    Top = 216
  end
  object CelAltChartCode: TOvcTCString
    MaxLength = 200
    Left = 496
    Top = 192
  end
end
