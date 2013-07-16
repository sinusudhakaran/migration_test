object dlgEditGST: TdlgEditGST
  Left = 410
  Top = 293
  BorderStyle = bsDialog
  Caption = 'GST Set Up'
  ClientHeight = 446
  ClientWidth = 662
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    662
    446)
  PixelsPerInch = 96
  TextHeight = 13
  object pcGST: TPageControl
    Left = 0
    Top = 0
    Width = 662
    Height = 406
    ActivePage = tsGSTRates
    Align = alTop
    TabOrder = 0
    OnChange = pcGSTChange
    object pgDetails: TTabSheet
      Caption = '&Details'
      object bvlBAS: TBevel
        Left = 8
        Top = 185
        Width = 313
        Height = 184
        Shape = bsFrame
      end
      object lblNumber: TLabel
        Left = 12
        Top = 36
        Width = 65
        Height = 13
        Caption = 'GST / ABN No'
      end
      object lblBasis: TLabel
        Left = 12
        Top = 111
        Width = 24
        Height = 13
        Caption = 'Basis'
      end
      object lblPeriod: TLabel
        Left = 12
        Top = 197
        Width = 52
        Height = 13
        Caption = 'GST Period'
      end
      object lblStarts: TLabel
        Left = 12
        Top = 149
        Width = 29
        Height = 13
        Caption = 'Starts'
      end
      object lblPAYG: TLabel
        Left = 12
        Top = 231
        Width = 107
        Height = 32
        AutoSize = False
        Caption = 'PAYG tax withheld period'
        WordWrap = True
      end
      object lblPeriodsTitle: TLabel
        Left = 384
        Top = 32
        Width = 175
        Height = 13
        Caption = 'Business Activity Statement Periods:'
      end
      object lblPAYGInstalment: TLabel
        Left = 12
        Top = 279
        Width = 137
        Height = 17
        AutoSize = False
        Caption = 'PAYG income tax instalment period'
        WordWrap = True
      end
      object lblTFN: TLabel
        Left = 12
        Top = 73
        Width = 19
        Height = 13
        Caption = 'TFN'
      end
      object lblRatio: TLabel
        Left = 12
        Top = 312
        Width = 39
        Height = 13
        Caption = 'Ratio %'
        FocusControl = cbRatioOption
      end
      object lsvPeriodDisplay: TListView
        Left = 384
        Top = 56
        Width = 153
        Height = 255
        Color = clBtnHighlight
        Columns = <>
        Ctl3D = False
        FlatScrollBars = True
        IconOptions.Arrangement = iaLeft
        IconOptions.WrapText = False
        ShowColumnHeaders = False
        TabOrder = 10
        TabStop = False
        ViewStyle = vsList
        OnEnter = lsvPeriodDisplayEnter
      end
      object cmbBasis: TComboBox
        Left = 160
        Top = 107
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
        OnChange = cmbBasisChange
      end
      object cmbPeriod: TComboBox
        Left = 160
        Top = 193
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        OnChange = cmbPeriodChange
      end
      object cmbStarts: TComboBox
        Left = 160
        Top = 145
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 4
        OnChange = cmbPeriodChange
      end
      object eABN_Division: TEdit
        Left = 312
        Top = 32
        Width = 42
        Height = 24
        BorderStyle = bsNone
        MaxLength = 3
        TabOrder = 1
        Text = 'eABN_Division'
        Visible = False
      end
      object eGSTNumber: TMaskEdit
        Left = 160
        Top = 32
        Width = 145
        Height = 24
        BorderStyle = bsNone
        Ctl3D = True
        ParentCtl3D = False
        TabOrder = 0
        OnClick = eGSTNumberClick
      end
      object cmbPAYGWithheld: TComboBox
        Left = 160
        Top = 235
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 6
        OnChange = cmbPAYGWithheldChange
      end
      object cmbPAYGInstalment: TComboBox
        Left = 160
        Top = 275
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 7
        OnChange = cmbPAYGWithheldChange
      end
      object chkIncludeFBT: TCheckBox
        Left = 12
        Top = 310
        Width = 161
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Include FBT/WET/LCT'
        TabOrder = 8
      end
      object chkIncludeFuel: TCheckBox
        Left = 12
        Top = 342
        Width = 161
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Include Fuel Tax'
        TabOrder = 9
        OnClick = chkIncludeFuelClick
      end
      object eTFN: TMaskEdit
        Left = 160
        Top = 69
        Width = 145
        Height = 24
        BorderStyle = bsNone
        Ctl3D = True
        MaxLength = 10
        ParentCtl3D = False
        TabOrder = 2
        OnClick = eGSTNumberClick
      end
      object cbProvisional: TCheckBox
        Left = 12
        Top = 305
        Width = 161
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Include provisional tax'
        TabOrder = 11
        OnClick = cbProvisionalClick
      end
      object cbRatioOption: TCheckBox
        Left = 12
        Top = 328
        Width = 161
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Use ratio option'
        TabOrder = 12
        OnClick = cbRatioOptionClick
      end
      object ERatio: TOvcNumericField
        Left = 160
        Top = 312
        Width = 145
        Height = 21
        Cursor = crIBeam
        DataType = nftDouble
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '###.#'
        TabOrder = 13
        RangeHigh = {00000000000000C80540}
        RangeLow = {00000000000000000000}
      end
    end
    object tsGSTRates: TTabSheet
      Caption = '&Rates'
      ImageIndex = 2
      object Label5: TLabel
        Left = 220
        Top = 30
        Width = 74
        Height = 13
        Caption = 'Effective Dates'
      end
      object sbtnChart: TSpeedButton
        Left = 569
        Top = 26
        Width = 71
        Height = 25
        Caption = 'Chart'
        Flat = True
        OnClick = sbtnChartClick
      end
      object Label7: TLabel
        Left = 333
        Top = 8
        Width = 32
        Height = 13
        Caption = 'Rate 1'
      end
      object Label8: TLabel
        Left = 416
        Top = 8
        Width = 32
        Height = 13
        Caption = 'Rate 2'
      end
      object Label9: TLabel
        Left = 504
        Top = 8
        Width = 32
        Height = 13
        Caption = 'Rate 3'
      end
      object tblRates: TOvcTable
        Left = 3
        Top = 55
        Width = 643
        Height = 262
        ActiveRow = 2
        RowLimit = 21
        LockedCols = 0
        LeftCol = 0
        ActiveCol = 0
        BorderStyle = bsNone
        Color = clWindow
        Colors.ActiveUnfocused = clWindow
        Colors.ActiveUnfocusedText = clWindowText
        Colors.Editing = clWindow
        Controller = OvcController1
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
        TabOrder = 3
        OnActiveCellChanged = tblRatesActiveCellChanged
        OnActiveCellMoving = tblRatesActiveCellMoving
        OnBeginEdit = tblRatesBeginEdit
        OnDoneEdit = tblRatesDoneEdit
        OnEndEdit = tblRatesEndEdit
        OnEnter = tblRatesEnter
        OnExit = tblRatesExit
        OnGetCellData = tblRatesGetCellData
        OnGetCellAttributes = tblRatesGetCellAttributes
        OnUserCommand = tblRatesUserCommand
        CellData = (
          'dlgEditGST.colHeader'
          'dlgEditGST.colNormPercent'
          'dlgEditGST.colAccount'
          'dlgEditGST.colRate3'
          'dlgEditGST.colRate2'
          'dlgEditGST.colRate1'
          'dlgEditGST.celGSTType'
          'dlgEditGST.colDesc'
          'dlgEditGST.ColID')
        RowData = (
          22)
        ColData = (
          40
          False
          True
          'dlgEditGST.ColID'
          137
          False
          True
          'dlgEditGST.colDesc'
          164
          False
          True
          'dlgEditGST.celGSTType'
          54
          False
          True
          'dlgEditGST.colRate1'
          55
          False
          True
          'dlgEditGST.colRate2'
          56
          False
          True
          'dlgEditGST.colRate3'
          100
          False
          True
          'dlgEditGST.colAccount'
          60
          False
          True
          'dlgEditGST.colNormPercent')
      end
      object eDate1: TOvcPictureField
        Left = 310
        Top = 27
        Width = 79
        Height = 22
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
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
        TabOrder = 0
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object eDate2: TOvcPictureField
        Left = 395
        Top = 27
        Width = 77
        Height = 22
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
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
        TabOrder = 1
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object eDate3: TOvcPictureField
        Left = 478
        Top = 27
        Width = 86
        Height = 22
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
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
        TabOrder = 2
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object btnDefaults: TButton
        Left = 5
        Top = 322
        Width = 108
        Height = 25
        Caption = '&Load Defaults'
        TabOrder = 4
        OnClick = btnDefaultsClick
      end
      object btnLoadTemplate: TButton
        Left = 119
        Top = 322
        Width = 108
        Height = 25
        Caption = 'Load Template'
        TabOrder = 5
        OnClick = btnLoadTemplateClick
      end
      object btnSaveTemplate: TButton
        Left = 233
        Top = 322
        Width = 108
        Height = 25
        Caption = 'Save Template'
        TabOrder = 6
        OnClick = btnSaveTemplateClick
      end
    end
    object pgBASRules: TTabSheet
      Caption = '&BAS Fields'
      ImageIndex = 3
      object Label10: TLabel
        Left = 8
        Top = 8
        Width = 388
        Height = 13
        Caption = 
          'Select the GST Classes and Account Codes to be used to calculate' +
          ' the BAS totals'
      end
      object BASTV: TTreeView
        Left = 10
        Top = 32
        Width = 601
        Height = 279
        BorderWidth = 2
        HideSelection = False
        Indent = 19
        ReadOnly = True
        TabOrder = 0
        OnCustomDrawItem = BASTVCustomDrawItem
      end
      object btnAddTaxLevel: TButton
        Left = 10
        Top = 320
        Width = 111
        Height = 25
        Caption = 'Add &GST Class'
        TabOrder = 1
        OnClick = btnAddTaxLevelClick
      end
      object btnAddAccount: TButton
        Left = 138
        Top = 320
        Width = 111
        Height = 25
        Caption = 'Add A&ccount'
        TabOrder = 2
        OnClick = btnAddAccountClick
      end
      object btnDelete: TButton
        Left = 265
        Top = 320
        Width = 111
        Height = 25
        Caption = 'De&lete'
        TabOrder = 3
        OnClick = btnDeleteClick
      end
    end
    object pgReportSettings: TTabSheet
      Caption = 'Report O&ptions'
      ImageIndex = 4
      object gbxAccrual: TGroupBox
        Left = 8
        Top = 4
        Width = 601
        Height = 131
        TabOrder = 0
        object Label2: TLabel
          Left = 16
          Top = 15
          Width = 566
          Height = 26
          Caption = 
            'Do you want to include any Accrual Journals you have entered on ' +
            'the GST Reports?  If you choose NO, then the GST Report will onl' +
            'y show CASH Transactions and Journals.'
          WordWrap = True
        end
        object lblPaymentsOn: TLabel
          Left = 16
          Top = 95
          Width = 578
          Height = 26
          Caption = 
            'Note: You have chosen '#39'%s Basis'#39' for GST in the Details Tab. Thi' +
            's means that Accrual Journals cannot be included on the GST Repo' +
            'rts.'
          WordWrap = True
        end
        object chkJournals: TCheckBox
          Left = 16
          Top = 60
          Width = 203
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Include Accrual Journals?'
          TabOrder = 0
        end
      end
      object gbxClassify: TGroupBox
        Left = 8
        Top = 140
        Width = 601
        Height = 106
        TabOrder = 1
        DesignSize = (
          601
          106)
        object Label1: TLabel
          Left = 16
          Top = 76
          Width = 91
          Height = 13
          Caption = 'Classify Entries By '
          FocusControl = cmbEntriesBy
        end
        object Label6: TLabel
          Left = 16
          Top = 16
          Width = 580
          Height = 39
          Anchors = [akLeft, akTop, akRight]
          Caption = 
            'For GST purposes, do you want to classify transactions into a pa' +
            'rticular GST period based on their effective date, or the actual' +
            ' date of presentation?  If you choose the presentation date opti' +
            'on, then the GST Report will not include unpresented entries.'
          WordWrap = True
        end
        object cmbEntriesBy: TComboBox
          Left = 205
          Top = 72
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'Effective Date'
            'Presentation Date')
        end
      end
      object pnlBASReportOptions: TPanel
        Left = 8
        Top = 254
        Width = 601
        Height = 95
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 2
        object Label16: TLabel
          Left = 16
          Top = 12
          Width = 408
          Height = 13
          Caption = 
            'What report format do you want to use for Business/Instalment Ac' +
            'tivity Statements?'
        end
        object rbATOBas: TRadioButton
          Left = 16
          Top = 40
          Width = 183
          Height = 17
          Caption = 'ATO style'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbATOBasClick
        end
        object rbOnePageBAS: TRadioButton
          Left = 16
          Top = 69
          Width = 183
          Height = 17
          Caption = 'One-page summary'
          TabOrder = 1
          OnClick = rbATOBasClick
        end
        object chkDontPrintCS: TCheckBox
          Left = 205
          Top = 40
          Width = 325
          Height = 17
          Caption = 'Do not include GST Calculation Sheet'
          TabOrder = 2
        end
        object chkDontPrintFuel: TCheckBox
          Left = 205
          Top = 69
          Width = 325
          Height = 17
          Caption = 'Do not include Fuel Tax Calculation Sheet'
          TabOrder = 3
        end
      end
    end
    object pgCalcMethod: TTabSheet
      Caption = 'Calculation &Method'
      ImageIndex = 4
      object Label12: TLabel
        Left = 16
        Top = 64
        Width = 606
        Height = 81
        AutoSize = False
        Caption = 
          'ALL figures on the BAS Calculation Sheet are accurate.  The GST ' +
          'Payable and GST Credit amounts are calculated using the Gross Tr' +
          'ansaction amounts for each entry.'#13#13'You must dissect entries to c' +
          'hange the GST amount of an entry.'
        WordWrap = True
        OnClick = Label12Click
      end
      object Label13: TLabel
        Left = 16
        Top = 191
        Width = 593
        Height = 90
        AutoSize = False
        Caption = 
          'Some figures on the BAS Calculation Sheet are estimated figures.' +
          '  The GST Payable and GST Credit amounts are calculated using th' +
          'e GST amount for each entry, rather than the Gross Transaction a' +
          'mount.'#13#13'You can override the GST amount on an entry.'
        WordWrap = True
      end
      object rbFull: TRadioButton
        Left = 16
        Top = 41
        Width = 113
        Height = 17
        Caption = 'Full Method'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbSimpleClick
      end
      object rbSimple: TRadioButton
        Left = 16
        Top = 168
        Width = 129
        Height = 17
        Caption = 'Simplified Method'
        TabOrder = 1
        OnClick = rbSimpleClick
      end
      object pnlMethodWarning: TPanel
        Left = 3
        Top = 287
        Width = 613
        Height = 58
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 2
        Visible = False
        object Label15: TLabel
          Left = 54
          Top = 3
          Width = 552
          Height = 54
          AutoSize = False
          Caption = 
            'Note: You should not change back from the Simplified Method to t' +
            'he Full Method if you are part way through a GST Period, as this' +
            ' will cause the GST Payable and GST Credit amounts to be incorre' +
            'ct on the Business Activity Statement.'
          WordWrap = True
        end
        object WarningBmp: TImage
          Left = 8
          Top = 10
          Width = 40
          Height = 40
          AutoSize = True
          Picture.Data = {
            07544269746D6170760A0000424D760A00000000000036040000280000002800
            0000280000000100080000000000400600000000000000000000000100000001
            000000000000000080000080000000808000800000008000800080800000C0C0
            C000C0DCC000F0CAA6000020400000206000002080000020A0000020C0000020
            E00000400000004020000040400000406000004080000040A0000040C0000040
            E00000600000006020000060400000606000006080000060A0000060C0000060
            E00000800000008020000080400000806000008080000080A0000080C0000080
            E00000A0000000A0200000A0400000A0600000A0800000A0A00000A0C00000A0
            E00000C0000000C0200000C0400000C0600000C0800000C0A00000C0C00000C0
            E00000E0000000E0200000E0400000E0600000E0800000E0A00000E0C00000E0
            E00040000000400020004000400040006000400080004000A0004000C0004000
            E00040200000402020004020400040206000402080004020A0004020C0004020
            E00040400000404020004040400040406000404080004040A0004040C0004040
            E00040600000406020004060400040606000406080004060A0004060C0004060
            E00040800000408020004080400040806000408080004080A0004080C0004080
            E00040A0000040A0200040A0400040A0600040A0800040A0A00040A0C00040A0
            E00040C0000040C0200040C0400040C0600040C0800040C0A00040C0C00040C0
            E00040E0000040E0200040E0400040E0600040E0800040E0A00040E0C00040E0
            E00080000000800020008000400080006000800080008000A0008000C0008000
            E00080200000802020008020400080206000802080008020A0008020C0008020
            E00080400000804020008040400080406000804080008040A0008040C0008040
            E00080600000806020008060400080606000806080008060A0008060C0008060
            E00080800000808020008080400080806000808080008080A0008080C0008080
            E00080A0000080A0200080A0400080A0600080A0800080A0A00080A0C00080A0
            E00080C0000080C0200080C0400080C0600080C0800080C0A00080C0C00080C0
            E00080E0000080E0200080E0400080E0600080E0800080E0A00080E0C00080E0
            E000C0000000C0002000C0004000C0006000C0008000C000A000C000C000C000
            E000C0200000C0202000C0204000C0206000C0208000C020A000C020C000C020
            E000C0400000C0402000C0404000C0406000C0408000C040A000C040C000C040
            E000C0600000C0602000C0604000C0606000C0608000C060A000C060C000C060
            E000C0800000C0802000C0804000C0806000C0808000C080A000C080C000C080
            E000C0A00000C0A02000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0
            E000C0C00000C0C02000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0
            A000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
            FF00A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403
            000000000000000000000000000000000000000000000000A4A4A4A4A4A4A4A4
            A4A4A4A4A4A403FBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFB07
            00A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFB
            FBFBFBFBFBFBFBFB0700A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFBFBFBFBFB
            FBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFB00A4A4A4A4A4A4A4A4A4A4A403FBFB
            FBFBFBFBFBFBFBFBFBFB07000007FBFBFBFBFBFBFBFBFBFBFB00A4A4A4A4A4A4
            A4A4A4A4A403FBFBFBFBFBFBFBFBFBFBFBFB00000000FBFBFBFBFBFBFBFBFBFB
            0700A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFBFBFBFBFBFB00000000FBFB
            FBFBFBFBFBFBFBFB00A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFBFBFBFB
            FBFB07000007FBFBFBFBFBFBFBFBFB0700A4A4A4A4A4A4A4A4A4A4A4A4A4A403
            FBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFB00A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A403FBFBFBFBFBFBFBFBFBFBFB00FBFBFBFBFBFBFBFBFBFB0700
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFBFBFBFB070007FBFBFB
            FBFBFBFBFBFB00A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFBFB
            FBFB030003FBFBFBFBFBFBFBFB0700A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A403FBFBFBFBFBFBFBFB000000FBFBFBFBFBFBFBFB00A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A403FBFBFBFBFBFBFB0700000007FBFBFBFBFBFB0700A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFB0300000003FBFB
            FBFBFBFB00A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFB
            FB0000000000FBFBFBFBFB0700A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A403FBFBFBFBFB0000000000FBFBFBFBFB00A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFB0000000000FBFBFBFB0700A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFB0000000000FBFB
            FBFB00A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFB
            FB0000000000FBFBFB0700A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A403FBFBFB0700000007FBFBFB00A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFBFBFBFBFB0700A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFBFBFBFB
            00A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FB
            FBFBFBFBFBFBFB0700A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A403FBFBFBFBFBFBFB00A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFBFB0700A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A403FBFBFBFBFB00A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            03FBFBFBFB0700A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A403FBFB0700A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4030303A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4A4
            A4A4}
          Transparent = True
        end
      end
    end
    object tsTaxRates: TTabSheet
      Caption = '&Other Rates'
      ImageIndex = 5
      object Label3: TLabel
        Left = 311
        Top = 25
        Width = 32
        Height = 13
        Caption = 'Rate 3'
      end
      object Label4: TLabel
        Left = 231
        Top = 25
        Width = 32
        Height = 13
        Caption = 'Rate 2'
      end
      object Label17: TLabel
        Left = 143
        Top = 25
        Width = 32
        Height = 13
        Caption = 'Rate 1'
      end
      object lh10: TLabel
        Left = 16
        Top = 3
        Width = 66
        Height = 13
        Caption = 'Company Tax'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Bevel7: TBevel
        Left = 114
        Top = 9
        Width = 457
        Height = 9
        Shape = bsTopLine
      end
      object Label18: TLabel
        Left = 20
        Top = 45
        Width = 74
        Height = 13
        Caption = 'Effective Dates'
      end
      object Label19: TLabel
        Left = 20
        Top = 79
        Width = 23
        Height = 13
        Caption = 'Rate'
      end
      object EDateT3: TOvcPictureField
        Left = 296
        Top = 44
        Width = 86
        Height = 22
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
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
        TabOrder = 4
        OnDblClick = EDateT1DblClick
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object EDateT2: TOvcPictureField
        Left = 213
        Top = 44
        Width = 77
        Height = 22
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
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
        TabOrder = 2
        OnDblClick = EDateT1DblClick
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object EDateT1: TOvcPictureField
        Left = 128
        Top = 44
        Width = 79
        Height = 22
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
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
        TabOrder = 0
        OnDblClick = EDateT1DblClick
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object eRate3: TOvcPictureField
        Left = 296
        Top = 76
        Width = 86
        Height = 22
        Cursor = crIBeam
        DataType = pftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
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
        MaxLength = 9
        Options = [efoCaretToEnd]
        PictureMask = '####.####'
        TabOrder = 5
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
      object ERate2: TOvcPictureField
        Left = 213
        Top = 76
        Width = 77
        Height = 22
        Cursor = crIBeam
        DataType = pftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
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
        MaxLength = 9
        Options = [efoCaretToEnd]
        PictureMask = '####.####'
        TabOrder = 3
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
      object eRate1: TOvcPictureField
        Left = 128
        Top = 76
        Width = 79
        Height = 22
        Cursor = crIBeam
        DataType = pftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
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
        MaxLength = 9
        Options = [efoCaretToEnd]
        PictureMask = '####.####'
        TabOrder = 1
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
      object btndefaultTax: TButton
        Left = 5
        Top = 322
        Width = 108
        Height = 25
        Caption = '&Load Defaults'
        TabOrder = 6
        OnClick = btndefaultTaxClick
      end
    end
  end
  object btnOk: TButton
    Left = 495
    Top = 417
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 579
    Top = 417
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object OvcController1: TOvcController
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
    Left = 80
    Top = 376
  end
  object colDesc: TOvcTCString
    MaxLength = 60
    Table = tblRates
    Left = 112
    Top = 376
  end
  object colRate1: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '###.####'
    Table = tblRates
    Left = 176
    Top = 376
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object colRate2: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '###.####'
    Table = tblRates
    Left = 216
    Top = 376
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object colRate3: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '###.####'
    Table = tblRates
    Left = 256
    Top = 376
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object colAccount: TOvcTCString
    MaxLength = 10
    Table = tblRates
    OnChange = colAccountChange
    OnExit = colAccountExit
    OnKeyDown = colAccountKeyDown
    OnKeyPress = colAccountKeyPress
    OnKeyUp = colAccountKeyUp
    OnOwnerDraw = colAccountOwnerDraw
    Left = 296
    Top = 376
  end
  object colHeader: TOvcTCColHead
    Headings.Strings = (
      'ID'
      'Class Description'
      'GST Type'
      'Rate 1'
      'Rate 2'
      'Rate 3'
      'Control A/c'
      'Norm %'
      '')
    ShowLetters = False
    Table = tblRates
    Left = 48
    Top = 376
  end
  object ColID: TOvcTCString
    MaxLength = 3
    Table = tblRates
    Left = 16
    Top = 376
  end
  object celGSTType: TOvcTCComboBox
    DropDownCount = 10
    Items.Strings = (
      'Income'
      'Expenditure'
      'Exempt'
      'Zero Rated')
    MaxLength = 15
    Style = csOwnerDrawFixed
    Table = tblRates
    OnDropDown = celGSTTypeDropDown
    Left = 144
    Top = 376
  end
  object colNormPercent: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '###.##'
    Table = tblRates
    Left = 328
    Top = 376
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
end
