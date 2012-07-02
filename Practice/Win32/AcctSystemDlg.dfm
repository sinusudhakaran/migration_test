object dlgAcctSystem: TdlgAcctSystem
  Left = 473
  Top = 83
  BorderStyle = bsDialog
  Caption = 'Maintain Accounting System'
  ClientHeight = 540
  ClientWidth = 520
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    520
    540)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 356
    Top = 510
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 5
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 437
    Top = 510
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 6
    OnClick = btnCancelClick
  end
  object gbType: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 3
    Width = 504
    Height = 50
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 0
    object lblLoadDefaults: TLabel
      Left = 16
      Top = 20
      Width = 62
      Height = 13
      Caption = 'System Type'
      FocusControl = cmbSystem
    end
    object rbAccounting: TRadioButton
      Left = 140
      Top = 19
      Width = 113
      Height = 17
      Caption = 'Ac&counting'
      TabOrder = 0
      OnClick = rbAccountingClick
    end
    object rbSuper: TRadioButton
      Left = 310
      Top = 19
      Width = 113
      Height = 17
      Caption = 'Superf&und'
      TabOrder = 1
      OnClick = rbAccountingClick
    end
  end
  object gbxAccounting: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 56
    Width = 504
    Height = 237
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 1
    DesignSize = (
      504
      237)
    object lblFrom: TLabel
      Left = 16
      Top = 144
      Width = 80
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Loa&d Chart From'
      FocusControl = eFrom
    end
    object lblSaveTo: TLabel
      Left = 16
      Top = 176
      Width = 75
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Save &Entries To'
      FocusControl = eTo
    end
    object btnFromFolder: TSpeedButton
      Left = 462
      Top = 139
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      Anchors = [akLeft, akBottom]
      OnClick = btnFromFolderClick
    end
    object btnToFolder: TSpeedButton
      Left = 462
      Top = 171
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      Anchors = [akLeft, akBottom]
      OnClick = btnToFolderClick
    end
    object Label1: TLabel
      Left = 16
      Top = 16
      Width = 62
      Height = 13
      Caption = '&System Used'
      FocusControl = cmbSystem
    end
    object Label2: TLabel
      Left = 16
      Top = 48
      Width = 66
      Height = 13
      Caption = '&Account Mask'
      FocusControl = eMask
    end
    object eFrom: TEdit
      Left = 140
      Top = 141
      Width = 317
      Height = 21
      Anchors = [akLeft, akBottom]
      TabOrder = 4
      Text = 'eFrom'
      OnChange = eFromChange
    end
    object eTo: TEdit
      Left = 140
      Top = 173
      Width = 317
      Height = 21
      Anchors = [akLeft, akBottom]
      TabOrder = 5
      Text = 'eTo'
    end
    object btnCheckBankManID: TButton
      Left = 140
      Top = 201
      Width = 129
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Set &BankLink ID'
      TabOrder = 6
      OnClick = btnCheckBankManIDClick
    end
    object cmbSystem: TComboBox
      Left = 140
      Top = 13
      Width = 347
      Height = 21
      Style = csDropDownList
      ItemHeight = 0
      Sorted = True
      TabOrder = 0
      OnChange = cmbSystemChange
    end
    object eMask: TEdit
      Left = 140
      Top = 45
      Width = 201
      Height = 21
      MaxLength = 10
      TabOrder = 1
      Text = 'eMask'
    end
    object chkLockChart: TCheckBox
      Left = 140
      Top = 75
      Width = 201
      Height = 17
      Caption = 'Loc&k Chart of Accounts'
      TabOrder = 3
    end
    object btnSetBankpath: TButton
      Left = 358
      Top = 43
      Width = 129
      Height = 25
      Caption = 'Set Bank&Path'
      TabOrder = 2
      OnClick = btnSetBankpathClick
    end
    object pnlMASLedgerCode: TPanel
      Left = 10
      Top = 98
      Width = 486
      Height = 29
      BevelOuter = bvNone
      TabOrder = 7
      DesignSize = (
        486
        29)
      object btnMasLedgerCode: TSpeedButton
        Left = 452
        Top = 1
        Width = 25
        Height = 24
        Hint = 'Click to Select a Folder'
        Anchors = [akLeft, akBottom]
        OnClick = btnMasLedgerCodeClick
      end
      object edtExtractID: TEdit
        Left = 325
        Top = 3
        Width = 121
        Height = 21
        CharCase = ecUpperCase
        MaxLength = 20
        TabOrder = 1
        Text = 'EDT'
      end
      object chkUseCustomLedgerCode: TCheckBox
        Left = 130
        Top = 5
        Width = 180
        Height = 17
        Caption = 'Use &Custom Ledger Code'
        TabOrder = 0
        OnClick = chkUseCustomLedgerCodeClick
      end
    end
  end
  object GBExtract: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 296
    Width = 504
    Height = 46
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 7
    object Label3: TLabel
      Left = 16
      Top = 16
      Width = 54
      Height = 13
      Caption = 'Bulk Export'
    end
    object cbExtract: TComboBox
      Left = 272
      Top = 13
      Width = 215
      Height = 21
      Style = csDropDownList
      ItemHeight = 0
      TabOrder = 0
    end
    object ckExtract: TCheckBox
      Left = 140
      Top = 15
      Width = 126
      Height = 17
      Caption = 'Include in format:'
      TabOrder = 1
      OnClick = ckExtractClick
    end
  end
  object gbxTaxInterface: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 345
    Width = 504
    Height = 105
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 2
    object Label5: TLabel
      Left = 16
      Top = 16
      Width = 93
      Height = 13
      Caption = '&Tax Interface Used'
      FocusControl = cmbTaxInterface
    end
    object Label8: TLabel
      Left = 16
      Top = 46
      Width = 87
      Height = 13
      Caption = 'Export Tax &File To'
      FocusControl = edtSaveTaxTo
    end
    object lblTaxLedger: TLabel
      Left = 16
      Top = 76
      Width = 82
      Height = 13
      Caption = 'Ta&x Ledger Code'
      FocusControl = eTaxLedger
      Visible = False
    end
    object btnTaxFolder: TSpeedButton
      Left = 462
      Top = 41
      Width = 25
      Height = 24
      ParentShowHint = False
      ShowHint = True
      OnClick = btnTaxFolderClick
    end
    object eTaxLedger: TEdit
      Left = 140
      Top = 73
      Width = 145
      Height = 21
      Ctl3D = True
      MaxLength = 16
      ParentCtl3D = False
      TabOrder = 2
      Visible = False
    end
    object edtSaveTaxTo: TEdit
      Left = 140
      Top = 43
      Width = 316
      Height = 21
      MaxLength = 128
      TabOrder = 1
    end
    object cmbTaxInterface: TComboBox
      Left = 140
      Top = 13
      Width = 347
      Height = 21
      Style = csDropDownList
      ItemHeight = 0
      Sorted = True
      TabOrder = 0
      OnChange = cmbTaxInterfaceChange
    end
  end
  object gbxWebExport: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 454
    Width = 504
    Height = 46
    Margins.Left = 8
    Margins.Top = 4
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 3
    object Label4: TLabel
      Left = 16
      Top = 16
      Width = 94
      Height = 13
      Caption = '&Web Export Format'
      FocusControl = cmbWebFormats
    end
    object cmbWebFormats: TComboBox
      Left = 140
      Top = 13
      Width = 347
      Height = 21
      Style = csDropDownList
      ItemHeight = 0
      Sorted = True
      TabOrder = 0
      OnChange = cmbWebFormatsChange
    end
  end
  object btndefault: TButton
    Left = 8
    Top = 510
    Width = 108
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Load Default'
    TabOrder = 4
    OnClick = btndefaultClick
  end
end
