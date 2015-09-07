object dlgListCharges: TdlgListCharges
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'List Charges'
  ClientHeight = 130
  ClientWidth = 542
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblShowCharges: TLabel
    Left = 8
    Top = 28
    Width = 92
    Height = 13
    Caption = 'Show charges from'
  end
  object cmbMonths: TComboBox
    Left = 128
    Top = 24
    Width = 407
    Height = 26
    Style = csOwnerDrawFixed
    DropDownCount = 12
    ItemHeight = 20
    TabOrder = 0
    OnChange = cmbMonthsChange
    OnDrawItem = cmbMonthsDrawItem
  end
  object pnlControls: TPanel
    Left = 0
    Top = 89
    Width = 542
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 1
    DesignSize = (
      542
      41)
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 542
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnPreview: TButton
      Left = 9
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Previe&w'
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 90
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnPrint: TButton
      Left = 377
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Print'
      Default = True
      TabOrder = 2
      OnClick = btnPrintClick
    end
    object btnCancel: TButton
      Left = 459
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 3
      OnClick = btnCancelClick
    end
  end
end
