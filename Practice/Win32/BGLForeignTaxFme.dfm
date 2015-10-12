object fmeBGLForeignTax: TfmeBGLForeignTax
  Left = 0
  Top = 0
  Width = 442
  Height = 159
  TabOrder = 0
  object lblForeignIncomeTaxOffset: TLabel
    Left = 3
    Top = 5
    Width = 129
    Height = 13
    Caption = 'Foreign Income Tax Offset'
    FocusControl = nfForeignIncomeTaxOffset
  end
  object lpForeignIncomeTaxOffset: TLabel
    Left = 380
    Top = 5
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfForeignIncomeTaxOffset
    Visible = False
  end
  object lblAUFrankingCreditsFromNZCompany: TLabel
    Left = 3
    Top = 37
    Width = 186
    Height = 13
    Caption = 'AU Franking Credits from an NZ Company'
    FocusControl = nfAUFrankingCreditsFromNZCompany
  end
  object lpAUFrankingCreditsFromNZCompany: TLabel
    Left = 380
    Top = 37
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfAUFrankingCreditsFromNZCompany
    Visible = False
  end
  object lblTFNAmountsWithheld: TLabel
    Left = 3
    Top = 69
    Width = 103
    Height = 13
    Caption = 'TFN Amounts Witheld'
    FocusControl = nfTFNAmountsWithheld
  end
  object lpTFNAmountsWithheld: TLabel
    Left = 380
    Top = 69
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfTFNAmountsWithheld
    Visible = False
  end
  object lblNonResidentWithholdingTax: TLabel
    Left = 3
    Top = 101
    Width = 145
    Height = 13
    Caption = 'Non-Resident Withholding Tax'
    FocusControl = nfNonResidentWithholdingTax
  end
  object lpNonResidentWithholdingTax: TLabel
    Left = 380
    Top = 101
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfNonResidentWithholdingTax
    Visible = False
  end
  object lblLICDeductions: TLabel
    Left = 3
    Top = 133
    Width = 72
    Height = 13
    Caption = 'LIC Deductions'
    FocusControl = nfLICDeductions
  end
  object lpLICDeductions: TLabel
    Left = 380
    Top = 133
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfLICDeductions
    Visible = False
  end
  object nfForeignIncomeTaxOffset: TOvcNumericField
    Left = 250
    Top = 3
    Width = 132
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
    RangeHigh = {F6285CFFFFF802952040}
    RangeLow = {5C8FC2F5FF276BEE1CC0}
  end
  object nfAUFrankingCreditsFromNZCompany: TOvcNumericField
    Left = 250
    Top = 35
    Width = 132
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
    RangeHigh = {F6285CFFFFF802952040}
    RangeLow = {5C8FC2F5FF276BEE1CC0}
  end
  object nfTFNAmountsWithheld: TOvcNumericField
    Left = 250
    Top = 67
    Width = 132
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
    RangeHigh = {F6285CFFFFF802952040}
    RangeLow = {5C8FC2F5FF276BEE1CC0}
  end
  object nfNonResidentWithholdingTax: TOvcNumericField
    Left = 250
    Top = 99
    Width = 132
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
    RangeHigh = {F6285CFFFFF802952040}
    RangeLow = {5C8FC2F5FF276BEE1CC0}
  end
  object nfLICDeductions: TOvcNumericField
    Left = 250
    Top = 131
    Width = 132
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
    RangeHigh = {F6285CFFFFF802952040}
    RangeLow = {5C8FC2F5FF276BEE1CC0}
  end
end
