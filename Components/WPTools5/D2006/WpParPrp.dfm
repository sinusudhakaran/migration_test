object WPParagraphProp: TWPParagraphProp
  Left = 151
  Top = 160
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Paragraph Format'
  ClientHeight = 390
  ClientWidth = 487
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 120
  TextHeight = 16
  object Bevel3: TBevel
    Left = 8
    Top = 8
    Width = 468
    Height = 328
    Shape = bsFrame
  end
  object Bevel1: TBevel
    Left = 97
    Top = 55
    Width = 369
    Height = 7
    Shape = bsTopLine
  end
  object labFirst: TLabel
    Left = 246
    Top = 74
    Width = 53
    Height = 16
    Caption = 'First Line'
    FocusControl = FirstIndent
    Transparent = True
  end
  object labLeft: TLabel
    Left = 38
    Top = 74
    Width = 21
    Height = 16
    Caption = 'Left'
    FocusControl = LeftIndent
    Transparent = True
  end
  object labRight: TLabel
    Left = 38
    Top = 106
    Width = 31
    Height = 16
    Caption = 'Right'
    FocusControl = RightIndent
    Transparent = True
  end
  object labBefore: TLabel
    Left = 38
    Top = 159
    Width = 40
    Height = 16
    Caption = 'Before'
    FocusControl = SpacingBefore
    Transparent = True
  end
  object labLinespacing: TLabel
    Left = 248
    Top = 162
    Width = 73
    Height = 16
    Caption = 'Linespacing'
    FocusControl = SpacingType
    Transparent = True
  end
  object labAfter: TLabel
    Left = 38
    Top = 194
    Width = 27
    Height = 16
    Caption = 'After'
    FocusControl = SpacingAfter
    Transparent = True
  end
  object labAlignment: TLabel
    Left = 38
    Top = 18
    Width = 59
    Height = 16
    Caption = 'Alignment'
    FocusControl = cbxAlignment
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object Bevel2: TBevel
    Left = 97
    Top = 137
    Width = 369
    Height = 6
    Shape = bsTopLine
  end
  object labValue: TLabel
    Left = 364
    Top = 162
    Width = 35
    Height = 16
    Caption = 'Value'
    FocusControl = SpacingBetween
    Transparent = True
  end
  object labSpacing: TLabel
    Left = 22
    Top = 129
    Width = 50
    Height = 16
    Caption = 'Spacing'
    Transparent = True
  end
  object labIndent: TLabel
    Left = 22
    Top = 48
    Width = 65
    Height = 16
    Caption = 'Indentation'
    Transparent = True
  end
  object RichBevel: TBevel
    Left = 32
    Top = 224
    Width = 425
    Height = 97
    Visible = False
  end
  object Label1: TLabel
    Left = 238
    Top = 18
    Width = 77
    Height = 16
    Caption = 'Outline Level'
    FocusControl = cbxAlignment
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = True
  end
  object FirstIndent: TWPValueEdit
    Left = 362
    Top = 68
    Width = 94
    Height = 26
    AvailableUnits = [euInch, euCm, euPt]
    UnitType = euCm
    OnUnitChange = SpacingBetweenUnitChange
    Ctl3D = True
    TabOrder = 2
    ParentCtl3D = False
    OnChange = UpdateExample
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object LeftIndent: TWPValueEdit
    Left = 131
    Top = 68
    Width = 94
    Height = 26
    AvailableUnits = [euInch, euCm, euPt]
    UnitType = euCm
    OnUnitChange = SpacingBetweenUnitChange
    Ctl3D = True
    TabOrder = 1
    ParentCtl3D = False
    OnChange = UpdateExample
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object RightIndent: TWPValueEdit
    Left = 131
    Top = 100
    Width = 94
    Height = 26
    AvailableUnits = [euInch, euCm, euPt]
    UnitType = euCm
    OnUnitChange = SpacingBetweenUnitChange
    Ctl3D = True
    TabOrder = 3
    ParentCtl3D = False
    OnChange = UpdateExample
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object SpacingBefore: TWPValueEdit
    Left = 131
    Top = 153
    Width = 94
    Height = 26
    AvailableUnits = [euInch, euCm, euPt]
    UnitType = euCm
    OnUnitChange = SpacingBetweenUnitChange
    Ctl3D = True
    TabOrder = 4
    ParentCtl3D = False
    OnChange = UpdateExample
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object SpacingAfter: TWPValueEdit
    Left = 131
    Top = 188
    Width = 94
    Height = 26
    AvailableUnits = [euInch, euCm, euPt]
    UnitType = euCm
    OnUnitChange = SpacingBetweenUnitChange
    Ctl3D = True
    TabOrder = 5
    ParentCtl3D = False
    OnChange = UpdateExample
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object SpacingBetween: TWPValueEdit
    Left = 362
    Top = 188
    Width = 94
    Height = 26
    AvailableUnits = [euInch, euCm, euPt]
    UnitType = euCm
    OnUnitChange = SpacingBetweenUnitChange
    Ctl3D = True
    TabOrder = 7
    ParentCtl3D = False
    OnChange = UpdateExample
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object SpacingType: TComboBox
    Left = 247
    Top = 188
    Width = 93
    Height = 24
    Style = csDropDownList
    ItemHeight = 16
    TabOrder = 6
    OnChange = UpdateExample
    OnClick = SpacingTypeClick
    Items.Strings = (
      ''
      'multiple'
      'at least'
      'exactly')
  end
  object ButOK: TButton
    Left = 287
    Top = 348
    Width = 93
    Height = 30
    Caption = 'OK'
    Default = True
    TabOrder = 10
    OnClick = ButOKClick
  end
  object ButCancel: TButton
    Left = 386
    Top = 348
    Width = 92
    Height = 30
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 9
  end
  object ButUpdate: TButton
    Left = 106
    Top = 348
    Width = 92
    Height = 30
    Caption = 'Apply'
    TabOrder = 8
    OnClick = ButUpdateClick
  end
  object cbxAlignment: TComboBox
    Left = 131
    Top = 16
    Width = 94
    Height = 24
    Style = csDropDownList
    ItemHeight = 16
    TabOrder = 0
    OnChange = UpdateExample
    Items.Strings = (
      ''
      'Left'
      'Center'
      'Right'
      'Justified')
  end
  object ButOpenTabs: TButton
    Left = 10
    Top = 348
    Width = 92
    Height = 30
    Caption = 'Tabstops...'
    TabOrder = 11
    OnClick = ButOpenTabsClick
  end
  object cbxOutlineLevel: TComboBox
    Left = 360
    Top = 16
    Width = 97
    Height = 24
    Style = csDropDownList
    ItemHeight = 16
    TabOrder = 12
    Items.Strings = (
      'Body'
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9')
  end
end
