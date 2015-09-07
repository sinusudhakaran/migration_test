object dlgListPayeeOptions: TdlgListPayeeOptions
  Left = 474
  Top = 315
  BorderStyle = bsDialog
  Caption = 'List Payees'
  ClientHeight = 165
  ClientWidth = 483
  Color = clWhite
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
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
  object Panel1: TPanel
    Left = 0
    Top = 124
    Width = 483
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 3
    ExplicitLeft = 8
    ExplicitTop = 208
    ExplicitWidth = 478
    DesignSize = (
      483
      41)
    object ShapeBottom: TShape
      Left = 0
      Top = 0
      Width = 483
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 494
    end
    object btnPreview: TButton
      Left = 4
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Previe&w'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 84
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnOK: TButton
      Left = 325
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Print'
      TabOrder = 2
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 405
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 3
      OnClick = btnCancelClick
    end
    object btnSave: TBitBtn
      Left = 245
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Sa&ve'
      TabOrder = 4
      OnClick = BtnSaveClick
    end
    object btnEmail: TButton
      Left = 165
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'E&mail'
      TabOrder = 5
      OnClick = btnEmailClick
    end
  end
end
