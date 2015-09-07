object dlgDownloadReportOptions: TdlgDownloadReportOptions
  Left = 358
  Top = 192
  BorderIcons = [biSystemMenu]
  Caption = 'Download Report'
  ClientHeight = 345
  ClientWidth = 519
  Color = clWhite
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 8
    Width = 263
    Height = 13
    Caption = 'Please select the detail you want to see on this report.'
  end
  object ShapeBorder: TShape
    Left = 15
    Top = 29
    Width = 404
    Height = 221
    Pen.Color = clSilver
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
    BevelOuter = bvNone
    TabOrder = 0
    object chkActive: TCheckBox
      Left = 17
      Top = 49
      Width = 360
      Height = 17
      Caption = 'Active Accounts (received entries in the last download)'
      Color = clWhite
      ParentColor = False
      TabOrder = 1
    end
    object chkInactive: TCheckBox
      Left = 17
      Top = 83
      Width = 360
      Height = 17
      Caption = 'Inactive Accounts (no entries in the last download)'
      Color = clWhite
      ParentColor = False
      TabOrder = 2
    end
    object chkNew: TCheckBox
      Left = 17
      Top = 116
      Width = 360
      Height = 17
      Caption = 'New Accounts '
      Color = clWhite
      ParentColor = False
      TabOrder = 3
    end
    object chkMissing: TCheckBox
      Left = 17
      Top = 150
      Width = 360
      Height = 17
      Caption = 'Deleted Accounts (accounts not received in last download)'
      Color = clWhite
      ParentColor = False
      TabOrder = 4
    end
    object chkNotAllocated: TCheckBox
      Left = 17
      Top = 184
      Width = 360
      Height = 17
      Caption = 'Accounts that have not been allocated to a client'
      Color = clWhite
      ParentColor = False
      TabOrder = 5
    end
    object chkAll: TCheckBox
      Left = 17
      Top = 16
      Width = 360
      Height = 17
      Caption = 'Complete list of accounts'
      Color = clWhite
      ParentColor = False
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
  object Panel2: TPanel
    Left = 0
    Top = 304
    Width = 519
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 4
    ExplicitLeft = 24
    ExplicitTop = 280
    ExplicitWidth = 487
    DesignSize = (
      519
      41)
    object ShapeBottom: TShape
      Left = 0
      Top = 0
      Width = 519
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnPreview: TButton
      Left = 4
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Previe&w'
      Default = True
      DragCursor = crDefault
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 84
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnCancel: TButton
      Left = 440
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
      ExplicitLeft = 408
    end
    object btnPrint: TButton
      Left = 360
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Print'
      TabOrder = 3
      OnClick = btnPrintClick
    end
  end
end
