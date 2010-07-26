object dxBarItemAddEditor: TdxBarItemAddEditor
  Left = 352
  Top = 153
  BorderStyle = bsDialog
  Caption = 'Add New ExpressBars Item'
  ClientHeight = 150
  ClientWidth = 263
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object LName: TLabel
    Left = 8
    Top = 68
    Width = 47
    Height = 13
    AutoSize = False
    Caption = 'Name:'
  end
  object LCaption: TLabel
    Left = 8
    Top = 96
    Width = 47
    Height = 13
    AutoSize = False
    Caption = 'Caption:'
  end
  object LType: TLabel
    Left = 8
    Top = 12
    Width = 47
    Height = 13
    AutoSize = False
    Caption = 'Type:'
  end
  object LCategory: TLabel
    Left = 8
    Top = 40
    Width = 47
    Height = 13
    AutoSize = False
    Caption = 'Category:'
  end
  object Edit1: TEdit
    Left = 62
    Top = 64
    Width = 194
    Height = 21
    TabOrder = 2
  end
  object Edit2: TEdit
    Left = 62
    Top = 92
    Width = 194
    Height = 21
    TabOrder = 3
    Text = 'New Item'
  end
  object ComboBox1: TComboBox
    Left = 62
    Top = 8
    Width = 194
    Height = 21
    Style = csDropDownList
    DropDownCount = 100
    ItemHeight = 13
    TabOrder = 0
    OnClick = ComboBox1Click
  end
  object ComboBox2: TComboBox
    Left = 62
    Top = 36
    Width = 194
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
  end
  object BOk: TButton
    Left = 100
    Top = 122
    Width = 73
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = BOkClick
  end
  object BCancel: TButton
    Left = 184
    Top = 122
    Width = 73
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
end
