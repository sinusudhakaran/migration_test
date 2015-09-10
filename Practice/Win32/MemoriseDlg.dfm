object dlgMemorise: TdlgMemorise
  Left = 345
  Top = 246
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Memorise Transaction'
  ClientHeight = 730
  ClientWidth = 1008
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
    Width = 1008
    Height = 182
    Align = alTop
    Caption = '  Match On  '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      1008
      182)
    object eRef: TEdit
      Left = 139
      Top = 95
      Width = 209
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 12
      ParentFont = False
      TabOrder = 3
      Text = 'eRef'
    end
    object ePart: TEdit
      Left = 498
      Top = 98
      Width = 262
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 12
      ParentFont = False
      TabOrder = 11
      Text = 'ePart'
    end
    object eOther: TEdit
      Left = 139
      Top = 122
      Width = 209
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 20
      ParentFont = False
      TabOrder = 9
      Text = 'eOther'
    end
    object eCode: TEdit
      Left = 139
      Top = 149
      Width = 209
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 12
      ParentFont = False
      TabOrder = 5
      Text = 'eCode'
    end
    object cRef: TCheckBox
      Left = 3
      Top = 99
      Width = 130
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Reference'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = cRefClick
    end
    object cPart: TCheckBox
      Left = 382
      Top = 97
      Width = 96
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Particulars'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 10
      OnClick = cPartClick
    end
    object cOther: TCheckBox
      Left = 3
      Top = 126
      Width = 130
      Height = 17
      Alignment = taLeftJustify
      Caption = 'O&ther Party'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 8
      OnClick = cOtherClick
    end
    object cCode: TCheckBox
      Left = 3
      Top = 149
      Width = 130
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Analysis Code'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = cCodeClick
    end
    object cmbValue: TComboBox
      Left = 498
      Top = 68
      Width = 143
      Height = 24
      Style = csDropDownList
      Ctl3D = False
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 16
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 15
      OnChange = cmbValueChange
    end
    object nValue: TOvcNumericField
      Left = 647
      Top = 70
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
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = []
      ParentFont = False
      PictureMask = '###,###,###.##'
      TabOrder = 16
      OnChange = nValueChange
      OnKeyPress = nValueKeyPress
      RangeHigh = {73B2DBB9838916F2FE43}
      RangeLow = {73B2DBB9838916F2FEC3}
    end
    object cEntry: TCheckBox
      Left = 3
      Top = 22
      Width = 130
      Height = 18
      Alignment = taLeftJustify
      Caption = 'Entry Type'
      Checked = True
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      State = cbChecked
      TabOrder = 0
    end
    object cNotes: TCheckBox
      Left = 382
      Top = 120
      Width = 96
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Notes'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 12
      OnClick = cNotesClick
    end
    object eNotes: TEdit
      Left = 498
      Top = 125
      Width = 262
      Height = 21
      BorderStyle = bsNone
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 40
      ParentFont = False
      TabOrder = 13
      Text = 'eCode'
    end
    object chkStatementDetails: TCheckBox
      Left = 3
      Top = 46
      Width = 130
      Height = 17
      Alignment = taLeftJustify
      Caption = '&Statement Details'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      OnClick = chkStatementDetailsClick
    end
    object eStatementDetails: TEdit
      Left = 139
      Top = 47
      Width = 209
      Height = 42
      Anchors = [akLeft, akTop, akRight]
      BorderStyle = bsNone
      Enabled = False
      MaxLength = 100
      TabOrder = 7
      Text = 'eStatement Details'
    end
    object cValue: TCheckBox
      Left = 382
      Top = 69
      Width = 96
      Height = 22
      Alignment = taLeftJustify
      Caption = '&Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 14
      OnClick = cValueClick
    end
    object eDateFrom: TOvcPictureField
      Left = 498
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
      TabOrder = 19
      OnDblClick = eDateFromDblClick
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object eDateTo: TOvcPictureField
      Left = 498
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
      TabOrder = 21
      OnDblClick = eDateFromDblClick
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object cbFrom: TCheckBox
      Left = 382
      Top = 21
      Width = 96
      Height = 17
      Alignment = taLeftJustify
      Anchors = [akTop, akRight]
      Caption = 'Applies from'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 18
      OnClick = cbFromClick
    end
    object cbTo: TCheckBox
      Left = 382
      Top = 46
      Width = 96
      Height = 17
      Alignment = taLeftJustify
      Anchors = [akTop, akRight]
      Caption = 'Applies to'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 20
      OnClick = cbToClick
    end
    object cbMinus: TComboBox
      Left = 766
      Top = 68
      Width = 53
      Height = 24
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 16
      ParentFont = False
      TabOrder = 17
      OnChange = cbMinusChange
      Items.Strings = (
        'CR'
        'DR')
    end
    object cmbType: TComboBox
      Left = 139
      Top = 17
      Width = 209
      Height = 24
      Style = csDropDownList
      ItemHeight = 16
      TabOrder = 1
    end
    object Button1: TButton
      Left = 869
      Top = 68
      Width = 129
      Height = 25
      Caption = 'Show more options'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 22
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 671
    Width = 1008
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      1008
      38)
    object btnOK: TButton
      Left = 849
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 929
      Top = 8
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
      ParentFont = False
      TabOrder = 2
      OnClick = btnCancelClick
    end
    object btnCopy: TButton
      Left = 754
      Top = 8
      Width = 89
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Copy'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnCopyClick
    end
  end
  object sBar: TStatusBar
    Left = 0
    Top = 709
    Width = 1008
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Panels = <
      item
        Text = '1 of 100'
        Width = 75
      end>
    UseSystemFont = False
  end
  object pnlMain: TPanel
    Left = 0
    Top = 182
    Width = 1008
    Height = 489
    Align = alClient
    TabOrder = 3
    object Splitter: TSplitter
      Left = 1
      Top = 233
      Width = 1006
      Height = 3
      Cursor = crVSplit
      Align = alTop
      Beveled = True
    end
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 1006
      Height = 232
      Align = alTop
      BevelOuter = bvLowered
      BorderWidth = 5
      TabOrder = 0
      DesignSize = (
        1006
        232)
      object lblFixedHdr: TLabel
        Left = 222
        Top = 204
        Width = 41
        Height = 16
        Caption = 'Fixed $'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblFixed: TLabel
        Left = 272
        Top = 204
        Width = 96
        Height = 16
        Caption = '$999,999,999.00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblRemDollar: TLabel
        Left = 55
        Top = 204
        Width = 96
        Height = 16
        Caption = '$999,999,999.00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblRemDollarHdr: TLabel
        Left = 12
        Top = 202
        Width = 37
        Height = 16
        Caption = 'Rem $'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object ToolBar: TPanel
        AlignWithMargins = True
        Left = 6
        Top = 6
        Width = 994
        Height = 26
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 5
        Align = alTop
        AutoSize = True
        BevelOuter = bvNone
        TabOrder = 0
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
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
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
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
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
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
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
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
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
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
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
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = chkAccountSystemClick
        end
        object cbAccounting: TComboBox
          AlignWithMargins = True
          Left = 554
          Top = 1
          Width = 437
          Height = 24
          Margins.Top = 1
          Margins.Bottom = 1
          Align = alClient
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 16
          ParentFont = False
          Sorted = True
          TabOrder = 2
        end
      end
      object tblSplit: TOvcTable
        Left = 6
        Top = 37
        Width = 991
        Height = 161
        RowLimit = 6
        LockedCols = 0
        LeftCol = 0
        ActiveCol = 0
        Anchors = [akLeft, akTop, akRight, akBottom]
        Color = clWindow
        Colors.ActiveUnfocused = clWindow
        Colors.ActiveUnfocusedText = clWindowText
        Colors.Editing = clWindow
        Controller = memController
        Ctl3D = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
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
        Options = [otoNoRowResizing, otoEnterToArrow, otoNoSelection]
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 1
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
          'dlgMemorise.colLineType'
          'dlgMemorise.ColPercent'
          'dlgMemorise.ColAmount'
          'dlgMemorise.ColGSTCode'
          'dlgMemorise.colJob'
          'dlgMemorise.ColPayee'
          'dlgMemorise.colNarration'
          'dlgMemorise.ColDesc'
          'dlgMemorise.ColAcct'
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
      object Panel4: TPanel
        Left = 568
        Top = 204
        Width = 432
        Height = 25
        Anchors = [akRight, akBottom]
        BevelInner = bvRaised
        BevelOuter = bvLowered
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = 27
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        object lblAmountHdr: TLabel
          Left = 4
          Top = 4
          Width = 44
          Height = 16
          Caption = 'Amount'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblTotalPercHdr: TLabel
          Left = 156
          Top = 4
          Width = 45
          Height = 16
          Alignment = taRightJustify
          Caption = 'Total %'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblRemPercHdr: TLabel
          Left = 277
          Top = 4
          Width = 76
          Height = 16
          Alignment = taRightJustify
          Caption = 'Remaining %'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblRemPerc: TLabel
          Left = 383
          Top = 4
          Width = 40
          Height = 16
          Alignment = taRightJustify
          Caption = '1000%'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblTotalPerc: TLabel
          Left = 231
          Top = 4
          Width = 40
          Height = 16
          Alignment = taRightJustify
          Caption = '1000%'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblAmount: TLabel
          Left = 54
          Top = 4
          Width = 96
          Height = 16
          Caption = '$999,999,999.00'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
    end
    object tblTran: TOvcTable
      Left = 1
      Top = 236
      Width = 1006
      Height = 252
      RowLimit = 2
      LockedCols = 0
      LeftCol = 0
      Align = alClient
      Color = clWindow
      Colors.ActiveUnfocused = clWindow
      Colors.ActiveUnfocusedText = clWindowText
      Colors.Editing = clWindow
      Controller = tranController
      Ctl3D = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
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
      Options = [otoNoRowResizing, otoEnterToArrow, otoNoSelection]
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 1
      CellData = ()
      RowData = (
        21)
      ColData = (
        150
        False
        False
        150
        False
        False
        150
        False
        False
        150
        False
        False
        150
        False
        False
        150
        False
        False
        150
        False
        False
        150
        False
        False
        150
        False
        False
        150
        False
        False)
    end
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
    Left = 280
    Top = 336
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
    Options = [efoCaretToEnd]
    PictureMask = '###,###,###.##'
    Table = tblSplit
    TableColor = False
    OnKeyPress = ColAmountKeyPress
    Left = 488
    Top = 360
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object ColDesc: TOvcTCString
    Adjust = otaCenterLeft
    Color = clWindow
    Table = tblSplit
    TableColor = False
    Left = 328
    Top = 360
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
    Left = 288
    Top = 360
  end
  object ColGSTCode: TOvcTCString
    MaxLength = 3
    Table = tblSplit
    OnKeyDown = ColGSTCodeKeyDown
    OnOwnerDraw = ColGSTCodeOwnerDraw
    Left = 456
    Top = 360
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
    Left = 256
    Top = 360
  end
  object colNarration: TOvcTCString
    MaxLength = 200
    Table = tblSplit
    Left = 360
    Top = 360
  end
  object colLineType: TOvcTCComboBox
    AcceptActivationClick = False
    DropDownCount = 2
    HideButton = True
    MaxLength = 1
    Style = csDropDownList
    Table = tblSplit
    Left = 392
    Top = 328
  end
  object popMem: TPopupMenu
    Images = AppImages.Coding
    OnPopup = popMemPopup
    Left = 704
    Top = 328
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
      ImageIndex = 18
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
    Options = [efoCaretToEnd, efoTrimBlanks]
    PictureMask = '999999'
    ShowHint = True
    Table = tblSplit
    OnKeyDown = ColPayeeKeyDown
    OnOwnerDraw = ColPayeeOwnerDraw
    Left = 392
    Top = 361
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
    PictureMask = '###,###,###.####'
    Table = tblSplit
    TableColor = False
    OnKeyPress = ColAmountKeyPress
    Left = 520
    Top = 360
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object colJob: TOvcTCString
    MaxLength = 8
    Table = tblSplit
    Left = 424
    Top = 360
  end
  object Rowtmr: TTimer
    Enabled = False
    Interval = 100
    OnTimer = RowtmrTimer
    Left = 104
    Top = 304
  end
  object tmrPayee: TTimer
    Interval = 30
    OnTimer = tmrPayeeTimer
    Left = 640
    Top = 328
  end
  object tranController: TOvcController
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
    Left = 280
    Top = 488
  end
end
