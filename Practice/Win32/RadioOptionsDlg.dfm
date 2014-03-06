object dlgRadioOptions: TdlgRadioOptions
  Scaled = False
Left = 243
  Top = 179
  BorderIcons = [biSystemMenu]
  ClientHeight = 220
  ClientWidth = 464
  Color = clBtnFace
  DefaultMonitor = dmMainForm
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
    Width = 28
    Height = 13
    Caption = 'Line 1'
    Color = clBtnFace
    ParentColor = False
    WordWrap = True
  end
  object lblLine2: TLabel
    Left = 8
    Top = 48
    Width = 457
    Height = 33
    AutoSize = False
    Caption = 'Line 2'
    Color = clBtnFace
    ParentColor = False
    WordWrap = True
  end
  object radRadio1: TRadioButton
    Left = 16
    Top = 92
    Width = 449
    Height = 17
    TabOrder = 0
    Visible = False
  end
  object radRadio2: TRadioButton
    Left = 16
    Top = 116
    Width = 449
    Height = 17
    TabOrder = 1
    Visible = False
  end
  object radRadio3: TRadioButton
    Left = 16
    Top = 140
    Width = 449
    Height = 17
    TabOrder = 2
    Visible = False
  end
  object radRadio4: TRadioButton
    Left = 16
    Top = 164
    Width = 449
    Height = 17
    TabOrder = 3
    Visible = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 187
    Width = 464
    Height = 33
    Align = alBottom
    Anchors = [akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 4
    DesignSize = (
      464
      33)
    object btnButton1: TButton
      Left = 295
      Top = 4
      Width = 77
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnButton2: TButton
      Left = 383
      Top = 4
      Width = 77
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
