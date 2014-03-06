object Form1: TForm1
  Left = 348
  Top = 290
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'BK Database Encryption'
  ClientHeight = 110
  ClientWidth = 332
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 8
    Width = 301
    Height = 13
    Caption = 
      'This utility wil encrypt or decrypt an admin database (system.db' +
      ').'
  end
  object Label2: TLabel
    Left = 24
    Top = 32
    Width = 159
    Height = 13
    Caption = 'Please run it from your BK5 folder.'
  end
  object btnEnc: TButton
    Left = 24
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Encrypt'
    TabOrder = 0
    OnClick = btnEncClick
  end
  object btnDec: TButton
    Left = 104
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Decrypt'
    TabOrder = 1
    OnClick = btnDecClick
  end
  object btnExit: TButton
    Left = 184
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Exit'
    TabOrder = 2
    OnClick = btnExitClick
  end
  object OpenDialog1: TOpenDialog
    Left = 248
    Top = 72
  end
end
