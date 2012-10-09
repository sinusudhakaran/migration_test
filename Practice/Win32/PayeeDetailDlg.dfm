object dlgPayeeDetail: TdlgPayeeDetail
  Left = 340
  Top = 266
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Payee Details'
  ClientHeight = 370
  ClientWidth = 1075
  Color = clBtnFace
  Constraints.MinHeight = 350
  Constraints.MinWidth = 630
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
  object pnlMain: TPanel
    Left = 0
    Top = 137
    Width = 1075
    Height = 162
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 0
    object tblSplit: TOvcTable
      Left = 1
      Top = 30
      Width = 1073
      Height = 131
      RowLimit = 6
      LockedCols = 0
      LeftCol = 0
      ActiveCol = 0
      Align = alClient
      Color = clWindow
      ColorUnused = clBtnFace
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
      GridPenSet.LockedGrid.Effect = ge3D
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
        'dlgPayeeDetail.Header'
        'dlgPayeeDetail.ColAcct'
        'dlgPayeeDetail.ColDesc'
        'dlgPayeeDetail.colNarration'
        'dlgPayeeDetail.ColGSTCode'
        'dlgPayeeDetail.ColAmount'
        'dlgPayeeDetail.colPercent'
        'dlgPayeeDetail.colLineType')
      RowData = (
        21)
      ColData = (
        80
        False
        True
        'dlgPayeeDetail.ColAcct'
        150
        False
        True
        'dlgPayeeDetail.ColDesc'
        134
        False
        True
        'dlgPayeeDetail.colNarration'
        35
        False
        True
        'dlgPayeeDetail.ColGSTCode'
        100
        False
        True
        'dlgPayeeDetail.ColAmount'
        100
        False
        True
        'dlgPayeeDetail.colPercent'
        45
        False
        True
        'dlgPayeeDetail.colLineType')
    end
    object Panel2: TPanel
      Left = 1
      Top = 1
      Width = 1073
      Height = 29
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object sbtnChart: TSpeedButton
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 65
        Height = 23
        Align = alLeft
        Caption = 'Chart'
        Flat = True
        OnClick = sbtnChartClick
        ExplicitLeft = 8
        ExplicitHeight = 22
      end
      object sbtnSuper: TSpeedButton
        AlignWithMargins = True
        Left = 74
        Top = 3
        Width = 65
        Height = 23
        Align = alLeft
        Caption = 'Super'
        Flat = True
        OnClick = sbtnSuperClick
        ExplicitLeft = 88
        ExplicitTop = 5
        ExplicitHeight = 22
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 299
    Width = 1075
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      1075
      50)
    object btnOK: TButton
      Left = 913
      Top = 20
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 997
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
      Left = 7
      Top = 3
      Width = 366
      Height = 46
      BevelInner = bvRaised
      BevelOuter = bvLowered
      TabOrder = 0
      object lblFixedHdr: TLabel
        Left = 12
        Top = 8
        Width = 35
        Height = 13
        Caption = 'Fixed $'
      end
      object lblTotalPercHdr: TLabel
        Left = 245
        Top = 8
        Width = 38
        Height = 13
        Alignment = taRightJustify
        Caption = 'Total %'
      end
      object lblRemPercHdr: TLabel
        Left = 322
        Top = 8
        Width = 35
        Height = 13
        Alignment = taRightJustify
        Caption = 'Rem %'
      end
      object lblRemPerc: TLabel
        Left = 321
        Top = 24
        Width = 35
        Height = 13
        Alignment = taRightJustify
        Caption = '1000%'
      end
      object lblTotalPerc: TLabel
        Left = 249
        Top = 24
        Width = 35
        Height = 13
        Alignment = taRightJustify
        Caption = '1000%'
      end
      object lblFixed: TLabel
        Left = 12
        Top = 24
        Width = 84
        Height = 13
        Caption = '$999,999,999.00'
      end
    end
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 1075
    Height = 137
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Label2: TLabel
      Left = 16
      Top = 20
      Width = 70
      Height = 13
      Caption = '&Payee Number'
      FocusControl = nPayeeNo
    end
    object Label1: TLabel
      Left = 16
      Top = 52
      Width = 60
      Height = 13
      Caption = 'Payee &Name'
      FocusControl = eName
    end
    object nPayeeNo: TOvcNumericField
      Left = 127
      Top = 16
      Width = 70
      Height = 21
      Cursor = crIBeam
      DataType = nftLongInt
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      Controller = memController
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '999999'
      TabOrder = 0
      RangeHigh = {3F420F00000000000000}
      RangeLow = {00000000000000000000}
    end
    object eName: TEdit
      Left = 127
      Top = 48
      Width = 377
      Height = 24
      BorderStyle = bsNone
      MaxLength = 40
      TabOrder = 2
      OnChange = eNameChange
      OnEnter = eNameEnter
    end
    object pnlPayeeName: TPanel
      Left = 13
      Top = 74
      Width = 495
      Height = 61
      BevelOuter = bvNone
      TabOrder = 3
      Visible = False
      object Label3: TLabel
        Left = 3
        Top = 6
        Width = 75
        Height = 13
        Caption = 'Payee &Surname'
        FocusControl = edtPayeeSurname
      end
      object Label4: TLabel
        Left = 3
        Top = 35
        Width = 88
        Height = 13
        Caption = 'Payee &given name'
        FocusControl = edtPayeeGivenName
      end
      object Label5: TLabel
        Left = 271
        Top = 35
        Width = 57
        Height = 13
        Caption = 'Other na&me'
        FocusControl = edtOtherName
      end
      object edtPayeeSurname: TEdit
        Left = 114
        Top = 3
        Width = 377
        Height = 24
        BorderStyle = bsNone
        MaxLength = 30
        TabOrder = 0
        OnChange = eNameChange
        OnEnter = eNameEnter
      end
      object edtPayeeGivenName: TEdit
        Left = 114
        Top = 32
        Width = 145
        Height = 24
        BorderStyle = bsNone
        MaxLength = 15
        TabOrder = 1
        OnChange = eNameChange
        OnEnter = eNameEnter
      end
      object edtOtherName: TEdit
        Left = 346
        Top = 32
        Width = 145
        Height = 24
        BorderStyle = bsNone
        MaxLength = 15
        TabOrder = 2
        OnChange = eNameChange
        OnEnter = eNameEnter
      end
    end
    object pnlPayeeAddress: TPanel
      Left = 529
      Top = 18
      Width = 374
      Height = 117
      BevelOuter = bvNone
      TabOrder = 4
      Visible = False
      object Label6: TLabel
        Left = 2
        Top = 5
        Width = 39
        Height = 13
        Caption = '&Address'
        FocusControl = edtAddress
      end
      object Label7: TLabel
        Left = 2
        Top = 33
        Width = 26
        Height = 13
        Caption = 'To&wn'
        FocusControl = edtTown
      end
      object Label8: TLabel
        Left = 2
        Top = 62
        Width = 26
        Height = 13
        Caption = 'S&tate'
        FocusControl = edtState
      end
      object Label9: TLabel
        Left = 2
        Top = 91
        Width = 70
        Height = 13
        Caption = 'P&hone Number'
      end
      object Label10: TLabel
        Left = 215
        Top = 62
        Width = 44
        Height = 13
        Caption = 'Postco&de'
        FocusControl = edtPostcode
      end
      object edtPostcode: TEdit
        Left = 271
        Top = 59
        Width = 98
        Height = 24
        BorderStyle = bsNone
        MaxLength = 4
        TabOrder = 3
        OnChange = eNameChange
        OnEnter = eNameEnter
      end
      object edtAddress: TEdit
        Left = 96
        Top = 2
        Width = 273
        Height = 24
        BorderStyle = bsNone
        MaxLength = 38
        TabOrder = 0
        OnChange = eNameChange
        OnEnter = eNameEnter
      end
      object edtState: TEdit
        Left = 96
        Top = 59
        Width = 109
        Height = 24
        BorderStyle = bsNone
        MaxLength = 3
        TabOrder = 2
        OnChange = eNameChange
        OnEnter = eNameEnter
      end
      object edtTown: TEdit
        Left = 96
        Top = 30
        Width = 273
        Height = 24
        BorderStyle = bsNone
        MaxLength = 27
        TabOrder = 1
        OnChange = eNameChange
        OnEnter = eNameEnter
      end
      object edtPhoneNumber: TBKNumericEdit
        Left = 96
        Top = 88
        Width = 109
        Height = 21
        BorderStyle = bsNone
        MaxLength = 10
        TabOrder = 4
      end
    end
    object chkContractorPayee: TCheckBox
      Left = 387
      Top = 16
      Width = 117
      Height = 17
      Caption = '&Contractor Payee'
      TabOrder = 1
      Visible = False
    end
    object pnlPayeeABN: TPanel
      Left = 923
      Top = 16
      Width = 151
      Height = 33
      BevelOuter = bvNone
      TabOrder = 5
      Visible = False
      object Label11: TLabel
        Left = 2
        Top = 7
        Width = 20
        Height = 13
        Caption = 'A&BN'
        FocusControl = edtABN
      end
      object edtABN: TMaskEdit
        Left = 34
        Top = 4
        Width = 113
        Height = 24
        BorderStyle = bsNone
        EditMask = '99\ 999\ 999\ 999;0; '
        MaxLength = 14
        TabOrder = 0
      end
    end
  end
  object sBar: TStatusBar
    Left = 0
    Top = 349
    Width = 1075
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
    Left = 784
    Top = 312
  end
  object Header: TOvcTCColHead
    Headings.Strings = (
      'Code'
      'Account Description'
      'Narration'
      'GST'
      'Amount'
      'Percent'
      '%/$')
    ShowLetters = False
    Adjust = otaCenterLeft
    Table = tblSplit
    Left = 496
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
    Options = [efoCaretToEnd]
    PictureMask = '###,###,###.##'
    Table = tblSplit
    TableColor = False
    OnKeyPress = ColAmountKeyPress
    Left = 752
    Top = 312
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object ColDesc: TOvcTCString
    Color = clWindow
    Table = tblSplit
    TableColor = False
    Left = 560
    Top = 312
  end
  object ColAcct: TOvcTCString
    AutoAdvanceLeftRight = True
    MaxLength = 10
    Table = tblSplit
    OnExit = ColAcctExit
    OnKeyDown = ColAcctKeyDown
    OnKeyPress = ColAcctKeyPress
    OnKeyUp = ColAcctKeyUp
    OnOwnerDraw = ColAcctOwnerDraw
    Left = 528
    Top = 312
  end
  object ColGSTCode: TOvcTCString
    MaxLength = 3
    Table = tblSplit
    OnOwnerDraw = ColGSTCodeOwnerDraw
    Left = 624
    Top = 312
  end
  object colNarration: TOvcTCString
    MaxLength = 40
    Table = tblSplit
    Left = 592
    Top = 312
  end
  object colLineType: TOvcTCComboBox
    AcceptActivationClick = False
    DropDownCount = 2
    HideButton = True
    MaxLength = 1
    Style = csDropDownList
    Table = tblSplit
    Left = 656
    Top = 312
  end
  object popPayee: TPopupMenu
    Images = AppImages.Coding
    Left = 688
    Top = 312
    object LookupChart1: TMenuItem
      Caption = '&Lookup chart                                       F2'
      ImageIndex = 0
      OnClick = sbtnChartClick
    end
    object LookupGSTClass1: TMenuItem
      Caption = 'Lookup &GST class                                F7'
      OnClick = LookupGSTClass1Click
    end
    object Sep1: TMenuItem
      Caption = '-'
    end
    object FixedAmount1: TMenuItem
      Caption = 'Apply &fixed amount                              $'
      OnClick = FixedAmount1Click
    end
    object PercentageofTotal1: TMenuItem
      Caption = 'Apply &percentage split                         %'
      OnClick = PercentageofTotal1Click
    end
    object AmountApplyRemainingAmount1: TMenuItem
      Caption = 'Appl&y remaining                                    ='
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
  object colPercent: TOvcTCNumericField
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
    Left = 720
    Top = 312
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
end
