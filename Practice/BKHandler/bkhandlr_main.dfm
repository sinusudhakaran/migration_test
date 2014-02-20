object frmMain: TfrmMain
  Left = 0
  Top = 50
  BorderStyle = bsSingle
  Caption = 'MYOB BankLink File Handler'
  ClientHeight = 42
  ClientWidth = 176
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object DDEClientConv_BK: TDdeClientConv
    ConnectMode = ddeManual
    Left = 24
    Top = 8
  end
  object bkSystem: TDdeServerConv
    OnExecuteMacro = bkSystemExecuteMacro
    Left = 64
    Top = 8
  end
  object tmrClose: TTimer
    Enabled = False
    Interval = 120000
    OnTimer = tmrCloseTimer
    Left = 136
    Top = 8
  end
  object XPManifest1: TXPManifest
    Left = 96
    Top = 8
  end
end
