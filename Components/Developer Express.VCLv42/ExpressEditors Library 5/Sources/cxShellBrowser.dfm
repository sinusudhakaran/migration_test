object cxShellBrowserDlg: TcxShellBrowserDlg
  Left = 455
  Top = 160
  ActiveControl = cxStv
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Browse for Folder'
  ClientHeight = 358
  ClientWidth = 308
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 250
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object lblFolder: TcxLabel
    Left = 12
    Top = 8
    Caption = 'Current Folder'
    Transparent = True
  end
  object cxStv: TcxShellTreeView
    Left = 12
    Top = 56
    Width = 284
    Height = 261
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideSelection = False
    Indent = 19
    Options.ShowNonFolders = False
    RightClickSelect = True
    TabOrder = 0
    OnChange = cxStvChange
  end
  object cxTeFolder: TcxTextEdit
    Left = 12
    Top = 24
    Anchors = [akLeft, akTop, akRight, akBottom]
    Properties.ReadOnly = True
    Style.Color = clWindow
    TabOrder = 1
    Width = 284
  end
  object cxButton1: TcxButton
    Left = 139
    Top = 323
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object cxButton2: TcxButton
    Left = 219
    Top = 323
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
