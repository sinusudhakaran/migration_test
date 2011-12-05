object frmBanklinkOnlineSettings: TfrmBanklinkOnlineSettings
  Left = 0
  Top = 0
  Caption = 'BankLink Online Settings'
  ClientHeight = 519
  ClientWidth = 481
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object grpProductAccess: TGroupBox
    Left = 8
    Top = 120
    Width = 465
    Height = 166
    Caption = 'Product Access'
    TabOrder = 0
    object lblSelectProducts: TLabel
      Left = 16
      Top = 20
      Width = 244
      Height = 30
      Caption = 
        'Select the BankLink Online products that you wish to have availa' +
        'ble for this client:'
      WordWrap = True
    end
    object btnSelectAll: TButton
      Left = 327
      Top = 67
      Width = 75
      Height = 25
      Caption = 'Select &All'
      TabOrder = 0
      OnClick = btnSelectAllClick
    end
    object btnClearAll: TButton
      Left = 327
      Top = 98
      Width = 75
      Height = 25
      Caption = '&Clear All'
      TabOrder = 1
      OnClick = btnClearAllClick
    end
    object chklistProducts: TCheckListBox
      Left = 21
      Top = 60
      Width = 300
      Height = 93
      ItemHeight = 13
      TabOrder = 2
    end
  end
  object grpBillingFrequency: TGroupBox
    Left = 8
    Top = 292
    Width = 465
    Height = 53
    Caption = 'Billing Frequency'
    TabOrder = 1
    object lblNextBillingFrequency: TLabel
      Left = 21
      Top = 22
      Width = 108
      Height = 13
      Caption = 'Next billing frequency:'
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
    Left = 8
    Top = 351
    Width = 465
    Height = 114
    Caption = 'Default Client Administrator'
    TabOrder = 2
    object lblUserName: TLabel
      Left = 21
      Top = 47
      Width = 52
      Height = 13
      Caption = 'User &Name'
    end
    object lblEmailAddress: TLabel
      Left = 21
      Top = 73
      Width = 70
      Height = 13
      Caption = '&E-mail Address'
    end
    object chkUseClientDetails: TCheckBox
      Left = 16
      Top = 24
      Width = 193
      Height = 17
      Caption = '&Use Client Details'
      TabOrder = 0
    end
    object edtUserName: TEdit
      Left = 128
      Top = 47
      Width = 321
      Height = 21
      TabOrder = 1
    end
    object edtEmailAddress: TEdit
      Left = 128
      Top = 74
      Width = 321
      Height = 21
      TabOrder = 2
    end
  end
  object btnOK: TButton
    Left = 301
    Top = 479
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 382
    Top = 479
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object grpClientAccess: TGroupBox
    Left = 8
    Top = 8
    Width = 465
    Height = 105
    Caption = 'Client Access'
    TabOrder = 5
    object lblClientConnect: TLabel
      Left = 34
      Top = 37
      Width = 125
      Height = 13
      Caption = 'Client must connect every'
    end
    object rbActive: TRadioButton
      Left = 16
      Top = 17
      Width = 113
      Height = 17
      Caption = 'Active'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbActiveClick
    end
    object rbSuspended: TRadioButton
      Left = 16
      Top = 57
      Width = 113
      Height = 17
      Caption = 'Suspended'
      TabOrder = 1
      OnClick = rbSuspendedClick
    end
    object rbDeactivated: TRadioButton
      Left = 16
      Top = 77
      Width = 113
      Height = 17
      Caption = 'Deactivated'
      TabOrder = 2
      OnClick = rbDeactivatedClick
    end
    object cmbConnectDays: TComboBox
      Left = 197
      Top = 34
      Width = 84
      Height = 21
      ItemHeight = 13
      TabOrder = 3
      Text = '30 days'
      Items.Strings = (
        '30 days'
        '90 days'
        '365 days')
    end
  end
end
