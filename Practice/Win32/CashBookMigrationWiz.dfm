object frmCashBookMigrationWiz: TfrmCashBookMigrationWiz
  Left = 480
  Top = 386
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'MYOB Essentials Cashbook Migration'
  ClientHeight = 491
  ClientWidth = 744
  Color = clBtnFace
  Constraints.MinHeight = 526
  Constraints.MinWidth = 760
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 449
    Width = 744
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      744
      42)
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 744
      Height = 2
      Align = alTop
      Shape = bsTopLine
      ExplicitWidth = 622
    end
    object btnBack: TButton
      Left = 490
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
      Left = 570
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
      Left = 658
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
    Width = 744
    Height = 449
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlWizard'
    TabOrder = 0
    object Bevel2: TBevel
      Left = 0
      Top = 69
      Width = 744
      Height = 3
      Align = alTop
      Shape = bsTopLine
      ExplicitWidth = 593
    end
    object pnlTabTitle: TPanel
      Left = 0
      Top = 0
      Width = 744
      Height = 69
      Align = alTop
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 0
      DesignSize = (
        744
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
        Width = 722
        Height = 34
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Description for Page 1'
        ShowAccelChar = False
        WordWrap = True
      end
    end
    object PageControl1: TPageControl
      Left = 0
      Top = 72
      Width = 744
      Height = 377
      ActivePage = tabMYOBCredentials
      Align = alClient
      Style = tsButtons
      TabHeight = 5
      TabOrder = 1
      TabStop = False
      TabWidth = 5
      object tabOverview: TTabSheet
        Caption = 'tabOverview'
        DesignSize = (
          736
          362)
        object BKOverviewWebBrowser: TBKWebBrowser
          Left = 3
          Top = 3
          Width = 717
          Height = 351
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          ControlData = {
            4C0000001B4A0000472400000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E12620A000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
      object tabMYOBCredentials: TTabSheet
        Tag = 1
        Caption = 'tabMYOBCredentials'
        ImageIndex = 1
        DesignSize = (
          736
          362)
        object pnlLogin: TPanel
          Left = 10
          Top = 3
          Width = 716
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
          end
          object btnForgotPassword: TButton
            Left = 24
            Top = 124
            Width = 132
            Height = 25
            Caption = 'Forgot Password'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 2
            OnClick = btnForgotPasswordClick
          end
          object btnSignUp: TButton
            Left = 162
            Top = 124
            Width = 110
            Height = 25
            Caption = 'Sign Up'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 3
            OnClick = btnSignUpClick
          end
          object btnSignIn: TButton
            Left = 572
            Top = 124
            Width = 110
            Height = 25
            Caption = 'Sign in'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 4
            OnClick = btnSignInClick
          end
        end
        object pnlFirm: TPanel
          Left = 10
          Top = 180
          Width = 716
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
            ItemHeight = 16
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
        DesignSize = (
          736
          362)
        object pnlSelectData: TPanel
          Left = 10
          Top = 3
          Width = 716
          Height = 351
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          object Label3: TLabel
            Left = 37
            Top = 156
            Width = 484
            Height = 16
            Caption = 
              'Bank Feeds - your Bank Feeds will no longer be delivered to Prac' +
              'tice after migration.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label4: TLabel
            Left = 37
            Top = 193
            Width = 487
            Height = 16
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
          object Label5: TLabel
            Left = 55
            Top = 27
            Width = 65
            Height = 16
            Caption = 'Bank Feeds'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object chkBankFeed: TCheckBox
            Left = 37
            Top = 26
            Width = 12
            Height = 21
            Checked = True
            Enabled = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 0
          end
          object chkChartofAccount: TCheckBox
            Left = 37
            Top = 62
            Width = 180
            Height = 17
            Caption = 'Chart of Account'
            Checked = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 1
            OnClick = chkChartofAccountClick
          end
          object chkBalances: TCheckBox
            Left = 55
            Top = 85
            Width = 180
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
            TabOrder = 2
          end
          object chkTransactions: TCheckBox
            Left = 37
            Top = 121
            Width = 356
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
            TabOrder = 3
          end
        end
      end
      object tabProgress: TTabSheet
        Tag = 4
        Caption = 'tabProgress'
        ImageIndex = 4
        DesignSize = (
          736
          362)
        object pnlProgress: TPanel
          Left = 10
          Top = 0
          Width = 716
          Height = 351
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
        object pnlCashbookComplete: TPanel
          Left = 0
          Top = 0
          Width = 736
          Height = 134
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object lblClientCompleteAmount: TLabel
            Left = 24
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
            Left = 24
            Top = 85
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
          object lblCashbookLoginLink: TLabel
            Left = 24
            Top = 45
            Width = 147
            Height = 16
            Caption = 'You can log into (%) here'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlue
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = [fsUnderline]
            ParentFont = False
          end
        end
        object pnlCashbookErrors: TPanel
          Left = 0
          Top = 134
          Width = 736
          Height = 228
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          DesignSize = (
            736
            228)
          object lblClientError: TLabel
            Left = 24
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
            Left = 24
            Top = 203
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
          end
          object lstClientErrors: TListBox
            Left = 24
            Top = 22
            Width = 681
            Height = 175
            Anchors = [akLeft, akTop, akBottom]
            ItemHeight = 13
            TabOrder = 0
          end
        end
      end
      object tabCheckList: TTabSheet
        Caption = 'tabCheckList'
        ImageIndex = 6
        DesignSize = (
          736
          362)
        object BKChecklistWebBrowser: TBKWebBrowser
          Left = 3
          Top = 3
          Width = 717
          Height = 351
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          ControlData = {
            4C0000001B4A0000472400000000000000000000000000000000000000000000
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
