object frmExchangeGainLossCodeEntry: TfrmExchangeGainLossCodeEntry
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Enter Exchange Gain/Loss Code'
  ClientHeight = 176
  ClientWidth = 533
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblMessage: TLabel
    Left = 20
    Top = 18
    Width = 505
    Height = 33
    AutoSize = False
    Caption = 
      'BankLink needs to know the exchange gain/loss code in your clien' +
      't'#39's chart for this bank account %s (%s).'
    WordWrap = True
  end
  object Label2: TLabel
    Left = 20
    Top = 88
    Width = 124
    Height = 13
    Caption = '&Exchange Gain/Loss Code'
    FocusControl = edtExchangeGainLossCode
  end
  object sbtnChart: TSpeedButton
    Left = 311
    Top = 85
    Width = 24
    Height = 22
    Flat = True
    OnClick = sbtnChartClick
  end
  object lblExchangeGainLossDesc: TLabel
    Left = 341
    Top = 88
    Width = 184
    Height = 20
    AutoSize = False
    Caption = 'lblExchangeGainLossDesc'
    Visible = False
  end
  object btnOk: TButton
    Left = 370
    Top = 143
    Width = 75
    Height = 25
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnOkClick
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
  object edtExchangeGainLossCode: TEdit
    Left = 177
    Top = 85
    Width = 130
    Height = 21
    TabOrder = 0
    OnChange = edtExchangeGainLossCodeChange
    OnExit = edtExchangeGainLossCodeExit
    OnKeyPress = edtExchangeGainLossCodeKeyPress
    OnKeyUp = edtExchangeGainLossCodeKeyUp
  end
end
