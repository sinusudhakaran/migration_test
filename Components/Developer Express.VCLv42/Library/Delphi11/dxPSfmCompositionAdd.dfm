object dxfmCompositionAddItems: TdxfmCompositionAddItems
  Left = 426
  Top = 382
  ActiveControl = lvItems
  BorderStyle = bsDialog
  Caption = 'Add Items to Composition'
  ClientHeight = 381
  ClientWidth = 329
  Color = clBtnFace
  Constraints.MinHeight = 250
  Constraints.MinWidth = 337
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 87
    Top = 352
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 168
    Top = 352
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 249
    Top = 352
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Help'
    TabOrder = 3
  end
  object pgctrlItems: TPageControl
    Left = 5
    Top = 7
    Width = 319
    Height = 339
    ActivePage = tshItems
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    TabStop = False
    object tshItems: TTabSheet
      Caption = 'Available Items'
      object lvItems: TListView
        Left = 0
        Top = 0
        Width = 311
        Height = 280
        Align = alTop
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <>
        ColumnClick = False
        MultiSelect = True
        ReadOnly = True
        TabOrder = 0
        OnDblClick = lvItemsDblClick
      end
      object pnlNoItems: TPanel
        Tag = 20
        Left = 19
        Top = 33
        Width = 277
        Height = 22
        BevelOuter = bvNone
        Caption = 'There are no Items do Display'
        Color = clWindow
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBtnShadow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
      end
      object chbxHideIncludedItems: TCheckBox
        Left = 2
        Top = 287
        Width = 303
        Height = 17
        Anchors = [akLeft, akRight, akBottom]
        Caption = 'Hide Already Included Items'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = chbxHideIncludedItemsClick
      end
    end
  end
end
