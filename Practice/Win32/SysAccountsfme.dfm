object fmeSysAccounts: TfmeSysAccounts
  AlignWithMargins = True
  Left = 0
  Top = 0
  Width = 795
  Height = 240
  Margins.Left = 0
  Margins.Bottom = 0
  TabOrder = 0
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 795
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      AlignWithMargins = True
      Left = 356
      Top = 1
      Width = 33
      Height = 24
      Margins.Left = 9
      Margins.Top = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'Search'
      Layout = tlCenter
      ExplicitHeight = 13
    end
    object lblCount: TLabel
      AlignWithMargins = True
      Left = 567
      Top = 1
      Width = 121
      Height = 24
      Margins.Top = 0
      Margins.Bottom = 0
      Align = alLeft
      AutoSize = False
      Caption = '99999 accounts Listed'
      Layout = tlCenter
      ExplicitLeft = 560
      ExplicitHeight = 23
    end
    object Shape1: TShape
      Left = 794
      Top = 1
      Width = 1
      Height = 24
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 793
      ExplicitHeight = 72
    end
    object Shape3: TShape
      Left = 0
      Top = 0
      Width = 795
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object pnlFilter: TPanel
      Left = 0
      Top = 1
      Width = 135
      Height = 24
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object Shape2: TShape
        Left = 0
        Top = 0
        Width = 1
        Height = 24
        Align = alLeft
        Pen.Color = clSilver
        ExplicitHeight = 72
      end
      object cbFilter: TComboBox
        Left = 2
        Top = 1
        Width = 128
        Height = 21
        BevelInner = bvNone
        BevelOuter = bvNone
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cbFilterChange
        Items.Strings = (
          'All'
          'Attached'
          'New'
          'Unattached'
          'Deleted'
          'Inactive'
          'Provisional')
      end
    end
    object btnFilter: TButton
      AlignWithMargins = True
      Left = 138
      Top = 1
      Width = 100
      Height = 24
      Margins.Top = 0
      Margins.Bottom = 0
      Action = actFilter
      Align = alLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      ExplicitLeft = 126
      ExplicitTop = 2
      ExplicitHeight = 21
    end
    object btnResetFilter: TButton
      AlignWithMargins = True
      Left = 244
      Top = 1
      Width = 100
      Height = 24
      Margins.Top = 0
      Margins.Bottom = 0
      Action = actReset
      Align = alLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      ExplicitLeft = 232
      ExplicitTop = 2
      ExplicitHeight = 21
    end
    object pnlFind: TPanel
      Left = 392
      Top = 1
      Width = 91
      Height = 24
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 3
      ExplicitLeft = 380
      ExplicitTop = 2
      ExplicitHeight = 21
      object EBFind: TEdit
        AlignWithMargins = True
        Left = 0
        Top = 1
        Width = 91
        Height = 21
        Margins.Top = 0
        Margins.Bottom = 0
        MaxLength = 12
        TabOrder = 0
        OnChange = EBFindChange
        OnKeyPress = EBFindKeyPress
      end
    end
    object btnSearchClear: TButton
      AlignWithMargins = True
      Left = 486
      Top = 1
      Width = 75
      Height = 24
      Margins.Top = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'Clear'
      Enabled = False
      TabOrder = 4
      OnClick = btnSearchClearClick
      ExplicitLeft = 474
      ExplicitTop = 2
      ExplicitHeight = 21
    end
  end
  object AccountTree: TVirtualStringTree
    Left = 0
    Top = 25
    Width = 795
    Height = 215
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDblClickResize, hoDrag, hoShowSortGlyphs, hoVisible]
    Header.PopupMenu = pmHeader
    Images = AppImages.States
    ParentBackground = False
    TabOrder = 1
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toMultiSelect, toRightClickSelect]
    OnBeforeItemPaint = AccountTreeBeforeItemPaint
    OnClick = AccountTreeClick
    OnGetImageIndex = AccountTreeGetImageIndex
    OnHeaderClick = AccountTreeHeaderClick
    OnHeaderDragging = AccountTreeHeaderDragging
    OnKeyDown = AccountTreeKeyDown
    OnKeyPress = AccountTreeKeyPress
    ExplicitTop = 76
    ExplicitHeight = 167
    Columns = <
      item
        Position = 0
        Tag = 1
        Width = 300
      end
      item
        Position = 1
        Tag = 2
        WideText = 'Bank account'
      end
      item
        Position = 2
        Tag = 3
        WideText = 'Name'
      end>
  end
  object pmHeader: TPopupMenu
    OnPopup = pmHeaderPopup
    Left = 24
    Top = 96
  end
  object SearchTimer: TTimer
    Enabled = False
    OnTimer = SearchTimerTimer
    Left = 600
    Top = 32
  end
  object Frameactions: TActionList
    Left = 176
    Top = 72
    object actFilter: TAction
      Caption = 'Filter Accounts'
      OnExecute = actFilterExecute
    end
    object actReset: TAction
      Caption = 'Reset Filter'
      OnExecute = actResetExecute
    end
    object actRestoreColumns: TAction
      Caption = 'Restore Default Column Layout'
      OnExecute = actRestoreColumnsExecute
    end
  end
end
