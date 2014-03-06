object dlgAdminAccountOptions: TdlgAdminAccountOptions
  Scaled = False
Left = 358
  Top = 192
  BorderIcons = [biSystemMenu]
  Caption = 'Download Report'
  ClientHeight = 151
  ClientWidth = 513
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    513
    151)
  PixelsPerInch = 96
  TextHeight = 13
  object btnPreview: TButton
    Left = 8
    Top = 118
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Preview'
    Default = True
    DragCursor = crDefault
    TabOrder = 0
    OnClick = btnPreviewClick
  end
  object btnFile: TButton
    Left = 88
    Top = 118
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'File'
    TabOrder = 1
    OnClick = btnFileClick
  end
  object btnCancel: TButton
    Left = 428
    Top = 119
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = btnCancelClick
  end
  object btnPrint: TButton
    Left = 348
    Top = 119
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'Print'
    TabOrder = 2
    OnClick = btnPrintClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 496
    Height = 102
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Report Options'
    TabOrder = 4
    DesignSize = (
      496
      102)
    object chkIncludeDeleted: TCheckBox
      Left = 8
      Top = 79
      Width = 297
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Include &Bank Accounts marked as deleted'
      TabOrder = 0
    end
    object GBInactive: TGroupBox
      Left = 8
      Top = 16
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
end
