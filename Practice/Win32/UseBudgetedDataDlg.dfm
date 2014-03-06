object dlgUseBudgetedData: TdlgUseBudgetedData
  Left = 354
  Top = 301
  BorderStyle = bsDialog
  Caption = 'Use budget data?'
  ClientHeight = 174
  ClientWidth = 533
  Color = clWindow
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    533
    174)
  PixelsPerInch = 96
  TextHeight = 13
  object lblMessage: TLabel
    Left = 16
    Top = 16
    Width = 509
    Height = 66
    AutoSize = False
    Caption = 'Actual data...'
    WordWrap = True
  end
  object lblBudget: TLabel
    Left = 16
    Top = 96
    Width = 67
    Height = 13
    Caption = 'Budget to use'
  end
  object btnYes: TButton
    Left = 369
    Top = 141
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Yes'
    Default = True
    ModalResult = 6
    TabOrder = 1
  end
  object btnNo: TButton
    Left = 450
    Top = 141
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'No'
    ModalResult = 7
    TabOrder = 2
  end
  object cmbBudget: TComboBox
    Left = 124
    Top = 92
    Width = 401
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
  end
end
