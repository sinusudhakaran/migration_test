object dxStatusBarIndicatorEditor: TdxStatusBarIndicatorEditor
  Left = 624
  Top = 110
  BorderStyle = bsDialog
  ClientHeight = 234
  ClientWidth = 279
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 192
    Width = 337
    Height = 2
  end
  object BtnOK: TButton
    Left = 117
    Top = 202
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object BtnCancel: TButton
    Left = 197
    Top = 202
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object chlbIndicators: TCheckListBox
    Left = 8
    Top = 8
    Width = 153
    Height = 149
    ItemHeight = 13
    TabOrder = 2
    OnClick = chlbIndicatorsClick
    OnKeyDown = chlbIndicatorsKeyDown
  end
  object BtnAdd: TButton
    Left = 175
    Top = 8
    Width = 92
    Height = 25
    Caption = '&Add'
    TabOrder = 3
    OnClick = BtnAddClick
  end
  object BtnDelete: TButton
    Left = 175
    Top = 40
    Width = 92
    Height = 25
    Caption = '&Delete'
    TabOrder = 4
    OnClick = BtnDeleteClick
  end
  object BtnClear: TButton
    Left = 175
    Top = 72
    Width = 92
    Height = 25
    Caption = '&Clear'
    TabOrder = 5
    OnClick = BtnClearClick
  end
  object cbItemTypes: TComboBox
    Left = 9
    Top = 164
    Width = 153
    Height = 21
    ItemHeight = 13
    Items.Strings = (
      'sitOff'
      'sitYellow'
      'sitBlue'
      'sitGreen'
      'sitRed'
      'sitTeal'
      'sitPurple')
    TabOrder = 6
    OnChange = cbItemTypesChange
  end
  object GroupBox1: TGroupBox
    Left = 172
    Top = 130
    Width = 97
    Height = 56
    Caption = 'Example'
    TabOrder = 7
    object imgExample: TImage
      Left = 31
      Top = 26
      Width = 34
      Height = 15
      Center = True
    end
  end
end
