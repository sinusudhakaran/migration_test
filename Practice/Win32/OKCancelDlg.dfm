object dlgOkCancel: TdlgOkCancel
  Left = 272
  Top = 299
  BorderStyle = bsDialog
  Caption = 'dlgOkCancel'
  ClientHeight = 142
  ClientWidth = 471
  Color = clWindow
  DefaultMonitor = dmMainForm
  ParentFont = True
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 15
    Top = 6
    Width = 40
    Height = 40
    AutoSize = True
    Stretch = True
    Transparent = True
  end
  object lblText: TLabel
    Left = 76
    Top = 8
    Width = 330
    Height = 13
    Caption = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    ShowAccelChar = False
    Transparent = True
    WordWrap = True
  end
  object btnOk: TButton
    Left = 292
    Top = 98
    Width = 75
    Height = 25
    Caption = '&OK'
    TabOrder = 0
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 384
    Top = 98
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    Default = True
    TabOrder = 1
    OnClick = btnCancelClick
  end
end
