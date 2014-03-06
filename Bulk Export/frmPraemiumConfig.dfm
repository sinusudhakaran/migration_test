object PraemiumConfig: TPraemiumConfig
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'PraemiumConfig'
  ClientHeight = 131
  ClientWidth = 543
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnKeyPress = FormKeyPress
  DesignSize = (
    543
    131)
  PixelsPerInch = 96
  TextHeight = 13
  object lSave: TLabel
    Left = 49
    Top = 24
    Width = 81
    Height = 13
    Alignment = taRightJustify
    Caption = 'Save in directory'
  end
  object eFilename: TEdit
    Left = 136
    Top = 21
    Width = 316
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    Text = 'eFilename'
  end
  object btnBrowse: TButton
    Left = 458
    Top = 19
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object pBtn: TPanel
    Left = 0
    Top = 90
    Width = 543
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    DesignSize = (
      543
      41)
    object btnCancel: TButton
      Left = 458
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnOK: TButton
      Left = 377
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
  object ckSeparate: TCheckBox
    Left = 136
    Top = 56
    Width = 169
    Height = 17
    Caption = 'Separate file per client'
    TabOrder = 2
  end
  object SaveDlg: TSaveDialog
    Filter = 'Comma Seperated Variables file|*.csv'
    Left = 392
  end
end
