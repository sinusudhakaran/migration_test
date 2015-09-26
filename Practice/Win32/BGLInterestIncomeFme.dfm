object fmeBGLInterestIncome: TfmeBGLInterestIncome
  Left = 0
  Top = 0
  Width = 442
  Height = 54
  TabOrder = 0
  object lblInterest: TLabel
    Left = 3
    Top = 3
    Width = 69
    Height = 13
    Caption = 'Gross Interest'
    FocusControl = nfInterest
  end
  object lpInterest: TLabel
    Left = 380
    Top = 3
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfInterest
    Visible = False
  end
  object lpOtherIncome: TLabel
    Left = 380
    Top = 35
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfOtherIncome
    Visible = False
  end
  object lblOtherIncome: TLabel
    Left = 3
    Top = 35
    Width = 66
    Height = 13
    Caption = 'Other Income'
    FocusControl = nfOtherIncome
  end
  object nfInterest: TOvcNumericField
    Left = 250
    Top = 1
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
    RangeLow = {00000000000000000000}
  end
  object nfOtherIncome: TOvcNumericField
    Left = 250
    Top = 33
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
    RangeLow = {00000000000000000000}
  end
end
