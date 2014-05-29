object dlgMemorise: TdlgMemorise
  Left = 345
  Top = 246
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Memorise Transaction'
  ClientHeight = 514
  ClientWidth = 746
  Color = clBtnFace
  Constraints.MinHeight = 450
  Constraints.MinWidth = 570
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 746
    Height = 230
    Align = alTop
    Caption = '  Match On  '
    TabOrder = 0
    DesignSize = (
      746
      230)
    object lblType: TLabel
      Left = 170
      Top = 23
      Width = 60
      Height = 13
      Caption = '50: Deposits'
    end
    object Label1: TLabel
      Left = 27
      Top = 23
      Width = 53
      Height = 13
      Caption = 'Entry Type'
    end
    object eRef: TEdit
      Left = 170
      Top = 44
      Width = 209
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      MaxLength = 12
      TabOrder = 2
      Text = 'eRef'
    end
    object ePart: TEdit
      Left = 170
      Top = 145
      Width = 337
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      MaxLength = 12
      TabOrder = 10
      Text = 'ePart'
    end
    object eOther: TEdit
      Left = 170
      Top = 119
      Width = 337
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      MaxLength = 20
      TabOrder = 8
      Text = 'eOther'
    end
    object eCode: TEdit
      Left = 170
      Top = 69
      Width = 209
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      MaxLength = 12
      TabOrder = 4
      Text = 'eCode'
    end
    object cRef: TCheckBox
      Left = 25
      Top = 46
      Width = 129
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Reference'
      TabOrder = 1
      OnClick = cRefClick
    end
    object cPart: TCheckBox
      Left = 25
      Top = 147
      Width = 129
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Particulars'
      TabOrder = 9
      OnClick = cPartClick
    end
    object cOther: TCheckBox
      Left = 25
      Top = 121
      Width = 129
      Height = 17
      Alignment = taLeftJustify
      Caption = 'O&ther Party'
      TabOrder = 7
      OnClick = cOtherClick
    end
    object cCode: TCheckBox
      Left = 25
      Top = 71
      Width = 129
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Analysis Code'
      TabOrder = 3
      OnClick = cCodeClick
    end
    object cmbValue: TComboBox
      Left = 170
      Top = 195
      Width = 177
      Height = 21
      Style = csDropDownList
      Ctl3D = False
      Enabled = False
      ItemHeight = 0
      ParentCtl3D = False
      TabOrder = 14
      OnChange = cmbValueChange
    end
    object nValue: TOvcNumericField
      Left = 374
      Top = 196
      Width = 113
      Height = 22
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      Controller = memController
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Enabled = False
      Options = []
      PictureMask = '###,###,###.##'
      TabOrder = 15
      OnChange = nValueChange
      OnKeyPress = nValueKeyPress
      RangeHigh = {73B2DBB9838916F2FE43}
      RangeLow = {73B2DBB9838916F2FEC3}
    end
    object cEntry: TCheckBox
      Left = 122
      Top = 22
      Width = 32
      Height = 18
      Alignment = taLeftJustify
      Checked = True
      Enabled = False
      State = cbChecked
      TabOrder = 0
    end
    object cNotes: TCheckBox
      Left = 25
      Top = 172
      Width = 129
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Notes'
      TabOrder = 11
      OnClick = cNotesClick
    end
    object eNotes: TEdit
      Left = 170
      Top = 170
      Width = 337
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      MaxLength = 40
      TabOrder = 12
      Text = 'eCode'
    end
    object chkStatementDetails: TCheckBox
      Left = 25
      Top = 96
      Width = 129
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Statement Details'
      TabOrder = 5
      OnClick = chkStatementDetailsClick
    end
    object eStatementDetails: TEdit
      Left = 170
      Top = 94
      Width = 567
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      BorderStyle = bsNone
      Enabled = False
      MaxLength = 100
      TabOrder = 6
      Text = 'eStatement Details'
    end
    object cValue: TCheckBox
      Left = 25
      Top = 197
      Width = 129
      Height = 22
      Alignment = taLeftJustify
      Caption = '&Value'
      TabOrder = 13
      OnClick = cValueClick
    end
    object eDateFrom: TOvcPictureField
      Left = 667
      Top = 17
      Width = 70
      Height = 20
      Cursor = crIBeam
      DataType = pftDate
      Anchors = [akTop, akRight]
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      Controller = memController
      ControlCharColor = clRed
      DecimalPlaces = 0
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Enabled = False
      Epoch = 0
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
      PictureMask = 'DD/mm/yy'
      TabOrder = 17
      OnDblClick = eDateFromDblClick
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object eDateTo: TOvcPictureField
      Left = 667
      Top = 43
      Width = 70
      Height = 20
      Cursor = crIBeam
      DataType = pftDate
      Anchors = [akTop, akRight]
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      Controller = memController
      ControlCharColor = clRed
      DecimalPlaces = 0
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Enabled = False
      Epoch = 0
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
      PictureMask = 'DD/mm/yy'
      TabOrder = 18
      OnDblClick = eDateFromDblClick
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object cbFrom: TCheckBox
      Left = 571
      Top = 22
      Width = 96
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Applies from'
      TabOrder = 19
      OnClick = cbFromClick
    end
    object cbTo: TCheckBox
      Left = 571
      Top = 46
      Width = 96
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Applies to'
      TabOrder = 20
      OnClick = cbToClick
    end
    object cbMinus: TComboBox
      Left = 493
      Top = 196
      Width = 53
      Height = 21
      Enabled = False
      ItemHeight = 13
      TabOrder = 16
      OnChange = cbMinusChange
      Items.Strings = (
        'CR'
        'DR')
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 230
    Width = 746
    Height = 213
    Align = alClient
    BevelOuter = bvLowered
    BorderWidth = 5
    TabOrder = 1
    object ToolBar: TPanel
      AlignWithMargins = True
      Left = 6
      Top = 6
      Width = 734
      Height = 26
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 5
      Align = alTop
      AutoSize = True
      BevelOuter = bvNone
      TabOrder = 1
      object sbtnPayee: TSpeedButton
        AlignWithMargins = True
        Left = 74
        Top = 2
        Width = 65
        Height = 22
        Margins.Top = 2
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Payee'
        Flat = True
        OnClick = sbtnPayeeClick
        ExplicitLeft = 0
        ExplicitTop = 0
      end
      object sbtnChart: TSpeedButton
        AlignWithMargins = True
        Left = 3
        Top = 2
        Width = 65
        Height = 22
        Margins.Top = 2
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Chart'
        Flat = True
        OnClick = sbtnChartClick
        ExplicitTop = 4
      end
      object sbtnJob: TSpeedButton
        AlignWithMargins = True
        Left = 145
        Top = 2
        Width = 65
        Height = 22
        Margins.Top = 2
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Job'
        Flat = True
        OnClick = sbtnJobClick
      end
      object sbtnSuper: TSpeedButton
        AlignWithMargins = True
        Left = 216
        Top = 2
        Width = 65
        Height = 22
        Margins.Top = 2
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Super'
        Flat = True
        OnClick = sbtnSuperClick
        ExplicitTop = 4
      end
      object chkMaster: TCheckBox
        AlignWithMargins = True
        Left = 287
        Top = 2
        Width = 141
        Height = 22
        Margins.Top = 2
        Margins.Bottom = 2
        Align = alLeft
        Caption = '&Memorise to MASTER'
        TabOrder = 0
        OnClick = chkMasterClick
      end
      object chkAccountSystem: TCheckBox
        AlignWithMargins = True
        Left = 434
        Top = 2
        Width = 114
        Height = 22
        Margins.Top = 2
        Margins.Bottom = 2
        Align = alLeft
        Caption = 'Only Apply to :'
        TabOrder = 1
        OnClick = chkAccountSystemClick
      end
      object cbAccounting: TComboBox
        AlignWithMargins = True
        Left = 554
        Top = 1
        Width = 177
        Height = 21
        Margins.Top = 1
        Margins.Bottom = 1
        Align = alClient
        Style = csDropDownList
        ItemHeight = 0
        Sorted = True
        TabOrder = 2
      end
    end
    object tblSplit: TOvcTable
      Left = 6
      Top = 37
      Width = 734
      Height = 170
      RowLimit = 6
      LockedCols = 0
      LeftCol = 0
      ActiveCol = 0
      Align = alClient
      Color = clWindow
      Colors.ActiveUnfocused = clWindow
      Colors.ActiveUnfocusedText = clWindowText
      Colors.Editing = clWindow
      Controller = memController
      Ctl3D = False
      GridPenSet.NormalGrid.NormalColor = clBtnShadow
      GridPenSet.NormalGrid.Style = psSolid
      GridPenSet.NormalGrid.Effect = ge3D
      GridPenSet.LockedGrid.NormalColor = clBtnShadow
      GridPenSet.LockedGrid.Style = psSolid
      GridPenSet.LockedGrid.Effect = geBoth
      GridPenSet.CellWhenFocused.NormalColor = clBlack
      GridPenSet.CellWhenFocused.Style = psSolid
      GridPenSet.CellWhenFocused.Effect = geBoth
      GridPenSet.CellWhenUnfocused.NormalColor = clBlack
      GridPenSet.CellWhenUnfocused.Style = psDash
      GridPenSet.CellWhenUnfocused.Effect = geNone
      LockedRowsCell = Header
      Options = [otoNoRowResizing, otoEnterToArrow, otoNoSelection]
      ParentCtl3D = False
      TabOrder = 0
      OnActiveCellChanged = tblSplitActiveCellChanged
      OnActiveCellMoving = tblSplitActiveCellMoving
      OnBeginEdit = tblSplitBeginEdit
      OnDoneEdit = tblSplitDoneEdit
      OnEndEdit = tblSplitEndEdit
      OnEnter = tblSplitEnter
      OnEnteringRow = tblSplitEnteringRow
      OnExit = tblSplitExit
      OnGetCellData = tblSplitGetCellData
      OnGetCellAttributes = tblSplitGetCellAttributes
      OnMouseDown = tblSplitMouseDown
      OnUserCommand = tblSplitUserCommand
      CellData = (
        'dlgMemorise.Header')
      RowData = (
        21)
      ColData = (
        86
        False
        True
        'dlgMemorise.ColAcct'
        172
        False
        True
        'dlgMemorise.ColDesc'
        145
        False
        True
        'dlgMemorise.colNarration'
        45
        False
        True
        'dlgMemorise.ColPayee'
        86
        False
        True
        'dlgMemorise.colJob'
        45
        False
        True
        'dlgMemorise.ColGSTCode'
        100
        False
        True
        'dlgMemorise.ColAmount'
        100
        False
        True
        'dlgMemorise.ColPercent'
        45
        False
        True
        'dlgMemorise.colLineType')
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 443
    Width = 746
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      746
      50)
    object btnOK: TButton
      Left = 587
      Top = 20
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 667
      Top = 20
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
    object Panel4: TPanel
      Left = 3
      Top = 3
      Width = 442
      Height = 46
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 0
      object lblAmountHdr: TLabel
        Left = 13
        Top = 8
        Width = 37
        Height = 13
        Caption = 'Amount'
      end
      object lblFixedHdr: TLabel
        Left = 117
        Top = 8
        Width = 35
        Height = 13
        Caption = 'Fixed $'
      end
      object lblRemDollarHdr: TLabel
        Left = 219
        Top = 8
        Width = 30
        Height = 13
        Caption = 'Rem $'
      end
      object lblTotalPercHdr: TLabel
        Left = 322
        Top = 8
        Width = 38
        Height = 13
        Alignment = taRightJustify
        Caption = 'Total %'
      end
      object lblRemPercHdr: TLabel
        Left = 399
        Top = 8
        Width = 35
        Height = 13
        Alignment = taRightJustify
        Caption = 'Rem %'
      end
      object lblRemPerc: TLabel
        Left = 397
        Top = 24
        Width = 35
        Height = 13
        Alignment = taRightJustify
        Caption = '1000%'
      end
      object lblTotalPerc: TLabel
        Left = 325
        Top = 24
        Width = 35
        Height = 13
        Alignment = taRightJustify
        Caption = '1000%'
      end
      object lblRemDollar: TLabel
        Left = 219
        Top = 24
        Width = 84
        Height = 13
        Caption = '$999,999,999.00'
      end
      object lblFixed: TLabel
        Left = 116
        Top = 24
        Width = 84
        Height = 13
        Caption = '$999,999,999.00'
      end
      object lblAmount: TLabel
        Left = 12
        Top = 24
        Width = 84
        Height = 13
        Caption = '$999,999,999.00'
      end
    end
    object btnCopy: TButton
      Left = 492
      Top = 19
      Width = 89
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Copy to New'
      TabOrder = 3
      OnClick = btnCopyClick
    end
  end
  object sBar: TStatusBar
    Left = 0
    Top = 493
    Width = 746
    Height = 21
    Panels = <
      item
        Text = '1 of 100'
        Width = 75
      end>
    ParentFont = True
    UseSystemFont = False
  end
  object memController: TOvcController
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
    Left = 216
    Top = 312
  end
  object ColAmount: TOvcTCNumericField
    Adjust = otaCenterRight
    Color = clWindow
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '###,###,###.##'
    Table = tblSplit
    TableColor = False
    OnKeyPress = ColAmountKeyPress
    Left = 424
    Top = 336
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object ColDesc: TOvcTCString
    Adjust = otaCenterLeft
    Color = clWindow
    Table = tblSplit
    TableColor = False
    Left = 264
    Top = 336
  end
  object ColAcct: TOvcTCString
    Adjust = otaCenterLeft
    AutoAdvanceLeftRight = True
    MaxLength = 10
    Table = tblSplit
    OnExit = ColAcctExit
    OnKeyDown = ColAcctKeyDown
    OnKeyPress = ColAcctKeyPress
    OnKeyUp = ColAcctKeyUp
    OnOwnerDraw = ColAcctOwnerDraw
    Left = 224
    Top = 336
  end
  object ColGSTCode: TOvcTCString
    MaxLength = 3
    Table = tblSplit
    OnKeyDown = ColGSTCodeKeyDown
    OnOwnerDraw = ColGSTCodeOwnerDraw
    Left = 392
    Top = 336
  end
  object Header: TOvcTCColHead
    Headings.Strings = (
      'Code'
      'Account Description'
      'Narration'
      'Payee'
      'Job'
      'GST'
      'Amount'
      'Percent'
      '%/$')
    ShowLetters = False
    Table = tblSplit
    Left = 192
    Top = 336
  end
  object colNarration: TOvcTCString
    MaxLength = 200
    Table = tblSplit
    Left = 296
    Top = 336
  end
  object colLineType: TOvcTCComboBox
    AcceptActivationClick = False
    DropDownCount = 2
    HideButton = True
    MaxLength = 1
    Style = csDropDownList
    Table = tblSplit
    Left = 328
    Top = 304
  end
  object popMem: TPopupMenu
    Images = AppImages.Coding
    OnPopup = popMemPopup
    Left = 568
    Top = 64
    object LookupChart1: TMenuItem
      Caption = '&Lookup Chart                                        F2'
      ImageIndex = 0
      OnClick = sbtnChartClick
    end
    object LookupPayee1: TMenuItem
      Caption = 'Lookup &Payee                                      F3'
      ImageIndex = 1
      OnClick = sbtnPayeeClick
    end
    object LookupJob1: TMenuItem
      Caption = 'Lookup &Job                                          F5'
      OnClick = sbtnJobClick
    end
    object LookupGSTClass1: TMenuItem
      Caption = 'Lookup &GST class                                 F7'
      OnClick = LookupGSTClass1Click
    end
    object EditSuperfundDetails1: TMenuItem
      Caption = 'Edit Superfund Details                           F11'
      ImageIndex = 11
      OnClick = sbtnSuperClick
    end
    object ClearSuperfundDetails1: TMenuItem
      Caption = 'Clear Superfund Details'
      OnClick = ClearSuperfundDetails1Click
    end
    object Sep1: TMenuItem
      Caption = '-'
    end
    object FixedAmount1: TMenuItem
      Caption = 'Apply &fixed amount                             $'
      OnClick = FixedAmount1Click
    end
    object PercentageofTotal1: TMenuItem
      Caption = 'Apply percentage &split                        %'
      OnClick = PercentageofTotal1Click
    end
    object AmountApplyRemainingAmount1: TMenuItem
      Caption = 'Appl&y remaining                                   ='
      OnClick = AmountApplyRemainingAmount1Click
    end
    object Sep2: TMenuItem
      Caption = '-'
    end
    object CopyContentoftheCellAbove1: TMenuItem
      Caption = 'C&opy contents of the cell above          +'
      ImageIndex = 6
      OnClick = CopyContentoftheCellAbove1Click
    end
  end
  object ColPayee: TOvcTCNumericField
    Adjust = otaCenterLeft
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '999999'
    ShowHint = True
    Table = tblSplit
    OnKeyDown = ColPayeeKeyDown
    OnOwnerDraw = ColPayeeOwnerDraw
    Left = 328
    Top = 337
    RangeHigh = {3F420F00000000000000}
    RangeLow = {00000000000000000000}
  end
  object ColPercent: TOvcTCNumericField
    Adjust = otaCenterRight
    Color = clWindow
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '###,###,###.####'
    Table = tblSplit
    TableColor = False
    OnKeyPress = ColAmountKeyPress
    Left = 456
    Top = 336
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object colJob: TOvcTCString
    MaxLength = 8
    Table = tblSplit
    Left = 360
    Top = 336
  end
  object Rowtmr: TTimer
    Enabled = False
    Interval = 100
    OnTimer = RowtmrTimer
    Left = 40
    Top = 280
  end
end
