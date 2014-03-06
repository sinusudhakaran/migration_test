object dlgEditSupervisorFields: TdlgEditSupervisorFields
  Scaled = False
Left = 317
  Top = 224
  BorderStyle = bsDialog
  Caption = 'Superfund Details'
  ClientHeight = 492
  ClientWidth = 628
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
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
    Top = 446
    Width = 628
    Height = 46
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      628
      46)
    object btnOK: TButton
      Left = 463
      Top = 13
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 3
    end
    object btnCancel: TButton
      Left = 543
      Top = 13
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 4
    end
    object btnClear: TButton
      Left = 8
      Top = 13
      Width = 75
      Height = 25
      Caption = 'Clear All'
      TabOrder = 0
      OnClick = btnClearClick
    end
    object btnBack: TBitBtn
      Left = 282
      Top = 13
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
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
      Left = 363
      Top = 13
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
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
    Width = 628
    Height = 55
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    DesignSize = (
      628
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
      Left = 200
      Top = 5
      Width = 45
      Height = 13
      Caption = 'Narration'
    end
    object lblNarration: TLabel
      Left = 200
      Top = 29
      Width = 419
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'NC JAME JAME'
      ExplicitWidth = 412
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 55
    Width = 628
    Height = 391
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    object Label15: TLabel
      Left = 19
      Top = 36
      Width = 52
      Height = 13
      Caption = 'Member ID'
    end
    object Label27: TLabel
      Left = 19
      Top = 6
      Width = 39
      Height = 13
      Caption = 'Account'
    end
    object btnChart: TSpeedButton
      Left = 294
      Top = 5
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
    object Label28: TLabel
      Left = 333
      Top = 6
      Width = 42
      Height = 13
      Caption = 'Quantity'
    end
    object lMember: TLabel
      Left = 298
      Top = 36
      Width = 4
      Height = 13
      Caption = '-'
    end
    object gbTax: TGroupBox
      Left = 7
      Top = 277
      Width = 611
      Height = 105
      Caption = 'Tax Effect Items'
      TabOrder = 3
      object Label9: TLabel
        Left = 16
        Top = 25
        Width = 84
        Height = 13
        Caption = 'Imputation Credit'
      end
      object Label13: TLabel
        Left = 16
        Top = 50
        Width = 68
        Height = 13
        Caption = 'Foreign Credit'
      end
      object Label19: TLabel
        Left = 16
        Top = 75
        Width = 85
        Height = 13
        Caption = 'Foreign CG Credit'
      end
      object Label24: TLabel
        Left = 325
        Top = 26
        Width = 88
        Height = 13
        Caption = 'Withholding Credit'
      end
      object Label25: TLabel
        Left = 325
        Top = 51
        Width = 81
        Height = 13
        Caption = 'Other Tax Credit'
      end
      object Label26: TLabel
        Left = 325
        Top = 74
        Width = 83
        Height = 13
        Caption = 'Non-resident Tax'
      end
      object btnCalc: TSpeedButton
        Left = 285
        Top = 20
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
        Left = 156
        Top = 22
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
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {0090C2F5FF276BEE1CC0}
      end
      object nfForeignTaxCredits: TOvcNumericField
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
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {0090C2F5FF276BEE1CC0}
      end
      object nfForeignCGCredit: TOvcNumericField
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
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfTFNCredits: TOvcNumericField
        Left = 455
        Top = 22
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
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfOtherTaxCredit: TOvcNumericField
        Left = 455
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
        TabOrder = 4
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfNonResidentTax: TOvcNumericField
        Left = 455
        Top = 74
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
        TabOrder = 5
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
    end
    object gbRevenue: TGroupBox
      Left = 7
      Top = 59
      Width = 611
      Height = 217
      Caption = 'Revenue Items'
      TabOrder = 2
      DesignSize = (
        611
        217)
      object lblFranked: TLabel
        Left = 16
        Top = 25
        Width = 39
        Height = 13
        Caption = 'Franked'
      end
      object lblUnfranked: TLabel
        Left = 16
        Top = 50
        Width = 50
        Height = 13
        Caption = 'Unfranked'
      end
      object Label3: TLabel
        Left = 16
        Top = 75
        Width = 39
        Height = 13
        Caption = 'Interest'
      end
      object Label4: TLabel
        Left = 16
        Top = 100
        Width = 36
        Height = 13
        Caption = 'Foreign'
      end
      object Label16: TLabel
        Left = 16
        Top = 125
        Width = 53
        Height = 13
        Caption = 'Foreign CG'
      end
      object Label17: TLabel
        Left = 16
        Top = 150
        Width = 137
        Height = 16
        AutoSize = False
        Caption = 'Foreign Discount CG'
        WordWrap = True
      end
      object Label18: TLabel
        Left = 16
        Top = 175
        Width = 23
        Height = 13
        Caption = 'Rent'
      end
      object Label21: TLabel
        Left = 326
        Top = 25
        Width = 57
        Height = 13
        Caption = 'Capital Gain'
      end
      object Label22: TLabel
        Left = 326
        Top = 50
        Width = 58
        Height = 13
        Caption = 'Discount CG'
      end
      object Label5: TLabel
        Left = 326
        Top = 75
        Width = 69
        Height = 13
        Caption = 'Other Taxable'
      end
      object Label6: TLabel
        Left = 326
        Top = 100
        Width = 64
        Height = 13
        Caption = 'Tax Deferred'
      end
      object Label7: TLabel
        Left = 326
        Top = 125
        Width = 71
        Height = 13
        Caption = 'Tax Free Trust'
      end
      object Label14: TLabel
        Left = 326
        Top = 150
        Width = 61
        Height = 13
        Caption = 'Non-Taxable'
      end
      object Label8: TLabel
        Left = 326
        Top = 175
        Width = 71
        Height = 13
        Caption = 'Special Income'
      end
      object lP1: TLabel
        Left = 291
        Top = 25
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfFranked
      end
      object lp2: TLabel
        Left = 291
        Top = 50
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfUnfranked
      end
      object Label23: TLabel
        Left = 326
        Top = 196
        Width = 49
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Remaining'
      end
      object lblRemain: TLabel
        Left = 484
        Top = 196
        Width = 100
        Height = 17
        Alignment = taRightJustify
        Anchors = [akLeft, akBottom]
        AutoSize = False
        Caption = '$0.00'
      end
      object lp4: TLabel
        Left = 291
        Top = 75
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfInterest
      end
      object lp5: TLabel
        Left = 291
        Top = 100
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfForeignIncome
      end
      object lp6: TLabel
        Left = 291
        Top = 125
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfCapitalGainsOther
      end
      object lp7: TLabel
        Left = 291
        Top = 150
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfCapitalGainsForeignDisc
      end
      object lp8: TLabel
        Left = 291
        Top = 175
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfRent
      end
      object lp9: TLabel
        Left = 591
        Top = 25
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfCapitalGains
      end
      object lp10: TLabel
        Left = 591
        Top = 50
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfDiscountedCapitalGains
      end
      object lp11: TLabel
        Left = 591
        Top = 75
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfOtherExpenses
      end
      object lp12: TLabel
        Left = 591
        Top = 100
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfTaxDeferredDist
      end
      object lp13: TLabel
        Left = 591
        Top = 125
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfTaxFreeDist
      end
      object lp14: TLabel
        Left = 591
        Top = 150
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfTaxExemptDist
      end
      object lp15: TLabel
        Left = 591
        Top = 175
        Width = 11
        Height = 13
        Caption = '%'
        FocusControl = nfSpecialIncome
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
        RangeLow = {0090C2F5FF276BEE1CC0}
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
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfInterest: TOvcNumericField
        Left = 156
        Top = 72
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
      object nfForeignIncome: TOvcNumericField
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
      object nfCapitalGainsForeignDisc: TOvcNumericField
        Left = 156
        Top = 148
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
        TabOrder = 5
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfRent: TOvcNumericField
        Left = 156
        Top = 173
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
      object nfCapitalGains: TOvcNumericField
        Left = 456
        Top = 22
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
        Left = 456
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
        TabOrder = 8
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfOtherExpenses: TOvcNumericField
        Left = 456
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
        TabOrder = 9
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {0090C2F5FF276BEE1CC0}
      end
      object nfTaxDeferredDist: TOvcNumericField
        Left = 456
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
        TabOrder = 10
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      object nfTaxFreeDist: TOvcNumericField
        Left = 456
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
        TabOrder = 11
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {0090C2F5FF276BEE1CC0}
      end
      object nfTaxExemptDist: TOvcNumericField
        Left = 456
        Top = 148
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
        TabOrder = 12
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {0090C2F5FF276BEE1CC0}
      end
      object nfSpecialIncome: TOvcNumericField
        Left = 456
        Top = 173
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
        TabOrder = 13
        OnChange = nfGeneralChange
        OnExit = nfExit
        OnKeyPress = nfKeyPress
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {0090C2F5FF276BEE1CC0}
      end
    end
    object nfUnits: TOvcNumericField
      Left = 463
      Top = 6
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
      TabOrder = 1
      OnKeyDown = nfUnitsKeyDown
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object cmbxAccount: TcxComboBox
      Left = 163
      Top = 4
      Properties.Alignment.Horz = taLeftJustify
      Properties.DropDownAutoWidth = False
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownWidth = 300
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
      TabOrder = 0
      OnKeyDown = cmbxAccountKeyDown
      Width = 129
    end
    object cmbMembers: TcxComboBox
      Left = 163
      Top = 34
      Properties.Alignment.Horz = taLeftJustify
      Properties.DropDownAutoWidth = False
      Properties.DropDownWidth = 300
      Properties.OnChange = cmbMembersPropertiesChange
      Properties.OnDrawItem = cmbMembersPropertiesDrawItem
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
      TabOrder = 4
      Width = 129
    end
  end
end
