object frmHeaderFooter: TfrmHeaderFooter
  Scaled = False
Left = 0
  Top = 0
  Caption = 'frmHeaderFooter'
  ClientHeight = 520
  ClientWidth = 693
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 335
    Width = 693
    Height = 4
    Cursor = crVSplit
    Align = alTop
    Beveled = True
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 693
    Height = 41
    Align = alTop
    Caption = 'Panel1'
    TabOrder = 0
    object Topbar: TRzToolbar
      Left = 1
      Top = 1
      Width = 691
      Height = 39
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      Images = ImageList1
      Margin = 0
      RowHeight = 36
      ButtonLayout = blGlyphTop
      ButtonWidth = 40
      ButtonHeight = 40
      ShowButtonCaptions = True
      TextOptions = ttoCustom
      BorderInner = fsNone
      BorderOuter = fsGroove
      BorderSides = [sdTop]
      BorderWidth = 0
      GradientColorStyle = gcsCustom
      GradientColorStop = 11446784
      TabOrder = 0
      VisualStyle = vsGradient
      ToolbarControls = (
        btnAll
        btnOdd
        BtnEven
        BtnFirst
        BtnLast
        RzSpacer1
        RzSpacer2
        RzSpacer3
        BtnInsert)
      object btnAll: TRzToolButton
        Left = 0
        Top = 0
        Width = 40
        Height = 40
        DisabledIndex = 1
        GroupIndex = 10
        Down = True
        ImageIndex = 2
        Layout = blGlyphTop
        ShowCaption = True
        UseToolbarButtonLayout = False
        UseToolbarButtonSize = False
        UseToolbarShowCaption = False
        Caption = 'All '
        OnClick = DoTypeBtn
      end
      object btnOdd: TRzToolButton
        Tag = 1
        Left = 40
        Top = 0
        Width = 40
        Height = 40
        GroupIndex = 10
        ImageIndex = 2
        Layout = blGlyphTop
        UseToolbarButtonSize = False
        Caption = 'Odd '
        OnClick = DoTypeBtn
      end
      object BtnEven: TRzToolButton
        Tag = 2
        Left = 80
        Top = 0
        Width = 40
        Height = 40
        DisabledIndex = 5
        GroupIndex = 10
        ImageIndex = 4
        Layout = blGlyphTop
        UseToolbarButtonSize = False
        Caption = 'Even'
        OnClick = DoTypeBtn
      end
      object BtnFirst: TRzToolButton
        Tag = 3
        Left = 120
        Top = 0
        Width = 40
        Height = 40
        DisabledIndex = 7
        GroupIndex = 10
        ImageIndex = 6
        Layout = blGlyphTop
        UseToolbarButtonSize = False
        Caption = 'First'
        OnClick = DoTypeBtn
      end
      object BtnLast: TRzToolButton
        Tag = 4
        Left = 160
        Top = 0
        Width = 40
        Height = 40
        DisabledIndex = 9
        GroupIndex = 10
        ImageIndex = 8
        Layout = blGlyphTop
        UseToolbarButtonSize = False
        Caption = 'Last'
        OnClick = DoTypeBtn
      end
      object RzSpacer1: TRzSpacer
        Left = 200
        Top = 8
      end
      object RzSpacer2: TRzSpacer
        Left = 208
        Top = 8
        Grooved = True
      end
      object RzSpacer3: TRzSpacer
        Left = 216
        Top = 8
      end
      object BtnInsert: TRzToolButton
        Left = 224
        Top = 0
        Width = 54
        Height = 40
        DisabledIndex = 1
        DropDownMenu = pmInsert
        ImageIndex = 0
        Layout = blGlyphTop
        ToolStyle = tsDropDown
        Caption = 'Insert'
      end
    end
  end
  object WPToolBar1: TWPToolBar
    Left = 0
    Top = 41
    Width = 693
    Height = 29
    ParentColor = False
    UseDockManager = False
    KeepGroupsTogether = True
    Align = alTop
    BevelLines = []
    AutoEnabling = True
    WidthBetweenGroups = 4
    FontChoice = fsPrinterFonts
    sel_ListBoxes = [SelFontName, SelFontSize, SelFontColor, SelParColor]
    sel_StatusIcons = [SelBold, SelItalic, SelUnder, SelLeft, SelRight, SelBlock, SelCenter]
    sel_ActionIcons = [SelPrint, SelPrintSetup]
    sel_DatabaseIcons = []
    sel_EditIcons = [SelCopy, SelCut, SelPaste, SelFind, SelReplace]
    sel_TableIcons = [SelCreateTable]
    sel_OutlineIcons = []
    FontSizeFrom = 8
    FlatButtons = False
    ButtonHeight = 0
    TrueTypeOnly = False
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 70
    Width = 693
    Height = 265
    Align = alTop
    TabOrder = 2
    object RulerHeader: TWPRuler
      Left = 1
      Top = 42
      Width = 691
      Height = 26
      Units = wrCentimeter
      DrawOptions = []
      TabKind = tkLeft
      Options = [wrShowTabSelector, wrShowTabStops, wrShowIndents, wpUseIntervalls, wpNoVertRulerAttached]
      ColorMargin = clAppWorkSpace
      ColorBack = clBtnFace
      Align = alTop
    end
    object VertRulerHeader: TWPVertRuler
      Left = 1
      Top = 68
      Width = 26
      Height = 196
      Units = wrCentimeter
      DrawOptions = []
      ColorMargin = clAppWorkSpace
      ColorBack = clBtnFace
      Align = alLeft
    end
    object RTHeader: TWPRichText
      Left = 27
      Top = 68
      Width = 665
      Height = 196
      RTFVariables = <>
      SpellCheckStrategie = wpspCheckInInit
      WPToolBar = WPToolBar1
      WPRuler = RulerHeader
      VRuler = VertRulerHeader
      GraphicPopupMenu = GraphicPopupMenu
      XOffset = 144
      YOffset = 144
      XBetween = 144
      YBetween = 144
      AutoZoom = wpAutoZoomWidth
      LayoutMode = wplayPageGap
      ScrollBars = ssBoth
      EditOptions = [wpTableResizing, wpTableColumnResizing, wpObjectMoving, wpObjectResizingWidth, wpObjectResizingHeight, wpObjectResizingKeepRatio, wpObjectSelecting, wpObjectDeletion, wpSpreadsheetCursorMovement, wpActivateUndo, wpActivateUndoHotkey, wpMoveCPOnPageUpDown]
      FormatOptions = [wpDisableAutosizeTables]
      FormatOptionsEx = []
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
      HyperlinkTextAttr.HotTextColor = clRed
      HyperlinkTextAttr.HotUnderline = tsTRUE
      HyperlinkTextAttr.HotStyleIsActive = True
      BookmarkTextAttr.Bold = tsIgnore
      BookmarkTextAttr.Italic = tsIgnore
      BookmarkTextAttr.DoubleUnderline = False
      BookmarkTextAttr.Underline = tsIgnore
      BookmarkTextAttr.StrikeOut = tsIgnore
      BookmarkTextAttr.StrikeOutColor = clBlack
      BookmarkTextAttr.SuperScript = tsIgnore
      BookmarkTextAttr.SubScript = tsIgnore
      BookmarkTextAttr.Hidden = False
      BookmarkTextAttr.UnderlineColor = clBlack
      BookmarkTextAttr.TextColor = clBlack
      BookmarkTextAttr.BackgroundColor = clBlack
      BookmarkTextAttr.UseUnderlineColor = False
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
      WriteObjectMode = wobRTF
      OneClickHyperlink = False
      Align = alClient
      TabOrder = 2
    end
    object RzPanel1: TRzPanel
      Left = 1
      Top = 1
      Width = 691
      Height = 41
      Align = alTop
      BorderSides = []
      GradientColorStyle = gcsCustom
      GradientColorStop = 11446784
      TabOrder = 3
      VisualStyle = vsGradient
      object Label1: TLabel
        Left = 26
        Top = 19
        Width = 47
        Height = 16
        Caption = 'Header'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 339
    Width = 693
    Height = 181
    Align = alClient
    TabOrder = 3
    object RulerFooter: TWPRuler
      Left = 1
      Top = 42
      Width = 691
      Height = 26
      Units = wrCentimeter
      DrawOptions = []
      TabKind = tkLeft
      Options = [wrShowTabSelector, wrShowTabStops, wrShowIndents, wpUseIntervalls, wpNoVertRulerAttached]
      ColorMargin = clAppWorkSpace
      ColorBack = clBtnFace
      Align = alTop
    end
    object VertRulerFooter: TWPVertRuler
      Left = 1
      Top = 68
      Width = 26
      Height = 112
      Units = wrCentimeter
      DrawOptions = []
      ColorMargin = clAppWorkSpace
      ColorBack = clBtnFace
      Align = alLeft
    end
    object RTFooter: TWPRichText
      Left = 27
      Top = 68
      Width = 665
      Height = 112
      RTFVariables = <>
      SpellCheckStrategie = wpspCheckInInit
      WPToolBar = WPToolBar1
      WPRuler = RulerFooter
      VRuler = VertRulerFooter
      GraphicPopupMenu = GraphicPopupMenu
      XOffset = 144
      YOffset = 144
      XBetween = 144
      YBetween = 144
      AutoZoom = wpAutoZoomWidth
      LayoutMode = wplayPageGap
      ScrollBars = ssBoth
      EditOptions = [wpTableResizing, wpTableColumnResizing, wpObjectMoving, wpObjectResizingWidth, wpObjectResizingHeight, wpObjectResizingKeepRatio, wpObjectSelecting, wpObjectDeletion, wpSpreadsheetCursorMovement, wpActivateUndo, wpActivateUndoHotkey, wpMoveCPOnPageUpDown]
      FormatOptions = [wpDisableAutosizeTables]
      FormatOptionsEx = []
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
      HyperlinkTextAttr.HotTextColor = clRed
      HyperlinkTextAttr.HotUnderline = tsTRUE
      HyperlinkTextAttr.HotStyleIsActive = True
      BookmarkTextAttr.Bold = tsIgnore
      BookmarkTextAttr.Italic = tsIgnore
      BookmarkTextAttr.DoubleUnderline = False
      BookmarkTextAttr.Underline = tsIgnore
      BookmarkTextAttr.StrikeOut = tsIgnore
      BookmarkTextAttr.StrikeOutColor = clBlack
      BookmarkTextAttr.SuperScript = tsIgnore
      BookmarkTextAttr.SubScript = tsIgnore
      BookmarkTextAttr.Hidden = False
      BookmarkTextAttr.UnderlineColor = clBlack
      BookmarkTextAttr.TextColor = clBlack
      BookmarkTextAttr.BackgroundColor = clBlack
      BookmarkTextAttr.UseUnderlineColor = False
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
      WriteObjectMode = wobRTF
      OneClickHyperlink = False
      OnClick = RTFooterClick
      Align = alClient
      TabOrder = 2
    end
    object RzPanel2: TRzPanel
      Left = 1
      Top = 1
      Width = 691
      Height = 41
      Align = alTop
      BorderSides = []
      GradientColorStyle = gcsCustom
      GradientColorStop = 11446784
      TabOrder = 3
      VisualStyle = vsGradient
      object Label2: TLabel
        Left = 26
        Top = 19
        Width = 42
        Height = 16
        Caption = 'Footer'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        Transparent = True
      end
    end
  end
  object ImageList1: TImageList
    Left = 280
    Bitmap = {
      494C010104000500040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000993300000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000999999000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000CC996600CC99
      6600CC996600CC996600CC996600CC996600CC996600CC996600CC996600CC99
      6600CC996600CC99660000000000000000000000000000000000999999009999
      9900999999009999990099999900999999009999990099999900999999009999
      9900999999009999990000000000000000000000000000000000000000000000
      0000000000000000000099330000CC6600009933000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000099999900CCCCCC009999990000000000000000000000
      0000000000000000000000000000000000000000000000000000CC996600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00CC99660000000000000000000000000000000000999999000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000009999990000000000000000000000000000000000000000000000
      00000000000099330000CC660000CC660000CC66000099330000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000099999900CCCCCC00CCCCCC00CCCCCC0099999900000000000000
      0000000000000000000000000000000000000000000000000000CC996600FFFF
      FF00E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5
      E500FFFFFF00CC99660000000000000000000000000000000000999999000000
      0000CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCC
      CC00000000009999990000000000000000000000000000000000000000000000
      000099330000CC660000CC660000CC660000CC660000CC660000993300000000
      0000000000000000000000000000000000000000000000000000000000000000
      000099999900CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00999999000000
      0000000000000000000000000000000000000000000000000000CC996600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00CC99660000000000000000000000000000000000999999000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000009999990000000000000000000000000000000000000000009933
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC6600009933
      0000000000000000000000000000000000000000000000000000000000009999
      9900CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC009999
      9900000000000000000000000000000000000000000000000000CC996600FFFF
      FF00E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5
      E500FFFFFF00CC99660000000000000000000000000000000000999999000000
      0000CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCC
      CC0000000000999999000000000000000000000000000000000099330000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      000099330000000000000000000000000000000000000000000099999900CCCC
      CC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCC
      CC00999999000000000000000000000000000000000000000000CC996600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00CC99660000000000000000000000000000000000999999000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000999999000000000000000000000000000000000099330000CC66
      0000CC660000CC660000CC660000CC660000CC660000CC660000CC660000CC66
      000099330000000000000000000000000000000000000000000099999900CCCC
      CC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCC
      CC00999999000000000000000000000000000000000000000000CC996600FFFF
      FF00E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5
      E500FFFFFF00CC99660000000000000000000000000000000000999999000000
      0000CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCC
      CC00000000009999990000000000000000000000000000000000993300009933
      00009933000099330000CC660000CC660000CC66000099330000993300009933
      0000993300000000000000000000000000000000000000000000999999009999
      99009999990099999900CCCCCC00CCCCCC00CCCCCC0099999900999999009999
      9900999999000000000000000000000000000000000000000000CC996600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00CC99660000000000000000000000000000000000999999000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000009999990000000000000000000000000000000000000000000000
      00000000000099330000CC660000CC660000CC66000099330000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000099999900CCCCCC00CCCCCC00CCCCCC0099999900000000000000
      0000000000000000000000000000000000000000000000000000CC996600FFFF
      FF00E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500E5E5
      E500FFFFFF00CC99660000000000000000000000000000000000999999000000
      0000CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCC
      CC00000000009999990000000000000000000000000000000000000000000000
      00000000000099330000CC660000CC660000CC66000099330000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000099999900CCCCCC00CCCCCC00CCCCCC0099999900000000000000
      0000000000000000000000000000000000000000000000000000CC996600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00CC99660000000000000000000000000000000000999999000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000009999990000000000000000000000000000000000000000000000
      00000000000099330000CC660000CC660000CC66000099330000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000099999900CCCCCC00CCCCCC00CCCCCC0099999900000000000000
      0000000000000000000000000000000000000000000000000000CC996600FFFF
      FF00E5E5E500E5E5E500E5E5E500E5E5E500E5E5E500FFFFFF00CC996600CC99
      6600CC996600CC99660000000000000000000000000000000000999999000000
      0000CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC0000000000999999009999
      9900999999009999990000000000000000000000000000000000000000000000
      00000000000099330000CC660000CC660000CC66000099330000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000099999900CCCCCC00CCCCCC00CCCCCC0099999900000000000000
      0000000000000000000000000000000000000000000000000000CC996600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CC996600E5E5
      E500CC9966000000000000000000000000000000000000000000999999000000
      0000000000000000000000000000000000000000000000000000999999000000
      0000999999000000000000000000000000000000000000000000000000000000
      00000000000099330000CC660000CC660000CC66000099330000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000099999900CCCCCC00CCCCCC00CCCCCC0099999900000000000000
      0000000000000000000000000000000000000000000000000000CC996600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00CC996600CC99
      6600000000000000000000000000000000000000000000000000999999000000
      0000000000000000000000000000000000000000000000000000999999009999
      9900000000000000000000000000000000000000000000000000000000000000
      0000000000009933000099330000993300009933000099330000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000009999990099999900999999009999990099999900000000000000
      0000000000000000000000000000000000000000000000000000CC996600CC99
      6600CC996600CC996600CC996600CC996600CC996600CC996600CC9966000000
      0000000000000000000000000000000000000000000000000000999999009999
      9900999999009999990099999900999999009999990099999900999999000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFFFFFFFEFFFEFFC003C003
      FC7FFC7FC003DFFBF83FF83FC003D00BF01FF01FC003DFFBE00FE00FC003D00B
      C007C007C003DFFBC007C007C003D00BC007C007C003DFFBF83FF83FC003D00B
      F83FF83FC003DFFBF83FF83FC003D043F83FF83FC007DFD7F83FF83FC00FDFCF
      F83FF83FC01FC01FFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object pmInsert: TPopupMenu
    Left = 320
    Top = 8
    object Picture1: TMenuItem
      Caption = 'Picture'
      OnClick = Picture1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object PageNumber1: TMenuItem
      Caption = 'Page Number'
      OnClick = PageNumber1Click
    end
    object PageCount1: TMenuItem
      Caption = 'Page Count'
      OnClick = PageCount1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object Date1: TMenuItem
      Caption = 'Date'
      OnClick = Date1Click
    end
    object Time1: TMenuItem
      Caption = 'Time'
      OnClick = Time1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Client1: TMenuItem
      Caption = 'Client'
      OnClick = Client1Click
    end
    object ClientCode1: TMenuItem
      Caption = 'Client Code'
      OnClick = ClientCode1Click
    end
    object Operator1: TMenuItem
      Caption = 'Operator'
      OnClick = Operator1Click
    end
    object OperatorCode1: TMenuItem
      Caption = 'Operator Code'
      OnClick = OperatorCode1Click
    end
  end
  object GraphicPopupMenu: TPopupMenu
    OnPopup = GraphicPopupMenuPopup
    Left = 362
    Top = 3
    object grChar: TMenuItem
      Tag = 6
      Caption = 'As Character'
      GroupIndex = 13
      RadioItem = True
      OnClick = grPopupClick
    end
    object grPage: TMenuItem
      Tag = 7
      Caption = 'Relative to page :'
      GroupIndex = 13
      RadioItem = True
      OnClick = grPopupClick
    end
    object gr1: TMenuItem
      Tag = 4
      Caption = '-'
      GroupIndex = 13
    end
    object grAutoWrap: TMenuItem
      Tag = 1
      Caption = 'Auto wrap'
      GroupIndex = 13
      RadioItem = True
      OnClick = grPopupClick
    end
    object grLeft: TMenuItem
      Tag = 2
      Caption = 'Wrap left'
      GroupIndex = 13
      OnClick = grPopupClick
    end
    object grRight: TMenuItem
      Tag = 3
      Caption = 'Wrap Right'
      GroupIndex = 13
      RadioItem = True
      OnClick = grPopupClick
    end
    object grBothWrap: TMenuItem
      Tag = 4
      Caption = 'Wrap left and Right'
      GroupIndex = 13
      RadioItem = True
      OnClick = grPopupClick
    end
    object grNoWrap: TMenuItem
      Tag = 5
      Caption = 'No Wrapping'
      GroupIndex = 13
      RadioItem = True
      OnClick = grPopupClick
    end
  end
end
