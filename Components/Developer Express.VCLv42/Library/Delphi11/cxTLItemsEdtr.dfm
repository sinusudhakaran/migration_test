object frmItemsEditor: TfrmItemsEditor
  Left = 243
  Top = 174
  Width = 485
  Height = 374
  Anchors = [akLeft, akTop, akBottom]
  BorderIcons = [biSystemMenu]
  Caption = 'Items Editor'
  Color = clBtnFace
  Constraints.MinHeight = 374
  Constraints.MinWidth = 476
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 477
    Height = 304
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object Panel3: TPanel
      Left = 368
      Top = 0
      Width = 109
      Height = 304
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnNewItem: TcxButton
        Tag = 4
        Left = 10
        Top = 8
        Width = 90
        Height = 22
        Anchors = [akTop, akRight]
        Caption = '&New Item'
        TabOrder = 0
        OnClick = cxButtonPress
      end
      object btnNewSubItem: TcxButton
        Tag = 5
        Left = 10
        Top = 40
        Width = 90
        Height = 22
        Anchors = [akTop, akRight]
        Caption = 'New &SubItem'
        TabOrder = 1
        OnClick = cxButtonPress
      end
      object btnDelete: TcxButton
        Tag = 6
        Left = 10
        Top = 72
        Width = 90
        Height = 22
        Anchors = [akTop, akRight]
        Caption = '&Delete'
        TabOrder = 2
        OnClick = cxButtonPress
      end
      object Panel5: TPanel
        Left = 0
        Top = 100
        Width = 109
        Height = 204
        Align = alBottom
        Anchors = [akLeft, akTop, akRight, akBottom]
        BevelOuter = bvNone
        TabOrder = 3
        object gbIndexes: TGroupBox
          Left = 10
          Top = 7
          Width = 91
          Height = 94
          Anchors = [akTop, akRight]
          Caption = 'Image Indexes'
          TabOrder = 0
          object Label1: TLabel
            Left = 8
            Top = 24
            Width = 29
            Height = 13
            Caption = 'Image'
          end
          object Label2: TLabel
            Left = 8
            Top = 48
            Width = 42
            Height = 13
            Caption = 'Selected'
          end
          object Label3: TLabel
            Left = 8
            Top = 72
            Width = 25
            Height = 13
            Caption = 'State'
          end
          object edtImage: TcxTextEdit
            Left = 59
            Top = 19
            Width = 24
            Height = 21
            TabOrder = 0
            Text = '0'
            OnExit = edtImageExit
            OnKeyDown = edtImageKeyDown
          end
          object edtSelected: TcxTextEdit
            Tag = 1
            Left = 59
            Top = 43
            Width = 24
            Height = 21
            TabOrder = 1
            Text = '0'
            OnExit = edtImageExit
            OnKeyDown = edtImageKeyDown
          end
          object edtState: TcxTextEdit
            Tag = 2
            Left = 59
            Top = 67
            Width = 24
            Height = 21
            TabOrder = 2
            Text = '-1'
            OnExit = edtImageExit
            OnKeyDown = edtImageKeyDown
          end
        end
        object gbDefaultIndexes: TGroupBox
          Left = 10
          Top = 108
          Width = 92
          Height = 94
          Anchors = [akTop, akRight]
          Caption = 'Default Indexes'
          TabOrder = 1
          object Label4: TLabel
            Left = 8
            Top = 24
            Width = 29
            Height = 13
            Caption = 'Image'
          end
          object Label5: TLabel
            Left = 8
            Top = 48
            Width = 42
            Height = 13
            Caption = 'Selected'
          end
          object Label6: TLabel
            Left = 8
            Top = 72
            Width = 25
            Height = 13
            Caption = 'State'
          end
          object edtDefImage: TcxTextEdit
            Left = 59
            Top = 19
            Width = 24
            Height = 21
            TabOrder = 0
            Text = '0'
          end
          object edtDefSelected: TcxTextEdit
            Tag = 1
            Left = 59
            Top = 43
            Width = 24
            Height = 21
            TabOrder = 1
            Text = '0'
          end
          object edtDefState: TcxTextEdit
            Tag = 2
            Left = 59
            Top = 67
            Width = 24
            Height = 21
            TabOrder = 2
            Text = '-1'
          end
        end
      end
    end
    object Panel6: TPanel
      Left = 0
      Top = 0
      Width = 368
      Height = 304
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object Panel7: TPanel
        Left = 0
        Top = 0
        Width = 368
        Height = 8
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
      end
      object Panel10: TPanel
        Left = 0
        Top = 8
        Width = 8
        Height = 294
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 1
      end
      object cxTreeList1: TcxTreeList
        Left = 8
        Top = 8
        Width = 360
        Height = 294
        Align = alClient
        Bands = <
          item
            Caption.Text = 'Band + 1'
          end>
        BufferedPaint = False
        DragMode = dmAutomatic
        OptionsBehavior.AutomateLeftMostIndent = False
        OptionsSelection.HideFocusRect = False
        OptionsSelection.InvertSelect = False
        OptionsSelection.MultiSelect = True
        OptionsView.GridLines = tlglBoth
        OptionsView.PaintStyle = tlpsCategorized
        PopupMenu = mnuEditItems
        Preview.Visible = True
        TabOrder = 2
        OnDragOver = cxTreeList1DragOver
        object cxTreeList1cxTreeListColumn1: TcxTreeListColumn
          DataBinding.ValueType = 'String'
          Position.ColIndex = 0
          Position.RowIndex = 0
          Position.BandIndex = 0
        end
      end
      object Panel8: TPanel
        Left = 0
        Top = 302
        Width = 368
        Height = 2
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 3
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 304
    Width = 477
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnCustomize: TcxButton
      Left = 8
      Top = 6
      Width = 90
      Height = 22
      Anchors = [akLeft, akBottom]
      Caption = 'C&ustomize'
      TabOrder = 0
      OnClick = cxButtonPress
    end
    object Panel4: TPanel
      Left = 250
      Top = 0
      Width = 227
      Height = 36
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object btnOk: TcxButton
        Tag = 1
        Left = 28
        Top = 6
        Width = 90
        Height = 22
        Anchors = [akRight, akBottom]
        Caption = '&Ok'
        ModalResult = 1
        TabOrder = 0
      end
      object btnCancel: TcxButton
        Tag = 2
        Left = 128
        Top = 6
        Width = 90
        Height = 22
        Anchors = [akRight, akBottom]
        Caption = '&Cancel'
        ModalResult = 2
        TabOrder = 1
      end
    end
  end
  object mnuEditItems: TPopupMenu
    Left = 296
    Top = 8
    object NewItem1: TMenuItem
      Tag = 4
      Caption = '&New Item'
      OnClick = cxButtonPress
    end
    object NewSubItem1: TMenuItem
      Tag = 5
      Caption = 'New &SubItem'
      OnClick = cxButtonPress
    end
    object Delete1: TMenuItem
      Tag = 6
      Caption = '&Delete'
      OnClick = cxButtonPress
    end
    object N1: TMenuItem
      Caption = '-'
      OnClick = cxButtonPress
    end
    object Customize1: TMenuItem
      Caption = 'C&ustomize'
      OnClick = cxButtonPress
    end
  end
  object cxLookAndFeelController1: TcxLookAndFeelController
    Left = 328
    Top = 8
  end
end
