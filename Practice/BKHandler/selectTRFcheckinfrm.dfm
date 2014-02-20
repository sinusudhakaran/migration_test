object SelectTRFcheckinform: TSelectTRFcheckinform
  Left = 0
  Top = 0
  Caption = 'Select checkinform'
  ClientHeight = 350
  ClientWidth = 451
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    451
    350)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 273
    Top = 315
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 0
  end
  object Button2: TButton
    Left = 369
    Top = 315
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object GBBNotes: TGroupBox
    Left = 8
    Top = 48
    Width = 442
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    object RBBnotes: TRadioButton
      Left = 8
      Top = 8
      Width = 425
      Height = 17
      Caption = '&Open with BankLink Notes'
      TabOrder = 0
      OnClick = CBBNotesClick
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 88
    Width = 442
    Height = 217
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    DesignSize = (
      442
      217)
    object LBBK5Paths: TListBox
      Left = 16
      Top = 40
      Width = 407
      Height = 161
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
      OnClick = LBBK5PathsClick
      OnDblClick = LBBK5PathsDblClick
    end
    object RBBK5: TRadioButton
      Left = 8
      Top = 16
      Width = 417
      Height = 17
      Caption = '&Import into BankLink'
      TabOrder = 1
      OnClick = CBBK5Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 441
    Height = 33
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    object Label1: TLabel
      Left = 8
      Top = 8
      Width = 47
      Height = 13
      Caption = 'Open file:'
    end
    object LBLTRFFile: TLabel
      Left = 64
      Top = 8
      Width = 52
      Height = 13
      Caption = 'lblFilename'
    end
  end
end
