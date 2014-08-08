object dlgListPayeeOptions: TdlgListPayeeOptions
  Left = 474
  Top = 315
  BorderStyle = bsDialog
  Caption = 'List Payees'
  ClientHeight = 157
  ClientWidth = 494
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    494
    157)
  PixelsPerInch = 96
  TextHeight = 13
  object btnPreview: TButton
    Left = 8
    Top = 125
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Previe&w'
    Default = True
    TabOrder = 0
    OnClick = btnPreviewClick
  end
  object btnFile: TButton
    Left = 88
    Top = 125
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Fil&e'
    TabOrder = 1
    OnClick = btnFileClick
  end
  object btnOK: TButton
    Left = 330
    Top = 125
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Print'
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 411
    Top = 125
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object btnSave: TBitBtn
    Left = 249
    Top = 125
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Sa&ve'
    TabOrder = 2
    OnClick = BtnSaveClick
  end
  object ckbRuleLineBetweenPayees: TCheckBox
    Left = 8
    Top = 98
    Width = 280
    Height = 17
    Caption = '&Rule a line between payees'
    TabOrder = 5
  end
  object rgSortPayeesBy: TRadioGroup
    Left = 211
    Top = 8
    Width = 195
    Height = 82
    Caption = 'Sort Payees by'
    ItemIndex = 0
    Items.Strings = (
      '&Name'
      'N&umber')
    TabOrder = 6
  end
  object rgReportFormat: TRadioGroup
    Left = 8
    Top = 8
    Width = 195
    Height = 82
    Caption = 'Report Format'
    ItemIndex = 0
    Items.Strings = (
      '&Summarised'
      '&Detailed')
    TabOrder = 7
  end
  object btnEmail: TButton
    Left = 169
    Top = 125
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'E&mail'
    TabOrder = 8
    OnClick = btnEmailClick
  end
end
