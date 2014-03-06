object dlgCheckBoxOptions: TdlgCheckBoxOptions
  Left = 293
  Top = 233
  Anchors = []
  BorderIcons = [biSystemMenu]
  ClientHeight = 213
  ClientWidth = 462
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblLine1: TLabel
    Left = 8
    Top = 8
    Width = 457
    Height = 33
    AutoSize = False
    WordWrap = True
  end
  object lblLine2: TLabel
    Left = 8
    Top = 48
    Width = 457
    Height = 33
    AutoSize = False
    WordWrap = True
  end
  object chkBox1: TCheckBox
    Left = 16
    Top = 92
    Width = 449
    Height = 17
    TabOrder = 0
    Visible = False
  end
  object chkBox2: TCheckBox
    Left = 16
    Top = 116
    Width = 449
    Height = 17
    TabOrder = 1
    Visible = False
  end
  object chkBox3: TCheckBox
    Left = 16
    Top = 140
    Width = 449
    Height = 17
    TabOrder = 2
    Visible = False
  end
  object chkBox4: TCheckBox
    Left = 16
    Top = 164
    Width = 449
    Height = 17
    TabOrder = 3
    Visible = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 180
    Width = 462
    Height = 33
    Align = alBottom
    Anchors = [akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 4
    DesignSize = (
      462
      33)
    object btnButton1: TButton
      Left = 300
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnButton2: TButton
      Left = 381
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
