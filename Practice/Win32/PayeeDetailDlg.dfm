object dlgPayeeDetail: TdlgPayeeDetail
  Left = 340
  Top = 266
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Payee Details'
  ClientHeight = 592
  ClientWidth = 1103
  Color = clBtnFace
  Constraints.MinHeight = 350
  Constraints.MinWidth = 630
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label7: TLabel
    Left = 675
    Top = 370
    Width = 20
    Height = 13
    Caption = 'A&BN'
  end
  object Panel3: TPanel
    Left = 0
    Top = 521
    Width = 1103
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      1103
      50)
    object btnOK: TButton
      Left = 941
      Top = 20
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 1025
      Top = 20
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
    object pnlTotalAmounts: TPanel
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
  object sBar: TStatusBar
    Left = 0
    Top = 571
    Width = 1103
    Height = 21
    Panels = <
      item
        Text = '1 of 100'
        Width = 75
      end>
    ParentFont = True
    UseSystemFont = False
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 1103
    Height = 521
    ActivePage = tsContractorDetails
    Align = alClient
    TabOrder = 2
    OnChange = PageControl1Change
    object tsPayeeDetails: TTabSheet
      Caption = 'Payee Details'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object pnlMain: TPanel
        Left = 0
        Top = 101
        Width = 1095
        Height = 392
        Align = alClient
        BevelOuter = bvLowered
        TabOrder = 0
        object tblSplit: TOvcTable
          Left = 1
          Top = 30
          Width = 1093
          Height = 361
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
            'dlgPayeeDetail.Header')
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
          Width = 1093
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
      object pnlPayeeDetails: TPanel
        Left = 0
        Top = 0
        Width = 1095
        Height = 101
        Align = alTop
        TabOrder = 1
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
        object chkContractorPayee: TCheckBox
          Left = 387
          Top = 16
          Width = 117
          Height = 17
          Caption = '&Contractor Payee'
          TabOrder = 1
          Visible = False
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
      end
    end
    object tsContractorDetails: TTabSheet
      Caption = 'Contractor Details'
      ImageIndex = 1
      object lblPhoneNumber: TLabel
        Left = 596
        Top = 253
        Width = 84
        Height = 16
        Caption = 'P&hone Number'
        FocusControl = edtPhoneNumber
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblABN: TLabel
        Left = 595
        Top = 283
        Width = 23
        Height = 16
        Caption = 'A&BN'
        FocusControl = mskABN
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblBankAccount: TLabel
        Left = 596
        Top = 313
        Width = 76
        Height = 16
        Caption = 'Bank Account'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object grpContractorType: TGroupBox
        Left = 21
        Top = 16
        Width = 508
        Height = 321
        Caption = 'Contractor Type'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object lblPayeeSurname: TLabel
          Left = 36
          Top = 58
          Width = 90
          Height = 16
          Caption = 'Payee &Surname'
          FocusControl = edtPayeeSurname
        end
        object lblGivenName: TLabel
          Left = 36
          Top = 95
          Width = 106
          Height = 16
          Caption = 'Payee &Given Name'
          FocusControl = edtPayeeGivenName
        end
        object lblSecondGivenName: TLabel
          Left = 36
          Top = 135
          Width = 152
          Height = 16
          Caption = 'Payee Second Given Name'
          FocusControl = edtSecondGivenName
        end
        object lblBusinessName: TLabel
          Left = 36
          Top = 221
          Width = 86
          Height = 16
          Caption = 'Business Name'
          FocusControl = edtBusinessName
        end
        object lblTradingName: TLabel
          Left = 36
          Top = 258
          Width = 81
          Height = 16
          Caption = 'Trading Name'
          FocusControl = edtTradingName
        end
        object edtPayeeSurname: TEdit
          Left = 200
          Top = 55
          Width = 260
          Height = 21
          BorderStyle = bsNone
          MaxLength = 30
          TabOrder = 1
          Text = 'edtPayeeSurname'
          OnChange = eNameChange
          OnEnter = eNameEnter
        end
        object edtPayeeGivenName: TEdit
          Left = 200
          Top = 92
          Width = 260
          Height = 21
          BorderStyle = bsNone
          MaxLength = 15
          TabOrder = 2
          Text = 'edtPayeeGivenName'
          OnChange = eNameChange
          OnEnter = eNameEnter
        end
        object edtSecondGivenName: TEdit
          Left = 200
          Top = 132
          Width = 260
          Height = 21
          BorderStyle = bsNone
          MaxLength = 15
          TabOrder = 3
          Text = 'edtSecondGivenName'
          OnChange = eNameChange
          OnEnter = eNameEnter
        end
        object radIndividual: TRadioButton
          Left = 17
          Top = 24
          Width = 416
          Height = 17
          Caption = 'Individual'
          TabOrder = 0
          OnClick = radIndividualClick
        end
        object radBusiness: TRadioButton
          Left = 17
          Top = 187
          Width = 416
          Height = 17
          Caption = 'Business'
          TabOrder = 4
          OnClick = radBusinessClick
        end
        object edtBusinessName: TEdit
          Left = 200
          Top = 218
          Width = 260
          Height = 21
          BorderStyle = bsNone
          MaxLength = 200
          TabOrder = 5
          Text = 'edtBusinessName'
          OnChange = eNameChange
          OnEnter = eNameEnter
        end
        object edtTradingName: TEdit
          Left = 200
          Top = 255
          Width = 260
          Height = 21
          BorderStyle = bsNone
          MaxLength = 200
          TabOrder = 6
          Text = 'edtTradingName'
          OnChange = eNameChange
          OnEnter = eNameEnter
        end
      end
      object grpStreetAddress: TGroupBox
        Left = 552
        Top = 16
        Width = 505
        Height = 215
        Caption = 'Street Address'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        object lblPostCode: TLabel
          Left = 43
          Top = 145
          Width = 51
          Height = 16
          Caption = 'Postcode'
          FocusControl = edtPostCode
        end
        object lblState: TLabel
          Left = 44
          Top = 115
          Width = 30
          Height = 16
          Caption = 'State'
        end
        object lblStreetAddress: TLabel
          Left = 44
          Top = 25
          Width = 46
          Height = 16
          Caption = 'Address'
          FocusControl = edtStreetAddressLine1
        end
        object lblSuburb: TLabel
          Left = 44
          Top = 85
          Width = 78
          Height = 16
          Caption = 'Town/Suburb'
          FocusControl = edtSuburb
        end
        object lblSupplierCountry: TLabel
          Left = 44
          Top = 145
          Width = 44
          Height = 16
          Caption = 'Country'
          FocusControl = edtSupplierCountry
        end
        object cmbState: TComboBox
          Left = 164
          Top = 112
          Width = 57
          Height = 24
          Style = csDropDownList
          ItemHeight = 16
          TabOrder = 3
          OnChange = cmbStateChange
        end
        object edtPostCode: TEdit
          Left = 164
          Top = 142
          Width = 80
          Height = 22
          BorderStyle = bsNone
          MaxLength = 4
          TabOrder = 4
          Text = 'edtPostCode'
          OnKeyPress = edtPostCodeKeyPress
        end
        object edtStreetAddressLine1: TEdit
          Left = 164
          Top = 22
          Width = 300
          Height = 22
          BorderStyle = bsNone
          MaxLength = 38
          TabOrder = 0
          Text = 'edtStreetAddressLine1'
        end
        object edtStreetAddressLine2: TEdit
          Left = 164
          Top = 52
          Width = 300
          Height = 22
          BorderStyle = bsNone
          MaxLength = 38
          TabOrder = 1
          Text = 'edtStreetAddressLine2'
        end
        object edtSuburb: TEdit
          Left = 164
          Top = 82
          Width = 300
          Height = 22
          BorderStyle = bsNone
          MaxLength = 27
          TabOrder = 2
          Text = 'edtSuburb'
        end
        object edtSupplierCountry: TEdit
          Left = 164
          Top = 142
          Width = 300
          Height = 22
          BorderStyle = bsNone
          MaxLength = 20
          TabOrder = 5
          Text = 'edtSupplierCountry'
        end
      end
      object edtPhoneNumber: TEdit
        Left = 716
        Top = 250
        Width = 273
        Height = 21
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxLength = 15
        ParentFont = False
        TabOrder = 2
        Text = 'edtPhoneNumber'
      end
      object mskABN: TMaskEdit
        Left = 716
        Top = 280
        Width = 112
        Height = 21
        BorderStyle = bsNone
        EditMask = '99\ 999\ 999\ 999;0; '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxLength = 14
        ParentFont = False
        TabOrder = 3
        Text = 'mskABN'
        OnClick = mskABNClick
      end
      object edtBankBSB: TEdit
        Left = 716
        Top = 310
        Width = 57
        Height = 21
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxLength = 6
        ParentFont = False
        TabOrder = 4
        Text = 'edtBankBSB'
      end
      object edtBankAccount: TEdit
        Left = 779
        Top = 310
        Width = 210
        Height = 21
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxLength = 9
        ParentFont = False
        TabOrder = 5
        Text = 'edtBankAccount'
      end
    end
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
    Left = 480
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
    Left = 512
  end
  object ColDesc: TOvcTCString
    Color = clWindow
    Table = tblSplit
    TableColor = False
    Left = 544
  end
  object colNarration: TOvcTCString
    MaxLength = 40
    Table = tblSplit
    Left = 576
  end
  object ColGSTCode: TOvcTCString
    MaxLength = 3
    Table = tblSplit
    OnOwnerDraw = ColGSTCodeOwnerDraw
    Left = 608
  end
  object colLineType: TOvcTCComboBox
    AcceptActivationClick = False
    DropDownCount = 2
    HideButton = True
    MaxLength = 1
    Style = csDropDownList
    Table = tblSplit
    Left = 640
  end
  object popPayee: TPopupMenu
    Images = AppImages.Coding
    Left = 672
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
    Options = [efoCaretToEnd]
    PictureMask = '###,###,###.####'
    Table = tblSplit
    TableColor = False
    OnKeyPress = ColAmountKeyPress
    Left = 704
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
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
    Left = 736
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
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
    Left = 768
  end
end
