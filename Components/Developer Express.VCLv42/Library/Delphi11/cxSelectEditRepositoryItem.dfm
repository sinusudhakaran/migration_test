object cxSelectRepositoryItem: TcxSelectRepositoryItem
  Left = 403
  Top = 209
  BorderStyle = bsDialog
  Caption = 'Select EditRepositoryItem'
  ClientHeight = 392
  ClientWidth = 346
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 320
    Width = 56
    Height = 13
    Caption = 'Description:'
  end
  object lbItems: TListBox
    Left = 8
    Top = 8
    Width = 233
    Height = 305
    ItemHeight = 13
    Sorted = True
    TabOrder = 0
    OnClick = lbItemsClick
    OnMouseDown = lbItemsMouseDown
  end
  object Panel1: TPanel
    Left = 8
    Top = 335
    Width = 329
    Height = 49
    BevelInner = bvLowered
    Color = clInfoBk
    TabOrder = 3
    object lbHint: TLabel
      Left = 4
      Top = 4
      Width = 321
      Height = 41
      AutoSize = False
      Caption = 'LongHint'
      WordWrap = True
    end
  end
  object btOk: TButton
    Left = 256
    Top = 8
    Width = 75
    Height = 25
    Caption = '&Ok'
    Default = True
    Enabled = False
    ModalResult = 1
    TabOrder = 1
  end
  object btCancel: TButton
    Left = 256
    Top = 40
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
