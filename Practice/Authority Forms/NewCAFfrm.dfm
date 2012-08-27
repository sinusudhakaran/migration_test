object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 290
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object lblCompleteTheDetailsBelow: TLabel
    Left = 10
    Top = 15
    Width = 473
    Height = 13
    Caption = 
      'Complete the details below to ensure that all spaces on the auth' +
      'ority forms are correctly filled out:'
  end
  object lbl20: TLabel
    Left = 468
    Top = 43
    Width = 12
    Height = 13
    Caption = '20'
  end
  object Label1: TLabel
    Left = 12
    Top = 62
    Width = 69
    Height = 13
    Caption = 'Account Name'
  end
  object lblServiceStartMonthAndYear: TLabel
    Left = 361
    Top = 67
    Width = 141
    Height = 13
    Caption = 'Service Start Month and Year'
  end
  object edtAccountName: TEdit
    Left = 8
    Top = 40
    Width = 321
    Height = 21
    TabOrder = 0
  end
  object cmbServiceStartMonth: TComboBox
    Left = 345
    Top = 40
    Width = 112
    Height = 21
    ItemHeight = 13
    TabOrder = 1
  end
  object edtServiceStartYear: TEdit
    Left = 482
    Top = 40
    Width = 34
    Height = 21
    TabOrder = 2
  end
end
