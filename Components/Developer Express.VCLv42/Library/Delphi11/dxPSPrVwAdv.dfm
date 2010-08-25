object dxfmPreviewWdxBar: TdxfmPreviewWdxBar
  Left = 352
  Top = 204
  Width = 893
  Height = 461
  Caption = 'Print Preview'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    00000000000000000000000000000FFFFFFFFFF000000FFFFFFF000070000FFF
    FFF0788707000FFFFF0788E770000FFFFF08888780000FFFFF08E88780000FFF
    FF07EE8770000FFFFFF0788700000FFFFFFF000000000FFFFFFFFFF000000FFF
    FFFF000000000FFFFFFF080000000FFFFFFF000000000000000000000000FFFF
    0000000C00000008000000010000000300000003000000030000000300000003
    000000070000000F0000000F0000000F0000001F0000003F0000007F0000}
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = True
  Position = poDefault
  ShowHint = True
  PixelsPerInch = 96
  TextHeight = 13
  object dxBarManager: TdxBarManager
    AutoHideEmptyBars = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    Bars = <
      item
        Caption = 'MenuBar'
        DockedDockingStyle = dsTop
        DockedLeft = 0
        DockedTop = 0
        DockingStyle = dsTop
        FloatLeft = 0
        FloatTop = 0
        FloatClientWidth = 0
        FloatClientHeight = 0
        IsMainMenu = True
        ItemLinks = <
          item
            Item = bbFile
            Visible = True
          end
          item
            Item = bbExplorer
            Visible = True
          end
          item
            Item = bbEdit
            Visible = True
          end
          item
            Item = bbView
            Visible = True
          end
          item
            Item = bbInsert
            Visible = True
          end
          item
            Item = bbFormat
            Visible = True
          end
          item
            Item = bbGoToPage
            Visible = True
          end
          item
            Item = bbTools
            Visible = True
          end
          item
            Item = bbHelp
            Visible = True
          end>
        MultiLine = True
        Name = 'Build-In Menus'
        OneOnRow = True
        Row = 0
        UseOwnFont = False
        Visible = True
        WholeRow = False
      end
      item
        Caption = 'Standard'
        DockedDockingStyle = dsTop
        DockedLeft = 0
        DockedTop = 23
        DockingStyle = dsTop
        FloatLeft = 332
        FloatTop = 321
        FloatClientWidth = 554
        FloatClientHeight = 22
        ItemLinks = <
          item
            Item = bbFileDesign
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbFileLoad
            Visible = True
          end
          item
            Item = bbFileClose
            Visible = True
          end
          item
            Item = bbFileSave
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbFilePrint
            Visible = True
          end
          item
            Item = bbFilePrintDialog
            Visible = True
          end
          item
            Item = bbFilePageSetup
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbViewExplorer
            Visible = True
          end
          item
            Item = bbViewThumbnails
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbFormatTitle
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbZoomPercent100
            Visible = True
          end
          item
            Item = bbZoomPageWidth
            Visible = True
          end
          item
            Item = bbZoomWholePage
            Visible = True
          end
          item
            Item = bbZoomTwoPages
            Visible = True
          end
          item
            Item = bbZoomMultiplePages
            Visible = True
          end
          item
            Item = cbxPredefinedZoom
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbFormatPageBackground
            Visible = True
          end
          item
            Item = bbFormatShrinkToPageWidth
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbGoToFirstPage
            Visible = True
          end
          item
            Item = bbGoToPrevPage
            Visible = True
          end
          item
            Item = seActivePage
            UserDefine = [udWidth]
            UserWidth = 63
            Visible = True
          end
          item
            Item = bbGoToNextPage
            Visible = True
          end
          item
            Item = bbGoToLastPage
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbFileExit
            Visible = True
          end>
        Name = 'Standard'
        OneOnRow = True
        Row = 1
        UseOwnFont = False
        Visible = True
        WholeRow = False
      end
      item
        AllowClose = False
        Caption = 'Header and Footer'
        DockedDockingStyle = dsTop
        DockedLeft = 50
        DockedTop = 0
        DockingStyle = dsNone
        FloatLeft = 523
        FloatTop = 228
        FloatClientWidth = 601
        FloatClientHeight = 22
        Hidden = True
        ItemLinks = <
          item
            Item = bsiInsertAutoText
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbInsertHFPageNumber
            UserDefine = [udPaintStyle]
            Visible = True
          end
          item
            Item = bbInsertHFTotalPages
            UserDefine = [udPaintStyle]
            Visible = True
          end
          item
            Item = bbInsertHFPageOfPages
            Visible = True
          end
          item
            Item = bbFormatPageNumbering
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbInsertHFDateTime
            Visible = True
          end
          item
            Item = bbInsertHFDate
            Visible = True
          end
          item
            Item = bbInsertHFTime
            Visible = True
          end
          item
            Item = bbFormatDateTime
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbInsertHFUserName
            Visible = True
          end
          item
            Item = bbInsertHFMachineName
            UserDefine = [udPaintStyle]
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbFormatHFClear
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbFormatHFBackground
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbFilePageSetup
            Visible = True
          end
          item
            Item = bbViewHFSwitchHeaderFooter
            Visible = True
          end
          item
            Item = bbViewSwitchToLeftPart
            Visible = True
          end
          item
            Item = bbViewSwitchToCenterPart
            Visible = True
          end
          item
            Item = bbViewSwitchToRightPart
            Visible = True
          end
          item
            BeginGroup = True
            Item = bbViewHFClose
            Visible = True
          end>
        Name = 'Header and Footer'
        OneOnRow = True
        Row = 0
        UseOwnFont = False
        Visible = False
        WholeRow = False
      end
      item
        Caption = 'Shortcut Menus'
        DockedDockingStyle = dsTop
        DockedLeft = 0
        DockedTop = 0
        DockingStyle = dsNone
        FloatLeft = 293
        FloatTop = 319
        FloatClientWidth = 188
        FloatClientHeight = 19
        Hidden = True
        ItemLinks = <
          item
            Item = bsiShortcutPreview
            Visible = True
          end
          item
            Item = bsiShortCutExplorer
            Visible = True
          end
          item
            Item = bsiShortcutThumbnails
            Visible = True
          end>
        Name = 'Shortcut Menus'
        NotDocking = [dsLeft, dsTop, dsRight, dsBottom]
        OneOnRow = False
        Row = 0
        UseOwnFont = False
        Visible = False
        WholeRow = False
      end
      item
        Caption = 'AutoText'
        DockedDockingStyle = dsTop
        DockedLeft = 0
        DockedTop = 0
        DockingStyle = dsNone
        FloatLeft = 460
        FloatTop = 288
        FloatClientWidth = 124
        FloatClientHeight = 22
        ItemLinks = <
          item
            Item = bbInsertEditAutoText
            Visible = True
          end
          item
            BeginGroup = True
            Item = bsiInsertAutoText
            Visible = True
          end>
        Name = 'AutoText'
        OneOnRow = False
        Row = 0
        UseOwnFont = False
        Visible = False
        WholeRow = False
      end
      item
        Caption = 'Explorer'
        DockedDockingStyle = dsTop
        DockedLeft = 0
        DockedTop = 49
        DockingStyle = dsTop
        FloatLeft = 461
        FloatTop = 349
        FloatClientWidth = 23
        FloatClientHeight = 22
        ItemLinks = <
          item
            Item = bbExplorerCreateNewFolder
            Visible = True
          end
          item
            Item = bbExplorerDelete
            Visible = True
          end
          item
            Item = bbExplorerProperties
            Visible = True
          end>
        Name = 'Explorer'
        OneOnRow = True
        Row = 2
        UseOwnFont = False
        Visible = False
        WholeRow = False
      end>
    Categories.Strings = (
      'File'
      'Explorer'
      'Edit'
      'Insert'
      'View'
      'Format'
      'Zoom'
      'Tools'
      'Go'
      'Help'
      'Built-in Menus'
      'Shortcut Menus'
      'New Menu')
    Categories.ItemsVisibles = (
      2
      2
      0
      2
      2
      2
      2
      2
      2
      2
      2
      2
      2)
    Categories.Visibles = (
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      True
      False
      True)
    Images = ilToolBar
    LargeImages = ilToolBar
    MenusShowRecentItemsFirst = False
    PopupMenuLinks = <
      item
        PopupMenu = pmPreview
      end
      item
        PopupMenu = pmThumbnails
      end>
    ShowShortCutInHint = True
    StoreInRegistry = True
    StretchGlyphs = False
    Style = bmsFlat
    UseSystemFont = True
    OnBarVisibleChange = dxBarManagerBarVisibleChange
    OnHideCustomizingForm = dxBarManagerHideCustomizingForm
    OnShowCustomizingForm = dxBarManagerShowCustomizingForm
    Left = 63
    Top = 197
    DockControlHeights = (
      0
      0
      49
      0)
    object bbFile: TdxBarSubItem
      Caption = '&File'
      Category = 10
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bbFileDesign
          Visible = True
        end
        item
          Item = bbFileRebuild
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbFileLoad
          Visible = True
        end
        item
          Item = bbFileClose
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbFileSave
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbFilePrintDialog
          Visible = True
        end
        item
          Item = bbFilePageSetup
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbFileExit
          Visible = True
        end>
    end
    object bbFileDesign: TdxBarButton
      Caption = '&Design...'
      Category = 0
      Hint = 'ReportDesign|'
      Visible = ivNever
      ImageIndex = 0
      ShortCut = 16452
      OnClick = DesignClick
    end
    object bbFileRebuild: TdxBarButton
      Caption = 'Rebuild'
      Category = 0
      Hint = 'Rebuild'
      Visible = ivAlways
      ShortCut = 16500
      OnClick = bbFileRebuildClick
    end
    object bbViewMargins: TdxBarButton
      Caption = '&Margins'
      Category = 4
      Hint = 'Margins'
      Visible = ivAlways
      ButtonStyle = bsChecked
      Down = True
      ShortCut = 16461
      OnClick = bbViewMarginsClick
    end
    object bbZoomPercent100: TdxBarButton
      Caption = '&Percent 100'
      Category = 6
      Hint = 'Zoom 100 %'
      Visible = ivAlways
      ImageIndex = 5
      ShortCut = 16604
      OnClick = ZoomClick
    end
    object bbZoomPageWidth: TdxBarButton
      Tag = 1
      Caption = '&Fit To Window'
      Category = 6
      Hint = 'Zoom Page Width'
      Visible = ivAlways
      ImageIndex = 6
      ShortCut = 16432
      OnClick = ZoomClick
    end
    object bbZoomWholePage: TdxBarButton
      Tag = 2
      Caption = '&One Page'
      Category = 6
      Hint = 'Zoom One Page'
      Visible = ivAlways
      ImageIndex = 7
      ShortCut = 16433
      OnClick = ZoomClick
    end
    object bbZoomTwoPages: TdxBarButton
      Tag = 3
      Caption = '&Two Page'
      Category = 6
      Hint = 'Zoom Two Page'
      Visible = ivAlways
      ImageIndex = 8
      ShortCut = 16434
      OnClick = ZoomClick
    end
    object bbExplorer: TdxBarSubItem
      Caption = 'E&xplorer'
      Category = 10
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bbExplorerCreateNewFolder
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbExplorerDelete
          Visible = True
        end
        item
          Item = bbExplorerRename
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbExplorerProperties
          Visible = True
        end>
    end
    object bbGoToFirstPage: TdxBarButton
      Caption = '&First Page'
      Category = 8
      Hint = 'Go to First Page'
      Visible = ivAlways
      ImageIndex = 13
      ShortCut = 36
      OnClick = GoToPageClick
    end
    object bbGoToPrevPage: TdxBarButton
      Tag = 1
      Caption = '&Previous Page'
      Category = 8
      Hint = 'Go to Prev Page'
      Visible = ivAlways
      ImageIndex = 14
      ShortCut = 33
      OnClick = GoToPageClick
    end
    object bbGoToNextPage: TdxBarButton
      Tag = 2
      Caption = '&Next Page'
      Category = 8
      Hint = 'Go to Next Page'
      Visible = ivAlways
      ImageIndex = 15
      ShortCut = 34
      OnClick = GoToPageClick
    end
    object bbGoToLastPage: TdxBarButton
      Tag = 3
      Caption = '&Last Page'
      Category = 8
      Hint = 'Go to Last Page'
      Visible = ivAlways
      ImageIndex = 16
      ShortCut = 35
      OnClick = GoToPageClick
    end
    object bbEdit: TdxBarSubItem
      Caption = '&Edit'
      Category = 10
      Visible = ivNever
      ItemLinks = <
        item
          Item = bbEditFind
          Visible = True
        end
        item
          Item = bbEditFindNext
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbEditReplace
          Visible = True
        end>
    end
    object bbZoomFourPages: TdxBarButton
      Tag = 4
      Caption = 'Four Page'
      Category = 6
      Hint = 'Zoom Four Page'
      Visible = ivAlways
      ImageIndex = 9
      ShortCut = 16436
      OnClick = ZoomClick
    end
    object bbZoomMultiplePages: TdxBarButton
      Caption = '&Multiple Pages'
      Category = 6
      Hint = 'Multiple Pages'
      Visible = ivAlways
      ImageIndex = 10
      OnClick = bbZoomMultiplePagesClick
    end
    object bbZoomWidenToSourceWidth: TdxBarButton
      Tag = 5
      Caption = 'Widen To Source Width'
      Category = 6
      Hint = 'Widen to source width'
      Visible = ivAlways
      ImageIndex = 11
      OnClick = ZoomClick
    end
    object seActivePage: TdxBarSpinEdit
      Caption = '&Active Page :'
      Category = 8
      Hint = 'Active Page :'
      Visible = ivAlways
      OnChange = seActivePageChange
      Width = 100
      OnButtonClick = seActivePageButtonClick
    end
    object cbxPredefinedZoom: TdxBarImageCombo
      Caption = '&Zoom :'
      Category = 6
      Hint = 'Zoom :'
      Visible = ivAlways
      Text = '100%'
      OnChange = cbxPredefinedZoomChange
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888008888888888888800088888888888888000888888888888880008700007
        88888880000888800888888807EE88887088888708E88888807888808E888888
        88088880888888888808888088888888E808888088888888E80888870888888E
        E078888807888EEE708888888008888008888888887000078888}
      Width = 100
      OnClick = cbxPredefinedZoomClick
      ShowEditor = True
      Images = ilToolBar
      Items.Strings = (
        '500%'
        '200%'
        '150%'
        '100%'
        '75%'
        '50%'
        '25%'
        '10%'
        'Page Width'
        'Whole Page'
        'Two Pages'
        'Four Pages'
        'Widen To Source Width')
      ItemIndex = 3
      ImageIndexes = (
        -1
        -1
        -1
        5
        -1
        -1
        -1
        -1
        6
        7
        8
        9
        11)
    end
    object bbFileLoad: TdxBarButton
      Caption = '&Load...'
      Category = 0
      Hint = 'Load'
      Visible = ivAlways
      ImageIndex = 43
      ShortCut = 16463
      OnClick = ExplorerLoadDataClick
    end
    object bbZoomSetup: TdxBarButton
      Caption = '&Setup ...'
      Category = 6
      Hint = 'Setup '
      Visible = ivAlways
      PaintStyle = psCaption
      OnClick = bbZoomSetupClick
    end
    object bbToolsOptions: TdxBarButton
      Caption = '&Options...'
      Category = 7
      Hint = 'Options'
      Visible = ivAlways
      OnClick = bbToolsOptionsClick
    end
    object bbViewMarginBar: TdxBarButton
      Caption = 'MarginBar'
      Category = 4
      Hint = 'Margin Bar'
      Visible = ivAlways
      ButtonStyle = bsChecked
      Down = True
      OnClick = bbViewMarginBarClick
    end
    object bbFileSave: TdxBarButton
      Caption = '&Save...'
      Category = 0
      Hint = 'Save'
      Visible = ivAlways
      ImageIndex = 38
      ShortCut = 16467
      OnClick = FileSaveClick
    end
    object bbViewStatusBar: TdxBarButton
      Caption = 'StatusBar'
      Category = 4
      Hint = 'StatusBar'
      Visible = ivAlways
      ButtonStyle = bsChecked
      Down = True
      OnClick = bbViewStatusBarClick
    end
    object bbHelpTopics: TdxBarButton
      Caption = '&Help Topics...'
      Category = 9
      Hint = 'Help'
      Visible = ivAlways
      ImageIndex = 17
      OnClick = HelpClick
    end
    object bbViewExplorer: TdxBarButton
      Caption = 'E&xplorer'
      Category = 4
      Hint = 'Explorer'
      Visible = ivAlways
      ButtonStyle = bsChecked
      ImageIndex = 48
      ShortCut = 16472
      OnClick = bbViewExplorerClick
    end
    object bsiShortcutPreview: TdxBarSubItem
      Caption = 'Preview'
      Category = 11
      Visible = ivInCustomizing
      ItemLinks = <>
    end
    object bsiInsertHFAutoText: TdxBarSubItem
      Caption = 'AutoText'
      Category = 3
      Visible = ivAlways
      Detachable = True
      DetachingBar = 4
      ItemLinks = <
        item
          Item = bbInsertEditAutoText
          Visible = True
        end
        item
          BeginGroup = True
          Item = bliInsertAutoTextEntries
          Visible = True
        end>
    end
    object bbInsertEditAutoText: TdxBarButton
      Caption = 'AutoTe&xt...'
      Category = 3
      Hint = 'AutoText'
      Visible = ivAlways
      ImageIndex = 33
    end
    object bsiInsertAutoText: TdxBarSubItem
      Caption = 'Insert AutoText'
      Category = 3
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bliInsertAutoTextEntries
          Visible = True
        end>
    end
    object bliInsertAutoTextEntries: TdxBarListItem
      Caption = 'List of AutoText Entries'
      Category = 3
      Visible = ivAlways
      ShowNumbers = False
    end
    object bbInsertHFPageNumber: TdxBarButton
      Caption = '&Page Number'
      Category = 3
      Hint = 'Insert Page Number'
      Visible = ivAlways
      ImageIndex = 19
      ShortCut = 41040
      OnClick = InsertHFClick
    end
    object bbInsertHFTotalPages: TdxBarButton
      Tag = 1
      Caption = '&Number of Pages'
      Category = 3
      Hint = 'Insert Number of Pages'
      Visible = ivAlways
      ImageIndex = 21
      OnClick = InsertHFClick
    end
    object bbInsertHFPageOfPages: TdxBarButton
      Tag = 2
      Caption = 'Page Number Of Pages'
      Category = 3
      Hint = 'Insert Page Number Of Pages'
      Visible = ivAlways
      ImageIndex = 20
      OnClick = InsertHFClick
    end
    object bbInsertHFDateTime: TdxBarButton
      Tag = 3
      Caption = 'Date and Time'
      Category = 3
      Hint = 'Insert Date and Time'
      Visible = ivAlways
      ImageIndex = 23
      OnClick = InsertHFClick
    end
    object bbInsertHFDate: TdxBarButton
      Tag = 4
      Caption = '&Date'
      Category = 3
      Hint = 'Insert Date'
      Visible = ivAlways
      ImageIndex = 24
      ShortCut = 41028
      OnClick = InsertHFClick
    end
    object bbInsertHFTime: TdxBarButton
      Tag = 5
      Caption = '&Time'
      Category = 3
      Hint = 'Insert Time'
      Visible = ivAlways
      ImageIndex = 25
      ShortCut = 41044
      OnClick = InsertHFClick
    end
    object bbInsertHFUserName: TdxBarButton
      Tag = 6
      Caption = '&User Name'
      Category = 3
      Hint = 'Insert User Name'
      Visible = ivAlways
      ImageIndex = 27
      OnClick = InsertHFClick
    end
    object bbInsert: TdxBarSubItem
      Caption = '&Insert'
      Category = 10
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bsiInsertHFAutoText
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbInsertHFPageNumber
          Visible = True
        end
        item
          Item = bbInsertHFTotalPages
          Visible = True
        end
        item
          Item = bbInsertHFPageOfPages
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbInsertHFDateTime
          Visible = True
        end
        item
          Item = bbInsertHFDate
          Visible = True
        end
        item
          Item = bbInsertHFTime
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbInsertHFUserName
          Visible = True
        end
        item
          Item = bbInsertHFMachineName
          Visible = True
        end>
    end
    object bbView: TdxBarSubItem
      Caption = '&View'
      Category = 10
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bbViewMargins
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbViewMarginBar
          Visible = True
        end
        item
          Item = bbViewStatusBar
          Visible = True
        end
        item
          Item = bbViewExplorer
          Visible = True
        end
        item
          Item = bbViewThumbnails
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbViewToolbars
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbFormatHeaderAndFooter
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbViewZoom
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbViewPageHeaders
          Visible = True
        end
        item
          Item = bbViewPageFooters
          Visible = True
        end>
    end
    object bbViewZoom: TdxBarSubItem
      Caption = 'Zoom'
      Category = 10
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bbZoomPercent100
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbZoomPageWidth
          Visible = True
        end
        item
          Item = bbZoomWholePage
          Visible = True
        end
        item
          Item = bbZoomTwoPages
          Visible = True
        end
        item
          Item = bbZoomFourPages
          Visible = True
        end
        item
          Item = bbZoomMultiplePages
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbZoomWidenToSourceWidth
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbZoomSetup
          Visible = True
        end>
    end
    object bbFormatHeaderAndFooter: TdxBarButton
      Caption = '&Header and Footer'
      Category = 5
      Hint = 'Header and Footer'
      Visible = ivAlways
      AllowAllUp = True
      ButtonStyle = bsChecked
      ImageIndex = 36
      OnClick = bbFormatHeaderAndFooterClick
    end
    object bbFormatDateTime: TdxBarButton
      Caption = 'Date and &Time...'
      Category = 5
      Hint = 'Date and Time'
      Visible = ivAlways
      ImageIndex = 26
      OnClick = bbFormatDateTimeClick
    end
    object bbFormatPageNumbering: TdxBarButton
      Caption = 'Page &Numbering...'
      Category = 5
      Hint = 'Page Numbering'
      Visible = ivAlways
      ImageIndex = 22
      OnClick = bbFormatPageNumbersClick
    end
    object bbEditFind: TdxBarButton
      Caption = 'Find...'
      Category = 2
      Hint = 'Find'
      Visible = ivNever
      ShortCut = 16454
    end
    object bbFormatPageBackground: TdxBarButton
      Caption = 'Page Bac&kground...'
      Category = 5
      Hint = 'Background'
      Visible = ivAlways
      ImageIndex = 4
      ShortCut = 16459
      OnClick = PageBackgroundClick
    end
    object bbFormatShrinkToPageWidth: TdxBarButton
      Caption = '&Shrink To Page'
      Category = 5
      Hint = 'Shrink To Page'
      Visible = ivAlways
      AllowAllUp = True
      ButtonStyle = bsChecked
      ImageIndex = 12
      OnClick = bbFormatShrinkToPageWidthClick
    end
    object bbEditFindNext: TdxBarButton
      Caption = 'Find &Next'
      Category = 2
      Hint = 'Find Next'
      Visible = ivNever
      ShortCut = 114
    end
    object bbEditReplace: TdxBarButton
      Caption = '&Replace...'
      Category = 2
      Hint = 'Replace'
      Visible = ivNever
      ShortCut = 16466
    end
    object bbFormatShowHideEmptyPages: TdxBarButton
      Caption = 'Show/Hide EmptyPages'
      Category = 5
      Hint = 'Show/Hide Empty Pages'
      Visible = ivAlways
      ButtonStyle = bsChecked
      OnClick = bbFormatShowHideEmptyPagesClick
    end
    object bbViewThumbnails: TdxBarButton
      Caption = 'Th&umbnails'
      Category = 4
      Hint = 'Thumbnails'
      Visible = ivAlways
      ButtonStyle = bsChecked
      ImageIndex = 49
      ShortCut = 16469
      OnClick = bbViewThumbnailsClick
    end
    object bbFormatHFBackground: TdxBarButton
      Caption = 'Header and Footer Background ...'
      Category = 5
      Hint = 'Header and Footer Background '
      Visible = ivAlways
      ImageIndex = 34
      OnClick = bbFormatHFBackgroundClick
    end
    object bbThumbnailsSmall: TdxBarButton
      Caption = '&Small Thumbnails'
      Category = 4
      Hint = 'Small Thumbnails'
      Visible = ivAlways
      ButtonStyle = bsChecked
      OnClick = bbThumbnailsSizeClick
    end
    object bbToolsCustomize: TdxBarButton
      Caption = '&Customize...'
      Category = 7
      Hint = 'Customize'
      Visible = ivAlways
      OnClick = bbToolsCustomizeClick
    end
    object bbThumbnailsLarge: TdxBarButton
      Tag = 1
      Caption = '&Large Thumbnails'
      Category = 4
      Hint = 'Large Thumbnails'
      Visible = ivAlways
      ButtonStyle = bsChecked
      Down = True
      OnClick = bbThumbnailsSizeClick
    end
    object bbViewPages: TdxBarSubItem
      Caption = 'Pages'
      Category = 10
      Visible = ivNever
      ItemLinks = <>
    end
    object bbViewToolbars: TdxBarToolbarsListItem
      Caption = '&Toolbars'
      Category = 4
      Visible = ivAlways
    end
    object bbHelpAbout: TdxBarButton
      Caption = '&About...'
      Category = 9
      Hint = 'About'
      Visible = ivNever
    end
    object bbViewPageHeaders: TdxBarButton
      Caption = 'Page &Headers'
      Category = 4
      Hint = 'Page Headers'
      Visible = ivAlways
      ButtonStyle = bsChecked
      Down = True
      OnClick = bbViewPageHeadersClick
    end
    object bbViewPageFooters: TdxBarButton
      Caption = 'Page &Footers'
      Category = 4
      Hint = 'Page Footers'
      Visible = ivAlways
      ButtonStyle = bsChecked
      Down = True
      OnClick = bbViewPageFootersClick
    end
    object bbViewSwitchToLeftPart: TdxBarButton
      Caption = 'Switch To Left Part'
      Category = 4
      Hint = 'Switch To Left Part'
      Visible = ivAlways
      ButtonStyle = bsChecked
      GroupIndex = 1
      Down = True
      ImageIndex = 30
      OnClick = SwitchPartClick
    end
    object bbFormat: TdxBarSubItem
      Caption = '&Format'
      Category = 10
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bbFormatTitle
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbFormatPageNumbering
          Visible = True
        end
        item
          Item = bbFormatDateTime
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbFormatShrinkToPageWidth
          Visible = True
        end
        item
          Item = bbFormatShowHideEmptyPages
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbFormatPageBackground
          Visible = True
        end>
    end
    object bbGoToPage: TdxBarSubItem
      Caption = '&Go'
      Category = 10
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bbGoToFirstPage
          Visible = True
        end
        item
          Item = bbGoToPrevPage
          Visible = True
        end
        item
          BeginGroup = True
          Item = seActivePage
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbGoToNextPage
          Visible = True
        end
        item
          Item = bbGoToLastPage
          Visible = True
        end>
    end
    object bbFormatHFClear: TdxBarButton
      Caption = 'Clea&r Text'
      Category = 5
      Hint = 'Clear Text'
      Visible = ivAlways
      OnClick = bbFormatHFClearClick
    end
    object bsiNewMenuNewMenu: TdxBarSubItem
      Caption = 'New Item'
      Category = 12
      Visible = ivAlways
      ItemLinks = <>
    end
    object bbFileClose: TdxBarButton
      Caption = '&Unload'
      Category = 0
      Hint = 'Unload'
      Visible = ivAlways
      ImageIndex = 44
      ShortCut = 16499
      OnClick = bbFileCloseClick
    end
    object bbFilePrint: TdxBarButton
      Caption = 'Print'
      Category = 0
      Hint = 'Print'
      Visible = ivNever
      ImageIndex = 1
      OnClick = PrintClick
    end
    object bbInsertHFMachineName: TdxBarButton
      Tag = 7
      Caption = '&Machine Name'
      Category = 3
      Hint = 'Insert Machine Name'
      Visible = ivAlways
      ImageIndex = 28
      OnClick = InsertHFClick
    end
    object bbFilePrintDialog: TdxBarButton
      Tag = 1
      Caption = '&Print...'
      Category = 0
      Hint = 'Print Dialog'
      Visible = ivNever
      ImageIndex = 2
      ShortCut = 16464
      OnClick = PrintClick
    end
    object bbTools: TdxBarSubItem
      Caption = '&Tools'
      Category = 10
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bbToolsCustomize
          Visible = True
        end
        item
          Item = bbToolsOptions
          Visible = True
        end>
    end
    object bbExplorerCreateNewFolder: TdxBarButton
      Caption = 'Create &Folder...'
      Category = 1
      Hint = 'Create Folder'
      Visible = ivAlways
      ImageIndex = 40
      ShortCut = 32821
      OnClick = ExplorerCreateNewFolderClick
    end
    object bbHelp: TdxBarSubItem
      Caption = '&Help'
      Category = 10
      Visible = ivAlways
      ItemLinks = <
        item
          Item = bbHelpTopics
          Visible = True
        end
        item
          BeginGroup = True
          Item = bbHelpAbout
          Visible = True
        end>
    end
    object bbFilePageSetup: TdxBarButton
      Tag = 2
      Caption = 'Page set&up...'
      Category = 0
      Hint = 'Page Setup '
      Visible = ivNever
      ButtonStyle = bsDropDown
      DropDownMenu = pmPrintStyles
      ImageIndex = 3
      OnClick = PageSetupClick
    end
    object bbViewSwitchToCenterPart: TdxBarButton
      Tag = 1
      Caption = 'Switch To Center Part'
      Category = 4
      Hint = 'Switch To Center Part'
      Visible = ivAlways
      ButtonStyle = bsChecked
      GroupIndex = 1
      ImageIndex = 31
      OnClick = SwitchPartClick
    end
    object bliPrintStyles: TdxBarListItem
      Caption = 'Print Styles'
      Category = 0
      Visible = ivAlways
      ShowCheck = True
      ShowNumbers = False
    end
    object bsiShortCutExplorer: TdxBarSubItem
      Caption = 'Explorer'
      Category = 11
      Visible = ivAlways
      ItemLinks = <>
    end
    object bbDefinePrintStyles: TdxBarButton
      Caption = 'Define Print Styles...'
      Category = 0
      Hint = 'Define Print Styles'
      Visible = ivAlways
    end
    object bbExplorerDelete: TdxBarButton
      Caption = '&Delete...'
      Category = 1
      Hint = 'Delete'
      Visible = ivAlways
      ImageIndex = 39
      ShortCut = 46
      OnClick = ExplorerDeleteItemClick
    end
    object bbExplorerRename: TdxBarButton
      Caption = '&Rename...'
      Category = 1
      Hint = 'Rename'
      Visible = ivAlways
      ShortCut = 113
      OnClick = ExplorerRenameItemClick
    end
    object bbFormatTitle: TdxBarButton
      Caption = 'Title...'
      Category = 5
      Hint = 'Title'
      Visible = ivAlways
      ImageIndex = 45
      OnClick = bbFormatTitleClick
    end
    object bbViewSwitchToRightPart: TdxBarButton
      Tag = 2
      Caption = 'Switch To Right Part'
      Category = 4
      Hint = 'Switch To Right Part'
      Visible = ivAlways
      ButtonStyle = bsChecked
      GroupIndex = 1
      ImageIndex = 32
      OnClick = SwitchPartClick
    end
    object bbViewHFSwitchHeaderFooter: TdxBarButton
      Caption = '&Show Header/Footer'
      Category = 4
      Hint = 'Show Header/Footer'
      Visible = ivAlways
      AllowAllUp = True
      ButtonStyle = bsChecked
      ImageIndex = 29
      OnClick = bbViewHFSwitchHeaderFooterClick
    end
    object bbViewHFClose: TdxBarButton
      Caption = '&Close'
      Category = 4
      Hint = 'Close Header and Footer'
      Visible = ivAlways
      OnClick = bbViewHFCloseClick
    end
    object bsiShortcutThumbnails: TdxBarSubItem
      Caption = 'Thumbnails'
      Category = 11
      Visible = ivAlways
      ItemLinks = <>
    end
    object bbExplorerProperties: TdxBarButton
      Caption = '&Properties...'
      Category = 1
      Hint = 'P&roperties'
      Visible = ivAlways
      ImageIndex = 46
      ShortCut = 32781
      OnClick = bbExplorerPropertiesClick
    end
    object bbFileExit: TdxBarButton
      Caption = '&Close'
      Category = 0
      Hint = 'Close'
      Visible = ivAlways
      OnClick = CloseClick
    end
  end
  object ilToolBar: TImageList
    AllocBy = 48
    Left = 35
    Top = 197
    Bitmap = {
      494C010132003600040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      000000000000360000002800000040000000E0000000010020000000000000E0
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
      0000FF000000FFFF000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FFFF00008000000000000000000000000000000000000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000808000008080000080
      8000008080000080800000808000008080000080800000808000FF000000FFFF
      0000800000000080800000808000000000000000000000000000808080000000
      0000000000000000000080808000000000000000000000000000808080000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF00FF000000FFFF00008000
      000000FFFF0000FFFF000080800000000000000000000000000080808000FFFF
      FF00FFFFFF000000000080808000FFFFFF00FFFFFF000000000080808000FFFF
      FF00FFFFFF000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF0000FFFF0000FF
      FF0000FFFF00C0C0C000000000000000000000000000C0C0C0008000000000FF
      FF0000FFFF0000FFFF000080800000000000000000000000000080808000FFFF
      FF00FFFFFF000000000080808000FFFFFF00FFFFFF000000000080808000FFFF
      FF00FFFFFF000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF0000FFFF0000FF
      FF00C0C0C00000000000FFFF0000C0C0C000FFFF000000000000C0C0C00000FF
      FF0000FFFF0000FFFF000080800000000000000000000000000080808000FFFF
      FF00FFFFFF000000000080808000FFFFFF00FFFFFF000000000080808000FFFF
      FF00FFFFFF000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF0000FFFF0000FF
      FF0000000000FFFF0000C0C0C000FFFF0000C0C0C000FFFF00000000000000FF
      FF0000FFFF0000FFFF0000808000000000000000000000000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF0000FFFF0000FF
      FF0000000000C0C0C000FFFF0000C0C0C000FFFF0000C0C0C0000000000000FF
      FF0000FFFF0000FFFF0000808000000000000000000000000000808080000000
      0000000000000000000080808000000000000000000000000000808080000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF0000FFFF0000FF
      FF0000000000FFFF0000C0C0C000FFFF0000C0C0C000FFFF00000000000000FF
      FF0000FFFF0000FFFF000080800000000000000000000000000080808000FFFF
      FF00FFFFFF000000000080808000FFFFFF00FFFFFF000000000080808000FFFF
      FF00FFFFFF000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF0000FFFF0000FF
      FF00C0C0C00000000000FFFF0000C0C0C000FFFF000000000000C0C0C00000FF
      FF0000FFFF0000FFFF000080800000000000000000000000000080808000FFFF
      FF00FFFFFF000000000080808000FFFFFF00FFFFFF000000000080808000FFFF
      FF00FFFFFF000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF0000FFFF0000FF
      FF0000FFFF00C0C0C000000000000000000000000000C0C0C00000FFFF0000FF
      FF0000FFFF0000FFFF000080800000000000000000000000000080808000FFFF
      FF00FFFFFF000000000080808000FFFFFF00FFFFFF000000000080808000FFFF
      FF00FFFFFF000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000808000000000000000000000000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008080800000FFFF000000
      0000FFFFFF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000FFFF
      FF00000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF0000000000000000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000FFFF
      FF00808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000808080000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF00000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      800000808000000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000FFFFFF0000000000808080000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      800000808000000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C000FFFFFF00FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0
      C000FFFFFF0000000000808080000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000000000000000000000000000000000000000
      0000FFFFFF0000FFFF00FFFFFF00000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      800000808000000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C000FFFFFF00FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0
      C000FFFFFF0000000000808080000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      800000808000000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000FFFFFF0000000000808080000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF00000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      800000808000000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C000FFFFFF00FFFFFF00C0C0C000FFFFFF00C0C0C000FFFFFF00C0C0
      C000FFFFFF0000000000808080000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000FFFF00FFFF
      FF000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      800000808000000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000FFFFFF0000000000808080000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF0000000000C0C0C00000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF00000000000000000000000000FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF00000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      800000808000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000808080000000000000000000FFFFFF0000000000C0C0
      C00000000000FFFFFF0000000000C0C0C00000000000C0C0C000000000000000
      000000000000000000008000000080000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000808080000000000000000000000000000000000000000000FFFF
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF00FFFFFF0000000000808080000000000000000000FFFFFF00FFFFFF000000
      0000C0C0C00000000000C0C0C00000000000C0C0C00000000000C0C0C000C0C0
      C000C0C0C0000000000080000000800000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      000000000000000000000000000080000000000000000000000000000000FFFF
      FF000000FF000000000000000000000000000000000000000000000000000000
      FF00FFFFFF000000000080808000000000000000000000000000000000000000
      000000000000C0C0C00000000000C0C0C00000000000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C00080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000080000000000000000000000000000000FFFF
      FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF00FFFFFF000000000080808000000000000000000000000000000000000000
      00000000000000000000C0C0C00000000000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000C0C0C000800000008000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000080000000000000008000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C0000000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080000000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000008000000080000000000000000000000000000000000000000000
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
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF00000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF008000000080000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF00000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00000000000000000000000000000000000000000000000000FFFF
      FF0000FFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080000000800000008000000080000000800000008000
      0000FFFFFF00FFFFFF0000000000000000000000000000FFFF00000000000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF008000000080000000FFFFFF00FFFFFF00FFFF
      FF0080000000FFFFFF00000000000000000000000000FFFFFF0000FFFF000000
      0000008080000080800000808000008080000080800000808000008080000080
      80000080800000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF00000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF00FFFFFF00FFFF
      FF0080000000FFFFFF0000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000080800000808000008080000080800000808000008080000080
      8000008080000080800000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF008080800000FFFF00FFFFFF0000FFFF008080
      800000FFFF0000FFFF0000FFFF00808080000000000000FFFF00FFFFFF000000
      000000000000000000000000000000000000FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF008080800000FFFF0000FFFF008080
      800000FFFF00FFFFFF008080800000FFFF0000000000FFFFFF0000FFFF00FFFF
      FF00000000000000000000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF0080000000FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF008080800000FFFF008080
      8000FFFFFF008080800000FFFF00000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF000000000000000000000000000000000000000000FFFF
      FF0080000000FFFFFF00FFFFFF00FFFFFF008000000080000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF0080808000808080008080800080808000FFFF
      FF008080800080808000808080008080800000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00800000008000000080000000800000008000000080000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000FFFF008080800000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008000000080000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF0000000000000000008080800000FFFF008080
      800000FFFF008080800000FFFF0000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000FFFF00000000008080
      8000FFFFFF00000000008080800000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000008080800000FFFF0000000000000000008080
      8000808080000000000000000000808080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000FFFFFF000000000000000000000000000000000000000000000000000000
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
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008000
      8000C0C0C0000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000000000000000000000000000000000008000
      8000800080008000800080008000800080008000800080008000800080008000
      8000800080000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008000
      8000C0C0C0000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      000000000000FFFFFF000000000000000000000000000000000000000000FFFF
      FF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FFFFFF000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008000
      8000C0C0C0000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008000
      8000C0C0C0000000000000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000008080000080800000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FFFFFF000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008000
      8000C0C0C0000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000008080000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00000000000000000000000000FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008000
      8000C0C0C0000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C000FFFFFF000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008000
      8000C0C0C0000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008000
      8000C0C0C0000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C0008000
      8000C0C0C0000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00000000000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000FFFFFF0000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000008000
      800080008000800080008000800080008000800080008000800000000000C0C0
      C000000000000000000000000000000000000000000000000000008080000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C0C0C00000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000C0C0C00080008000C0C0C000C0C0C000C0C0C000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000084848400848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840000FFFF00848484008484
      840000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000084848400FFFFFF008484
      8400FFFFFF00FFFFFF0000FFFF000000000000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840000FFFF0000FFFF0000FF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000084848400000000008484
      840000000000FFFFFF0000FFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000848484008484
      84008484840000000000FFFFFF00FFFFFF0000FFFF0084848400FFFFFF00FFFF
      FF0000FFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000C6C6C600C6C6C600C6C6
      C600848484008484840000000000FFFFFF00FFFFFF008400000084848400FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6C600C6C6
      C600C6C6C60084848400848484000000000000FFFF008400000084000000FFFF
      FF0000FFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C6008484840084848400840000008400000084000000FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF000000
      0000FFFFFF0000000000FFFFFF0000000000C6C6C600FFFFFF00FFFFFF00C6C6
      C60000000000C6C6C600C6C6C60084848400840000008400000084000000FFFF
      FF0000FFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000848400008484000000
      0000FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF0000000000FFFF
      FF0000000000FFFFFF00000000000000000000000000C6C6C600FFFFFF000000
      00008400000000000000C6C6C60084000000840000008400000084848400FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00000000000000
      000000000000FFFFFF00000000000000000000000000FFFFFF00000000000000
      000000000000FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000FFFFFF000000000000848400008484000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000C6C6C600FFFF
      FF0084000000C6C6C60084848400840000008400000084848400FFFFFF0000FF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000C6C6C600FFFFFF00C6C6C60000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840084848400848484008484
      84008484840000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000008484000000000000000000000000008400000000000000C6C6
      C60084000000848484000000000084848400FFFFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF0000000000000000000000000000000000FFFFFF00FFFFFF00C6C6
      C600000000000000000000000000C6C6C600FFFFFF00FFFFFF00000000000000
      000000000000FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840000FFFF0000FFFF0000FF
      FF0000FFFF0000000000000000000000000000000000FFFFFF00FFFFFF000084
      8400FFFFFF0000848400FFFFFF0000848400FFFFFF0000848400FFFFFF000084
      8400FFFFFF000084840000000000000000000000000084000000C6C6C6000000
      0000840000000000000084848400000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00848484008484840084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000848484000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484840000FFFF00848484008484
      840000FFFF0000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084840000000000000000000000000084000000C6C6C600C6C6
      C600840000008484840000FFFF000000000000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      000000000000FFFFFF0000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000084
      8400FFFFFF0000848400FFFFFF0000848400FFFFFF0000848400FFFFFF000084
      8400FFFFFF000000000000000000000000000000000084848400840000008400
      00008484840084848400848484000000000000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF000000000000000000000000000000000000FFFF008484
      84008484840000FFFF0084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF008484840000FFFF00848484008484840000FFFF0084848400FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000848484008484840084848400848484008484840000000000000000000000
      0000848484008484840084848400848484000000000000000000000000000000
      0000FFFFFF008484840084848400848484008484840084848400848484008484
      84008484840000FFFF000000000000000000000000000000000000FFFF0000FF
      FF0000FFFF0000FFFF0084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF008484840000FFFF0000FFFF0000FFFF0000FFFF0084848400FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00C6C6C600C6C6C600848484000000000000000000FFFF
      FF00848484008484840084848400848484000000000084848400848484000000
      000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000000000000000000000000000848484008484
      8400848484008484840084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00848484008484840084848400848484008484840084848400FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF000000000000000000848484008484840000000000FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF000000000000000000848484008484840000000000FFFFFF00848484008484
      840084848400848484008484840084848400FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000084848400840000008400
      00008400000084000000840000008400000084000000FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF00848484008484840000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000084848400840000008400
      00008400000084000000840000008400000084000000FFFFFF0000000000FFFF
      FF000000000000000000848484008484840000000000FFFFFF00848484008484
      840084848400848484008484840084848400FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000084848400840000008400
      00008400000084000000840000008400000084000000FFFFFF0000000000FFFF
      FF000000000000000000848484008484840000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000084848400840000008400
      00008400000084000000840000008400000084000000FFFFFF0000000000FFFF
      FF008484840084848400848484008484840000000000FFFFFF00848484008484
      840084848400848484008484840084848400FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000084848400840000008400
      00008400000084000000840000008400000084000000FFFFFF0000000000FFFF
      FF008484840084848400848484008484840000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484008484840084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00848484008484840084848400848484008484840084848400FFFF
      FF00FFFFFF000000000000000000000000000000000084848400848484008484
      840084848400848484008484840084848400848484008484840000000000FFFF
      FF00848484008484840084848400848484000000000084848400848484008484
      840084848400848484008484840084848400848484000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF000000000000000000000000000000000000FFFF0000FF
      FF0000FFFF0000FFFF0084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF008484840000FFFF0000FFFF0000FFFF0000FFFF0084848400FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      84008484840000FFFF000000000000000000000000000000000000FFFF008484
      84008484840000FFFF0084848400FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF008484840000FFFF00848484008484840000FFFF0084848400FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000000000000000000000000000000000000000
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
      000000000000000000000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600FFFFFF00000000000000000000000000000000000000
      000000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C600000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000008400000084000000840000008400
      0000840000008400000000000000FFFFFF0000FFFF00FFFFFF0000000000FFFF
      FF0000FFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF0000000000FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600FFFFFF0000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF0000000000000000000000000084000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000FFFF00FFFFFF0000FFFF000000000000FF
      FF00FFFFFF0000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000C6C6C600C6C6C60000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      00000000000000000000C6C6C600FFFFFF00C6C6C6000000840000008400FFFF
      FF00C6C6C600FFFFFF00C6C6C600000000000000000000000000FFFFFF0000FF
      FF000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000000000000000000000000084000000C6C6C600FFFFFF000000
      8400FFFFFF0000008400000084000000000000FFFF00FFFFFF0000000000FFFF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C6C6C6000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF0000000000FFFFFF00C6C6C600FFFFFF000000840000008400C6C6
      C600FFFFFF00C6C6C600FFFFFF000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF00000000000000000084000000FFFFFF00C6C6C6000000
      8400C6C6C60000008400C6C6C600FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6C6000000
      00000000000000000000000000000000000000000000FFFFFF00848484000000
      84000000840000000000C6C6C600FFFFFF00C6C6C600FFFFFF00000084000000
      8400C6C6C600FFFFFF00C6C6C600000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00000000000000000084000000C6C6C600000084000000
      8400FFFFFF00C6C6C60000008400C6C6C600C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C600C6C6C600C6C6C6000000
      00000000000000000000000000000000000000000000C6C6C600000084000000
      8400FFFFFF0000000000FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF000000
      840000008400C6C6C600FFFFFF000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000000000000000000000000
      000000000000FFFFFF00000000000000000084000000FFFFFF00C6C6C6000000
      8400C6C6C60084000000FFFFFF0084000000C6C6C600C6C6C600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C6000000000000000000000000000000000000000000FFFFFF00848484000000
      84000000840000000000C6C6C600FFFFFF000000840000008400000084000000
      840000008400FFFFFF00C6C6C600000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00000000000000000084000000C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600FFFFFF00C6C6C600C6C6C60000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C6C6C600C6C6C600C6C6C600000000000000
      00000000000000000000000000000000000000000000C6C6C600000084000000
      8400FFFFFF0000000000FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600FFFFFF000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000000000000000008400000084000000840000008400
      0000840000000000000000000000C6C6C60000000000C6C6C60000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600C6C6C6000000
      00000000000000000000000000000000000000000000FFFFFF00848484000000
      8400000084000000000084000000840000008400000084000000840000008400
      0000840000008400000084000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000000000000000000000000084000000FF00000084000000FF00
      0000FF00000000000000C6C6C60000000000C6C6C60000000000C6C6C6000000
      0000C6C6C600C6C6C60000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C6000000000000000000000000000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF000000000084000000840000008400000084000000840000008400
      000084000000840000008400000000000000000000000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000000000008400000084000000840000008400
      0000840000008400000000000000C6C6C60000000000C6C6C60000000000C6C6
      C600C6C6C600C6C6C600C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084000000840000008400
      0000840000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000000000FFFFFF0000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C60000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084000000840000008400
      0000840000008400000084000000840000008400000084000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000000000000000000000000000000000000
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
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF00FFFFFF0000000000FFFF
      FF0000FFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084000000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084000000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF008400000084000000840000008400000084000000FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF008400
      0000FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000008400000084000000840000008400
      0000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF0084000000FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00840000008400
      000084000000840000008400000084000000FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0000FFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084000000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0084000000FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000008400000084000000840000008400
      0000840000008400000000000000FFFFFF0000FFFF00FFFFFF0000000000FFFF
      FF0000FFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF0084000000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF008400
      00008400000084000000840000008400000084000000FFFFFF00FFFFFF000000
      00000000000000000000000000000000000084000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000FFFF00FFFFFF0000FFFF000000000000FF
      FF00FFFFFF0000FFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0084000000FFFFFF0084000000FFFFFF00FFFFFF00000000000000
      00000000000000000000000000000000000084000000C6C6C600FFFFFF000000
      8400FFFFFF0000008400000084000000000000FFFF00FFFFFF0000000000FFFF
      FF0000FFFF00000000000000000000000000000000000000000000000000FFFF
      FF008400000084000000840000008400000084000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF0084000000FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000000000000000
      00000000000000000000000000000000000084000000FFFFFF00C6C6C6000000
      8400C6C6C60000008400C6C6C600FFFFFF000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF008400000084000000840000008400000084000000FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000FFFFFF000000000000000000000000000000
      00000000000000000000000000008400000084000000C6C6C600000084000000
      8400FFFFFF00C6C6C60000008400C6C6C6008400000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000008400000084000000FFFFFF00C6C6C6000000
      8400C6C6C6000000840000008400FFFFFF008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000008400000084000000C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600FFFFFF00C6C6C6008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000840000008400000084000000840000008400
      0000840000008400000084000000840000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000008400000084000000FF00000084000000FF00
      0000FF000000FF00000084000000FF0000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840000008400000084000000840000008400
      0000840000008400000084000000840000008400000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000000000008484
      840084848400848484008484840084848400848484000000000000FFFF000000
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000848484008484840000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      8400848484008484840000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF0000000000000000000000000000FFFF
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF00FFFFFF00FFFFFF008400000084000000FFFFFF00FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      840084848400848484000000000000FFFF0000FFFF0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF0084000000FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF0000FFFF00008484840000000000FFFF
      0000FFFF00000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      840084848400000000000000000000FFFF0000FFFF0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF0084000000FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF000000000000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF00FFFFFF00FFFFFF008400000084848400FFFFFF00FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      840084848400848484000000000000FFFF0000FFFF0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0084000000840000008400000084000000840000008400000084000000FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF00000000
      0000FFFF0000FFFF0000FFFF0000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000FFFF00FFFFFF008484840084000000C6C6C600FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      840084848400848484000000000000FFFF0000FFFF0084848400000000000000
      000000000000848484008484840084848400000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF0084000000FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF000000000000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF00FFFFFF00FFFFFF0000FFFF0084848400840000008484840000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      840084848400848484000000000000FFFF0000FFFF0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF0084000000FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF0000FFFF00008484840000000000FFFF
      0000FFFF00000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF008400000084848400FFFFFF00FFFFFF008400000084000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      840084848400848484000000000000FFFF0000FFFF0084848400000000000000
      000000000000848484008484840084848400000000000000000000000000FFFF
      FF00FFFFFF008400000084000000840000008400000084000000840000008400
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFF0000000000000000000000000000FFFF
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF00840000008400000000FFFF00C6C6C600840000008400000000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      8400848484000000000000FFFF0000FFFF0000FFFF0000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF0084000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00C6C6C60084000000840000008400000084000000C6C6C600FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000008484
      84000000000000FFFF0000FFFF0000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF0084000000FFFFFF00FFFFFF0084000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
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
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FF000000FF000000FF00
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FF000000FF000000FF00
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000FFFF0000000000000000000000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600C6C6C600C6C6C600C6C6C60000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      0000FFFF00000000000084848400FFFF0000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF0000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF00000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600FF000000FF000000FF00000000000000FFFFFF00FF000000FF000000FF00
      0000FFFFFF000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      000000000000000000000000000000000000000000008484000000000000C6C6
      C600C6C6C600C6C6C600C6C6C60000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFF0000FFFF0000FFFF
      000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000008484000000000000C6C6
      C600FF000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      000000000000000000000000000000000000000000008484000000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FFFF00000000000084848400FFFF0000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF0000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF00000000
      000000000000000000000000000000000000000000008484000000000000C6C6
      C600FF000000FF000000FF000000C6C6C6000000000000000000000000000000
      0000000000000000000084000000000000000000000000000000000000000000
      0000FFFF0000000000000000000000000000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000000000000000
      000000000000000000000000000000000000000000008484000000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      0000000000008400000084000000840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084840000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084840000848400008484
      0000848400008484000000000000000000000000000000000000840000000000
      0000000000000000000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000840000008400000000000000000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000084848400848400008484
      8400848400008484840084840000848484008484000084848400848400008484
      8400848400008484840084840000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400848400008484
      8400848400008484840084840000848484008484000084848400848400008484
      8400848400008484840084840000000000000000000084840000000000000000
      0000000000000000000000000000848400008484840000000000000000000000
      0000000000000000000084848400000000000000000084848400848400008484
      8400848400008484840084840000848484008484000084848400848400008484
      84008484000084848400848400000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000084840000000000000000
      0000000000000000000000000000848400008484840000000000000000000000
      000000000000000000008484840000000000000000008484840000000000FFFF
      FF00FFFFFF00FFFFFF0000000000848484008484000000000000FFFFFF00FFFF
      FF00FFFFFF000000000084840000000000000000000084840000848484008484
      0000848484008484000084848400848400008484840084840000848484008484
      00008484840084840000848484000000000000000000FFFFFF00FFFFFF000000
      000000000000FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF0000000000FFFFFF00FFFFFF0000000000000000008484840000000000FFFF
      FF00FFFFFF00FFFFFF0000000000848484008484000000000000FFFFFF00FFFF
      FF00FFFFFF000000000084840000000000000000000084840000000000000000
      000000000000FFFFFF0000000000848400008484840000000000000000000000
      0000FFFFFF000000000084848400000000000000000084848400000000000000
      0000000000008484840000000000000000000000000084840000000000000000
      00000000000084848400848400000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000000000008484000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000848400008484840000000000FFFFFF000000
      000000000000000000008484840000000000000000008484840000000000FFFF
      FF00FFFFFF00FFFFFF0000000000848484008484000000000000FFFFFF00FFFF
      FF00FFFFFF00000000008484000000000000000000008484000000000000FFFF
      FF00000000008484000000000000FFFFFF00000000008484840000000000FFFF
      FF000000000084840000848484000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000084848400000000000000
      000000000000FFFFFF0000000000848484008484000000000000FFFFFF00FFFF
      FF00FFFFFF000000000084840000000000000000000084840000000000000000
      0000000000000000000000000000848400008484840000000000000000000000
      000000000000000000008484840000000000000000008484840000000000FFFF
      FF00000000008484840000000000FFFFFF00000000008484000000000000FFFF
      FF000000000084848400848400000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000000000008484000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000848400008484840000000000000000000000
      0000FFFFFF000000000084848400000000000000000084848400848400008484
      8400848400008484840084840000848484008484000084848400848400008484
      8400848400008484840084840000000000000000000084840000000000000000
      0000000000008484000000000000000000000000000084840000000000000000
      00000000000084840000848484000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000000000008484840000000000FFFF
      FF00000000000000000000000000848484008484000000000000FFFFFF00FFFF
      FF00FFFFFF000000000084840000000000000000000084840000848484008484
      0000848484008484000084848400848400008484840084840000848484008484
      0000848484008484000084848400000000000000000084848400848400008484
      8400848400008484840084840000848484008484000084848400848400008484
      84008484000084848400848400000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF0000000000000000008484000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000848400008484840000000000FFFFFF000000
      0000FFFFFF000000000084848400000000000000000084848400000000000000
      0000000000000000000000000000848484008484000000000000000000000000
      0000000000000000000084840000000000000000000084840000000000000000
      0000000000008484000000000000000000000000000084840000000000000000
      0000000000008484000084848400000000008484840000000000FF000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FF0000000000000084848400000000008484840000000000FFFF
      FF0000000000FFFFFF0000000000848484008484000000000000FFFFFF00FFFF
      FF00FFFFFF00000000008484000000000000000000008484000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000848400008484840000000000FFFFFF00FFFF
      FF00FFFFFF00000000008484840000000000000000008484840000000000FFFF
      FF00000000008484840000000000FFFFFF00000000008484840000000000FFFF
      FF000000000084848400848400000000000000000000FF000000FF0000000000
      0000FFFFFF00FF000000000000000000000000000000FFFFFF00FF000000FFFF
      FF0000000000FF000000FF00000000000000000000008484000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000848400008484840000000000FFFFFF00FFFF
      FF00FFFFFF000000000084848400000000000000000084848400000000000000
      000000000000FFFFFF0000000000848484008484000000000000000000000000
      0000FFFFFF00000000008484000000000000000000008484000000000000FFFF
      FF00000000008484000000000000FFFFFF00000000008484000000000000FFFF
      FF00000000008484000084848400000000008484840000000000FF000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FF00000000000000848484000000000084848400000000000000
      0000000000000000000000000000848484008484000000000000000000000000
      000000000000000000008484000000000000000000008484000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000848400008484840000000000FFFFFF00FFFF
      FF00FFFFFF000000000084848400000000000000000084848400000000000000
      0000000000008484840000000000000000000000000084848400000000000000
      00000000000084848400848400000000000000000000FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000084840000848484008484
      0000848484008484000084848400848400008484840084840000848484008484
      0000848484008484000084848400000000000000000084848400000000000000
      0000000000000000000000000000848484008484000000000000000000000000
      0000000000000000000084840000000000000000000084840000848484008484
      0000848484008484000084848400848400008484840084840000848484008484
      00008484840084840000848484000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084840000848484008484
      0000848484008484000084848400848400008484840084840000848484008484
      0000848484008484000084848400000000000000000000000000000000000000
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
      000000000000000000000000000000000000000000000000000084848400FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FF
      FF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000084848400848400008484
      8400848400008484840084840000848484008484000084848400848400008484
      840084840000848484008484000000000000000000000000000084848400FFFF
      FF000000000000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFF
      FF00FFFFFF0000FFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000084840000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484008484000084848400000000000000000000000000848484000000
      00008484840000000000FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FF
      FF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00000000000000000084848400848400000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000008484840084840000000000000000000000000000000000008484
      8400848484008484840000000000FFFFFF00FFFFFF0000FFFF0084848400FFFF
      FF00FFFFFF0000FFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000084840000848484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000008484000084848400000000000000000000000000C6C6C600C6C6
      C600C6C6C600848484008484840000000000FFFFFF00FFFFFF00840000008484
      8400FFFFFF00FFFFFF00000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000084848400848400000000
      0000FFFFFF00840000008400000084000000840000008400000084000000FFFF
      FF000000000084848400848400000000000000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C60084848400848484000000000000FFFF00840000008400
      0000FFFFFF0000FFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000084840000848484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000848400008484840000000000C6C6C600FFFFFF00FFFFFF00C6C6
      C600C6C6C600C6C6C600C6C6C600848484008484840084000000840000008400
      0000FFFFFF00FFFFFF00000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000000000FFFFFF00FFFFFF000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF00FFFFFF00000000000000000084848400848400000000
      0000FFFFFF0084000000840000008400000084000000FFFFFF00FFFFFF00FFFF
      FF000000000084848400848400000000000000000000C6C6C600FFFFFF00FFFF
      FF00C6C6C60000000000C6C6C600C6C6C6008484840084000000840000008400
      0000FFFFFF0000FFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF0000000000FF00
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FF00000000000000FFFFFF00000000000000000084840000848484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000008484000084848400000000000000000000000000C6C6C600FFFF
      FF00000000008400000000000000C6C6C6008400000084000000840000008484
      8400FFFFFF00FFFFFF00000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000000000000FF000000FF00
      000000000000FFFFFF0000000000FF000000FF00000000000000FFFFFF000000
      0000FF000000FF00000000000000000000000000000084848400848400000000
      0000FFFFFF00840000008400000084000000840000008400000084000000FFFF
      FF0000000000848484008484000000000000000000000000000000000000C6C6
      C600FFFFFF0084000000C6C6C60084848400840000008400000084848400FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF0000000000FF00
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FF00000000000000FFFFFF00000000000000000084840000848484000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000008484000084848400000000000000000000000000840000000000
      0000C6C6C60084000000848484000000000084848400FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF000000000000000000FFFFFF00FFFFFF000000
      0000FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF00FFFFFF00000000000000000084848400848400000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000848484008484000000000000000000000000000084000000C6C6
      C60000000000840000000000000084848400FFFFFF0000FFFF00FFFFFF008484
      8400C6C6C60000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000084840000848484008484
      0000848484008484000084848400848400008484840084840000848484008484
      000084848400848400008484840000000000000000000000000084000000C6C6
      C600C6C6C600840000008484840000FFFF00FFFFFF00FFFFFF00FFFFFF008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008400
      0000840000008484840084848400848484008484840084848400848484008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400000000008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C6000000000000000000000000000000000000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C6000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484000000
      00000000000000000000C6C6C600C6C6C600C6C6C60000000000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6C6C60000000000000000000000000000000000000000000000
      000000000000FFFFFF008484840000000000FFFFFF0000000000000000000000
      000000000000000000000000000000000000000000008484840000000000C6C6
      C600848484000000000000000000C6C6C600C6C6C6000000000084848400C6C6
      C6000000000000000000848484000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60000FFFF0000FFFF0000FFFF00C6C6C600C6C6
      C6000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60000FFFF0000FFFF0000FFFF00C6C6C600C6C6
      C600000000000000000000000000000000000000000084848400FFFFFF00FFFF
      FF00FFFFFF00848484008484840000000000FFFFFF00FFFFFF00848484008484
      840084848400848484000000000000000000000000000000000084848400C6C6
      C60084848400C6C6C600C6C6C6008484840000000000C6C6C600848484008484
      84008484840084848400000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600848484008484840084848400C6C6C600C6C6
      C60000000000C6C6C600000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600848484008484840084848400C6C6C600C6C6
      C60000000000C6C6C60000000000000000000000000084848400FFFFFF008484
      840084848400848484008484840000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008484840000000000000000000000000000000000000000000000
      0000C6C6C600C6C6C60000000000FFFFFF00FFFFFF0000000000C6C6C6000000
      0000000000000000000000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6C6C600C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6C6C600C6C6C600000000000000000084848400FFFFFF008484
      840084848400848484008484840000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008484840000000000000000008484840000000000C6C6C6000000
      0000C6C6C60000000000C6C6C600C6C6C600C6C6C600FFFFFF00848484000000
      0000C6C6C600C6C6C600000000008484840000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C60000000000C6C6C6000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C60000000000C6C6C600000000000000000084848400FFFFFF008484
      840084848400848484008484840000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008484840000000000000000008484840000000000C6C6C600C6C6
      C600FFFFFF00000000008484840000000000C6C6C600FFFFFF0084848400C6C6
      C600C6C6C600C6C6C60000000000848484000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60000000000C6C6C60000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60000000000C6C6C60000000000000000000000000084848400FFFFFF008484
      840084848400848484008484840000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008484840000000000000000008484840000000000000000000000
      0000FFFFFF00000000008484840084848400C6C6C60000000000C6C6C6000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000C6C6C60000000000C6C6C60000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000C6C6C60000000000C6C6C600848484000000000084848400FFFFFF008484
      840084848400848484008484840000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008484840000000000000000000000000000000000000000000000
      0000C6C6C600FFFFFF00000000000000000000000000C6C6C600C6C6C6000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008484
      0000FFFF0000FFFF0000FFFF0000000000000000000084848400FFFFFF008484
      840084848400848484008484840000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00848484000000000000000000000000000000000084848400C6C6
      C60084848400C6C6C600FFFFFF00FFFFFF00C6C6C600C6C6C600848484008484
      8400848484000000000084848400000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000084848400000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000848400000000000000000000848484000000000084848400FFFFFF008484
      840084848400848484008484840000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00848484000000000000000000000000008484840000000000C6C6
      C600848484000000000000000000C6C6C6000000000000000000C6C6C600C6C6
      C600000000008484840000000000000000000000000000000000000000000000
      000000000000FFFFFF000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000FFFF00008484
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000000000000000000000000000000000000000000084848400FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000848484000000
      00008484840000000000C6C6C600C6C6C600C6C6C60000000000848484000000
      0000848484000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000084848400000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000848400000000000000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400000000000000000000000000000000000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00848484008484
      0000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400000000000000000000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000E00000000100010000000000000700000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFF18000000000008000800000000000
      0000800000000000000080000000000000008000000000000000800000000000
      0000800000000000000080000000000000008000000000000000800000000000
      0000800000000000000080000000000000018000000000008007800000000000
      C007800000000000E007FFFF00000000FFFFE001FFFFFFFFFFFFC001000F8000
      8003C001000F80008003C001000F80008003C001000F80008003C001000F8000
      8003C001000F80008003C001000F80008003C001000F80008003C00100048000
      8003C00100008000C1FEC00100008001E3FEC001F800C07FFFF5C001FC00E0FF
      FFF3C003FE04FFFFFFF1FFFFFFFFFFFFFFFFFFFFC001FFFF00010001C001FFFF
      00010001C001001F00010001C001000F00010001C001000700010001C0010003
      00010001C001000100000001C001000000000001C001001F00010001C001001F
      00000001C001001F00000003C0018FF1808180FFC001FFF9C124C1FFC003FF75
      FE66FFFFC007FF8FFFE7FFFFC00FFFFFC001FFFFFFFFFFFFC001C003C001FFFF
      C001C0038031FFF9C001C0038031E7FFC001C0038031C3F3C001C0038001C3E7
      C001C0038001E1C7C001C0038001F08FC001C0038FF1F81FC001C0038FF1FC3F
      C001C0038FF1F81FC001C0038FF1F09FC003C0038FF1C1C7C007C0078FF183E3
      C00FC00F80018FF1FFFFC01FFFFFFFFFFFFFFFFFFE0080008003FFFF80000000
      8003FF81800000008003FF00800000008003FE00800300008003FE0000030000
      8003FC80000300008003FA000003000080038000000300008003000100030000
      8003000180030000800300018003000080030001800000008003000180000000
      8003000580000000FFFF8003FE0000018001FFFFFFFFFFFF8001E00180038003
      DFFBE00180038003F070000180038003E060000180038003802C000180038003
      000C003F800380030000003F80038003000C003F800380030000003F80038003
      0000003F80038003000000018003800300000001800380030000000180038003
      FFFFE00180038003FFFFE001FFFFFFFFFFFFFFFFFC01FFFFF800F83FFC01FFFF
      F800E00F8001F7DF0000C0070001F63F000080030001F83F000080030003FC1F
      000000010007F80F00000001003FF00F00000001000FF00700000001000FF00F
      000000010003F00F000080030001F007000080030000F8070000C007FE00FC1F
      001FE00FFE00FFFF001FF83FFF80FFFFFFFFFFFFFFFFFFFFC003C003000FFF07
      C003C003000FFE03C003C003140FFC01C003C003000FFC01C003C003000F8001
      C003C003000F0001C003C003000F0001C003C003000F0003C003C003052F0007
      C003C0030052003FC003C00302AC003FC003C003815E003FE003E003C0BE003F
      F003F003E07C003FF803F803FF82007FFFFFFFEFFDFFFFFFFFFFFFCFF9FFFFFF
      FFFFE007F1FFC003FDDFC003E1FFC003FCCF80030007C003FC478003C03FC003
      00038003C037C00300018003C027C00300008003C000C00300018003C000C003
      00038003C000C003FC478003C027C003FCCF8003C037C003FDDF8003C03FE003
      FFFF8003C03FF003FFFFC007FFFFF803FFFFFFFFFFFFFFFFFE03FFFFFFFFFFFF
      FE03FFFFFFFFFFFFFE03FBBFFEFFFF7FFE03F33FFCFFFF3FC003E23FF8FFFF1F
      C003C000F003C00F00038000E003C00700030000C003C00300038000E003C007
      007FC000F003C00F007DE23FF8FFFF1F0078F33FFCFFFF3F007DFBBFFEFFFF7F
      01DDFFFFFFFFFFFF01E3FFFFFFFFFFFFFFFF8001FFFFFFFF8001000080018081
      0000000000000080000000000000008000000000000000800000000000000100
      0000000000000100000000000000018000000000000000800000000000000000
      0000000000000100000000000000018000000000000000800000000000000080
      8001000080018081FFFF8001FFFFFFFFFFFFFFFFFFFFFFFFC001800180018001
      C001000000000000C001000000000000C001000000000000C001000000000000
      8001000000000000000100000000000000010000000000000001000000000000
      8001000000000000C001000000000000C001000000000000C003000000000000
      C007800180018001C00FFFFFFFFFFFFFFC7FFFFFFFFFFFFFFC27C007C007FFFF
      EC2380038003F83FC4010001000100018001000100010001C003000100010001
      E000000000000001000000000000000100008000800000010003C000C0000001
      E001E001E0000001C001E007800000018003F00780070101C407F00380008383
      EC3FF803F000FFFFFC7FFFFFF800FFFF00000000000000000000000000000000
      000000000000}
  end
  object pmPreview: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Item = bbFileDesign
        Visible = True
      end
      item
        BeginGroup = True
        Item = bbFilePageSetup
        Visible = True
      end
      item
        BeginGroup = True
        Item = bbFormatShrinkToPageWidth
        Visible = True
      end
      item
        BeginGroup = True
        Item = cbxPredefinedZoom
        Visible = True
      end
      item
        Item = bbZoomWholePage
        Visible = True
      end
      item
        BeginGroup = True
        Item = bbGoToFirstPage
        Visible = True
      end
      item
        Item = bbGoToPrevPage
        Visible = True
      end
      item
        BeginGroup = True
        Item = seActivePage
        Visible = True
      end
      item
        BeginGroup = True
        Item = bbGoToNextPage
        Visible = True
      end
      item
        Item = bbGoToLastPage
        Visible = True
      end>
    UseOwnFont = False
    Left = 91
    Top = 197
  end
  object MainMenu1: TMainMenu
    Left = 7
    Top = 197
  end
  object pmPrintStyles: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Item = bliPrintStyles
        Visible = True
      end
      item
        BeginGroup = True
        Item = bbDefinePrintStyles
        Visible = True
      end>
    UseOwnFont = False
    Left = 119
    Top = 197
  end
  object TimerHint: TTimer
    Enabled = False
    OnTimer = TimerHintTimer
    Left = 8
    Top = 246
  end
  object pmExplorer: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Item = bbFileLoad
        Visible = True
      end
      item
        Item = bbFileClose
        Visible = True
      end
      item
        BeginGroup = True
        Item = bbExplorerCreateNewFolder
        Visible = True
      end
      item
        BeginGroup = True
        Item = bbExplorerDelete
        Visible = True
      end
      item
        Item = bbExplorerRename
        Visible = True
      end
      item
        BeginGroup = True
        Item = bbExplorerProperties
        Visible = True
      end>
    UseOwnFont = False
    OnPopup = pmExplorerPopup
    Left = 147
    Top = 197
  end
  object pmThumbnails: TdxBarPopupMenu
    BarManager = dxBarManager
    ItemLinks = <
      item
        Item = bbThumbnailsSmall
        Visible = True
      end
      item
        Item = bbThumbnailsLarge
        Visible = True
      end>
    UseOwnFont = False
    Left = 175
    Top = 197
  end
end
