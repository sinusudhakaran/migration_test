object frmBillingDocReader: TfrmBillingDocReader
  Left = 514
  Top = 515
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Statements and Download Documents'
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
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 28
    Width = 76
    Height = 13
    Caption = 'Show document'
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
    TabOrder = 1
    OnClick = cbIncludeInterimReportsClick
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
    TabOrder = 2
    ExplicitTop = 88
    ExplicitWidth = 362
    DesignSize = (
      542
      41)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 542
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnPDF: TButton
      Left = 374
      Top = 7
      Width = 80
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Create &PDF'
      Default = True
      TabOrder = 0
      OnClick = btnPDFClick
    end
    object btnCancel: TButton
      Left = 460
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
