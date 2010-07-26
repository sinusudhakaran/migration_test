object LayoutCustomizeForm: TLayoutCustomizeForm
  Left = 219
  Top = 183
  BorderStyle = bsSizeToolWin
  Caption = 'LayoutCustomizeForm'
  ClientHeight = 297
  ClientWidth = 223
  Color = clBtnFace
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object LayoutControl: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 223
    Height = 297
    Align = alClient
    TabOrder = 0
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = lfStandard
    object pcMain: TPageControl
      Left = 4
      Top = 4
      Width = 217
      Height = 241
      ActivePage = tshItems
      TabOrder = 0
      object tshItems: TTabSheet
        Caption = 'Items'
        object lcItems: TdxLayoutControl
          Left = 0
          Top = 0
          Width = 209
          Height = 213
          Align = alClient
          TabOrder = 0
          AutoContentSizes = [acsWidth, acsHeight]
          LookAndFeel = lfStandard
          object lbItems: TListBox
            Left = 6
            Top = 6
            Width = 129
            Height = 145
            Style = lbOwnerDrawFixed
            BorderStyle = bsNone
            Color = clBtnFace
            ItemHeight = 13
            TabOrder = 0
            OnDrawItem = lbItemsDrawItem
            OnMeasureItem = lbItemsMeasureItem
          end
          object lcItemsGroup_Root: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object lcItemsItem1: TdxLayoutItem
              AutoAligns = [aaHorizontal]
              AlignVert = avClient
              Control = lbItems
            end
          end
        end
      end
      object tshGroups: TTabSheet
        Caption = 'Groups'
        ImageIndex = 1
        object lcGroups: TdxLayoutControl
          Left = 0
          Top = 0
          Width = 209
          Height = 213
          Align = alClient
          TabOrder = 0
          AutoContentSizes = [acsWidth, acsHeight]
          LookAndFeel = lfStandard
          object lbGroups: TListBox
            Left = 6
            Top = 6
            Width = 145
            Height = 149
            Style = lbOwnerDrawFixed
            BorderStyle = bsNone
            Color = clBtnFace
            ItemHeight = 13
            TabOrder = 0
            OnClick = lbGroupsClick
            OnDrawItem = lbGroupsDrawItem
            OnMeasureItem = lbGroupsMeasureItem
          end
          object btnGroupsCreate: TButton
            Left = 25
            Top = 234
            Width = 75
            Height = 23
            Caption = 'Create'
            TabOrder = 1
            OnClick = btnGroupsCreateClick
          end
          object btnGroupsDelete: TButton
            Left = 106
            Top = 234
            Width = 75
            Height = 23
            Caption = 'Delete'
            TabOrder = 2
            OnClick = btnGroupsDeleteClick
          end
          object lcGroupsGroup_Root: TdxLayoutGroup
            ShowCaption = False
            Hidden = True
            ShowBorder = False
            object lcGroupsItem1: TdxLayoutItem
              AutoAligns = [aaHorizontal]
              AlignVert = avClient
              Control = lbGroups
            end
            object lcGroupsGroup1: TdxLayoutGroup
              AutoAligns = [aaVertical]
              AlignHorz = ahCenter
              ShowCaption = False
              Hidden = True
              LayoutDirection = ldHorizontal
              ShowBorder = False
              object lcGroupsItem4: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = 'Button1'
                ShowCaption = False
                Control = btnGroupsCreate
                ControlOptions.ShowBorder = False
              end
              object lcGroupsItem2: TdxLayoutItem
                AutoAligns = [aaVertical]
                AlignHorz = ahClient
                Caption = 'Button2'
                ShowCaption = False
                Control = btnGroupsDelete
                ControlOptions.ShowBorder = False
              end
            end
          end
        end
      end
    end
    object LayoutControlGroup_Root: TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object LayoutControlItem1: TdxLayoutItem
        AutoAligns = [aaHorizontal]
        AlignVert = avClient
        Control = pcMain
        ControlOptions.ShowBorder = False
      end
    end
  end
  object LookAndFeels: TdxLayoutLookAndFeelList
    Left = 154
    Top = 66
    object lfStandard: TdxLayoutStandardLookAndFeel
      ItemOptions.ControlBorderStyle = lbsFlat
      Offsets.RootItemsAreaOffsetHorz = 3
      Offsets.RootItemsAreaOffsetVert = 3
    end
  end
end
