object frmBillingDocReader: TfrmBillingDocReader
  Scaled = False
Left = 514
  Top = 515
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Statements and Download Documents'
  ClientHeight = 130
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
  DesignSize = (
    542
    130)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 28
    Width = 76
    Height = 13
    Caption = 'Show document'
  end
  object btnPDF: TButton
    Left = 368
    Top = 97
    Width = 80
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Create &PDF'
    Default = True
    TabOrder = 1
    OnClick = btnPDFClick
  end
  object btnCancel: TButton
    Left = 457
    Top = 97
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object cmbImages: TComboBox
    Left = 128
    Top = 24
    Width = 409
    Height = 26
    Style = csOwnerDrawFixed
    DropDownCount = 12
    ItemHeight = 20
    TabOrder = 0
    OnDrawItem = cmbImagesDrawItem
  end
  object cbIncludeInterimReports: TCheckBox
    Left = 128
    Top = 66
    Width = 175
    Height = 17
    Caption = 'Include Interim Reports'
    TabOrder = 3
    OnClick = cbIncludeInterimReportsClick
  end
end
