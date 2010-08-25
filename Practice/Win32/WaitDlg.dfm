object DelayForm: TDelayForm
  Left = 281
  Top = 300
  BorderIcons = []
  BorderStyle = bsToolWindow
  ClientHeight = 69
  ClientWidth = 392
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblDelay: TLabel
    Left = 10
    Top = 16
    Width = 371
    Height = 24
    Alignment = taCenter
    AutoSize = False
    Caption = 'Waiting for ...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object pbProgress: TRzProgressBar
    Left = 7
    Top = 48
    Width = 377
    Height = 14
    BarColor = 10445568
    BorderOuter = fsFlat
    BorderWidth = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 10445568
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    InteriorOffset = 1
    NumSegments = 100
    ParentFont = False
    PartsComplete = 0
    Percent = 50
    ShowPercent = False
    TotalParts = 0
  end
end
