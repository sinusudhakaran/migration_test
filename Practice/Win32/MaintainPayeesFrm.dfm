object frmMaintainPayees: TfrmMaintainPayees
  Left = 378
  Top = 315
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Maintain Payee List'
  ClientHeight = 420
  ClientWidth = 467
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  PixelsPerInch = 96
  TextHeight = 13
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 467
    Height = 22
    AutoSize = True
    ButtonWidth = 58
    Caption = 'ToolBar1'
    Images = AppImages.Maintain
    List = True
    ShowCaptions = True
    TabOrder = 0
    object tbNew: TToolButton
      Left = 0
      Top = 0
      AutoSize = True
      Caption = 'New'
      ImageIndex = 10
      OnClick = tbNewClick
    end
    object tbEdit: TToolButton
      Left = 52
      Top = 0
      AutoSize = True
      Caption = 'Edit'
      ImageIndex = 11
      OnClick = tbEditClick
    end
    object tbDelete: TToolButton
      Left = 101
      Top = 0
      AutoSize = True
      Caption = 'Delete'
      ImageIndex = 1
      OnClick = tbDeleteClick
    end
    object ToolButton5: TToolButton
      Left = 163
      Top = 0
      Width = 8
      Caption = 'ToolButton5'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object tbMerge: TToolButton
      Left = 171
      Top = 0
      AutoSize = True
      Caption = 'Merge'
      ImageIndex = 15
      OnClick = tbMergeClick
    end
    object ToolButton2: TToolButton
      Left = 232
      Top = 0
      Width = 8
      Caption = 'ToolButton2'
      ImageIndex = 4
      Style = tbsSeparator
    end
    object tbClose: TToolButton
      Left = 240
      Top = 0
      AutoSize = True
      Caption = 'Close'
      ImageIndex = 2
      OnClick = tbCloseClick
    end
    object tbHelpSep: TToolButton
      Left = 297
      Top = 0
      Width = 8
      Caption = 'tbHelpSep'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object tbHelp: TToolButton
      Left = 305
      Top = 0
      Caption = 'Help'
      ImageIndex = 20
      OnClick = tbHelpClick
    end
  end
  object lvPayees: TListView
    Left = 0
    Top = 22
    Width = 467
    Height = 363
    Align = alClient
    Columns = <
      item
        Caption = 'Payee No'
        Width = 100
      end
      item
        Caption = 'Payee Name'
        Width = 250
      end>
    HideSelection = False
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    SmallImages = AppImages.Maintain
    TabOrder = 1
    ViewStyle = vsReport
    OnColumnClick = lvPayeesColumnClick
    OnDblClick = lvPayeesDblClick
    OnKeyPress = lvPayeesKeyPress
    OnSelectItem = lvPayeesSelectItem
    ExplicitWidth = 451
    ExplicitHeight = 398
  end
  object pnlInactive: TPanel
    Left = 0
    Top = 385
    Width = 467
    Height = 35
    Align = alBottom
    TabOrder = 2
    ExplicitWidth = 451
    object chkShowInactive: TCheckBox
      Left = 8
      Top = 8
      Width = 97
      Height = 17
      Caption = 'Show Inactive'
      TabOrder = 0
      OnClick = chkShowInactiveClick
    end
  end
end
