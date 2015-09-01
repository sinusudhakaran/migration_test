object dlgListPayeeOptions: TdlgListPayeeOptions
  Left = 474
  Top = 315
  BorderStyle = bsDialog
  Caption = 'List Payees'
  ClientHeight = 164
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
    164)
  PixelsPerInch = 96
  TextHeight = 13
  object BevelBorder: TBevel
    Left = 0
    Top = 121
    Width = 500
    Height = 12
    Shape = bsTopLine
  end
  object btnPreview: TButton
    Left = 8
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Previe&w'
    Default = True
    TabOrder = 3
    OnClick = btnPreviewClick
    ExplicitTop = 125
  end
  object btnFile: TButton
    Left = 88
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Fil&e'
    TabOrder = 4
    OnClick = btnFileClick
    ExplicitTop = 125
  end
  object btnOK: TButton
    Left = 330
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Print'
    TabOrder = 7
    OnClick = btnOKClick
    ExplicitTop = 125
  end
  object btnCancel: TButton
    Left = 411
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 8
    OnClick = btnCancelClick
    ExplicitTop = 125
  end
  object btnSave: TBitBtn
    Left = 249
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Sa&ve'
    TabOrder = 6
    OnClick = BtnSaveClick
    ExplicitTop = 125
  end
  object ckbRuleLineBetweenPayees: TCheckBox
    Left = 8
    Top = 98
    Width = 280
    Height = 17
    Caption = '&Rule a line between payees'
    TabOrder = 2
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
    TabOrder = 1
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
    TabOrder = 0
  end
  object btnEmail: TButton
    Left = 169
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'E&mail'
    TabOrder = 5
    OnClick = btnEmailClick
    ExplicitTop = 125
  end
end
