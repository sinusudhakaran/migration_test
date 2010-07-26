object WPBulletStyleDialog: TWPBulletStyleDialog
  Left = 52
  Top = 165
  BorderStyle = bsDialog
  Caption = 'Edit NumberStyle'
  ClientHeight = 274
  ClientWidth = 315
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = SelectFontChange
  PixelsPerInch = 120
  TextHeight = 16
  object labType: TLabel
    Left = 17
    Top = 15
    Width = 32
    Height = 16
    Caption = 'Type'
  end
  object labTextB: TLabel
    Left = 17
    Top = 106
    Width = 69
    Height = 16
    Caption = 'Text Before'
  end
  object labTextA: TLabel
    Left = 17
    Top = 137
    Width = 56
    Height = 16
    Caption = 'Text After'
  end
  object Label2: TLabel
    Left = 17
    Top = 45
    Width = 26
    Height = 16
    Caption = 'Font'
  end
  object labIndent: TLabel
    Left = 17
    Top = 167
    Width = 36
    Height = 16
    Caption = 'Indent'
  end
  object btnSelectFont: TSpeedButton
    Left = 273
    Top = 41
    Width = 24
    Height = 24
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00000000000000
      00000BBBBBB00AAAAAA00BBBBBB00AAAAAA00BBBBBB00AAAAAA00BBBBBB00AAA
      AAA00BBBBBB00AAAAAA00BBBBBB00AAAAAA00000000000000000000000000000
      0000099999900CCCCCC0099999900CCCCCC0099999900CCCCCC0099999900CCC
      CCC0099999900CCCCCC0099999900CCCCCC00000000000000000}
    OnClick = btnSelectFontClick
  end
  object btnSelectSymbol: TSpeedButton
    Left = 273
    Top = 99
    Width = 24
    Height = 24
    Flat = True
    Glyph.Data = {
      F6000000424DF600000000000000760000002800000010000000100000000100
      0400000000008000000000000000000000001000000000000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
      8888888880000008888888880FFFFFF088888880FFFFFFFF0888880FFFFFFFFF
      F08880FFFFFFFFFFF08880FF00F00F00FF0880FF00F00F00FF0880FFFFFFFFFF
      FF0880FFFFFFFFFFFF0880FFFFFFFFFFF088880FFFFFFFFFF0888880FFFFFFFF
      088888880FFFFFF0888888888000000888888888888888888888}
    OnClick = btnSelectSymbolClick
  end
  object labFontSize: TLabel
    Left = 17
    Top = 76
    Width = 26
    Height = 16
    Caption = 'Size'
  end
  object SelectType: TComboBox
    Left = 149
    Top = 11
    Width = 148
    Height = 24
    Style = csDropDownList
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 0
    OnChange = SelectTypeChange
    Items.Strings = (
      ' '
      '*'
      '+'
      '1 2 3'
      'I II III IV'
      'i ii iii iv'
      'A B C'
      'a b c')
  end
  object SelectFont: TComboBox
    Left = 149
    Top = 41
    Width = 118
    Height = 24
    ItemHeight = 16
    TabOrder = 1
    Text = 'cmFont'
    OnChange = SelectFontChange
  end
  object EditTextB: TEdit
    Left = 149
    Top = 99
    Width = 118
    Height = 24
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object EditTextA: TEdit
    Left = 149
    Top = 130
    Width = 148
    Height = 24
    TabOrder = 4
  end
  object CheckUsePrev: TCheckBox
    Left = 17
    Top = 198
    Width = 201
    Height = 21
    Alignment = taLeftJustify
    Caption = 'Legal mode: 1)   1.1)    1.1.1)'
    TabOrder = 6
  end
  object btnCancel: TButton
    Left = 207
    Top = 227
    Width = 92
    Height = 31
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
  object btnOK: TButton
    Left = 108
    Top = 227
    Width = 93
    Height = 31
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 8
  end
  object EditIndent: TWPValueEdit
    Left = 149
    Top = 158
    Width = 100
    Height = 26
    AvailableUnits = [euInch, euCm, euPt]
    UnitType = euTwips
    TabOrder = 5
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object cbxFontSize: TComboBox
    Left = 149
    Top = 69
    Width = 148
    Height = 24
    ItemHeight = 16
    TabOrder = 2
    OnChange = SelectFontChange
    Items.Strings = (
      ''
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12'
      '15'
      '18'
      '22'
      '28'
      '36'
      '48'
      '56'
      '72')
  end
  object ColorDialog1: TColorDialog
    Left = 267
    Top = 173
  end
end
