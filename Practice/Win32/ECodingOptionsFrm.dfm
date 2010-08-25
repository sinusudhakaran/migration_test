object frmECodingOptions: TfrmECodingOptions
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
    ExplicitTop = 289
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
    ExplicitTop = 289
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
    ExplicitHeight = 278
    inherited lblPassword: TLabel
      FocusControl = ecExportOptions.edtPassword
    end
    inherited cmbInclude: TComboBox
      TabOrder = 9
    end
    inherited chkIncludeChart: TCheckBox
      TabOrder = 8
    end
    inherited chkIncludePayees: TCheckBox
      TabOrder = 7
    end
    inherited chkShowQuantity: TCheckBox
      TabOrder = 1
    end
    inherited chkShowGST: TCheckBox
      TabOrder = 2
    end
    inherited chkShowTaxInv: TCheckBox
      TabOrder = 0
    end
    inherited chkShowAccount: TCheckBox
      TabOrder = 3
    end
    inherited chkAddUPIs: TCheckBox
      TabOrder = 4
    end
    inherited cmbWebSpace: TComboBox
      Left = 168
      ExplicitLeft = 168
    end
    inherited ChkSuperfund: TCheckBox
      TabOrder = 5
    end
    inherited chkIncludeJobs: TCheckBox
      TabOrder = 6
    end
  end
end
