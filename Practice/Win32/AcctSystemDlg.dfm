object dlgAcctSystem: TdlgAcctSystem
  Left = 473
  Top = 83
  ActiveControl = rbAccounting
  BorderStyle = bsDialog
  Caption = 'Maintain Accounting System'
  ClientHeight = 550
  ClientWidth = 520
  Color = clWindow
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
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
    Height = 226
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 1
    DesignSize = (
      504
      226)
    object btnFromFolder: TSpeedButton
      Left = 462
      Top = 128
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      Anchors = [akLeft, akBottom]
      OnClick = btnFromFolderClick
      ExplicitTop = 139
    end
    object lblFrom: TLabel
      Left = 16
      Top = 133
      Width = 80
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Loa&d Chart From'
      FocusControl = eFrom
      ExplicitTop = 144
    end
    object lblSaveTo: TLabel
      Left = 16
      Top = 165
      Width = 75
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Save &Entries To'
      FocusControl = eTo
      ExplicitTop = 176
    end
    object btnToFolder: TSpeedButton
      Left = 462
      Top = 160
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      Anchors = [akLeft, akBottom]
      OnClick = btnToFolderClick
      ExplicitTop = 171
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
    object lblBGL360FundName: TLabel
      Left = 272
      Top = 133
      Width = 215
      Height = 17
      Anchors = [akLeft, akBottom]
      AutoSize = False
      ShowAccelChar = False
      ExplicitTop = 144
    end
    object lblFirmName: TLabel
      Left = 140
      Top = 161
      Width = 347
      Height = 23
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Firm name'
      Visible = False
      ExplicitTop = 171
    end
    object lblPLClientName: TLabel
      Left = 139
      Top = 161
      Width = 348
      Height = 23
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Selected my.MYOB client name goes here'
      ShowAccelChar = False
      ExplicitTop = 171
    end
    object eFrom: TEdit
      Left = 139
      Top = 132
      Width = 317
      Height = 21
      Anchors = [akLeft, akBottom]
      TabOrder = 6
      Text = 'eFrom'
      OnChange = eFromChange
    end
    object eTo: TEdit
      Left = 140
      Top = 162
      Width = 317
      Height = 21
      Anchors = [akLeft, akBottom]
      TabOrder = 7
      Text = 'eTo'
    end
    object btnCheckBankManID: TButton
      Left = 140
      Top = 190
      Width = 129
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Set &BankLink ID'
      TabOrder = 8
      OnClick = btnCheckBankManIDClick
    end
    object cmbSystem: TComboBox
      Left = 140
      Top = 13
      Width = 347
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
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
      TabOrder = 4
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
    object btnConnectBGL: TButton
      Left = 137
      Top = 128
      Width = 129
      Height = 27
      Hint = 
        'Sign in and select a Fund to refresh the client'#39's Chart of Accou' +
        'nts from'
      Anchors = [akLeft, akBottom]
      Caption = 'BGL Sign in'
      TabOrder = 5
      OnClick = btnConnectBGLClick
    end
    object btnConnectMYOB: TButton
      Left = 140
      Top = 128
      Width = 165
      Height = 27
      Anchors = [akLeft, akBottom]
      Caption = 'MYOB Login'
      TabOrder = 9
      OnClick = btnConnectMYOBClick
    end
  end
  object GBExtract: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 285
    Width = 504
    Height = 46
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 2
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
      ItemHeight = 13
      TabOrder = 1
    end
    object ckExtract: TCheckBox
      Left = 140
      Top = 15
      Width = 126
      Height = 17
      Caption = 'Include in format:'
      TabOrder = 0
      OnClick = ckExtractClick
    end
  end
  object gbxTaxInterface: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 334
    Width = 504
    Height = 105
    Margins.Left = 8
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 3
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
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
      OnChange = cmbTaxInterfaceChange
    end
  end
  object gbxWebExport: TGroupBox
    AlignWithMargins = True
    Left = 8
    Top = 443
    Width = 504
    Height = 46
    Margins.Left = 8
    Margins.Top = 4
    Margins.Right = 8
    Margins.Bottom = 0
    Align = alTop
    TabOrder = 4
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
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
      OnChange = cmbWebFormatsChange
    end
  end
  object pnlControls: TPanel
    Left = 0
    Top = 509
    Width = 520
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 5
    DesignSize = (
      520
      41)
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 520
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btndefault: TButton
      Left = 8
      Top = 8
      Width = 108
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Load Default'
      TabOrder = 0
      OnClick = btndefaultClick
    end
    object btnOk: TButton
      Left = 355
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      TabOrder = 1
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 436
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
  end
end
