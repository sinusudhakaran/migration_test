object dxfmSelectStyleClass: TdxfmSelectStyleClass
  Left = 427
  Top = 284
  BorderStyle = bsDialog
  Caption = 'Select PrintStyle Type'
  ClientHeight = 91
  ClientWidth = 279
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 2
    Top = -2
    Width = 275
    Height = 58
    TabOrder = 0
    object Label1: TLabel
      Left = 7
      Top = 24
      Width = 28
      Height = 13
      Caption = '&Type:'
      FocusControl = cbxStyleTypes
      OnClick = Label1Click
    end
    object cbxStyleTypes: TComboBox
      Left = 44
      Top = 20
      Width = 220
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbxStyleTypesChange
    end
  end
  object btnOK: TButton
    Left = 31
    Top = 63
    Width = 79
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 115
    Top = 63
    Width = 79
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 198
    Top = 63
    Width = 79
    Height = 23
    Caption = '&Help'
    TabOrder = 3
  end
end
