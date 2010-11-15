object FromBrowse: TFromBrowse
  Left = 0
  Top = 0
  Caption = 'Select Practice System To Migrate From'
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
    ExplicitTop = 249
    ExplicitWidth = 554
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
      ExplicitLeft = 505
    end
    object Btnok: TButton
      Left = 468
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Ok'
      TabOrder = 1
      OnClick = BtnokClick
      ExplicitLeft = 426
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 328
    Width = 631
    Height = 82
    Align = alBottom
    TabOrder = 1
    ExplicitWidth = 607
    DesignSize = (
      631
      82)
    object Label1: TLabel
      Left = 280
      Top = 16
      Width = 342
      Height = 15
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'Or; browse to a different BankLink Practice 5 database location'
      ExplicitLeft = 269
    end
    object EResult: TEdit
      Left = 9
      Top = 37
      Width = 532
      Height = 23
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      ExplicitWidth = 508
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
      ExplicitLeft = 523
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
    ExplicitTop = 16
    ExplicitWidth = 586
    ExplicitHeight = 297
    DesignSize = (
      631
      328)
    object LExsiting: TLabel
      Left = 8
      Top = -8
      Width = 322
      Height = 45
      Caption = 
        #13'Select an existing instalation BankLink Practice 5 database'#13'run' +
        ' on this machine before '
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
    Filter = 'Client Files|*.bk5|Practice|system.db'
    Options = [ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Practice Install'
    Left = 440
  end
end
