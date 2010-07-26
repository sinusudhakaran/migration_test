object dxMasterViewDesigner: TdxMasterViewDesigner
  Left = 617
  Top = 100
  Width = 365
  Height = 418
  BorderIcons = [biSystemMenu]
  Caption = 'Designer'
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OnActivate = FormActivate
  OnClose = FormClose
  OnDeactivate = FormDeactivate
  PixelsPerInch = 96
  TextHeight = 13
  object pcMain: TPageControl
    Left = 5
    Top = 5
    Width = 347
    Height = 381
    ActivePage = pageMain
    Align = alClient
    TabOrder = 0
    OnChange = pcMainChange
    OnChanging = pcMainChanging
    object pageMain: TTabSheet
      Caption = 'Main'
      object splMain: TSplitter
        Left = 0
        Top = 75
        Width = 339
        Height = 6
        Cursor = crVSplit
        Align = alTop
        OnMoved = splMainMoved
      end
      object pnlLevels: TPanel
        Left = 0
        Top = 0
        Width = 339
        Height = 75
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object pnlLevelButtons: TPanel
          Left = 238
          Top = 21
          Width = 101
          Height = 52
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 1
          object btnLevelAdd: TButton
            Left = 6
            Top = 0
            Width = 90
            Height = 22
            Caption = 'Add'
            TabOrder = 0
            OnClick = btnLevelAddClick
          end
          object btnLevelDelete: TButton
            Left = 6
            Top = 30
            Width = 90
            Height = 22
            Caption = 'Delete'
            TabOrder = 1
            OnClick = btnLevelDeleteClick
          end
        end
        object pnlLevelHeader: TPanel
          Left = 0
          Top = 0
          Width = 339
          Height = 21
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 2
          object Bevel2: TBevel
            Left = 5
            Top = 10
            Width = 2000
            Height = 7
            Shape = bsTopLine
          end
          object Label1: TLabel
            Left = 12
            Top = 4
            Width = 37
            Height = 13
            Caption = ' Levels '
          end
          object Panel7: TPanel
            Left = 334
            Top = 0
            Width = 5
            Height = 21
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 0
          end
        end
        object tvLevels: TTreeView
          Left = 5
          Top = 21
          Width = 233
          Height = 52
          Align = alClient
          HideSelection = False
          Indent = 19
          ReadOnly = True
          ShowButtons = False
          ShowRoot = False
          TabOrder = 0
          OnChange = tvLevelsChange
          OnEnter = tvLevelsEnter
          OnKeyDown = tvLevelsKeyDown
        end
        object Panel5: TPanel
          Left = 0
          Top = 21
          Width = 5
          Height = 52
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 3
        end
        object Panel4: TPanel
          Left = 0
          Top = 73
          Width = 339
          Height = 2
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 4
        end
      end
      object Panel11: TPanel
        Left = 0
        Top = 81
        Width = 339
        Height = 11
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Bevel1: TBevel
          Left = 5
          Top = 4
          Width = 2000
          Height = 7
          Shape = bsTopLine
        end
        object Panel15: TPanel
          Left = 334
          Top = 0
          Width = 5
          Height = 11
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 0
        end
      end
      object pcPages: TPageControl
        Left = 5
        Top = 92
        Width = 329
        Height = 256
        ActivePage = tshColumns
        Align = alClient
        TabOrder = 2
        object tshColumns: TTabSheet
          Caption = ' Columns '
          object pnlColumnButtons: TPanel
            Left = 220
            Top = 5
            Width = 101
            Height = 218
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 0
            object btnColumnAdd: TButton
              Left = 6
              Top = 0
              Width = 90
              Height = 22
              Caption = 'Add...'
              TabOrder = 0
              OnClick = btnColumnAddClick
            end
            object btnColumnDelete: TButton
              Left = 6
              Top = 28
              Width = 90
              Height = 22
              Caption = 'Delete'
              TabOrder = 1
              OnClick = btnColumnDeleteClick
            end
            object btnColumnAddAll: TButton
              Left = 6
              Top = 56
              Width = 90
              Height = 22
              Caption = 'Add All'
              TabOrder = 2
              OnClick = btnColumnAddAllClick
            end
            object btnColumnMoveUp: TButton
              Left = 6
              Top = 112
              Width = 90
              Height = 22
              Caption = 'Move Up'
              TabOrder = 4
              OnClick = btnColumnMoveUpClick
            end
            object btnColumnRestoreDefaults: TButton
              Left = 6
              Top = 168
              Width = 90
              Height = 22
              Caption = 'Restore Defaults'
              TabOrder = 6
              OnClick = btnColumnRestoreDefaultsClick
            end
            object btnColumnRestoreWidth: TButton
              Left = 6
              Top = 196
              Width = 90
              Height = 22
              Caption = 'Restore Width'
              TabOrder = 7
              OnClick = btnColumnRestoreWidthClick
            end
            object btnColumnMoveDown: TButton
              Left = 6
              Top = 140
              Width = 90
              Height = 22
              Caption = 'Move Down'
              TabOrder = 5
              OnClick = btnColumnMoveDownClick
            end
            object btnColumnChangeType: TButton
              Left = 6
              Top = 84
              Width = 90
              Height = 22
              Caption = 'Change Type...'
              TabOrder = 3
              OnClick = btnColumnChangeTypeClick
            end
          end
          object lbColumns: TListBox
            Left = 5
            Top = 5
            Width = 215
            Height = 218
            Align = alClient
            ItemHeight = 13
            MultiSelect = True
            TabOrder = 1
            OnClick = lbColumnsClick
            OnEnter = lbColumnsEnter
            OnKeyDown = lbColumnsKeyDown
          end
          object Panel1: TPanel
            Left = 0
            Top = 0
            Width = 321
            Height = 5
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 2
          end
          object Panel13: TPanel
            Left = 0
            Top = 5
            Width = 5
            Height = 218
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 3
          end
          object Panel14: TPanel
            Left = 0
            Top = 223
            Width = 321
            Height = 5
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 4
          end
        end
        object tshData: TTabSheet
          Caption = ' Data '
          object lblDataSource: TLabel
            Left = 104
            Top = 72
            Width = 68
            Height = 13
            Alignment = taRightJustify
            Caption = 'DataSource'
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblID: TLabel
            Left = 161
            Top = 100
            Width = 11
            Height = 13
            Alignment = taRightJustify
            Caption = 'ID'
          end
          object lblMasterKey: TLabel
            Left = 62
            Top = 36
            Width = 50
            Height = 13
            Alignment = taRightJustify
            Caption = 'MasterKey'
          end
          object lblDetailKey: TLabel
            Left = 127
            Top = 124
            Width = 45
            Height = 13
            Alignment = taRightJustify
            Caption = 'DetailKey'
          end
          object Bevel5: TBevel
            Left = 90
            Top = 52
            Width = 33
            Height = 79
            Shape = bsLeftLine
          end
          object Bevel6: TBevel
            Left = 91
            Top = 130
            Width = 31
            Height = 7
            Shape = bsTopLine
          end
          object lblMasterDataSource: TLabel
            Left = 6
            Top = 8
            Width = 106
            Height = 13
            Alignment = taRightJustify
            Caption = 'MasterDataSource'
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object cmbDataSource: TComboBox
            Left = 176
            Top = 68
            Width = 140
            Height = 21
            Style = csDropDownList
            DropDownCount = 12
            ItemHeight = 0
            TabOrder = 2
            OnChange = cmbDataSourceChange
          end
          object cmbID: TComboBox
            Left = 176
            Top = 96
            Width = 140
            Height = 21
            DropDownCount = 12
            ItemHeight = 0
            TabOrder = 3
            OnClick = cmbIDClick
            OnExit = cmbIDClick
            OnKeyDown = cmbIDKeyDown
          end
          object cmbMasterKey: TComboBox
            Left = 116
            Top = 32
            Width = 140
            Height = 21
            DropDownCount = 12
            ItemHeight = 0
            TabOrder = 1
            OnClick = cmbMasterKeyClick
            OnExit = cmbMasterKeyClick
            OnKeyDown = cmbMasterKeyKeyDown
          end
          object cmbDetailKey: TComboBox
            Left = 176
            Top = 120
            Width = 140
            Height = 21
            DropDownCount = 12
            ItemHeight = 0
            TabOrder = 4
            OnClick = cmbDetailKeyClick
            OnExit = cmbDetailKeyClick
            OnKeyDown = cmbDetailKeyKeyDown
          end
          object pnlMasterDataSource: TPanel
            Left = 116
            Top = 4
            Width = 140
            Height = 21
            Alignment = taLeftJustify
            BevelOuter = bvLowered
            TabOrder = 0
          end
        end
      end
      object Panel9: TPanel
        Left = 0
        Top = 92
        Width = 5
        Height = 256
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 3
      end
      object Panel10: TPanel
        Left = 334
        Top = 92
        Width = 5
        Height = 256
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 4
      end
      object Panel12: TPanel
        Left = 0
        Top = 348
        Width = 339
        Height = 5
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 5
      end
    end
    object pageStyles: TTabSheet
      Caption = 'Styles'
      object Panel21: TPanel
        Left = 0
        Top = 5
        Width = 5
        Height = 343
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
      end
      object Panel22: TPanel
        Left = 0
        Top = 348
        Width = 339
        Height = 5
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
      end
      object Panel23: TPanel
        Left = 0
        Top = 0
        Width = 339
        Height = 5
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
      end
      object Panel2: TPanel
        Left = 5
        Top = 5
        Width = 334
        Height = 343
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 3
        object lbStyles: TListBox
          Left = 0
          Top = 0
          Width = 233
          Height = 268
          Align = alClient
          ItemHeight = 13
          MultiSelect = True
          TabOrder = 0
          OnClick = lbStylesClick
          OnKeyDown = lbStylesKeyDown
        end
        object pnlStyleButtons: TPanel
          Left = 233
          Top = 0
          Width = 101
          Height = 268
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 1
          object btnStyleAdd: TButton
            Left = 6
            Top = 0
            Width = 90
            Height = 22
            Caption = 'Add'
            TabOrder = 0
            OnClick = btnStyleAddClick
          end
          object btnStyleDelete: TButton
            Left = 6
            Top = 28
            Width = 90
            Height = 22
            Caption = 'Delete'
            TabOrder = 1
            OnClick = btnStyleDeleteClick
          end
          object btnStyleMoveUp: TButton
            Left = 6
            Top = 56
            Width = 90
            Height = 22
            Caption = 'Move Up'
            TabOrder = 2
            OnClick = btnStyleMoveUpClick
          end
          object btnStyleMoveDown: TButton
            Left = 6
            Top = 84
            Width = 90
            Height = 22
            Caption = 'Move Down'
            TabOrder = 3
            OnClick = btnStyleMoveDownClick
          end
        end
        object Panel3: TPanel
          Left = 0
          Top = 268
          Width = 334
          Height = 75
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 2
          object Bevel3: TBevel
            Left = 0
            Top = 9
            Width = 1996
            Height = 5
            Shape = bsTopLine
          end
          object Label2: TLabel
            Left = 8
            Top = 3
            Width = 44
            Height = 13
            Caption = ' Preview '
          end
          object Panel8: TPanel
            Left = 329
            Top = 0
            Width = 5
            Height = 75
            Align = alRight
            BevelOuter = bvNone
            TabOrder = 0
          end
          object pnlPreviews: TPanel
            Left = 16
            Top = 20
            Width = 293
            Height = 55
            BevelOuter = bvNone
            TabOrder = 1
            object Label3: TLabel
              Left = 34
              Top = 44
              Width = 57
              Height = 13
              Caption = 'Color & Font'
              ShowAccelChar = False
            end
            object Label4: TLabel
              Left = 179
              Top = 44
              Width = 94
              Height = 13
              Caption = 'AnotherColor & Font'
              ShowAccelChar = False
            end
            object bvlMainPreview: TBevel
              Left = 0
              Top = 0
              Width = 133
              Height = 41
            end
            object bvlAnotherPreview: TBevel
              Left = 160
              Top = 0
              Width = 133
              Height = 41
            end
            object pnlMainPreview: TPanel
              Left = 1
              Top = 1
              Width = 131
              Height = 39
              BevelOuter = bvNone
              Caption = 'Developer Express'
              Font.Color = clBtnFace
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentColor = True
              ParentFont = False
              TabOrder = 0
            end
            object pnlAnotherPreview: TPanel
              Left = 161
              Top = 1
              Width = 131
              Height = 39
              BevelOuter = bvNone
              Caption = 'Developer Express'
              Font.Color = clBtnFace
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentColor = True
              ParentFont = False
              TabOrder = 1
            end
          end
        end
      end
    end
  end
  object Panel16: TPanel
    Left = 0
    Top = 0
    Width = 357
    Height = 5
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
  end
  object Panel17: TPanel
    Left = 352
    Top = 5
    Width = 5
    Height = 381
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
  end
  object Panel18: TPanel
    Left = 0
    Top = 5
    Width = 5
    Height = 381
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 3
  end
  object Panel19: TPanel
    Left = 0
    Top = 386
    Width = 357
    Height = 5
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
  end
end
