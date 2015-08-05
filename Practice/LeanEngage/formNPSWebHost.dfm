object frmNPSWebHost: TfrmNPSWebHost
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  ClientHeight = 436
  ClientWidth = 572
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object WebBrowser: TBKWebBrowser
    Left = 0
    Top = 0
    Width = 572
    Height = 436
    Align = alClient
    TabOrder = 0
    OnQuit = WebBrowserQuit
    OnWindowClosing = WebBrowserWindowClosing
    ExplicitLeft = 5
    ExplicitTop = 4
    ExplicitWidth = 642
    ExplicitHeight = 329
    ControlData = {
      4C0000001E3B0000102D00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620C000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
