object frmCashBookMigrationWiz: TfrmCashBookMigrationWiz
  Left = 480
  Top = 386
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'MYOB Essentials Cashbook Migration'
  ClientHeight = 501
  ClientWidth = 754
  Color = clBtnFace
  Constraints.MinHeight = 526
  Constraints.MinWidth = 760
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 459
    Width = 754
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      754
      42)
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 754
      Height = 2
      Align = alTop
      Shape = bsTopLine
      ExplicitWidth = 622
    end
    object btnBack: TButton
      Left = 500
      Top = 12
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '< &Back'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnBackClick
    end
    object btnNext: TButton
      Left = 580
      Top = 12
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Next >'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnNextClick
    end
    object btnCancel: TButton
      Left = 668
      Top = 12
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 2
    end
  end
  object pnlWizard: TPanel
    Left = 0
    Top = 0
    Width = 754
    Height = 459
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlWizard'
    TabOrder = 0
    object Bevel2: TBevel
      Left = 0
      Top = 69
      Width = 754
      Height = 3
      Align = alTop
      Shape = bsTopLine
      ExplicitWidth = 593
    end
    object pnlTabTitle: TPanel
      Left = 0
      Top = 0
      Width = 754
      Height = 69
      Align = alTop
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 0
      DesignSize = (
        754
        69)
      object lblTitle: TLabel
        Left = 8
        Top = 8
        Width = 107
        Height = 16
        Caption = 'Title for Page 1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        ShowAccelChar = False
      end
      object lblDescription: TLabel
        Left = 8
        Top = 29
        Width = 732
        Height = 34
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Description for Page 1'
        ShowAccelChar = False
        WordWrap = True
        ExplicitWidth = 722
      end
    end
    object PageControl1: TPageControl
      Left = 0
      Top = 72
      Width = 754
      Height = 387
      ActivePage = tabSelectData
      Align = alClient
      Style = tsButtons
      TabHeight = 5
      TabOrder = 1
      TabStop = False
      TabWidth = 5
      object tabOverview: TTabSheet
        Caption = 'tabOverview'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        DesignSize = (
          746
          372)
        object BKOverviewWebBrowser: TBKWebBrowser
          Left = 12
          Top = 124
          Width = 723
          Height = 227
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          ControlData = {
            4C000000B94A0000761700000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E12620A000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
        object stgSelectedClients: TStringGrid
          Left = 12
          Top = 3
          Width = 723
          Height = 110
          ColCount = 2
          DefaultRowHeight = 20
          FixedCols = 0
          Options = [goRangeSelect, goRowSelect]
          TabOrder = 1
          ColWidths = (
            122
            583)
        end
      end
      object tabMYOBCredentials: TTabSheet
        Tag = 1
        Caption = 'tabMYOBCredentials'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        DesignSize = (
          746
          372)
        object pnlLogin: TPanel
          Left = 12
          Top = 3
          Width = 723
          Height = 169
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          object lblEmail: TLabel
            Left = 24
            Top = 27
            Width = 31
            Height = 16
            Caption = 'Email'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblPassword: TLabel
            Left = 24
            Top = 69
            Width = 55
            Height = 16
            Caption = 'Password'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblForgotPassword: TLabel
            Left = 24
            Top = 128
            Width = 131
            Height = 16
            Caption = 'Forgot your password?'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlue
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = [fsUnderline]
            ParentFont = False
            OnClick = lblForgotPasswordClick
          end
          object edtEmail: TEdit
            Left = 128
            Top = 24
            Width = 553
            Height = 24
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            OnChange = edtEmailChange
          end
          object edtPassword: TEdit
            Left = 128
            Top = 66
            Width = 553
            Height = 24
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            PasswordChar = '#'
            TabOrder = 1
            OnChange = edtEmailChange
          end
          object btnSignIn: TButton
            Left = 572
            Top = 124
            Width = 110
            Height = 25
            Caption = 'Login'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 2
            OnClick = btnSignInClick
          end
        end
        object pnlFirm: TPanel
          Left = 12
          Top = 194
          Width = 723
          Height = 164
          Anchors = [akLeft, akRight, akBottom]
          TabOrder = 1
          object Label6: TLabel
            Left = 0
            Top = 51
            Width = 713
            Height = 16
            Alignment = taCenter
            AutoSize = False
            Caption = 'MYOB Essentials Cashbook will be created in'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblSingleFirm: TLabel
            Left = 0
            Top = 83
            Width = 713
            Height = 16
            Alignment = taCenter
            AutoSize = False
            Caption = 'MYOB Essentials Cashbook will be created in'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object cmbSelectFirm: TComboBox
            Left = 230
            Top = 80
            Width = 254
            Height = 24
            Style = csDropDownList
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ItemHeight = 0
            ParentFont = False
            TabOrder = 0
            OnChange = cmbSelectFirmChange
          end
        end
      end
      object tabSelectData: TTabSheet
        Tag = 2
        Caption = 'tabSelectData'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ImageIndex = 2
        ParentFont = False
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        DesignSize = (
          746
          372)
        object pnlSelectData: TPanel
          Left = 12
          Top = 3
          Width = 723
          Height = 357
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          object lblBankfeeds3: TLabel
            Left = 79
            Top = 125
            Width = 650
            Height = 16
            AutoSize = False
            Caption = 'Bank Feeds'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblMems1: TLabel
            Left = 31
            Top = 275
            Width = 650
            Height = 16
            AutoSize = False
            Caption = 
              'Memorisations - you can add these manually as '#39'Rules'#39' in MYOB Es' +
              'sentials Cashbook.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblBankfeeds1: TLabel
            Left = 48
            Top = 25
            Width = 650
            Height = 16
            AutoSize = False
            Caption = 'Bank feeds'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblBankfeeds2: TLabel
            Left = 80
            Top = 75
            Width = 650
            Height = 16
            AutoSize = False
            Caption = 'They will be deleted from'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblBankfeeds4: TLabel
            Left = 80
            Top = 150
            Width = 650
            Height = 16
            AutoSize = False
            Caption = 'you can request to have your Bank feed from'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object chkChartofAccount: TCheckBox
            Left = 32
            Top = 175
            Width = 650
            Height = 17
            Caption = 'Chart of Accounts'
            Checked = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 2
            OnClick = chkChartofAccountClick
          end
          object chkBalances: TCheckBox
            Left = 49
            Top = 200
            Width = 650
            Height = 17
            Caption = 'Chart of Account balances'
            Checked = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 3
          end
          object chkTransactions: TCheckBox
            Left = 32
            Top = 225
            Width = 650
            Height = 17
            Caption = 'Non-transferred transaction data'
            Checked = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 4
          end
          object radMove: TRadioButton
            Left = 50
            Top = 52
            Width = 650
            Height = 17
            Caption = 'Move'
            TabOrder = 0
            OnClick = radCopyClick
          end
          object radCopy: TRadioButton
            Left = 50
            Top = 100
            Width = 650
            Height = 17
            Caption = 'Copy'
            TabOrder = 1
            OnClick = radCopyClick
          end
          object CheckBox1: TCheckBox
            Left = 32
            Top = 25
            Width = 17
            Height = 17
            Checked = True
            Enabled = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clInfoText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 5
            OnClick = chkChartofAccountClick
          end
        end
      end
      object tabProgress: TTabSheet
        Tag = 4
        Caption = 'tabProgress'
        ImageIndex = 4
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        DesignSize = (
          746
          372)
        object pnlProgress: TPanel
          Left = 12
          Top = 3
          Width = 723
          Height = 357
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          object lblProgressTitle: TLabel
            Left = 150
            Top = 128
            Width = 401
            Height = 25
            Alignment = taCenter
            AutoSize = False
            Caption = 'Migrating Data to MYOB Essentials Cashbook'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            ShowAccelChar = False
            Transparent = True
          end
          object lblClientFiles: TLabel
            Left = 150
            Top = 159
            Width = 401
            Height = 18
            Alignment = taCenter
            AutoSize = False
            Caption = '1 of 10 files'
          end
          object prgClientFiles: TRzProgressBar
            Left = 150
            Top = 179
            Width = 401
            Height = 15
            BarStyle = bsLED
            BorderOuter = fsBump
            BorderWidth = 0
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clHighlight
            Font.Height = -15
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            InteriorOffset = 1
            NumSegments = 50
            ParentFont = False
            PartsComplete = 0
            Percent = 0
            ShowPercent = False
            TotalParts = 0
          end
        end
      end
      object tabComplete: TTabSheet
        Tag = 5
        Caption = 'tabComplete'
        ImageIndex = 5
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object pnlCashbookComplete: TPanel
          Left = 0
          Top = 0
          Width = 746
          Height = 161
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object lblClientCompleteAmount: TLabel
            Left = 25
            Top = 15
            Width = 453
            Height = 16
            Caption = 
              '% client(s) and their data are now being created in MYOB Essenti' +
              'als Cashbook.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblCashbookMigrated: TLabel
            Left = 25
            Top = 129
            Width = 611
            Height = 16
            Caption = 
              'It may take up to 48 hours for all client data to be available. ' +
              'You can check the status of your bank feeds in'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblCashbookLoginLink: TLabel
            Left = 25
            Top = 107
            Width = 147
            Height = 16
            Caption = 'You can log into (%) here'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlue
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = [fsUnderline]
            ParentFont = False
            OnClick = lblCashbookLoginLinkClick
          end
          object lblYuoCanCheckYourStatus: TLabel
            Left = 25
            Top = 151
            Width = 408
            Height = 16
            Caption = 
              'This will show your Cashbooks when the migration has fully compl' +
              'eted.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object stgClientsMigrated: TStringGrid
            Left = 25
            Top = 37
            Width = 681
            Height = 64
            ColCount = 2
            DefaultRowHeight = 20
            FixedCols = 0
            Options = [goRangeSelect, goRowSelect]
            TabOrder = 0
            ColWidths = (
              122
              583)
          end
        end
        object pnlCashbookErrors: TPanel
          Left = 0
          Top = 161
          Width = 746
          Height = 211
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          DesignSize = (
            746
            211)
          object lblClientError: TLabel
            Left = 25
            Top = 0
            Width = 276
            Height = 16
            Caption = 'The following % client(s) could not be migrated.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object lblClientErrorSupport: TLabel
            Left = 25
            Top = 186
            Width = 306
            Height = 16
            Anchors = [akLeft, akBottom]
            Caption = 'Please contact (support) if the problems persist : (%)'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            ExplicitTop = 152
          end
          object lblMoreInfoOnErros: TLabel
            Left = 25
            Top = 164
            Width = 339
            Height = 16
            Anchors = [akLeft, akBottom]
            Caption = 'For more information on errors, please see the system log.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            ExplicitTop = 154
          end
          object stgClientErrors: TStringGrid
            Left = 25
            Top = 22
            Width = 691
            Height = 135
            Anchors = [akLeft, akTop, akRight, akBottom]
            ColCount = 2
            DefaultRowHeight = 20
            FixedCols = 0
            Options = [goRangeSelect, goRowSelect]
            TabOrder = 0
            ColWidths = (
              122
              583)
          end
        end
      end
      object tabCheckList: TTabSheet
        Caption = 'tabCheckList'
        ImageIndex = 6
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        DesignSize = (
          746
          372)
        object BKChecklistWebBrowser: TBKWebBrowser
          Left = 12
          Top = 3
          Width = 723
          Height = 347
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          ControlData = {
            4C000000B94A0000DD2300000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E12620A000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
    end
    object pnlTabButtonHider: TPanel
      Left = 57
      Top = 69
      Width = 185
      Height = 11
      BevelOuter = bvLowered
      TabOrder = 2
    end
  end
end
