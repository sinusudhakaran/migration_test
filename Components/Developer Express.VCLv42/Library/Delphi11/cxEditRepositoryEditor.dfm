inherited cxEditRepositoryEditor: TcxEditRepositoryEditor
  Left = 363
  Top = 194
  Width = 353
  Height = 416
  Caption = 'EditRepository editor'
  Constraints.MinHeight = 200
  Constraints.MinWidth = 350
  PopupMenu = PopupMenu1
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LBItems: TListBox
    Left = 0
    Top = 0
    Width = 258
    Height = 382
    Align = alClient
    ItemHeight = 13
    MultiSelect = True
    Sorted = True
    TabOrder = 0
    OnClick = LBItemsClick
  end
  object Panel1: TPanel
    Left = 258
    Top = 0
    Width = 87
    Height = 382
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object btAdd: TButton
      Left = 6
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Add...'
      TabOrder = 0
      OnClick = btAddClick
    end
    object btDelete: TButton
      Left = 6
      Top = 40
      Width = 75
      Height = 25
      Caption = '&Delete'
      TabOrder = 1
      OnClick = btDeleteClick
    end
    object btClose: TButton
      Left = 6
      Top = 356
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Close'
      TabOrder = 2
      OnClick = btCloseClick
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 32
    Top = 16
    object miAdd: TMenuItem
      Caption = 'Add'
      ShortCut = 45
      OnClick = miAddClick
    end
    object miDelete: TMenuItem
      Caption = 'Delete'
      Enabled = False
      ShortCut = 46
      OnClick = miDeleteClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miSelectAll: TMenuItem
      Caption = 'Select all'
      Enabled = False
      ShortCut = 16449
      OnClick = miSelectAllClick
    end
  end
end
