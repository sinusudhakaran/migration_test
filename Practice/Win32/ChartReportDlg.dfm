object DlgChartReport: TDlgChartReport
  Left = 277
  Top = 313
  BorderStyle = bsDialog
  Caption = 'List Chart of Accounts'
  ClientHeight = 149
  ClientWidth = 494
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 141
    Top = 63
    Width = 181
    Height = 13
    Caption = 'Where do you want this report to go?'
    FocusControl = btnCancel
  end
  object btnPreview: TButton
    Left = 6
    Top = 114
    Width = 75
    Height = 25
    Caption = 'Previe&w'
    Default = True
    TabOrder = 2
    OnClick = btnPreviewClick
  end
  object btnFile: TButton
    Left = 87
    Top = 114
    Width = 75
    Height = 25
    Caption = 'Fil&e'
    TabOrder = 3
    OnClick = btnFileClick
  end
  object btnPrint: TButton
    Left = 329
    Top = 114
    Width = 75
    Height = 25
    Caption = '&Print'
    TabOrder = 6
    OnClick = btnPrintClick
  end
  object btnCancel: TButton
    Left = 410
    Top = 114
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 7
    OnClick = btnCancelClick
  end
  object rbFull: TRadioButton
    Left = 141
    Top = 15
    Width = 106
    Height = 16
    Caption = 'Print &Full Chart'
    Checked = True
    TabOrder = 0
    TabStop = True
  end
  object rbBasic: TRadioButton
    Left = 261
    Top = 15
    Width = 122
    Height = 16
    Caption = 'Print &Basic Chart'
    TabOrder = 1
  end
  object BtnSave: TBitBtn
    Left = 248
    Top = 114
    Width = 75
    Height = 25
    Caption = 'Sa&ve'
    TabOrder = 5
    OnClick = BtnSaveClick
  end
  object btnEmail: TButton
    Left = 167
    Top = 114
    Width = 75
    Height = 25
    Caption = 'E&mail'
    TabOrder = 4
    OnClick = btnEmailClick
  end
end
