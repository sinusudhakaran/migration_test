object WPTabDialog: TWPTabDialog
  Left = 284
  Top = 148
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsDialog
  Caption = 'Tabs'
  ClientHeight = 387
  ClientWidth = 487
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 120
  TextHeight = 16
  object Bevel2: TBevel
    Left = 16
    Top = 56
    Width = 457
    Height = 241
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = 16
    Top = 304
    Width = 193
    Height = 73
    Shape = bsFrame
  end
  object labDefaultTab: TLabel
    Left = 23
    Top = 318
    Width = 125
    Height = 16
    AutoSize = False
    Caption = 'Default tabstop:'
  end
  object gbxTabStop: TLabel
    Left = 16
    Top = 11
    Width = 56
    Height = 16
    Caption = 'Tab Stop'
  end
  object TabList: TListBox
    Left = 24
    Top = 64
    Width = 145
    Height = 145
    Style = lbOwnerDrawFixed
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
    OnClick = TabListClick
    OnDrawItem = TabListDrawItem
  end
  object btnDelete: TBitBtn
    Left = 370
    Top = 139
    Width = 93
    Height = 25
    Caption = '&Delete'
    Enabled = False
    TabOrder = 1
    OnClick = btnDeleteClick
  end
  object btnDeleteAll: TBitBtn
    Left = 370
    Top = 179
    Width = 93
    Height = 25
    Caption = 'Delete &All'
    Enabled = False
    TabOrder = 2
    OnClick = btnDeleteAllClick
  end
  object btnOk: TButton
    Left = 279
    Top = 350
    Width = 93
    Height = 25
    Caption = '&Ok'
    Default = True
    TabOrder = 4
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 376
    Top = 350
    Width = 93
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object AlignmentGroup: TRadioGroup
    Left = 184
    Top = 64
    Width = 161
    Height = 145
    Caption = ' Alignment '
    Items.Strings = (
      '&Left'
      '&Right'
      '&Center'
      '&Decimal'
      '&Bar')
    TabOrder = 3
    OnClick = AlignmentGroupClick
  end
  object veTabDefault: TWPValueEdit
    Left = 87
    Top = 337
    Width = 110
    Height = 26
    AvailableUnits = [euInch, euCm]
    UnitType = euCm
    OnUnitChange = veInsertTabUnitChange
    TabOrder = 6
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object btnInsert: TBitBtn
    Left = 196
    Top = 11
    Width = 93
    Height = 25
    Caption = '&Insert'
    TabOrder = 7
    OnClick = btnInsertClick
  end
  object veInsertTab: TWPValueEdit
    Left = 90
    Top = 11
    Width = 95
    Height = 26
    AvailableUnits = [euInch, euCm]
    UnitType = euCm
    OnUnitChange = veInsertTabUnitChange
    TabOrder = 8
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnChange = veInsertTabChange
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object TabFillGroup: TRadioGroup
    Left = 24
    Top = 216
    Width = 441
    Height = 73
    Caption = ' Fill  '
    Columns = 4
    Items.Strings = (
      '&1 none'
      '&2 .....'
      '&3 ..... (middle)'
      '&4 - - - - - '
      '&5 ______'
      '&6 - - - - (thick)'
      '&7 = = = = = = '
      '&8 ------->')
    TabOrder = 9
    OnClick = TabFillGroupClick
  end
end
