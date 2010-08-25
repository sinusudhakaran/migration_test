inherited cxBandedTableViewEditor: TcxBandedTableViewEditor
  Left = 477
  Caption = 'cxBandedTableViewEditor'
  PixelsPerInch = 96
  TextHeight = 13
  inherited PViewEditor: TPanel
    inherited PageControl1: TcxPageControl
      ActivePage = TSBands
      object TSBands: TcxTabSheet [0]
        BorderWidth = 8
        Caption = '   Bands   '
        object Panel22: TPanel
          Left = 209
          Top = 0
          Width = 118
          Height = 273
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 1
          object BAddBand: TcxButton
            Left = 8
            Top = 0
            Width = 110
            Height = 24
            Caption = '&Add'
            TabOrder = 0
            OnClick = BAddBandClick
          end
          object BDeleteBand: TcxButton
            Left = 8
            Top = 32
            Width = 110
            Height = 24
            Caption = 'Delete'
            TabOrder = 1
            OnClick = BDeleteBandClick
          end
          object BBandMoveDown: TcxButton
            Left = 8
            Top = 104
            Width = 110
            Height = 24
            Caption = 'Move &Down'
            TabOrder = 2
            OnClick = BBandMoveDownClick
          end
          object BBandMoveUp: TcxButton
            Left = 8
            Top = 72
            Width = 110
            Height = 24
            Caption = 'Move &Up'
            TabOrder = 3
            OnClick = BBandMoveUpClick
          end
        end
        object Panel20: TPanel
          Left = 0
          Top = 0
          Width = 209
          Height = 273
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 1
          Color = clBtnShadow
          TabOrder = 0
          object LBBands: TListBox
            Left = 1
            Top = 1
            Width = 207
            Height = 271
            Style = lbOwnerDrawFixed
            Align = alClient
            BorderStyle = bsNone
            DragMode = dmAutomatic
            ItemHeight = 16
            MultiSelect = True
            PopupMenu = PMBands
            TabOrder = 0
            OnClick = LBBandsClick
            OnDragDrop = LBBandsDragDrop
            OnDragOver = LBBandsDragOver
            OnDrawItem = LBBandsDrawItem
            OnEndDrag = LBBandsEndDrag
            OnKeyPress = FormKeyPress
            OnStartDrag = LBBandsStartDrag
          end
        end
      end
    end
  end
  object PMBands: TPopupMenu
    Left = 230
    Top = 90
    object MIBandsAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = BAddBandClick
    end
    object MIBandsDelete: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = BDeleteBandClick
    end
    object MenuItem4: TMenuItem
      Caption = '-'
    end
    object MIBandsMoveUp: TMenuItem
      Caption = 'Move Up'
      ShortCut = 16422
      OnClick = BBandMoveUpClick
    end
    object MIBandsMoveDown: TMenuItem
      Caption = 'Move Down'
      ShortCut = 16424
      OnClick = BBandMoveDownClick
    end
    object MenuItem7: TMenuItem
      Caption = '-'
    end
    object MIBandsSelectAll: TMenuItem
      Caption = '&Select All'
      ShortCut = 16449
      OnClick = MIBandsSelectAllClick
    end
  end
end
