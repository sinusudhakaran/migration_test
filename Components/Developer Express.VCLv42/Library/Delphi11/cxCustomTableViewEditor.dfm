inherited cxCustomTableViewEditor: TcxCustomTableViewEditor
  Left = 556
  Top = 316
  ActiveControl = PageControl1
  Caption = 'cxCustomTableViewEditor'
  ClientHeight = 319
  ClientWidth = 344
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inherited PViewEditor: TPanel
    Width = 344
    Height = 319
    Constraints.MinHeight = 282
    Constraints.MinWidth = 344
    object PageControl1: TcxPageControl
      Left = 0
      Top = 0
      Width = 344
      Height = 319
      ActivePage = TSItems
      Align = alClient
      TabOrder = 0
      ClientRectBottom = 319
      ClientRectRight = 344
      ClientRectTop = 24
      object TSItems: TcxTabSheet
        BorderWidth = 8
        object Panel1: TPanel
          Left = 200
          Top = 0
          Width = 128
          Height = 279
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 1
          object BColumnAdd: TcxButton
            Left = 8
            Top = 0
            Width = 120
            Height = 24
            Caption = '&Add'
            TabOrder = 0
            OnClick = BColumnAddClick
          end
          object BColumnDelete: TcxButton
            Left = 8
            Top = 32
            Width = 120
            Height = 24
            Caption = 'Delete'
            TabOrder = 1
            OnClick = BColumnDeleteClick
          end
          object BColumnAddAll: TcxButton
            Left = 8
            Top = 176
            Width = 120
            Height = 24
            Caption = 'Retrieve &Fields'
            TabOrder = 5
            Visible = False
            OnClick = BColumnAddAllClick
          end
          object BColumnRestore: TcxButton
            Left = 8
            Top = 64
            Width = 120
            Height = 24
            Caption = '&Restore Defaults'
            TabOrder = 2
            OnClick = BColumnRestoreClick
          end
          object BColumnMoveUp: TcxButton
            Left = 8
            Top = 104
            Width = 120
            Height = 24
            Caption = 'Move &Up'
            TabOrder = 3
            OnClick = BColumnMoveUpClick
          end
          object BColumnMoveDown: TcxButton
            Left = 8
            Top = 136
            Width = 120
            Height = 24
            Caption = 'Move &Down'
            TabOrder = 4
            OnClick = BColumnMoveDownClick
          end
          object BColumnAddMissing: TcxButton
            Left = 8
            Top = 208
            Width = 120
            Height = 24
            Caption = 'Retrieve &Missing Fields'
            TabOrder = 6
            Visible = False
            OnClick = BColumnAddMissingClick
          end
        end
        object Panel8: TPanel
          Left = 0
          Top = 0
          Width = 200
          Height = 279
          Align = alClient
          BevelOuter = bvNone
          BorderWidth = 1
          Color = clBtnShadow
          TabOrder = 0
          object LBColumns: TListBox
            Left = 1
            Top = 1
            Width = 198
            Height = 277
            Style = lbOwnerDrawFixed
            Align = alClient
            BorderStyle = bsNone
            DragMode = dmAutomatic
            ItemHeight = 13
            MultiSelect = True
            PopupMenu = PMColumns
            TabOrder = 0
            OnClick = LBColumnsClick
            OnDragDrop = LBColumnsDragDrop
            OnDragOver = LBColumnsDragOver
            OnDrawItem = LBColumnsDrawItem
            OnEndDrag = LBColumnsEndDrag
            OnKeyPress = FormKeyPress
            OnStartDrag = LBColumnsStartDrag
          end
        end
      end
      object TSSummary: TcxTabSheet
        BorderWidth = 8
        Caption = '   Summary   '
        ImageIndex = 1
        object PageControl2: TcxPageControl
          Left = 0
          Top = 0
          Width = 328
          Height = 279
          ActivePage = TSFooterSummaryItems
          Align = alClient
          TabOrder = 0
          ClientRectBottom = 279
          ClientRectRight = 328
          ClientRectTop = 24
          object TSFooterSummaryItems: TcxTabSheet
            Caption = '   Footer   '
            object Panel2: TPanel
              Left = 0
              Top = 0
              Width = 185
              Height = 255
              Align = alLeft
              BevelOuter = bvNone
              TabOrder = 0
              object Panel3: TPanel
                Left = 0
                Top = 220
                Width = 185
                Height = 35
                Align = alBottom
                BevelOuter = bvNone
                TabOrder = 1
                object BAddFooterSummaryItem: TcxButton
                  Left = 13
                  Top = 8
                  Width = 75
                  Height = 24
                  Caption = '&Add'
                  TabOrder = 0
                  OnClick = BAddFooterSummaryItemClick
                end
                object BDeleteFooterSummaryItem: TcxButton
                  Left = 97
                  Top = 8
                  Width = 75
                  Height = 24
                  Caption = '&Delete'
                  TabOrder = 1
                  OnClick = BDeleteFooterSummaryItemClick
                end
              end
              object Panel4: TPanel
                Left = 0
                Top = 0
                Width = 185
                Height = 20
                Align = alTop
                BevelOuter = bvNone
                TabOrder = 2
                object Label1: TLabel
                  Left = 4
                  Top = 4
                  Width = 28
                  Height = 13
                  Caption = 'Items:'
                end
              end
              object Panel9: TPanel
                Left = 0
                Top = 20
                Width = 185
                Height = 200
                Align = alClient
                BevelOuter = bvNone
                BorderWidth = 1
                Color = clBtnShadow
                TabOrder = 0
                object LBFooterSummary: TListBox
                  Left = 1
                  Top = 1
                  Width = 183
                  Height = 198
                  Align = alClient
                  BorderStyle = bsNone
                  ItemHeight = 13
                  MultiSelect = True
                  PopupMenu = PMFooterSummary
                  TabOrder = 0
                  OnClick = LBFooterSummaryClick
                  OnKeyPress = FormKeyPress
                end
              end
            end
          end
          object TSDefaultGroupSummaryItems: TcxTabSheet
            Caption = '   Default For Groups   '
            ImageIndex = 1
            object Panel5: TPanel
              Left = 0
              Top = 0
              Width = 185
              Height = 255
              Align = alLeft
              BevelOuter = bvNone
              TabOrder = 0
              object Panel6: TPanel
                Left = 0
                Top = 220
                Width = 185
                Height = 35
                Align = alBottom
                BevelOuter = bvNone
                TabOrder = 1
                object BDefaultGroupSummaryAdd: TcxButton
                  Left = 13
                  Top = 8
                  Width = 75
                  Height = 24
                  Caption = '&Add'
                  TabOrder = 0
                  OnClick = BDefaultGroupSummaryAddClick
                end
                object BDefaultGroupSummaryDelete: TcxButton
                  Left = 97
                  Top = 8
                  Width = 75
                  Height = 24
                  Caption = '&Delete'
                  TabOrder = 1
                  OnClick = BDefaultGroupSummaryDeleteClick
                end
              end
              object Panel7: TPanel
                Left = 0
                Top = 0
                Width = 185
                Height = 20
                Align = alTop
                BevelOuter = bvNone
                TabOrder = 2
                object Label2: TLabel
                  Left = 4
                  Top = 4
                  Width = 28
                  Height = 13
                  Caption = 'Items:'
                end
              end
              object Panel10: TPanel
                Left = 0
                Top = 20
                Width = 185
                Height = 200
                Align = alClient
                BevelOuter = bvNone
                BorderWidth = 1
                Color = clBtnShadow
                TabOrder = 0
                object LBDefaultGroupsSummary: TListBox
                  Left = 1
                  Top = 1
                  Width = 183
                  Height = 198
                  Align = alClient
                  BorderStyle = bsNone
                  ItemHeight = 13
                  MultiSelect = True
                  PopupMenu = PMDefaultGroupsSummary
                  TabOrder = 0
                  OnClick = LBDefaultGroupsSummaryClick
                  OnKeyPress = FormKeyPress
                end
              end
            end
          end
          object TabSheet3: TcxTabSheet
            Caption = '   Groups   '
            ImageIndex = 2
            object Splitter2: TSplitter
              Left = 0
              Top = 137
              Width = 328
              Height = 5
              Cursor = crVSplit
              Align = alBottom
              Beveled = True
            end
            object PSummaryGroups: TPanel
              Left = 0
              Top = 0
              Width = 328
              Height = 137
              Align = alClient
              BevelOuter = bvNone
              Constraints.MinHeight = 100
              TabOrder = 0
              OnResize = PSummaryGroupsResize
              object PGroupItems: TPanel
                Left = 166
                Top = 0
                Width = 162
                Height = 137
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 1
                object Panel11: TPanel
                  Left = 0
                  Top = 103
                  Width = 162
                  Height = 34
                  Align = alBottom
                  BevelOuter = bvNone
                  TabOrder = 1
                  object BGroupSummaryItemAdd: TcxButton
                    Left = 4
                    Top = 6
                    Width = 75
                    Height = 24
                    Caption = '&Add'
                    TabOrder = 0
                    OnClick = BGroupSummaryItemAddClick
                  end
                  object BGroupSummaryItemDelete: TcxButton
                    Left = 83
                    Top = 6
                    Width = 75
                    Height = 24
                    Caption = '&Delete'
                    TabOrder = 1
                    OnClick = BGroupSummaryItemDeleteClick
                  end
                end
                object Panel12: TPanel
                  Left = 0
                  Top = 0
                  Width = 162
                  Height = 20
                  Align = alTop
                  BevelOuter = bvNone
                  TabOrder = 2
                  object Label4: TLabel
                    Left = 4
                    Top = 4
                    Width = 28
                    Height = 13
                    Caption = 'Items:'
                  end
                end
                object Panel16: TPanel
                  Left = 0
                  Top = 20
                  Width = 162
                  Height = 83
                  Align = alClient
                  BevelOuter = bvNone
                  BorderWidth = 1
                  Color = clBtnShadow
                  TabOrder = 0
                  object LBGroupSummaryItems: TListBox
                    Left = 1
                    Top = 1
                    Width = 160
                    Height = 81
                    Align = alClient
                    BorderStyle = bsNone
                    ItemHeight = 13
                    MultiSelect = True
                    PopupMenu = PMGroupSummaryItems
                    TabOrder = 0
                    OnClick = LBGroupSummaryItemsClick
                    OnKeyPress = FormKeyPress
                  end
                end
              end
              object PGroups: TPanel
                Left = 0
                Top = 0
                Width = 162
                Height = 137
                Align = alLeft
                BevelOuter = bvNone
                TabOrder = 0
                object Panel14: TPanel
                  Left = 0
                  Top = 103
                  Width = 162
                  Height = 34
                  Align = alBottom
                  BevelOuter = bvNone
                  TabOrder = 1
                  object BSummaryGroupAdd: TcxButton
                    Left = 4
                    Top = 6
                    Width = 75
                    Height = 24
                    Caption = '&Add'
                    TabOrder = 0
                    OnClick = BSummaryGroupAddClick
                  end
                  object BSummaryGroupDelete: TcxButton
                    Left = 83
                    Top = 6
                    Width = 75
                    Height = 24
                    Caption = '&Delete'
                    TabOrder = 1
                    OnClick = BSummaryGroupDeleteClick
                  end
                end
                object Panel15: TPanel
                  Left = 0
                  Top = 0
                  Width = 162
                  Height = 20
                  Align = alTop
                  BevelOuter = bvNone
                  TabOrder = 2
                  object Label5: TLabel
                    Left = 4
                    Top = 4
                    Width = 37
                    Height = 13
                    Caption = 'Groups:'
                  end
                end
                object Panel13: TPanel
                  Left = 0
                  Top = 20
                  Width = 162
                  Height = 83
                  Align = alClient
                  BevelOuter = bvNone
                  BorderWidth = 1
                  Color = clBtnShadow
                  TabOrder = 0
                  object LBSummaryGroups: TListBox
                    Left = 1
                    Top = 1
                    Width = 160
                    Height = 81
                    Align = alClient
                    BorderStyle = bsNone
                    ItemHeight = 13
                    MultiSelect = True
                    PopupMenu = PMSummaryGroups
                    TabOrder = 0
                    OnClick = LBSummaryGroupsClick
                    OnKeyPress = FormKeyPress
                  end
                end
              end
              object PGSeparator: TPanel
                Left = 162
                Top = 0
                Width = 4
                Height = 137
                Align = alLeft
                BevelOuter = bvNone
                TabOrder = 2
              end
            end
            object PLinks: TPanel
              Left = 0
              Top = 142
              Width = 328
              Height = 113
              Align = alBottom
              BevelOuter = bvNone
              Constraints.MinHeight = 100
              TabOrder = 1
              OnResize = PLinksResize
              object PUnlinkedColumns: TPanel
                Left = 0
                Top = 0
                Width = 147
                Height = 113
                Align = alLeft
                BevelOuter = bvNone
                TabOrder = 0
                object Panel19: TPanel
                  Left = 0
                  Top = 0
                  Width = 147
                  Height = 20
                  Align = alTop
                  BevelOuter = bvNone
                  TabOrder = 0
                  object Label6: TLabel
                    Left = 4
                    Top = 4
                    Width = 88
                    Height = 13
                    Caption = 'Unlinked Columns:'
                  end
                end
                object Panel17: TPanel
                  Left = 0
                  Top = 20
                  Width = 147
                  Height = 93
                  Align = alClient
                  BevelOuter = bvNone
                  BorderWidth = 1
                  Color = clBtnShadow
                  TabOrder = 1
                  object LBUnlinkedColumns: TListBox
                    Left = 1
                    Top = 1
                    Width = 145
                    Height = 91
                    Align = alClient
                    BorderStyle = bsNone
                    ItemHeight = 13
                    MultiSelect = True
                    TabOrder = 0
                    OnClick = LBUnlinkedColumnsClick
                    OnKeyPress = FormKeyPress
                  end
                end
              end
              object PLinkUnlink: TPanel
                Left = 147
                Top = 0
                Width = 35
                Height = 113
                Align = alLeft
                BevelOuter = bvNone
                TabOrder = 1
                object BColumnLink: TcxButton
                  Left = 5
                  Top = 34
                  Width = 25
                  Height = 25
                  Caption = '>'
                  TabOrder = 0
                  OnClick = BColumnLinkClick
                end
                object BColumnUnlink: TcxButton
                  Left = 5
                  Top = 68
                  Width = 25
                  Height = 25
                  Caption = '<'
                  TabOrder = 1
                  OnClick = BColumnUnlinkClick
                end
              end
              object PLinkedColumns: TPanel
                Left = 182
                Top = 0
                Width = 146
                Height = 113
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 2
                object Panel23: TPanel
                  Left = 0
                  Top = 0
                  Width = 146
                  Height = 20
                  Align = alTop
                  BevelOuter = bvNone
                  TabOrder = 0
                  object Label7: TLabel
                    Left = 4
                    Top = 4
                    Width = 78
                    Height = 13
                    Caption = 'Linked Columns:'
                  end
                end
                object Panel18: TPanel
                  Left = 0
                  Top = 20
                  Width = 146
                  Height = 93
                  Align = alClient
                  BevelOuter = bvNone
                  BorderWidth = 1
                  Color = clBtnShadow
                  TabOrder = 1
                  object LBLinkedColumns: TListBox
                    Left = 1
                    Top = 1
                    Width = 144
                    Height = 91
                    Align = alClient
                    BorderStyle = bsNone
                    ItemHeight = 13
                    MultiSelect = True
                    TabOrder = 0
                    OnClick = LBUnlinkedColumnsClick
                    OnKeyPress = FormKeyPress
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  object PMColumns: TPopupMenu
    Left = 228
    Top = 6
    object MIColumnAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = BColumnAddClick
    end
    object MIColumnDelete: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = BColumnDeleteClick
    end
    object MIColumnRestore: TMenuItem
      Caption = 'Rest&ore Defaults'
      OnClick = BColumnRestoreClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object MIColumnMoveUp: TMenuItem
      Caption = 'Move Up'
      ShortCut = 16422
      OnClick = BColumnMoveUpClick
    end
    object MIColumnMoveDown: TMenuItem
      Caption = 'Move Down'
      ShortCut = 16424
      OnClick = BColumnMoveDownClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MIColumnSelectAll: TMenuItem
      Caption = '&Select All'
      ShortCut = 16449
      OnClick = MIColumnSelectAllClick
    end
  end
  object PMFooterSummary: TPopupMenu
    Left = 230
    Top = 90
    object MIFooterSummaryAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = BAddFooterSummaryItemClick
    end
    object MIFooterSummaryDelete: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = BDeleteFooterSummaryItemClick
    end
    object MenuItem4a: TMenuItem
      Caption = '-'
    end
    object MIFooterSummarySelectAll: TMenuItem
      Caption = '&Select All'
      ShortCut = 16449
      OnClick = MIFooterSummarySelectAllClick
    end
  end
  object PMDefaultGroupsSummary: TPopupMenu
    Left = 230
    Top = 130
    object MIDefaultGroupSummaryAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = BDefaultGroupSummaryAddClick
    end
    object MIDefaultGroupSummaryDelete: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = BDefaultGroupSummaryDeleteClick
    end
    object MenuItem3b: TMenuItem
      Caption = '-'
    end
    object MIDefaultGroupSummarySelectAll: TMenuItem
      Caption = '&Select All'
      ShortCut = 16449
      OnClick = MIDefaultGroupSummarySelectAllClick
    end
  end
  object PMSummaryGroups: TPopupMenu
    Left = 230
    Top = 170
    object MISummaryGroupAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = BSummaryGroupAddClick
    end
    object MISummaryGroupDelete: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = BSummaryGroupDeleteClick
    end
    object MenuItem5d: TMenuItem
      Caption = '-'
    end
    object MISummaryGroupSelectAll: TMenuItem
      Caption = '&Select All'
      ShortCut = 16449
      OnClick = MISummaryGroupSelectAllClick
    end
  end
  object PMGroupSummaryItems: TPopupMenu
    Left = 230
    Top = 210
    object MIGroupSummaryItemsAdd: TMenuItem
      Caption = '&Add'
      ShortCut = 45
      OnClick = BGroupSummaryItemAddClick
    end
    object MIGroupSummaryItemsDelete: TMenuItem
      Caption = '&Delete'
      ShortCut = 46
      OnClick = BGroupSummaryItemDeleteClick
    end
    object MenuItem6c: TMenuItem
      Caption = '-'
    end
    object MIGroupSummaryItemsSelectAll: TMenuItem
      Caption = '&Select All'
      ShortCut = 16449
      OnClick = MIGroupSummaryItemsSelectAllClick
    end
  end
end
