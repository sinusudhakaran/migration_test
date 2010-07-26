inherited cxChartViewEditor: TcxChartViewEditor
  Left = 543
  Top = 157
  Caption = 'cxChartViewEditor'
  ClientHeight = 291
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited PViewEditor: TPanel
    Height = 291
    Constraints.MinHeight = 210
    Constraints.MinWidth = 200
    object tcMain: TcxTabControl
      Left = 0
      Top = 0
      Width = 343
      Height = 291
      Align = alClient
      TabOrder = 0
      Tabs.Strings = (
        '  Series  '
        '  DataGroups  ')
      OnChange = tcMainChange
      OnChanging = tcMainChanging
      ClientRectBottom = 291
      ClientRectRight = 343
      ClientRectTop = 24
      object Panel1: TPanel
        Left = 0
        Top = 24
        Width = 343
        Height = 267
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 8
        TabOrder = 0
        object Panel2: TPanel
          Left = 217
          Top = 8
          Width = 118
          Height = 251
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 1
          object btnItemAdd: TcxButton
            Left = 8
            Top = 0
            Width = 110
            Height = 24
            Caption = '&Add'
            TabOrder = 0
            OnClick = btnItemAddClick
          end
          object btnItemDelete: TcxButton
            Left = 8
            Top = 32
            Width = 110
            Height = 24
            Caption = 'Delete'
            TabOrder = 1
            OnClick = btnItemDeleteClick
          end
          object btnItemMoveUp: TcxButton
            Left = 8
            Top = 72
            Width = 110
            Height = 24
            Caption = 'Move &Up'
            TabOrder = 2
            OnClick = btnItemMoveUpClick
          end
          object btnItemMoveDown: TcxButton
            Left = 8
            Top = 104
            Width = 110
            Height = 24
            Caption = 'Move &Down'
            TabOrder = 3
            OnClick = btnItemMoveDownClick
          end
          object btnItemSelectAll: TcxButton
            Left = 8
            Top = 144
            Width = 110
            Height = 24
            Caption = 'Select All'
            TabOrder = 4
            OnClick = btnItemSelectAllClick
          end
        end
        object Panel9: TPanel
          Left = 8
          Top = 8
          Width = 209
          Height = 251
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 1
          Color = clBtnShadow
          TabOrder = 0
          object lbItems: TListBox
            Left = 1
            Top = 1
            Width = 207
            Height = 249
            Style = lbOwnerDrawFixed
            Align = alClient
            BorderStyle = bsNone
            DragMode = dmAutomatic
            ItemHeight = 13
            MultiSelect = True
            PopupMenu = pmItems
            TabOrder = 0
            OnClick = lbItemsClick
            OnDragDrop = lbItemsDragDrop
            OnDragOver = lbItemsDragOver
            OnDrawItem = lbItemsDrawItem
            OnEndDrag = lbItemsEndDrag
            OnKeyPress = FormKeyPress
            OnStartDrag = lbItemsStartDrag
          end
        end
      end
    end
  end
  object pmItems: TPopupMenu
    Left = 140
    Top = 74
    object miItemAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = btnItemAddClick
    end
    object miItemDelete: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = btnItemDeleteClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miItemMoveUp: TMenuItem
      Caption = 'Move Up'
      ShortCut = 16422
      OnClick = btnItemMoveUpClick
    end
    object miItemMoveDown: TMenuItem
      Caption = 'Move Down'
      ShortCut = 16424
      OnClick = btnItemMoveDownClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miItemSelectAll: TMenuItem
      Caption = '&Select All'
      ShortCut = 16449
      OnClick = btnItemSelectAllClick
    end
  end
  object pmItemsAdd: TPopupMenu
    Left = 140
    Top = 112
  end
end
