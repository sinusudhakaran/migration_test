object frmdxSideBarEditor: TfrmdxSideBarEditor
  Left = 245
  Top = 126
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'ExpressSideBar Editor: '
  ClientHeight = 367
  ClientWidth = 545
  Color = clBtnFace
  OldCreateOrder = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 125
    Height = 367
    Align = alLeft
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object Bar: TdxSideBar
      Left = 4
      Top = 4
      Width = 117
      Height = 359
      Align = alClient
      BkGround.BeginColor = clGray
      BkGround.EndColor = clGray
      Color = clGray
      CanSelected = True
      GroupFont.Charset = DEFAULT_CHARSET
      GroupFont.Color = clWindowText
      GroupFont.Height = -11
      GroupFont.Name = 'MS Sans Serif'
      GroupFont.Style = []
      Groups = <>
      ActiveGroupIndex = 0
      GroupPopupMenu = AutoOutLookPopupMenu1
      ItemFont.Charset = DEFAULT_CHARSET
      ItemFont.Color = clWhite
      ItemFont.Height = -11
      ItemFont.Name = 'MS Sans Serif'
      ItemFont.Style = []
      ItemPopupMenu = AutoOutLookPopupMenu1
      OnChangeActiveGroup = BarChangeActiveGroup
      OnChangeSelectedItem = BarChangeSelectedItem
      DragMode = dmAutomatic
    end
  end
  object Panel1: TPanel
    Left = 125
    Top = 0
    Width = 420
    Height = 367
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Panel2: TPanel
      Left = 0
      Top = 340
      Width = 420
      Height = 27
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      object BOk: TButton
        Left = 157
        Top = 4
        Width = 80
        Height = 21
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 1
        OnClick = BOkClick
      end
      object BCancel: TButton
        Left = 248
        Top = 4
        Width = 80
        Height = 21
        Cancel = True
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 2
        OnClick = BCancelClick
      end
      object bHelp: TButton
        Left = 336
        Top = 4
        Width = 80
        Height = 21
        Caption = 'Help'
        TabOrder = 3
      end
      object BDefault: TButton
        Left = 8
        Top = 3
        Width = 80
        Height = 21
        Caption = 'Default'
        TabOrder = 0
        OnClick = BDefaultClick
      end
    end
    object BIAdd: TButton
      Left = 6
      Top = 289
      Width = 80
      Height = 21
      Caption = 'Add'
      TabOrder = 1
      OnClick = BIAddClick
    end
    object BIInsert: TButton
      Left = 6
      Top = 313
      Width = 80
      Height = 21
      Caption = 'Insert'
      TabOrder = 2
      OnClick = BIInsertClick
    end
    object BIDelete: TButton
      Left = 89
      Top = 289
      Width = 80
      Height = 21
      Caption = 'Delete'
      TabOrder = 3
      OnClick = BIDeleteClick
    end
    object BIClear: TButton
      Left = 89
      Top = 312
      Width = 80
      Height = 21
      Caption = 'Clear'
      TabOrder = 4
      OnClick = BIClearClick
    end
    object BIMoveUp: TButton
      Left = 174
      Top = 289
      Width = 80
      Height = 21
      Caption = 'Move Up'
      TabOrder = 5
      OnClick = BIMoveUpClick
    end
    object BIMovedown: TButton
      Left = 174
      Top = 312
      Width = 80
      Height = 21
      Caption = 'Move down'
      TabOrder = 6
      OnClick = BIMovedownClick
    end
    object GGroup: TGroupBox
      Left = 8
      Top = 1
      Width = 408
      Height = 72
      Caption = 'Groups'
      TabOrder = 7
      object LIconType: TLabel
        Left = 272
        Top = 21
        Width = 48
        Height = 13
        Caption = 'Icon Type'
      end
      object BGAdd: TButton
        Left = 6
        Top = 18
        Width = 80
        Height = 21
        Caption = 'Add'
        TabOrder = 0
        OnClick = BGAddClick
      end
      object BGDelete: TButton
        Left = 91
        Top = 18
        Width = 80
        Height = 21
        Caption = 'Delete'
        TabOrder = 1
        OnClick = BGDeleteClick
      end
      object BGRename: TButton
        Left = 177
        Top = 18
        Width = 80
        Height = 21
        Caption = 'Rename'
        TabOrder = 2
        OnClick = BGRenameClick
      end
      object CBGIType: TCheckBox
        Left = 338
        Top = 20
        Width = 65
        Height = 17
        Caption = 'Large'
        Checked = True
        State = cbChecked
        TabOrder = 3
        OnClick = CBGITypeClick
      end
      object BGUp: TButton
        Left = 6
        Top = 42
        Width = 80
        Height = 21
        Caption = 'Move Up'
        TabOrder = 4
        OnClick = BGUpClick
      end
      object BGDown: TButton
        Left = 91
        Top = 42
        Width = 80
        Height = 21
        Caption = 'Move Down'
        TabOrder = 5
        OnClick = BGDownClick
      end
      object cbGroupVisible: TCheckBox
        Left = 274
        Top = 46
        Width = 122
        Height = 17
        Caption = 'Visible'
        TabOrder = 6
        OnClick = cbGroupVisibleClick
      end
    end
    object GItemProp: TGroupBox
      Left = 8
      Top = 80
      Width = 245
      Height = 205
      Caption = 'Item properties'
      TabOrder = 8
      object LCustomData: TLabel
        Left = 6
        Top = 19
        Width = 61
        Height = 13
        Caption = 'Custom Data'
      end
      object LTag: TLabel
        Left = 7
        Top = 43
        Width = 19
        Height = 13
        Caption = 'Tag'
      end
      object LSILarge: TLabel
        Left = 5
        Top = 117
        Width = 38
        Height = 29
        AutoSize = False
        Caption = 'Large Image'
        WordWrap = True
      end
      object LSISmall: TLabel
        Left = 126
        Top = 119
        Width = 38
        Height = 29
        AutoSize = False
        Caption = 'Small Image'
        WordWrap = True
      end
      object LCaption: TLabel
        Left = 7
        Top = 72
        Width = 36
        Height = 13
        Caption = 'Caption'
      end
      object Bevel1: TBevel
        Left = 7
        Top = 64
        Width = 231
        Height = 2
      end
      object LHint: TLabel
        Left = 7
        Top = 96
        Width = 19
        Height = 13
        Caption = 'Hint'
      end
      object ECustomData: TEdit
        Left = 91
        Top = 17
        Width = 147
        Height = 21
        TabOrder = 0
        OnExit = ECustomDataExit
      end
      object ETag: TEdit
        Left = 91
        Top = 40
        Width = 147
        Height = 21
        TabOrder = 1
        OnExit = ETagExit
        OnKeyPress = ETagKeyPress
      end
      object SILarge: TdxSpinImage
        Left = 45
        Top = 119
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
        OnChange = SILargeChange
        ParentColor = True
        TabOrder = 4
      end
      object SISmall: TdxSpinImage
        Left = 169
        Top = 119
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
        OnChange = SISmallChange
        ParentColor = True
        TabOrder = 5
      end
      object ECaption: TEdit
        Left = 69
        Top = 69
        Width = 169
        Height = 21
        TabOrder = 2
        OnChange = ECaptionChange
      end
      object BIDefault: TButton
        Left = 7
        Top = 178
        Width = 233
        Height = 22
        Caption = 'Set default item properties'
        TabOrder = 6
        OnClick = BIDefaultClick
      end
      object EHint: TEdit
        Left = 69
        Top = 93
        Width = 169
        Height = 21
        TabOrder = 3
        OnChange = EHintChange
      end
    end
    object GStoredItems: TGroupBox
      Left = 256
      Top = 80
      Width = 161
      Height = 258
      Caption = 'Stored Items'
      TabOrder = 9
      object CBStoredGroup: TComboBox
        Left = 3
        Top = 13
        Width = 154
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnClick = CBStoredGroupClick
      end
      object LBStoredItems: TdxImageListBox
        Left = 4
        Top = 38
        Width = 152
        Height = 213
        Alignment = taLeftJustify
        ImageAlign = dxliLeft
        ItemHeight = 0
        MultiLines = True
        VertAlignment = tvaCenter
        DragMode = dmAutomatic
        TabOrder = 1
        OnDragDrop = LBStoredItemsDragDrop
        OnDragOver = LBStoredItemsDragOver
        OnEndDrag = LBStoredItemsEndDrag
        OnStartDrag = LBStoredItemsStartDrag
        SaveStrings = ()
      end
    end
  end
  object AutoOutLookPopupMenu1: TdxSideBarPopupMenu
    Options = [sbmIconType, sbmAddGroup, sbmRemoveGroup, sbmRenameGroup, sbmRenameItem, sbmRemoveItem]
    Left = 69
    Top = 120
  end
end
