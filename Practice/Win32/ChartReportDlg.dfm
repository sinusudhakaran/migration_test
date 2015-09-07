object DlgChartReport: TDlgChartReport
  Left = 277
  Top = 313
  BorderStyle = bsDialog
  Caption = 'List Chart of Accounts'
  ClientHeight = 195
  ClientWidth = 494
  Color = clWhite
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
  object PanelBottom: TPanel
    Left = 0
    Top = 150
    Width = 494
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 2
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 494
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 492
    end
    object btnPreview: TButton
      Left = 6
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Previe&w'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 87
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnEmail: TButton
      Left = 167
      Top = 10
      Width = 75
      Height = 25
      Caption = 'E&mail'
      TabOrder = 2
      OnClick = btnEmailClick
    end
    object BtnSave: TBitBtn
      Left = 248
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Sa&ve'
      TabOrder = 3
      OnClick = BtnSaveClick
    end
    object btnPrint: TButton
      Left = 329
      Top = 10
      Width = 75
      Height = 25
      Caption = '&Print'
      TabOrder = 4
      OnClick = btnPrintClick
    end
    object btnCancel: TButton
      Left = 410
      Top = 10
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 5
      OnClick = btnCancelClick
    end
  end
end
