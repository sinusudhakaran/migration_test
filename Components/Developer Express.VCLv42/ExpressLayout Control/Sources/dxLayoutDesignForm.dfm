object DesignForm: TDesignForm
  Left = 423
  Top = 176
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  ClientHeight = 291
  ClientWidth = 306
  Color = clBtnFace
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lcMain: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 306
    Height = 291
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth, acsHeight]
    LookAndFeel = lfStandard
    object lbItems: TListBox
      Left = 8
      Top = 8
      Width = 173
      Height = 245
      Style = lbOwnerDrawFixed
      BorderStyle = bsNone
      ItemHeight = 13
      MultiSelect = True
      TabOrder = 0
      OnDrawItem = lbItemsDrawItem
    end
    object btnAddGroup: TButton
      Left = 191
      Top = 6
      Width = 85
      Height = 23
      Caption = 'Add Group...'
      TabOrder = 1
      OnClick = btnAddGroupClick
    end
    object btnAddItem: TButton
      Left = 191
      Top = 35
      Width = 85
      Height = 23
      Caption = 'Add Item...'
      TabOrder = 2
      OnClick = btnAddItemClick
    end
    object btnDelete: TButton
      Left = 191
      Top = 64
      Width = 85
      Height = 23
      Caption = 'Delete'
      TabOrder = 3
    end
    object btnClose: TButton
      Left = 191
      Top = 262
      Width = 85
      Height = 23
      Cancel = True
      Caption = 'Close'
      Default = True
      TabOrder = 6
      OnClick = btnCloseClick
    end
    object btnAlign: TButton
      Left = 191
      Top = 93
      Width = 109
      Height = 23
      Caption = 'Align by...'
      TabOrder = 4
      OnClick = btnAlignClick
    end
    object chbShowHiddenGroupsBounds: TCheckBox
      Left = 191
      Top = 122
      Width = 7
      Height = 26
      TabOrder = 5
      OnClick = chbShowHiddenGroupsBoundsClick
    end
    object TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      LayoutDirection = ldHorizontal
      ShowBorder = False
      object dxLayoutControl1Item1: TdxLayoutItem
        AutoAligns = []
        AlignHorz = ahClient
        AlignVert = avClient
        Control = lbItems
      end
      object dxLayoutControl1Group2: TdxLayoutGroup
        ShowCaption = False
        Hidden = True
        ShowBorder = False
        object dxLayoutControl1Item2: TdxLayoutItem
          Caption = 'Button1'
          ShowCaption = False
          Control = btnAddGroup
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item3: TdxLayoutItem
          Caption = 'Button2'
          ShowCaption = False
          Control = btnAddItem
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item4: TdxLayoutItem
          Caption = 'Button3'
          ShowCaption = False
          Control = btnDelete
          ControlOptions.ShowBorder = False
        end
        object lcMainItem1: TdxLayoutItem
          Caption = 'Button1'
          ShowCaption = False
          Control = btnAlign
          ControlOptions.ShowBorder = False
        end
        object lcMainItem4: TdxLayoutItem
          Caption = 'Show Hidden Groups Bounds'
          CaptionOptions.Layout = clRight
          CaptionOptions.Width = 96
          OnCaptionClick = lcMainItem4CaptionClick
          Control = chbShowHiddenGroupsBounds
          ControlOptions.ShowBorder = False
        end
        object lcMainGroup1: TdxLayoutGroup
          AutoAligns = [aaHorizontal]
          Caption = 'Legend'
          LookAndFeel = lfStandardLegend
          object lcMainItem2: TdxLayoutItem
            Caption = 'Actually Invisible Group/Item'
            CaptionOptions.Width = 80
            LookAndFeel = lfStandardBtnFace
          end
          object lcMainItem3: TdxLayoutItem
            Caption = 'Hidden Group '
            LookAndFeel = lfStandardBoldItalic
          end
        end
        object dxLayoutControl1Item5: TdxLayoutItem
          AutoAligns = [aaHorizontal]
          AlignVert = avBottom
          Caption = 'Button4'
          ShowCaption = False
          Control = btnClose
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
  object lflMain: TdxLayoutLookAndFeelList
    Left = 164
    Top = 24
    object lfStandard: TdxLayoutStandardLookAndFeel
      Offsets.RootItemsAreaOffsetHorz = 4
      Offsets.RootItemsAreaOffsetVert = 4
    end
    object lfStandardBtnFace: TdxLayoutStandardLookAndFeel
      ItemOptions.CaptionOptions.TextColor = clBtnFace
    end
    object lfStandardBoldItalic: TdxLayoutStandardLookAndFeel
      ItemOptions.CaptionOptions.Font.Charset = DEFAULT_CHARSET
      ItemOptions.CaptionOptions.Font.Color = clWindowText
      ItemOptions.CaptionOptions.Font.Height = -11
      ItemOptions.CaptionOptions.Font.Name = 'MS Sans Serif'
      ItemOptions.CaptionOptions.Font.Style = [fsBold, fsItalic]
      ItemOptions.CaptionOptions.UseDefaultFont = False
    end
    object lfStandardLegend: TdxLayoutStandardLookAndFeel
      GroupOptions.Color = clInfoBk
    end
  end
  object pmAlign: TPopupMenu
    Left = 272
    Top = 224
    object Left1: TMenuItem
      Caption = 'Left Side'
      OnClick = pmAlignItemClick
    end
    object Right1: TMenuItem
      Tag = 2
      Caption = 'Right Side'
      OnClick = pmAlignItemClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object op1: TMenuItem
      Tag = 1
      Caption = 'Top Side'
      OnClick = pmAlignItemClick
    end
    object Bottom1: TMenuItem
      Tag = 3
      Caption = 'Bottom Side'
      OnClick = pmAlignItemClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object None1: TMenuItem
      Tag = -1
      Caption = 'None'
      OnClick = pmAlignItemClick
    end
  end
end
