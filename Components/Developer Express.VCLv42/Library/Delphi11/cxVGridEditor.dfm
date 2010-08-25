inherited cxVerticalGridEditor: TcxVerticalGridEditor
  Left = 591
  Top = 125
  Width = 282
  Height = 404
  Caption = 'VerticalGrid - rows editor'
  Constraints.MinHeight = 310
  Constraints.MinWidth = 280
  PopupMenu = PopupMenu
  OnActivate = FormActivate
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 147
    Top = 0
    Width = 127
    Height = 364
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    object btCategory: TcxButton
      Left = 6
      Top = 50
      Width = 110
      Height = 31
      Caption = 'Add category'
      TabOrder = 2
      OnClick = btCategoryClick
    end
    object btEditor: TcxButton
      Left = 6
      Top = 11
      Width = 110
      Height = 31
      Caption = 'Add editor'
      TabOrder = 0
      OnClick = btEditorClick
    end
    object btClose: TcxButton
      Left = 6
      Top = 397
      Width = 110
      Height = 31
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Close'
      TabOrder = 5
      OnClick = btCloseClick
    end
    object btMultiEditor: TcxButton
      Left = 6
      Top = 90
      Width = 110
      Height = 31
      Caption = 'Add multieditor'
      TabOrder = 1
      OnClick = btMultiEditorClick
    end
    object btDelete: TcxButton
      Left = 6
      Top = 129
      Width = 110
      Height = 31
      Caption = 'Delete'
      Enabled = False
      TabOrder = 3
      OnClick = btDeleteClick
    end
    object btClear: TcxButton
      Left = 6
      Top = 208
      Width = 110
      Height = 31
      Caption = 'Clear all'
      Enabled = False
      TabOrder = 4
      OnClick = btClearClick
    end
    object btCreateAll: TcxButton
      Left = 6
      Top = 169
      Width = 110
      Height = 30
      Caption = 'Create all items'
      TabOrder = 6
      OnClick = btCreateAllClick
    end
    object btLayoutEditor: TcxButton
      Left = 6
      Top = 247
      Width = 110
      Height = 31
      Caption = 'Layout editor...'
      Enabled = False
      TabOrder = 7
      OnClick = btLayoutEditorClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 147
    Height = 364
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object lbRows: TListBox
      Left = 4
      Top = 4
      Width = 139
      Height = 356
      Align = alClient
      ItemHeight = 16
      MultiSelect = True
      TabOrder = 0
      OnClick = lbRowsClick
    end
  end
  object PopupMenu: TPopupMenu
    Left = 128
    Top = 16
    object miEditor: TMenuItem
      Caption = 'Add &editor'
      ShortCut = 45
      OnClick = miEditorClick
    end
    object miCategory: TMenuItem
      Caption = 'Add &category'
      OnClick = miCategoryClick
    end
    object miMultieditor: TMenuItem
      Caption = 'Add &multieditor'
      OnClick = miMultieditorClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miDelete: TMenuItem
      Caption = '&Delete row'
      Enabled = False
      ShortCut = 46
      OnClick = miDeleteClick
    end
    object miClearAll: TMenuItem
      Caption = 'C&lear all'
      Enabled = False
      OnClick = miClearAllClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miSelectAll: TMenuItem
      Caption = 'Select &All'
      Enabled = False
      ShortCut = 16449
      OnClick = miSelectAllClick
    end
  end
end
