object frmPracticeDetails: TfrmPracticeDetails
  Left = 392
  Top = 300
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsDialog
  Caption = 'Practice Details'
  ClientHeight = 460
  ClientWidth = 633
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    633
    460)
  PixelsPerInch = 96
  TextHeight = 13
  object Label14: TLabel
    Left = 16
    Top = 40
    Width = 60
    Height = 13
    Caption = 'ABN Number'
  end
  object btnOK: TButton
    Left = 465
    Top = 430
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 549
    Top = 430
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
    Width = 617
    Height = 416
    ActivePage = tbsInterfaces
    MultiLine = True
    TabOrder = 0
    OnChange = PageControl1Change
    OnChanging = PageControl1Changing
    object tbsDetails: TTabSheet
      Caption = 'Details'
      OnShow = tbsDetailsShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        609
        370)
      object Label1: TLabel
        Left = 8
        Top = 10
        Width = 27
        Height = 13
        Caption = '&Name'
        FocusControl = ePracName
      end
      object Label9: TLabel
        Left = 8
        Top = 38
        Width = 30
        Height = 13
        Caption = 'P&hone'
        FocusControl = edtPhone
      end
      object Label7: TLabel
        Left = 8
        Top = 66
        Width = 24
        Height = 13
        Caption = '&Email'
        FocusControl = ePracEmail
      end
      object Label10: TLabel
        Left = 8
        Top = 120
        Width = 85
        Height = 13
        Caption = '&Web Site Address'
        FocusControl = edtWebSite
      end
      object Label15: TLabel
        Left = 8
        Top = 150
        Width = 83
        Height = 13
        Caption = '&Practice Logo File'
        FocusControl = edtLogoBitmapFilename
      end
      object btnBrowseLogoBitmap: TSpeedButton
        Left = 534
        Top = 159
        Width = 24
        Height = 24
        Anchors = [akLeft, akBottom]
        ParentShowHint = False
        ShowHint = True
        Transparent = False
        OnClick = btnBrowseLogoBitmapClick
        ExplicitTop = 148
      end
      object lblLogoBitmapNote: TLabel
        Left = 152
        Top = 174
        Width = 376
        Height = 35
        AutoSize = False
        Caption = 
          'Note: This image will added to BNotes and BankLink 5 offsite cli' +
          'ent files'
        WordWrap = True
      end
      object lblCountry: TLabel
        Left = 580
        Top = -1
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
      object imgPracticeLogo: TImage
        Left = 152
        Top = 205
        Width = 377
        Height = 101
        Center = True
        Proportional = True
        Stretch = True
      end
      object Label2: TLabel
        Left = 8
        Top = 94
        Width = 46
        Height = 13
        Caption = '&Signature'
        FocusControl = btnEdit
      end
      object ePracName: TEdit
        Left = 152
        Top = 8
        Width = 377
        Height = 22
        BorderStyle = bsNone
        MaxLength = 60
        TabOrder = 0
        Text = 'ePracName'
      end
      object edtPhone: TEdit
        Left = 152
        Top = 36
        Width = 209
        Height = 22
        BorderStyle = bsNone
        MaxLength = 20
        TabOrder = 1
        Text = 'Phone No'
      end
      object ePracEmail: TEdit
        Left = 152
        Top = 64
        Width = 377
        Height = 22
        BorderStyle = bsNone
        MaxLength = 80
        TabOrder = 2
        Text = 'ePracEmail'
      end
      object edtWebSite: TEdit
        Left = 152
        Top = 120
        Width = 377
        Height = 22
        BorderStyle = bsNone
        TabOrder = 4
        Text = 'Web Site'
      end
      object gbxDownLoad: TGroupBox
        Left = 0
        Top = 311
        Width = 593
        Height = 45
        TabOrder = 6
        object lblConnect: TLabel
          Left = 11
          Top = 17
          Width = 25
          Height = 13
          Caption = '&Code'
          FocusControl = eBCode
        end
        object Label3: TLabel
          Left = 296
          Top = 17
          Width = 122
          Height = 13
          Caption = 'Last Download Processe&d'
          FocusControl = txtLastDiskID
        end
        object eBCode: TEdit
          Left = 161
          Top = 14
          Width = 121
          Height = 22
          BorderStyle = bsNone
          CharCase = ecUpperCase
          MaxLength = 8
          TabOrder = 0
          Text = 'EBCODE'
        end
        object txtLastDiskID: TEdit
          Left = 464
          Top = 14
          Width = 113
          Height = 22
          BorderStyle = bsNone
          CharCase = ecUpperCase
          Ctl3D = False
          MaxLength = 4
          ParentCtl3D = False
          TabOrder = 1
          Text = '000'
          OnChange = txtLastDiskIDChange
        end
      end
      object edtLogoBitmapFilename: TEdit
        Left = 152
        Top = 148
        Width = 378
        Height = 24
        BorderStyle = bsNone
        Ctl3D = True
        ParentCtl3D = False
        TabOrder = 5
        OnChange = edtLogoBitmapFilenameChange
      end
      object btnEdit: TButton
        Left = 152
        Top = 92
        Width = 91
        Height = 22
        Caption = 'Edit'
        TabOrder = 3
        OnClick = btnEditClick
      end
    end
    object tbsInterfaces: TTabSheet
      Caption = 'Accounting System'
      ImageIndex = 1
      OnShow = tbsInterfacesShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gbxClientDefault: TGroupBox
        Left = 8
        Top = 4
        Width = 593
        Height = 147
        TabOrder = 0
        object Label4: TLabel
          Left = 16
          Top = 20
          Width = 62
          Height = 13
          Caption = 'System &Used'
          FocusControl = cmbSystem
        end
        object lblLoad: TLabel
          Left = 16
          Top = 83
          Width = 80
          Height = 13
          Caption = '&Load Chart From'
          FocusControl = eLoad
        end
        object lblSave: TLabel
          Left = 16
          Top = 115
          Width = 75
          Height = 13
          Caption = '&Save Entries To'
          FocusControl = eSave
        end
        object btnLoadFolder: TSpeedButton
          Left = 442
          Top = 79
          Width = 25
          Height = 24
          ParentShowHint = False
          ShowHint = True
          OnClick = btnLoadFolderClick
        end
        object btnSaveFolder: TSpeedButton
          Left = 442
          Top = 111
          Width = 25
          Height = 24
          ParentShowHint = False
          ShowHint = True
          OnClick = btnSaveFolderClick
        end
        object lblMask: TLabel
          Left = 16
          Top = 51
          Width = 66
          Height = 13
          Caption = 'Account &Mask'
          FocusControl = eMask
        end
        object lblFirmName: TLabel
          Left = 144
          Top = 112
          Width = 400
          Height = 19
          AutoSize = False
        end
        object cmbSystem: TComboBox
          Left = 144
          Top = 16
          Width = 324
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          Sorted = True
          TabOrder = 0
          OnChange = cmbSystemChange
        end
        object eLoad: TEdit
          Left = 144
          Top = 80
          Width = 297
          Height = 22
          BorderStyle = bsNone
          MaxLength = 128
          TabOrder = 2
          Text = 'eLoad'
        end
        object eSave: TEdit
          Left = 144
          Top = 112
          Width = 297
          Height = 22
          BorderStyle = bsNone
          MaxLength = 128
          TabOrder = 3
          Text = 'eSave'
        end
        object eMask: TEdit
          Left = 144
          Top = 48
          Width = 121
          Height = 22
          BorderStyle = bsNone
          MaxLength = 10
          TabOrder = 1
          Text = 'eMask'
        end
        object btnConnectMYOB: TButton
          Left = 144
          Top = 79
          Width = 121
          Height = 27
          Caption = 'MYOB Login'
          TabOrder = 4
          Visible = False
          OnClick = btnConnectMYOBClick
        end
      end
      object gbxWebExport: TGroupBox
        Left = 8
        Top = 243
        Width = 593
        Height = 50
        TabOrder = 2
        object Label11: TLabel
          Left = 16
          Top = 20
          Width = 94
          Height = 13
          Caption = '&Web Export Format'
          FocusControl = cmbWebFormats
        end
        object cmbWebFormats: TComboBox
          Left = 144
          Top = 16
          Width = 322
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          Sorted = True
          TabOrder = 0
        end
      end
      object gbxTaxInterface: TGroupBox
        Left = 8
        Top = 156
        Width = 593
        Height = 82
        TabOrder = 1
        object Label5: TLabel
          Left = 16
          Top = 20
          Width = 93
          Height = 13
          Caption = '&Tax Interface Used'
          FocusControl = cmbTaxInterface
        end
        object Label8: TLabel
          Left = 16
          Top = 50
          Width = 87
          Height = 13
          Caption = 'E&xport Tax File To'
          FocusControl = edtSaveTaxTo
        end
        object btnTaxFolder: TSpeedButton
          Left = 442
          Top = 46
          Width = 25
          Height = 24
          ParentShowHint = False
          ShowHint = True
          OnClick = btnTaxFolderClick
        end
        object cmbTaxInterface: TComboBox
          Left = 144
          Top = 16
          Width = 322
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          Sorted = True
          TabOrder = 0
          OnChange = cmbTaxInterfaceChange
        end
        object edtSaveTaxTo: TEdit
          Left = 144
          Top = 47
          Width = 297
          Height = 22
          BorderStyle = bsNone
          MaxLength = 128
          TabOrder = 1
        end
      end
    end
    object tsSuperFundSystem: TTabSheet
      Caption = 'Superfund System'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gbxSuperSystem: TGroupBox
        Left = 8
        Top = 1
        Width = 595
        Height = 149
        TabOrder = 0
        DesignSize = (
          595
          149)
        object lblSuperfundSystem: TLabel
          Left = 16
          Top = 20
          Width = 62
          Height = 13
          Caption = 'System &Used'
          FocusControl = cmbSuperSystem
        end
        object lblSuperLoad: TLabel
          Left = 16
          Top = 83
          Width = 80
          Height = 13
          Caption = '&Load Chart From'
          FocusControl = eSuperLoad
        end
        object lblSuperSave: TLabel
          Left = 16
          Top = 115
          Width = 75
          Height = 13
          Caption = '&Save Entries To'
          FocusControl = eSuperSave
        end
        object btnSuperLoadFolder: TSpeedButton
          Left = 442
          Top = 79
          Width = 25
          Height = 24
          ParentShowHint = False
          ShowHint = True
          OnClick = btnSuperLoadFolderClick
        end
        object btnSuperSaveFolder: TSpeedButton
          Left = 442
          Top = 111
          Width = 25
          Height = 24
          ParentShowHint = False
          ShowHint = True
          OnClick = btnSuperSaveFolderClick
        end
        object lblSuperMask: TLabel
          Left = 16
          Top = 51
          Width = 66
          Height = 13
          Caption = 'Account &Mask'
          FocusControl = eSuperMask
        end
        object lblConnectBGL: TLabel
          Left = 272
          Top = 83
          Width = 137
          Height = 13
          Caption = 'Successfully signed in to BGL'
        end
        object eSuperLoad: TEdit
          Left = 144
          Top = 80
          Width = 297
          Height = 22
          BorderStyle = bsNone
          MaxLength = 128
          TabOrder = 3
          Text = 'eSuperLoad'
        end
        object cmbSuperSystem: TComboBox
          Left = 144
          Top = 16
          Width = 316
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          Sorted = True
          TabOrder = 0
          OnChange = cmbSuperSystemChange
        end
        object eSuperSave: TEdit
          Left = 144
          Top = 112
          Width = 297
          Height = 22
          BorderStyle = bsNone
          MaxLength = 128
          TabOrder = 4
          Text = 'eSuperSave'
        end
        object eSuperMask: TEdit
          Left = 144
          Top = 48
          Width = 121
          Height = 22
          BorderStyle = bsNone
          MaxLength = 10
          TabOrder = 1
          Text = 'eSuperMask'
        end
        object btnConnectBGL: TButton
          Left = 144
          Top = 79
          Width = 121
          Height = 27
          Anchors = [akLeft, akBottom]
          Caption = 'BGL Sign in'
          TabOrder = 2
          OnClick = btnConnectBGLClick
        end
      end
    end
    object tbsPracticeManagementSystem: TTabSheet
      Caption = 'Practice Management System'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object gbxPracticeManagementSystem: TGroupBox
        Left = 8
        Top = 4
        Width = 594
        Height = 147
        TabOrder = 0
        object lblPracticeManagementSystem: TLabel
          Left = 16
          Top = 20
          Width = 62
          Height = 13
          Caption = 'System &Used'
          FocusControl = cmbPracticeManagementSystem
        end
        object cmbPracticeManagementSystem: TComboBox
          Left = 144
          Top = 16
          Width = 316
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          Sorted = True
          TabOrder = 0
          OnChange = cmbSuperSystemChange
        end
      end
    end
    object tsBankLinkOnline: TTabSheet
      Caption = 'BankLink Online'
      ImageIndex = 4
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lblURL: TLabel
        Left = 16
        Top = 51
        Width = 60
        Height = 13
        Caption = 'Practice &URL'
        FocusControl = edtURL
      end
      object lblPrimaryContact: TLabel
        Left = 16
        Top = 89
        Width = 77
        Height = 13
        Caption = '&Primary Contact'
        FocusControl = cbPrimaryContact
      end
      object lblSelectProducts: TLabel
        Left = 16
        Top = 129
        Width = 390
        Height = 13
        Caption = 
          'Select the BankLink Online products and services that you wish t' +
          'o have available:'
      end
      object ckUseBankLinkOnline: TCheckBox
        Left = 16
        Top = 20
        Width = 265
        Height = 17
        Caption = 'Use &BankLink Online'
        TabOrder = 0
        OnClick = ckUseBankLinkOnlineClick
      end
      object edtURL: TEdit
        Left = 129
        Top = 48
        Width = 383
        Height = 21
        Enabled = False
        ReadOnly = True
        TabOrder = 1
      end
      object cbPrimaryContact: TComboBox
        Left = 129
        Top = 86
        Width = 249
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 2
        OnClick = cbPrimaryContactClick
      end
      object vtProducts: TVirtualStringTree
        Left = 20
        Top = 157
        Width = 496
        Height = 191
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.MainColumn = -1
        Header.Options = [hoColumnResize, hoDrag]
        ParentBackground = False
        TabOrder = 3
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
        OnBeforeItemPaint = vtProductsBeforeItemPaint
        OnChecked = vtProductsChecked
        OnFreeNode = vtProductsFreeNode
        OnGetText = vtProductsGetText
        Columns = <>
      end
      object btnSelectAll: TButton
        Left = 522
        Top = 152
        Width = 75
        Height = 25
        Action = actSelectAllProducts
        Caption = 'Select &All'
        TabOrder = 4
      end
      object btnClearAll: TButton
        Left = 522
        Top = 183
        Width = 75
        Height = 25
        Action = actClearAllProducts
        TabOrder = 5
      end
    end
    object tbsDataExport: TTabSheet
      Caption = 'Data Export Settings'
      ImageIndex = 5
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label12: TLabel
        Left = 16
        Top = 20
        Width = 256
        Height = 13
        Caption = 'There are no Export Data options currently available.'
      end
      object pnlExportOptions: TPanel
        Left = 0
        Top = 0
        Width = 609
        Height = 370
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Label6: TLabel
          Left = 16
          Top = 20
          Width = 47
          Height = 13
          Caption = 'Export To'
        end
        object pgcVendorExportOptions: TPageControl
          Left = 22
          Top = 157
          Width = 575
          Height = 193
          TabOrder = 1
        end
        object chklistExportTo: TCheckListBox
          Left = 161
          Top = 24
          Width = 307
          Height = 108
          OnClickCheck = chklistExportToClickCheck
          IntegralHeight = True
          ItemHeight = 13
          TabOrder = 0
        end
      end
    end
    object tbsTPRSupplierDetails: TTabSheet
      Caption = 'TPAR Supplier Details'
      ImageIndex = 6
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object lblABNNumber: TLabel
        Left = 16
        Top = 43
        Width = 72
        Height = 16
        Caption = 'ABN Number'
        FocusControl = mskABN
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblABNHeading: TLabel
        Left = 8
        Top = 8
        Width = 387
        Height = 16
        Caption = 
          'These are your Practice details and will be sent as '#39'Supplier De' +
          'tails'#39
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblContactName: TLabel
        Left = 16
        Top = 73
        Width = 80
        Height = 16
        Caption = 'Contact Name'
        FocusControl = edtContactName
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblContactPhone: TLabel
        Left = 16
        Top = 103
        Width = 82
        Height = 16
        Caption = 'Contact Phone'
        FocusControl = edtContactPhone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object lblStreetAddress: TLabel
        Left = 16
        Top = 133
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
        Left = 16
        Top = 193
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
        Left = 15
        Top = 253
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
        Left = 16
        Top = 253
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
        Left = 16
        Top = 223
        Width = 30
        Height = 16
        Caption = 'State'
        FocusControl = cmbState
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object edtContactName: TEdit
        Left = 128
        Top = 70
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
        Text = 'edtContactName'
      end
      object edtContactPhone: TEdit
        Left = 128
        Top = 100
        Width = 377
        Height = 22
        BorderStyle = bsNone
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxLength = 15
        ParentFont = False
        TabOrder = 2
        Text = 'edtContactPhone'
      end
      object edtStreetAddressLine1: TEdit
        Left = 128
        Top = 130
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
        TabOrder = 3
        Text = 'edtStreetAddressLine1'
      end
      object edtStreetAddressLine2: TEdit
        Left = 128
        Top = 160
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
        TabOrder = 4
        Text = 'edtStreetAddressLine2'
      end
      object edtSuburb: TEdit
        Left = 128
        Top = 190
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
        TabOrder = 5
        Text = 'edtSuburb'
      end
      object edtPostCode: TEdit
        Left = 128
        Top = 250
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
        TabOrder = 8
        Text = 'edtPostCode'
        OnKeyPress = edtPostCodeKeyPress
      end
      object edtSupplierCountry: TEdit
        Left = 128
        Top = 250
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
        TabOrder = 7
        Text = 'edtSupplierCountry'
      end
      object cmbState: TComboBox
        Left = 128
        Top = 220
        Width = 57
        Height = 24
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ItemHeight = 0
        ParentFont = False
        TabOrder = 6
        OnChange = cmbStateChange
      end
      object mskABN: TMaskEdit
        Left = 128
        Top = 40
        Width = 112
        Height = 21
        BorderStyle = bsNone
        EditMask = '99\ 999\ 999\ 999;0; '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        MaxLength = 14
        ParentFont = False
        TabOrder = 0
        Text = 'mskABN'
        OnClick = mskABNClick
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
    Left = 40
    Top = 424
  end
  object OpenPictureDlg: TOpenPictureDialog
    Filter = 
      'All (*.jpg;*.jpeg;*.bmp;)|*.jpg;*.jpeg;*.bmp;|JPEG Image File (*' +
      '.jpg)|*.jpg|JPEG Image File (*.jpeg)|*.jpeg|Bitmaps (*.bmp)|*.bm' +
      'p'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 8
    Top = 424
  end
  object ActionList1: TActionList
    Left = 72
    Top = 424
    object actSelectAllProducts: TAction
      Caption = '&Select All'
      OnExecute = actSelectAllProductsExecute
    end
    object actClearAllProducts: TAction
      Caption = '&Clear All'
      OnExecute = actClearAllProductsExecute
    end
  end
end
