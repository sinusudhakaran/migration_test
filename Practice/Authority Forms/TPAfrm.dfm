object frmTPA: TfrmTPA
  Left = 236
  Top = 116
  BorderIcons = [biSystemMenu]
  Caption = 'Third Party Authority'
  ClientHeight = 698
  ClientWidth = 692
  Color = clBtnFace
  Constraints.MinWidth = 640
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ScrollBox1: TScrollBox
    Left = 0
    Top = 0
    Width = 692
    Height = 657
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
      Top = 0
      Width = 671
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
        Width = 324
        Height = 13
        Caption = 
          'Incorporating BankLink Limited and Media Transfer Services Limit' +
          'ed '
      end
      object lblAddress: TLabel
        Left = 427
        Top = 4
        Width = 250
        Height = 41
        AutoSize = False
        Caption = 
          'Send completed form to:'#13'BankLink, PO Box 56354,'#13'Dominion Road, A' +
          'uckland 1446'
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
      Top = 177
      Width = 671
      Height = 64
      Align = alTop
      TabOrder = 2
      object Label4: TLabel
        Left = 13
        Top = 10
        Width = 86
        Height = 13
        Caption = 'Name of Account '
      end
      object Label5: TLabel
        Left = 13
        Top = 40
        Width = 83
        Height = 13
        Caption = 'Account Number '
      end
      object Label6: TLabel
        Left = 416
        Top = 10
        Width = 57
        Height = 13
        Caption = 'Client Code '
      end
      object Label7: TLabel
        Left = 416
        Top = 40
        Width = 52
        Height = 13
        Caption = 'Cost Code '
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
      object edtNumber3: TEdit
        Left = 112
        Top = 36
        Width = 281
        Height = 21
        Hint = 
          'Enter the account number (including bank & branch number, accoun' +
          't and suffix)'
        MaxLength = 32
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnExit = edtExit
      end
      object edtClient3: TEdit
        Left = 493
        Top = 6
        Width = 160
        Height = 21
        Hint = 'Enter the code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
      object edtCost3: TEdit
        Left = 493
        Top = 36
        Width = 160
        Height = 21
        Hint = 'Enter the cost code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
    end
    object pnlAccount2: TPanel
      Left = 0
      Top = 113
      Width = 671
      Height = 64
      Align = alTop
      TabOrder = 1
      object Label12: TLabel
        Left = 13
        Top = 10
        Width = 86
        Height = 13
        Caption = 'Name of Account '
      end
      object Label13: TLabel
        Left = 13
        Top = 40
        Width = 83
        Height = 13
        Caption = 'Account Number '
      end
      object Label14: TLabel
        Left = 416
        Top = 10
        Width = 57
        Height = 13
        Caption = 'Client Code '
      end
      object Label15: TLabel
        Left = 416
        Top = 40
        Width = 52
        Height = 13
        Caption = 'Cost Code '
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
      object edtNumber2: TEdit
        Left = 112
        Top = 36
        Width = 281
        Height = 21
        Hint = 
          'Enter the account number (including bank & branch number, accoun' +
          't and suffix)'
        MaxLength = 32
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnExit = edtExit
      end
      object edtClient2: TEdit
        Left = 493
        Top = 6
        Width = 160
        Height = 21
        Hint = 'Enter the code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
      object edtCost2: TEdit
        Left = 493
        Top = 36
        Width = 160
        Height = 21
        Hint = 'Enter the cost code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
    end
    object pnlFooter: TPanel
      Left = 0
      Top = 241
      Width = 671
      Height = 41
      Align = alTop
      TabOrder = 7
      object lblForm: TLabel
        Left = 16
        Top = 10
        Width = 241
        Height = 24
        Caption = 'THIRD PARTY AUTHORITY '
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
      Top = 49
      Width = 671
      Height = 64
      Align = alTop
      TabOrder = 0
      object lblAcName: TLabel
        Left = 13
        Top = 10
        Width = 86
        Height = 13
        Caption = 'Name of Account '
      end
      object lblAcNum: TLabel
        Left = 13
        Top = 40
        Width = 83
        Height = 13
        Caption = 'Account Number '
      end
      object lblClient: TLabel
        Left = 416
        Top = 6
        Width = 57
        Height = 13
        Caption = 'Client Code '
      end
      object lblCost: TLabel
        Left = 416
        Top = 36
        Width = 52
        Height = 13
        Caption = 'Cost Code '
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
      object edtNumber1: TEdit
        Left = 112
        Top = 36
        Width = 281
        Height = 21
        Hint = 
          'Enter the account number (including bank & branch number, accoun' +
          't and suffix)'
        MaxLength = 32
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnExit = edtExit
      end
      object edtClient1: TEdit
        Left = 493
        Top = 5
        Width = 160
        Height = 21
        Hint = 'Enter the code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
      object edtCost1: TEdit
        Left = 493
        Top = 32
        Width = 160
        Height = 21
        Hint = 'Enter the cost code your practice uses for this client'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
    end
    object pnlBank: TPanel
      Left = 0
      Top = 282
      Width = 671
      Height = 126
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 3
      object lblTo: TLabel
        Left = 8
        Top = 15
        Width = 89
        Height = 13
        Caption = 'To:  The Manager,'
      end
      object lblPos: TLabel
        Left = 8
        Top = 58
        Width = 159
        Height = 13
        Caption = '(Insert name of Bank and Branch)'
      end
      object lblPos1: TLabel
        Left = 8
        Top = 83
        Width = 157
        Height = 39
        Caption = 
          'And:'#13'To:   The General Manager,'#13'        Media Transfer Services ' +
          'Ltd'
      end
      object edtBank: TEdit
        Left = 8
        Top = 36
        Width = 387
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
      Top = 408
      Width = 671
      Height = 120
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 4
      object lblClause1: TLabel
        Left = 8
        Top = 18
        Width = 609
        Height = 52
        Caption = 
          'As from the               day of                             20 ' +
          '         you and each of you are hereby authorised to disclose a' +
          'nd/or make'#13'use of all data and information relating to my/our ba' +
          'nk account/s designated above which may be required in connectio' +
          'n with the'#13'performance of the processing services under any E.D.' +
          'P. Services Contract which you or either of you may now or herea' +
          'fter have'#13'with'
      end
      object lblPos2: TLabel
        Left = 8
        Top = 95
        Width = 84
        Height = 13
        Caption = '(my/our advisors) '
      end
      object lblPracticeCode: TLabel
        Left = 400
        Top = 95
        Width = 73
        Height = 13
        Caption = '(Practice Code)'
      end
      object cmbMonth: TComboBox
        Left = 140
        Top = 8
        Width = 78
        Height = 21
        Hint = 'Choose the month in which you want data collection to start'
        Style = csDropDownList
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
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
        Left = 240
        Top = 8
        Width = 20
        Height = 21
        Hint = 'Enter the year in which you want data collection to start'
        MaxLength = 2
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edtExit
      end
      object edtAdvisors: TEdit
        Left = 8
        Top = 72
        Width = 386
        Height = 21
        Hint = 'Enter your practice name'
        MaxLength = 50
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        OnExit = edtExit
      end
      object edtPractice: TEdit
        Left = 400
        Top = 72
        Width = 145
        Height = 21
        Hint = 'Enter your BankLink practice code'
        CharCase = ecUpperCase
        MaxLength = 8
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        OnExit = edtExit
        OnKeyPress = edtKeyPress
      end
      object cmbDay: TComboBox
        Left = 65
        Top = 8
        Width = 40
        Height = 21
        Hint = 'Choose the day on which you want data collection to start'
        Style = csDropDownList
        ItemHeight = 13
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Items.Strings = (
          ''
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9'
          '10'
          '11'
          '12'
          '13'
          '14'
          '15'
          '16'
          '17'
          '18'
          '19'
          '20'
          '21'
          '22'
          '23'
          '24'
          '25'
          '26'
          '27'
          '28'
          '29'
          '30'
          '31')
      end
    end
    object pnl2: TPanel
      Left = 0
      Top = 528
      Width = 671
      Height = 65
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 8
      object lblClause2: TLabel
        Left = 8
        Top = 4
        Width = 590
        Height = 52
        Caption = 
          'and neither of you shall be liable for delays, non-performance, ' +
          'failure to perform, processing errors or any other matter or thi' +
          'ng'#13'arising out of this authority or the contract which occur for' +
          ' reasons beyond your control and under no circumstances shall yo' +
          'ur'#13'liability (either joint or several) include or extend to any ' +
          'special or consequential loss or damage. This authority is termi' +
          'nable by'#13'you or either of you at any time without notice on any ' +
          'grounds you may think fit without rendering you liable in any wa' +
          'y.'
      end
    end
    object pnlSign: TPanel
      Left = 0
      Top = 593
      Width = 671
      Height = 207
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 9
      object lblDate: TLabel
        Left = 8
        Top = 14
        Width = 344
        Height = 13
        Caption = 
          'Dated this ................. day of ............................' +
          '........................ 20............'
      end
      object lblName: TLabel
        Left = 8
        Top = 55
        Width = 276
        Height = 26
        Caption = 
          '................................................................' +
          '............................'#13'(Print name of Third Party) '
      end
      object lblSign: TLabel
        Left = 295
        Top = 55
        Width = 360
        Height = 130
        Caption = 
          '................................................................' +
          '......................................'#13'(Signature of Third Party' +
          ')'#13#13'Signature confirmed:'#13#13#13'......................................' +
          '................................................................' +
          '    Manager'#13#13#13'..................................................' +
          '....................................................    Branch'
      end
    end
    object pnlExtras: TPanel
      Left = 0
      Top = 800
      Width = 671
      Height = 85
      Align = alBottom
      TabOrder = 5
      object lblAdditional: TLabel
        Left = 16
        Top = 9
        Width = 297
        Height = 13
        Caption = 'Additional Information to assist BankLink processing'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblMonthly: TLabel
        Left = 16
        Top = 33
        Width = 92
        Height = 13
        Caption = 'Service Frequency:'
      end
      object lblRural: TLabel
        Left = 16
        Top = 59
        Width = 105
        Height = 13
        Caption = 'Rural Institutions Only:'
      end
      object pnlService: TPanel
        Left = 160
        Top = 28
        Width = 489
        Height = 25
        BevelOuter = bvNone
        TabOrder = 0
        object rbMonthly: TRadioButton
          Left = 8
          Top = 5
          Width = 113
          Height = 17
          Hint = 'Click to select monthly (default) data delivery'
          Caption = 'Monthly (default)'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          TabStop = True
        end
        object rbWeekly: TRadioButton
          Left = 140
          Top = 5
          Width = 145
          Height = 17
          Hint = 'Click to select weekly data delivery'
          Caption = 'Weekly (where available)'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          TabStop = True
        end
        object rbDaily: TRadioButton
          Left = 313
          Top = 5
          Width = 129
          Height = 17
          Hint = 'Click to select daily data delivery'
          Caption = 'Daily (where available)'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          TabStop = True
        end
      end
      object pnlRural: TPanel
        Left = 160
        Top = 53
        Width = 489
        Height = 25
        BevelOuter = bvNone
        TabOrder = 1
        object rbReDate: TRadioButton
          Left = 8
          Top = 5
          Width = 209
          Height = 17
          Hint = 'Click to select re-dated transactions'
          Caption = 'Re-date transactions to Payment Date'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          TabStop = True
        end
        object rbDate: TRadioButton
          Left = 232
          Top = 5
          Width = 225
          Height = 17
          Hint = 'Click to select statement date transactions'
          Caption = 'Date shown on statement (not re-dated)'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          TabStop = True
        end
      end
    end
  end
  object Panel6: TPanel
    Left = 0
    Top = 657
    Width = 692
    Height = 41
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    DesignSize = (
      692
      41)
    object btnPreview: TButton
      Left = 16
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Preview the Third Party Authority Form'
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
      Hint = 'Save the Third Party Authority Form to a file'
      Caption = 'File'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnCancel: TButton
      Left = 603
      Top = 8
      Width = 80
      Height = 25
      Hint = 'Close the Third Party Authority Form'
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = btnCancelClick
    end
    object btnPrint: TButton
      Left = 422
      Top = 8
      Width = 85
      Height = 25
      Hint = 'Print the Third Party Authority Form'
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
      Hint = 'E-mail the Third Party Authority Form to the client'
      Caption = 'E-mail'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = btnEmailClick
    end
    object btnClear: TButton
      Left = 513
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
      Left = 340
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
