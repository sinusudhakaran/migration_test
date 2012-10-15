object frmModalDualProgress: TfrmModalDualProgress
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'frmModalDualProgress'
  ClientHeight = 96
  ClientWidth = 435
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblProgressTitle: TLabel
    Left = 16
    Top = 8
    Width = 401
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = 'Exporting Client Transactions'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ShowAccelChar = False
    Transparent = True
  end
  object prgFirstProgress: TRzProgressBar
    Left = 16
    Top = 59
    Width = 401
    Height = 15
    BarStyle = bsLED
    BorderOuter = fsBump
    BorderWidth = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlight
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    InteriorOffset = 1
    NumSegments = 50
    ParentFont = False
    PartsComplete = 0
    Percent = 0
    ShowPercent = False
    TotalParts = 0
  end
  object lblFirstProgress: TLabel
    Left = 16
    Top = 40
    Width = 401
    Height = 18
    Alignment = taCenter
    AutoSize = False
    Caption = 'Exporting Client TEST1'
  end
  object prgSecondProgress: TRzProgressBar
    Left = 16
    Top = 76
    Width = 401
    Height = 15
    BarStyle = bsLED
    BorderOuter = fsBump
    BorderWidth = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlight
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    InteriorOffset = 1
    NumSegments = 50
    ParentFont = False
    PartsComplete = 0
    Percent = 0
    ShowPercent = False
    TotalParts = 0
  end
end
