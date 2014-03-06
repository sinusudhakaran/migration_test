object frmUpgradeReminder: TfrmUpgradeReminder
  Scaled = False
Left = 0
  Top = 0
  Caption = 'Upgrade Reminder'
  ClientHeight = 442
  ClientWidth = 624
  Color = clBtnFace
  Constraints.MinHeight = 480
  Constraints.MinWidth = 640
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
    624
    442)
  PixelsPerInch = 96
  TextHeight = 13
  object BKWebBrowser: TBKWebBrowser
    Left = 8
    Top = 8
    Width = 608
    Height = 398
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    ExplicitWidth = 574
    ExplicitHeight = 385
    ControlData = {
      4C000000D73E0000222900000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object btnOk: TButton
    Left = 541
    Top = 412
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
    ExplicitLeft = 496
    ExplicitTop = 431
  end
end
