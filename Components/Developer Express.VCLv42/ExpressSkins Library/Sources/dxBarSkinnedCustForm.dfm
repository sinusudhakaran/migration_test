object dxBarSkinnedCustomizationForm: TdxBarSkinnedCustomizationForm
  ClientWidth = 370
  ClientHeight = 310
  BorderIcons = [biSystemMenu]
  Caption = 'Customize'
  Color = clBtnFace
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LeftBevel: TBevel
    Left = 0
    Top = 8
    Width = 6
    Height = 258
    Align = alLeft
    Shape = bsSpacer
  end
  object RightBevel: TBevel
    Left = 363
    Top = 8
    Width = 6
    Height = 258
    Align = alRight
    Shape = bsSpacer
  end
  object TopBevel: TBevel
    Left = 0
    Top = 0
    Width = 369
    Height = 8
    Align = alTop
    Shape = bsSpacer
  end
  object Panel1: TPanel
    Left = 0
    Top = 266
    Width = 369
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object BClose: TcxButton
      Left = 285
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Close'
      Default = True
      ModalResult = 1
      TabOrder = 1
	  OnClick = BCloseClick
    end
    object BHelp: TcxButton
      Left = 6
      Top = 6
      Width = 25
      Height = 25
      TabOrder = 0
	  OnClick = BHelpClick
    end
  end
  object PageControl: TcxPageControl
    Left = 6
    Top = 8
    Width = 357
    Height = 258
    ActivePage = tsToolbars
    Align = alClient
    TabOrder = 0
    ClientRectBottom = 258
    ClientRectRight = 357
    ClientRectTop = 24
    object tsToolbars: TcxTabSheet
      Caption = ' Toolbars '
      object BBarNew: TcxButton
        Left = 239
        Top = 21
        Width = 104
        Height = 25
        TabOrder = 0
      end
      object BBarDelete: TcxButton
        Left = 239
        Top = 83
        Width = 104
        Height = 25
        TabOrder = 2
      end
      object BBarRename: TcxButton
        Left = 239
        Top = 52
        Width = 104
        Height = 25
        TabOrder = 1
      end
      object BBarReset: TcxButton
        Left = 239
        Top = 114
        Width = 104
        Height = 25
        TabOrder = 3
      end
      object LabelToobars: TcxLabel
        Left = 4
        Top = 4
        Caption = 'Toolb&ars:'
        Transparent = True
      end
      object lbBarsList: TcxListBox
        Left = 4
        Top = 20
        Width = 227
        Height = 199
        Anchors = [akLeft, akTop, akBottom]
        ItemHeight = 13
        ListStyle = lbOwnerDrawFixed
        TabOrder = 5
      end
    end
    object tsItems: TcxTabSheet
      Caption = ' Commands '
      object Panel6: TPanel
        Left = 0
        Top = 0
        Width = 347
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object LabelCategories: TcxLabel
          Left = 6
          Top = 8
          Caption = 'Cate&gories:'
          FocusControl = lbCategories
          Transparent = True
        end
        object LabelCommands: TcxLabel
          Left = 167
          Top = 8
		  Anchors = [akTop, akRight]
          Caption = 'Comman&ds:'
          Transparent = True
        end
        object CategoriesPopupButtonPlace: TcxButton
          Left = 65
          Top = 6
          Width = 75
          Height = 17
          TabOrder = 3
        end
        object CommandsPopupButtonPlace: TcxButton
          Anchors = [akTop, akRight]
		  Left = 232
          Top = 6
          Width = 120
          Height = 17
          TabOrder = 2
        end
      end
      object Panel7: TPanel
        Left = 0
        Top = 25
        Width = 347
        Height = 200
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Bevel4: TBevel
          Left = 343
          Top = 0
          Width = 4
          Height = 134
          Align = alRight
          Shape = bsSpacer
        end
        object Bevel5: TBevel
          Left = 0
          Top = 0
          Width = 4
          Height = 134
          Align = alLeft
          Shape = bsSpacer
        end
        object Panel9: TPanel
          Left = 0
          Top = 134
          Width = 347
          Height = 66
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 2
          object Bevel1: TBevel
            Left = 8
            Top = 10
            Width = 329
            Height = 5
            Shape = bsTopLine
          end
          object DescriptionLabel: TcxLabel
            Left = 8
            Top = 20
            AutoSize = False
            Transparent = True
            Height = 17
            Width = 47
          end
          object LabelDescription: TcxLabel
            Left = 8
            Top = 4
            Caption = 'Description  '
            Transparent = True
          end
        end
        object lbCategories: TcxListBox
          Left = 4
          Top = 0
          Width = 145
          Height = 134
          Align = alLeft
          ItemHeight = 13
          TabOrder = 0
        end
        object lbItems: TcxListBox
          Left = 155
          Top = 0
          Width = 188
          Height = 134
          Align = alRight
          ItemHeight = 13
          ListStyle = lbOwnerDrawVariable
          TabOrder = 1
          OnDrawItem = lbItemsDrawItem
        end
      end
    end
    object tsOptions: TcxTabSheet
      Caption = ' Options '
      object EnhancedOptionsPanel: TPanel
        Left = 0
        Top = 0
        Width = 347
        Height = 225
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Bevel2: TBevel
          Left = 12
          Top = 122
          Width = 317
          Height = 9
          Shape = bsTopLine
        end
        object Bevel3: TBevel
          Left = 12
          Top = 18
          Width = 317
          Height = 7
          Shape = bsTopLine
        end
        object BResetUsageData: TcxButton
          Left = 20
          Top = 76
          Width = 119
          Height = 25
          Caption = '&Reset my usage data'
          TabOrder = 2
          OnClick = BResetUsageDataClick
        end
        object Label1: TcxLabel
          Left = 20
          Top = 197
          Caption = '&Menu animations:'
          FocusControl = ComboBoxMenuAnimationsEx
          Transparent = True
        end
        object Label2: TcxLabel
          Left = 12
          Top = 116
          Caption = 'Other  '
          Transparent = True
        end
        object Label3: TcxLabel
          Left = 12
          Top = 12
          Caption = 'Personalized Menus and Toolbars  '
          Transparent = True
        end
        object CBMenusShowRecentItemsFirst: TcxCheckBox
          Left = 20
          Top = 32
          Caption = 'Me&nus show recently used commands first'
          TabOrder = 0
          Transparent = True
          OnClick = CBMenusShowRecentItemsFirstClick
          Width = 309
        end
        object CBShowFullMenusAfterDelay: TcxCheckBox
          Left = 36
          Top = 52
          Caption = 'Show f&ull menus after a short delay'
          TabOrder = 1
          Transparent = True
          OnClick = CBShowFullMenusAfterDelayClick
          Width = 293
        end
        object CBHint1Ex: TcxCheckBox
          Left = 20
          Top = 152
          Caption = 'Show Tool&Tips on toolbars'
          TabOrder = 4
          Transparent = True
          OnClick = CBHint1ExClick
          Width = 309
        end
        object CBHint2Ex: TcxCheckBox
          Left = 36
          Top = 172
          Caption = 'Show s&hortcut keys in ToolTips'
          TabOrder = 5
          Transparent = True
          OnClick = CBHint2Click
          Width = 293
        end
        object CBLargeIconsEx: TcxCheckBox
          Left = 20
          Top = 132
          Caption = '&Large icons'
          TabOrder = 3
          Transparent = True
          OnClick = CBLargeIconsClick
          Width = 309
        end
        object ComboBoxMenuAnimationsEx: TcxComboBox
          Left = 132
          Top = 196
          Properties.DropDownListStyle = lsFixedList
          TabOrder = 6
          OnClick = ComboBoxMenuAnimationsClick
          Width = 93
        end
      end
      object StandardOptionsPanel: TPanel
        Left = 0
        Top = 0
        Width = 347
        Height = 225
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object LabelMenuAnimations: TcxLabel
          Left = 24
          Top = 152
          Caption = '&Menu animations:'
          FocusControl = ComboBoxMenuAnimations
          Transparent = True
        end
        object ComboBoxMenuAnimations: TcxComboBox
          Left = 134
          Top = 148
          Properties.DropDownListStyle = lsEditFixedList
          TabOrder = 2
          OnClick = ComboBoxMenuAnimationsClick
          Width = 93
        end
        object CBHint2: TcxCheckBox
          Left = 24
          Top = 85
          Caption = 'Show s&hortcut keys in ToolTips'
          TabOrder = 1
          Transparent = True
          OnClick = CBHint2Click
          Width = 301
        end
        object CBLargeIcons: TcxCheckBox
          Left = 24
          Top = 38
          Caption = '&Large icons'
          TabOrder = 0
          Transparent = True
          OnClick = CBLargeIconsClick
          Width = 301
        end
        object CBHint1: TcxCheckBox
          Left = 24
          Top = 63
          Caption = 'Show Tool&Tips on toolbars'
          TabOrder = 4
          Transparent = True
          OnClick = CBHint1Click
          Width = 301
        end
      end
    end
    object TabSheet1: TcxTabSheet
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
end
