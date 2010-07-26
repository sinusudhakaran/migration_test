object cxTreeListBandColumnDesigner: TcxTreeListBandColumnDesigner
  Left = 480
  Top = 171
  Width = 386
  Height = 317
  HorzScrollBar.Range = 5
  VertScrollBar.Range = 42
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'TreeListDesigner'
  Color = clBtnFace
  Constraints.MinHeight = 281
  Constraints.MinWidth = 361
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 0
    Height = 283
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 378
    Height = 283
    ActivePage = tsColumns
    Align = alClient
    TabOrder = 1
    OnChange = PageControlChange
    object tsBands: TTabSheet
      Caption = '  Bands  '
      object Panel12: TPanel
        Left = 257
        Top = 0
        Width = 113
        Height = 246
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnBAdd: TcxButton
          Left = 5
          Top = 8
          Width = 105
          Height = 22
          Caption = '&Add'
          TabOrder = 0
          OnClick = BandTabButtonsClick
        end
        object btnBDel: TcxButton
          Tag = 1
          Left = 5
          Top = 40
          Width = 105
          Height = 22
          Caption = '&Delete'
          TabOrder = 1
          OnClick = BandTabButtonsClick
        end
        object btnBMoveU: TcxButton
          Tag = 2
          Left = 5
          Top = 72
          Width = 105
          Height = 22
          Caption = 'Move &Up '
          TabOrder = 2
          OnClick = BandTabButtonsClick
        end
        object btnBMoveD: TcxButton
          Tag = 3
          Left = 5
          Top = 104
          Width = 105
          Height = 22
          Caption = 'Move Dow&n'
          TabOrder = 3
          OnClick = BandTabButtonsClick
        end
        object btnBResD: TcxButton
          Tag = 4
          Left = 5
          Top = 136
          Width = 105
          Height = 22
          Caption = 'Rest&ore Defaults'
          TabOrder = 4
          OnClick = BandTabButtonsClick
        end
        object btnBResW: TcxButton
          Tag = 5
          Left = 5
          Top = 168
          Width = 105
          Height = 22
          Caption = 'Restore &Widths'
          TabOrder = 5
          OnClick = BandTabButtonsClick
        end
      end
      object lbxBands: TListBox
        Left = 0
        Top = 0
        Width = 257
        Height = 246
        Align = alClient
        DragMode = dmAutomatic
        ItemHeight = 16
        MultiSelect = True
        PopupMenu = pmBands
        TabOrder = 1
        OnClick = BandsListClick
        OnKeyDown = lbxKeyDown
      end
    end
    object tsColumns: TTabSheet
      Caption = '  Columns  '
      object pnButtons: TPanel
        Left = 257
        Top = 0
        Width = 113
        Height = 255
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        object btnCAdd: TcxButton
          Left = 5
          Top = 8
          Width = 105
          Height = 22
          Caption = '&Add'
          TabOrder = 0
          OnClick = ColumnsEventHandle
        end
        object btnCDel: TcxButton
          Tag = 1
          Left = 5
          Top = 40
          Width = 105
          Height = 22
          Caption = '&Delete'
          TabOrder = 1
          OnClick = ColumnsEventHandle
        end
        object btnCMoveU: TcxButton
          Tag = 2
          Left = 5
          Top = 72
          Width = 105
          Height = 22
          Caption = 'Move &Up '
          TabOrder = 2
          OnClick = ColumnsEventHandle
        end
        object btnCMoveD: TcxButton
          Tag = 3
          Left = 5
          Top = 104
          Width = 105
          Height = 22
          Caption = 'Move Dow&n'
          TabOrder = 3
          OnClick = ColumnsEventHandle
        end
        object btnCResD: TcxButton
          Tag = 4
          Left = 5
          Top = 136
          Width = 105
          Height = 22
          Caption = 'Rest&ore Defaults'
          TabOrder = 4
          OnClick = ColumnsEventHandle
        end
        object btnCResW: TcxButton
          Tag = 5
          Left = 5
          Top = 168
          Width = 105
          Height = 22
          Caption = 'Restore &Widths'
          TabOrder = 5
          OnClick = ColumnsEventHandle
        end
        object btnCreateAllFields: TcxButton
          Tag = 6
          Left = 5
          Top = 200
          Width = 105
          Height = 22
          Caption = 'Create all &fields'
          TabOrder = 6
          OnClick = ColumnsEventHandle
        end
      end
      object lbxColumns: TListBox
        Left = 0
        Top = 0
        Width = 257
        Height = 255
        Align = alClient
        DragMode = dmAutomatic
        ItemHeight = 13
        MultiSelect = True
        PopupMenu = pmColumns
        TabOrder = 1
        OnClick = ColumnsListClick
        OnKeyDown = lbxKeyDown
      end
    end
  end
  object pmColumns: TPopupMenu
    Left = 228
    Top = 6
    object mnuCAdd: TMenuItem
      Caption = '&Add...'
      ShortCut = 45
      OnClick = ColumnsEventHandle
    end
    object mnuCDel: TMenuItem
      Tag = 1
      Caption = '&Delete'
      ShortCut = 46
      OnClick = ColumnsEventHandle
    end
    object mnuCMoveU: TMenuItem
      Tag = 2
      Caption = 'Move &Up'
      OnClick = ColumnsEventHandle
    end
    object mnuCMoveD: TMenuItem
      Tag = 3
      Caption = 'Move Dow&n'
      OnClick = ColumnsEventHandle
    end
    object mnuCResD: TMenuItem
      Tag = 4
      Caption = 'Rest&ore Defaults'
      OnClick = ColumnsEventHandle
    end
    object mnuCResW: TMenuItem
      Tag = 5
      Caption = 'Restore &Widths'
      OnClick = ColumnsEventHandle
    end
    object mnuCreateAllFields: TMenuItem
      Tag = 6
      Caption = 'Create all fields'
      OnClick = ColumnsEventHandle
    end
    object mnuCSelectAll: TMenuItem
      Tag = 8
      Caption = 'Select All'
      ShortCut = 16449
      OnClick = ColumnsEventHandle
    end
  end
  object pmBands: TPopupMenu
    Left = 194
    Top = 6
    object mnuBAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = BandTabButtonsClick
    end
    object mnuBDel: TMenuItem
      Tag = 1
      Caption = '&Delete'
      ShortCut = 46
      OnClick = BandTabButtonsClick
    end
    object mnuBMoveU: TMenuItem
      Tag = 2
      Caption = 'Move &Up'
      OnClick = BandTabButtonsClick
    end
    object mnuBMoveD: TMenuItem
      Tag = 3
      Caption = 'Move Dow&n'
      OnClick = BandTabButtonsClick
    end
    object mnuBResD: TMenuItem
      Tag = 4
      Caption = 'Rest&ore Defaults'
      OnClick = BandTabButtonsClick
    end
    object mnuBResW: TMenuItem
      Caption = 'Restore &Width'
    end
    object mnuBSelectAll: TMenuItem
      Tag = 8
      Caption = 'Select All'
      ShortCut = 16449
      OnClick = BandTabButtonsClick
    end
  end
end
