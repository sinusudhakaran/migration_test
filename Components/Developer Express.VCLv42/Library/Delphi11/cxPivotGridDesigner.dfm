object frmPivotGridDesigner: TfrmPivotGridDesigner
  Left = 253
  Top = 245
  AutoScroll = False
  BorderIcons = [biSystemMenu, biHelp]
  Caption = 'PivotGrid Designer'
  ClientHeight = 368
  ClientWidth = 442
  Color = clBtnFace
  Constraints.MinHeight = 402
  Constraints.MinWidth = 450
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pcDesigner: TPageControl
    Left = 0
    Top = 0
    Width = 442
    Height = 329
    ActivePage = tbsFields
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tbsFields: TTabSheet
      Caption = '&Fields'
      OnStartDrag = tbsFieldsStartDrag
      object btnDelete: TcxButton
        Tag = 1
        Left = 325
        Top = 43
        Width = 100
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Delete'
        TabOrder = 2
        OnClick = btnFieldsPageClick
      end
      object btnMoveUp: TcxButton
        Tag = 2
        Left = 325
        Top = 75
        Width = 100
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Move &Up'
        TabOrder = 3
        OnClick = btnFieldsPageClick
      end
      object btnAdd: TcxButton
        Left = 325
        Top = 10
        Width = 100
        Height = 25
        Anchors = [akTop, akRight]
        Caption = '&Add '
        TabOrder = 1
        OnClick = btnFieldsPageClick
      end
      object btnMoveDown: TcxButton
        Tag = 3
        Left = 325
        Top = 107
        Width = 100
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Move &Down'
        TabOrder = 4
        OnClick = btnFieldsPageClick
      end
      object btnRetrieveFields: TcxButton
        Tag = 4
        Left = 325
        Top = 140
        Width = 100
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Retrieve &Fields'
        TabOrder = 5
        OnClick = btnFieldsPageClick
      end
      object lbFields: TcxListBox
        Left = 8
        Top = 9
        Width = 306
        Height = 281
        Anchors = [akLeft, akTop, akRight, akBottom]
        DragMode = dmAutomatic
        ItemHeight = 13
        MultiSelect = True
        PopupMenu = pmFields
        TabOrder = 0
        OnClick = lbFieldsClick
        OnDragDrop = lbFieldsDragDrop
        OnDragOver = lbFieldsDragOver
        OnEndDrag = lbFieldsEndDrag
      end
    end
    object tbsGroups: TTabSheet
      Caption = '&Groups'
      ImageIndex = 1
      OnResize = tbsGroupsResize
      object pnlGroups: TPanel
        Left = 0
        Top = 0
        Width = 177
        Height = 301
        Align = alLeft
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 11
          Top = 6
          Width = 37
          Height = 13
          Caption = 'Groups:'
        end
        object tvGroups: TcxTreeView
          Left = 8
          Top = 26
          Width = 160
          Height = 265
          Anchors = [akLeft, akTop, akRight, akBottom]
          PopupMenu = pmGroups
          TabOrder = 0
          OnClick = tvGroupsClick
          OnDblClick = tvGroupsDblClick
          OnDragDrop = tvGroupsDragDrop
          OnDragOver = tvGroupsDragOver
          OnKeyUp = tvGroupsKeyUp
          OnMouseDown = tvGroupsMouseDown
          OnChange = tvGroupsChange
          OnCustomDrawItem = tvGroupsCustomDrawItem
          OnEditing = tvGroupsEditing
          OnEdited = tvGroupsEdited
        end
      end
      object pnlGroupUngroup: TPanel
        Left = 177
        Top = 0
        Width = 80
        Height = 301
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
        object btnUnlink: TcxButton
          Tag = 2
          Left = 1
          Top = 101
          Width = 78
          Height = 25
          Anchors = [akTop]
          Caption = '>'
          TabOrder = 0
          OnClick = btnGroupClick
        end
        object btnLink: TcxButton
          Tag = 3
          Left = 1
          Top = 136
          Width = 78
          Height = 25
          Anchors = [akTop]
          Caption = '<'
          TabOrder = 1
          OnClick = btnGroupClick
        end
        object btnAddGroup: TcxButton
          Left = 1
          Top = 32
          Width = 78
          Height = 25
          Anchors = [akTop]
          Caption = '&Add'
          TabOrder = 2
          OnClick = btnGroupClick
        end
        object btnDeleteGroup: TcxButton
          Tag = 1
          Left = 1
          Top = 66
          Width = 78
          Height = 25
          Anchors = [akTop]
          Caption = '&Delete'
          TabOrder = 3
          OnClick = btnGroupClick
        end
        object btnMoveUpGroup: TcxButton
          Tag = 2
          Left = 1
          Top = 171
          Width = 78
          Height = 25
          Anchors = [akTop]
          Caption = 'Move &Up'
          TabOrder = 4
          OnClick = miMoveInGroupClick
        end
        object btnMoveDownGroup: TcxButton
          Tag = 3
          Left = 1
          Top = 206
          Width = 78
          Height = 25
          Anchors = [akTop]
          Caption = 'Move &Down'
          TabOrder = 5
          OnClick = miMoveInGroupClick
        end
      end
      object pnlUnlinked: TPanel
        Left = 257
        Top = 0
        Width = 177
        Height = 301
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 2
        object Label2: TLabel
          Left = 11
          Top = 8
          Width = 72
          Height = 13
          Caption = 'Unlinked fields:'
        end
        object lbUnlinkedFields: TcxListBox
          Left = 8
          Top = 26
          Width = 160
          Height = 265
          Anchors = [akLeft, akTop, akRight, akBottom]
          DragMode = dmAutomatic
          ItemHeight = 13
          MultiSelect = True
          TabOrder = 0
          OnClick = lbUnlinkedFieldsClick
          OnDblClick = lbUnlinkedFieldsDblClick
        end
      end
    end
  end
  object btnClose: TcxButton
    Left = 352
    Top = 335
    Width = 80
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Close'
    Default = True
    ModalResult = 1
    TabOrder = 1
    OnClick = btnCloseClick
  end
  object pmFields: TPopupMenu
    Left = 36
    Top = 336
    object miAdd: TMenuItem
      Caption = 'Add'
      ShortCut = 45
      OnClick = btnFieldsPageClick
    end
    object miDelete: TMenuItem
      Tag = 1
      Caption = 'Delete'
      ShortCut = 46
      OnClick = btnFieldsPageClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miMoveUp: TMenuItem
      Tag = 2
      Caption = 'Move Up'
      ShortCut = 16422
      OnClick = btnFieldsPageClick
    end
    object miMoveDown: TMenuItem
      Tag = 3
      Caption = 'Move Down'
      ShortCut = 16424
      OnClick = btnFieldsPageClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object miSelectAll: TMenuItem
      Tag = 5
      Caption = 'Select All'
      ShortCut = 16449
      OnClick = btnFieldsPageClick
    end
  end
  object pmGroups: TPopupMenu
    Left = 76
    Top = 336
    object miAddGroup: TMenuItem
      Caption = 'Add'
      ShortCut = 45
      OnClick = btnGroupClick
    end
    object miDeleteGroup: TMenuItem
      Tag = 1
      Caption = 'Delete'
      ShortCut = 46
      OnClick = btnGroupClick
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object miMoveUpInGroup: TMenuItem
      Tag = 2
      Caption = 'Move Up'
      ShortCut = 16422
      OnClick = miMoveInGroupClick
    end
    object miMoveDownInGroup: TMenuItem
      Tag = 3
      Caption = 'Move Down'
      ShortCut = 16424
      OnClick = miMoveInGroupClick
    end
  end
end
