object CSVConfig: TCSVConfig
  Scaled = False
Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'CSVConfig'
  ClientHeight = 131
  ClientWidth = 486
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 24
    Width = 37
    Height = 13
    Caption = 'Save to'
  end
  object eFilename: TEdit
    Left = 80
    Top = 21
    Width = 305
    Height = 21
    TabOrder = 0
    Text = 'eFilename'
    OnChange = eFilenameChange
  end
  object btnBrowse: TButton
    Left = 400
    Top = 19
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object pBtn: TPanel
    Left = 0
    Top = 90
    Width = 486
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    DesignSize = (
      486
      41)
    object btnCancel: TButton
      Left = 401
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnOK: TButton
      Left = 320
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
    Left = 80
    Top = 48
    Width = 153
    Height = 17
    Caption = 'Separate file per client'
    TabOrder = 2
  end
  object SaveDlg: TSaveDialog
    Filter = 'Comma Seperated Variables file|*.csv'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 392
  end
end
