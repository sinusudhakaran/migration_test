object frmTPA: TfrmTPA
  Left = 236
  Top = 116
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Third Party Authority'
  ClientHeight = 602
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
    602)
  PixelsPerInch = 96
  TextHeight = 13
  object btnPreview: TButton
    Left = 8
    Top = 569
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
    Top = 569
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
    Top = 569
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
    Top = 569
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
    Top = 569
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
    Top = 569
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
    Top = 569
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
    Height = 553
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
        Left = 24
        Top = 22
        Width = 60
        Height = 16
        Caption = 'Institution :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object lblInstitutionOther: TLabel
        Left = 24
        Top = 46
        Width = 563
        Height = 16
        Caption = 
          #39'Other'#39' is for provisional accounts. For non-provisional account' +
          's, please select a valid institution.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object cmbInstitution: TComboBox
        Left = 152
        Top = 16
        Width = 379
        Height = 24
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemHeight = 16
        ParentFont = False
        TabOrder = 0
        OnChange = cmbInstitutionChange
      end
      object edtInstitutionName: TEdit
        Left = 267
        Top = 16
        Width = 265
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
        Width = 392
        Height = 131
        Align = alClient
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        DesignSize = (
          392
          131)
        object lblAccountHintLine: TLabel
          Left = 8
          Top = 75
          Width = 379
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
        end
        object edtBranch: TEdit
          Left = 8
          Top = 0
          Width = 379
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
          Width = 379
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
          OnKeyPress = edtKeyPress
        end
        object mskAccountNumber: TMaskValidateEdit
          Left = 8
          Top = 106
          Width = 378
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
          Width = 379
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
          Left = 24
          Top = 5
          Width = 48
          Height = 16
          Caption = 'Branch :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lblAccount: TLabel
          Left = 24
          Top = 109
          Width = 105
          Height = 16
          Caption = 'Account Number :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lblNameOfAccount: TLabel
          Left = 21
          Top = 48
          Width = 108
          Height = 16
          Caption = 'Name of Account :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
      end
      object pnlInstSpacer: TPanel
        Left = 537
        Top = 1
        Width = 74
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
          Left = 24
          Top = 46
          Width = 69
          Height = 16
          Caption = 'Cost Code :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lblClientCode: TLabel
          Left = 24
          Top = 5
          Width = 75
          Height = 16
          Caption = 'Client Code :'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object lblStartDate: TLabel
          Left = 24
          Top = 94
          Width = 65
          Height = 16
          Caption = 'Start Date :'
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
          Width = 108
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
        end
        object edtClientStartDte: TOvcPictureField
          Left = 6
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
      Height = 104
      Align = alTop
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      DesignSize = (
        612
        104)
      object lblRecieved: TLabel
        Left = 261
        Top = 27
        Width = 111
        Height = 16
        Caption = 'To be received in :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object lblSecureCode: TLabel
        Left = 261
        Top = 72
        Width = 85
        Height = 16
        Caption = 'Secure Code :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object chkExistingClient: TCheckBox
        Left = 22
        Top = 72
        Width = 167
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Existing Client'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 2
        OnClick = chkExistingClientClick
      end
      object chkDataToClient: TCheckBox
        Left = 22
        Top = 27
        Width = 162
        Height = 17
        Hint = 'For BankLink Books Secure or BankLink Online Secure clients'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Data sent direct to client'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnClick = chkDataToClientClick
      end
      object cmbRecieved: TComboBox
        Left = 381
        Top = 25
        Width = 210
        Height = 24
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemHeight = 16
        ParentFont = False
        TabOrder = 1
      end
      object edtSecureCode: TEdit
        Left = 381
        Top = 70
        Width = 210
        Height = 24
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        MaxLength = 8
        ParentFont = False
        TabOrder = 3
      end
    end
    object pnlRural: TPanel
      Left = 0
      Top = 447
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
