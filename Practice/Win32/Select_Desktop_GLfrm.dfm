object frmSelect_Desktop_GL: TfrmSelect_Desktop_GL
  Scaled = False
Left = 867
  Top = 243
  BorderStyle = bsDialog
  Caption = 'Select Fund'
  ClientHeight = 121
  ClientWidth = 419
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
  DesignSize = (
    419
    121)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 56
    Height = 13
    Caption = 'Select &Fund'
    FocusControl = cmbLedger
  end
  object Label2: TLabel
    Left = 16
    Top = 56
    Width = 52
    Height = 13
    Caption = 'Fund Code'
  end
  object lblLedgerPath: TLabel
    Left = 120
    Top = 56
    Width = 40
    Height = 16
    Caption = 'ZAPT'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnSelect: TButton
    Left = 248
    Top = 90
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Select'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancl: TButton
    Left = 336
    Top = 90
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object cmbLedger: TComboBox
    Left = 120
    Top = 21
    Width = 241
    Height = 22
    Style = csOwnerDrawFixed
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 2
    OnChange = cmbLedgerChange
    OnDrawItem = cmbLedgerDrawItem
    OnDropDown = cmbLedgerDropDown
  end
end
