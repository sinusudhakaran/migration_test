object InsFootNote: TInsFootNote
  Left = 55
  Top = 213
  Width = 407
  Height = 149
  ActiveControl = FText
  Caption = 'Insert Footnote'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 10
    Top = 39
    Width = 70
    Height = 20
    Caption = 'Character'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 10
    Top = 69
    Width = 56
    Height = 20
    Caption = 'Number'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 10
    Top = 10
    Width = 30
    Height = 20
    Caption = 'Text'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -17
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Edit1: TEdit
    Left = 89
    Top = 69
    Width = 60
    Height = 24
    TabOrder = 0
    OnChange = Edit1Change
  end
  object Edit2: TEdit
    Left = 89
    Top = 39
    Width = 60
    Height = 24
    MaxLength = 1
    TabOrder = 1
    OnChange = Edit2Change
  end
  object FText: TEdit
    Left = 89
    Top = 10
    Width = 296
    Height = 24
    TabOrder = 2
  end
  object BitBtn1: TBitBtn
    Left = 177
    Top = 69
    Width = 80
    Height = 31
    Enabled = False
    TabOrder = 3
    Kind = bkOK
  end
  object BitBtn2: TBitBtn
    Left = 276
    Top = 69
    Width = 109
    Height = 31
    TabOrder = 4
    Kind = bkCancel
  end
end
