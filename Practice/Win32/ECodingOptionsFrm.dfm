object frmECodingOptions: TfrmECodingOptions
  Scaled = False
Left = 298
  Top = 236
  BorderStyle = bsDialog
  Caption = 'ECoding Options'
  ClientHeight = 364
  ClientWidth = 496
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    496
    364)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 4
    Top = 4
    Width = 489
    Height = 326
    Anchors = [akLeft, akTop, akBottom]
    Shape = bsFrame
    ExplicitHeight = 241
  end
  object btnOk: TButton
    Left = 336
    Top = 334
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 416
    Top = 334
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  inline ecExportOptions: TfmeECodingExport
    Left = 5
    Top = 5
    Width = 484
    Height = 323
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 0
    TabStop = True
    ExplicitLeft = 5
    ExplicitTop = 5
    ExplicitWidth = 484
    ExplicitHeight = 323
    inherited lblPassword: TLabel
      FocusControl = ecExportOptions.edtPassword
    end
    inherited edtPassword: TEdit
      Height = 21
      ExplicitHeight = 21
    end
    inherited edtConfirm: TEdit
      Height = 21
      ExplicitHeight = 21
    end
  end
end
