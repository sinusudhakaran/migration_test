object frmTPA: TfrmTPA
  Left = 236
  Top = 116
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Third Party Authority'
  ClientHeight = 749
  ClientWidth = 782
  Color = clWindow
  Constraints.MinWidth = 640
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 17
  object pnlMain: TPanel
    Left = 8
    Top = 8
    Width = 767
    Height = 691
    BevelKind = bkFlat
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object pnlInstTop: TPanel
      Left = 0
      Top = 0
      Width = 763
      Height = 80
      Align = alTop
      BevelOuter = bvNone
      BevelWidth = 2
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      DesignSize = (
        763
        80)
      object lblInstitution: TLabel
        Left = 28
        Top = 13
        Width = 56
        Height = 17
        Caption = 'Institution'
      end
      object lblBranch: TLabel
        Left = 28
        Top = 49
        Width = 39
        Height = 17
        Caption = 'Branch'
      end
      object Bevel1: TBevel
        Left = 0
        Top = 75
        Width = 763
        Height = 5
        Align = alBottom
        Shape = bsTopLine
        ExplicitTop = 74
      end
      object cmbInstitution: TComboBox
        Left = 153
        Top = 10
        Width = 328
        Height = 25
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 0
        TabOrder = 0
        OnChange = cmbInstitutionChange
      end
      object edtInstitutionName: TEdit
        Left = 263
        Top = 10
        Width = 213
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 50
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Visible = False
        OnExit = edt1Exit
      end
      object edtBranch: TEdit
        Left = 153
        Top = 46
        Width = 323
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 100
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnExit = edt1Exit
      end
    end
    object pnlInstitution: TPanel
      Left = 0
      Top = 80
      Width = 763
      Height = 379
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object Bevel2: TBevel
        Left = 0
        Top = 374
        Width = 763
        Height = 5
        Align = alBottom
        Shape = bsTopLine
        ExplicitTop = 74
      end
      object Bevel4: TBevel
        Left = -2
        Top = 125
        Width = 777
        Height = 12
      end
      object Bevel5: TBevel
        Left = -14
        Top = 248
        Width = 777
        Height = 10
      end
      object pnlInstData1: TPanel
        Left = 145
        Top = 2
        Width = 615
        Height = 120
        BevelEdges = [beTop, beRight, beBottom]
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        DesignSize = (
          615
          120)
        object lblAccountHintLine1: TLabel
          Left = 6
          Top = 40
          Width = 550
          Height = 31
          Alignment = taCenter
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Account Hint Line'
          Color = clBtnFace
          ParentColor = False
          ExplicitWidth = 604
        end
        object lblMaskErrorHint1: TLabel
          Left = 7
          Top = 96
          Width = 608
          Height = 20
          AutoSize = False
          Caption = '<Mask Error Hint>'
          Color = clWhite
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object lblClientCode1: TLabel
          Left = 375
          Top = 13
          Width = 67
          Height = 17
          Caption = 'Client Code'
        end
        object lblCostCode1: TLabel
          Left = 375
          Top = 68
          Width = 61
          Height = 17
          Caption = 'Cost Code'
        end
        object edtNameOfAccount1: TEdit
          Left = 8
          Top = 10
          Width = 278
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 100
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = edtNameOfAccount1Change
          OnEnter = edt1Exit
        end
        object mskAccountNumber1: TMaskValidateEdit
          Left = 8
          Top = 65
          Width = 278
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          TabOrder = 2
          OnChange = mskAccountNumber1Change
          OnEnter = mskAccountNumber1Enter
          OnExit = mskAccountNumber1Exit
          OnKeyUp = mskAccountNumber1KeyUp
          OnMouseDown = mskAccountNumber1MouseDown
          OnValidateError = mskAccountNumber1ValidateError
          OnValidateEdit = mskAccountNumber1ValidateEdit
        end
        object edtAccountNumber1: TEdit
          Left = 36
          Top = 65
          Width = 278
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 20
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnChange = edtAccountNumber1Change
          OnEnter = edtAccountNumber1Enter
          OnExit = edtAccountNumber1Exit
        end
        object edtClientCode1: TEdit
          Left = 464
          Top = 10
          Width = 65
          Height = 25
          Hint = 'The client code from BankLink or your general ledger'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          MaxLength = 8
          TabOrder = 3
          OnChange = edtClientCode1Change
          OnExit = edt1Exit
          OnKeyPress = edt1KeyPress
        end
        object edtCostCode1: TEdit
          Left = 464
          Top = 65
          Width = 65
          Height = 25
          Hint = 'The cost code from your practice management or billing system'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          MaxLength = 10
          TabOrder = 4
          OnChange = edtCostCode1Change
          OnExit = edt1Exit
          OnKeyPress = edt1KeyPress
        end
      end
      object pnlInstData2: TPanel
        Left = 145
        Top = 127
        Width = 615
        Height = 120
        BevelEdges = [beTop, beRight, beBottom]
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          615
          120)
        object lblClientCode2: TLabel
          Left = 375
          Top = 13
          Width = 67
          Height = 17
          Caption = 'Client Code'
        end
        object lblCostCode2: TLabel
          Left = 375
          Top = 68
          Width = 61
          Height = 17
          Caption = 'Cost Code'
        end
        object lblAccountHintLine2: TLabel
          Left = 6
          Top = 40
          Width = 550
          Height = 31
          Alignment = taCenter
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Account Hint Line'
          Color = clBtnFace
          ParentColor = False
          ExplicitWidth = 604
        end
        object lblMaskErrorHint2: TLabel
          Left = 7
          Top = 96
          Width = 608
          Height = 22
          AutoSize = False
          Caption = '<Mask Error Hint>'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object edtNameOfAccount2: TEdit
          Left = 8
          Top = 10
          Width = 278
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 100
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = edtNameOfAccount2Change
          OnEnter = edt2Exit
        end
        object edtClientCode2: TEdit
          Left = 464
          Top = 10
          Width = 65
          Height = 25
          Hint = 'The client code from BankLink or your general ledger'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          MaxLength = 8
          TabOrder = 3
          OnChange = edtClientCode2Change
          OnExit = edt2Exit
          OnKeyPress = edt2KeyPress
        end
        object edtCostCode2: TEdit
          Left = 464
          Top = 65
          Width = 65
          Height = 25
          Hint = 'The cost code from your practice management or billing system'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          MaxLength = 10
          TabOrder = 4
          OnChange = edtCostCode2Change
          OnExit = edt2Exit
          OnKeyPress = edt2KeyPress
        end
        object mskAccountNumber2: TMaskValidateEdit
          Left = 8
          Top = 65
          Width = 278
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          TabOrder = 2
          OnChange = mskAccountNumber2Change
          OnEnter = mskAccountNumber2Enter
          OnExit = mskAccountNumber2Exit
          OnKeyUp = mskAccountNumber2KeyUp
          OnMouseDown = mskAccountNumber2MouseDown
          OnValidateError = mskAccountNumber2ValidateError
          OnValidateEdit = mskAccountNumber2ValidateEdit
        end
        object edtAccountNumber2: TEdit
          Left = 36
          Top = 65
          Width = 278
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 20
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnChange = edtAccountNumber2Change
          OnEnter = edtAccountNumber2Enter
          OnExit = edtAccountNumber2Exit
        end
      end
      object pnlInstLabels2: TPanel
        Left = 3
        Top = 127
        Width = 144
        Height = 120
        BevelEdges = [beLeft, beTop, beBottom]
        BevelOuter = bvNone
        BevelWidth = 2
        BorderWidth = 1
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
        object lblNameOfAccount2: TLabel
          Left = 24
          Top = 13
          Width = 101
          Height = 17
          Caption = 'Name of Account'
        end
        object lblAccount2: TLabel
          Left = 24
          Top = 68
          Width = 98
          Height = 17
          Caption = 'Account Number'
        end
      end
      object pnlInstLabels1: TPanel
        Left = 3
        Top = 2
        Width = 144
        Height = 120
        BevelEdges = [beLeft, beTop, beBottom]
        BevelOuter = bvNone
        BevelWidth = 2
        BorderWidth = 1
        Color = clWhite
        ParentBackground = False
        TabOrder = 3
        object lblNameOfAccount1: TLabel
          Left = 24
          Top = 13
          Width = 101
          Height = 17
          Caption = 'Name of Account'
        end
        object lblAccount1: TLabel
          Left = 24
          Top = 68
          Width = 98
          Height = 17
          Caption = 'Account Number'
        end
      end
      object pnlInstData3: TPanel
        Left = 145
        Top = 253
        Width = 615
        Height = 120
        BevelEdges = [beTop, beRight, beBottom]
        BevelOuter = bvNone
        TabOrder = 4
        DesignSize = (
          615
          120)
        object lblClientCode3: TLabel
          Left = 375
          Top = 13
          Width = 67
          Height = 17
          Caption = 'Client Code'
        end
        object lblCostCode3: TLabel
          Left = 375
          Top = 68
          Width = 61
          Height = 17
          Caption = 'Cost Code'
        end
        object lblAccountHintLine3: TLabel
          Left = 6
          Top = 40
          Width = 550
          Height = 31
          Alignment = taCenter
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Account Hint Line'
          Color = clBtnFace
          ParentColor = False
          ExplicitWidth = 604
        end
        object lblMaskErrorHint3: TLabel
          Left = 7
          Top = 96
          Width = 608
          Height = 22
          AutoSize = False
          Caption = '<Mask Error Hint>'
          Color = clBtnFace
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentColor = False
          ParentFont = False
        end
        object edtNameOfAccount3: TEdit
          Left = 8
          Top = 10
          Width = 278
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 100
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = edtNameOfAccount3Change
          OnEnter = edt3Exit
        end
        object edtClientCode3: TEdit
          Left = 464
          Top = 10
          Width = 65
          Height = 25
          Hint = 'The client code from BankLink or your general ledger'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          MaxLength = 8
          TabOrder = 3
          OnChange = edtClientCode3Change
          OnExit = edt3Exit
          OnKeyPress = edt3KeyPress
        end
        object edtCostCode3: TEdit
          Left = 464
          Top = 65
          Width = 65
          Height = 25
          Hint = 'The cost code from your practice management or billing system'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          MaxLength = 10
          TabOrder = 4
          OnChange = edtCostCode3Change
          OnExit = edt3Exit
          OnKeyPress = edt3KeyPress
        end
        object mskAccountNumber3: TMaskValidateEdit
          Left = 8
          Top = 65
          Width = 278
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          TabOrder = 2
          OnChange = mskAccountNumber3Change
          OnEnter = mskAccountNumber3Enter
          OnExit = mskAccountNumber3Exit
          OnKeyUp = mskAccountNumber3KeyUp
          OnMouseDown = mskAccountNumber3MouseDown
          OnValidateError = mskAccountNumber3ValidateError
          OnValidateEdit = mskAccountNumber3ValidateEdit
        end
        object edtAccountNumber3: TEdit
          Left = 36
          Top = 65
          Width = 278
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 20
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnChange = edtAccountNumber3Change
          OnEnter = edtAccountNumber3Enter
          OnExit = edtAccountNumber3Exit
        end
      end
      object s: TPanel
        Left = 3
        Top = 253
        Width = 144
        Height = 120
        BevelEdges = [beLeft, beTop, beBottom]
        BevelOuter = bvNone
        BevelWidth = 2
        BorderWidth = 1
        Color = clWhite
        ParentBackground = False
        TabOrder = 5
        object lblNameOfAccount3: TLabel
          Left = 24
          Top = 13
          Width = 101
          Height = 17
          Caption = 'Name of Account'
        end
        object lblAccount3: TLabel
          Left = 24
          Top = 68
          Width = 98
          Height = 17
          Caption = 'Account Number'
        end
      end
    end
    object pnlClient: TPanel
      Left = 0
      Top = 459
      Width = 763
      Height = 36
      Align = alTop
      BevelEdges = [beLeft, beTop, beRight]
      BevelOuter = bvNone
      TabOrder = 2
      object pnlClientLabel: TPanel
        Left = 0
        Top = 4
        Width = 144
        Height = 31
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblStartDate: TLabel
          Left = 28
          Top = 7
          Width = 58
          Height = 17
          Caption = 'Start Date'
        end
      end
      object pnlClientData: TPanel
        Left = 145
        Top = 6
        Width = 122
        Height = 28
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        object edtClientStartDte: TOvcPictureField
          Left = 8
          Top = 3
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
          InitDateTime = False
          MaxLength = 8
          Options = [efoCaretToEnd]
          PictureMask = 'DD/mm/yy'
          TabOrder = 0
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
      end
      object pnlClientSpacer: TPanel
        Left = 267
        Top = 9
        Width = 344
        Height = 28
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
      end
    end
    object pnlData: TPanel
      Left = 0
      Top = 495
      Width = 763
      Height = 100
      Align = alTop
      BevelEdges = [beLeft, beRight, beBottom]
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      OnClick = pnlDataClick
      DesignSize = (
        763
        100)
      object lblSecureCode: TLabel
        Left = 299
        Top = 62
        Width = 74
        Height = 17
        Caption = 'Secure Code'
      end
      object lblNoteAddFormReq: TLabel
        Left = 46
        Top = 36
        Width = 201
        Height = 17
        Caption = 'An additional form is required for '
      end
      object lblBookSecureLink: TLabel
        Left = 249
        Top = 36
        Width = 78
        Height = 17
        Caption = 'Books Secure'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = lblBookSecureLinkClick
        OnMouseEnter = lblBookSecureLinkMouseEnter
        OnMouseLeave = lblBookSecureLinkMouseLeave
      end
      object lblOrContactiBizz: TLabel
        Left = 329
        Top = 36
        Width = 13
        Height = 17
        Caption = 'or'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object imgInfoAdditionalMsg: TImage
        Left = 28
        Top = 36
        Width = 16
        Height = 16
      end
      object lbliBizz: TLabel
        Left = 346
        Top = 36
        Width = 28
        Height = 17
        Caption = 'iBizz.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        OnClick = lbliBizzClick
        OnMouseEnter = lbliBizzMouseEnter
        OnMouseLeave = lbliBizzMouseLeave
      end
      object chkDataSecureExisting: TCheckBox
        Left = 28
        Top = 62
        Width = 251
        Height = 17
        Hint = 'For BankLink Books Secure or BankLink Online Secure clients'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Data sent to existing secure client'
        TabOrder = 1
        OnClick = chkDataSecureExistingClick
      end
      object chkDataSecureNew: TCheckBox
        Left = 28
        Top = 10
        Width = 358
        Height = 17
        Hint = 'For BankLink Books Secure or BankLink Online Secure clients'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Data sent direct to new secure client'
        TabOrder = 0
        OnClick = chkDataSecureNewClick
      end
      object edtSecureCode: TEdit
        Left = 384
        Top = 59
        Width = 140
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 8
        TabOrder = 2
      end
      object chkSupplyAsProvisional: TCheckBox
        Left = 28
        Top = 114
        Width = 512
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Supply as provisional if account(s) are not available from the B' +
          'ank'
        TabOrder = 3
        OnClick = chkDataSecureNewClick
      end
    end
    object pnlRural: TPanel
      Left = 0
      Top = 595
      Width = 763
      Height = 95
      Align = alTop
      BevelEdges = [beLeft, beRight, beBottom]
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 4
      ExplicitTop = 585
      DesignSize = (
        763
        95)
      object lblRuralInstitutions: TLabel
        Left = 28
        Top = 13
        Width = 103
        Height = 17
        Caption = 'Rural Institutions :'
      end
      object radReDateTransactions: TRadioButton
        Left = 57
        Top = 38
        Width = 644
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Re-date transactions to Payment Date'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnKeyDown = radReDateTransactionsKeyDown
        OnMouseDown = radReDateTransactionsMouseDown
      end
      object radDateShown: TRadioButton
        Left = 57
        Top = 71
        Width = 644
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Date shown on statement (not re-dated)'
        TabOrder = 1
        OnKeyDown = radDateShownKeyDown
        OnMouseDown = radDateShownMouseDown
      end
    end
  end
  object pnlControls: TPanel
    Left = 0
    Top = 708
    Width = 782
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 1
    DesignSize = (
      782
      41)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 782
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 780
    end
    object btnPreview: TButton
      Left = 3
      Top = 7
      Width = 85
      Height = 25
      Hint = 'Preview the Third Party Authority Form'
      Anchors = [akLeft, akBottom]
      Caption = 'Previe&w'
      Default = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 94
      Top = 7
      Width = 85
      Height = 25
      Hint = 'Save the Third Party Authority Form to a file'
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnEmail: TButton
      Left = 184
      Top = 7
      Width = 85
      Height = 25
      Hint = 'Email the Third Party Authority Form to the client'
      Anchors = [akLeft, akBottom]
      Caption = 'E&mail'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = btnEmailClick
    end
    object btnPrint: TButton
      Left = 276
      Top = 7
      Width = 85
      Height = 25
      Hint = 'Print the Third Party Authority Form'
      Anchors = [akLeft, akBottom]
      Caption = '&Print'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = btnPrintClick
    end
    object btnImport: TButton
      Left = 518
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Import'
      TabOrder = 4
      OnClick = btnImportClick
    end
    object btnClear: TButton
      Left = 600
      Top = 7
      Width = 85
      Height = 25
      Hint = 'Clear the form'
      Anchors = [akLeft, akBottom]
      Caption = 'Clear'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = btnClearClick
    end
    object btnCancel: TButton
      Left = 693
      Top = 7
      Width = 80
      Height = 25
      Hint = 'Close the Third Party Authority Form'
      Anchors = [akLeft, akBottom]
      Cancel = True
      Caption = 'Close'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = btnCancelClick
    end
  end
  object Opendlg: TOpenDialog
    Filter = 'Excel file*.xls|*.xls'
    Left = 512
    Top = 498
  end
end
