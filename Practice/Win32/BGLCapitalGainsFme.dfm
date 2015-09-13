object fmeBGLCapitalGainsTax: TfmeBGLCapitalGainsTax
  Left = 0
  Top = 0
  Width = 442
  Height = 90
  TabOrder = 0
  object lblCGTDiscounted: TLabel
    Left = 3
    Top = 3
    Width = 200
    Height = 13
    Caption = 'Discounted Capital Gain (Before Discount)'
    FocusControl = nfCGTDiscounted
  end
  object lpCGTDiscounted: TLabel
    Left = 380
    Top = 3
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfCGTDiscounted
    Visible = False
  end
  object lblCGTIndexation: TLabel
    Left = 3
    Top = 35
    Width = 124
    Height = 13
    Caption = 'Capital Gains - Indexation'
    FocusControl = nfCGTIndexation
  end
  object lpCGTIndexation: TLabel
    Left = 380
    Top = 35
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfCGTIndexation
    Visible = False
  end
  object lblCGTOther: TLabel
    Left = 3
    Top = 67
    Width = 139
    Height = 13
    Caption = 'Capital Gains - Other Method'
    FocusControl = nfCGTOther
  end
  object lpCGTOther: TLabel
    Left = 380
    Top = 67
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfCGTOther
    Visible = False
  end
  object nfCGTDiscounted: TOvcNumericField
    Left = 250
    Top = 1
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
    RangeHigh = {F6285CFFFFF802952040}
    RangeLow = {00000000000000000000}
  end
  object nfCGTIndexation: TOvcNumericField
    Left = 250
    Top = 33
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
    RangeHigh = {F6285CFFFFF802952040}
    RangeLow = {00000000000000000000}
  end
  object nfCGTOther: TOvcNumericField
    Left = 250
    Top = 65
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
    RangeHigh = {F6285CFFFFF802952040}
    RangeLow = {00000000000000000000}
  end
end
