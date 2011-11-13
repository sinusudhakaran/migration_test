object fmeClientLookup: TfmeClientLookup
  Left = 0
  Top = 0
  Width = 317
  Height = 175
  TabOrder = 0
  TabStop = True
  object vtClients: TVirtualStringTree
    Left = 0
    Top = 0
    Width = 317
    Height = 175
    Align = alClient
    BevelInner = bvNone
    ButtonStyle = bsTriangle
    Color = clWhite
    DefaultNodeHeight = 20
    DefaultPasteMode = amNoWhere
    Header.AutoSizeIndex = -1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Height = 18
    Header.Options = [hoColumnResize, hoDblClickResize, hoDrag, hoHotTrack, hoOwnerDraw, hoShowSortGlyphs, hoVisible]
    Header.ParentFont = True
    Header.Style = hsXPStyle
    HintMode = hmHint
    IncrementalSearchStart = ssLastHit
    IncrementalSearchTimeout = 2000
    LineMode = lmBands
    LineStyle = lsSolid
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    TreeOptions.MiscOptions = [toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
    TreeOptions.PaintOptions = [toHideFocusRect, toShowBackground, toShowRoot, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toMultiSelect, toRightClickSelect, toCenterScrollIntoView]
    TreeOptions.StringOptions = [toSaveCaptions]
    OnAfterCellPaint = vtClientsAfterCellPaint
    OnBeforeCellPaint = vtClientsBeforeCellPaint
    OnBeforeItemPaint = vtClientsBeforeItemPaint
    OnChange = vtClientsChange
    OnCollapsing = vtClientsCollapsing
    OnCompareNodes = vtClientsCompareNodes
    OnGetText = vtClientsGetText
    OnPaintText = vtClientsPaintText
    OnGetHint = vtClientsGetHint
    OnHeaderClick = vtClientsHeaderClick
    OnHeaderDraw = vtClientsHeaderDraw
    OnIncrementalSearch = vtClientsIncrementalSearch
    OnKeyDown = vtClientsKeyDown
    OnKeyPress = vtClientsKeyPress
    OnKeyUp = vtClientsKeyUp
    OnMouseUp = vtClientsMouseUp
    OnScroll = vtClientsScroll
    OnShortenString = vtClientsShortenString
    Columns = <
      item
        Position = 0
        WideText = 'So we can see'
      end>
  end
  object BtnLeft: TButton
    Left = 208
    Top = 40
    Width = 75
    Height = 25
    Caption = '<'
    TabOrder = 1
    Visible = False
    OnClick = BtnLeftClick
  end
  object BtnRight: TButton
    Left = 208
    Top = 71
    Width = 75
    Height = 25
    HelpType = htKeyword
    HelpKeyword = '>'
    Caption = '>'
    TabOrder = 2
    Visible = False
    OnClick = BtnRightClick
  end
  object popDelete: TPopupMenu
    OnPopup = popDeletePopup
    Left = 56
    Top = 48
    object mniDelete: TMenuItem
      Caption = 'Delete Client File'
      OnClick = mniDeleteClick
    end
  end
end
