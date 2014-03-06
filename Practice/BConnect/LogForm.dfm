object frmLog: TfrmLog
  Left = 192
  Top = 107
  BorderStyle = bsDialog
  Caption = 'View Log'
  ClientHeight = 271
  ClientWidth = 405
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 13
  object memoLog: TRzMemo
    Left = 0
    Top = 0
    Width = 405
    Height = 230
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object RzPanel1: TRzPanel
    Left = 0
    Top = 230
    Width = 405
    Height = 41
    Align = alBottom
    BorderOuter = fsNone
    TabOrder = 1
    object RzButton1: TRzButton
      Left = 326
      Top = 8
      Default = True
      ModalResult = 1
      Caption = 'OK'
      TabOrder = 0
      Anchors = [akTop, akRight]
    end
  end
end
