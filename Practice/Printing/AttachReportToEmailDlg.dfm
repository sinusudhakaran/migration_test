object AttachReportToEmailFrm: TAttachReportToEmailFrm
  Left = 468
  Top = 339
  BorderStyle = bsDialog
  Caption = 'Attach Report to Email'
  ClientHeight = 108
  ClientWidth = 481
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    481
    108)
  PixelsPerInch = 96
  TextHeight = 13
  object lblSaveTo: TLabel
    Left = 18
    Top = 44
    Width = 63
    Height = 13
    Caption = 'Report Name'
    FocusControl = edtReportName
  end
  object Label1: TLabel
    Left = 18
    Top = 12
    Width = 34
    Height = 13
    Caption = 'Format'
  end
  object edtReportName: TEdit
    Left = 128
    Top = 40
    Width = 313
    Height = 24
    BorderStyle = bsNone
    TabOrder = 1
  end
  object btnOk: TButton
    Left = 321
    Top = 80
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 2
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 401
    Top = 80
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object cmbFormat: TComboBox
    Left = 128
    Top = 8
    Width = 313
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
  end
end
