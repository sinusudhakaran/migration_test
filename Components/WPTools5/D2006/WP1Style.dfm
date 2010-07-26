object WPOneStyleDefinition: TWPOneStyleDefinition
  Left = 127
  Top = 145
  BorderStyle = bsDialog
  Caption = 'Modify Style'
  ClientHeight = 368
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Bevel1: TBevel
    Left = 9
    Top = 10
    Width = 280
    Height = 167
    Shape = bsFrame
  end
  object Bevel3: TBevel
    Left = 297
    Top = 10
    Width = 259
    Height = 167
    Shape = bsFrame
  end
  object labNumberLevel: TLabel
    Left = 16
    Top = 116
    Width = 84
    Height = 16
    Caption = 'Number Level'
    Transparent = True
  end
  object labBasedOn: TLabel
    Left = 16
    Top = 85
    Width = 58
    Height = 16
    Caption = 'Based on'
    Transparent = True
  end
  object labNextStyle: TLabel
    Left = 16
    Top = 58
    Width = 60
    Height = 16
    Caption = 'Next Style'
    Transparent = True
  end
  object labName: TLabel
    Left = 16
    Top = 27
    Width = 37
    Height = 16
    Caption = 'Name'
    Transparent = True
  end
  object Bevel2: TBevel
    Left = 7
    Top = 190
    Width = 551
    Height = 75
    Shape = bsFrame
  end
  object labFont: TLabel
    Left = 305
    Top = 21
    Width = 26
    Height = 16
    Caption = 'Font'
    Transparent = True
  end
  object labSize: TLabel
    Left = 305
    Top = 50
    Width = 26
    Height = 16
    Caption = 'Size'
    Transparent = True
  end
  object labColors: TLabel
    Left = 306
    Top = 135
    Width = 39
    Height = 16
    Caption = 'Colors'
    Transparent = True
  end
  object labBold: TLabel
    Left = 305
    Top = 81
    Width = 28
    Height = 16
    Caption = 'Bold'
    FocusControl = btnCancel
    Transparent = True
  end
  object labItalic: TLabel
    Left = 430
    Top = 80
    Width = 27
    Height = 16
    Caption = 'Italic'
    FocusControl = ItalicCheck
    Transparent = True
  end
  object labUnderline: TLabel
    Left = 305
    Top = 106
    Width = 58
    Height = 16
    Caption = 'Underline'
    FocusControl = UnderCheck
    Transparent = True
  end
  object labIsOutline: TLabel
    Left = 16
    Top = 150
    Width = 90
    Height = 16
    Caption = 'Is Outline Level'
    FocusControl = IsOutline
    Transparent = True
  end
  object labKeepTextToether: TLabel
    Left = 398
    Top = 154
    Width = 54
    Height = 16
    Caption = 'reserved'
    Transparent = True
    Visible = False
  end
  object labKeepWithNext: TLabel
    Left = 309
    Top = 156
    Width = 54
    Height = 16
    Caption = 'reserved'
    Transparent = True
    Visible = False
  end
  object labIsCharacterStyle: TLabel
    Left = 170
    Top = 149
    Width = 54
    Height = 16
    Caption = 'reserved'
    Transparent = True
    Visible = False
  end
  object NONE_str: TLabel
    Left = 178
    Top = 284
    Width = 33
    Height = 16
    Caption = 'None'
    Visible = False
  end
  object ModifyEntry: TButton
    Left = 11
    Top = 326
    Width = 99
    Height = 31
    Caption = '&Format'
    TabOrder = 12
    OnClick = ModifyEntryClick
  end
  object LevelSel: TComboBox
    Left = 122
    Top = 111
    Width = 148
    Height = 24
    ItemHeight = 16
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
    Left = 122
    Top = 81
    Width = 148
    Height = 24
    ItemHeight = 16
    TabOrder = 2
  end
  object NextSel: TComboBox
    Left = 122
    Top = 53
    Width = 148
    Height = 24
    ItemHeight = 16
    TabOrder = 1
    Items.Strings = (
      '<same style>'
      'a'
      'b'
      'c'
      'd')
  end
  object NameEdit: TEdit
    Left = 122
    Top = 23
    Width = 148
    Height = 24
    TabOrder = 0
    Text = 'Headline'
    OnChange = NameEditChange
  end
  object TemplateWP: TWPRichText
    Left = 12
    Top = 194
    Width = 538
    Height = 63
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
    Left = 396
    Top = 80
    Width = 20
    Height = 22
    AllowGrayed = True
    State = cbGrayed
    TabOrder = 7
    OnClick = BoldCheckClick
  end
  object UnderCheck: TCheckBox
    Tag = 2
    Left = 396
    Top = 103
    Width = 20
    Height = 23
    AllowGrayed = True
    State = cbGrayed
    TabOrder = 9
    OnClick = BoldCheckClick
  end
  object ItalicCheck: TCheckBox
    Tag = 1
    Left = 498
    Top = 80
    Width = 20
    Height = 22
    Alignment = taLeftJustify
    AllowGrayed = True
    State = cbGrayed
    TabOrder = 8
    OnClick = BoldCheckClick
  end
  object FontCombo: TComboBox
    Left = 396
    Top = 18
    Width = 148
    Height = 24
    ItemHeight = 16
    TabOrder = 5
    OnChange = FontComboChange
  end
  object SizeCombo: TComboBox
    Left = 396
    Top = 47
    Width = 148
    Height = 24
    ItemHeight = 16
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
    Left = 396
    Top = 132
    Width = 74
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
    Left = 473
    Top = 132
    Width = 73
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
    Left = 351
    Top = 326
    Width = 98
    Height = 31
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 14
  end
  object btnCancel: TButton
    Left = 457
    Top = 326
    Width = 98
    Height = 31
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 15
  end
  object Memo1: TMemo
    Left = 8
    Top = 276
    Width = 549
    Height = 43
    BorderStyle = bsNone
    Color = clBtnFace
    TabOrder = 16
    OnMouseDown = Memo1MouseDown
  end
  object IsOutline: TCheckBox
    Left = 137
    Top = 148
    Width = 19
    Height = 22
    Alignment = taLeftJustify
    TabOrder = 4
    OnClick = IsOutlineClick
  end
  object ckOverwriteParProps: TCheckBox
    Left = 127
    Top = 333
    Width = 215
    Height = 17
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
      Caption = 'Borders/Shading'
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
