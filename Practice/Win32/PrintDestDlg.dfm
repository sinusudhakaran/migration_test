object DlgPrintDest: TDlgPrintDest
  Scaled = False
Left = 324
  Top = 307
  BorderStyle = bsDialog
  Caption = 'Select Report Destination'
  ClientHeight = 222
  ClientWidth = 463
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lDestination: TLabel
    Left = 3
    Top = 8
    Width = 409
    Height = 25
    AutoSize = False
    Caption = 'Where do you want this report to go?'
    WordWrap = True
  end
  object pBtn: TPanel
    Left = 0
    Top = 190
    Width = 463
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      463
      32)
    object btnPreview: TButton
      Left = 6
      Top = 4
      Width = 76
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Previe&w'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnPrint: TButton
      Left = 301
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Print'
      TabOrder = 1
      OnClick = btnPrintClick
    end
    object btnCancel: TButton
      Left = 381
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
    object btnFile: TButton
      Left = 88
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      TabOrder = 3
      OnClick = btnFileClick
    end
    object btnSave: TBitBtn
      Left = 221
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Sa&ve'
      TabOrder = 4
      OnClick = btnSaveClick
    end
  end
  inline fmeAccountSelector1: TfmeAccountSelector
    Left = 0
    Top = 0
    Width = 460
    Height = 188
    TabOrder = 1
    TabStop = True
  end
end
