inherited dlgPrintScheduled: TdlgPrintScheduled
  Left = 340
  Top = 277
  Caption = 'Generate Scheduled Reports'
  ClientHeight = 598
  ClientWidth = 646
  Color = clWindow
  OldCreateOrder = True
  OnDestroy = FormDestroy
  ExplicitWidth = 652
  ExplicitHeight = 626
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlBottomControls: TPanel
    Top = 557
    Width = 646
    ParentBackground = False
    TabOrder = 1
    ExplicitTop = 557
    ExplicitWidth = 646
    inherited ShapeBotBorder: TShape
      Width = 646
      Visible = False
      ExplicitWidth = 646
    end
    inherited btnCancel: TButton
      Left = 561
      Top = 7
      Hint = 'Cancel changes'
      ModalResult = 0
      TabOrder = 3
      OnClick = btnCancelClick
      ExplicitLeft = 561
      ExplicitTop = 7
    end
    inherited btnOK: TButton
      Left = 478
      Hint = 'Save the scheduled report settings'
      Anchors = [akLeft, akBottom]
      Caption = 'OK'
      Default = False
      ModalResult = 0
      TabOrder = 2
      OnClick = btnOKClick
      ExplicitLeft = 478
    end
    object btnPrint: TButton
      Left = 90
      Top = 8
      Width = 75
      Height = 25
      Hint = 'Generate the Scheduled Reports'
      Anchors = [akLeft, akBottom]
      Caption = '&Generate'
      TabOrder = 1
      OnClick = btnPrintClick
    end
    object btnPreview: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Hint = 'Preview the Scheduled Reports'
      Anchors = [akLeft, akBottom]
      Caption = 'Pre&view'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 646
    Height = 557
    ActivePage = tbsOptions
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    object tbsOptions: TTabSheet
      Caption = '&Scheduled Reporting Options'
      object grpSettings: TGroupBox
        Left = 0
        Top = 68
        Width = 632
        Height = 134
        Caption = ' Select Clients'
        TabOrder = 1
        object lblFrom: TLabel
          Left = 149
          Top = 76
          Width = 82
          Height = 13
          Caption = '&From Client Code'
          FocusControl = edtFromCode
        end
        object lblTo: TLabel
          Left = 397
          Top = 76
          Width = 70
          Height = 13
          Caption = 'T&o Client Code'
          FocusControl = edtToCode
        end
        object Label5: TLabel
          Left = 16
          Top = 24
          Width = 76
          Height = 13
          Caption = 'Sort Reports by'
        end
        object btnFromLookup: TSpeedButton
          Left = 358
          Top = 72
          Width = 23
          Height = 25
          Hint = 'Lookup '#39'from'#39' range'
          OnClick = btnFromLookupClick
        end
        object btnToLookup: TSpeedButton
          Left = 592
          Top = 72
          Width = 23
          Height = 25
          Hint = 'Lookup '#39'to'#39' range'
          OnClick = btnToLookupClick
        end
        object lblSelection: TLabel
          Left = 148
          Top = 106
          Width = 114
          Height = 13
          Caption = 'Selected Staff Members'
        end
        object btnSelect: TSpeedButton
          Left = 591
          Top = 102
          Width = 23
          Height = 25
          Hint = 'Select codes'
          OnClick = btnSelectClick
        end
        object rbStaffMember: TRadioButton
          Left = 220
          Top = 25
          Width = 137
          Height = 17
          Caption = 'S&taff Member'
          TabOrder = 1
          OnClick = rbStaffMemberClick
        end
        object rbClient: TRadioButton
          Left = 139
          Top = 24
          Width = 62
          Height = 17
          Caption = 'Cl&ient'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbStaffMemberClick
        end
        object edtFromCode: TEdit
          Left = 268
          Top = 72
          Width = 89
          Height = 24
          BorderStyle = bsNone
          CharCase = ecUpperCase
          MaxLength = 8
          TabOrder = 5
        end
        object edtToCode: TEdit
          Left = 502
          Top = 72
          Width = 89
          Height = 24
          BorderStyle = bsNone
          CharCase = ecUpperCase
          MaxLength = 8
          TabOrder = 6
        end
        object edtSelection: TEdit
          Left = 297
          Top = 102
          Width = 293
          Height = 24
          BorderStyle = bsNone
          CharCase = ecUpperCase
          TabOrder = 7
          OnExit = edtSelectionExit
        end
        object rbGroup: TRadioButton
          Left = 343
          Top = 25
          Width = 69
          Height = 17
          Caption = '&Group'
          TabOrder = 2
          OnClick = rbStaffMemberClick
        end
        object rbClientType: TRadioButton
          Left = 425
          Top = 25
          Width = 98
          Height = 17
          Caption = 'Client T&ype'
          TabOrder = 3
          OnClick = rbStaffMemberClick
        end
        object Panel1: TPanel
          Left = 4
          Top = 42
          Width = 145
          Height = 82
          BevelOuter = bvNone
          TabOrder = 4
          object rbRange: TRadioButton
            Left = 17
            Top = 26
            Width = 113
            Height = 31
            Caption = 'Use Range'
            Color = clBtnFace
            ParentColor = False
            TabOrder = 0
            OnClick = rbRangeClick
          end
          object rbSelection: TRadioButton
            Left = 18
            Top = 64
            Width = 113
            Height = 17
            Caption = 'Use Selection'
            Color = clBtnFace
            ParentColor = False
            TabOrder = 1
            OnClick = rbRangeClick
          end
          object rbSelectAll: TRadioButton
            Left = 18
            Top = -2
            Width = 125
            Height = 29
            Caption = 'All Staff Members'
            Checked = True
            Color = clBtnFace
            ParentColor = False
            TabOrder = 2
            TabStop = True
            OnClick = rbRangeClick
          end
        end
      end
      object grpRange: TGroupBox
        Left = 0
        Top = 6
        Width = 632
        Height = 61
        Caption = 'Select Month'
        TabOrder = 0
        object Label3: TLabel
          Left = 16
          Top = 27
          Width = 121
          Height = 13
          Caption = 'Generate Reports &Ending'
          FocusControl = rcbReportsEnding
        end
        object rcbReportsEnding: TRzComboBox
          Left = 176
          Top = 23
          Width = 145
          Height = 21
          Hint = 'Select the scheduled reports end date'
          Style = csDropDownList
          Ctl3D = False
          FrameHotTrack = True
          FrameHotStyle = fsNone
          FrameStyle = fsNone
          FrameVisible = True
          ItemHeight = 13
          ParentCtl3D = False
          TabOrder = 0
        end
      end
      object gbInclude: TGroupBox
        Left = 0
        Top = 204
        Width = 632
        Height = 125
        Caption = ' Select Destination(s)'
        TabOrder = 2
        object cbToPrinter: TCheckBox
          Left = 16
          Top = 23
          Width = 167
          Height = 17
          Hint = 'Include reports to be sent to the printer'
          Caption = '&Printed Reports'
          TabOrder = 0
        end
        object cbToFax: TCheckBox
          Left = 16
          Top = 47
          Width = 155
          Height = 17
          Hint = 'Include reports to be sent to the fax'
          Caption = 'F&axed Reports'
          TabOrder = 1
        end
        object cbToEMail: TCheckBox
          Left = 16
          Top = 71
          Width = 183
          Height = 17
          Hint = 'Include reports to be sent via email'
          Caption = 'Emaile&d Reports'
          TabOrder = 2
        end
        object cbToECoding: TCheckBox
          Left = 16
          Top = 95
          Width = 223
          Height = 17
          Hint = 'Include reports to be sent via a BankLink Notes file'
          Caption = '&BankLink Notes files'
          TabOrder = 3
        end
        object cbToWebX: TCheckBox
          Left = 300
          Top = 23
          Width = 223
          Height = 17
          Hint = 'Include reports to be sent to the Web'
          Caption = '&Web files'
          TabOrder = 5
        end
        object cbCheckOut: TCheckBox
          Left = 300
          Top = 47
          Width = 169
          Height = 17
          Hint = 'Include reports to be sent via a checked out file'
          Caption = 'BankLink Boo&ks files'
          TabOrder = 6
        end
        object cbToBusinessProducts: TCheckBox
          Left = 300
          Top = 95
          Width = 259
          Height = 17
          Hint = 'Include reports to be sent to Business Products'
          Caption = 'Business Product Files (&QIF and OFX)'
          TabOrder = 4
          Visible = False
        end
        object cbOnline: TCheckBox
          Left = 300
          Top = 70
          Width = 314
          Height = 17
          Hint = 'Include reports to be sent via a checked out file'
          Caption = 'BankLink Books Files via &online'
          TabOrder = 7
        end
      end
      object gbTrans: TGroupBox
        Left = 0
        Top = 332
        Width = 632
        Height = 49
        Caption = 'Select Transactions'
        TabOrder = 3
        object rbNew: TRadioButton
          Left = 16
          Top = 23
          Width = 161
          Height = 17
          Caption = '&New transactions only'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbAll: TRadioButton
          Left = 300
          Top = 23
          Width = 113
          Height = 17
          Caption = 'A&ll transactions'
          TabOrder = 1
        end
      end
      object btnListReportsDue: TButton
        Left = 472
        Top = 385
        Width = 160
        Height = 25
        Hint = 'Show all reports that are due'
        Caption = 'List Reports D&ue'
        TabOrder = 4
        OnClick = btnListReportsDueClick
      end
    end
    object tsMessages: TTabSheet
      Caption = '&Message Setup'
      ImageIndex = 3
      object gbOptions: TGroupBox
        Left = 0
        Top = 6
        Width = 632
        Height = 170
        Caption = 'Printed Reports'
        TabOrder = 0
        object chkClientHeader: TCheckBox
          Left = 17
          Top = 24
          Width = 216
          Height = 17
          Caption = 'Print header page for each &client'
          TabOrder = 0
          OnClick = chkClientHeaderClick
        end
        object chkStaffHeader: TCheckBox
          Left = 17
          Top = 52
          Width = 272
          Height = 17
          Caption = 'Print header page for each s&taff member'
          TabOrder = 1
        end
        object btnHeaderMsg: TButton
          Left = 421
          Top = 20
          Width = 206
          Height = 25
          Hint = 'Enter a message to be added to the header of each printed report'
          Caption = 'Client &Header Message'
          TabOrder = 4
          OnClick = btnHeaderMsgClick
        end
        object chkGroupHeader: TCheckBox
          Left = 17
          Top = 80
          Width = 272
          Height = 17
          Caption = 'Print header page for each grou&p'
          TabOrder = 2
        end
        object chkClientTypeHeader: TCheckBox
          Left = 17
          Top = 108
          Width = 272
          Height = 17
          Caption = 'Print header page for each client t&ype'
          TabOrder = 3
        end
        object ckCDPrint: TCheckBox
          Left = 17
          Top = 136
          Width = 169
          Height = 17
          Caption = 'Print C&ustom Document'
          TabOrder = 5
          OnClick = ckCDClick
        end
        object cbCDPrint: TComboBox
          Left = 190
          Top = 133
          Width = 217
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemHeight = 13
          TabOrder = 6
        end
      end
      object gbFaxed: TGroupBox
        Left = 0
        Top = 178
        Width = 632
        Height = 56
        Caption = 'Faxed Reports'
        TabOrder = 1
        object btnCoverPageMsg: TButton
          Left = 410
          Top = 20
          Width = 217
          Height = 25
          Hint = 
            'Enter a message to be added to the coverpage of each faxed repor' +
            't'
          Caption = 'Cover &Page Message'
          TabOrder = 2
          OnClick = btnCoverPageMsgClick
        end
        object ckCDFax: TCheckBox
          Left = 15
          Top = 24
          Width = 170
          Height = 17
          Caption = '&Fax Custom Document'
          TabOrder = 0
          OnClick = ckCDClick
        end
        object cbCDFax: TComboBox
          Left = 190
          Top = 20
          Width = 217
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemHeight = 13
          TabOrder = 1
        end
      end
      object gbEmail: TGroupBox
        Left = 0
        Top = 235
        Width = 632
        Height = 56
        Caption = 'Emailed Reports'
        TabOrder = 2
        object btnEmailMsg: TButton
          Left = 410
          Top = 20
          Width = 217
          Height = 25
          Caption = 'Ema&il Message '
          TabOrder = 2
          OnClick = btnEmailMsgClick
        end
        object cbCDEmail: TComboBox
          Left = 190
          Top = 20
          Width = 217
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemHeight = 13
          TabOrder = 1
        end
        object ckCDEmail: TCheckBox
          Left = 17
          Top = 24
          Width = 170
          Height = 17
          Caption = '&Attach Custom Document'
          TabOrder = 0
          OnClick = ckCDClick
        end
      end
      object gbNotes: TGroupBox
        Left = 0
        Top = 292
        Width = 632
        Height = 56
        Caption = 'Send BankLink Notes files'
        TabOrder = 3
        object btnBNotesMsg: TButton
          Left = 410
          Top = 20
          Width = 217
          Height = 25
          Caption = '&BankLink Notes Message '
          TabOrder = 2
          OnClick = btnBNotesMsgClick
        end
        object ckCDNotes: TCheckBox
          Left = 14
          Top = 24
          Width = 170
          Height = 17
          Caption = 'Attach C&ustom Document'
          TabOrder = 0
          OnClick = ckCDClick
        end
        object cbCDNotes: TComboBox
          Left = 190
          Top = 20
          Width = 217
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemHeight = 13
          TabOrder = 1
        end
      end
      object gbBooks: TGroupBox
        Left = 0
        Top = 409
        Width = 632
        Height = 56
        Caption = 'Send Banklink Books files'
        TabOrder = 5
        object btnCheckOutMsg: TButton
          Left = 410
          Top = 20
          Width = 217
          Height = 25
          Caption = 'BankLink Boo&ks Message'
          TabOrder = 2
          OnClick = btnCheckOutMsgClick
        end
        object cbCDBooks: TComboBox
          Left = 190
          Top = 20
          Width = 217
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemHeight = 13
          TabOrder = 1
        end
        object ckCDBooks: TCheckBox
          Left = 17
          Top = 24
          Width = 170
          Height = 17
          Caption = 'Attach Cust&om Document'
          TabOrder = 0
          OnClick = ckCDClick
        end
      end
      object gbwebNotes: TGroupBox
        Left = 0
        Top = 350
        Width = 632
        Height = 56
        Caption = 'Send BankLink webNotes files'
        TabOrder = 4
        object btnWebNotesMsg: TButton
          Left = 410
          Top = 20
          Width = 217
          Height = 25
          Caption = '&BankLink WebNotes Message '
          TabOrder = 2
          OnClick = btnWebNotesMsgClick
        end
        object ckCDwebNotes: TCheckBox
          Left = 14
          Top = 24
          Width = 170
          Height = 17
          Caption = 'Attach C&ustom Document'
          TabOrder = 0
          OnClick = ckCDClick
        end
        object cbCDwebNotes: TComboBox
          Left = 190
          Top = 20
          Width = 217
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemHeight = 13
          TabOrder = 1
        end
      end
      object gbSend: TGroupBox
        Left = 1
        Top = 468
        Width = 631
        Height = 56
        Caption = 'Send Banklink Books files via BankLink Online'
        TabOrder = 6
        object btnOnlineMsg: TButton
          Left = 413
          Top = 20
          Width = 213
          Height = 25
          Caption = 'BankLink Boo&ks Message'
          TabOrder = 2
          OnClick = btnOnlineMsgClick
        end
        object cbCDOnline: TComboBox
          Left = 190
          Top = 20
          Width = 217
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemHeight = 13
          TabOrder = 1
        end
        object ckCDOnline: TCheckBox
          Left = 17
          Top = 24
          Width = 170
          Height = 17
          Caption = 'Attach Cust&om Document'
          TabOrder = 0
          OnClick = ckCDClick
        end
      end
    end
    object tbsReportSetup: TTabSheet
      Caption = '&Report Setup'
      ImageIndex = 1
      object GroupBox2: TGroupBox
        Left = 0
        Top = 6
        Width = 632
        Height = 251
        Caption = ' Set up the report settings for each Scheduled Report '
        TabOrder = 0
        object btnCoding: TButton
          Left = 17
          Top = 24
          Width = 145
          Height = 25
          Caption = 'Co&ding'
          TabOrder = 0
          OnClick = btnCodingClick
        end
        object btnPayee: TButton
          Left = 17
          Top = 54
          Width = 145
          Height = 25
          Caption = '&List Payees'
          TabOrder = 1
          OnClick = btnPayeeClick
        end
        object btnChart: TButton
          Left = 17
          Top = 116
          Width = 145
          Height = 25
          Caption = 'List Chart of &Accounts'
          TabOrder = 3
          OnClick = btnChartClick
        end
        object btnSort: TButton
          Left = 17
          Top = 178
          Width = 145
          Height = 25
          Caption = 'Sort Header'
          TabOrder = 5
          OnClick = btnSortClick
        end
        object btnClient: TButton
          Left = 17
          Top = 147
          Width = 145
          Height = 25
          Caption = '&Client Header'
          TabOrder = 4
          OnClick = btnClientClick
        end
        object btnSummary: TButton
          Left = 17
          Top = 209
          Width = 145
          Height = 25
          Caption = 'S&ummary'
          TabOrder = 6
          OnClick = btnSummaryClick
        end
        object btnJobs: TButton
          Left = 17
          Top = 85
          Width = 145
          Height = 25
          Caption = 'List &Jobs'
          TabOrder = 2
          OnClick = btnJobsClick
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Fa&x Setup'
      ImageIndex = 2
      object gbSetup: TGroupBox
        Left = 0
        Top = 253
        Width = 632
        Height = 91
        Caption = ' Set up the report settings for each Scheduled Report '
        TabOrder = 2
        object btnFaxCoding: TButton
          Left = 16
          Top = 23
          Width = 145
          Height = 25
          Hint = 'Edit the Reports Settings for the Coding Report'
          Caption = 'Co&ding'
          TabOrder = 0
          OnClick = btnFaxCodingClick
        end
        object btnFaxPayees: TButton
          Left = 165
          Top = 23
          Width = 145
          Height = 25
          Hint = 'Edit the Reports Settings for the List Payees Report'
          Caption = '&List Payees'
          TabOrder = 1
          OnClick = btnFaxPayeesClick
        end
        object btnFaxChart: TButton
          Left = 464
          Top = 23
          Width = 145
          Height = 25
          Hint = 'Edit the Reports Settings for the List Chart of Accounts Report'
          Caption = 'List Chart of &Accounts'
          TabOrder = 3
          OnClick = btnFaxChartClick
        end
        object Button1: TButton
          Left = 16
          Top = 54
          Width = 145
          Height = 25
          Caption = 'Test Report'
          TabOrder = 4
          Visible = False
          OnClick = Button1Click
        end
        object btnFaxJobs: TButton
          Left = 314
          Top = 23
          Width = 145
          Height = 25
          Hint = 'Edit the Reports Settings for the List Payees Report'
          Caption = 'List &Jobs'
          TabOrder = 2
          OnClick = btnFaxJobsClick
        end
      end
      object gbFaxOptions: TGroupBox
        Left = 0
        Top = 133
        Width = 632
        Height = 114
        Caption = ' Fax Options'
        TabOrder = 1
        object Label6: TLabel
          Left = 16
          Top = 25
          Width = 56
          Height = 13
          Caption = '&Cover Page'
          FocusControl = edtCoverPageFilename
        end
        object btnOpenDialog: TSpeedButton
          Left = 584
          Top = 17
          Width = 25
          Height = 24
          Hint = 'Click to Select a File'
          OnClick = btnOpenDialogClick
        end
        object edtCoverPageFilename: TEdit
          Left = 168
          Top = 17
          Width = 410
          Height = 24
          Hint = 'Select a fax coverpage'
          BorderStyle = bsNone
          TabOrder = 0
          Text = 'coverpage.cvp'
        end
        object pnlOffpeak: TPanel
          Left = 5
          Top = 56
          Width = 561
          Height = 67
          BevelOuter = bvNone
          TabOrder = 1
          object Label2: TLabel
            Left = 11
            Top = 9
            Width = 102
            Height = 13
            Caption = 'When sending faxes:'
          end
          object rbSendImmediate: TRadioButton
            Left = 163
            Top = 8
            Width = 147
            Height = 17
            Hint = 'Send fax immediately'
            Caption = 'Send &Immediately'
            Checked = True
            Color = clBtnFace
            ParentColor = False
            TabOrder = 0
            TabStop = True
          end
          object rbsendOffPeak: TRadioButton
            Left = 163
            Top = 31
            Width = 147
            Height = 17
            Hint = 'Send fax later (off-peak)'
            Caption = 'Send O&ff-Peak'
            Color = clBtnFace
            ParentColor = False
            TabOrder = 1
          end
        end
      end
      object gbFaxService: TGroupBox
        Left = 0
        Top = 6
        Width = 632
        Height = 121
        Caption = ' Fax Service'
        TabOrder = 0
        object Label1: TLabel
          Left = 16
          Top = 25
          Width = 68
          Height = 13
          Caption = 'Fax &Transport'
          FocusControl = cmbFaxTransport
        end
        object Label4: TLabel
          Left = 16
          Top = 61
          Width = 53
          Height = 13
          Caption = 'Fax &Printer'
          FocusControl = cmbPrinter
          Transparent = True
        end
        object btnTestFax: TButton
          Left = 534
          Top = 84
          Width = 75
          Height = 25
          Hint = 'Send a test fax'
          Caption = 'T&est'
          TabOrder = 2
          OnClick = btnTestFaxClick
        end
        object cmbFaxTransport: TComboBox
          Left = 168
          Top = 25
          Width = 441
          Height = 21
          Hint = 'Select the Fax Transport'
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = cmbFaxTransportChange
          Items.Strings = (
            '(none)'
            'Windows Fax Service (requires Windows 2000 or later)'
            'WinFax Pro')
        end
        object cmbPrinter: TComboBox
          Left = 168
          Top = 57
          Width = 441
          Height = 21
          Hint = 'Select the fax printer'
          Style = csDropDownList
          Ctl3D = True
          ItemHeight = 13
          ParentCtl3D = False
          Sorted = True
          TabOrder = 1
        end
      end
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
    Left = 392
    Top = 61
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'cvp'
    Options = [ofHideReadOnly, ofNoChangeDir, ofFileMustExist, ofEnableSizing]
    Title = 'Select Cover Page'
    Left = 385
    Top = 225
  end
end
