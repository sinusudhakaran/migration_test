object FSelectUnion: TFSelectUnion
  Left = 425
  Top = 211
  BorderStyle = bsDialog
  Caption = 'Select Union'
  ClientHeight = 271
  ClientWidth = 263
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 240
    Width = 263
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 186
      Top = 4
      Width = 75
      Height = 25
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object Button2: TButton
      Left = 106
      Top = 4
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
  end
  object lbUnions: TListBox
    Left = 0
    Top = 0
    Width = 263
    Height = 240
    Align = alClient
    ItemHeight = 13
    TabOrder = 1
  end
end
