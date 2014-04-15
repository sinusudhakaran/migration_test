object frmClientDetails: TfrmClientDetails
  Left = 368
  Top = 312
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Client Details'
  ClientHeight = 618
  ClientWidth = 604
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    604
    618)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 441
    Top = 585
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 521
    Top = 585
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object PageControl1: TPageControl
    Left = 8
    Top = 8
    Width = 589
    Height = 571
    ActivePage = tsTPRPayerDetails
    TabOrder = 0
    object tbsClient: TTabSheet
      Caption = 'Client Details'
      DesignSize = (
        581
        543)
      object Label1: TLabel
        Left = 16
        Top = 10
        Width = 55
        Height = 13
        Caption = 'C&lient Code'
        FocusControl = eCode
      end
      object Label2: TLabel
        Left = 16
        Top = 38
        Width = 57
        Height = 13
        Caption = 'Client &Name'
        FocusControl = eName
      end
      object Label3: TLabel
        Left = 16
        Top = 67
        Width = 39
        Height = 13
        Caption = 'A&ddress'
        FocusControl = eAddr1
      end
      object Label4: TLabel
        Left = 16
        Top = 185
        Width = 68
        Height = 13
        Caption = 'Con&tact Name'
        FocusControl = eContact
      end
      object Label5: TLabel
        Left = 16
        Top = 215
        Width = 30
        Height = 13
        Caption = '&Phone'
        FocusControl = ePhone
      end
      object Label7: TLabel
        Left = 16
        Top = 305
        Width = 46
        Height = 13
        Caption = 'Pa&ssword'
        FocusControl = ePassword
      end
      object Label8: TLabel
        Left = 16
        Top = 365
        Width = 98
        Height = 13
        Caption = '&Financial Year Starts'
        FocusControl = eFinYear
      end
      object Label9: TLabel
        Left = 16
        Top = 275
        Width = 28
        Height = 13
        Caption = 'E-&mail'
        FocusControl = eMail
      end
      object Label12: TLabel
        Left = 16
        Top = 335
        Width = 86
        Height = 13
        Caption = 'Confirm Pass&word'
        FocusControl = eConfirm
      end
      object Label13: TLabel
        Left = 16
        Top = 245
        Width = 18
        Height = 13
        Caption = 'Fa&x'
        FocusControl = eFax
      end
      object lblCountry: TLabel
        Left = 513
        Top = 4
        Width = 26
        Height = 24
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        Caption = 'NZ'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -19
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Label15: TLabel
        Left = 328
        Top = 233
        Width = 30
        Height = 13
        Caption = 'Mo&bile'
        FocusControl = eMobile
      end
      object Label18: TLabel
        Left = 16
        Top = 155
        Width = 48
        Height = 13
        Caption = 'S&alutation'
        FocusControl = eSal
      end
      object Label20: TLabel
        Left = 291
        Top = 305
        Width = 115
        Height = 13
        Caption = '(Maximum 8 characters)'
      end
      object eCode: TEdit
        Left = 152
        Top = 6
        Width = 121
        Height = 24
        BorderStyle = bsNone
        CharCase = ecUpperCase
        Ctl3D = True
        MaxLength = 8
        ParentCtl3D = False
        TabOrder = 0
        Text = 'ECODE'
      end
      object eName: TEdit
        Left = 152
        Top = 34
        Width = 401
        Height = 24
        BorderStyle = bsNone
        Ctl3D = True
        MaxLength = 60
        ParentCtl3D = False
        TabOrder = 1
        Text = 'eName'
      end
      object eContact: TEdit
        Left = 152
        Top = 181
        Width = 401
        Height = 24
        BorderStyle = bsNone
        Ctl3D = True
        MaxLength = 60
        ParentCtl3D = False
        TabOrder = 6
        Text = 'eContact'
      end
      object ePhone: TEdit
        Left = 152
        Top = 211
        Width = 161
        Height = 24
        BorderStyle = bsNone
        Ctl3D = True
        MaxLength = 60
        ParentCtl3D = False
        TabOrder = 7
        Text = 'ePhone'
      end
      object ePassword: TEdit
        Left = 152
        Top = 301
        Width = 121
        Height = 24
        BorderStyle = bsNone
        CharCase = ecUpperCase
        Ctl3D = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Wingdings'
        Font.Style = []
        MaxLength = 8
        ParentCtl3D = False
        ParentFont = False
        PasswordChar = #376
        TabOrder = 11
        Text = 'EPASSWORD'
      end
      object eFinYear: TOvcPictureField
        Left = 152
        Top = 361
        Width = 121
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
        TabOrder = 13
        OnError = eFinYearError
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object eMail: TEdit
        Left = 152
        Top = 271
        Width = 305
        Height = 24
        BorderStyle = bsNone
        MaxLength = 80
        TabOrder = 10
        Text = 'eMail'
      end
      object eConfirm: TEdit
        Left = 152
        Top = 331
        Width = 121
        Height = 24
        BorderStyle = bsNone
        CharCase = ecUpperCase
        Ctl3D = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Wingdings'
        Font.Style = []
        MaxLength = 8
        ParentCtl3D = False
        ParentFont = False
        PasswordChar = #376
        TabOrder = 12
        Text = 'EPASSWORD'
      end
      object eFax: TEdit
        Left = 152
        Top = 241
        Width = 161
        Height = 24
        BorderStyle = bsNone
        MaxLength = 60
        TabOrder = 8
        Text = 'eFax'
      end
      object eAddr1: TEdit
        Left = 152
        Top = 63
        Width = 401
        Height = 24
        BorderStyle = bsNone
        MaxLength = 60
        TabOrder = 2
        Text = 'eAddr1'
      end
      object eAddr2: TEdit
        Left = 152
        Top = 90
        Width = 401
        Height = 24
        BorderStyle = bsNone
        MaxLength = 60
        TabOrder = 3
        Text = 'eAddr2'
      end
      object eAddr3: TEdit
        Left = 152
        Top = 117
        Width = 401
        Height = 24
        BorderStyle = bsNone
        MaxLength = 60
        TabOrder = 4
        Text = 'eAddr3'
      end
      object eMobile: TEdit
        Left = 392
        Top = 229
        Width = 161
        Height = 24
        BorderStyle = bsNone
        Ctl3D = True
        MaxLength = 60
        ParentCtl3D = False
        TabOrder = 9
        Text = 'eMobile'
      end
      object eSal: TEdit
        Left = 152
        Top = 151
        Width = 161
        Height = 24
        BorderStyle = bsNone
        Ctl3D = True
        MaxLength = 10
        ParentCtl3D = False
        TabOrder = 5
        Text = 'eSal'
      end
    end
    object tbsOptions: TTabSheet
      Caption = 'Options'
      ImageIndex = 3
      object chkNewTrx: TCheckBox
        Left = 16
        Top = 27
        Width = 449
        Height = 17
        Caption = 'C&heck for new transactions when the client file is opened'
        TabOrder = 0
      end
      object grpDownLoadSettings: TGroupBox
        Left = 16
        Top = 369
        Width = 529
        Height = 137
        TabOrder = 3
        Visible = False
        object lblConnectName: TLabel
          Left = 16
          Top = 26
          Width = 68
          Height = 13
          Caption = 'Connec&t Code'
          FocusControl = eConnectCode
        end
        object lblMethod: TLabel
          Left = 16
          Top = 95
          Width = 36
          Height = 13
          Caption = 'M&ethod'
          FocusControl = cmbOSDMethod
        end
        object Label11: TLabel
          Left = 16
          Top = 59
          Width = 122
          Height = 13
          Caption = '&Last Download Processed'
          FocusControl = txtLastDiskID
        end
        object eConnectCode: TEdit
          Left = 240
          Top = 23
          Width = 121
          Height = 22
          BorderStyle = bsNone
          CharCase = ecUpperCase
          MaxLength = 8
          TabOrder = 0
        end
        object cmbOSDMethod: TComboBox
          Left = 240
          Top = 91
          Width = 209
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
        end
        object txtLastDiskID: TEdit
          Left = 240
          Top = 56
          Width = 121
          Height = 22
          BorderStyle = bsNone
          CharCase = ecUpperCase
          Ctl3D = False
          MaxLength = 4
          ParentCtl3D = False
          TabOrder = 2
          Text = '000'
          OnChange = txtLastDiskIDChange
        end
      end
      object chkFillNarration: TCheckBox
        Left = 16
        Top = 50
        Width = 441
        Height = 17
        Caption = 'Set default Na&rration when coding dissections and Journals'
        TabOrder = 1
      end
      object grpBooks: TGroupBox
        Left = 16
        Top = 155
        Width = 529
        Height = 200
        TabOrder = 2
        object chkForceCheckout: TCheckBox
          Left = 16
          Top = 19
          Width = 313
          Height = 17
          Hint = 
            'Check to force this client file to be read-only when sending fro' +
            'm the offsite installation'
          Caption = '&Force client to be read-only on Send'
          TabOrder = 0
          OnClick = chkForceCheckoutClick
        end
        object chkDisableCheckout: TCheckBox
          Left = 16
          Top = 43
          Width = 300
          Height = 17
          Hint = 
            'Check to not flag as read-only in the offsite installation on se' +
            'nd'
          Caption = '&Do not flag as read-only on Send'
          TabOrder = 1
          OnClick = chkDisableCheckoutClick
        end
        object chkOffsite: TCheckBox
          Left = 16
          Top = 163
          Width = 433
          Height = 17
          Caption = 'Off-&site Client'
          TabOrder = 6
          OnClick = chkOffsiteClick
        end
        object chkGenerateFinancial: TCheckBox
          Left = 16
          Top = 67
          Width = 329
          Height = 17
          Caption = '&Allow client to generate financial reports'
          TabOrder = 2
        end
        object chkUnlockEntries: TCheckBox
          Left = 16
          Top = 91
          Width = 329
          Height = 17
          Caption = 'Allow client to &unlock entries and clear transfer flags'
          TabOrder = 3
        end
        object chkEditChart: TCheckBox
          Left = 16
          Top = 115
          Width = 329
          Height = 17
          Caption = 'Allow client to edit &chart of accounts'
          TabOrder = 4
        end
        object chkEditMems: TCheckBox
          Left = 16
          Top = 139
          Width = 300
          Height = 17
          Caption = 'Allow client to edit &memorisations'
          TabOrder = 5
        end
      end
      object grpBOClients: TGroupBox
        Left = 16
        Top = 73
        Width = 529
        Height = 67
        Caption = 'BankLink Online Clients'
        TabOrder = 4
        object btnClientSettings: TButton
          Left = 20
          Top = 24
          Width = 93
          Height = 27
          Caption = 'Client Settings'
          TabOrder = 0
          OnClick = btnClientSettingsClick
        end
        object Panel1: TPanel
          Left = 125
          Top = 8
          Width = 401
          Height = 56
          BevelOuter = bvNone
          TabOrder = 1
          object lblClientBOProducts: TLabel
            Left = 6
            Top = 19
            Width = 401
            Height = 20
            AutoSize = False
            Caption = 
              'This client currently has access to {#} BankLink Online product(' +
              's)'
            Layout = tlCenter
            WordWrap = True
          end
        end
      end
    end
    object tbsAdmin: TTabSheet
      Caption = 'Administration'
      ImageIndex = 1
      object Label14: TLabel
        Left = 92
        Top = 208
        Width = 3
        Height = 13
      end
      object Label6: TLabel
        Left = 16
        Top = 22
        Width = 68
        Height = 13
        Caption = '&Assigned User'
        FocusControl = cmbResponsible
      end
      object Label17: TLabel
        Left = 16
        Top = 57
        Width = 217
        Height = 13
        Caption = 'Practice Contact Details as seen by this client'
        FocusControl = cmbResponsible
      end
      object Label10: TLabel
        Left = 16
        Top = 300
        Width = 141
        Height = 13
        Caption = 'Web site details for this client'
      end
      object Label21: TLabel
        Left = 16
        Top = 233
        Width = 75
        Height = 13
        Caption = 'Assigned &Group'
        FocusControl = cmbGroup
      end
      object Label22: TLabel
        Left = 16
        Top = 263
        Width = 54
        Height = 13
        Caption = 'Client &Type'
        FocusControl = cmbType
      end
      object cmbResponsible: TComboBox
        Left = 168
        Top = 19
        Width = 393
        Height = 21
        Style = csDropDownList
        Ctl3D = True
        ItemHeight = 13
        ParentCtl3D = False
        TabOrder = 0
        OnChange = cmbResponsibleChange
      end
      object pnlContactOptions: TPanel
        Left = 0
        Top = 78
        Width = 177
        Height = 73
        BevelOuter = bvNone
        TabOrder = 1
        object radPractice: TRadioButton
          Left = 16
          Top = 4
          Width = 125
          Height = 17
          Caption = '&Practice Details'
          TabOrder = 0
          OnClick = radPracticeClick
        end
        object radStaffMember: TRadioButton
          Left = 16
          Top = 29
          Width = 205
          Height = 17
          Caption = '&Staff Member Details'
          TabOrder = 1
          OnClick = radPracticeClick
        end
        object radCustom: TRadioButton
          Left = 16
          Top = 52
          Width = 159
          Height = 17
          Caption = '&Custom'
          TabOrder = 2
          OnClick = radPracticeClick
        end
      end
      object pnlContactDetails: TPanel
        Left = 160
        Top = 126
        Width = 406
        Height = 97
        BevelOuter = bvNone
        TabOrder = 2
        object lblContactNameView: TLabel
          Left = 104
          Top = 9
          Width = 68
          Height = 13
          Caption = 'Contact Name'
          ShowAccelChar = False
        end
        object lblPhoneView: TLabel
          Left = 104
          Top = 41
          Width = 71
          Height = 13
          Caption = 'Contact Phone'
          ShowAccelChar = False
        end
        object lblEmailView: TLabel
          Left = 104
          Top = 73
          Width = 65
          Height = 13
          Caption = 'Contact Email'
          ShowAccelChar = False
        end
        object lblEmail: TLabel
          Left = 8
          Top = 71
          Width = 28
          Height = 13
          Caption = '&E-mail'
          FocusControl = edtContactEmail
        end
        object lblPhone: TLabel
          Left = 8
          Top = 41
          Width = 30
          Height = 13
          Caption = 'P&hone'
          FocusControl = edtContactPhone
        end
        object lblContactName: TLabel
          Left = 8
          Top = 11
          Width = 38
          Height = 13
          Caption = 'Co&ntact'
          FocusControl = edtContactName
        end
        object edtContactName: TEdit
          Left = 105
          Top = 9
          Width = 292
          Height = 21
          BorderStyle = bsNone
          Ctl3D = True
          MaxLength = 60
          ParentCtl3D = False
          TabOrder = 0
        end
        object edtContactPhone: TEdit
          Left = 105
          Top = 39
          Width = 292
          Height = 21
          BorderStyle = bsNone
          Ctl3D = True
          MaxLength = 60
          ParentCtl3D = False
          TabOrder = 1
        end
        object edtContactEmail: TEdit
          Left = 105
          Top = 69
          Width = 292
          Height = 21
          BorderStyle = bsNone
          MaxLength = 80
          TabOrder = 2
        end
      end
      object pnlWebsiteOptions: TPanel
        Left = 0
        Top = 330
        Width = 97
        Height = 51
        BevelOuter = bvNone
        TabOrder = 5
        object radPracticeWebSite: TRadioButton
          Left = 16
          Top = 0
          Width = 77
          Height = 17
          Caption = 'P&ractice'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = radPracticeWebSiteClick
        end
        object radCustomWebsite: TRadioButton
          Left = 16
          Top = 24
          Width = 77
          Height = 17
          Caption = 'C&ustom'
          TabOrder = 1
          OnClick = radPracticeWebSiteClick
        end
      end
      object pnlWebsiteDetails: TPanel
        Left = 168
        Top = 345
        Width = 410
        Height = 39
        BevelOuter = bvNone
        TabOrder = 6
        object Label16: TLabel
          Left = 0
          Top = 11
          Width = 42
          Height = 13
          Caption = '&Web site'
          FocusControl = edtLoginURL
        end
        object lblWebSite: TLabel
          Left = 97
          Top = 11
          Width = 385
          Height = 16
          AutoSize = False
          Caption = 'lblWebSite'
        end
        object edtLoginURL: TEdit
          Left = 97
          Top = 11
          Width = 289
          Height = 22
          BorderStyle = bsNone
          Ctl3D = False
          ParentCtl3D = False
          TabOrder = 0
          Text = 'edtLoginURL'
          OnChange = cmbResponsibleChange
        end
      end
      object chkArchived: TCheckBox
        Left = 16
        Top = 399
        Width = 425
        Height = 17
        Caption = 'Arc&hive this client'
        TabOrder = 7
      end
      object cmbGroup: TComboBox
        Left = 168
        Top = 229
        Width = 393
        Height = 21
        Style = csDropDownList
        Ctl3D = True
        ItemHeight = 13
        ParentCtl3D = False
        TabOrder = 3
        OnChange = cmbResponsibleChange
      end
      object cmbType: TComboBox
        Left = 168
        Top = 259
        Width = 393
        Height = 21
        Style = csDropDownList
        Ctl3D = True
        ItemHeight = 13
        ParentCtl3D = False
        TabOrder = 4
        OnChange = cmbResponsibleChange
      end
    end
    object tbsNotes: TTabSheet
      Caption = 'Notes'
      ImageIndex = 2
      DesignSize = (
        581
        543)
      object meNotes: TMemo
        Left = 12
        Top = 12
        Width = 561
        Height = 504
        Anchors = [akLeft, akTop, akRight, akBottom]
        Ctl3D = False
        Lines.Strings = (
          'meNotes')
        MaxLength = 20000
        ParentCtl3D = False
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object chkShowOnOpen: TCheckBox
        Left = 12
        Top = 522
        Width = 259
        Height = 17
        Anchors = [akLeft, akBottom]
        Caption = 'Show notes when openin&g this client'
        TabOrder = 1
      end
    end
    object tsSmartLink: TTabSheet
      Caption = 'SmartLink'
      ImageIndex = 4
      object Label19: TLabel
        Left = 16
        Top = 16
        Width = 63
        Height = 13
        Caption = '&FingerTips ID'
      end
      object edtFingertipsClientID: TEdit
        Left = 121
        Top = 13
        Width = 441
        Height = 24
        BorderStyle = bsNone
        TabOrder = 0
      end
    end
    object tsTPRPayerDetails: TTabSheet
      Caption = 'TPAR Payer Details'
      ImageIndex = 5
      object grpPracticeContactDetails: TGroupBox
        Left = 13
        Top = 9
        Width = 549
        Height = 286
        Caption = 'Practice Contact Details'
        TabOrder = 0
        object lblPracticeContactName: TLabel
          Left = 67
          Top = 180
          Width = 80
          Height = 16
          Caption = 'Contact Name'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblPracticeContactPhone: TLabel
          Left = 67
          Top = 210
          Width = 82
          Height = 16
          Caption = 'Contact Phone'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblPracticeContactEmail: TLabel
          Left = 67
          Top = 240
          Width = 83
          Height = 16
          Caption = 'Contact E-mail'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblSupplierContactName: TLabel
          Left = 67
          Top = 60
          Width = 80
          Height = 16
          Caption = 'Contact Name'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblSupplierContactPhone: TLabel
          Left = 67
          Top = 90
          Width = 82
          Height = 16
          Caption = 'Contact Phone'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblSupplierContactEmail: TLabel
          Left = 67
          Top = 120
          Width = 83
          Height = 16
          Caption = 'Contact E-mail'
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object radUsePracticeTPRSupplierDetails: TRadioButton
          Left = 16
          Top = 30
          Width = 497
          Height = 17
          Caption = 'Use Practice TPAR Supplier Details'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = radUsePracticeTPRSupplierDetailsClick
        end
        object radUseCustomContactDetails: TRadioButton
          Left = 16
          Top = 150
          Width = 497
          Height = 17
          Caption = 'Use Custom Contact Details'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = radUseCustomContactDetailsClick
        end
        object edtPracticeContactName: TEdit
          Left = 160
          Top = 177
          Width = 341
          Height = 21
          BorderStyle = bsNone
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 38
          ParentFont = False
          TabOrder = 2
          Text = 'edtPracticeContactName'
        end
        object edtPracticeContactPhone: TEdit
          Left = 160
          Top = 207
          Width = 341
          Height = 21
          BorderStyle = bsNone
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 15
          ParentFont = False
          TabOrder = 3
          Text = 'edtPracticeContactPhone'
        end
        object edtPracticeContactEmail: TEdit
          Left = 160
          Top = 237
          Width = 341
          Height = 21
          BorderStyle = bsNone
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 76
          ParentFont = False
          TabOrder = 4
          Text = 'edtPracticeContactEmail'
        end
        object edtSupplierContactName: TEdit
          Left = 160
          Top = 57
          Width = 341
          Height = 21
          BorderStyle = bsNone
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 38
          ParentFont = False
          ReadOnly = True
          TabOrder = 5
          Text = 'edtSupplierContactName'
        end
        object edtSupplierContactPhone: TEdit
          Left = 160
          Top = 87
          Width = 341
          Height = 21
          BorderStyle = bsNone
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 15
          ParentFont = False
          ReadOnly = True
          TabOrder = 6
          Text = 'edtSupplierContactPhone'
        end
        object edtSupplierContactEmail: TEdit
          Left = 160
          Top = 117
          Width = 341
          Height = 21
          BorderStyle = bsNone
          Enabled = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 76
          ParentFont = False
          ReadOnly = True
          TabOrder = 7
          Text = 'edtSupplierContactEmail'
        end
      end
      object grpPayerDetails: TGroupBox
        Left = 13
        Top = 301
        Width = 549
        Height = 231
        Caption = 'Payer Details'
        TabOrder = 1
        object lblTradingName: TLabel
          Left = 12
          Top = 33
          Width = 81
          Height = 16
          Caption = 'Trading Name'
          FocusControl = edtTradingName
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblStreetAddress: TLabel
          Left = 12
          Top = 63
          Width = 85
          Height = 16
          Caption = 'Street Address'
          FocusControl = edtStreetAddressLine1
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblSuburb: TLabel
          Left = 12
          Top = 123
          Width = 78
          Height = 16
          Caption = 'Town/Suburb'
          FocusControl = edtSuburb
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblPostCode: TLabel
          Left = 11
          Top = 183
          Width = 51
          Height = 16
          Caption = 'Postcode'
          FocusControl = edtPostCode
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblSupplierCountry: TLabel
          Left = 12
          Top = 183
          Width = 44
          Height = 16
          Caption = 'Country'
          FocusControl = edtSupplierCountry
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object lblState: TLabel
          Left = 12
          Top = 153
          Width = 30
          Height = 16
          Caption = 'State'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object edtTradingName: TEdit
          Left = 124
          Top = 30
          Width = 377
          Height = 22
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 200
          ParentFont = False
          TabOrder = 0
          Text = 'edtTradingName'
        end
        object edtStreetAddressLine1: TEdit
          Left = 124
          Top = 60
          Width = 377
          Height = 22
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 38
          ParentFont = False
          TabOrder = 1
          Text = 'edtStreetAddressLine1'
        end
        object edtStreetAddressLine2: TEdit
          Left = 124
          Top = 90
          Width = 377
          Height = 22
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 38
          ParentFont = False
          TabOrder = 2
          Text = 'edtStreetAddressLine2'
        end
        object edtSuburb: TEdit
          Left = 124
          Top = 120
          Width = 377
          Height = 22
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 27
          ParentFont = False
          TabOrder = 3
          Text = 'edtSuburb'
        end
        object edtPostCode: TEdit
          Left = 124
          Top = 180
          Width = 80
          Height = 22
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 4
          ParentFont = False
          TabOrder = 5
          Text = 'edtPostCode'
          OnKeyPress = edtPostCodeKeyPress
        end
        object edtSupplierCountry: TEdit
          Left = 124
          Top = 180
          Width = 377
          Height = 22
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          MaxLength = 20
          ParentFont = False
          TabOrder = 6
          Text = 'edtSupplierCountry'
        end
        object cmbState: TComboBox
          Left = 124
          Top = 149
          Width = 57
          Height = 24
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ItemHeight = 16
          ParentFont = False
          TabOrder = 4
          OnChange = cmbStateChange
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
    Left = 536
    Top = 8
  end
end
