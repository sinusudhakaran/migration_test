object WPOneStyleDefinition: TWPOneStyleDefinition
  Left = 295
  Top = 132
  BorderStyle = bsDialog
  Caption = 'Modify Style'
  ClientHeight = 299
  ClientWidth = 458
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 7
    Top = 8
    Width = 228
    Height = 136
    Shape = bsFrame
  end
  object Bevel3: TBevel
    Left = 241
    Top = 8
    Width = 211
    Height = 136
    Shape = bsFrame
  end
  object labNumberLevel: TLabel
    Left = 13
    Top = 94
    Width = 66
    Height = 13
    Caption = 'Number Level'
    Transparent = True
  end
  object labBasedOn: TLabel
    Left = 13
    Top = 69
    Width = 45
    Height = 13
    Caption = 'Based on'
    Transparent = True
  end
  object labNextStyle: TLabel
    Left = 13
    Top = 47
    Width = 48
    Height = 13
    Caption = 'Next Style'
    Transparent = True
  end
  object labName: TLabel
    Left = 13
    Top = 22
    Width = 28
    Height = 13
    Caption = 'Name'
    Transparent = True
  end
  object Bevel2: TBevel
    Left = 6
    Top = 154
    Width = 447
    Height = 61
    Shape = bsFrame
  end
  object labFont: TLabel
    Left = 248
    Top = 17
    Width = 21
    Height = 13
    Caption = 'Font'
    Transparent = True
  end
  object labSize: TLabel
    Left = 248
    Top = 41
    Width = 20
    Height = 13
    Caption = 'Size'
    Transparent = True
  end
  object labColors: TLabel
    Left = 249
    Top = 110
    Width = 29
    Height = 13
    Caption = 'Colors'
    Transparent = True
  end
  object labBold: TLabel
    Left = 248
    Top = 66
    Width = 21
    Height = 13
    Caption = 'Bold'
    FocusControl = btnCancel
    Transparent = True
  end
  object labItalic: TLabel
    Left = 349
    Top = 65
    Width = 22
    Height = 13
    Caption = 'Italic'
    FocusControl = ItalicCheck
    Transparent = True
  end
  object labUnderline: TLabel
    Left = 248
    Top = 86
    Width = 45
    Height = 13
    Caption = 'Underline'
    FocusControl = UnderCheck
    Transparent = True
  end
  object labIsOutline: TLabel
    Left = 13
    Top = 122
    Width = 73
    Height = 13
    Caption = 'Is Outline Level'
    FocusControl = IsOutline
    Transparent = True
  end
  object labKeepTextToether: TLabel
    Left = 323
    Top = 125
    Width = 41
    Height = 13
    Caption = 'reserved'
    Transparent = True
    Visible = False
  end
  object labKeepWithNext: TLabel
    Left = 251
    Top = 127
    Width = 41
    Height = 13
    Caption = 'reserved'
    Transparent = True
    Visible = False
  end
  object labIsCharacterStyle: TLabel
    Left = 138
    Top = 121
    Width = 41
    Height = 13
    Caption = 'reserved'
    Transparent = True
    Visible = False
  end
  object NONE_str: TLabel
    Left = 145
    Top = 231
    Width = 26
    Height = 13
    Caption = 'None'
    Visible = False
  end
  object ModifyEntry: TButton
    Left = 9
    Top = 265
    Width = 80
    Height = 25
    Caption = '&Format'
    TabOrder = 12
    OnClick = ModifyEntryClick
  end
  object LevelSel: TComboBox
    Left = 99
    Top = 90
    Width = 120
    Height = 21
    ItemHeight = 13
    TabOrder = 3
    OnChange = LevelSelChange
    Items.Strings = (
      'None'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9')
  end
  object BasedOnSel: TComboBox
    Left = 99
    Top = 66
    Width = 120
    Height = 21
    ItemHeight = 13
    TabOrder = 2
  end
  object NextSel: TComboBox
    Left = 99
    Top = 43
    Width = 120
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    Items.Strings = (
      '<same style>'
      'a'
      'b'
      'c'
      'd')
  end
  object NameEdit: TEdit
    Left = 99
    Top = 19
    Width = 120
    Height = 21
    TabOrder = 0
    Text = 'Headline'
    OnChange = NameEditChange
  end
  object TemplateWP: TWPRichText
    Left = 10
    Top = 158
    Width = 437
    Height = 51
    Cursor = crIBeam
    RTFText.Data = {
      3C215750546F6F6C735F466F726D617420563D3530302F3E0D0A3C6469763E3C
      2F6469763E0D0A}
    Header.DefaultTabstop = 254
    RTFVariables = <>
    SpellCheckStrategie = wpspCheckInInit
    XOffset = 2
    YOffset = 141
    XBetween = 144
    YBetween = 144
    LayoutMode = wplayNormal
    ScrollBars = ssNone
    EditOptions = [wpTableResizing, wpTableColumnResizing, wpObjectMoving, wpObjectResizingWidth, wpObjectResizingHeight, wpObjectResizingKeepRatio, wpObjectSelecting, wpObjectDeletion, wpSpreadsheetCursorMovement, wpActivateUndo, wpActivateUndoHotkey, wpMoveCPOnPageUpDown, wpNoHorzScrolling, wpNoVertScrolling]
    ViewOptions = [wpHideSelection]
    FormatOptions = [wpDisableAutosizeTables]
    FormatOptionsEx = []
    EditBoxModes = [wpemLimitTextWidth]
    WordWrap = True
    ProtectedProp = []
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
    Enabled = False
    ParentColor = False
    TabOrder = 13
  end
  object BoldCheck: TCheckBox
    Left = 322
    Top = 65
    Width = 16
    Height = 18
    AllowGrayed = True
    State = cbGrayed
    TabOrder = 7
    OnClick = BoldCheckClick
  end
  object UnderCheck: TCheckBox
    Tag = 2
    Left = 322
    Top = 84
    Width = 16
    Height = 18
    AllowGrayed = True
    State = cbGrayed
    TabOrder = 9
    OnClick = BoldCheckClick
  end
  object ItalicCheck: TCheckBox
    Tag = 1
    Left = 405
    Top = 65
    Width = 16
    Height = 18
    Alignment = taLeftJustify
    AllowGrayed = True
    State = cbGrayed
    TabOrder = 8
    OnClick = BoldCheckClick
  end
  object FontCombo: TComboBox
    Left = 322
    Top = 15
    Width = 120
    Height = 21
    ItemHeight = 13
    TabOrder = 5
    OnChange = FontComboChange
  end
  object SizeCombo: TComboBox
    Left = 322
    Top = 38
    Width = 120
    Height = 21
    ItemHeight = 13
    TabOrder = 6
    OnChange = SizeComboChange
    OnKeyPress = SizeComboKeyPress
    Items.Strings = (
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12'
      '13'
      '14'
      '15'
      '16'
      '17'
      '18'
      '20'
      '22'
      '24'
      '28'
      '32'
      '36'
      '42'
      '48'
      '56'
      '76')
  end
  object FontColor: TComboBox
    Left = 322
    Top = 107
    Width = 60
    Height = 19
    Style = csOwnerDrawFixed
    ItemHeight = 13
    TabOrder = 10
    OnClick = FontColorClick
    OnDrawItem = FontColorDrawItem
    Items.Strings = (
      'clNone'
      'clBlack'
      'clRed'
      'clGreen'
      'clBlue'
      'clYellow'
      'clFuchsia'
      'clPurple'
      'clMaroon'
      'clLime'
      'clAqua'
      'clTeal'
      'clNavy'
      'clWhite'
      'clGray')
  end
  object BKColor: TComboBox
    Left = 384
    Top = 107
    Width = 60
    Height = 19
    Style = csOwnerDrawFixed
    ItemHeight = 13
    TabOrder = 11
    OnClick = FontColorClick
    OnDrawItem = FontColorDrawItem
    Items.Strings = (
      'clNone'
      'clWhite'
      'clBlack'
      'clRed'
      'clGreen'
      'clBlue'
      'clYellow'
      'clFuchsia'
      'clPurple'
      'clMaroon'
      'clLime'
      'clAqua'
      'clTeal'
      'clNavy'
      'clGray')
  end
  object btnOk: TButton
    Left = 285
    Top = 265
    Width = 80
    Height = 25
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 14
  end
  object btnCancel: TButton
    Left = 371
    Top = 265
    Width = 80
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 15
  end
  object Memo1: TMemo
    Left = 7
    Top = 224
    Width = 446
    Height = 35
    BorderStyle = bsNone
    Color = clBtnFace
    TabOrder = 16
    OnMouseDown = Memo1MouseDown
  end
  object IsOutline: TCheckBox
    Left = 111
    Top = 120
    Width = 16
    Height = 18
    Alignment = taLeftJustify
    TabOrder = 4
    OnClick = IsOutlineClick
  end
  object ckOverwriteParProps: TCheckBox
    Left = 103
    Top = 271
    Width = 175
    Height = 13
    Alignment = taLeftJustify
    Caption = 'Overwrite paragraph properties'
    TabOrder = 17
  end
  object WPParagraphPropDlg1: TWPParagraphPropDlg
    EditBox = TemplateWP
    AutoUpdate = False
    Left = 166
    Top = 237
  end
  object WPParagraphBorderDlg1: TWPParagraphBorderDlg
    EditBox = TemplateWP
    AutoUpdate = False
    Left = 201
    Top = 236
  end
  object WPTabDlg1: TWPTabDlg
    EditBox = TemplateWP
    Left = 233
    Top = 236
  end
  object WPBulletDlg1: TWPBulletDlg
    EditBox = TemplateWP
    Left = 270
    Top = 236
  end
  object PopupMenu1: TPopupMenu
    Left = 306
    Top = 235
    object ParagraphProperties1: TMenuItem
      Tag = 1
      Caption = 'Alignment/Spacing/Indents'
      OnClick = Numbers1Click
    end
    object Borders1: TMenuItem
      Tag = 3
      Caption = 'Shading'
      OnClick = Numbers1Click
    end
    object Tabstops1: TMenuItem
      Tag = 4
      Caption = 'Tabstops'
      OnClick = Numbers1Click
    end
    object Numbers1: TMenuItem
      Tag = 5
      Caption = 'Numbers'
      OnClick = Numbers1Click
    end
  end
end
