object dxBarCustomizationForm: TdxBarCustomizationForm
  Left = 707
  Top = 171
  BorderIcons = [biSystemMenu]
  Caption = 'Customize'
  ClientHeight = 310
  ClientWidth = 366
  Color = clBtnFace
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 274
    Width = 366
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BClose: TButton
      Left = 285
      Top = 8
      Width = 75
      Height = 23
      Cancel = True
      Caption = 'Close'
      Default = True
      ModalResult = 1
      TabOrder = 1
      OnClick = BCloseClick
    end
    object BHelp: TBitBtn
      Left = 6
      Top = 8
      Width = 24
      Height = 23
      TabOrder = 0
      OnClick = BHelpClick
      Style = bsNew
    end
  end
  object PageControl: TPageControl
    Left = 6
    Top = 8
    Width = 354
    Height = 266
    ActivePage = tsToolbars
    Align = alClient
    TabOrder = 0
    object tsToolbars: TTabSheet
      Caption = ' Toolbars '
      object LabelToobars: TLabel
        Left = 4
        Top = 4
        Width = 44
        Height = 13
        Caption = 'Toolb&ars:'
      end
      object BBarDelete: TButton
        Left = 239
        Top = 79
        Width = 104
        Height = 22
		Action = aDeleteToolBar
        TabOrder = 3
      end
      object BBarNew: TButton
        Left = 239
        Top = 21
        Width = 104
        Height = 22
		Action = aNewToolBar
        TabOrder = 1
      end
      object BBarRename: TButton
        Left = 239
        Top = 50
        Width = 104
        Height = 22
		Action = aRenameToolBar
        TabOrder = 2
      end
      object lbBarsList: TListBox
        Left = 4
        Top = 20
        Width = 227
        Height = 213
        Style = lbOwnerDrawFixed
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 13
        TabOrder = 0
      end
      object BBarReset: TButton
        Left = 239
        Top = 108
        Width = 104
        Height = 22
		Action = aResetToolBar
        TabOrder = 4
      end
    end
    object tsItems: TTabSheet
      Caption = ' Commands '
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 346
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object LabelCategories: TLabel
          Left = 6
          Top = 8
          Width = 53
          Height = 13
          Caption = 'Cate&gories:'
          FocusControl = lbCategories
        end
        object LabelCommands: TLabel
          Left = 148
          Top = 8
          Width = 55
          Height = 13
          Caption = 'Comman&ds:'
        end
        object CategoriesPopupButtonPlace: TSpeedButton
          Left = 65
          Top = 6
          Width = 75
          Height = 17
        end
        object CommandsPopupButtonPlace: TSpeedButton
          Left = 207
          Top = 6
          Width = 134
          Height = 17
        end
      end
      object Panel7: TPanel
        Left = 5
        Top = 25
        Width = 336
        Height = 213
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel7'
        TabOrder = 1
        object lbCategories: TListBox
          Left = 0
          Top = 0
          Width = 135
          Height = 147
          Align = alLeft
          ItemHeight = 13
          TabOrder = 0
        end
        object lbItems: TListBox
          Left = 142
          Top = 0
          Width = 194
          Height = 147
          Style = lbOwnerDrawFixed
          Align = alRight
          Color = clBtnFace
          ItemHeight = 22
          TabOrder = 1
          OnDrawItem = lbItemsDrawItem
        end
        object Panel9: TPanel
          Left = 0
          Top = 147
          Width = 336
          Height = 66
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 2
          object DescriptionLabel: TLabel
            Left = 0
            Top = 20
            Width = 335
            Height = 40
            AutoSize = False
            WordWrap = True
          end
          object Bevel1: TBevel
            Left = 0
            Top = 10
            Width = 337
            Height = 5
            Shape = bsTopLine
          end
          object LabelDescription: TLabel
            Left = 0
            Top = 4
            Width = 59
            Height = 13
            Caption = 'Description  '
          end
        end
      end
      object Panel5: TPanel
        Left = 0
        Top = 25
        Width = 5
        Height = 213
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 2
      end
      object Panel8: TPanel
        Left = 341
        Top = 25
        Width = 5
        Height = 213
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 3
      end
    end
    object tsOptions: TTabSheet
      Caption = ' Options '
      object StandardOptionsPanel: TPanel
        Left = 0
        Top = 0
        Width = 346
        Height = 238
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object LabelMenuAnimations: TLabel
          Left = 24
          Top = 152
          Width = 83
          Height = 13
          Caption = '&Menu animations:'
          FocusControl = ComboBoxMenuAnimations
        end
        object ComboBoxMenuAnimations: TComboBox
          Left = 134
          Top = 148
          Width = 93
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 3
          OnClick = ComboBoxMenuAnimationsClick
          Items.Strings = (
            '(None)'
            'Random'
            'Unfold'
            'Slide')
        end
        object CBHint1: TCheckBox
          Left = 24
          Top = 63
          Width = 301
          Height = 17
          Caption = 'Show Tool&Tips on toolbars'
          TabOrder = 1
          OnClick = CBHint1Click
        end
        object CBHint2: TCheckBox
          Left = 24
          Top = 85
          Width = 301
          Height = 17
          Caption = 'Show s&hortcut keys in ToolTips'
          TabOrder = 2
          OnClick = CBHint2Click
        end
        object CBLargeIcons: TCheckBox
          Left = 24
          Top = 38
          Width = 301
          Height = 17
          Caption = '&Large icons'
          TabOrder = 0
          OnClick = CBLargeIconsClick
        end
      end
      object EnhancedOptionsPanel: TPanel
        Left = 0
        Top = 0
        Width = 346
        Height = 238
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Label1: TLabel
          Left = 20
          Top = 200
          Width = 83
          Height = 13
          Caption = '&Menu animations:'
          FocusControl = ComboBoxMenuAnimationsEx
        end
        object Bevel2: TBevel
          Left = 12
          Top = 122
          Width = 317
          Height = 9
          Shape = bsTopLine
        end
        object Label2: TLabel
          Left = 12
          Top = 116
          Width = 32
          Height = 13
          Caption = 'Other  '
        end
        object Bevel3: TBevel
          Left = 12
          Top = 18
          Width = 317
          Height = 7
          Shape = bsTopLine
        end
        object Label3: TLabel
          Left = 12
          Top = 12
          Width = 166
          Height = 13
          Caption = 'Personalized Menus and Toolbars  '
        end
        object ComboBoxMenuAnimationsEx: TComboBox
          Left = 132
          Top = 196
          Width = 93
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 6
          OnClick = ComboBoxMenuAnimationsClick
          Items.Strings = (
            '(None)'
            'Random'
            'Unfold'
            'Slide')
        end
        object CBHint1Ex: TCheckBox
          Left = 20
          Top = 152
          Width = 309
          Height = 17
          Caption = 'Show Tool&Tips on toolbars'
          TabOrder = 4
          OnClick = CBHint1ExClick
        end
        object CBHint2Ex: TCheckBox
          Left = 36
          Top = 172
          Width = 293
          Height = 17
          Caption = 'Show s&hortcut keys in ToolTips'
          TabOrder = 5
          OnClick = CBHint2Click
        end
        object CBLargeIconsEx: TCheckBox
          Left = 20
          Top = 132
          Width = 309
          Height = 17
          Caption = '&Large icons'
          TabOrder = 3
          OnClick = CBLargeIconsClick
        end
        object CBMenusShowRecentItemsFirst: TCheckBox
          Left = 20
          Top = 32
          Width = 309
          Height = 17
          Caption = 'Me&nus show recently used commands first'
          TabOrder = 0
          OnClick = CBMenusShowRecentItemsFirstClick
        end
        object CBShowFullMenusAfterDelay: TCheckBox
          Left = 36
          Top = 52
          Width = 293
          Height = 17
          Caption = 'Show f&ull menus after a short delay'
          TabOrder = 1
          OnClick = CBShowFullMenusAfterDelayClick
        end
        object BResetUsageData: TButton
          Left = 20
          Top = 76
          Width = 119
          Height = 22
          Caption = '&Reset my usage data'
          TabOrder = 2
          OnClick = BResetUsageDataClick
        end
      end
    end
    object tsCommands: TTabSheet
      Caption = ' All commands '
      object LAllCommands: TListBox
        Left = 6
        Top = 8
        Width = 333
        Height = 200
        Style = lbOwnerDrawFixed
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 16
        MultiSelect = True
        TabOrder = 0
        OnClick = LAllCommandsClick
        OnDrawItem = LAllCommandsDrawItem
        OnKeyDown = LAllCommandsKeyDown
      end
      object CBShowCommandsWithShortCut: TCheckBox
        Left = 6
        Top = 216
        Width = 333
        Height = 17
        Anchors = [akLeft, akBottom]
        Caption = 'Show commands that may have a shortcut'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = CBShowCommandsWithShortCutClick
      end
    end
    object tsGroups: TTabSheet
      Caption = 'Groups'
      object Bevel4: TBevel
        Left = 171
        Top = 0
        Width = 4
        Height = 238
        Align = alLeft
        Shape = bsSpacer
      end
      object gpGroupItems: TGroupBox
        Left = 175
        Top = 0
        Width = 171
        Height = 238
        Align = alClient
        Caption = ' Items '
        TabOrder = 0
        object lbGroupItems: TListBox
          Left = 2
          Top = 44
          Width = 167
          Height = 192
          Style = lbOwnerDrawVariable
          Align = alClient
          BorderStyle = bsNone
          ItemHeight = 13
          MultiSelect = True
          TabOrder = 0
          OnClick = lbGroupItemsClick
          OnDrawItem = lbGroupItemsDrawItem
          OnKeyDown = lbGroupItemsKeyDown
          OnMeasureItem = lbGroupsMeasureItem
        end
        object tbGroupItems: TToolBar
          Left = 2
          Top = 15
          Width = 167
          Height = 29
          Caption = 'tbGroupItems'
          EdgeBorders = [ebBottom]
          EdgeOuter = esNone
          Flat = True
		  Images = imgGroups
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          object btnAddGroupItem: TToolButton
            Left = 0
            Top = 0
            Action = aAddGroupItem
          end
          object btnDeleteGroupItem: TToolButton
            Left = 23
            Top = 0
            Action = aDeleteGroupItem
          end
          object ToolButton8: TToolButton
            Left = 46
            Top = 0
            Width = 8
            Caption = 'ToolButton8'
            ImageIndex = 2
            Style = tbsSeparator
          end
          object btnMoveUpGroupItem: TToolButton
            Left = 54
            Top = 0
            Action = aMoveUpGroupItem
          end
          object btnMoveDownGroupItem: TToolButton
            Left = 77
            Top = 0
            Action = aMoveDownGroupItem
          end
        end
      end
      object gbGroups: TGroupBox
        Left = 0
        Top = 0
        Width = 171
        Height = 238
        Align = alLeft
        Caption = ' Groups '
        TabOrder = 1
        object lbGroups: TListBox
          Left = 2
          Top = 44
          Width = 167
          Height = 192
          Style = lbOwnerDrawVariable
          Align = alClient
          BorderStyle = bsNone
          ItemHeight = 13
          MultiSelect = True
          TabOrder = 0
          OnClick = lbGroupsClick
          OnDrawItem = lbGroupsDrawItem
          OnKeyDown = lbGroupsKeyDown
          OnMeasureItem = lbGroupsMeasureItem
        end
        object tbGroups: TToolBar
          Left = 2
          Top = 15
          Width = 167
          Height = 29
          Caption = 'tbGroups'
          EdgeBorders = [ebBottom]
          EdgeOuter = esNone
          Flat = True
		  Images = imgGroups
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          object btnAddGroup: TToolButton
            Left = 0
            Top = 0
            Action = aAddGroup
          end
          object btnDeleteGroup: TToolButton
            Left = 23
            Top = 0
            Action = aDeleteGroup
          end
          object ToolButton3: TToolButton
            Left = 46
            Top = 0
            Width = 8
            Caption = 'ToolButton3'
            ImageIndex = 2
            Style = tbsSeparator
          end
          object btnMoveUpGroup: TToolButton
            Left = 54
            Top = 0
            Action = aMoveUpGroup
            AllowAllUp = True
          end
          object btnMoveDownGroup: TToolButton
            Left = 77
            Top = 0
            Action = aMoveDownGroup
          end
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Key Tips'
      ImageIndex = 5
      TabVisible = False
      object tvKeyTips: TTreeView
        Left = 11
        Top = 13
        Width = 314
        Height = 204
        Indent = 19
        TabOrder = 0
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 8
    Width = 6
    Height = 266
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
  end
  object Panel3: TPanel
    Left = 360
    Top = 8
    Width = 6
    Height = 266
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 3
  end
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 366
    Height = 8
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 4
  end
  object alGroupCustomize: TActionList
    Left = 48
    Top = 280
	Images = imgGroup
    object aAddGroup: TAction
      Category = 'Groups'
      Caption = 'Add Group'
      Hint = 'Add Group (Ins)'
      ImageIndex = 0
      OnExecute = aAddGroupExecute
    end
    object aDeleteGroup: TAction
      Category = 'Groups'
      Caption = 'Delete Group'
      Hint = 'Delete Group (Del)'
      ImageIndex = 1
      OnExecute = aDeleteGroupExecute
    end
    object aMoveUpGroup: TAction
      Tag = -1
      Category = 'Groups'
      Caption = 'Move Up Group'
      Hint = 'Move Up Group'
      ImageIndex = 2
      OnExecute = aMoveGroupExecute
    end
    object aMoveDownGroup: TAction
      Tag = 1
      Category = 'Groups'
      Caption = 'Move Down Group'
      Hint = 'Move Down Group'
      ImageIndex = 3
      OnExecute = aMoveGroupExecute
    end
    object aAddGroupItem: TAction
      Category = 'GroupItems'
      Caption = '&Add...'
      ImageIndex = 0
      OnExecute = aAddGroupItemExecute
    end
    object aDeleteGroupItem: TAction
      Category = 'GroupItems'
      Caption = 'Delete'
      ImageIndex = 1
      OnExecute = aDeleteGroupItemExecute
    end
    object aMoveUpGroupItem: TAction
      Tag = -1
      Category = 'GroupItems'
      Caption = 'Move Up Item'
      ImageIndex = 2
	  OnExecute = aMoveGroupItemExecute
    end
    object aMoveDownGroupItem: TAction
      Tag = 1
      Category = 'GroupItems'
      Caption = 'aMoveDownGroupItem'
      ImageIndex = 3
	  OnExecute = aMoveGroupItemExecute
    end
  end
end
