object frmAddGroupItems: TfrmAddGroupItems
  Left = 209
  Top = 107
  Width = 364
  Height = 400
  Caption = 'Add Group Items'
  Color = clBtnFace
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel2: TPanel
    Left = 0
    Top = 5
    Width = 5
    Height = 334
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
  end
  object Panel3: TPanel
    Left = 351
    Top = 5
    Width = 5
    Height = 334
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
  end
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 356
    Height = 5
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
  end
  object lbGroupItems: TListBox
    Left = 5
    Top = 5
    Width = 346
    Height = 334
    Align = alClient
    ItemHeight = 16
    MultiSelect = True
    Style = lbOwnerDrawVariable
    TabOrder = 3
    OnDrawItem = lbGroupItemsDrawItem
    OnMeasureItem = lbGroupItemsMeasureItem
  end
  object Panel1: TPanel
    Left = 0
    Top = 339
    Width = 356
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object Panel5: TPanel
      Left = 191
      Top = 0
      Width = 165
      Height = 34
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOk: TButton
        Left = 0
        Top = 7
        Width = 76
        Height = 23
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object btnCancel: TButton
        Left = 84
        Top = 7
        Width = 76
        Height = 23
        Cancel = True
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 1
      end
    end
  end
end
