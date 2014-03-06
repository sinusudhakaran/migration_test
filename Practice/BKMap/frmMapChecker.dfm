object MainForm: TMainForm
  Scaled = False
Left = 364
  Top = 261
  BorderStyle = bsDialog
  Caption = 'BankLink Client-Account Map'
  ClientHeight = 307
  ClientWidth = 472
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
    Left = 42
    Top = 5
    Width = 388
    Height = 13
    Caption = 
      '* WARNING: Please shut down BankLink before running this utility' +
      ' *'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnCheck: TButton
    Left = 27
    Top = 28
    Width = 422
    Height = 25
    Caption = 'Check Client-Account Map'
    TabOrder = 0
    OnClick = btnCheckClick
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 288
    Width = 472
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Click the "Check Client-Account Map" button to start'
  end
  object moResults: TMemo
    Left = 27
    Top = 64
    Width = 422
    Height = 209
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 2
  end
end
