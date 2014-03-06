object BGLXMLConfig: TBGLXMLConfig
  Scaled = False
Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'BGL XML Config'
  ClientHeight = 253
  ClientWidth = 506
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 72
    Width = 77
    Height = 13
    Caption = 'Directory to use'
  end
  object Label2: TLabel
    Left = 8
    Top = 16
    Width = 54
    Height = 13
    Caption = 'File options'
  end
  object Label3: TLabel
    Left = 8
    Top = 113
    Width = 73
    Height = 13
    Caption = 'Coding Options'
  end
  object Label4: TLabel
    Left = 8
    Top = 154
    Width = 81
    Height = 13
    Caption = 'Clearing Account'
  end
  object eFilename: TEdit
    Left = 112
    Top = 69
    Width = 305
    Height = 21
    TabOrder = 0
    Text = 'eFilename'
  end
  object btnBrowse: TButton
    Left = 423
    Top = 67
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object pBtn: TPanel
    Left = 0
    Top = 212
    Width = 506
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      506
      41)
    object btnCancel: TButton
      Left = 421
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnOK: TButton
      Left = 340
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
  object eClearing: TEdit
    Left = 112
    Top = 151
    Width = 121
    Height = 21
    Hint = 'Uncoded entries will be posted to this code'
    TabOrder = 3
    Text = '998'
  end
  object ckCoding: TCheckBox
    Left = 112
    Top = 112
    Width = 303
    Height = 17
    Caption = 'Export coded clients only'
    TabOrder = 4
  end
  object rbSingle: TRadioButton
    Left = 112
    Top = 15
    Width = 384
    Height = 17
    Caption = 'Export entries to a &single file for all clients'
    Checked = True
    TabOrder = 5
    TabStop = True
  end
  object rbSplit: TRadioButton
    Left = 112
    Top = 38
    Width = 386
    Height = 17
    Caption = 'Export entries to &individual files for each client'
    TabOrder = 6
  end
  object SaveDlg: TSaveDialog
    Filter = 'XML file|*.xml'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Left = 472
    Top = 32
  end
end
