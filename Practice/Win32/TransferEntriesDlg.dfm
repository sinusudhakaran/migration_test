inherited dlgTransferEntries: TdlgTransferEntries
  Left = 316
  Top = 344
  Caption = 'Combine Manual & System Bank Accounts'
  ClientHeight = 466
  ClientWidth = 622
  Color = clWindow
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShortCut = FormShortCut
  OnShow = FormShow
  ExplicitWidth = 628
  ExplicitHeight = 494
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel [0]
    Left = 16
    Top = 16
    Width = 326
    Height = 13
    Caption = 'Transfer Entries from Manual Bank Account to System Bank Account'
  end
  object Label2: TLabel [1]
    Left = 16
    Top = 53
    Width = 102
    Height = 13
    Caption = '&Manual Bank Account'
    FocusControl = cmbTempAccount
  end
  object Label3: TLabel [2]
    Left = 18
    Top = 99
    Width = 103
    Height = 13
    Caption = '&System Bank Account'
    FocusControl = cmbBankAccount
  end
  object lblWarning: TLabel [3]
    Left = 16
    Top = 208
    Width = 571
    Height = 33
    AutoSize = False
    Caption = 
      '%s will transfer ALL entries from the manual bank account to the' +
      ' system bank account that fall in the date range specified.  '
    WordWrap = True
  end
  object Label4: TLabel [4]
    Left = 16
    Top = 248
    Width = 457
    Height = 13
    Caption = 
      'Any existing entries in the system bank account that fall within' +
      ' the date range will be DELETED.'
  end
  inherited pnlBottomControls: TPanel
    Top = 423
    Width = 622
    Height = 43
    ParentBackground = False
    TabOrder = 2
    ExplicitTop = 423
    ExplicitWidth = 622
    ExplicitHeight = 43
    inherited ShapeBotBorder: TShape
      Width = 622
      ExplicitWidth = 622
    end
    inherited btnCancel: TButton
      Left = 540
      Top = 10
      ExplicitLeft = 540
      ExplicitTop = 10
    end
    inherited btnOK: TButton
      Left = 456
      Top = 10
      ExplicitLeft = 456
      ExplicitTop = 10
    end
  end
  object cmbTempAccount: TComboBox
    Left = 152
    Top = 48
    Width = 413
    Height = 21
    Style = csDropDownList
    Ctl3D = False
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 0
    OnSelect = cmbTempAccountSelect
  end
  object cmbBankAccount: TComboBox
    Left = 152
    Top = 96
    Width = 413
    Height = 21
    Style = csDropDownList
    Ctl3D = False
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 1
    OnSelect = cmbBankAccountSelect
  end
  object Panel1: TPanel
    Left = 8
    Top = 280
    Width = 609
    Height = 137
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 3
    object Label8: TLabel
      Left = 8
      Top = 16
      Width = 39
      Height = 13
      Caption = 'Account'
    end
    object Label9: TLabel
      Left = 349
      Top = 16
      Width = 33
      Height = 13
      Alignment = taRightJustify
      Caption = 'Entries'
    end
    object lblTempAccount: TLabel
      Left = 8
      Top = 43
      Width = 330
      Height = 16
      AutoSize = False
      Caption = 'DUMMY A/C 1'
    end
    object lblBankAccount: TLabel
      Left = 8
      Top = 67
      Width = 330
      Height = 16
      AutoSize = False
      Caption = '12-3112-5434554-55'
    end
    object lblTempEntries: TLabel
      Left = 370
      Top = 43
      Width = 12
      Height = 13
      Alignment = taRightJustify
      Caption = '50'
    end
    object lblBankEntries: TLabel
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
    object lblTempFrom: TLabel
      Left = 408
      Top = 43
      Width = 60
      Height = 13
      Caption = 'lblTempFrom'
    end
    object lblBankFrom: TLabel
      Left = 408
      Top = 67
      Width = 57
      Height = 13
      Caption = 'lblBankFrom'
    end
    object lblTempTo: TLabel
      Left = 496
      Top = 43
      Width = 48
      Height = 13
      Caption = 'lblTempTo'
    end
    object lblBankTo: TLabel
      Left = 496
      Top = 67
      Width = 45
      Height = 13
      Caption = 'lblBankTo'
    end
    object lblDupDesc: TLabel
      Left = 8
      Top = 98
      Width = 330
      Height = 34
      AutoSize = False
      Caption = 
        'Existing entries which will be deleted from the system bank acco' +
        'unt'
      WordWrap = True
    end
    object lblDupFrom: TLabel
      Left = 408
      Top = 98
      Width = 53
      Height = 13
      Caption = 'lblDupFrom'
    end
    object lblDupTo: TLabel
      Left = 496
      Top = 98
      Width = 41
      Height = 13
      Caption = 'lblDupTo'
    end
    object lblDupEntries: TLabel
      Left = 376
      Top = 98
      Width = 6
      Height = 13
      Alignment = taRightJustify
      Caption = '0'
    end
    object Bevel1: TBevel
      Left = 7
      Top = 35
      Width = 550
      Height = 2
    end
  end
  inline DateSelector: TfmeDateSelector
    Left = 18
    Top = 128
    Width = 458
    Height = 73
    TabOrder = 4
    TabStop = True
    ExplicitLeft = 18
    ExplicitTop = 128
    ExplicitWidth = 458
    ExplicitHeight = 73
    inherited Label2: TLabel
      Left = 3
      Top = 11
      Width = 31
      Height = 16
      ExplicitLeft = 3
      ExplicitTop = 11
      ExplicitWidth = 31
      ExplicitHeight = 16
    end
    inherited btnPrev: TSpeedButton
      Left = 245
      Top = 7
      ExplicitLeft = 245
      ExplicitTop = 7
    end
    inherited btnNext: TSpeedButton
      Left = 272
      Top = 7
      ExplicitLeft = 272
      ExplicitTop = 7
    end
    inherited btnQuik: TSpeedButton
      Left = 303
      Top = 7
      ExplicitLeft = 303
      ExplicitTop = 7
    end
    inherited Label3: TLabel
      Left = 3
      Top = 38
      Width = 17
      Height = 16
      ExplicitLeft = 3
      ExplicitTop = 38
      ExplicitWidth = 17
      ExplicitHeight = 16
    end
    inherited eDateFrom: TOvcPictureField
      Left = 134
      BorderStyle = bsSingle
      Epoch = 0
      ExplicitLeft = 134
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    inherited eDateTo: TOvcPictureField
      Left = 134
      BorderStyle = bsSingle
      Epoch = 0
      ExplicitLeft = 134
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    inherited pmDates: TPopupMenu
      Left = 296
    end
    inherited OvcController1: TOvcController
      EntryCommands.TableList = (
        'Default'
        True
        ()
        'WordStar'
        False
        ()
        'Grid'
        False
        ())
      Left = 336
    end
  end
end
