object DlgPrintDest: TDlgPrintDest
  Left = 324
  Top = 307
  BorderStyle = bsDialog
  Caption = 'Select Report Destination'
  ClientHeight = 222
  ClientWidth = 546
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
    Width = 546
    Height = 32
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      546
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
      Left = 384
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Print'
      TabOrder = 1
      OnClick = btnPrintClick
    end
    object btnCancel: TButton
      Left = 464
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
      Left = 304
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Sa&ve'
      TabOrder = 4
      OnClick = btnSaveClick
    end
    object btnEmail: TButton
      Left = 169
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'E&mail'
      TabOrder = 5
      OnClick = btnEmailClick
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
