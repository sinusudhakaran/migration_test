object frmSideBarStoreEditor: TfrmSideBarStoreEditor
  Left = 306
  Top = 100
  Width = 554
  Height = 368
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'SideBarStore Editor:'
  Color = clBtnFace
  OldCreateOrder = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 239
    Width = 546
    Height = 95
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object LItemCaption: TLabel
      Left = 197
      Top = 19
      Width = 36
      Height = 13
      Caption = 'Caption'
    end
    object LLImage: TLabel
      Left = 3
      Top = 5
      Width = 59
      Height = 13
      Caption = 'Large Image'
    end
    object LSImage: TLabel
      Left = 107
      Top = 5
      Width = 57
      Height = 13
      Caption = 'Small Image'
    end
    object LItemHint: TLabel
      Left = 199
      Top = 46
      Width = 19
      Height = 13
      Caption = 'Hint'
    end
    object EItemCaption: TEdit
      Tag = 2
      Left = 265
      Top = 18
      Width = 177
      Height = 24
      TabOrder = 2
      Anchors = [akLeft, akTop, akRight]
      OnExit = EItemCaptionExit
    end
    object BClose: TButton
      Left = 267
      Top = 70
      Width = 87
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Close'
      TabOrder = 4
      OnClick = BCloseClick
    end
    object BHelp: TButton
      Left = 360
      Top = 70
      Width = 80
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Help'
      TabOrder = 5
    end
    object SILImage: TdxSpinImage
      Left = 4
      Top = 19
      Width = 70
      Height = 54
      AutoSize = False
      BorderStyle = bsSingle
      DefaultImages = True
      ImageHAlign = hsiCenter
      ImageVAlign = vsiCenter
      Items = <>
      ItemIndex = -1
      ReadOnly = False
      Stretch = True
      UpDownAlign = udaRight
      UpDownOrientation = siVertical
      UpDownWidth = 16
      UseDblClick = True
      OnChange = SIImageChange
      ParentColor = True
      TabOrder = 0
    end
    object SISImage: TdxSpinImage
      Left = 107
      Top = 20
      Width = 70
      Height = 54
      AutoSize = False
      BorderStyle = bsSingle
      DefaultImages = True
      ImageHAlign = hsiCenter
      ImageVAlign = vsiCenter
      Items = <>
      ItemIndex = -1
      ReadOnly = False
      Stretch = True
      UpDownAlign = udaRight
      UpDownOrientation = siVertical
      UpDownWidth = 16
      UseDblClick = True
      OnChange = SISImageChange
      ParentColor = True
      TabOrder = 1
    end
    object EItemHint: TEdit
      Tag = 2
      Left = 266
      Top = 44
      Width = 175
      Height = 24
      TabOrder = 3
      Anchors = [akLeft, akTop, akRight]
      OnExit = EItemHintExit
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 90
    Height = 239
    Align = alLeft
    BevelInner = bvLowered
    BevelOuter = bvNone
    TabOrder = 1
    object ListBox: TListBox
      Left = 1
      Top = 1
      Width = 88
      Height = 237
      Align = alClient
      ItemHeight = 13
      TabOrder = 0
      OnClick = ListBoxClick
      OnDragOver = ListBoxDragOver
    end
  end
  object Panel3: TPanel
    Left = 90
    Top = 0
    Width = 456
    Height = 239
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 108
      Height = 239
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object GBGroups: TGroupBox
        Left = 0
        Top = 0
        Width = 108
        Height = 239
        Align = alClient
        Caption = 'Categories'
        TabOrder = 0
        object BGAdd: TButton
          Left = 5
          Top = 17
          Width = 96
          Height = 21
          Caption = 'Add ...'
          TabOrder = 0
          OnClick = BGAddClick
        end
        object BGInsert: TButton
          Left = 5
          Top = 40
          Width = 96
          Height = 21
          Caption = 'Insert ...'
          TabOrder = 1
          OnClick = BGInsertClick
        end
        object BGDelete: TButton
          Left = 5
          Top = 63
          Width = 96
          Height = 21
          Caption = 'Delete'
          TabOrder = 2
          OnClick = BGDeleteClick
        end
        object BGRename: TButton
          Left = 5
          Top = 86
          Width = 96
          Height = 21
          Caption = 'Rename ...'
          TabOrder = 3
          OnClick = BGRenameClick
        end
        object BGMoveUp: TButton
          Left = 6
          Top = 110
          Width = 94
          Height = 21
          Caption = 'Move Up'
          TabOrder = 4
          OnClick = BGMoveUpClick
        end
        object BGMoveDown: TButton
          Left = 6
          Top = 134
          Width = 94
          Height = 21
          Caption = 'Move Down'
          TabOrder = 5
          OnClick = BGMoveDownClick
        end
      end
    end
    object Panel5: TPanel
      Left = 342
      Top = 0
      Width = 114
      Height = 239
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 2
      object GBItems: TGroupBox
        Left = 0
        Top = 0
        Width = 114
        Height = 239
        Align = alClient
        Caption = 'Items'
        TabOrder = 0
        object BIAdd: TButton
          Left = 5
          Top = 17
          Width = 105
          Height = 21
          Caption = 'Add'
          TabOrder = 0
          OnClick = BIAddClick
        end
        object BIDelete: TButton
          Left = 5
          Top = 40
          Width = 105
          Height = 21
          Caption = 'Delete'
          TabOrder = 1
          OnClick = BIDeleteClick
        end
        object BIClear: TButton
          Left = 5
          Top = 63
          Width = 105
          Height = 21
          Caption = 'Clear'
          TabOrder = 2
          OnClick = BIClearClick
        end
        object BIMoveUp: TButton
          Left = 6
          Top = 87
          Width = 103
          Height = 21
          Caption = 'Move Up'
          TabOrder = 3
          OnClick = BIMoveUpClick
        end
        object BIMoveDown: TButton
          Left = 7
          Top = 110
          Width = 103
          Height = 21
          Caption = 'Move Down'
          TabOrder = 4
          OnClick = BIMoveDownClick
        end
      end
    end
    object ImageListBox: TdxImageListBox
      Left = 108
      Top = 0
      Width = 234
      Height = 239
      Alignment = taLeftJustify
      ImageAlign = dxliLeft
      ItemHeight = 0
      MultiLines = True
      VertAlignment = tvaCenter
      Align = alClient
      DragMode = dmAutomatic
      TabOrder = 1
      OnClick = ImageListBoxClick
      OnDragOver = ImageListBoxDragOver
      OnEndDrag = ImageListBoxEndDrag
      SaveStrings = ()
    end
  end
end
