object Form1: TForm1
  Left = 114
  Top = 305
  Caption = 'Form1'
  ClientHeight = 399
  ClientWidth = 521
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 40
    Top = 32
    Width = 369
    Height = 49
    Caption = 'Check for Updates (BK5)'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 40
    Top = 87
    Width = 369
    Height = 49
    Caption = 'Install Updates (BK5)'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 40
    Top = 350
    Width = 369
    Height = 41
    Caption = 'Test Pending'
    TabOrder = 2
    OnClick = Button3Click
  end
  object btnCheckForCoreUpdate: TButton
    Left = 40
    Top = 142
    Width = 369
    Height = 49
    Caption = 'Check for Updates Standard (Core)'
    TabOrder = 3
    OnClick = btnCheckForCoreUpdateClick
  end
  object btnCheckForCoreUpdateEx: TButton
    Left = 40
    Top = 197
    Width = 369
    Height = 49
    Caption = 'Check for Updates Forced (Core)'
    TabOrder = 4
    OnClick = btnCheckForCoreUpdateExClick
  end
  object bthCheckUpdatesCoreCheckIndividualFiles: TButton
    Left = 40
    Top = 252
    Width = 369
    Height = 49
    Caption = 'Check for Updates Individual Files (Core)'
    TabOrder = 5
    OnClick = bthCheckUpdatesCoreCheckIndividualFilesClick
  end
  object XPManifest1: TXPManifest
    Left = 456
    Top = 57
  end
  object ipsHTTPS1: TipsHTTPS
    FirewallPort = 80
    SSLCertStore = 'MY'
    Left = 460
    Top = 108
  end
end
