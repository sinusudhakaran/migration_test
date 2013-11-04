object frmTPA: TfrmTPA
  Left = 236
  Top = 116
  BorderIcons = [biSystemMenu]
  Caption = 'Third Party Authority'
  ClientHeight = 447
  ClientWidth = 692
  Color = clBtnFace
  Constraints.MinWidth = 640
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel6: TPanel
    Left = 0
    Top = 406
    Width = 692
    Height = 41
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      692
      41)
    object btnPreview: TButton
      Left = 16
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Preview the Third Party Authority Form'
      Caption = 'Preview'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 107
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Save the Third Party Authority Form to a file'
      Caption = 'File'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnCancel: TButton
      Left = 603
      Top = 8
      Width = 80
      Height = 25
      Hint = 'Close the Third Party Authority Form'
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = btnCancelClick
    end
    object btnPrint: TButton
      Left = 422
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Print the Third Party Authority Form'
      Anchors = [akRight, akBottom]
      Caption = 'Print'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = btnPrintClick
    end
    object btnEmail: TButton
      Left = 197
      Top = 8
      Width = 85
      Height = 25
      Hint = 'E-mail the Third Party Authority Form to the client'
      Caption = 'E-mail'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = btnEmailClick
    end
    object btnClear: TButton
      Left = 513
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Clear the form'
      Anchors = [akRight, akBottom]
      Caption = 'Reset Form'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = btnClearClick
    end
    object btnImport: TButton
      Left = 340
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Import'
      TabOrder = 6
      OnClick = btnImportClick
    end
  end
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 692
    Height = 406
    Align = alClient
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    ExplicitTop = 2
    object pnlAccount: TPanel
      Left = 0
      Top = 73
      Width = 688
      Height = 96
      Align = alTop
      TabOrder = 0
      object lblAcName: TLabel
        Left = 13
        Top = 10
        Width = 86
        Height = 13
        Caption = 'Name of Account '
      end
      object lblAcNum: TLabel
        Left = 13
        Top = 48
        Width = 83
        Height = 13
        Caption = 'Account Number '
      end
      object lblClient: TLabel
        Left = 416
        Top = 7
        Width = 57
        Height = 13
        Caption = 'Client Code '
      end
      object lblCost: TLabel
        Left = 416
        Top = 52
        Width = 52
        Height = 13
        Caption = 'Cost Code '
      end
      object lblAccountNumberLine: TLabel
        Left = 112
        Top = 64
        Width = 281
        Height = 21
        Alignment = taCenter
        AutoSize = False
      end
      object lblAccountNumberHint: TLabel
        Left = 232
        Top = 64
        Width = 3
        Height = 13
      end
      object lblAccountValidationError: TLabel
        Left = 112
        Top = 28
        Width = 118
        Height = 13
        Caption = 'lblAccountValidationError'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object edtAccountName: TEdit
        Left = 112
        Top = 6
        Width = 281
        Height = 21
        Hint = 'Enter the account name'
        MaxLength = 50
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnExit = edtExit
      end
      object edtClientCode: TEdit
        Left = 493
        Top = 6
        Width = 160
        Height = 21
        Hint = 'Enter the code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
      object edtCost1: TEdit
        Left = 493
        Top = 48
        Width = 160
        Height = 21
        Hint = 'Enter the cost code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
      object mskAccountNumber: TMaskEdit
        Left = 112
        Top = 45
        Width = 281
        Height = 21
        TabOrder = 3
        OnEnter = mskAccountNumberEnter
        OnExit = mskAccountNumberExit
        OnKeyUp = mskAccountNumberKeyUp
        OnMouseDown = mskAccountNumberMouseDown
      end
    end
    object pnlInstitution: TPanel
      Left = 0
      Top = 0
      Width = 688
      Height = 73
      Align = alTop
      TabOrder = 1
      ExplicitLeft = -1
      object lblInstitution: TLabel
        Left = 16
        Top = 11
        Width = 51
        Height = 13
        Caption = 'Institution :'
      end
      object cmbInstitutionName: TComboBox
        Left = 112
        Top = 8
        Width = 281
        Height = 21
        ItemHeight = 13
        TabOrder = 0
        OnChange = cmbInstitutionNameChange
      end
    end
  end
  object Opendlg: TOpenDialog
    Filter = 'Excel file*.xls|*.xls'
    Left = 640
    Top = 272
  end
end
