object LookAndFeelListDesignForm: TLookAndFeelListDesignForm
  Left = 532
  Top = 129
  Width = 326
  Height = 441
  Color = clBtnFace
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lcMain: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 318
    Height = 407
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = dxLayoutOfficeLookAndFeel1
    object lbItems: TListBox
      Left = 12
      Top = 12
      Width = 401
      Height = 264
      Style = lbOwnerDrawFixed
      BorderStyle = bsNone
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
    end
    object btnAdd: TButton
      Left = 233
      Top = 10
      Width = 75
      Height = 23
      Caption = 'Add...'
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 233
      Top = 39
      Width = 75
      Height = 23
      Caption = 'Delete'
      TabOrder = 2
    end
    object btnClose: TButton
      Left = 233
      Top = 68
      Width = 75
      Height = 23
      Cancel = True
      Caption = 'Close'
      Default = True
      TabOrder = 3
      OnClick = btnCloseClick
    end
    object pnlPreview: TPanel
      Left = 20
      Top = 193
      Width = 278
      Height = 200
      BevelOuter = bvLowered
      TabOrder = 4
      object lcPreview: TdxLayoutControl
        Left = 1
        Top = 1
        Width = 276
        Height = 198
        Align = alClient
        TabOrder = 0
        TabStop = False
        Visible = False
        AutoContentSizes = [acsWidth, acsHeight]
        object Edit1: TEdit
          Left = 53
          Top = 30
          Width = 90
          Height = 17
          BorderStyle = bsNone
          TabOrder = 0
          Text = 'Edit1'
        end
        object Edit2: TEdit
          Left = 53
          Top = 57
          Width = 90
          Height = 17
          BorderStyle = bsNone
          TabOrder = 1
          Text = 'Edit2'
        end
        object CheckBox1: TCheckBox
          Left = 22
          Top = 112
          Width = 97
          Height = 17
          Caption = 'CheckBox1'
          TabOrder = 2
        end
        object CheckBox2: TCheckBox
          Left = 22
          Top = 135
          Width = 97
          Height = 17
          Caption = 'CheckBox2'
          TabOrder = 3
        end
        object ListBox1: TListBox
          Left = 172
          Top = 30
          Width = 80
          Height = 120
          BorderStyle = bsNone
          ItemHeight = 13
          Items.Strings = (
            'Item 1'
            'Item 2'
            'Item 3'
            'Item 4'
            'Item 5'
            'Item 6'
            'Item 7'
            'Item 8'
            'Item 9')
          TabOrder = 4
        end
        object TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          LayoutDirection = ldHorizontal
          ShowBorder = False
          object dxLayoutControl1Group4: TdxLayoutGroup
            AutoAligns = [aaVertical]
            AlignHorz = ahClient
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object dxLayoutGroup1: TdxLayoutGroup
              AutoAligns = [aaVertical]
              AlignHorz = ahClient
              Caption = 'Group 1'
              object dxLayoutItem1: TdxLayoutItem
                Caption = 'Edit1'
                Control = Edit1
              end
              object dxLayoutControl1Item2: TdxLayoutItem
                Caption = 'Edit2'
                Control = Edit2
              end
            end
            object dxLayoutControl1Group2: TdxLayoutGroup
              Caption = 'Group2'
              object dxLayoutControl1Item3: TdxLayoutItem
                Caption = 'CheckBox1'
                ShowCaption = False
                Control = CheckBox1
                ControlOptions.AutoColor = True
                ControlOptions.ShowBorder = False
              end
              object dxLayoutControl1Item4: TdxLayoutItem
                Caption = 'CheckBox2'
                ShowCaption = False
                Control = CheckBox2
                ControlOptions.AutoColor = True
                ControlOptions.ShowBorder = False
              end
            end
          end
          object dxLayoutControl1Group3: TdxLayoutGroup
            AutoAligns = [aaHorizontal]
            AlignVert = avClient
            Caption = 'Group3'
            object dxLayoutControl1Item5: TdxLayoutItem
              AutoAligns = [aaHorizontal]
              AlignVert = avClient
              Control = ListBox1
            end
          end
        end
      end
    end
    object TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object lcMainGroup4: TdxLayoutGroup
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        ShowCaption = False
        Hidden = True
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object lcMainItem1: TdxLayoutItem
          AutoAligns = []
          AlignHorz = ahClient
          AlignVert = avClient
          Control = lbItems
        end
        object lcMainGroup2: TdxLayoutGroup
          ShowCaption = False
          Hidden = True
          ShowBorder = False
          object lcMainItem2: TdxLayoutItem
            Caption = 'Button1'
            ShowCaption = False
            Control = btnAdd
            ControlOptions.ShowBorder = False
          end
          object lcMainItem3: TdxLayoutItem
            Caption = 'Button2'
            ShowCaption = False
            Control = btnDelete
            ControlOptions.ShowBorder = False
          end
          object lcMainItem4: TdxLayoutItem
            Caption = 'Button3'
            ShowCaption = False
            Control = btnClose
            ControlOptions.ShowBorder = False
          end
        end
      end
      object lcMainGroup3: TdxLayoutGroup
        Caption = 'Preview'
        object lcMainItem6: TdxLayoutItem
          Caption = 'Panel1'
          ShowCaption = False
          Control = pnlPreview
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object lflMain: TdxLayoutLookAndFeelList
    Left = 256
    Top = 116
    object dxLayoutOfficeLookAndFeel1: TdxLayoutOfficeLookAndFeel
    end
  end
end
