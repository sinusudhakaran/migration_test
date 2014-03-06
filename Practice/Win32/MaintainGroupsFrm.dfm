object frmMaintainGroups: TfrmMaintainGroups
  Left = 0
  Top = 0
  Caption = 'Maintain Groups'
  ClientHeight = 293
  ClientWidth = 533
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lvGroups: TListView
    Left = 0
    Top = 22
    Width = 533
    Height = 234
    Align = alClient
    Columns = <
      item
        Caption = 'Code'
        Width = 47
      end
      item
        AutoSize = True
        Caption = 'Name'
      end
      item
        Caption = 'Completed'
        Width = 47
      end>
    HideSelection = False
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    SmallImages = AppImages.Maintain
    SortType = stData
    TabOrder = 0
    ViewStyle = vsReport
    OnColumnClick = lvGroupsColumnClick
    OnCompare = lvGroupsCompare
    OnDblClick = lvGroupsDblClick
    OnKeyPress = lvGroupsKeyPress
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 533
    Height = 22
    AutoSize = True
    ButtonWidth = 58
    Images = AppImages.Maintain
    List = True
    ShowCaptions = True
    TabOrder = 1
    object tbNew: TToolButton
      Left = 0
      Top = 0
      Hint = 'Add a new Group'
      AutoSize = True
      Caption = 'New'
      ImageIndex = 10
      OnClick = tbNewClick
    end
    object tbEdit: TToolButton
      Left = 52
      Top = 0
      Hint = 'Edit the name for the selected Group'
      AutoSize = True
      Caption = 'Edit'
      ImageIndex = 11
      OnClick = tbEditClick
    end
    object tbDelete: TToolButton
      Left = 101
      Top = 0
      Hint = 'Delete the selected Group'
      AutoSize = True
      Caption = 'Delete'
      ImageIndex = 1
      OnClick = tbDeleteClick
    end
    object Sep1: TToolButton
      Left = 163
      Top = 0
      Width = 8
      Caption = 'Sep1'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object tbClose: TToolButton
      Left = 171
      Top = 0
      Hint = 'Close the window'
      AutoSize = True
      Caption = 'Close'
      ImageIndex = 2
      OnClick = tbCloseClick
    end
    object Sep2: TToolButton
      Left = 228
      Top = 0
      Width = 8
      Caption = 'Sep2'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object tbHelp: TToolButton
      Left = 236
      Top = 0
      Hint = 'View help for this feature'
      AutoSize = True
      Caption = 'Help'
      ImageIndex = 20
      OnClick = tbHelpClick
    end
  end
  object pDeleted: TPanel
    Left = 0
    Top = 256
    Width = 533
    Height = 37
    Align = alBottom
    TabOrder = 2
    Visible = False
    object cbCompleted: TCheckBox
      Left = 14
      Top = 6
      Width = 122
      Height = 16
      Hint = 'Include completed Jobs'
      Caption = 'Show completed'
      TabOrder = 0
      Visible = False
      OnClick = cbCompletedClick
    end
    object btnAddJob: TButton
      Left = 14
      Top = 5
      Width = 71
      Height = 25
      Caption = 'Add Job'
      TabOrder = 1
      Visible = False
      OnClick = tbNewClick
    end
    object btnOK: TButton
      Left = 450
      Top = 6
      Width = 77
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 2
      Visible = False
    end
  end
end
