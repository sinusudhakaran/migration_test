object WPBulletStyleDialog: TWPBulletStyleDialog
  Left = 1157
  Top = 83
  BorderStyle = bsDialog
  Caption = 'Edit NumberStyle'
  ClientHeight = 223
  ClientWidth = 256
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = SelectFontChange
  PixelsPerInch = 96
  TextHeight = 13
  object labType: TLabel
    Left = 14
    Top = 12
    Width = 24
    Height = 13
    Caption = 'Type'
  end
  object labTextB: TLabel
    Left = 14
    Top = 86
    Width = 55
    Height = 13
    Caption = 'Text Before'
  end
  object labTextA: TLabel
    Left = 14
    Top = 111
    Width = 46
    Height = 13
    Caption = 'Text After'
  end
  object Label2: TLabel
    Left = 14
    Top = 37
    Width = 21
    Height = 13
    Caption = 'Font'
  end
  object labIndent: TLabel
    Left = 14
    Top = 136
    Width = 30
    Height = 13
    Caption = 'Indent'
  end
  object btnSelectFont: TSpeedButton
    Left = 222
    Top = 33
    Width = 19
    Height = 20
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
    Left = 222
    Top = 80
    Width = 19
    Height = 20
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
    Left = 14
    Top = 62
    Width = 20
    Height = 13
    Caption = 'Size'
  end
  object SelectType: TComboBox
    Left = 121
    Top = 9
    Width = 120
    Height = 22
    Style = csDropDownList
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ItemHeight = 14
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
    Left = 121
    Top = 33
    Width = 96
    Height = 21
    ItemHeight = 13
    TabOrder = 1
    OnChange = SelectFontChange
  end
  object EditTextB: TEdit
    Left = 121
    Top = 80
    Width = 96
    Height = 22
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object EditTextA: TEdit
    Left = 121
    Top = 106
    Width = 120
    Height = 21
    TabOrder = 4
  end
  object CheckUsePrev: TCheckBox
    Left = 14
    Top = 161
    Width = 163
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Legal mode: 1)   1.1)    1.1.1)'
    TabOrder = 6
  end
  object btnCancel: TButton
    Left = 168
    Top = 184
    Width = 75
    Height = 26
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
  object btnOK: TButton
    Left = 88
    Top = 184
    Width = 75
    Height = 26
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 8
  end
  object EditIndent: TWPValueEdit
    Left = 121
    Top = 128
    Width = 81
    Height = 22
    AvailableUnits = [euInch, euCm, euPt]
    UnitType = euTwips
    TabOrder = 5
    AllowNegative = False
    Value = 0
    IntValue = 0
    Undefined = False
  end
  object cbxFontSize: TComboBox
    Left = 121
    Top = 56
    Width = 120
    Height = 21
    ItemHeight = 13
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
