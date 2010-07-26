object fmImageComboBoxItemsEditor: TfmImageComboBoxItemsEditor
  Left = 287
  Top = 190
  AutoScroll = False
  Caption = 'fmImageComboBoxItemsEditor'
  ClientHeight = 266
  ClientWidth = 573
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 581
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 480
    Top = 0
    Width = 93
    Height = 266
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 6
      Height = 266
      Align = alLeft
      Shape = bsLeftLine
    end
    object btnAdd: TcxButton
      Left = 6
      Top = 12
      Width = 83
      Height = 22
      Anchors = [akTop, akRight]
      Caption = '&Add'
      TabOrder = 0
      OnClick = btnAddClick
      LookAndFeel.NativeStyle = True
    end
    object btnDelete: TcxButton
      Left = 6
      Top = 76
      Width = 83
      Height = 22
      Anchors = [akTop, akRight]
      Caption = '&Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
      LookAndFeel.NativeStyle = True
    end
    object btnInsert: TcxButton
      Left = 6
      Top = 44
      Width = 83
      Height = 22
      Anchors = [akTop, akRight]
      Caption = '&Insert'
      TabOrder = 1
      OnClick = btnInsertClick
      LookAndFeel.NativeStyle = True
    end
    object btnOk: TcxButton
      Left = 6
      Top = 201
      Width = 83
      Height = 22
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      ModalResult = 1
      TabOrder = 5
      OnClick = btnOkClick
      LookAndFeel.NativeStyle = True
    end
    object btnCancel: TcxButton
      Left = 6
      Top = 233
      Width = 83
      Height = 22
      Anchors = [akRight, akBottom]
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 6
      LookAndFeel.NativeStyle = True
    end
    object btnSelectAll: TcxButton
      Left = 6
      Top = 108
      Width = 83
      Height = 22
      Anchors = [akTop, akRight]
      Caption = '&Select All'
      TabOrder = 3
      OnClick = btnSelectAllClick
      LookAndFeel.NativeStyle = True
    end
    object btnValueType: TcxButton
      Left = 6
      Top = 140
      Width = 83
      Height = 22
      Anchors = [akTop, akRight]
      Caption = 'Set Value&Type'
      TabOrder = 4
      DropDownMenu = mnuValueTypes
      Kind = cxbkDropDown
      LookAndFeel.NativeStyle = True
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 480
    Height = 266
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel3'
    TabOrder = 0
    object cxgImageComboBoxItems: TcxGrid
      Left = 0
      Top = 0
      Width = 480
      Height = 266
      Align = alClient
      TabOrder = 0
      LookAndFeel.NativeStyle = True
      object tvImageComboBoxItems: TcxGridTableView
        OnKeyDown = tvImageComboBoxItemsKeyDown
        NavigatorButtons.ConfirmDelete = False
        OnEditKeyDown = tvImageComboBoxItemsEditKeyDown
        DataController.Summary.DefaultGroupSummaryItems = <>
        DataController.Summary.FooterSummaryItems = <>
        DataController.Summary.SummaryGroups = <>
        DataController.OnRecordChanged = tvImageComboBoxItemsDataControllerRecordChanged
        DataController.Data = {
          960000000F00000044617461436F6E74726F6C6C657231050000001300000054
          6378496E746567657256616C75655479706512000000546378537472696E6756
          616C75655479706512000000546378537472696E6756616C7565547970651200
          0000546378537472696E6756616C75655479706513000000546378496E746567
          657256616C756554797065010000000001010001000000300101}
        OptionsBehavior.CellHints = True
        OptionsBehavior.ImmediateEditor = False
        OptionsBehavior.ColumnHeaderHints = False
        OptionsCustomize.ColumnFiltering = False
        OptionsCustomize.ColumnGrouping = False
        OptionsCustomize.ColumnHidingOnGrouping = False
        OptionsCustomize.ColumnMoving = False
        OptionsData.DeletingConfirmation = False
        OptionsData.Inserting = False
        OptionsSelection.MultiSelect = True
        OptionsSelection.UnselectFocusedRecordOnExit = False
        OptionsView.CellEndEllipsis = True
        OptionsView.ShowEditButtons = gsebAlways
        OptionsView.ColumnAutoWidth = True
        OptionsView.ExpandButtonsForEmptyDetails = False
        OptionsView.GroupByBox = False
        object clnImage: TcxGridColumn
          Caption = 'Image'
          DataBinding.ValueType = 'Integer'
          PropertiesClassName = 'TcxImageComboBoxProperties'
          Properties.Items = <
            item
            end>
          Properties.ShowDescriptions = False
          MinWidth = 36
          Options.HorzSizing = False
          Width = 36
        end
        object clnDescription: TcxGridColumn
          Caption = 'Description'
          Width = 168
        end
        object clnValue: TcxGridColumn
          Caption = 'Value'
          PropertiesClassName = 'TcxTextEditProperties'
          Width = 109
        end
        object clnValueType: TcxGridColumn
          Caption = 'ValueType'
          PropertiesClassName = 'TcxComboBoxProperties'
          Properties.DropDownListStyle = lsFixedList
          Properties.ImmediatePost = True
          Properties.OnEditValueChanged = clnValueTypePropertiesEditValueChanged
          Width = 117
        end
        object clnTag: TcxGridColumn
          Caption = 'Tag'
          DataBinding.ValueType = 'Integer'
          PropertiesClassName = 'TcxMaskEditProperties'
          Properties.MaskKind = emkRegExprEx
          Properties.EditMask = '\d+'
          Width = 51
        end
      end
      object lvImageComboBoxItems: TcxGridLevel
        GridView = tvImageComboBoxItems
      end
    end
  end
  object mnuValueTypes: TPopupMenu
    Left = 390
    Top = 138
    object miAdd: TMenuItem
      Caption = '&Add'
      OnClick = miValueTypeClick
    end
    object miInsert: TMenuItem
      Caption = '&Insert'
    end
    object miDelete: TMenuItem
      Caption = '&Delete'
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miHelp: TMenuItem
      Caption = '&Help'
    end
  end
end
