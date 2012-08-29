object frmNewCAF: TfrmNewCAF
  Left = 0
  Top = 0
  Caption = 'Customer Authority Form Details'
  ClientHeight = 597
  ClientWidth = 544
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblCompleteTheDetailsBelow: TLabel
    Left = 10
    Top = 15
    Width = 473
    Height = 13
    Caption = 
      'Complete the details below to ensure that all spaces on the auth' +
      'ority forms are correctly filled out:'
  end
  object lbl20: TLabel
    Left = 486
    Top = 51
    Width = 12
    Height = 13
    Caption = '20'
  end
  object lblAccountName: TLabel
    Left = 13
    Top = 70
    Width = 69
    Height = 13
    Caption = 'Account Name'
  end
  object lblServiceStartMonthAndYear: TLabel
    Left = 377
    Top = 70
    Width = 141
    Height = 13
    Caption = 'Service Start Month and Year'
  end
  object lblSortCode: TLabel
    Left = 13
    Top = 120
    Width = 48
    Height = 13
    Caption = 'Sort Code'
  end
  object lblAccountNumber: TLabel
    Left = 140
    Top = 120
    Width = 79
    Height = 13
    Caption = 'Account Number'
  end
  object lblClientCode: TLabel
    Left = 388
    Top = 120
    Width = 55
    Height = 13
    Caption = 'Client Code'
  end
  object lblCodeCode: TLabel
    Left = 468
    Top = 120
    Width = 50
    Height = 13
    Caption = 'Cost Code'
  end
  object lblBank: TLabel
    Left = 13
    Top = 170
    Width = 23
    Height = 13
    Caption = 'Bank'
  end
  object lblBranch: TLabel
    Left = 279
    Top = 170
    Width = 33
    Height = 13
    Caption = 'Branch'
  end
  object lblAccountSignatories: TLabel
    Left = 13
    Top = 220
    Width = 217
    Height = 13
    Caption = 'Account Signatories (please enter full names)'
    Visible = False
  end
  object lblServiceFrequency: TLabel
    Left = 8
    Top = 270
    Width = 93
    Height = 13
    Caption = 'Service Frequency:'
  end
  object lblAddressLine1: TLabel
    Left = 13
    Top = 326
    Width = 70
    Height = 13
    Caption = 'Address Line 1'
    Visible = False
  end
  object lblAddressLine2: TLabel
    Left = 13
    Top = 376
    Width = 70
    Height = 13
    Caption = 'Address Line 2'
    Visible = False
  end
  object lblAddressLine3: TLabel
    Left = 13
    Top = 426
    Width = 70
    Height = 13
    Caption = 'Address Line 3'
    Visible = False
  end
  object lblAddressLine4: TLabel
    Left = 13
    Top = 476
    Width = 70
    Height = 13
    Caption = 'Address Line 4'
    Visible = False
  end
  object lblPostalCode: TLabel
    Left = 300
    Top = 476
    Width = 57
    Height = 13
    Caption = 'Postal Code'
    Visible = False
  end
  object edtAccountName: TEdit
    Left = 8
    Top = 48
    Width = 337
    Height = 21
    Hint = 'Enter the account name'
    MaxLength = 60
    ParentShowHint = False
    ShowHint = True
    TabOrder = 18
  end
  object cmbServiceStartMonth: TComboBox
    Left = 363
    Top = 48
    Width = 112
    Height = 21
    Hint = 'Enter the month in which you want to start collecting data'
    ItemHeight = 13
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnChange = cmbServiceStartMonthChange
    Items.Strings = (
      ''
      'ASAP'
      'January'
      'February'
      'March'
      'April'
      'May'
      'June'
      'July'
      'August'
      'September'
      'October'
      'November'
      'December')
  end
  object edtServiceStartYear: TEdit
    Left = 500
    Top = 48
    Width = 34
    Height = 21
    Hint = 'Enter the year in which you want to start collecting data'
    MaxLength = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnKeyPress = edtServiceStartYearKeyPress
  end
  object edtSortCode: TEdit
    Left = 8
    Top = 98
    Width = 121
    Height = 21
    Hint = 'Enter the sort code for this account'
    MaxLength = 8
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
  end
  object edtAccountNumber: TEdit
    Left = 135
    Top = 98
    Width = 242
    Height = 21
    Hint = 'Enter the account number'
    MaxLength = 22
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnKeyPress = edtAccountNumberKeyPress
  end
  object edtClientCode: TEdit
    Left = 383
    Top = 98
    Width = 74
    Height = 21
    Hint = 'Enter the code your practice uses for this client'
    MaxLength = 8
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
    OnKeyPress = edtClientCodeKeyPress
  end
  object edtCostCode: TEdit
    Left = 463
    Top = 98
    Width = 72
    Height = 21
    Hint = 'Enter the cost code your practice uses for this client'
    MaxLength = 8
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnKeyPress = edtCostCodeKeyPress
  end
  object edtBank: TEdit
    Left = 8
    Top = 148
    Width = 260
    Height = 21
    Hint = 'Enter the name of the bank where the account is held'
    MaxLength = 60
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
  end
  object edtBranch: TEdit
    Left = 274
    Top = 148
    Width = 260
    Height = 21
    Hint = 'Enter the name of the bank branch where the account is held'
    MaxLength = 60
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
  end
  object edtAccountSignatory1: TEdit
    Left = 8
    Top = 198
    Width = 260
    Height = 21
    MaxLength = 60
    TabOrder = 8
    Visible = False
  end
  object edtAccountSignatory2: TEdit
    Left = 274
    Top = 198
    Width = 260
    Height = 21
    MaxLength = 60
    TabOrder = 9
    Visible = False
  end
  object chkSupplyAccount: TCheckBox
    Left = 10
    Top = 248
    Width = 526
    Height = 17
    Hint = 'Supply Provisional Accounts'
    Caption = 
      'Please supply the account above as a Provisional Account if it i' +
      's not available from the bank'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
  end
  object pnlServiceFrequency: TPanel
    Left = 111
    Top = 269
    Width = 423
    Height = 26
    Hint = 
      'Select Daily, Weekly or Monthly for the data frequency on this a' +
      'ccount'
    BevelOuter = bvNone
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
    object rbMonthly: TRadioButton
      Left = 8
      Top = 0
      Width = 113
      Height = 17
      Caption = 'Monthly'
      TabOrder = 0
      TabStop = True
    end
    object rbWeekly: TRadioButton
      Left = 104
      Top = 0
      Width = 154
      Height = 17
      Caption = 'Weekly (where available)'
      TabOrder = 1
      TabStop = True
    end
    object rbDaily: TRadioButton
      Left = 288
      Top = 0
      Width = 145
      Height = 17
      Caption = 'Daily (where available)'
      Checked = True
      TabOrder = 2
      TabStop = True
    end
  end
  object edtAddressLine1: TEdit
    Left = 8
    Top = 304
    Width = 281
    Height = 21
    MaxLength = 60
    TabOrder = 12
    Visible = False
  end
  object edtAddressLine2: TEdit
    Left = 8
    Top = 354
    Width = 281
    Height = 21
    MaxLength = 60
    TabOrder = 13
    Visible = False
  end
  object edtAddressLine3: TEdit
    Left = 8
    Top = 404
    Width = 281
    Height = 21
    MaxLength = 60
    TabOrder = 14
    Visible = False
  end
  object edtAddressLine4: TEdit
    Left = 8
    Top = 454
    Width = 281
    Height = 21
    MaxLength = 60
    TabOrder = 15
    Visible = False
  end
  object edtPostalCode: TEdit
    Left = 295
    Top = 454
    Width = 98
    Height = 21
    MaxLength = 8
    TabOrder = 16
    Visible = False
  end
  object pnlBottom: TPanel
    Left = 3
    Top = 495
    Width = 544
    Height = 98
    BevelOuter = bvNone
    ParentShowHint = False
    ShowHint = False
    TabOrder = 17
    object bevel1: TBevel
      Left = 8
      Top = 5
      Width = 526
      Height = 2
    end
    object lblPracticeName: TLabel
      Left = 13
      Top = 40
      Width = 68
      Height = 13
      Caption = 'Practice Name'
    end
    object lblPracticeCode: TLabel
      Left = 418
      Top = 40
      Width = 66
      Height = 13
      Caption = 'Practice Code'
    end
    object edtPracticeName: TEdit
      Left = 8
      Top = 18
      Width = 385
      Height = 21
      Hint = 'Enter your practice name'
      Enabled = False
      MaxLength = 60
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object edtPracticeCode: TEdit
      Left = 410
      Top = 18
      Width = 121
      Height = 21
      Hint = 'Enter your practice code'
      Enabled = False
      MaxLength = 8
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object btnFile: TButton
      Left = 7
      Top = 65
      Width = 75
      Height = 25
      Caption = '&File'
      TabOrder = 2
      OnClick = btnFileClick
    end
    object btnEmail: TButton
      Left = 97
      Top = 65
      Width = 75
      Height = 25
      Caption = '&E-mail'
      TabOrder = 3
      OnClick = btnEmailClick
    end
    object btnPrint: TButton
      Left = 283
      Top = 65
      Width = 75
      Height = 25
      Caption = '&Print'
      TabOrder = 4
      OnClick = btnPrintClick
    end
    object btnResetForm: TButton
      Left = 370
      Top = 65
      Width = 75
      Height = 25
      Caption = 'Reset Form'
      TabOrder = 5
      OnClick = btnResetFormClick
    end
    object btnCancel: TButton
      Left = 457
      Top = 65
      Width = 75
      Height = 25
      Caption = 'Close'
      ModalResult = 2
      TabOrder = 6
    end
  end
end
