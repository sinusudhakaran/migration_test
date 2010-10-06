object dlgEditDesktopFields: TdlgEditDesktopFields
  Left = 317
  Top = 224
  BorderStyle = bsDialog
  Caption = 'Superfund Details'
  ClientHeight = 545
  ClientWidth = 621
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poDefault
  PrintScale = poPrintToFit
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFooters: TPanel
    Left = 0
    Top = 504
    Width = 621
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnOK: TButton
      Left = 456
      Top = 8
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 3
    end
    object btnCancel: TButton
      Left = 536
      Top = 8
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 4
    end
    object btnClear: TButton
      Left = 17
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Clear All'
      TabOrder = 0
      OnClick = btnClearClick
    end
    object btnBack: TBitBtn
      Left = 275
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Prev'
      TabOrder = 1
      OnClick = btnBackClick
      Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF0000000000000000000000000000000000BDBD0000BDBD0000BDBD00000000
        0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF0000000000BDBD0000BDBD0000BDBD0000BDBD0000BDBD0000BDBD
        0000BDBD000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD0000BDBD0000BDBD
        000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD000000000000FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
    end
    object btnNext: TBitBtn
      Left = 356
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Next'
      TabOrder = 2
      OnClick = btnNextClick
      Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD000000000000FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD0000BDBD0000BDBD
        000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF0000000000BDBD0000BDBD0000BDBD0000BDBD0000BDBD0000BDBD
        0000BDBD000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF0000000000000000000000000000000000BDBD0000BDBD0000BDBD00000000
        0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
      Layout = blGlyphRight
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 621
    Height = 55
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      621
      55)
    object Label10: TLabel
      Left = 8
      Top = 5
      Width = 23
      Height = 13
      Caption = 'Date'
    end
    object lblDate: TLabel
      Left = 8
      Top = 29
      Width = 44
      Height = 13
      Caption = '06/01/02'
    end
    object lblAmount: TLabel
      Left = 72
      Top = 29
      Width = 113
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = '-125.00'
    end
    object lblAmountlbl: TLabel
      Left = 148
      Top = 5
      Width = 37
      Height = 13
      Alignment = taRightJustify
      Caption = 'Amount'
    end
    object Label12: TLabel
      Left = 198
      Top = 5
      Width = 45
      Height = 13
      Caption = 'Narration'
    end
    object lblNarration: TLabel
      Left = 198
      Top = 29
      Width = 349
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'NC JAME JAME'
      ShowAccelChar = False
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 55
    Width = 621
    Height = 449
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object Label15: TLabel
      Left = 21
      Top = 65
      Width = 83
      Height = 13
      Caption = 'Investment Code'
    end
    object Label3: TLabel
      Left = 320
      Top = 65
      Width = 73
      Height = 13
      Caption = 'CGT / Tax date'
    end
    object Label8: TLabel
      Left = 320
      Top = 93
      Width = 96
      Height = 13
      Caption = 'Undeducted Contrib'
    end
    object Label13: TLabel
      Left = 20
      Top = 93
      Width = 80
      Height = 13
      Caption = 'Member Account'
    end
    object lblLedgerID: TLabel
      Left = 21
      Top = 11
      Width = 72
      Height = 13
      Caption = 'Selected Fund:'
    end
    object Label18: TLabel
      Left = 20
      Top = 37
      Width = 83
      Height = 13
      Caption = 'Transaction Type'
    end
    object Label26: TLabel
      Left = 320
      Top = 11
      Width = 39
      Height = 13
      Caption = 'Account'
    end
    object Label27: TLabel
      Left = 320
      Top = 37
      Width = 24
      Height = 13
      Caption = 'Units'
    end
    object lblLedger: TLabel
      Left = 164
      Top = 11
      Width = 140
      Height = 39
      AutoSize = False
      Caption = '<none>'
      WordWrap = True
    end
    object btnChart: TSpeedButton
      Left = 581
      Top = 7
      Width = 28
      Height = 22
      Glyph.Data = {
        36060000424D3606000000000000360000002800000020000000100000000100
        18000000000000060000C21E0000C21E00000000000000000000FF00FF844200
        8442004242424242424242424242424242424242424242424242424242424242
        42000000FF00FFFF00FFFFFFFFE6E6E622222222222242424242424242424242
        4242424242424242424242424242424242424242000000E6E6E6FF00FF844200
        C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6C6C6C6C6C6C6C6C6C6C6
        C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200844200844200844200844200844200424242C6C6C6C6C6C6C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C622222222222222222222
        2222222222222222424242C6C6C6C6C6C6C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF844200FFFFFF000000C6C6C6C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFF222222FFFFFF000000C6C6C6C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200FFFFFF00FFFFFFFFFF00FFFF84420000FFFFFFFFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FFFFFFFDFDFDFF
        FFFFFDFDFD222222FDFDFDFFFFFF222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF844200844200844200844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFF222222222222222222222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200FFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FFFFFFFDFDFDFF
        FFFFFDFDFDFFFFFFFDFDFDFFFFFF222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFFFDFDFDFFFFFFFDFDFD222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200FFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FFFFFFFDFDFDFF
        FFFFFDFDFDFFFFFFFDFDFDFFFFFF222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFFFDFDFDFFFFFFFDFDFD222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200FFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FFFFFFFDFDFDFF
        FFFFFDFDFDFFFFFFFDFDFDFFFFFF222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFFFDFDFDFFFFFFFDFDFD222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200424242846363846363846363846363846363424242424242C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C622222242424264646464
        6464646464646464646464424242424242C6C6C6000000E6E6E6FF00FF844200
        844200844200424242000000FFFFFFFFFFFFFFFFFF8484840000000000000000
        00000000FF00FFFF00FFFFFFFFE6E6E6222222222222222222424242000000FF
        FFFFFFFFFFFFFFFF848484000000000000000000000000E6E6E6FF00FFFF00FF
        FF00FFFF00FFFF00FF000000C6C6C6C6C6C6C6C6C6424242FF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFFFFFFE6E6E6E6E6E6E6E6E6E6E6E6E6E6E6000000C6
        C6C6C6C6C6C6C6C6424242E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6FF00FFFF00FF
        FF00FFFF00FFFF00FF000000424242000000424242422121FF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFFFFFFE6E6E6E6E6E6E6E6E6E6E6E6E6E6E600000042
        4242000000424242222222E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6}
      NumGlyphs = 2
      OnClick = btnChartClick
    end
    object gbTax: TGroupBox
      Left = 9
      Top = 351
      Width = 604
      Height = 77
      Caption = 'Tax Credits'
      TabOrder = 11
      object Label19: TLabel
        Left = 16
        Top = 52
        Width = 89
        Height = 13
        Caption = 'Foreign Tax Credit'
      end
      object Label25: TLabel
        Left = 311
        Top = 25
        Width = 52
        Height = 13
        Caption = 'ABN Credit'
      end
      object Label24: TLabel
        Left = 16
        Top = 25
        Width = 51
        Height = 13
        Caption = 'TFN Credit'
      end
      object nfForeignCGCredit: TOvcNumericField
        Left = 156
        Top = 49
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 1
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfTFNCredits: TOvcNumericField
        Left = 156
        Top = 23
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 0
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfOtherTaxCredit: TOvcNumericField
        Left = 442
        Top = 23
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 2
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
    end
    object gbRevenue: TGroupBox
      Left = 8
      Top = 121
      Width = 605
      Height = 169
      Caption = 'Gross Breakdown'
      TabOrder = 9
      DesignSize = (
        605
        169)
      object lblFranked: TLabel
        Left = 16
        Top = 25
        Width = 39
        Height = 13
        Caption = 'Franked'
      end
      object lblUnFranked: TLabel
        Left = 16
        Top = 50
        Width = 50
        Height = 13
        Caption = 'Unfranked'
      end
      object Label4: TLabel
        Left = 16
        Top = 75
        Width = 74
        Height = 13
        Caption = 'Foreign Income'
      end
      object Label16: TLabel
        Left = 16
        Top = 125
        Width = 88
        Height = 13
        Caption = 'Capital Gain Other'
      end
      object Label21: TLabel
        Left = 312
        Top = 50
        Width = 84
        Height = 13
        Caption = 'Capital Gain Conc'
      end
      object Label22: TLabel
        Left = 312
        Top = 24
        Width = 79
        Height = 13
        Caption = 'Capital Gain Disc'
      end
      object Label5: TLabel
        Left = 16
        Top = 100
        Width = 69
        Height = 13
        Caption = 'Other Taxable'
      end
      object Label6: TLabel
        Left = 312
        Top = 75
        Width = 64
        Height = 13
        Caption = 'Tax Deferred'
      end
      object Label7: TLabel
        Left = 312
        Top = 100
        Width = 71
        Height = 13
        Caption = 'Tax Free Trust'
      end
      object Label14: TLabel
        Left = 312
        Top = 125
        Width = 61
        Height = 13
        Caption = 'Non-Taxable'
      end
      object lp1: TLabel
        Left = 285
        Top = 24
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfFranked
      end
      object lp2: TLabel
        Left = 285
        Top = 50
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfUnfranked
      end
      object lblRemain: TLabel
        Left = 473
        Top = 149
        Width = 100
        Height = 17
        Alignment = taRightJustify
        Anchors = [akLeft, akBottom]
        AutoSize = False
        Caption = '$0.00'
      end
      object Label23: TLabel
        Left = 312
        Top = 150
        Width = 52
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Remaining '
      end
      object lp4: TLabel
        Left = 285
        Top = 75
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfForeignIncome
      end
      object lp5: TLabel
        Left = 285
        Top = 100
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfOtherExpenses
      end
      object lp6: TLabel
        Left = 285
        Top = 125
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfCapitalGainsOther
      end
      object lp7: TLabel
        Left = 573
        Top = 25
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfDiscountedCapitalGains
      end
      object lp8: TLabel
        Left = 573
        Top = 50
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfCapitalGains
      end
      object lp9: TLabel
        Left = 573
        Top = 75
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfTaxDeferredDist
      end
      object lp10: TLabel
        Left = 573
        Top = 100
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfTaxFreeDist
      end
      object lp11: TLabel
        Left = 573
        Top = 125
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfTaxExemptDist
      end
      object nfFranked: TOvcNumericField
        Left = 156
        Top = 23
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 0
        OnChange = nfFrankedChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {00000000000000000000}
      end
      object nfUnfranked: TOvcNumericField
        Left = 156
        Top = 48
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 1
        OnChange = nfUnfrankedChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {00000000000000000000}
      end
      object nfForeignIncome: TOvcNumericField
        Left = 156
        Top = 73
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 2
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfCapitalGainsOther: TOvcNumericField
        Left = 156
        Top = 123
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 4
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfCapitalGains: TOvcNumericField
        Left = 442
        Top = 48
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 7
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfDiscountedCapitalGains: TOvcNumericField
        Left = 442
        Top = 23
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 6
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfOtherExpenses: TOvcNumericField
        Left = 156
        Top = 98
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 3
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {0090C2F5FF276BEE1CC0}
      end
      object nfTaxDeferredDist: TOvcNumericField
        Left = 442
        Top = 73
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 8
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfTaxFreeDist: TOvcNumericField
        Left = 442
        Top = 98
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 9
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {0090C2F5FF276BEE1CC0}
      end
      object nfTaxExemptDist: TOvcNumericField
        Left = 442
        Top = 123
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 10
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {0090C2F5FF276BEE1CC0}
      end
      object btnThird: TButton
        Left = 413
        Top = 22
        Width = 27
        Height = 21
        Caption = '2/3'
        TabOrder = 5
        OnClick = btnThirdClick
      end
    end
    object eCGTDate: TOvcPictureField
      Left = 450
      Top = 62
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = pftDate
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
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
      TabOrder = 7
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object nfContrib: TOvcNumericField
      Left = 450
      Top = 90
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 8
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object cmbFund: TComboBox
      Left = 164
      Top = 62
      Width = 145
      Height = 21
      ItemHeight = 13
      MaxLength = 20
      TabOrder = 3
      Text = '1212'
      OnCloseUp = cmbFundCloseUp
      OnDropDown = cmbMemberDropDown
    end
    object cmbMember: TComboBox
      Left = 164
      Top = 90
      Width = 145
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 4
      OnDrawItem = cmbMemberDrawItem
      OnDropDown = cmbMemberDropDown
    end
    object cmbTrans: TComboBox
      Left = 164
      Top = 34
      Width = 145
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 2
      OnDrawItem = cmbTransDrawItem
      OnDropDown = cmbTransDropDown
    end
    object nfUnits: TOvcNumericField
      Left = 450
      Top = 34
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '###,###,###.####'
      TabOrder = 6
      OnKeyDown = nfUnitsKeyDown
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object GroupBox1: TGroupBox
      Left = 9
      Top = 296
      Width = 604
      Height = 49
      TabOrder = 10
      object lblGrosstext: TLabel
        Left = 16
        Top = 17
        Width = 67
        Height = 13
        Caption = 'Gross Amount'
      end
      object Label9: TLabel
        Left = 311
        Top = 17
        Width = 78
        Height = 13
        Caption = 'Franking Credits'
      end
      object lblGross: TLabel
        Left = 160
        Top = 17
        Width = 124
        Height = 16
        Alignment = taRightJustify
        AutoSize = False
        Caption = '$0.00'
      end
      object btnCalc: TSpeedButton
        Left = 573
        Top = 13
        Width = 28
        Height = 22
        Glyph.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000FFFFFF000000
          000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
          FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000FFFFFF000000
          0000FFFFFF00848484000000000000FFFF008484840000000000FFFFFF008484
          84000000000000FFFF008484840000000000FFFFFF0000000000FFFFFF000000
          000000FFFF00FFFFFF000000000000FFFF00FFFFFF000000000000FFFF00FFFF
          FF000000000000FFFF00FFFFFF000000000000FFFF0000000000FFFFFF000000
          0000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
          FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000FFFFFF000000
          000000FFFF00848484000000000000FFFF00848484000000000000FFFF008484
          84000000000000FFFF00848484000000000000FFFF0000000000FFFFFF000000
          000000FFFF00FFFFFF000000000000FFFF00FFFFFF000000000000FFFF00FFFF
          FF000000000000FFFF00FFFFFF000000000000FFFF0000000000FFFFFF000000
          0000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
          FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000FFFFFF000000
          000000FFFF000000000000000000000000000000000000000000000000000000
          0000000000000000000000FFFF00FFFFFF0000FFFF0000000000FFFFFF000000
          000000FFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF000000000000FFFF0000FFFF0000FFFF0000000000FFFFFF000000
          000000FFFF000000000000000000000000000000000000000000000000000000
          00000000000000000000FFFFFF0000FFFF00FFFFFF0000000000FFFFFF000000
          000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
          FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000FFFFFF00FFFF
          FF00000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
        OnClick = btnCalcClick
      end
      object nfImputedCredit: TOvcNumericField
        Left = 442
        Top = 15
        Width = 129
        Height = 20
        Cursor = crIBeam
        DataType = nftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Options = []
        PictureMask = '#,###,###,###.##'
        TabOrder = 0
        OnChange = nfImputedCreditChange
        OnKeyPress = nfImputedCreditKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {00000000000000000000}
      end
    end
    object cmbxAccount: TcxComboBox
      Left = 450
      Top = 6
      Properties.Alignment.Horz = taLeftJustify
      Properties.DropDownAutoWidth = False
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownWidth = 300
      Properties.PopupAlignment = taRightJustify
      Properties.OnChange = cmbxAccountPropertiesChange
      Properties.OnDrawItem = cmbxAccountPropertiesDrawItem
      Style.BorderStyle = ebs3D
      Style.LookAndFeel.Kind = lfStandard
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.TransparentBorder = True
      Style.ButtonStyle = bts3D
      Style.PopupBorderStyle = epbsDefault
      StyleDisabled.LookAndFeel.Kind = lfStandard
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfStandard
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfStandard
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 5
      OnKeyDown = cmbxAccountKeyDown
      Width = 129
    end
    object cmbSelectedFund: TComboBox
      Left = 205
      Top = 6
      Width = 145
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 1
      Visible = False
      OnChange = cmbSelectedFundChange
      OnDropDown = cmbSelectedFundDropDown
    end
    object cmbClassSuperFund: TComboBox
      Left = 214
      Top = -4
      Width = 145
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 0
      Visible = False
      OnChange = cmbClassSuperFundChange
      OnDropDown = cmbClassSuperFundDropDown
    end
  end
end
