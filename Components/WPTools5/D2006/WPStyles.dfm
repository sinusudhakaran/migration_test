object WPStyleDefinition: TWPStyleDefinition
  Left = 26
  Top = 147
  BorderStyle = bsDialog
  Caption = 'Paragraph Styles'
  ClientHeight = 361
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  ShowHint = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Bevel1: TBevel
    Left = 204
    Top = 11
    Width = 350
    Height = 308
    Shape = bsFrame
  end
  object labPreviewParagraph: TLabel
    Left = 204
    Top = 330
    Width = 122
    Height = 16
    Caption = 'Preview - Paragraph'
    Transparent = True
    Visible = False
  end
  object labPreviewFont: TLabel
    Left = 222
    Top = 183
    Width = 84
    Height = 16
    Caption = 'Preview - Font'
    Transparent = True
  end
  object labName: TLabel
    Left = 222
    Top = 22
    Width = 37
    Height = 16
    Caption = 'Name'
    Transparent = True
  end
  object labBasedOn: TLabel
    Left = 222
    Top = 54
    Width = 58
    Height = 16
    Caption = 'Based on'
    Transparent = True
  end
  object NewStyle: TSpeedButton
    Left = 6
    Top = 324
    Width = 44
    Height = 30
    Hint = 'Create a new Style'
    Flat = True
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      0400000000000001000000000000000000001000000010000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0033333333B333
      333B33FF33337F3333F73BB3777BB7777BB3377FFFF77FFFF77333B000000000
      0B3333777777777777333330FFFFFFFF07333337F33333337F333330FFFFFFFF
      07333337F33333337F333330FFFFFFFF07333337F33333337F333330FFFFFFFF
      07333FF7F33333337FFFBBB0FFFFFFFF0BB37777F3333333777F3BB0FFFFFFFF
      0BBB3777F3333FFF77773330FFFF000003333337F333777773333330FFFF0FF0
      33333337F3337F37F3333330FFFF0F0B33333337F3337F77FF333330FFFF003B
      B3333337FFFF77377FF333B000000333BB33337777777F3377FF3BB3333BB333
      3BB33773333773333773B333333B3333333B7333333733333337}
    NumGlyphs = 2
    OnClick = NewStyleClick
  end
  object DelStyle: TSpeedButton
    Left = 54
    Top = 325
    Width = 44
    Height = 30
    Hint = 'Delete the style'
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      80000080000000808000800000008000800080800000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
      7777777777777777777777777777777771F77771F7777777777777111F777777
      1F7777111F777771F777777111F77711F7777777111F711F77777777711111F7
      7777777777111F7777777777711111F777777777111F71F77777771111F77711
      F77771111F7777711F77711F7777777711F77777777777777777}
    OnClick = DelStyleClick
  end
  object LoadStyleSheet: TSpeedButton
    Left = 102
    Top = 324
    Width = 44
    Height = 30
    Hint = 'Load a stylesheet'
    Flat = True
    Glyph.Data = {
      76010000424D7601000000000000760000002800000020000000100000000100
      0400000000000001000000000000000000001000000010000000000000000000
      800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
      5555555555555555555555555555555555555555555555555555555555555555
      555555555555555555555555555555555555555FFFFFFFFFF555550000000000
      55555577777777775F55500B8B8B8B8B05555775F555555575F550F0B8B8B8B8
      B05557F75F555555575F50BF0B8B8B8B8B0557F575FFFFFFFF7F50FBF0000000
      000557F557777777777550BFBFBFBFB0555557F555555557F55550FBFBFBFBF0
      555557F555555FF7555550BFBFBF00055555575F555577755555550BFBF05555
      55555575FFF75555555555700007555555555557777555555555555555555555
      5555555555555555555555555555555555555555555555555555}
    NumGlyphs = 2
    OnClick = LoadStyleSheetClick
  end
  object SaveStyleSheet: TSpeedButton
    Left = 150
    Top = 324
    Width = 44
    Height = 30
    Hint = 'Save this stylesheet'
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDD70077777007007DD00077777007000DD00077777007000DD00077777007
      000DD00077777777000DD00000000000000DD00000000000000DD00FFFFFFFFF
      F00DD00FFFFFFFFFF00DD00F77777777F00DD00FFFFFFFFFF00DD00F77777777
      F00DD00FFFFFFFFFF00DD70000000000007DDDDDDDDDDDDDDDDD}
    OnClick = SaveStyleSheetClick
  end
  object LocateThisStyleInText: TSpeedButton
    Left = 223
    Top = 273
    Width = 90
    Height = 31
    Hint = 'Locate the selected style in the text'
    Enabled = False
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDDDDDDDDDDDDDDDDDDDDD00000000000DDDDDDDDDDDDDDDDDDDDD00000000
      000DDDD2DDDDDDDDDDDDDDD229999999999DD22222DDDDDDDDDDD2D229999999
      999DD2D2DDDDDDDDDDDDDDDD00000000000DD2DDDDDDDDDDDDDDDDDD00000000
      000DD2DDDDDDDDDDDDDDDDDD00000000000DD2DDDDDDDDDDDDDD}
    PopupMenu = ParCommands
    OnClick = LocateThisStyleInTextClick
  end
  object labPreviewText: TLabel
    Left = 246
    Top = 226
    Width = 157
    Height = 16
    Caption = 'The quick brown fox jumps'
    Visible = False
  end
  object labReplaceWithMsg: TLabel
    Left = 207
    Top = 343
    Width = 80
    Height = 16
    Caption = 'Replace with:'
    Visible = False
  end
  object labNewStyleName: TLabel
    Left = 217
    Top = 325
    Width = 60
    Height = 16
    Caption = 'New Style'
    Visible = False
  end
  object TemplateWP: TWPRichText
    Left = 222
    Top = 202
    Width = 320
    Height = 65
    Cursor = crIBeam
    RTFText.Data = {
      3C215750546F6F6C735F466F726D617420563D3530302F3E0D0A3C6469762077
      707374793D5B5B416C69676E6D656E743A313B496E64656E744C6566743A303B
      496E64656E7446697273743A303B496E64656E7452696768743A303B5D5D3E3C
      6373206E723D312077707374793D5B5B43686172466F6E743A27417269616C27
      3B43686172436861727365743A303B43686172466F6E7453697A653A31313030
      3B43686172436F6C6F723A636C426C61636B3B5D5D2F3E3C63206E723D312F3E
      2D2054686520717569636B2062726F776E20666F78202D3C2F6469763E0D0A}
    Header.DefaultTabstop = 254
    RTFVariables = <>
    SpellCheckStrategie = wpspCheckInInit
    Readonly = True
    XOffset = 3
    YOffset = 141
    XBetween = 144
    YBetween = 144
    LayoutMode = wplayNormal
    ScrollBars = ssNone
    EditOptions = [wpTableResizing, wpTableColumnResizing, wpObjectMoving, wpObjectResizingWidth, wpObjectResizingHeight, wpObjectResizingKeepRatio, wpObjectSelecting, wpSpreadsheetCursorMovement, wpActivateUndo, wpActivateUndoHotkey, wpMoveCPOnPageUpDown]
    FormatOptions = [wpDisableAutosizeTables]
    EditBoxModes = [wpemLimitTextWidth]
    WordWrap = True
    ProtectedProp = []
    BorderStyle = bsSingle
    HyperLinkCursor = crArrow
    TextObjectCursor = crHandPoint
    InsertPointAttr.Bold = tsIgnore
    InsertPointAttr.Italic = tsIgnore
    InsertPointAttr.DoubleUnderline = False
    InsertPointAttr.Underline = tsIgnore
    InsertPointAttr.StrikeOut = tsIgnore
    InsertPointAttr.StrikeOutColor = clBlack
    InsertPointAttr.SuperScript = tsIgnore
    InsertPointAttr.SubScript = tsIgnore
    InsertPointAttr.Hidden = False
    InsertPointAttr.UnderlineColor = clBlack
    InsertPointAttr.TextColor = clRed
    InsertPointAttr.BackgroundColor = clBlack
    InsertPointAttr.UseUnderlineColor = False
    InsertPointAttr.UseTextColor = True
    InsertPointAttr.UseBackgroundColor = False
    HyperlinkTextAttr.Bold = tsIgnore
    HyperlinkTextAttr.Italic = tsIgnore
    HyperlinkTextAttr.DoubleUnderline = False
    HyperlinkTextAttr.Underline = tsTRUE
    HyperlinkTextAttr.StrikeOut = tsIgnore
    HyperlinkTextAttr.StrikeOutColor = clBlack
    HyperlinkTextAttr.SuperScript = tsIgnore
    HyperlinkTextAttr.SubScript = tsIgnore
    HyperlinkTextAttr.Hidden = False
    HyperlinkTextAttr.UnderlineColor = clBlue
    HyperlinkTextAttr.TextColor = clBlack
    HyperlinkTextAttr.BackgroundColor = clBlack
    HyperlinkTextAttr.UseUnderlineColor = True
    HyperlinkTextAttr.UseTextColor = False
    HyperlinkTextAttr.UseBackgroundColor = False
    HyperlinkTextAttr.HotUnderlineColor = clRed
    HyperlinkTextAttr.UseHotUnderlineColor = True
    HyperlinkTextAttr.HotTextColor = clRed
    HyperlinkTextAttr.UseHotTextColor = True
    HyperlinkTextAttr.HotUnderline = tsTRUE
    HyperlinkTextAttr.HotStyleIsActive = True
    BookmarkTextAttr.Bold = tsIgnore
    BookmarkTextAttr.Italic = tsIgnore
    BookmarkTextAttr.DoubleUnderline = False
    BookmarkTextAttr.Underline = tsTRUE
    BookmarkTextAttr.StrikeOut = tsIgnore
    BookmarkTextAttr.StrikeOutColor = clBlack
    BookmarkTextAttr.SuperScript = tsIgnore
    BookmarkTextAttr.SubScript = tsIgnore
    BookmarkTextAttr.Hidden = False
    BookmarkTextAttr.UnderlineColor = clGreen
    BookmarkTextAttr.TextColor = clBlack
    BookmarkTextAttr.BackgroundColor = clBlack
    BookmarkTextAttr.UseUnderlineColor = True
    BookmarkTextAttr.UseTextColor = False
    BookmarkTextAttr.UseBackgroundColor = False
    SPANObjectTextAttr.Bold = tsIgnore
    SPANObjectTextAttr.Italic = tsIgnore
    SPANObjectTextAttr.DoubleUnderline = False
    SPANObjectTextAttr.Underline = tsIgnore
    SPANObjectTextAttr.StrikeOut = tsIgnore
    SPANObjectTextAttr.StrikeOutColor = clBlack
    SPANObjectTextAttr.SuperScript = tsIgnore
    SPANObjectTextAttr.SubScript = tsIgnore
    SPANObjectTextAttr.Hidden = False
    SPANObjectTextAttr.UnderlineColor = clBlack
    SPANObjectTextAttr.TextColor = clBlack
    SPANObjectTextAttr.BackgroundColor = clBlack
    SPANObjectTextAttr.UseUnderlineColor = False
    SPANObjectTextAttr.UseTextColor = False
    SPANObjectTextAttr.UseBackgroundColor = False
    HiddenTextAttr.Bold = tsIgnore
    HiddenTextAttr.Italic = tsIgnore
    HiddenTextAttr.DoubleUnderline = False
    HiddenTextAttr.Underline = tsIgnore
    HiddenTextAttr.StrikeOut = tsIgnore
    HiddenTextAttr.StrikeOutColor = clBlack
    HiddenTextAttr.SuperScript = tsIgnore
    HiddenTextAttr.SubScript = tsIgnore
    HiddenTextAttr.Hidden = True
    HiddenTextAttr.UnderlineColor = clBlack
    HiddenTextAttr.TextColor = clBlack
    HiddenTextAttr.BackgroundColor = clBlack
    HiddenTextAttr.UseUnderlineColor = False
    HiddenTextAttr.UseTextColor = False
    HiddenTextAttr.UseBackgroundColor = False
    AutomaticTextAttr.Bold = tsIgnore
    AutomaticTextAttr.Italic = tsIgnore
    AutomaticTextAttr.DoubleUnderline = False
    AutomaticTextAttr.Underline = tsIgnore
    AutomaticTextAttr.StrikeOut = tsIgnore
    AutomaticTextAttr.StrikeOutColor = clBlack
    AutomaticTextAttr.SuperScript = tsIgnore
    AutomaticTextAttr.SubScript = tsIgnore
    AutomaticTextAttr.Hidden = False
    AutomaticTextAttr.UnderlineColor = clBlack
    AutomaticTextAttr.TextColor = clBlack
    AutomaticTextAttr.BackgroundColor = clBlack
    AutomaticTextAttr.UseUnderlineColor = False
    AutomaticTextAttr.UseTextColor = False
    AutomaticTextAttr.UseBackgroundColor = False
    ProtectedTextAttr.Bold = tsIgnore
    ProtectedTextAttr.Italic = tsIgnore
    ProtectedTextAttr.DoubleUnderline = False
    ProtectedTextAttr.Underline = tsIgnore
    ProtectedTextAttr.StrikeOut = tsIgnore
    ProtectedTextAttr.StrikeOutColor = clBlack
    ProtectedTextAttr.SuperScript = tsIgnore
    ProtectedTextAttr.SubScript = tsIgnore
    ProtectedTextAttr.Hidden = False
    ProtectedTextAttr.UnderlineColor = clBlack
    ProtectedTextAttr.TextColor = clBlack
    ProtectedTextAttr.BackgroundColor = clBlack
    ProtectedTextAttr.UseUnderlineColor = False
    ProtectedTextAttr.UseTextColor = False
    ProtectedTextAttr.UseBackgroundColor = False
    FieldObjectTextAttr.Bold = tsIgnore
    FieldObjectTextAttr.Italic = tsIgnore
    FieldObjectTextAttr.DoubleUnderline = False
    FieldObjectTextAttr.Underline = tsIgnore
    FieldObjectTextAttr.StrikeOut = tsIgnore
    FieldObjectTextAttr.StrikeOutColor = clBlack
    FieldObjectTextAttr.SuperScript = tsIgnore
    FieldObjectTextAttr.SubScript = tsIgnore
    FieldObjectTextAttr.Hidden = False
    FieldObjectTextAttr.UnderlineColor = clBlack
    FieldObjectTextAttr.TextColor = clBlack
    FieldObjectTextAttr.BackgroundColor = clBlack
    FieldObjectTextAttr.UseUnderlineColor = False
    FieldObjectTextAttr.UseTextColor = False
    FieldObjectTextAttr.UseBackgroundColor = False
    WriteObjectMode = wobStandard
    OneClickHyperlink = False
    Ctl3D = False
    ParentColor = False
    TabOrder = 1
  end
  object ListBox1: TListBox
    Left = 6
    Top = 11
    Width = 191
    Height = 308
    Style = lbOwnerDrawFixed
    Ctl3D = False
    ItemHeight = 16
    ParentCtl3D = False
    TabOrder = 0
    OnClick = ListBox1Click
    OnDblClick = ListBox1DblClick
    OnDrawItem = ListBox1DrawItem
  end
  object btnOk: TButton
    Left = 351
    Top = 326
    Width = 98
    Height = 31
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 7
  end
  object btnCancel: TButton
    Left = 457
    Top = 326
    Width = 98
    Height = 31
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 8
  end
  object WPRichText1: TWPRichText
    Left = 223
    Top = 101
    Width = 320
    Height = 81
    Cursor = crIBeam
    RTFText.Data = {
      3C215750546F6F6C735F466F726D617420563D3530302F3E0D0A3C6469762077
      707374793D5B5B4647436F6C6F723A636C53696C7665723B53686164696E6756
      616C75653A32303B5D5D3E3C6373206E723D312077707374793D5B5B43686172
      466F6E743A27417269616C273B43686172466F6E7453697A653A313130303B43
      686172436F6C6F723A636C426C61636B3B5D5D2F3E3C63206E723D312F3E7878
      7878787820787878787878207878787878782078787878787820787878787878
      2078787878787820787878787878207878787878782078787878787820787878
      7878782078787878787820787878787878207878787878782078787878787820
      78787878787820787878787878203C2F6469763E0D0A3C6469763E3C63206E72
      3D312F3E78787878787820787878787878207878787878782078787878787820
      7878787878782078787878787820787878787878207878787878782078787878
      7878207878787878782020787878787878207878787878782078787878787820
      7878787878782078787878787820787878787878207878787878782078787878
      7878207878787878782078787878787820787878787878207878787878782078
      7878787878207878787878782078787878787820787878787878207878787878
      78207878787878782078787878787820787878787878207878787878783C2F64
      69763E0D0A3C6469762077707374793D5B5B4647436F6C6F723A636C53696C76
      65723B53686164696E6756616C75653A32303B5D5D3E3C63206E723D312F3E78
      7878787878207878787878782078787878787820787878787878207878787878
      7820787878787878207878787878782078787878787820787878787878207878
      787878782078787878787820787878787878203C2F6469763E0D0A}
    Header.DefaultTabstop = 0
    RTFVariables = <>
    SpellCheckStrategie = wpspCheckInInit
    XOffset = 0
    YOffset = 141
    XBetween = 144
    YBetween = 144
    Zooming = 50
    LayoutMode = wplayNormal
    ScrollBars = ssNone
    EditOptions = [wpTableResizing, wpTableColumnResizing, wpObjectMoving, wpObjectResizingWidth, wpObjectResizingHeight, wpObjectResizingKeepRatio, wpObjectSelecting, wpSpreadsheetCursorMovement, wpActivateUndo, wpActivateUndoHotkey, wpMoveCPOnPageUpDown, wpNoHorzScrolling, wpNoVertScrolling]
    FormatOptions = [wpDisableAutosizeTables]
    EditBoxModes = [wpemLimitTextWidth]
    WordWrap = True
    ProtectedProp = []
    BorderStyle = bsSingle
    HyperLinkCursor = crArrow
    TextObjectCursor = crHandPoint
    InsertPointAttr.Bold = tsIgnore
    InsertPointAttr.Italic = tsIgnore
    InsertPointAttr.DoubleUnderline = False
    InsertPointAttr.Underline = tsIgnore
    InsertPointAttr.StrikeOut = tsIgnore
    InsertPointAttr.StrikeOutColor = clBlack
    InsertPointAttr.SuperScript = tsIgnore
    InsertPointAttr.SubScript = tsIgnore
    InsertPointAttr.Hidden = False
    InsertPointAttr.UnderlineColor = clBlack
    InsertPointAttr.TextColor = clRed
    InsertPointAttr.BackgroundColor = clBlack
    InsertPointAttr.UseUnderlineColor = False
    InsertPointAttr.UseTextColor = True
    InsertPointAttr.UseBackgroundColor = False
    HyperlinkTextAttr.Bold = tsIgnore
    HyperlinkTextAttr.Italic = tsIgnore
    HyperlinkTextAttr.DoubleUnderline = False
    HyperlinkTextAttr.Underline = tsTRUE
    HyperlinkTextAttr.StrikeOut = tsIgnore
    HyperlinkTextAttr.StrikeOutColor = clBlack
    HyperlinkTextAttr.SuperScript = tsIgnore
    HyperlinkTextAttr.SubScript = tsIgnore
    HyperlinkTextAttr.Hidden = False
    HyperlinkTextAttr.UnderlineColor = clBlue
    HyperlinkTextAttr.TextColor = clBlack
    HyperlinkTextAttr.BackgroundColor = clBlack
    HyperlinkTextAttr.UseUnderlineColor = True
    HyperlinkTextAttr.UseTextColor = False
    HyperlinkTextAttr.UseBackgroundColor = False
    HyperlinkTextAttr.HotUnderlineColor = clRed
    HyperlinkTextAttr.UseHotUnderlineColor = True
    HyperlinkTextAttr.HotTextColor = clRed
    HyperlinkTextAttr.UseHotTextColor = True
    HyperlinkTextAttr.HotUnderline = tsTRUE
    HyperlinkTextAttr.HotStyleIsActive = True
    BookmarkTextAttr.Bold = tsIgnore
    BookmarkTextAttr.Italic = tsIgnore
    BookmarkTextAttr.DoubleUnderline = False
    BookmarkTextAttr.Underline = tsTRUE
    BookmarkTextAttr.StrikeOut = tsIgnore
    BookmarkTextAttr.StrikeOutColor = clBlack
    BookmarkTextAttr.SuperScript = tsIgnore
    BookmarkTextAttr.SubScript = tsIgnore
    BookmarkTextAttr.Hidden = False
    BookmarkTextAttr.UnderlineColor = clGreen
    BookmarkTextAttr.TextColor = clBlack
    BookmarkTextAttr.BackgroundColor = clBlack
    BookmarkTextAttr.UseUnderlineColor = True
    BookmarkTextAttr.UseTextColor = False
    BookmarkTextAttr.UseBackgroundColor = False
    SPANObjectTextAttr.Bold = tsIgnore
    SPANObjectTextAttr.Italic = tsIgnore
    SPANObjectTextAttr.DoubleUnderline = False
    SPANObjectTextAttr.Underline = tsIgnore
    SPANObjectTextAttr.StrikeOut = tsIgnore
    SPANObjectTextAttr.StrikeOutColor = clBlack
    SPANObjectTextAttr.SuperScript = tsIgnore
    SPANObjectTextAttr.SubScript = tsIgnore
    SPANObjectTextAttr.Hidden = False
    SPANObjectTextAttr.UnderlineColor = clBlack
    SPANObjectTextAttr.TextColor = clBlack
    SPANObjectTextAttr.BackgroundColor = clBlack
    SPANObjectTextAttr.UseUnderlineColor = False
    SPANObjectTextAttr.UseTextColor = False
    SPANObjectTextAttr.UseBackgroundColor = False
    HiddenTextAttr.Bold = tsIgnore
    HiddenTextAttr.Italic = tsIgnore
    HiddenTextAttr.DoubleUnderline = False
    HiddenTextAttr.Underline = tsIgnore
    HiddenTextAttr.StrikeOut = tsIgnore
    HiddenTextAttr.StrikeOutColor = clBlack
    HiddenTextAttr.SuperScript = tsIgnore
    HiddenTextAttr.SubScript = tsIgnore
    HiddenTextAttr.Hidden = True
    HiddenTextAttr.UnderlineColor = clBlack
    HiddenTextAttr.TextColor = clBlack
    HiddenTextAttr.BackgroundColor = clBlack
    HiddenTextAttr.UseUnderlineColor = False
    HiddenTextAttr.UseTextColor = False
    HiddenTextAttr.UseBackgroundColor = False
    AutomaticTextAttr.Bold = tsIgnore
    AutomaticTextAttr.Italic = tsIgnore
    AutomaticTextAttr.DoubleUnderline = False
    AutomaticTextAttr.Underline = tsIgnore
    AutomaticTextAttr.StrikeOut = tsIgnore
    AutomaticTextAttr.StrikeOutColor = clBlack
    AutomaticTextAttr.SuperScript = tsIgnore
    AutomaticTextAttr.SubScript = tsIgnore
    AutomaticTextAttr.Hidden = False
    AutomaticTextAttr.UnderlineColor = clBlack
    AutomaticTextAttr.TextColor = clBlack
    AutomaticTextAttr.BackgroundColor = clBlack
    AutomaticTextAttr.UseUnderlineColor = False
    AutomaticTextAttr.UseTextColor = False
    AutomaticTextAttr.UseBackgroundColor = False
    ProtectedTextAttr.Bold = tsIgnore
    ProtectedTextAttr.Italic = tsIgnore
    ProtectedTextAttr.DoubleUnderline = False
    ProtectedTextAttr.Underline = tsIgnore
    ProtectedTextAttr.StrikeOut = tsIgnore
    ProtectedTextAttr.StrikeOutColor = clBlack
    ProtectedTextAttr.SuperScript = tsIgnore
    ProtectedTextAttr.SubScript = tsIgnore
    ProtectedTextAttr.Hidden = False
    ProtectedTextAttr.UnderlineColor = clBlack
    ProtectedTextAttr.TextColor = clBlack
    ProtectedTextAttr.BackgroundColor = clBlack
    ProtectedTextAttr.UseUnderlineColor = False
    ProtectedTextAttr.UseTextColor = False
    ProtectedTextAttr.UseBackgroundColor = False
    FieldObjectTextAttr.Bold = tsIgnore
    FieldObjectTextAttr.Italic = tsIgnore
    FieldObjectTextAttr.DoubleUnderline = False
    FieldObjectTextAttr.Underline = tsIgnore
    FieldObjectTextAttr.StrikeOut = tsIgnore
    FieldObjectTextAttr.StrikeOutColor = clBlack
    FieldObjectTextAttr.SuperScript = tsIgnore
    FieldObjectTextAttr.SubScript = tsIgnore
    FieldObjectTextAttr.Hidden = False
    FieldObjectTextAttr.UnderlineColor = clBlack
    FieldObjectTextAttr.TextColor = clBlack
    FieldObjectTextAttr.BackgroundColor = clBlack
    FieldObjectTextAttr.UseUnderlineColor = False
    FieldObjectTextAttr.UseTextColor = False
    FieldObjectTextAttr.UseBackgroundColor = False
    WriteObjectMode = wobStandard
    OneClickHyperlink = False
    Ctl3D = False
    Enabled = False
    ParentColor = False
    TabOrder = 5
    TabStop = True
  end
  object NameEdit: TEdit
    Left = 320
    Top = 21
    Width = 224
    Height = 22
    Color = clBtnFace
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    TabOrder = 2
    Text = 'STYLENAME'
  end
  object btnChangeStyle: TButton
    Left = 444
    Top = 277
    Width = 99
    Height = 27
    Hint = 'Change this Style'
    Caption = '&Change'
    TabOrder = 6
    OnClick = btnChangeStyleClick
  end
  object BasedOn: TEdit
    Left = 320
    Top = 50
    Width = 224
    Height = 22
    Color = clBtnFace
    Ctl3D = False
    Enabled = False
    ParentCtl3D = False
    TabOrder = 3
    Text = 'BASESTYLE'
  end
  object ValueLines: TMemo
    Left = 222
    Top = 202
    Width = 320
    Height = 65
    Color = clBtnFace
    Ctl3D = False
    Lines.Strings = (
      'ValueLines')
    ParentCtl3D = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 4
    Visible = False
    WordWrap = False
  end
  object ParCommands: TPopupMenu
    Left = 326
    Top = 289
    object NormalizethisParagraph1: TMenuItem
      Caption = 'Normalize this Paragraph'
      OnClick = NormalizethisParagraph1Click
    end
    object NormalizeAllParagraphs1: TMenuItem
      Caption = 'Normalize all Paragraphs'
      OnClick = NormalizeAllParagraphs1Click
    end
  end
end
