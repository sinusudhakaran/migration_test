object frmCAF: TfrmCAF
  Left = 256
  Top = 163
  BorderIcons = [biSystemMenu]
  Caption = 'Client Authority Form'
  ClientHeight = 748
  ClientWidth = 709
  Color = clBtnFace
  Constraints.MinWidth = 350
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 709
    Height = 707
    VertScrollBar.Position = 246
    Align = alClient
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object pnlHeader: TPanel
      Left = 0
      Top = -246
      Width = 688
      Height = 49
      Align = alTop
      TabOrder = 6
      object lblTitle: TLabel
        Left = 16
        Top = 4
        Width = 107
        Height = 29
        Caption = 'BankLink'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -24
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblSubtitle: TLabel
        Left = 16
        Top = 33
        Width = 219
        Height = 13
        Caption = '(A Division of Media Transfer Services Limited)'
      end
      object lblAddress: TLabel
        Left = 467
        Top = 4
        Width = 207
        Height = 41
        AutoSize = False
        Caption = 'Send completed form to:'#13'BankLink'#13'GPO Box 4608, Sydney 2001, NSW'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
    end
    object pnlAccount3: TPanel
      Left = 0
      Top = -69
      Width = 688
      Height = 64
      Align = alTop
      TabOrder = 2
      object Label4: TLabel
        Left = 13
        Top = 10
        Width = 83
        Height = 13
        Caption = 'Name of Account'
      end
      object Label5: TLabel
        Left = 13
        Top = 40
        Width = 80
        Height = 13
        Caption = 'Account Number'
      end
      object Label6: TLabel
        Left = 416
        Top = 10
        Width = 54
        Height = 13
        Caption = 'Client Code'
      end
      object Label7: TLabel
        Left = 416
        Top = 40
        Width = 49
        Height = 13
        Caption = 'Cost Code'
      end
      object edtName3: TEdit
        Left = 112
        Top = 6
        Width = 281
        Height = 21
        Hint = 'Enter the account name'
        MaxLength = 50
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnExit = edtExit
      end
      object edtBSB3: TEdit
        Left = 112
        Top = 36
        Width = 81
        Height = 21
        Hint = 'Enter the BSB for this account'
        MaxLength = 7
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnExit = edtExit
      end
      object edtNumber3: TEdit
        Left = 191
        Top = 36
        Width = 202
        Height = 21
        Hint = 'Enter the account number'
        MaxLength = 32
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edtExit
      end
      object edtClient3: TEdit
        Left = 493
        Top = 6
        Width = 161
        Height = 21
        Hint = 'Enter the code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
      object edtCost3: TEdit
        Left = 493
        Top = 37
        Width = 161
        Height = 21
        Hint = 'Enter the cost code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
    end
    object pnlAccount2: TPanel
      Left = 0
      Top = -133
      Width = 688
      Height = 64
      Align = alTop
      TabOrder = 1
      object Label12: TLabel
        Left = 13
        Top = 10
        Width = 83
        Height = 13
        Caption = 'Name of Account'
      end
      object Label13: TLabel
        Left = 13
        Top = 40
        Width = 80
        Height = 13
        Caption = 'Account Number'
      end
      object Label14: TLabel
        Left = 416
        Top = 10
        Width = 54
        Height = 13
        Caption = 'Client Code'
      end
      object Label15: TLabel
        Left = 416
        Top = 40
        Width = 49
        Height = 13
        Caption = 'Cost Code'
      end
      object edtName2: TEdit
        Left = 112
        Top = 6
        Width = 281
        Height = 21
        Hint = 'Enter the account name'
        MaxLength = 50
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnExit = edtExit
      end
      object edtBSB2: TEdit
        Left = 112
        Top = 36
        Width = 81
        Height = 21
        Hint = 'Enter the BSB for this account'
        MaxLength = 7
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnExit = edtExit
      end
      object edtNumber2: TEdit
        Left = 191
        Top = 36
        Width = 202
        Height = 21
        Hint = 'Enter the account number'
        MaxLength = 32
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edtExit
      end
      object edtClient2: TEdit
        Left = 493
        Top = 6
        Width = 161
        Height = 21
        Hint = 'Enter the code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
      object edtCost2: TEdit
        Left = 493
        Top = 36
        Width = 161
        Height = 21
        Hint = 'Enter the cost code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
    end
    object pnlFooter: TPanel
      Left = 0
      Top = -5
      Width = 688
      Height = 41
      Align = alTop
      TabOrder = 7
      object lblForm: TLabel
        Left = 16
        Top = 9
        Width = 275
        Height = 24
        Caption = 'BANKLINK CLIENT AUTHORITY'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -18
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
    end
    object pnlAccount1: TPanel
      Left = 0
      Top = -197
      Width = 688
      Height = 64
      Align = alTop
      TabOrder = 0
      object lblAcName: TLabel
        Left = 13
        Top = 10
        Width = 83
        Height = 13
        Caption = 'Name of Account'
      end
      object lblAcNum: TLabel
        Left = 13
        Top = 40
        Width = 80
        Height = 13
        Caption = 'Account Number'
      end
      object lblClient: TLabel
        Left = 416
        Top = 6
        Width = 54
        Height = 13
        Caption = 'Client Code'
      end
      object lblCost: TLabel
        Left = 416
        Top = 36
        Width = 49
        Height = 13
        Caption = 'Cost Code'
      end
      object edtName1: TEdit
        Left = 112
        Top = 6
        Width = 281
        Height = 21
        Hint = 'Enter the account name'
        MaxLength = 50
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnExit = edtExit
      end
      object edtBSB1: TEdit
        Left = 112
        Top = 36
        Width = 81
        Height = 21
        Hint = 'Enter the BSB for this account'
        MaxLength = 7
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnExit = edtExit
      end
      object edtNumber1: TEdit
        Left = 191
        Top = 36
        Width = 202
        Height = 21
        Hint = 'Enter the account number'
        MaxLength = 32
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edtExit
      end
      object edtClient1: TEdit
        Left = 493
        Top = 6
        Width = 161
        Height = 21
        Hint = 'Enter the code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
      object edtCost1: TEdit
        Left = 493
        Top = 33
        Width = 161
        Height = 21
        Hint = 'Enter the cost code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
    end
    object pnlBank: TPanel
      Left = 0
      Top = 36
      Width = 688
      Height = 88
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 3
      object lblTo: TLabel
        Left = 8
        Top = 15
        Width = 16
        Height = 13
        Caption = 'To:'
      end
      object lblManager: TLabel
        Left = 32
        Top = 15
        Width = 481
        Height = 13
        Caption = 
          'The Manager,                                                    ' +
          '                                                                ' +
          '                and'
      end
      object lblBankLink: TLabel
        Left = 524
        Top = 26
        Width = 151
        Height = 26
        Caption = 'Media Transfer Services Limited'#13'("BankLink")'
      end
      object lblPos: TLabel
        Left = 32
        Top = 55
        Width = 242
        Height = 13
        Caption = 
          '(Bank)                                                         (' +
          'Branch)'
      end
      object lblPos1: TLabel
        Left = 32
        Top = 68
        Width = 59
        Height = 13
        Caption = '("the Bank")'
      end
      object lblTheGeneralManager: TLabel
        Left = 524
        Top = 15
        Width = 107
        Height = 13
        Caption = 'The General Manager,'
      end
      object edtBank: TEdit
        Left = 32
        Top = 28
        Width = 455
        Height = 21
        Hint = 
          'Enter the name of the bank and branch where the account(s) are h' +
          'eld'
        MaxLength = 50
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnExit = edtExit
      end
    end
    object pnl1: TPanel
      Left = 0
      Top = 124
      Width = 688
      Height = 99
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 4
      object lblClause1: TLabel
        Left = 8
        Top = 12
        Width = 645
        Height = 39
        Caption = 
          '1.    I/We hereby AUTHORISE the Bank and BankLink as at and from' +
          ' the first of                                  20               ' +
          'to forward all data and'#13'       information (whether in written, ' +
          'computer readable or any other format) relating to my/our banks ' +
          'account/s designated above to each'#13'       other and to'
      end
      object lblPos2: TLabel
        Left = 32
        Top = 78
        Width = 91
        Height = 13
        Caption = '("my/our advisors")'
      end
      object lblPracticeCode: TLabel
        Left = 510
        Top = 80
        Width = 67
        Height = 13
        Caption = 'Practice Code'
      end
      object cmbMonth: TComboBox
        Left = 394
        Top = 6
        Width = 93
        Height = 21
        Hint = 'Choose the month in which you want data collection to start'
        Style = csDropDownList
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = cmbMonthChange
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
      object edtYear: TEdit
        Left = 510
        Top = 6
        Width = 33
        Height = 21
        Hint = 'Enter the year in which you want data collection to start'
        MaxLength = 2
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnExit = edtExit
      end
      object edtAdvisors: TEdit
        Left = 29
        Top = 51
        Width = 458
        Height = 21
        Hint = 'Enter your practice name'
        MaxLength = 50
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edtExit
      end
      object edtPractice: TEdit
        Left = 510
        Top = 53
        Width = 115
        Height = 21
        Hint = 'Enter your BankLink practice code'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
    end
    object pnl2: TPanel
      Left = 0
      Top = 223
      Width = 688
      Height = 113
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 8
      object lblClause2: TLabel
        Left = 8
        Top = 3
        Width = 649
        Height = 104
        Caption = 
          '2.    I/We UNDERSTAND that:'#13'      a) no agency, partnership, joi' +
          'nt venture or any other type of similar relationship exists betw' +
          'een the Bank and BankLink and that the '#13'          Bank accepts n' +
          'o responsibility for the actions of BankLink, my/our advisors or' +
          ' any other third party;'#13'      b) neither the Bank nor BankLink w' +
          'ill, subject to any prohibition or limitation imposed by law, be' +
          ' liable for delays, non-performance, '#13'          failure to perfo' +
          'rm, processing errors or any other matter or thing arising out o' +
          'f this authority or any agreement which the Bank or '#13'          B' +
          'ankLink may have with my/our advisors and which occur for reason' +
          's beyond the control of respectively the Bank or BankLink, as '#13' ' +
          '         the case may be, nor will the liability of the Bank and' +
          '/or BankLink (whether jointly, severally or jointly and severall' +
          'y) include or '#13'          extend to any special or consequential ' +
          'loss or damage suffered by me/us.'
      end
    end
    object pnl3: TPanel
      Left = 0
      Top = 336
      Width = 688
      Height = 48
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 9
      object lblClause3: TLabel
        Left = 8
        Top = 3
        Width = 663
        Height = 39
        Caption = 
          '3.    I/We ACKNOWLEDGE that the Bank will receive a commission f' +
          'rom BankLink for disclosing the data and information referred to' +
          ' above, '#13'       and that the Bank is under no obligation to me/u' +
          's to supply the data and information referred to above to BankLi' +
          'nk, and may cease to '#13'       do so without notice to me/us.'
      end
    end
    object pnl4: TPanel
      Left = 0
      Top = 384
      Width = 688
      Height = 74
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 10
      object lblClause45: TLabel
        Left = 8
        Top = 2
        Width = 645
        Height = 65
        Caption = 
          '4.    This authority is terminable by any or both of the Bank or' +
          ' BankLink at any time where seven (7) days notice is given to me' +
          '/us on any '#13'       grounds thought fit, without rendering the Ba' +
          'nk and/or BankLink liable in any way.'#13#13'5.    Any revocation of t' +
          'his authority by me/us will not take effect until 14 days after ' +
          'written notice of the revocation is received by the '#13'       Bank' +
          ' from me/us.'
      end
    end
    object pnlSign: TPanel
      Left = 0
      Top = 458
      Width = 688
      Height = 161
      Align = alTop
      BevelOuter = bvNone
      Constraints.MinWidth = 640
      TabOrder = 11
      object lblSign: TLabel
        Left = 29
        Top = 23
        Width = 638
        Height = 130
        Caption = 
          'Dated this ................. day of ............................' +
          '........................ 20............'#13#13#13#13'.....................' +
          '................................................................' +
          '.................        .......................................' +
          '...............................................................'#13 +
          '(Account signatory)                                             ' +
          '                                                                ' +
          '                                           (Account signatory)'#13#13 +
          #13'...............................................................' +
          '.......................................        .................' +
          '................................................................' +
          '.....................'#13'(Witness)                                 ' +
          '                                                                ' +
          '                                                                ' +
          '                      (Witness)'
      end
    end
    object pnlFrequency: TPanel
      Left = 0
      Top = 619
      Width = 688
      Height = 84
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 5
      object Panel1: TPanel
        Tag = 29
        Left = 29
        Top = 6
        Width = 637
        Height = 77
        BevelOuter = bvNone
        BorderWidth = 1
        BorderStyle = bsSingle
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 0
        object lblAdditionalInfo: TLabel
          Left = 14
          Top = 9
          Width = 231
          Height = 13
          Caption = 'Additional information to assist BankLink'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblServiceFrequency: TLabel
          Left = 14
          Top = 53
          Width = 92
          Height = 13
          Caption = 'Service Frequency:'
        end
        object rbMonthly: TRadioButton
          Left = 137
          Top = 52
          Width = 113
          Height = 17
          Hint = 'Click to select monthly data delivery'
          Caption = 'Monthly (default)'
          TabOrder = 0
          TabStop = True
        end
        object rbWeekly: TRadioButton
          Left = 271
          Top = 52
          Width = 150
          Height = 17
          Hint = 'Click to select weekly data delivery'
          Caption = 'Weekly (where available)'
          TabOrder = 1
          TabStop = True
        end
        object rbDaily: TRadioButton
          Left = 444
          Top = 52
          Width = 150
          Height = 17
          Hint = 'Click to select daily data delivery'
          Caption = 'Daily (where available)'
          TabOrder = 2
          TabStop = True
        end
        object cbProvisional: TCheckBox
          Left = 14
          Top = 29
          Width = 586
          Height = 17
          Caption = 
            'Please supply the account(s) above as Provisional Account(s) if ' +
            'they are not available from the Bank'
          TabOrder = 3
        end
      end
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 707
    Width = 709
    Height = 41
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    DesignSize = (
      709
      41)
    object btnPreview: TButton
      Left = 16
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Preview the Client Authority Form'
      Caption = 'Preview'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 107
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Save the Client Authority Form to a file'
      Caption = 'File'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnCancel: TButton
      Left = 616
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Close the Client Authority Form'
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = btnCancelClick
    end
    object btnPrint: TButton
      Left = 434
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Print the Client Authority Form'
      Anchors = [akRight, akBottom]
      Caption = 'Print'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = btnPrintClick
    end
    object btnEmail: TButton
      Left = 197
      Top = 8
      Width = 85
      Height = 25
      Hint = 'E-mail the Client Authority Form to the client'
      Caption = 'E-mail'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = btnEmailClick
    end
    object btnClear: TButton
      Left = 525
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Clear the form'
      Anchors = [akRight, akBottom]
      Caption = 'Reset Form'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = btnClearClick
    end
    object btnImport: TButton
      Left = 353
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Import'
      TabOrder = 6
      OnClick = btnImportClick
    end
  end
  object Opendlg: TOpenDialog
    Filter = 'Excel file*.xls|*.xls'
    Left = 320
    Top = 16
  end
end
