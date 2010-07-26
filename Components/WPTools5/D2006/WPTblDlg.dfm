object WPTableDialog: TWPTableDialog
  Left = 76
  Top = 115
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Insert Table'
  ClientHeight = 194
  ClientWidth = 430
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object labColumns: TLabel
    Left = 30
    Top = 22
    Width = 120
    Height = 16
    Alignment = taRightJustify
    Caption = 'Number of Columns:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object labRows: TLabel
    Left = 48
    Top = 55
    Width = 102
    Height = 16
    Alignment = taRightJustify
    Caption = 'Number of Rows:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object ShowBord: TSpeedButton
    Left = 247
    Top = 18
    Width = 31
    Height = 31
    AllowAllUp = True
    GroupIndex = 1
    Down = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
      FFFFF00000000000000FF00000000000000FF00FF0FFFFFFFFFFF00FFF03FFFF
      FFFFF00FFF3B0FFFFFFFF00FFFF3B3FFFFFFF00FFFFF3B0FFFFFF00FFFFFF393
      FFFFF00FFFFFFF390FFFF00FFFFFFFF3B3FFF00FFFFFFFFF3B0FF00FFFFFFFFF
      F3B3F00FFFFFFFFFFF30F00FFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
    Visible = False
  end
  object labAlignment: TLabel
    Left = 50
    Top = 84
    Width = 100
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Alignment'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object labWidth: TLabel
    Left = 80
    Top = 137
    Width = 70
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Width:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object labBorder: TLabel
    Left = 80
    Top = 107
    Width = 70
    Height = 16
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Border:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object btnOk: TButton
    Left = 315
    Top = 20
    Width = 92
    Height = 30
    Caption = '&Ok'
    Default = True
    TabOrder = 0
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 315
    Top = 63
    Width = 92
    Height = 31
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object seColumns: TWPValueEdit
    Left = 158
    Top = 20
    Width = 86
    Height = 26
    AvailableUnits = []
    UnitType = euTwips
    TabOrder = 2
    MaxLength = 3
    OnChange = seColumnsChange
    AllowNegative = False
    Value = 2
    IntValue = 2
    Undefined = False
  end
  object seRows: TWPValueEdit
    Left = 158
    Top = 50
    Width = 86
    Height = 26
    AvailableUnits = []
    UnitType = euTwips
    TabOrder = 3
    MaxLength = 3
    OnChange = seColumnsChange
    AllowNegative = False
    Value = 2
    IntValue = 2
    Undefined = False
  end
  object CmbBxAlignment: TComboBox
    Left = 158
    Top = 82
    Width = 86
    Height = 19
    Style = csOwnerDrawFixed
    ItemHeight = 13
    TabOrder = 4
    Items.Strings = (
      'Center'
      'Left'
      'Right')
  end
  object CmbBxBorder: TComboBox
    Left = 158
    Top = 106
    Width = 86
    Height = 19
    Style = csOwnerDrawFixed
    ItemHeight = 13
    TabOrder = 5
    Items.Strings = (
      'Yes'
      'No')
  end
  object seWidth: TWPValueEdit
    Left = 158
    Top = 135
    Width = 86
    Height = 26
    AvailableUnits = []
    UnitType = euPercent
    TabOrder = 6
    MaxLength = 3
    OnChange = seWidthChange
    AllowNegative = False
    Value = 100
    IntValue = 100
    Undefined = False
  end
  object cbNestTable: TCheckBox
    Left = 25
    Top = 169
    Width = 152
    Height = 16
    Alignment = taLeftJustify
    Caption = 'Create nested Table'
    TabOrder = 7
    Visible = False
  end
end
