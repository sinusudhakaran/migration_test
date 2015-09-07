object dlgAdminAccountOptions: TdlgAdminAccountOptions
  Left = 358
  Top = 192
  BorderIcons = [biSystemMenu]
  Caption = 'Download Report'
  ClientHeight = 158
  ClientWidth = 513
  Color = clWhite
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object gbOptions: TGroupBox
    Left = 0
    Top = 0
    Width = 513
    Height = 117
    Align = alClient
    Caption = 'Report Options'
    TabOrder = 0
    DesignSize = (
      513
      117)
    object chkIncludeDeleted: TCheckBox
      Left = 8
      Top = 94
      Width = 297
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Include &Bank Accounts marked as deleted'
      TabOrder = 0
    end
    object GBInactive: TGroupBox
      Left = 8
      Top = 30
      Width = 481
      Height = 41
      TabOrder = 1
      object Label1: TLabel
        Left = 3
        Top = 12
        Width = 172
        Height = 13
        Caption = 'Accounts without transactions after'
      end
      object CBdates: TComboBox
        Left = 224
        Top = 12
        Width = 249
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 117
    Width = 513
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 1
    DesignSize = (
      513
      41)
    object btnPreview: TButton
      Left = 8
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
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnPrint: TButton
      Left = 352
      Top = 10
      Width = 75
      Height = 23
      Anchors = [akRight, akBottom]
      Caption = '&Print'
      TabOrder = 2
      OnClick = btnPrintClick
    end
    object btnCancel: TButton
      Left = 432
      Top = 10
      Width = 75
      Height = 23
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 3
      OnClick = btnCancelClick
    end
  end
end
