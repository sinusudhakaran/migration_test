object fmeBGLFranking: TfmeBGLFranking
  Left = 0
  Top = 0
  Width = 442
  Height = 90
  TabOrder = 0
  object lblFranked: TLabel
    Left = 3
    Top = 3
    Width = 79
    Height = 13
    Caption = 'Franked Amount'
    FocusControl = nfFranked
  end
  object lpFranked: TLabel
    Left = 380
    Top = 3
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfFranked
    Visible = False
  end
  object lblUnfranked: TLabel
    Left = 3
    Top = 35
    Width = 90
    Height = 13
    Caption = 'Unfranked Amount'
    FocusControl = nfUnfranked
  end
  object lpUnfranked: TLabel
    Left = 380
    Top = 35
    Width = 11
    Height = 13
    Caption = '%'
    FocusControl = nfUnfranked
    Visible = False
  end
  object lblFrankingCredits: TLabel
    Left = 3
    Top = 67
    Width = 78
    Height = 13
    Caption = 'Franking Credits'
    FocusControl = nfFrankingCredits
  end
  object btnFrankingCredits: TSpeedButton
    Left = 382
    Top = 63
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
  end
  object nfFranked: TOvcNumericField
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
  object nfUnfranked: TOvcNumericField
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
  object nfFrankingCredits: TOvcNumericField
    Left = 250
    Top = 65
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
    RangeLow = {00000000000000000000}
  end
end
