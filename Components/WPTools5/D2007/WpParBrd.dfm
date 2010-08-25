object WPParagraphBord: TWPParagraphBord
  Left = 5
  Top = 491
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Borders and Shading'
  ClientHeight = 253
  ClientWidth = 359
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnActivate = FormActivate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Borders: TGroupBox
    Left = 175
    Top = 9
    Width = 169
    Height = 195
    Caption = 'Borders'
    TabOrder = 1
    object btnTColor: TWPToolButton
      Left = 86
      Top = 17
      Width = 12
      Height = 25
      AllowAllUp = True
      Flat = True
      Glyph.Data = {
        06010000424D060100000000000076000000280000000A000000120000000100
        0400000000009000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFF00
        0000F44444444F000000F44444444F000000F44444444F000000F44444444F00
        0000F44444444F000000F22222222F000000F22222222F000000F22222222F00
        0000F22222222F000000F22222222F000000F22222222F000000F99999999F00
        0000F99999999F000000F99999999F000000F99999999F000000F99999999F00
        0000FFFFFFFFFF000000}
      Margin = 0
      OnClick = ColorButtonClick
      StyleGroup = 0
      StyleNumber = 0
      UseOwnGylph = False
    end
    object btnLColor: TWPToolButton
      Left = 15
      Top = 86
      Width = 12
      Height = 25
      AllowAllUp = True
      Flat = True
      Glyph.Data = {
        06010000424D060100000000000076000000280000000A000000120000000100
        0400000000009000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFF00
        0000F44444444F000000F44444444F000000F44444444F000000F44444444F00
        0000F44444444F000000F22222222F000000F22222222F000000F22222222F00
        0000F22222222F000000F22222222F000000F22222222F000000F99999999F00
        0000F99999999F000000F99999999F000000F99999999F000000F99999999F00
        0000FFFFFFFFFF000000}
      Margin = 0
      OnClick = ColorButtonClick
      StyleGroup = 0
      StyleNumber = 0
      UseOwnGylph = False
    end
    object btnRColor: TWPToolButton
      Left = 138
      Top = 86
      Width = 12
      Height = 25
      AllowAllUp = True
      Flat = True
      Glyph.Data = {
        06010000424D060100000000000076000000280000000A000000120000000100
        0400000000009000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFF00
        0000F44444444F000000F44444444F000000F44444444F000000F44444444F00
        0000F44444444F000000F22222222F000000F22222222F000000F22222222F00
        0000F22222222F000000F22222222F000000F22222222F000000F99999999F00
        0000F99999999F000000F99999999F000000F99999999F000000F99999999F00
        0000FFFFFFFFFF000000}
      Margin = 0
      OnClick = ColorButtonClick
      StyleGroup = 0
      StyleNumber = 0
      UseOwnGylph = False
    end
    object btnBColor: TWPToolButton
      Left = 86
      Top = 120
      Width = 12
      Height = 25
      AllowAllUp = True
      Flat = True
      Glyph.Data = {
        06010000424D060100000000000076000000280000000A000000120000000100
        0400000000009000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFF00
        0000F44444444F000000F44444444F000000F44444444F000000F44444444F00
        0000F44444444F000000F22222222F000000F22222222F000000F22222222F00
        0000F22222222F000000F22222222F000000F22222222F000000F99999999F00
        0000F99999999F000000F99999999F000000F99999999F000000F99999999F00
        0000FFFFFFFFFF000000}
      Margin = 0
      OnClick = ColorButtonClick
      StyleGroup = 0
      StyleNumber = 0
      UseOwnGylph = False
    end
    object PaintBox1: TPaintBox
      Left = 34
      Top = 45
      Width = 100
      Height = 73
      OnPaint = PaintBox1Paint
    end
    object WPToolButton1: TWPToolButton
      Left = 150
      Top = 164
      Width = 12
      Height = 25
      AllowAllUp = True
      Flat = True
      Glyph.Data = {
        06010000424D060100000000000076000000280000000A000000120000000100
        0400000000009000000000000000000000001000000010000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFF00
        0000F44444444F000000F44444444F000000F44444444F000000F44444444F00
        0000F44444444F000000F22222222F000000F22222222F000000F22222222F00
        0000F22222222F000000F22222222F000000F22222222F000000F99999999F00
        0000F99999999F000000F99999999F000000F99999999F000000F99999999F00
        0000FFFFFFFFFF000000}
      Margin = 0
      OnClick = WPToolButton1Click
      StyleGroup = 0
      StyleNumber = 0
      UseOwnGylph = False
    end
    object cbxAll: TSpeedButton
      Left = 121
      Top = 164
      Width = 27
      Height = 26
      Flat = True
      Glyph.Data = {
        7E010000424D7E01000000000000760000002800000016000000160000000100
        0400000000000801000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
        DDDDDDDDDD00DD000000000000000000DD00D0D0000000000000000D0D00D00D
        DDDDDDDDDDDDDDD00D00D00DDDDDDDDDDDDDDDD00D00D00DDDDDDDDDDDDDDDD0
        0D00D00DDDDDDDDDDDDDDDD00D00D00DDDDDDDDDDDDDDDD00D00D00DDDDDDDDD
        DDDDDDD00D00D00DDDDDDDDDDDDDDDD00D00D00DDDDDDDDDDDDDDDD00D00D00D
        DDDDDDDDDDDDDDD00D00D00DDDDDDDDDDDDDDDD00D00D00DDDDDDDDDDDDDDDD0
        0D00D00DDDDDDDDDDDDDDDD00D00D00DDDDDDDDDDDDDDDD00D00D00DDDDDDDDD
        DDDDDDD00D00D00DDDDDDDDDDDDDDDD00D00D00DDDDDDDDDDDDDDDD00D00D0D0
        000000000000000D0D00DD000000000000000000DD00DDDDDDDDDDDDDDDDDDDD
        DD00}
      OnClick = cbxAllClick
    end
    object btnTop: TCheckBox
      Left = 65
      Top = 21
      Width = 19
      Height = 17
      AllowGrayed = True
      Caption = 'Top'
      State = cbGrayed
      TabOrder = 0
    end
    object btnLeft: TCheckBox
      Left = 13
      Top = 68
      Width = 19
      Height = 17
      AllowGrayed = True
      Caption = 'Left'
      State = cbGrayed
      TabOrder = 1
    end
    object btnRight: TCheckBox
      Left = 136
      Top = 68
      Width = 19
      Height = 17
      AllowGrayed = True
      Caption = 'Right'
      State = cbGrayed
      TabOrder = 2
    end
    object btnBottom: TCheckBox
      Left = 65
      Top = 124
      Width = 19
      Height = 17
      AllowGrayed = True
      Caption = 'Bottom'
      State = cbGrayed
      TabOrder = 3
    end
  end
  object btnOk: TButton
    Left = 184
    Top = 216
    Width = 75
    Height = 25
    Caption = '&Ok'
    Default = True
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 270
    Top = 216
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object btnUpdate: TButton
    Left = 16
    Top = 216
    Width = 75
    Height = 25
    Caption = 'Update'
    TabOrder = 2
    OnClick = btnUpdateClick
  end
  object Style: TGroupBox
    Left = 16
    Top = 8
    Width = 153
    Height = 131
    Caption = 'Style'
    TabOrder = 0
    object labWidth: TLabel
      Left = 8
      Top = 68
      Width = 28
      Height = 13
      Caption = 'Width'
      FocusControl = vePenWidth
    end
    object labSpace: TLabel
      Left = 8
      Top = 100
      Width = 31
      Height = 13
      Caption = 'Space'
      FocusControl = veSpace
    end
    object vePenWidth: TWPValueEdit
      Left = 80
      Top = 64
      Width = 58
      Height = 22
      AllowUndefined = True
      AvailableUnits = []
      UnitType = euPt
      TabOrder = 2
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      MaxLength = 1
      ParentFont = False
      OnChange = WidthSpaceChange
      AllowNegative = False
      Value = 0
      IntValue = 0
      Undefined = False
    end
    object veSpace: TWPValueEdit
      Left = 80
      Top = 96
      Width = 58
      Height = 22
      AllowUndefined = True
      AvailableUnits = []
      UnitType = euPt
      TabOrder = 3
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnChange = WidthSpaceChange
      AllowNegative = False
      Value = 0
      IntValue = 0
      Undefined = False
    end
    object Ndouble: TCheckBox
      Left = 9
      Top = 40
      Width = 129
      Height = 15
      Alignment = taLeftJustify
      AllowGrayed = True
      Caption = 'Dou&ble Line'
      TabOrder = 1
      OnClick = NdoubleClick
    end
    object Dotted: TCheckBox
      Left = 9
      Top = 16
      Width = 129
      Height = 17
      Alignment = taLeftJustify
      AllowGrayed = True
      Caption = 'Dotted Line'
      State = cbGrayed
      TabOrder = 0
      OnClick = DottedClick
    end
  end
  object drBox: TCheckBox
    Left = 183
    Top = 178
    Width = 97
    Height = 17
    Alignment = taLeftJustify
    AllowGrayed = True
    Caption = 'Draw Box'
    TabOrder = 5
  end
  object btnUndo: TBitBtn
    Left = 95
    Top = 216
    Width = 32
    Height = 25
    Hint = 'Undo'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    Visible = False
    OnClick = btnUndoClick
    Glyph.Data = {
      06050000424D06050000000000003604000028000000100000000D0000000100
      080000000000D0000000130B0000130B00000001000000000000FF00FF00BF00
      0000A6430A00A13D07009F3C0700E99F4100AE4E1100A03D0800BE631C00D178
      2200CA6B1200B9540500A74407009E3B0800FFC15700B6591800EA983B00F09C
      3500D0731A00BE5B0900C45F0200CF690100B34F0500AA470700FFBB5300B557
      1700FCB04700E38C2D00AA460A00BA560400D16B0000B5571600952D0000FFB1
      4600D57A2200A13E0600A13E0800C9650200BB560300FFBC5300AF4F1200BB5F
      1C00FDAD4300CF731E009D380400BF5A0300C05C0300FFB85100C66B2300EE9A
      3600D0741D009D380600C15C0300BD590400FEB34D00EC973300DB7F1C00A542
      0500A23F0600A5420700A5410700A23F0800A2400800CB660200B24E0600F29E
      3400DC7E1600CD680300C9630100CC670200AB470600B9550400C8630200A23E
      0800AE490600A4400800B14D0500D06B0100AC480600B85404009E3A0800CD69
      0100BE5A0300FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000151520700000000000000000000000000171E4F500000010101010101
      014A4B00004C4D4E0D0001414243443F3F45460000004748490401363738393A
      3B3C3D0000003E3F4001012F3031323300000000000000343501012728292A2B
      2C0000000000002D2E0101181F20072122230000000024252601011819000007
      1A1B1C0101011D1E1704010E0F00000007101112131415161700010506000000
      000708090A0B0C0D000001020300000000000101010104000000000000000000
      00000000000000000000}
  end
  object Panel1: TPanel
    Left = 16
    Top = 143
    Width = 153
    Height = 62
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 7
    object labShading: TLabel
      Left = 7
      Top = 7
      Width = 39
      Height = 13
      Caption = 'Shading'
      FocusControl = cbxShading
    end
    object cpxShadingValue: TWPValueEdit
      Left = 79
      Top = 5
      Width = 58
      Height = 22
      AvailableUnits = [euInch, euCm, euPt]
      UnitType = euPercent
      TabOrder = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      OnChange = cpxShadingValueChange
      AllowNegative = False
      Value = 100
      IntValue = 100
      Undefined = False
    end
    object cbxShading: TWPComboBox
      Left = 79
      Top = 35
      Width = 58
      Height = 22
      Style = csOwnerDrawFixed
      ItemHeight = 16
      TabOrder = 1
      Text = '0'
      OnChange = cbxShadingChange
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '11'
        '12'
        '13'
        '14'
        '15')
      ComboBoxStyle = cbsBKColor
      DontApplyChanges = False
    end
  end
end
