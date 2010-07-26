object frmSelect_MYOBAO_GL: TfrmSelect_MYOBAO_GL
  Left = 867
  Top = 243
  BorderStyle = bsDialog
  Caption = 'Select General Ledger'
  ClientHeight = 121
  ClientWidth = 419
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
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
    Width = 65
    Height = 13
    Caption = 'Select &Ledger'
    FocusControl = cmbLedger
  end
  object Label2: TLabel
    Left = 16
    Top = 56
    Width = 58
    Height = 13
    Caption = 'Ledger Path'
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
    Top = 24
    Width = 291
    Height = 22
    Style = csOwnerDrawFixed
    ItemHeight = 16
    TabOrder = 2
    OnChange = cmbLedgerChange
    OnDrawItem = cmbLedgerDrawItem
    OnDropDown = cmbLedgerDropDown
  end
  object lblLedgerPath: TStaticText
    Left = 120
    Top = 52
    Width = 291
    Height = 22
    AutoSize = False
    BorderStyle = sbsSunken
    Caption = 'lblLedgerPath'
    TabOrder = 3
  end
end
