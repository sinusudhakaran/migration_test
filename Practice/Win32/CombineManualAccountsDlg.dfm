object DlgCombineManualAccounts: TDlgCombineManualAccounts
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Combine Manual Bank Accounts'
  ClientHeight = 248
  ClientWidth = 463
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    463
    248)
  PixelsPerInch = 96
  TextHeight = 12
  object lblInstructions: TLabel
    Left = 8
    Top = 15
    Width = 564
    Height = 23
    AutoSize = False
    Caption = 'This action will combine manual bank accounts.'
    WordWrap = True
  end
  object Label2: TLabel
    Left = 7
    Top = 61
    Width = 126
    Height = 12
    Caption = '&Old Bank Account Number:'
    FocusControl = cmbBankAccounts
  end
  object Label3: TLabel
    Left = 7
    Top = 101
    Width = 130
    Height = 12
    Caption = '&New Bank Account Number:'
    FocusControl = cmbCombine
  end
  object btnOK: TButton
    Left = 299
    Top = 217
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 380
    Top = 217
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object cmbBankAccounts: TComboBox
    Left = 192
    Top = 59
    Width = 261
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    TabOrder = 2
    OnSelect = cmbBankAccountsSelect
  end
  object cmbCombine: TComboBox
    Left = 192
    Top = 98
    Width = 261
    Height = 20
    Style = csDropDownList
    ItemHeight = 12
    TabOrder = 3
    OnSelect = cmbCombineSelect
  end
  object Panel1: TPanel
    Left = 6
    Top = 135
    Width = 448
    Height = 76
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 4
    object Label8: TLabel
      Left = 8
      Top = 15
      Width = 38
      Height = 12
      Caption = 'Account'
    end
    object Label9: TLabel
      Left = 258
      Top = 15
      Width = 30
      Height = 12
      Alignment = taRightJustify
      Caption = 'Entries'
    end
    object lblAccountFrom: TLabel
      Left = 8
      Top = 32
      Width = 246
      Height = 15
      AutoSize = False
      Caption = 'DUMMY A/C 1'
    end
    object lblAccountTo: TLabel
      Left = 8
      Top = 51
      Width = 246
      Height = 15
      AutoSize = False
      Caption = '12-3112-5434554-55'
    end
    object lblFromEntries: TLabel
      Left = 277
      Top = 35
      Width = 10
      Height = 12
      Alignment = taRightJustify
      Caption = '50'
    end
    object lblToEntries: TLabel
      Left = 282
      Top = 51
      Width = 5
      Height = 12
      Alignment = taRightJustify
      Caption = '4'
    end
    object Label10: TLabel
      Left = 306
      Top = 15
      Width = 24
      Height = 12
      Caption = 'From'
    end
    object Label11: TLabel
      Left = 372
      Top = 15
      Width = 12
      Height = 12
      Caption = 'To'
    end
    object lblDateFrom: TLabel
      Left = 306
      Top = 35
      Width = 54
      Height = 12
      Caption = 'lblDateFrom'
    end
    object lblDFrom: TLabel
      Left = 306
      Top = 51
      Width = 41
      Height = 12
      Caption = 'lblDFrom'
    end
    object lblDateTo: TLabel
      Left = 372
      Top = 35
      Width = 42
      Height = 12
      Caption = 'lblDateTo'
    end
    object lblDTo: TLabel
      Left = 372
      Top = 51
      Width = 29
      Height = 12
      Caption = 'lblDTo'
    end
  end
end
