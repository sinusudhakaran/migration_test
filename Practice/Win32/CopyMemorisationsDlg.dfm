object dlgCopyMemorisations: TdlgCopyMemorisations
  Scaled = False
Left = 236
  Top = 195
  BorderStyle = bsDialog
  Caption = 'Copy Memorisations To'
  ClientHeight = 199
  ClientWidth = 424
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    424
    199)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 225
    Height = 13
    Caption = 'Select an Account to transfer Memorisations to'
  end
  object lblAccountMemorisations: TLabel
    Left = 8
    Top = 68
    Width = 117
    Height = 13
    Caption = 'lblAccountMemorisations'
  end
  object cmbMemorisations: TComboBox
    Left = 8
    Top = 36
    Width = 409
    Height = 21
    Style = csDropDownList
    ItemHeight = 0
    TabOrder = 0
    OnChange = cmbMemorisationsChange
  end
  object radCopyAll: TRadioButton
    Left = 80
    Top = 103
    Width = 241
    Height = 17
    Caption = 'Copy all memorisations'
    TabOrder = 1
  end
  object radCopySelected: TRadioButton
    Left = 80
    Top = 132
    Width = 241
    Height = 17
    Caption = 'Copy selected memorisations only'
    TabOrder = 2
  end
  object btnCopy: TButton
    Left = 252
    Top = 169
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'C&opy'
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 340
    Top = 169
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
