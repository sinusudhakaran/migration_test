inherited DlgCombineAccounts: TDlgCombineAccounts
  Left = 393
  Top = 336
  Caption = 'Combine System Bank Accounts'
  ClientHeight = 290
  ClientWidth = 622
  OnShow = FormShow
  ExplicitWidth = 628
  ExplicitHeight = 316
  PixelsPerInch = 96
  TextHeight = 13
  object lblInstructions: TLabel [0]
    Left = 7
    Top = 16
    Width = 602
    Height = 48
    AutoSize = False
    Caption = 
      'This action will combine system bank accounts. You should only p' +
      'erform this operation if you are sure that the two selected bank' +
      ' accounts are the same bank account'
    WordWrap = True
  end
  object Label2: TLabel [1]
    Left = 7
    Top = 80
    Width = 128
    Height = 13
    Caption = '&Old Bank Account Number:'
    FocusControl = cmbBankAccounts
  end
  object Label3: TLabel [2]
    Left = 7
    Top = 122
    Width = 133
    Height = 13
    Caption = '&New Bank Account Number:'
    FocusControl = cmbCombine
  end
  inherited btnOK: TButton
    Left = 460
    Top = 259
    Caption = 'OK'
    ModalResult = 0
    TabOrder = 2
    OnClick = btnOKClick
    ExplicitLeft = 460
    ExplicitTop = 259
  end
  inherited btnCancel: TButton
    Left = 540
    Top = 259
    TabOrder = 3
    ExplicitLeft = 540
    ExplicitTop = 259
  end
  object cmbBankAccounts: TComboBox
    Left = 208
    Top = 77
    Width = 401
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnSelect = cmbBankAccountsSelect
  end
  object cmbCombine: TComboBox
    Left = 208
    Top = 120
    Width = 402
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
    OnSelect = cmbCombineSelect
  end
  object Panel1: TPanel
    Left = 7
    Top = 154
    Width = 609
    Height = 95
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 4
    object Label8: TLabel
      Left = 8
      Top = 16
      Width = 39
      Height = 13
      Caption = 'Account'
    end
    object Label9: TLabel
      Left = 349
      Top = 13
      Width = 33
      Height = 13
      Alignment = taRightJustify
      Caption = 'Entries'
    end
    object lblAccountFrom: TLabel
      Left = 8
      Top = 43
      Width = 305
      Height = 16
      AutoSize = False
      Caption = 'DUMMY A/C 1'
    end
    object lblAccountTo: TLabel
      Left = 8
      Top = 67
      Width = 305
      Height = 16
      AutoSize = False
      Caption = '12-3112-5434554-55'
    end
    object lblFromEntries: TLabel
      Left = 370
      Top = 43
      Width = 12
      Height = 13
      Alignment = taRightJustify
      Caption = '50'
    end
    object lblToEntries: TLabel
      Left = 376
      Top = 67
      Width = 6
      Height = 13
      Alignment = taRightJustify
      Caption = '4'
    end
    object Label10: TLabel
      Left = 408
      Top = 16
      Width = 24
      Height = 13
      Caption = 'From'
    end
    object Label11: TLabel
      Left = 496
      Top = 16
      Width = 12
      Height = 13
      Caption = 'To'
    end
    object lblDateFrom: TLabel
      Left = 408
      Top = 43
      Width = 57
      Height = 13
      Caption = 'lblDateFrom'
    end
    object lblDFrom: TLabel
      Left = 408
      Top = 67
      Width = 41
      Height = 13
      Caption = 'lblDFrom'
    end
    object lblDateTo: TLabel
      Left = 496
      Top = 43
      Width = 45
      Height = 13
      Caption = 'lblDateTo'
    end
    object lblDTo: TLabel
      Left = 496
      Top = 67
      Width = 29
      Height = 13
      Caption = 'lblDTo'
    end
    object Bevel1: TBevel
      Left = 10
      Top = 32
      Width = 551
      Height = 5
      Shape = bsBottomLine
    end
  end
end
