object dlgDownloadReportOptions: TdlgDownloadReportOptions
  Left = 358
  Top = 192
  BorderIcons = [biSystemMenu]
  Caption = 'Download Report'
  ClientHeight = 345
  ClientWidth = 519
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    519
    345)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 8
    Width = 263
    Height = 13
    Caption = 'Please select the detail you want to see on this report.'
  end
  object btnPreview: TButton
    Left = 8
    Top = 311
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Previe&w'
    Default = True
    DragCursor = crDefault
    TabOrder = 4
    OnClick = btnPreviewClick
  end
  object btnFile: TButton
    Left = 88
    Top = 311
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Fil&e'
    TabOrder = 5
    OnClick = btnFileClick
  end
  object btnCancel: TButton
    Left = 434
    Top = 311
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = btnCancelClick
  end
  object btnPrint: TButton
    Left = 354
    Top = 311
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Print'
    TabOrder = 6
    OnClick = btnPrintClick
  end
  object chkHideDeleted: TCheckBox
    Left = 16
    Top = 264
    Width = 425
    Height = 17
    Caption = 'Hide &Bank Accounts that have been marked as deleted'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object Panel1: TPanel
    Left = 16
    Top = 32
    Width = 400
    Height = 217
    TabOrder = 0
    object chkActive: TCheckBox
      Left = 17
      Top = 49
      Width = 360
      Height = 17
      Caption = 'Active Accounts (received entries in the last download)'
      TabOrder = 1
    end
    object chkInactive: TCheckBox
      Left = 17
      Top = 83
      Width = 360
      Height = 17
      Caption = 'Inactive Accounts (no entries in the last download)'
      TabOrder = 2
    end
    object chkNew: TCheckBox
      Left = 17
      Top = 116
      Width = 360
      Height = 17
      Caption = 'New Accounts '
      TabOrder = 3
    end
    object chkMissing: TCheckBox
      Left = 17
      Top = 150
      Width = 360
      Height = 17
      Caption = 'Deleted Accounts (accounts not received in last download)'
      TabOrder = 4
    end
    object chkNotAllocated: TCheckBox
      Left = 17
      Top = 184
      Width = 360
      Height = 17
      Caption = 'Accounts that have not been allocated to a client'
      TabOrder = 5
    end
    object chkAll: TCheckBox
      Left = 17
      Top = 16
      Width = 360
      Height = 17
      Caption = 'Complete list of accounts'
      TabOrder = 0
    end
  end
  object btnAll: TButton
    Left = 432
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Select All'
    TabOrder = 1
    OnClick = btnAllClick
  end
  object btnClear: TButton
    Left = 432
    Top = 64
    Width = 75
    Height = 25
    Caption = 'Clear All'
    TabOrder = 2
    OnClick = btnClearClick
  end
end
