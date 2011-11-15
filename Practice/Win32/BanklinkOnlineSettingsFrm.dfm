object frmBanklinkOnlineSettings: TfrmBanklinkOnlineSettings
  Left = 0
  Top = 0
  Caption = 'BankLink Online Settings'
  ClientHeight = 515
  ClientWidth = 495
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object grpProductAccess: TGroupBox
    Left = 16
    Top = 8
    Width = 465
    Height = 225
    Caption = 'Product Access'
    TabOrder = 0
    object lblSelectProducts: TLabel
      Left = 16
      Top = 24
      Width = 392
      Height = 13
      Caption = 
        'Select the BankLink Online products that you wish to have availa' +
        'ble for this client:'
    end
    object btnSelectAll: TButton
      Left = 327
      Top = 43
      Width = 75
      Height = 25
      Caption = 'Select &All'
      TabOrder = 0
      OnClick = btnSelectAllClick
    end
    object btnClearAll: TButton
      Left = 327
      Top = 74
      Width = 75
      Height = 25
      Caption = '&Clear All'
      TabOrder = 1
      OnClick = btnClearAllClick
    end
    object chkSuspendClient: TCheckBox
      Left = 23
      Top = 132
      Width = 97
      Height = 17
      Caption = 'Suspend Client'
      TabOrder = 2
    end
    object chkDeactivateClient: TCheckBox
      Left = 23
      Top = 150
      Width = 162
      Height = 17
      Caption = 'Deactivate Client'
      TabOrder = 3
    end
    object rbClientAlwaysOnline: TRadioButton
      Left = 23
      Top = 173
      Width = 162
      Height = 17
      Caption = 'Clien&t must always be online'
      TabOrder = 4
      OnClick = rbClientAlwaysOnlineClick
    end
    object rbClientMustConnect: TRadioButton
      Left = 23
      Top = 196
      Width = 239
      Height = 17
      Caption = 'Client must connect every                        &days'
      Checked = True
      TabOrder = 5
      TabStop = True
      OnClick = rbClientMustConnectClick
    end
    object cmbDays: TComboBox
      Left = 172
      Top = 194
      Width = 61
      Height = 21
      ItemHeight = 13
      TabOrder = 6
      Text = '30'
      Items.Strings = (
        '30'
        '90'
        '365')
    end
    object chklistProducts: TCheckListBox
      Left = 21
      Top = 44
      Width = 300
      Height = 85
      ItemHeight = 13
      TabOrder = 7
    end
    object btnTemp: TButton
      Left = 344
      Top = 128
      Width = 89
      Height = 25
      Caption = 'Switch to online'
      TabOrder = 8
      OnClick = btnTempClick
    end
  end
  object grpBillingFrequency: TGroupBox
    Left = 16
    Top = 239
    Width = 465
    Height = 106
    Caption = 'Billing Frequency'
    TabOrder = 1
    object lblFreeTrial: TLabel
      Left = 23
      Top = 24
      Width = 378
      Height = 13
      Caption = 
        'Free Trial until DD/MM/YYYY or Currently billed {Frequency} unti' +
        'l DD/MM/YYYY}'
    end
    object lblNextBillingPeriod: TLabel
      Left = 23
      Top = 43
      Width = 173
      Height = 13
      Caption = 'Next billing period starts: DD/MM/YY'
    end
    object lblNextBillingFrequency: TLabel
      Left = 23
      Top = 62
      Width = 108
      Height = 13
      Caption = 'Next billing frequency:'
    end
    object rbMonthly: TRadioButton
      Left = 40
      Top = 81
      Width = 91
      Height = 17
      Caption = '&Monthly'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbAnnually: TRadioButton
      Left = 149
      Top = 81
      Width = 113
      Height = 17
      Caption = 'Annua&lly'
      TabOrder = 1
    end
  end
  object grpDefaultClientAdministrator: TGroupBox
    Left = 16
    Top = 351
    Width = 465
    Height = 114
    Caption = 'Default Client Administrator'
    TabOrder = 2
    object lblUserName: TLabel
      Left = 21
      Top = 52
      Width = 52
      Height = 13
      Caption = 'User &Name'
    end
    object lblEmailAddress: TLabel
      Left = 21
      Top = 81
      Width = 70
      Height = 13
      Caption = '&E-mail Address'
    end
    object chkUseClientDetails: TCheckBox
      Left = 16
      Top = 24
      Width = 113
      Height = 17
      Caption = '&Use Client Details'
      TabOrder = 0
    end
    object edtUserName: TEdit
      Left = 112
      Top = 49
      Width = 337
      Height = 21
      TabOrder = 1
    end
    object edtEmailAddress: TEdit
      Left = 112
      Top = 80
      Width = 337
      Height = 21
      TabOrder = 2
    end
  end
  object btnOK: TButton
    Left = 311
    Top = 482
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 400
    Top = 482
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
