object dlgMemorise: TdlgMemorise
  Left = 345
  Top = 246
  ActiveControl = cRef
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Memorise Transaction'
  ClientHeight = 812
  ClientWidth = 1069
  Color = clBtnFace
  Constraints.MinHeight = 565
  Constraints.MinWidth = 850
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 776
    Width = 1069
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      1069
      36)
    object btnOK: TButton
      Left = 906
      Top = 6
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
      TabOrder = 2
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 987
      Top = 6
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
      TabOrder = 3
      OnClick = btnCancelClick
    end
    object btnCopy: TButton
      Left = 101
      Top = 6
      Width = 89
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Copy'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnCopyClick
    end
    object btnDelete: TButton
      Left = 6
      Top = 6
      Width = 89
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Delete'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnDeleteClick
    end
  end
  object pnlMain: TPanel
    Left = 0
    Top = 207
    Width = 1069
    Height = 569
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 0
      Top = 254
      Width = 1069
      Height = 3
      Cursor = crVSplit
      Align = alTop
      Beveled = True
      OnCanResize = Splitter1CanResize
      ExplicitTop = 232
      ExplicitWidth = 328
    end
    object pnlAllocateTo: TPanel
      Left = 0
      Top = 0
      Width = 1069
      Height = 254
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 5
      Constraints.MinHeight = 206
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      DesignSize = (
        1069
        254)
      object lblAllocateTo: TLabel
        Left = 14
        Top = 60
        Width = 72
        Height = 16
        Caption = 'Allocate To'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object ToolBar: TPanel
        AlignWithMargins = True
        Left = 6
        Top = 15
        Width = 1063
        Height = 26
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 5
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          1063
          26)
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
          Width = 103
          Height = 22
          Margins.Top = 2
          Margins.Bottom = 2
          Align = alLeft
          Caption = 'Only Apply to'
          TabOrder = 1
          OnClick = chkAccountSystemClick
        end
        object cbAccounting: TComboBox
          AlignWithMargins = True
          Left = 543
          Top = 1
          Width = 513
          Height = 24
          Margins.Top = 1
          Margins.Bottom = 1
          Style = csDropDownList
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 16
          Sorted = True
          TabOrder = 2
          OnChange = cbAccountingChange
        end
      end
      object tblSplit: TOvcTable
        Left = 9
        Top = 82
        Width = 1054
        Height = 121
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
        LockedRowsCell = Header
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
        OnKeyDown = tblSplitKeyDown
        OnMouseDown = tblSplitMouseDown
        OnUserCommand = tblSplitUserCommand
        CellData = (
          'dlgMemorise.Header'
          'dlgMemorise.colLineType'
          'dlgMemorise.ColPercent'
          'dlgMemorise.ColAmount'
          'dlgMemorise.ColGSTCode'
          'dlgMemorise.colJob'
          'dlgMemorise.ColPayee'
          'dlgMemorise.colNarration'
          'dlgMemorise.ColDesc'
          'dlgMemorise.ColAcct')
        RowData = (
          24)
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
        Left = 540
        Top = 209
        Width = 529
        Height = 39
        Anchors = [akRight, akBottom]
        BevelOuter = bvNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = 27
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        object lblTotalPerc: TLabel
          Left = 287
          Top = 0
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
        object lblRemPerc: TLabel
          Left = 479
          Top = 0
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
        object lblRemPercHdr: TLabel
          Left = 359
          Top = 0
          Width = 60
          Height = 16
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Remaining'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblTotalPercHdr: TLabel
          Left = 185
          Top = 0
          Width = 40
          Height = 16
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Total'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblAmount: TLabel
          Left = 68
          Top = 0
          Width = 96
          Height = 16
          Alignment = taRightJustify
          Caption = '$999,999,999.00'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblAmountHdr: TLabel
          Left = 18
          Top = 0
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
        object lblFixed: TLabel
          Left = 230
          Top = 20
          Width = 96
          Height = 16
          Alignment = taRightJustify
          Caption = '$999,999,999.00'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblFixedHdr: TLabel
          Left = 185
          Top = 20
          Width = 40
          Height = 16
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Fixed'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblRemDollar: TLabel
          Left = 423
          Top = 20
          Width = 96
          Height = 16
          Alignment = taRightJustify
          Caption = '$999,999,999.00'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblRemDollarHdr: TLabel
          Left = 359
          Top = 20
          Width = 60
          Height = 16
          Alignment = taRightJustify
          AutoSize = False
          Caption = 'Remaining'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlAllocateToLine: TPanel
        Left = 0
        Top = 50
        Width = 1069
        Height = 2
        HelpContext = 2
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvLowered
        TabOrder = 3
      end
      object pnlChartLine: TPanel
        Left = 0
        Top = 5
        Width = 1069
        Height = 2
        HelpContext = 2
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvLowered
        TabOrder = 4
      end
    end
    object pnlMatchingTransactions: TPanel
      Left = 0
      Top = 257
      Width = 1069
      Height = 312
      Align = alClient
      BevelOuter = bvNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      DesignSize = (
        1069
        312)
      object lblMatchingTransactions: TLabel
        Left = 14
        Top = 8
        Width = 146
        Height = 16
        Caption = 'Matching Transactions'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblMatchingTranNote: TLabel
        Left = 166
        Top = 10
        Width = 162
        Height = 13
        Caption = '(excludes locked and transferred)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object tblTran: TOvcTable
        Left = 8
        Top = 28
        Width = 1054
        Height = 278
        RowLimit = 2
        LockedCols = 0
        LeftCol = 0
        Anchors = [akLeft, akTop, akRight, akBottom]
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
        LockedRowsCell = tranHeader
        Options = [otoNoRowResizing, otoEnterToArrow, otoRowSelection]
        ParentCtl3D = False
        ParentFont = False
        TabOrder = 0
        OnActiveCellChanged = tblTranActiveCellChanged
        OnGetCellData = tblTranGetCellData
        OnGetCellAttributes = tblTranGetCellAttributes
        OnMouseDown = tblTranMouseDown
        CellData = (
          'dlgMemorise.tranHeader'
          'dlgMemorise.colTranCodedBy'
          'dlgMemorise.colTranStatementDetails'
          'dlgMemorise.colTranAmount'
          'dlgMemorise.colTranAccount'
          'dlgMemorise.colAnalysis'
          'dlgMemorise.colReference'
          'dlgMemorise.colTranDate')
        RowData = (
          24)
        ColData = (
          70
          False
          True
          'dlgMemorise.colTranDate'
          100
          False
          True
          'dlgMemorise.colReference'
          100
          False
          True
          'dlgMemorise.colAnalysis'
          100
          False
          True
          'dlgMemorise.colTranAccount'
          125
          False
          True
          'dlgMemorise.colTranAmount'
          500
          False
          True
          'dlgMemorise.colTranStatementDetails'
          150
          False
          True
          'dlgMemorise.colTranCodedBy')
      end
      object treView: TTreeView
        Left = 8
        Top = 28
        Width = 1054
        Height = 278
        Anchors = [akLeft, akTop, akRight, akBottom]
        Indent = 19
        ReadOnly = True
        TabOrder = 1
      end
      object pnlMessage: TPanel
        Left = 10
        Top = 30
        Width = 1050
        Height = 274
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        Caption = 'No matching transactions.'
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
        Visible = False
      end
    end
  end
  object pnlDetails: TPanel
    Left = 0
    Top = 0
    Width = 1069
    Height = 207
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      1069
      207)
    object lblMatchOn: TLabel
      Left = 14
      Top = 7
      Width = 61
      Height = 16
      Caption = 'Match On'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cEntry: TCheckBox
      Left = 12
      Top = 30
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
      OnClick = cEntryClick
      OnExit = cCodeExit
    end
    object cmbType: TComboBox
      Left = 150
      Top = 27
      Width = 305
      Height = 24
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ItemHeight = 16
      ParentFont = False
      TabOrder = 1
      OnChange = eStatementDetailsChange
      OnExit = cCodeExit
    end
    object chkStatementDetails: TCheckBox
      Left = 12
      Top = 60
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
      TabOrder = 2
      OnClick = chkStatementDetailsClick
      OnExit = cCodeExit
    end
    object cRef: TCheckBox
      Left = 12
      Top = 120
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
      TabOrder = 4
      OnClick = cRefClick
      OnExit = cCodeExit
    end
    object eRef: TEdit
      Left = 150
      Top = 117
      Width = 305
      Height = 24
      Anchors = [akLeft, akTop, akRight]
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
      Text = 'eRef'
      OnChange = eStatementDetailsChange
      OnExit = cCodeExit
    end
    object eOther: TEdit
      Left = 150
      Top = 147
      Width = 305
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      BorderStyle = bsNone
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 20
      ParentFont = False
      TabOrder = 7
      Text = 'eOther'
      OnChange = eStatementDetailsChange
      OnExit = cCodeExit
    end
    object cOther: TCheckBox
      Left = 12
      Top = 150
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
      TabOrder = 6
      OnClick = cOtherClick
      OnExit = cCodeExit
    end
    object cCode: TCheckBox
      Left = 12
      Top = 180
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
      TabOrder = 8
      OnClick = cCodeClick
      OnExit = cCodeExit
    end
    object eCode: TEdit
      Left = 150
      Top = 177
      Width = 305
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      BorderStyle = bsNone
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 12
      ParentFont = False
      TabOrder = 9
      Text = 'eCode'
      OnChange = eStatementDetailsChange
      OnExit = cCodeExit
    end
    object cNotes: TCheckBox
      Left = 475
      Top = 150
      Width = 96
      Height = 17
      Alignment = taLeftJustify
      Anchors = [akTop, akRight]
      Caption = '&Notes'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 20
      OnClick = cNotesClick
      OnExit = cCodeExit
    end
    object cPart: TCheckBox
      Left = 475
      Top = 120
      Width = 96
      Height = 17
      Alignment = taLeftJustify
      Anchors = [akTop, akRight]
      Caption = '&Particulars'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 18
      OnClick = cPartClick
      OnExit = cCodeExit
    end
    object cValue: TCheckBox
      Left = 475
      Top = 88
      Width = 96
      Height = 22
      Alignment = taLeftJustify
      Anchors = [akTop, akRight]
      Caption = '&Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 14
      OnClick = cValueClick
      OnExit = cCodeExit
    end
    object cbTo: TCheckBox
      Left = 475
      Top = 60
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
      TabOrder = 12
      OnClick = cbToClick
      OnExit = cCodeExit
    end
    object cbFrom: TCheckBox
      Left = 475
      Top = 30
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
      TabOrder = 10
      OnClick = cbFromClick
      OnExit = cCodeExit
    end
    object eDateFrom: TOvcPictureField
      Left = 580
      Top = 27
      Width = 70
      Height = 24
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
      TabOrder = 11
      OnChange = eStatementDetailsChange
      OnDblClick = eDateFromDblClick
      OnExit = cCodeExit
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object eDateTo: TOvcPictureField
      Left = 580
      Top = 57
      Width = 70
      Height = 24
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
      TabOrder = 13
      OnChange = eStatementDetailsChange
      OnDblClick = eDateFromDblClick
      OnExit = cCodeExit
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object cmbValue: TComboBox
      Left = 580
      Top = 87
      Width = 143
      Height = 24
      Style = csDropDownList
      Anchors = [akTop, akRight]
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
      OnExit = cCodeExit
    end
    object nValue: TOvcNumericField
      Left = 729
      Top = 87
      Width = 113
      Height = 24
      Cursor = crIBeam
      DataType = nftDouble
      Anchors = [akTop, akRight]
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
      OnExit = cCodeExit
      OnKeyPress = nValueKeyPress
      RangeHigh = {73B2DBB9838916F2FE43}
      RangeLow = {73B2DBB9838916F2FEC3}
    end
    object cbMinus: TComboBox
      Left = 849
      Top = 87
      Width = 53
      Height = 24
      Anchors = [akTop, akRight]
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
      OnExit = cCodeExit
      Items.Strings = (
        'CR'
        'DR')
    end
    object btnShowMoreOptions: TButton
      Left = 931
      Top = 86
      Width = 129
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Show more &options'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 22
      OnClick = btnShowMoreOptionsClick
    end
    object ePart: TEdit
      Left = 580
      Top = 117
      Width = 262
      Height = 24
      Anchors = [akTop, akRight]
      BorderStyle = bsNone
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 12
      ParentFont = False
      TabOrder = 19
      Text = 'ePart'
      OnChange = eStatementDetailsChange
      OnExit = cCodeExit
    end
    object eNotes: TEdit
      Left = 580
      Top = 147
      Width = 262
      Height = 24
      Anchors = [akTop, akRight]
      BorderStyle = bsNone
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      MaxLength = 40
      ParentFont = False
      TabOrder = 21
      Text = 'eCode'
      OnChange = eStatementDetailsChange
      OnExit = cCodeExit
    end
    object eStatementDetails: TMemo
      Left = 150
      Top = 57
      Width = 305
      Height = 48
      Anchors = [akLeft, akTop, akRight]
      BorderStyle = bsNone
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      Lines.Strings = (
        'eStatementDetails')
      MaxLength = 100
      ParentFont = False
      TabOrder = 3
      OnChange = eStatementDetailsChange
      OnExit = cCodeExit
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
    Top = 328
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
    Table = tblSplit
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
    Options = [efoCaretToEnd]
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
    Left = 264
    Top = 584
  end
  object tranHeader: TOvcTCColHead
    Headings.Strings = (
      'Date'
      'Reference'
      'Analysis'
      'Account'
      'Amount'
      'Statement Details'
      'Coded By')
    ShowLetters = False
    Table = tblTran
    Left = 304
    Top = 584
  end
  object colTranDate: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterLeft
    AutoAdvanceLeftRight = True
    MaxLength = 10
    Table = tblTran
    OnOwnerDraw = colTranDateOwnerDraw
    Left = 264
    Top = 632
  end
  object colTranAccount: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterLeft
    AutoAdvanceLeftRight = True
    MaxLength = 10
    Table = tblTran
    OnOwnerDraw = colTranAccountOwnerDraw
    Left = 384
    Top = 632
  end
  object colTranStatementDetails: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterLeft
    AutoAdvanceLeftRight = True
    MaxLength = 10
    Table = tblTran
    OnOwnerDraw = colTranStatementDetailsOwnerDraw
    Left = 464
    Top = 632
  end
  object colTranCodedBy: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterLeft
    AutoAdvanceLeftRight = True
    MaxLength = 10
    Table = tblTran
    OnOwnerDraw = colTranCodedByOwnerDraw
    Left = 504
    Top = 632
  end
  object colTranAmount: TOvcTCNumericField
    Access = otxReadOnly
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
    Table = tblTran
    TableColor = False
    Left = 424
    Top = 632
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object colReference: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterLeft
    AutoAdvanceLeftRight = True
    MaxLength = 10
    Table = tblTran
    OnOwnerDraw = colTranStatementDetailsOwnerDraw
    Left = 304
    Top = 632
  end
  object colAnalysis: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterLeft
    AutoAdvanceLeftRight = True
    MaxLength = 10
    Table = tblTran
    OnOwnerDraw = colTranStatementDetailsOwnerDraw
    Left = 344
    Top = 632
  end
  object popMatchTran: TPopupMenu
    Left = 456
    Top = 552
    object mnuMatchStatementDetails: TMenuItem
      Caption = 'Match on this Statement Details'
      OnClick = mnuMatchStatementDetailsClick
    end
  end
end
