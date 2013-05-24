object dlgEditBank: TdlgEditBank
  Left = 334
  Top = 217
  BorderStyle = bsDialog
  Caption = 'Edit Bank Account Details'
  ClientHeight = 523
  ClientWidth = 638
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  ShowHint = True
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 638
    Height = 486
    ActivePage = tbDetails
    Align = alClient
    TabOrder = 0
    object tbDetails: TTabSheet
      Caption = '&Details'
      object lblNo: TLabel
        Left = 24
        Top = 12
        Width = 55
        Height = 13
        Caption = 'Account No'
        FocusControl = eNumber
      end
      object Label1: TLabel
        Left = 24
        Top = 44
        Width = 69
        Height = 13
        Caption = 'Account &Name'
        FocusControl = eName
      end
      object stNumber: TLabel
        Left = 136
        Top = 12
        Width = 3
        Height = 13
      end
      object lblClause: TLabel
        Left = 3
        Top = 409
        Width = 618
        Height = 26
        Caption = 
          '* BankLink wishes to collect the Institution and Account Type in' +
          ' order to improve the service it provides by determining  whethe' +
          'r there are any additional account types or institutions which s' +
          'hould be added to the service.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        WordWrap = True
      end
      object lblM: TLabel
        Left = 122
        Top = 12
        Width = 8
        Height = 13
        Caption = 'M'
      end
      object lblLedgerID: TLabel
        Left = 159
        Top = 268
        Width = 410
        Height = 16
        AutoSize = False
        Caption = 'Ledger:'
      end
      object lblCurrency: TLabel
        Left = 397
        Top = 12
        Width = 44
        Height = 13
        Caption = 'C&urrency'
        FocusControl = cmbCurrency
      end
      object gCalc: TPanel
        Left = 24
        Top = 295
        Width = 601
        Height = 109
        Color = clInfoBk
        TabOrder = 8
        object lblPeriod: TLabel
          Left = 24
          Top = 86
          Width = 505
          Height = 16
          Alignment = taCenter
          AutoSize = False
          Caption = 'Tranactions from...'
        end
        object Label7: TLabel
          Left = 168
          Top = 60
          Width = 130
          Height = 13
          Caption = 'Calculated Current Balance'
        end
        object lblSign: TLabel
          Left = 444
          Top = 60
          Width = 14
          Height = 16
          Caption = 'IF'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object Bevel1: TBevel
          Left = 320
          Top = 43
          Width = 145
          Height = 9
          Shape = bsTopLine
        end
        object Label6: TLabel
          Left = 240
          Top = 17
          Width = 89
          Height = 13
          Caption = 'as at be&ginning of '
          FocusControl = eDateFrom
        end
        object Label4: TLabel
          Left = 8
          Top = 17
          Width = 37
          Height = 13
          Caption = 'Ba&lance'
          FocusControl = nCalcBal
        end
        object nCalculated: TOvcNumericField
          Left = 335
          Top = 56
          Width = 106
          Height = 24
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          CaretOvr.Shape = csBlock
          Color = clBtnFace
          Controller = OvcController1
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = [efoReadOnly]
          PictureMask = '###,###,###.##'
          TabOrder = 4
          TabStop = False
          RangeHigh = {73B2DBB9838916F2FE43}
          RangeLow = {73B2DBB9838916F2FEC3}
        end
        object btnUpdate: TButton
          Left = 470
          Top = 56
          Width = 75
          Height = 25
          Caption = '&Update'
          TabOrder = 5
          OnClick = btnUpdateClick
        end
        object btnCalc: TButton
          Left = 470
          Top = 13
          Width = 75
          Height = 25
          Caption = '&Calculate'
          TabOrder = 3
          OnClick = btnCalcClick
        end
        object eDateFrom: TOvcPictureField
          Left = 359
          Top = 13
          Width = 106
          Height = 24
          Cursor = crIBeam
          DataType = pftDate
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          Controller = OvcController1
          ControlCharColor = clRed
          DecimalPlaces = 0
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Epoch = 0
          InitDateTime = False
          MaxLength = 8
          Options = [efoCaretToEnd]
          PictureMask = 'DD/mm/yy'
          TabOrder = 2
          OnError = eDateFromError
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
        object cmbSign: TComboBox
          Left = 181
          Top = 13
          Width = 51
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          Items.Strings = (
            'IF'
            'OD')
        end
        object nCalcBal: TOvcNumericField
          Left = 71
          Top = 13
          Width = 106
          Height = 24
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          Controller = OvcController1
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '###,###,###.##'
          TabOrder = 0
          OnKeyDown = nCalcBalKeyDown
          RangeHigh = {73B2DBB9838916F2FE43}
          RangeLow = {73B2DBB9838916F2FEC3}
        end
      end
      object eNumber: TEdit
        Left = 136
        Top = 8
        Width = 240
        Height = 24
        BorderStyle = bsNone
        MaxLength = 20
        TabOrder = 0
        Text = 'eNumber'
        Visible = False
        OnExit = eNumberExit
      end
      object eName: TEdit
        Left = 136
        Top = 40
        Width = 422
        Height = 24
        BorderStyle = bsNone
        MaxLength = 60
        TabOrder = 2
        Text = 'eName'
        OnExit = eNumberExit
      end
      object pnlContra: TPanel
        Left = 0
        Top = 72
        Width = 553
        Height = 35
        BevelOuter = bvNone
        TabOrder = 3
        DesignSize = (
          553
          35)
        object Label2: TLabel
          Left = 24
          Top = 6
          Width = 61
          Height = 13
          Caption = 'C&ontra Code'
          FocusControl = eContra
        end
        object sbtnChart: TSpeedButton
          Left = 297
          Top = 3
          Width = 24
          Height = 22
          Flat = True
          OnClick = sbtnCodeClick
        end
        object lblContraDesc: TLabel
          Left = 331
          Top = 3
          Width = 217
          Height = 20
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'lblContraDesc'
        end
        object eContra: TEdit
          Left = 136
          Top = 2
          Width = 153
          Height = 24
          BorderStyle = bsNone
          Ctl3D = True
          MaxLength = 10
          ParentCtl3D = False
          TabOrder = 0
          Text = '12345678901234567890'
          OnChange = eCodeChange
          OnExit = eCodeExit
          OnKeyPress = eCodeKeyPress
          OnKeyUp = eCodeKeyUp
        end
      end
      object pnlBankOnly: TPanel
        Left = 8
        Top = 142
        Width = 561
        Height = 57
        BevelOuter = bvNone
        TabOrder = 5
        object lblBank: TLabel
          Left = 16
          Top = 16
          Width = 97
          Height = 36
          AutoSize = False
          Caption = 'Current &Balance'
          FocusControl = nBalance
          Layout = tlCenter
          WordWrap = True
        end
        object sbCalc: TSpeedButton
          Left = 377
          Top = 25
          Width = 23
          Height = 23
          Flat = True
          Glyph.Data = {
            66010000424D6601000000000000760000002800000014000000140000000100
            040000000000F000000000000000000000001000000010000000000000000000
            8000008000000080800080000000800080008080000080808000C0C0C0000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
            DDDDDDDD0000DDDD777777777777DDDD0000DDD00000000000007DDD0000DD0F
            EFEFEFEFEFEF07DD0000DD0E00000E00000E07DD0000DD0F88880F88880F07DD
            0000DD0EFEFEFEFEFEFE07DD0000DD0F00E00F00E00F07DD0000DD0E80F80E80
            F80E07DD0000DD0FEFEFEFEFEFEF07DD0000DD0E00F00E00F00E07DD0000DD0F
            80E80F80E80F07DD0000DD0EFEFEFEFEFEFE07DD0000DD0F00000000000F07DD
            0000DD0E08181881880E07DD0000DD0F08818818180F07DD0000DD0E00000000
            000E07DD0000DD0FEFEFEFEFEFEF0DDD0000DDD0000000000000DDDD0000DDDD
            DDDDDDDDDDDDDDDD0000}
          OnClick = sbCalcClick
        end
        object chkMaster: TCheckBox
          Left = 128
          Top = -2
          Width = 225
          Height = 17
          Caption = 'Use &Master Memorised Entries'
          TabOrder = 0
        end
        object nBalance: TOvcNumericField
          Left = 128
          Top = 24
          Width = 129
          Height = 24
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          Controller = OvcController1
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '###,###,###.##'
          TabOrder = 1
          OnChange = nBalanceChange
          OnKeyDown = nBalanceKeyDown
          RangeHigh = {73B2DBB9838916F2FE43}
          RangeLow = {00000000000000000000}
        end
        object cmbBalance: TComboBox
          Left = 264
          Top = 24
          Width = 105
          Height = 21
          Style = csDropDownList
          Ctl3D = True
          ItemHeight = 13
          ParentCtl3D = False
          TabOrder = 2
          Items.Strings = (
            'In Funds'
            'Overdrawn'
            'Unknown')
        end
      end
      object pnlManual: TPanel
        Left = 24
        Top = 200
        Width = 601
        Height = 61
        BevelOuter = bvNone
        TabOrder = 6
        object lblType: TLabel
          Left = 0
          Top = 37
          Width = 66
          Height = 13
          Caption = 'Account &Type'
          FocusControl = cmbType
        end
        object lblInst: TLabel
          Left = 0
          Top = 4
          Width = 49
          Height = 13
          Caption = '&Institution'
          FocusControl = eInst
        end
        object cmbType: TComboBox
          Left = 112
          Top = 33
          Width = 162
          Height = 21
          Style = csDropDownList
          Ctl3D = True
          ItemHeight = 13
          ParentCtl3D = False
          Sorted = True
          TabOrder = 1
          Items.Strings = (
            'Business credit card'
            'Cash'
            'Loan'
            'Personal credit card'
            'Trust')
        end
        object eInst: TEdit
          Left = 112
          Top = 0
          Width = 240
          Height = 24
          BorderStyle = bsNone
          MaxLength = 60
          TabOrder = 0
          Text = 'eInst'
          OnExit = eNumberExit
        end
        object chkPrivacy: TCheckBox
          Left = 280
          Top = 30
          Width = 317
          Height = 27
          Caption = '&Send Institution and Account Type to BankLink *'
          Checked = True
          State = cbChecked
          TabOrder = 2
          WordWrap = True
        end
      end
      object btnLedgerID: TButton
        Left = 24
        Top = 264
        Width = 129
        Height = 25
        Caption = 'Select &Fund'
        TabOrder = 7
        OnClick = btnLedgerIDClick
      end
      object cmbCurrency: TComboBox
        Left = 467
        Top = 8
        Width = 92
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = cmbCurrencyChange
        Items.Strings = (
          'GBP'
          'NZD'
          'AUD'
          'USD')
      end
      object pnlGainLoss: TPanel
        Left = 0
        Top = 104
        Width = 553
        Height = 34
        BevelOuter = bvNone
        TabOrder = 4
        DesignSize = (
          553
          34)
        object lblGainLoss: TLabel
          Left = 24
          Top = 1
          Width = 99
          Height = 33
          AutoSize = False
          Caption = '&Exchange Gain/Loss Code'
          FocusControl = eGainLoss
          WordWrap = True
        end
        object sbtnGainLossChart: TSpeedButton
          Left = 297
          Top = 3
          Width = 24
          Height = 22
          Flat = True
          OnClick = sbtnCodeClick
        end
        object lblGainLossDesc: TLabel
          Left = 331
          Top = 3
          Width = 217
          Height = 20
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'lblGainLossDesc'
        end
        object eGainLoss: TEdit
          Left = 136
          Top = 2
          Width = 153
          Height = 24
          BorderStyle = bsNone
          Ctl3D = True
          MaxLength = 10
          ParentCtl3D = False
          TabOrder = 0
          Text = '12345678901234567890'
          OnChange = eCodeChange
          OnExit = eCodeExit
          OnKeyPress = eCodeKeyPress
          OnKeyUp = eCodeKeyUp
        end
      end
    end
    object tbAnalysis: TTabSheet
      Caption = '&Analysis Coding'
      ImageIndex = 1
      object Label8: TLabel
        Left = 16
        Top = 16
        Width = 75
        Height = 13
        Caption = 'Analysis Coding'
      end
      object rbAnalysisEnabled: TRadioButton
        Left = 136
        Top = 16
        Width = 345
        Height = 17
        Caption = '&Enabled'
        Checked = True
        TabOrder = 0
        TabStop = True
      end
      object rbRestricted: TRadioButton
        Left = 136
        Top = 48
        Width = 345
        Height = 17
        Caption = '&Restricted to entry types 6, 7, 15, 30, 50, 56 and 57'
        TabOrder = 1
      end
      object rbVeryRestricted: TRadioButton
        Left = 136
        Top = 80
        Width = 345
        Height = 17
        Caption = 'Restricted to entry &types 6, 7, 56 and 57'
        TabOrder = 2
      end
      object rbDisabled: TRadioButton
        Left = 136
        Top = 112
        Width = 345
        Height = 17
        Caption = '&Disabled'
        TabOrder = 3
      end
    end
    object tbBankLinkOnline: TTabSheet
      Caption = 'BankLink Online'
      ImageIndex = 2
      object lblSelectExport: TLabel
        Left = 16
        Top = 11
        Width = 412
        Height = 16
        Caption = 
          'Select the Data Export options you want this account to be avail' +
          'able for:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblExportTo: TLabel
        Left = 16
        Top = 40
        Width = 55
        Height = 16
        Caption = 'Export To'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object chkLstAccVendors: TCheckListBox
        Left = 77
        Top = 40
        Width = 351
        Height = 108
        IntegralHeight = True
        ItemHeight = 13
        TabOrder = 0
      end
    end
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 486
    Width = 638
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      638
      37)
    object btnAdvanced: TButton
      Left = 8
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Ad&vanced'
      TabOrder = 0
      OnClick = btnAdvancedClick
    end
    object btnOK: TButton
      Left = 477
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Default = True
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 558
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
  end
  object OvcController1: TOvcController
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
    Epoch = 1900
    Left = 472
    Top = 8
  end
end
