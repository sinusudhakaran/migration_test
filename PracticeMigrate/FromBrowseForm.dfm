object FromBrowse: TFromBrowse
  Left = 0
  Top = 0
  Caption = 'Select BankLink Practice 5 Location to Migrate From'
  ClientHeight = 451
  ClientWidth = 631
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object pBtn: TPanel
    Left = 0
    Top = 410
    Width = 631
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      631
      41)
    object BtnCancel: TButton
      Left = 547
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object Btnok: TButton
      Left = 468
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 1
      OnClick = BtnokClick
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 328
    Width = 631
    Height = 82
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      631
      82)
    object Label1: TLabel
      Left = 8
      Top = 16
      Width = 287
      Height = 15
      Caption = 'Or; browse to a different BankLink Practice 5 location'
    end
    object EResult: TEdit
      Left = 8
      Top = 37
      Width = 532
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object BtnBrowse: TButton
      Left = 547
      Top = 37
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Browse'
      TabOrder = 1
      OnClick = BtnBrowseClick
    end
  end
  object PTop: TPanel
    Left = 0
    Top = 0
    Width = 631
    Height = 328
    Align = alClient
    Caption = 'PTop'
    TabOrder = 2
    DesignSize = (
      631
      328)
    object LExsiting: TLabel
      Left = 8
      Top = 4
      Width = 259
      Height = 30
      Caption = 
        'Select an existing BankLink Practice 5 location, '#13'run on this ma' +
        'chine before'
    end
    object EExststing: TListBox
      Left = 8
      Top = 51
      Width = 614
      Height = 262
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 15
      TabOrder = 0
      OnClick = EExststingClick
      OnDblClick = EExststingDblClick
    end
  end
  object OpenDlg: TOpenDialog
    Filter = 'BankLink Practice Database file|system.db'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'BankLink Practice 5 Location'
    Left = 440
  end
end
