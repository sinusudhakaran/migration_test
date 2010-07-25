object SaveBatchDlg: TSaveBatchDlg
  Left = 0
  Top = 0
  Caption = 'Save Reports to:'
  ClientHeight = 132
  ClientWidth = 549
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    549
    132)
  PixelsPerInch = 96
  TextHeight = 16
  object Button2: TButton
    Left = 364
    Top = 90
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Save'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 549
    Height = 73
    Align = alTop
    TabOrder = 1
    object Label2: TLabel
      Left = 16
      Top = 28
      Width = 67
      Height = 16
      Caption = 'Destination'
    end
    object EName: TEdit
      Left = 102
      Top = 25
      Width = 426
      Height = 24
      TabOrder = 0
      Text = 'EName'
    end
  end
  object Button1: TButton
    Left = 453
    Top = 90
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = Button1Click
  end
end
