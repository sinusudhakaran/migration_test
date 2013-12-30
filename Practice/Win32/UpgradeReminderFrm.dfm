object frmUpgradeReminder: TfrmUpgradeReminder
  Left = 0
  Top = 0
  Caption = 'Upgrade Reminder'
  ClientHeight = 461
  ClientWidth = 579
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    579
    461)
  PixelsPerInch = 96
  TextHeight = 13
  object BKWebBrowser: TBKWebBrowser
    Left = 8
    Top = 8
    Width = 563
    Height = 417
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    ExplicitWidth = 574
    ExplicitHeight = 385
    ControlData = {
      4C000000303A0000192B00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object btnOk: TButton
    Left = 496
    Top = 431
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 1
  end
end
