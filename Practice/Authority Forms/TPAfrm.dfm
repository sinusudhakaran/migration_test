object frmTPA: TfrmTPA
  Left = 236
  Top = 116
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Third Party Authority'
  ClientHeight = 634
  ClientWidth = 634
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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    634
    634)
  PixelsPerInch = 96
  TextHeight = 13
  object btnPreview: TButton
    Left = 8
    Top = 601
    Width = 85
    Height = 25
    Hint = 'Preview the Third Party Authority Form'
    Anchors = [akLeft, akBottom]
    Caption = 'Preview'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    OnClick = btnPreviewClick
  end
  object btnFile: TButton
    Left = 99
    Top = 601
    Width = 85
    Height = 25
    Hint = 'Save the Third Party Authority Form to a file'
    Anchors = [akLeft, akBottom]
    Caption = 'File'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 1
    OnClick = btnFileClick
  end
  object btnEmail: TButton
    Left = 189
    Top = 601
    Width = 85
    Height = 25
    Hint = 'E-mail the Third Party Authority Form to the client'
    Anchors = [akLeft, akBottom]
    Caption = 'E-mail'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    OnClick = btnEmailClick
  end
  object btnPrint: TButton
    Left = 281
    Top = 601
    Width = 85
    Height = 25
    Hint = 'Print the Third Party Authority Form'
    Anchors = [akLeft, akBottom]
    Caption = 'Print'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = btnPrintClick
  end
  object btnImport: TButton
    Left = 372
    Top = 601
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Import'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = btnImportClick
  end
  object btnClear: TButton
    Left = 453
    Top = 601
    Width = 85
    Height = 25
    Hint = 'Clear the form'
    Anchors = [akLeft, akBottom]
    Caption = 'Clear'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = btnClearClick
  end
  object btnCancel: TButton
    Left = 544
    Top = 601
    Width = 80
    Height = 25
    Hint = 'Close the Third Party Authority Form'
    Anchors = [akLeft, akBottom]
    Cancel = True
    Caption = 'Close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnClick = btnCancelClick
  end
  object pnlMain: TPanel
    Left = 8
    Top = 8
    Width = 616
    Height = 587
    BevelKind = bkFlat
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 7
    object pnlInstTop: TPanel
      Left = 0
      Top = 0
      Width = 612
      Height = 65
      Align = alTop
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      DesignSize = (
        612
        65)
      object lblInstitution: TLabel
        Left = 22
        Top = 19
        Width = 54
        Height = 16
        Caption = 'Institution'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object lblInstitutionOther: TLabel
        Left = 44
        Top = 46
        Width = 263
        Height = 16
        Caption = 'This will be loaded as a provisional account.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object imgInfoOtherMsg: TImage
        Left = 24
        Top = 46
        Width = 16
        Height = 16
      end
      object cmbInstitution: TComboBox
        Left = 152
        Top = 16
        Width = 401
        Height = 24
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemHeight = 0
        ParentFont = False
        TabOrder = 0
        OnChange = cmbInstitutionChange
      end
      object edtInstitutionName: TEdit
        Left = 271
        Top = 16
        Width = 287
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        MaxLength = 50
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Visible = False
        OnExit = edtExit
      end
    end
    object pnlInstitution: TPanel
      Left = 0
      Top = 65
      Width = 612
      Height = 133
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object pnlInstData: TPanel
        Left = 145
        Top = 1
        Width = 415
        Height = 131
        Align = alClient
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        DesignSize = (
          415
          131)
        object lblAccountHintLine: TLabel
          Left = 8
          Top = 75
          Width = 402
          Height = 31
          Alignment = taCenter
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Account Hint Line'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          ExplicitWidth = 379
        end
        object edtBranch: TEdit
          Left = 8
          Top = 0
          Width = 404
          Height = 24
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 100
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnExit = edtExit
        end
        object edtNameOfAccount: TEdit
          Left = 8
          Top = 45
          Width = 404
          Height = 24
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 100
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnEnter = edtExit
        end
        object mskAccountNumber: TMaskValidateEdit
          Left = 8
          Top = 106
          Width = 404
          Height = 24
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnEnter = mskAccountNumberEnter
          OnExit = mskAccountNumberExit
          OnKeyUp = mskAccountNumberKeyUp
          OnMouseDown = mskAccountNumberMouseDown
          OnValidateError = mskAccountNumberValidateError
          OnValidateEdit = mskAccountNumberValidateEdit
        end
        object edtAccountNumber: TEdit
          Left = 8
          Top = 106
          Width = 404
          Height = 24
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 20
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 3
          OnExit = edtAccountNumberExit
        end
      end
      object pnlInstLabels: TPanel
        Left = 1
        Top = 1
        Width = 144
        Height = 131
        Align = alLeft
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblBranch: TLabel
          Left = 22
          Top = 3
          Width = 42
          Height = 16
          Caption = 'Branch'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lblAccount: TLabel
          Left = 22
          Top = 109
          Width = 99
          Height = 16
          Caption = 'Account Number'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lblNameOfAccount: TLabel
          Left = 22
          Top = 48
          Width = 102
          Height = 16
          Caption = 'Name of Account'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlInstSpacer: TPanel
        Left = 560
        Top = 1
        Width = 51
        Height = 131
        Align = alRight
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
      end
    end
    object pnlClient: TPanel
      Left = 0
      Top = 225
      Width = 612
      Height = 118
      Align = alTop
      TabOrder = 2
      object pnlClientLabel: TPanel
        Left = 1
        Top = 1
        Width = 144
        Height = 116
        Align = alLeft
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblCostCode: TLabel
          Left = 22
          Top = 48
          Width = 63
          Height = 16
          Caption = 'Cost Code'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lblClientCode: TLabel
          Left = 22
          Top = 3
          Width = 69
          Height = 16
          Caption = 'Client Code'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lblStartDate: TLabel
          Left = 22
          Top = 91
          Width = 59
          Height = 16
          Caption = 'Start Date'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlClientData: TPanel
        Left = 145
        Top = 1
        Width = 122
        Height = 116
        Align = alClient
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        DesignSize = (
          122
          116)
        object edtClientCode: TEdit
          Left = 8
          Top = 0
          Width = 110
          Height = 24
          Hint = 'The client code from BankLink or your general ledger'
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 8
          ParentFont = False
          TabOrder = 0
          OnExit = edtExit
          OnKeyPress = edtKeyPress
        end
        object edtClientStartDte: TOvcPictureField
          Left = 8
          Top = 88
          Width = 85
          Height = 24
          Cursor = crIBeam
          DataType = pftDate
          AutoSize = False
          CaretOvr.Shape = csBlock
          ControlCharColor = clRed
          DecimalPlaces = 0
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Epoch = 0
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          InitDateTime = False
          MaxLength = 8
          Options = [efoCaretToEnd]
          ParentFont = False
          PictureMask = 'DD/mm/yy'
          TabOrder = 2
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
        object edtCostCode: TEdit
          Left = 8
          Top = 45
          Width = 108
          Height = 24
          Hint = 'The cost code from your practice management or billing system'
          Anchors = [akLeft, akTop, akRight]
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 10
          ParentFont = False
          TabOrder = 1
          OnExit = edtExit
          OnKeyPress = edtKeyPress
        end
      end
      object pnlClientSpacer: TPanel
        Left = 267
        Top = 1
        Width = 344
        Height = 116
        Align = alRight
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
      end
    end
    object pnlData: TPanel
      Left = 0
      Top = 343
      Width = 612
      Height = 114
      Align = alTop
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      DesignSize = (
        612
        114)
      object lblSecureCode: TLabel
        Left = 279
        Top = 79
        Width = 79
        Height = 16
        Caption = 'Secure Code'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object lblNoteAddFormReq: TLabel
        Left = 44
        Top = 50
        Width = 194
        Height = 16
        Caption = 'An additional form is required for '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object lblBookSecureLink: TLabel
        Left = 238
        Top = 50
        Width = 85
        Height = 16
        Caption = 'Books Secure'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = lblBookSecureLinkClick
        OnMouseEnter = lblBookSecureLinkMouseEnter
        OnMouseLeave = lblBookSecureLinkMouseLeave
      end
      object lblOrContactiBizz: TLabel
        Left = 326
        Top = 50
        Width = 12
        Height = 16
        Caption = 'or'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object imgInfoAdditionalMsg: TImage
        Left = 24
        Top = 50
        Width = 16
        Height = 16
      end
      object lbliBizz: TLabel
        Left = 342
        Top = 50
        Width = 30
        Height = 16
        Caption = 'iBizz.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = lbliBizzClick
        OnMouseEnter = lbliBizzMouseEnter
        OnMouseLeave = lbliBizzMouseLeave
      end
      object chkDataSecureExisting: TCheckBox
        Left = 22
        Top = 79
        Width = 239
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Data sent to existing secure client'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnClick = chkDataSecureExistingClick
      end
      object chkDataSecureNew: TCheckBox
        Left = 22
        Top = 27
        Width = 239
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Data sent direct to new secure client'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = chkDataSecureNewClick
      end
      object edtSecureCode: TEdit
        Left = 380
        Top = 76
        Width = 178
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        MaxLength = 8
        ParentFont = False
        TabOrder = 2
      end
    end
    object pnlRural: TPanel
      Left = 0
      Top = 457
      Width = 612
      Height = 98
      Align = alTop
      Color = clWhite
      ParentBackground = False
      TabOrder = 4
      DesignSize = (
        612
        98)
      object lblRuralInstitutions: TLabel
        Left = 25
        Top = 10
        Width = 102
        Height = 16
        Caption = 'Rural Institutions :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object radReDateTransactions: TRadioButton
        Left = 56
        Top = 38
        Width = 525
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Re-date transactions to Payment Date'
        Checked = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        TabStop = True
        OnKeyDown = radReDateTransactionsKeyDown
        OnMouseDown = radReDateTransactionsMouseDown
      end
      object radDateShown: TRadioButton
        Left = 56
        Top = 71
        Width = 525
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Date shown on statement (not re-dated)'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnKeyDown = radDateShownKeyDown
        OnMouseDown = radDateShownMouseDown
      end
    end
    object pnlAccountError: TPanel
      Left = 0
      Top = 198
      Width = 612
      Height = 27
      Align = alTop
      TabOrder = 5
      object lblAccountValidationError: TLabel
        Left = 1
        Top = 5
        Width = 608
        Height = 16
        Alignment = taCenter
        AutoSize = False
        Caption = 'Account Error hint'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
    end
  end
  object Opendlg: TOpenDialog
    Filter = 'Excel file*.xls|*.xls'
    Left = 584
    Top = 506
  end
end
