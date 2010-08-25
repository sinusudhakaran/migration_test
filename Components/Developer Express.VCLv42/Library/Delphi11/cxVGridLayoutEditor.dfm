object fmvgLayoutEditor: TfmvgLayoutEditor
  Left = 301
  Top = 223
  Width = 491
  Height = 343
  Caption = 'Layout editor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefaultPosOnly
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 378
    Top = 0
    Width = 105
    Height = 309
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object btCustomize: TcxButton
      Left = 8
      Top = 80
      Width = 89
      Height = 25
      Caption = 'Customize'
      TabOrder = 0
      OnClick = btCustomizeClick
    end
    object btOk: TcxButton
      Left = 8
      Top = 16
      Width = 89
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 1
    end
    object btCancel: TcxButton
      Left = 8
      Top = 48
      Width = 89
      Height = 25
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
    object StatusBar1: TStatusBar
      Left = 0
      Top = 290
      Width = 105
      Height = 19
      Panels = <
        item
          Bevel = pbNone
          Width = 50
        end>
    end
  end
  object pnlVGPlace: TPanel
    Left = 0
    Top = 0
    Width = 378
    Height = 309
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
  end
end
