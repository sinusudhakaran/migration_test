object frmBanklinkOnlineSettings: TfrmBanklinkOnlineSettings
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'BankLink Online Settings'
  ClientHeight = 647
  ClientWidth = 480
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grpProductAccess: TGroupBox
    Left = 0
    Top = 57
    Width = 480
    Height = 166
    Align = alTop
    Caption = 'Product Access'
    TabOrder = 1
    object lblSelectProducts: TLabel
      Left = 16
      Top = 20
      Width = 241
      Height = 26
      Caption = 
        'Select the BankLink Online products that you wish to have availa' +
        'ble for this client:'
      WordWrap = True
    end
    object btnSelectAll: TButton
      Left = 362
      Top = 75
      Width = 75
      Height = 25
      Caption = 'Select &All'
      TabOrder = 1
      OnClick = btnSelectAllClick
    end
    object btnClearAll: TButton
      Left = 362
      Top = 106
      Width = 75
      Height = 25
      Caption = '&Clear All'
      TabOrder = 2
      OnClick = btnClearAllClick
    end
    object chkListProducts: TCheckListBox
      Left = 21
      Top = 60
      Width = 300
      Height = 95
      IntegralHeight = True
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
    end
  end
  object grpBillingFrequency: TGroupBox
    Left = 0
    Top = 499
    Width = 480
    Height = 53
    Align = alTop
    Caption = 'Billing Frequency'
    TabOrder = 4
    Visible = False
    object lblNextBillingFrequency: TLabel
      Left = 21
      Top = 22
      Width = 108
      Height = 13
      Caption = 'Next &billing frequency:'
      FocusControl = cmbBillingFrequency
    end
    object cmbBillingFrequency: TComboBox
      Left = 165
      Top = 20
      Width = 125
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      Text = 'Monthly'
      Items.Strings = (
        'Monthly'
        'Annually')
    end
  end
  object grpDefaultClientAdministrator: TGroupBox
    Left = 0
    Top = 385
    Width = 480
    Height = 114
    Align = alTop
    Caption = 'Default Client Administrator'
    TabOrder = 3
    OnClick = grpDefaultClientAdministratorClick
    object lblUserName: TLabel
      Left = 21
      Top = 55
      Width = 52
      Height = 13
      Caption = 'User &Name'
      FocusControl = edtUserName
    end
    object lblEmailAddress: TLabel
      Left = 21
      Top = 81
      Width = 70
      Height = 13
      Caption = '&E-mail Address'
      FocusControl = edtEmailAddress
    end
    object edtUserName: TEdit
      Left = 128
      Top = 55
      Width = 321
      Height = 21
      MaxLength = 60
      TabOrder = 1
    end
    object edtEmailAddress: TEdit
      Left = 128
      Top = 82
      Width = 321
      Height = 21
      MaxLength = 80
      TabOrder = 2
    end
    object btnUseClientDetails: TButton
      Left = 20
      Top = 21
      Width = 125
      Height = 25
      Caption = '&Use Client Details'
      TabOrder = 0
      OnClick = btnUseClientDetailsClick
    end
  end
  object btnOK: TButton
    Left = 301
    Top = 612
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 5
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 390
    Top = 612
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
    OnClick = btnCancelClick
  end
  object grpClientAccess: TGroupBox
    Left = 0
    Top = 0
    Width = 480
    Height = 57
    Align = alTop
    Caption = 'Client Access'
    TabOrder = 0
    object lblClientConnect: TLabel
      Left = 20
      Top = 25
      Width = 125
      Height = 13
      Caption = 'Client &must connect every'
      FocusControl = cmbConnectDays
    end
    object rbActive: TRadioButton
      Left = 364
      Top = 9
      Width = 113
      Height = 17
      Caption = 'Ac&tive'
      Checked = True
      TabOrder = 0
      TabStop = True
      Visible = False
      OnClick = rbActiveClick
      OnMouseDown = rbActiveMouseDown
    end
    object rbSuspended: TRadioButton
      Left = 364
      Top = 24
      Width = 113
      Height = 17
      Caption = '&Suspended'
      TabOrder = 2
      Visible = False
      OnClick = rbSuspendedClick
    end
    object rbDeactivated: TRadioButton
      Left = 364
      Top = 40
      Width = 113
      Height = 17
      Caption = '&Deactivated'
      TabOrder = 3
      Visible = False
      OnClick = rbDeactivatedClick
    end
    object cmbConnectDays: TComboBox
      Left = 183
      Top = 22
      Width = 84
      Height = 21
      ItemHeight = 13
      TabOrder = 1
      Text = 'Always'
      Items.Strings = (
        'Always'
        '30 days'
        '90 days'
        '365 days')
    end
  end
  object grpServicesAvailable: TGroupBox
    Left = 0
    Top = 223
    Width = 480
    Height = 162
    Align = alTop
    Caption = 'Services Available'
    TabOrder = 2
    object lblExportTo: TLabel
      Left = 9
      Top = 20
      Width = 47
      Height = 13
      Caption = 'Export To'
    end
    object lblSecureCode: TLabel
      Left = 10
      Top = 135
      Width = 142
      Height = 13
      Caption = '&BankLink Online Secure Code:'
      Visible = False
    end
    object chkDeliverData: TCheckBox
      Left = 9
      Top = 109
      Width = 281
      Height = 17
      Caption = 'Deli&ver data direct to BankLink Online'
      TabOrder = 1
      OnClick = chkDeliverDataClick
    end
    object edtSecureCode: TEdit
      Left = 208
      Top = 132
      Width = 240
      Height = 21
      CharCase = ecUpperCase
      TabOrder = 2
      Visible = False
    end
    object chklistServicesAvailable: TCheckListBox
      Left = 80
      Top = 21
      Width = 368
      Height = 82
      OnClickCheck = chklistServicesAvailableClickCheck
      IntegralHeight = True
      ItemHeight = 13
      TabOrder = 0
    end
  end
end
