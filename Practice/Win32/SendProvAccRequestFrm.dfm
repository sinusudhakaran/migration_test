object frmSendProvAccRequest: TfrmSendProvAccRequest
  Left = 0
  Top = 0
  Caption = 'Request Provisional Account'
  ClientHeight = 312
  ClientWidth = 434
  Color = clBtnFace
  Constraints.MaxHeight = 350
  Constraints.MaxWidth = 450
  Constraints.MinHeight = 350
  Constraints.MinWidth = 450
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblAccountNumber: TLabel
    Left = 16
    Top = 16
    Width = 82
    Height = 13
    Caption = 'Account number:'
  end
  object lblAccountName: TLabel
    Left = 16
    Top = 48
    Width = 72
    Height = 13
    Caption = 'Account name:'
  end
  object lblInstitution: TLabel
    Left = 16
    Top = 80
    Width = 53
    Height = 13
    Caption = 'Institution:'
  end
  object lblAccountType: TLabel
    Left = 16
    Top = 112
    Width = 68
    Height = 13
    Caption = 'Account type:'
  end
  object lblCurrency: TLabel
    Left = 16
    Top = 144
    Width = 48
    Height = 13
    Caption = 'Currency:'
    Visible = False
  end
  object lblCurrencyWarning: TLabel
    Left = 128
    Top = 168
    Width = 260
    Height = 26
    Caption = 
      'If the account'#39's currency is not available here you will need to' +
      ' add it through Maintain Currencies'
    Visible = False
    WordWrap = True
  end
  object lblTerms: TLabel
    Left = 33
    Top = 240
    Width = 103
    Height = 13
    Cursor = crHandPoint
    Caption = 'Terms and Conditions'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = -2147483622
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsUnderline]
    ParentFont = False
    OnClick = lblTermsClick
  end
  object lblP: TLabel
    Left = 120
    Top = 16
    Width = 6
    Height = 13
    Caption = 'P'
    WordWrap = True
  end
  object edtAccountNumber: TEdit
    Left = 128
    Top = 13
    Width = 281
    Height = 21
    MaxLength = 19
    TabOrder = 0
  end
  object btnSubmit: TButton
    Left = 248
    Top = 278
    Width = 75
    Height = 25
    Caption = 'Submit'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnSubmitClick
  end
  object Button1: TButton
    Left = 335
    Top = 278
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edtAccountName: TEdit
    Left = 128
    Top = 45
    Width = 281
    Height = 21
    MaxLength = 60
    TabOrder = 3
  end
  object cbxAccountType: TComboBox
    Left = 128
    Top = 109
    Width = 281
    Height = 21
    ItemHeight = 13
    TabOrder = 4
    Text = 'Select'
  end
  object cbxCurrency: TComboBox
    Left = 128
    Top = 141
    Width = 281
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 5
    Visible = False
  end
  object chkReadTerms: TCheckBox
    Left = 16
    Top = 224
    Width = 393
    Height = 17
    Caption = 'I confirm that I have read and agree to be bound by Banklink'#39's '
    TabOrder = 6
  end
  object cbxInstitution: TComboBox
    Left = 128
    Top = 72
    Width = 281
    Height = 21
    ItemHeight = 13
    TabOrder = 7
  end
end
