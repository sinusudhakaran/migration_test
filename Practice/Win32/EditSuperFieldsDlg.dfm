object dlgEditSuperFields: TdlgEditSuperFields
  Left = 415
  Top = 256
  BorderStyle = bsDialog
  Caption = 'Superfund Details'
  ClientHeight = 419
  ClientWidth = 628
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PrintScale = poPrintToFit
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFooters: TPanel
    Left = 0
    Top = 381
    Width = 628
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnOK: TButton
      Left = 463
      Top = 6
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 544
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnClear: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Clear All'
      TabOrder = 2
      OnClick = btnClearClick
    end
    object btnBack: TBitBtn
      Left = 283
      Top = 6
      Width = 75
      Height = 25
      Caption = '&Prev'
      TabOrder = 3
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
      Left = 364
      Top = 6
      Width = 75
      Height = 25
      Caption = '&Next'
      TabOrder = 4
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
    Height = 73
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      628
      73)
    object Label10: TLabel
      Left = 8
      Top = 16
      Width = 23
      Height = 13
      Caption = 'Date'
    end
    object lblDate: TLabel
      Left = 8
      Top = 40
      Width = 33
      Height = 13
      Caption = 'lblDate'
    end
    object lblAmount: TLabel
      Left = 72
      Top = 40
      Width = 113
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lblAmount'
    end
    object lblamountlbl: TLabel
      Left = 136
      Top = 16
      Width = 37
      Height = 13
      Caption = 'Amount'
    end
    object Label12: TLabel
      Left = 200
      Top = 16
      Width = 45
      Height = 13
      Caption = 'Narration'
    end
    object lblNarration: TLabel
      Left = 200
      Top = 40
      Width = 419
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'lblNarration'
      ExplicitWidth = 407
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 73
    Width = 628
    Height = 308
    Align = alClient
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 138
      Width = 72
      Height = 13
      Caption = 'Imputed Credit'
    end
    object Label2: TLabel
      Left = 8
      Top = 170
      Width = 64
      Height = 13
      Caption = 'Tax Free Dist'
    end
    object Label3: TLabel
      Left = 8
      Top = 202
      Width = 78
      Height = 13
      Caption = 'Tax Exempt Dist'
    end
    object Label4: TLabel
      Left = 8
      Top = 235
      Width = 85
      Height = 13
      Caption = 'Tax Deferred Dist'
    end
    object Label5: TLabel
      Left = 312
      Top = 42
      Width = 56
      Height = 13
      Caption = 'TFN Credits'
    end
    object Label6: TLabel
      Left = 312
      Top = 74
      Width = 74
      Height = 13
      Caption = 'Foreign Income'
    end
    object Label7: TLabel
      Left = 312
      Top = 106
      Width = 94
      Height = 13
      Caption = 'Foreign Tax Credits'
    end
    object Label8: TLabel
      Left = 312
      Top = 170
      Width = 105
      Height = 13
      Caption = 'Capital Gains Indexed'
    end
    object Label9: TLabel
      Left = 312
      Top = 202
      Width = 118
      Height = 13
      Caption = 'Capital Gains Discounted'
    end
    object Label13: TLabel
      Left = 312
      Top = 235
      Width = 93
      Height = 13
      Caption = 'Capital Gains Other'
    end
    object Label14: TLabel
      Left = 312
      Top = 138
      Width = 77
      Height = 13
      Caption = 'Other Expenses'
    end
    object Label15: TLabel
      Left = 8
      Top = 42
      Width = 45
      Height = 13
      Caption = 'CGT date'
    end
    object lblFranked: TLabel
      Left = 8
      Top = 74
      Width = 79
      Height = 13
      Caption = 'Franked Amount'
    end
    object lblUnfranked: TLabel
      Left = 8
      Top = 106
      Width = 90
      Height = 13
      Caption = 'Unfranked Amount'
    end
    object Label18: TLabel
      Left = 8
      Top = 267
      Width = 96
      Height = 13
      Caption = 'Member Component'
    end
    object Label26: TLabel
      Left = 8
      Top = 9
      Width = 39
      Height = 13
      Caption = 'Account'
    end
    object btnChart: TSpeedButton
      Left = 271
      Top = 6
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
    object Label27: TLabel
      Left = 308
      Top = 9
      Width = 42
      Height = 13
      Caption = 'Quantity'
    end
    object btnCalc: TSpeedButton
      Left = 271
      Top = 134
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
    object lP1: TLabel
      Left = 269
      Top = 74
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfFranked
      Visible = False
    end
    object lp2: TLabel
      Left = 269
      Top = 106
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfUnfranked
      Visible = False
    end
    object lp4: TLabel
      Left = 269
      Top = 170
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfTaxFreeDist
      Visible = False
    end
    object lp5: TLabel
      Left = 269
      Top = 202
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfTaxExemptDist
      Visible = False
    end
    object lp6: TLabel
      Left = 269
      Top = 235
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfTaxDeferredDist
      Visible = False
    end
    object lp8: TLabel
      Left = 602
      Top = 42
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfTFNCredits
      Visible = False
    end
    object lp9: TLabel
      Left = 602
      Top = 74
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfForeignIncome
      Visible = False
    end
    object lp10: TLabel
      Left = 602
      Top = 106
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfForeignTaxCredits
      Visible = False
    end
    object lp11: TLabel
      Left = 602
      Top = 138
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfOtherExpenses
      Visible = False
    end
    object lp12: TLabel
      Left = 602
      Top = 170
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfCapitalGains
      Visible = False
    end
    object lp13: TLabel
      Left = 602
      Top = 202
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfDiscountedCapitalGains
      Visible = False
    end
    object lp14: TLabel
      Left = 602
      Top = 235
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = nfCapitalGainsOther
      Visible = False
    end
    object nfImputedCredit: TOvcNumericField
      Left = 139
      Top = 136
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
      OnChange = nfImputedCreditChange
      OnKeyPress = nfTFNCreditsKeyPress
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfTaxFreeDist: TOvcNumericField
      Left = 139
      Top = 168
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
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object nfTaxExemptDist: TOvcNumericField
      Left = 139
      Top = 200
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
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object nfTaxDeferredDist: TOvcNumericField
      Left = 139
      Top = 233
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
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object nfTFNCredits: TOvcNumericField
      Left = 472
      Top = 40
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
      OnKeyPress = nfTFNCreditsKeyPress
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfForeignIncome: TOvcNumericField
      Left = 472
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
      TabOrder = 11
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object nfForeignTaxCredits: TOvcNumericField
      Left = 472
      Top = 104
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
      OnKeyPress = nfTFNCreditsKeyPress
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfCapitalGains: TOvcNumericField
      Left = 472
      Top = 168
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
      TabOrder = 14
      OnKeyPress = nfTFNCreditsKeyPress
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfDiscountedCapitalGains: TOvcNumericField
      Left = 472
      Top = 200
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
      TabOrder = 15
      OnKeyPress = nfTFNCreditsKeyPress
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfCapitalGainsOther: TOvcNumericField
      Left = 472
      Top = 233
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
      TabOrder = 16
      OnKeyPress = nfTFNCreditsKeyPress
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfOtherExpenses: TOvcNumericField
      Left = 472
      Top = 136
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
      OnKeyPress = nfTFNCreditsKeyPress
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object eCGTDate: TOvcPictureField
      Left = 139
      Top = 40
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
      TabOrder = 1
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object nfFranked: TOvcNumericField
      Left = 139
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
      OnChange = nfFrankedChange
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfUnfranked: TOvcNumericField
      Left = 139
      Top = 104
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
      OnChange = nfUnfrankedChange
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object cmbMember: TComboBox
      Left = 139
      Top = 264
      Width = 334
      Height = 21
      Style = csDropDownList
      ItemHeight = 0
      TabOrder = 8
    end
    object nfUnits: TOvcNumericField
      Left = 472
      Top = 9
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
      TabOrder = 9
      OnKeyDown = nfUnitsKeyDown
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object cmbxAccount: TcxComboBox
      Left = 136
      Top = 6
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
      Width = 131
    end
  end
end
