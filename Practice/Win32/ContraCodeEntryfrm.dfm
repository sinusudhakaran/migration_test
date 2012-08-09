object frmContraCodeEntry: TfrmContraCodeEntry
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Enter Bank Account Contra Code'
  ClientHeight = 176
  ClientWidth = 538
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblMessage: TLabel
    Left = 20
    Top = 18
    Width = 409
    Height = 33
    AutoSize = False
    Caption = 
      'BankLink Practice needs to know the account code in your client'#39 +
      's chart for the bank account %s'
    WordWrap = True
  end
  object Label2: TLabel
    Left = 20
    Top = 88
    Width = 93
    Height = 13
    Caption = '&Bank Account Code'
    FocusControl = edtBankAccountCode
  end
  object sbtnChart: TSpeedButton
    Left = 278
    Top = 85
    Width = 24
    Height = 22
    Flat = True
    OnClick = sbtnChartClick
  end
  object lblContraDesc: TLabel
    Left = 308
    Top = 88
    Width = 217
    Height = 20
    AutoSize = False
    Caption = 'lblContraDesc'
    Visible = False
  end
  object btnOk: TButton
    Left = 370
    Top = 143
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 450
    Top = 143
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edtBankAccountCode: TEdit
    Left = 144
    Top = 85
    Width = 130
    Height = 21
    TabOrder = 0
    OnChange = edtBankAccountCodeChange
    OnKeyPress = edtBankAccountCodeKeyPress
  end
end
