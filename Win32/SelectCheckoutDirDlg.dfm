object dlgSelectCheckoutDir: TdlgSelectCheckoutDir
  Left = 431
  Top = 338
  BorderStyle = bsDialog
  Caption = 'Check out file(s)'
  ClientHeight = 92
  ClientWidth = 494
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    494
    92)
  PixelsPerInch = 96
  TextHeight = 13
  object lblDirLabel: TLabel
    Left = 7
    Top = 14
    Width = 94
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Check out file(s) to '
  end
  object btnFolder: TSpeedButton
    Left = 456
    Top = 11
    Width = 25
    Height = 22
    Hint = 'Click to Select a Folder'
    Anchors = [akRight, akBottom]
    ParentShowHint = False
    ShowHint = True
    OnClick = btnFolderClick
  end
  object ePath: TEdit
    Left = 128
    Top = 12
    Width = 325
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
    Text = 'A:\'
  end
  object btnOK: TButton
    Left = 331
    Top = 60
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 411
    Top = 60
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
