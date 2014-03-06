object dlgListCharges: TdlgListCharges
  Scaled = False
Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'List Charges'
  ClientHeight = 112
  ClientWidth = 542
  Color = clBtnFace
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
  DesignSize = (
    542
    112)
  PixelsPerInch = 96
  TextHeight = 13
  object lblShowCharges: TLabel
    Left = 8
    Top = 28
    Width = 92
    Height = 13
    Caption = 'Show charges from'
  end
  object btnCancel: TButton
    Left = 457
    Top = 79
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 0
    OnClick = btnCancelClick
  end
  object btnPrint: TButton
    Left = 376
    Top = 79
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Print'
    Default = True
    TabOrder = 1
    OnClick = btnPrintClick
  end
  object cmbMonths: TComboBox
    Left = 128
    Top = 24
    Width = 409
    Height = 26
    Style = csOwnerDrawFixed
    DropDownCount = 12
    ItemHeight = 20
    TabOrder = 2
    OnChange = cmbMonthsChange
    OnDrawItem = cmbMonthsDrawItem
  end
  object btnPreview: TButton
    Left = 8
    Top = 79
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Previe&w'
    TabOrder = 3
    OnClick = btnPreviewClick
  end
  object btnFile: TButton
    Left = 89
    Top = 79
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Fil&e'
    TabOrder = 4
    OnClick = btnFileClick
  end
end
