object WPInsNewInsertP: TWPInsNewInsertP
  Left = 43
  Top = 150
  BorderStyle = bsDialog
  Caption = 'Insert Insertpoint'
  ClientHeight = 122
  ClientWidth = 348
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 2
    Top = 1
    Width = 345
    Height = 87
    Style = bsRaised
  end
  object Label3: TLabel
    Left = 12
    Top = 7
    Width = 26
    Height = 16
    Caption = 'Text'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label1: TLabel
    Left = 12
    Top = 33
    Width = 64
    Height = 16
    Caption = 'Fieldname'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 12
    Top = 59
    Width = 58
    Height = 16
    Caption = 'Character'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object FText: TEdit
    Left = 96
    Top = 7
    Width = 241
    Height = 24
    TabOrder = 0
  end
  object FField: TEdit
    Left = 96
    Top = 31
    Width = 241
    Height = 24
    TabOrder = 1
  end
  object Button1: TButton
    Left = 258
    Top = 93
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object Button2: TButton
    Left = 178
    Top = 93
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object FCHar: TEdit
    Left = 96
    Top = 56
    Width = 49
    Height = 24
    MaxLength = 1
    TabOrder = 4
    Text = '%'
  end
end
