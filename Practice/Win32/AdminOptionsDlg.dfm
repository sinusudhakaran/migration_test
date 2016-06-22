object dlgAdminOptions: TdlgAdminOptions
  Left = 317
  Top = 231
  ActiveControl = chkExtractQty
  BorderStyle = bsDialog
  Caption = 'System Options'
  ClientHeight = 471
  ClientWidth = 618
  Color = clWhite
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 431
    Width = 618
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 618
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnOK: TButton
      Left = 456
      Top = 9
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 536
      Top = 9
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pcOptions: TPageControl
    Left = 0
    Top = 0
    Width = 618
    Height = 433
    ActivePage = tsInterfaces
    Align = alTop
    MultiLine = True
    TabOrder = 1
    object tsGeneral: TTabSheet
      Caption = 'General'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lh1: TLabel
        Left = 16
        Top = 3
        Width = 77
        Height = 13
        Caption = 'General Options'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object Bevel1: TBevel
        Left = 107
        Top = 9
        Width = 473
        Height = 8
        Shape = bsTopLine
      end
      object Label32: TLabel
        Left = 361
        Top = 311
        Width = 3
        Height = 13
      end
      object Panel1: TPanel
        Left = 3
        Top = 120
        Width = 590
        Height = 364
        BevelEdges = []
        BevelOuter = bvNone
        TabOrder = 3
        object lblAutoSaveTime: TLabel
          Left = 193
          Top = 65
          Width = 37
          Height = 13
          Caption = 'minutes'
        end
        object Label18: TLabel
          Left = 21
          Top = 65
          Width = 80
          Height = 13
          Caption = 'Auto &save every'
        end
        object Label31: TLabel
          Left = 21
          Top = 171
          Width = 77
          Height = 13
          Caption = 'Coding hint font'
        end
        object btnReportPwd: TButton
          Left = 385
          Top = 203
          Width = 145
          Height = 25
          Caption = '&Change Password'
          Enabled = False
          TabOrder = 9
          OnClick = btnReportPwdClick
        end
        object chkReportPwd: TCheckBox
          Left = 22
          Top = 199
          Width = 361
          Height = 25
          Caption = 'Pass&word protect Statements and Download Documents'
          TabOrder = 8
          OnClick = chkReportPwdClick
        end
        object pnlCESFont: TPanel
          Left = 442
          Top = 158
          Width = 161
          Height = 39
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = 'Coding hint'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 10
        end
        object btnReset: TButton
          Left = 385
          Top = 168
          Width = 51
          Height = 25
          Caption = 'R&eset'
          TabOrder = 7
          OnClick = btnResetClick
        end
        object cbSize: TRzComboBox
          Left = 328
          Top = 168
          Width = 42
          Height = 21
          AllowEdit = False
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 6
          OnChange = cbSizeChange
          Items.Strings = (
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
            '16')
        end
        object cbceFont: TRzFontComboBox
          Left = 121
          Top = 168
          Width = 201
          Height = 22
          PreviewFontSize = 8
          PreviewText = 'Coding Hint'
          DropDownWidth = 200
          ItemHeight = 18
          TabOrder = 5
          OnChange = cbceFontChange
        end
        object chkRetrieve: TCheckBox
          Left = 22
          Top = 123
          Width = 417
          Height = 17
          Caption = 'Automatically retrieve new &transactions when a Client is opened'
          TabOrder = 4
        end
        object chkUsage: TCheckBox
          Left = 21
          Top = 94
          Width = 385
          Height = 17
          Caption = 'Allow BankLink to collect software &usage information'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object rsAutoSaveTime: TRzSpinEdit
          Left = 130
          Top = 63
          Width = 49
          Height = 21
          AllowKeyEdit = True
          Max = 30.000000000000000000
          TabOrder = 2
          OnChange = rsAutoSaveTimeChange
        end
        object chkDissectedNarration: TCheckBox
          Left = 21
          Top = 36
          Width = 385
          Height = 17
          Caption = '&Replace Narration with Payee Name for Dissected Payees'
          TabOrder = 1
        end
        object chkIgnoreQuantity: TCheckBox
          Left = 21
          Top = 7
          Width = 217
          Height = 17
          Caption = '&Ignore quantity in downloads'
          TabOrder = 0
        end
      end
      object chkAutoPrintSchRepSummary: TCheckBox
        Left = 24
        Top = 69
        Width = 533
        Height = 17
        Caption = '&Automatically print the Scheduled Reports summary'
        TabOrder = 1
      end
      object chkCopyNarrationDissection: TCheckBox
        Left = 24
        Top = 40
        Width = 533
        Height = 17
        Caption = 'Set default &Narration when coding Dissections and Journals'
        TabOrder = 0
      end
      object chkAutoLogin: TCheckBox
        Left = 24
        Top = 98
        Width = 161
        Height = 17
        Caption = 'Allow automatic &login'
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
    end
    object tsExporting: TTabSheet
      Caption = 'Exporting'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lh2: TLabel
        Left = 16
        Top = 3
        Width = 94
        Height = 13
        Caption = 'Bulk Export Options'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object Bevel4: TBevel
        Left = 128
        Top = 9
        Width = 442
        Height = 8
        Shape = bsTopLine
      end
      object pnlCSVEXtract: TPanel
        Left = 34
        Top = 64
        Width = 543
        Height = 147
        BevelOuter = bvNone
        TabOrder = 1
        object Label2: TLabel
          Left = 2
          Top = 21
          Width = 72
          Height = 13
          Caption = 'Default Format'
          FocusControl = ckBulkExport
        end
        object cbBulkExport: TComboBox
          Left = 107
          Top = 18
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
        end
      end
      object ckBulkExport: TCheckBox
        Left = 32
        Top = 40
        Width = 297
        Height = 17
        Caption = '&Enable Bulk Data Export'
        TabOrder = 0
        OnClick = ckBulkExportClick
      end
    end
    object tsAdvanced: TTabSheet
      Caption = 'Advanced'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lh3: TLabel
        Left = 16
        Top = 3
        Width = 114
        Height = 13
        Caption = 'System Log File Options'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label4: TLabel
        Left = 28
        Top = 38
        Width = 124
        Height = 13
        Caption = '&Minimum Log File Size (Kb)'
        FocusControl = rsMinLogSize
      end
      object Label5: TLabel
        Left = 290
        Top = 38
        Width = 128
        Height = 13
        Caption = 'M&aximum Log File Size (Kb)'
        FocusControl = rsMaxLogSize
      end
      object Label6: TLabel
        Left = 28
        Top = 73
        Width = 142
        Height = 13
        Caption = '&Directory for Log File Backups'
        FocusControl = edtLogBackupsDir
      end
      object lh4: TLabel
        Left = 16
        Top = 134
        Width = 75
        Height = 13
        Caption = 'Locking Options'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label8: TLabel
        Left = 28
        Top = 158
        Width = 203
        Height = 13
        Caption = 'Maximum time to wait for Admin &Lock (sec)'
        FocusControl = rsSecToWait
      end
      object Bevel2: TBevel
        Left = 142
        Top = 9
        Width = 425
        Height = 9
        Shape = bsTopLine
      end
      object Bevel3: TBevel
        Left = 102
        Top = 140
        Width = 465
        Height = 8
        Shape = bsTopLine
      end
      object btnBackupDir: TSpeedButton
        Left = 523
        Top = 70
        Width = 25
        Height = 24
        Hint = 'Browse for directory'
        ParentShowHint = False
        ShowHint = True
        OnClick = btnBackupDirClick
      end
      object lblBackupDefault: TLabel
        Left = 213
        Top = 98
        Width = 289
        Height = 37
        AutoSize = False
        Caption = '(default is'
      end
      object Label12: TLabel
        Left = 28
        Top = 211
        Width = 105
        Height = 13
        Caption = 'Login &Bitmap Filename'
        FocusControl = edtLoginBitmap
      end
      object lh5: TLabel
        Left = 16
        Top = 186
        Width = 119
        Height = 13
        Caption = 'Advanced Login Options '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Bevel6: TBevel
        Left = 142
        Top = 193
        Width = 425
        Height = 8
        Shape = bsTopLine
      end
      object btnBrowseLOBitmap: TSpeedButton
        Left = 507
        Top = 233
        Width = 24
        Height = 24
        Hint = 'Browse for image'
        ParentShowHint = False
        ShowHint = True
        Transparent = False
        OnClick = btnBrowseLOBitmapClick
      end
      object rsMinLogSize: TRzSpinEdit
        Left = 213
        Top = 37
        Width = 57
        Height = 21
        AllowKeyEdit = True
        Max = 9900.000000000000000000
        Min = 100.000000000000000000
        Value = 100.000000000000000000
        Alignment = taLeftJustify
        TabOrder = 0
      end
      object rsMaxLogSize: TRzSpinEdit
        Left = 460
        Top = 37
        Width = 57
        Height = 21
        AllowKeyEdit = True
        Max = 10000.000000000000000000
        Min = 200.000000000000000000
        Value = 200.000000000000000000
        Alignment = taLeftJustify
        TabOrder = 1
      end
      object rsSecToWait: TRzSpinEdit
        Left = 284
        Top = 154
        Width = 65
        Height = 21
        AllowKeyEdit = True
        Max = 600.000000000000000000
        Min = 5.000000000000000000
        Value = 5.000000000000000000
        Alignment = taLeftJustify
        TabOrder = 3
      end
      object edtLogBackupsDir: TEdit
        Left = 213
        Top = 70
        Width = 304
        Height = 21
        TabOrder = 2
        Text = 'edtLogBackupsDir'
      end
      object btnRestoreDefaults: TButton
        Left = 3
        Top = 373
        Width = 137
        Height = 25
        Caption = '&Restore Defaults'
        TabOrder = 5
        OnClick = btnRestoreDefaultsClick
      end
      object edtLoginBitmap: TEdit
        Left = 28
        Top = 233
        Width = 473
        Height = 21
        TabOrder = 4
      end
      object Button1: TButton
        Left = 146
        Top = 373
        Width = 137
        Height = 25
        Caption = 'Check Oplocks'
        TabOrder = 6
        OnClick = Button1Click
      end
    end
    object tsInterfaces: TTabSheet
      Caption = 'Interfaces'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object PInterfaceOptions: TPanel
        Left = 0
        Top = 0
        Width = 610
        Height = 30
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lh6: TLabel
          Left = 16
          Top = 3
          Width = 85
          Height = 13
          Caption = 'Interface Options'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object Bevel5: TBevel
          Left = 120
          Top = 8
          Width = 473
          Height = 8
          Shape = bsTopLine
        end
      end
      object PQty: TPanel
        Left = 0
        Top = 30
        Width = 610
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object lblDP1: TLabel
          Left = 335
          Top = 10
          Width = 35
          Height = 13
          Caption = 'Extract'
        end
        object lbldp2: TLabel
          Left = 437
          Top = 10
          Width = 68
          Height = 13
          Caption = '&decimal places'
        end
        object chkExtractQty: TCheckBox
          Left = 24
          Top = 10
          Width = 249
          Height = 17
          Caption = '&Include quantities when extracting data'
          TabOrder = 0
          OnClick = chkExtractQtyClick
        end
        object rsDP: TRzSpinEdit
          Left = 385
          Top = 6
          Width = 46
          Height = 21
          AllowKeyEdit = True
          Max = 4.000000000000000000
          Value = 4.000000000000000000
          Alignment = taLeftJustify
          TabOrder = 1
        end
      end
      object PSol6: TPanel
        Left = 0
        Top = 62
        Width = 610
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object chkXlonSorting: TCheckBox
          Left = 24
          Top = 10
          Width = 561
          Height = 17
          Caption = 
            '&Use advanced chart code sorting for Solution 6 Classic (Xlon) c' +
            'lients'
          TabOrder = 0
        end
      end
      object PPA: TPanel
        Left = 0
        Top = 94
        Width = 610
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 3
        object chkMultiPA: TCheckBox
          Left = 24
          Top = 10
          Width = 529
          Height = 17
          Caption = '&Allow multiple accounts to be exported for PA clients'
          TabOrder = 0
        end
      end
      object PPA2: TPanel
        Left = 0
        Top = 126
        Width = 610
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 4
        object chkPAJournals: TCheckBox
          Left = 24
          Top = 10
          Width = 553
          Height = 17
          Caption = '&Extract Journal accounts using Journal tag for PA clients'
          TabOrder = 0
        end
      end
      object PmaxChar: TPanel
        Left = 0
        Top = 158
        Width = 610
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 5
        object Label20: TLabel
          Left = 24
          Top = 10
          Width = 274
          Height = 13
          Caption = '&Maximum number of characters to extract from Narration'
        end
        object rsMaxNarration: TRzSpinEdit
          Left = 385
          Top = 6
          Width = 57
          Height = 21
          AllowKeyEdit = True
          Max = 200.000000000000000000
          Value = 200.000000000000000000
          Alignment = taLeftJustify
          TabOrder = 0
        end
      end
      object PZero: TPanel
        Left = 0
        Top = 190
        Width = 610
        Height = 32
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 6
        object chkZeroAmounts: TCheckBox
          Left = 24
          Top = 10
          Width = 529
          Height = 17
          Caption = 
            'Include zero amount, narration only, entries when extracting dat' +
            'a'
          TabOrder = 0
        end
      end
      object pnlMYOBConnect: TPanel
        Left = 0
        Top = 222
        Width = 610
        Height = 77
        Align = alTop
        BevelOuter = bvNone
        Caption = ' '
        TabOrder = 7
        object lblFirmName: TLabel
          Left = 24
          Top = 44
          Width = 569
          Height = 23
          AutoSize = False
          Caption = ' '
        end
        object btnConnectMYOB: TButton
          Left = 24
          Top = 6
          Width = 165
          Height = 27
          Caption = 'MYOB login'
          TabOrder = 0
          OnClick = btnConnectMYOBClick
        end
      end
    end
    object tsSmartLink: TTabSheet
      Caption = 'SmartLink'
      ImageIndex = 6
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lh7: TLabel
        Left = 16
        Top = 3
        Width = 91
        Height = 13
        Caption = 'FingerTips Settings'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Bevel10: TBevel
        Left = 113
        Top = 9
        Width = 457
        Height = 8
        Shape = bsTopLine
      end
      object Label24: TLabel
        Left = 16
        Top = 53
        Width = 54
        Height = 13
        Caption = 'Server URL'
      end
      object lblSQLIP: TLabel
        Left = 16
        Top = 88
        Width = 53
        Height = 13
        Caption = 'SQL server'
      end
      object Label25: TLabel
        Left = 16
        Top = 120
        Width = 70
        Height = 13
        Caption = 'Timeout (secs)'
      end
      object edtFingertipsURL: TEdit
        Left = 120
        Top = 48
        Width = 457
        Height = 21
        TabOrder = 0
      end
      object edtSQL_IP: TEdit
        Left = 120
        Top = 81
        Width = 457
        Height = 21
        TabOrder = 1
      end
      object rsFingertipsTimeout: TRzSpinEdit
        Left = 119
        Top = 117
        Width = 53
        Height = 21
        AllowKeyEdit = True
        Increment = 10.000000000000000000
        Max = 600.000000000000000000
        TabOrder = 2
        OnChange = rsAutoSaveTimeChange
      end
    end
    object tsUpdates: TTabSheet
      Caption = 'Updates'
      ImageIndex = 7
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lh8: TLabel
        Left = 16
        Top = 3
        Width = 92
        Height = 13
        Caption = 'Check for Updates '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Bevel12: TBevel
        Left = 114
        Top = 9
        Width = 457
        Height = 9
        Shape = bsTopLine
      end
      object btnCheckForUpdates: TButton
        Left = 24
        Top = 32
        Width = 145
        Height = 25
        Caption = 'Check for Updates'
        TabOrder = 0
        OnClick = btnCheckForUpdatesClick
      end
      object btnInstallUpdates: TButton
        Left = 184
        Top = 32
        Width = 145
        Height = 25
        Caption = 'Install Updates'
        TabOrder = 1
        OnClick = btnInstallUpdatesClick
      end
    end
    object tsLinks: TTabSheet
      Caption = 'Links'
      ImageIndex = 8
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object pInstitute: TPanel
        Left = 0
        Top = 30
        Width = 610
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object LBLInstitutionList: TLabel
          Left = 15
          Top = 16
          Width = 68
          Height = 13
          Caption = 'Institution List'
        end
        object edtInstListLink: TEdit
          Left = 136
          Top = 12
          Width = 441
          Height = 21
          TabOrder = 0
        end
      end
      object pTop: TPanel
        Left = 0
        Top = 0
        Width = 610
        Height = 30
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Bevel11: TBevel
          Left = 96
          Top = 10
          Width = 497
          Height = 9
          Shape = bsTopLine
        end
        object lh9: TLabel
          Left = 16
          Top = 3
          Width = 54
          Height = 13
          Caption = 'Web pages'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
      object PGst: TPanel
        Left = 0
        Top = 71
        Width = 610
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object LBLGSTReturn: TLabel
          Left = 16
          Top = 16
          Width = 55
          Height = 13
          Caption = 'G&ST Return'
        end
        object edtGST101Link: TEdit
          Left = 136
          Top = 12
          Width = 441
          Height = 21
          TabOrder = 0
        end
      end
      object POnline: TPanel
        Left = 0
        Top = 112
        Width = 610
        Height = 41
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 3
        object lOnline: TLabel
          Left = 15
          Top = 16
          Width = 71
          Height = 13
          Caption = 'Banklink Online'
        end
        object eOnlineLink: TEdit
          Left = 136
          Top = 12
          Width = 441
          Height = 21
          TabOrder = 0
        end
      end
    end
    object tsBGL360: TTabSheet
      Caption = 'BGL 360 Credentials'
      ImageIndex = 7
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lblLoginClientID: TLabel
        Left = 16
        Top = 28
        Width = 85
        Height = 13
        Caption = 'BankLink Client ID'
        FocusControl = edtBGLClientID
      end
      object lblLoginSecret: TLabel
        Left = 16
        Top = 60
        Width = 75
        Height = 13
        Caption = 'BankLink Secret'
        FocusControl = edtBGLSecret
      end
      object edtBGLClientID: TEdit
        Left = 129
        Top = 25
        Width = 383
        Height = 21
        TabOrder = 0
        Text = 'bankLinkTest'
      end
      object edtBGLSecret: TEdit
        Left = 129
        Top = 57
        Width = 383
        Height = 21
        TabOrder = 1
        Text = 'bankLinkSecret'
      end
      object btnForceAuthorisationRefresh: TButton
        Left = 16
        Top = 88
        Width = 225
        Height = 25
        Caption = 'Force refresh of Authorisation'
        TabOrder = 2
        OnClick = btnForceAuthorisationRefreshClick
      end
    end
  end
  object OpenPictureDlg: TOpenPictureDialog
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 228
    Top = 368
  end
end
