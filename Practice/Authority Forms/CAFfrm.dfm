object frmCAF: TfrmCAF
  Left = 256
  Top = 163
  ActiveControl = edtInstitutionName
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Client Authority Form'
  ClientHeight = 691
  ClientWidth = 783
  Color = clWindow
  Constraints.MinWidth = 350
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
  object Panel6: TPanel
    Left = 0
    Top = 650
    Width = 783
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 783
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnPreview: TButton
      Left = 8
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Preview the Client Authority Form'
      Caption = 'Previe&w'
      Default = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 96
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Save the Client Authority Form to a file'
      Caption = 'Fil&e'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnCancel: TButton
      Left = 692
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Close the Client Authority Form'
      Cancel = True
      Caption = 'Close'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      OnClick = btnCancelClick
    end
    object btnPrint: TButton
      Left = 272
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Print the Client Authority Form'
      Caption = '&Print'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      OnClick = btnPrintClick
    end
    object btnEmail: TButton
      Left = 183
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Email the Client Authority Form to the client'
      Caption = 'E&mail'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      OnClick = btnEmailClick
    end
    object btnClear: TButton
      Left = 604
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Clear the form'
      Caption = 'Clear'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = btnClearClick
    end
    object btnImport: TButton
      Left = 516
      Top = 8
      Width = 83
      Height = 25
      Caption = 'Import'
      TabOrder = 4
      OnClick = btnImportClick
    end
  end
  object pnlMain: TPanel
    Left = 8
    Top = 10
    Width = 767
    Height = 632
    BevelKind = bkFlat
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 83
      Width = 767
      Height = 8
      Shape = bsTopLine
    end
    object Bevel4: TBevel
      Left = -4
      Top = 456
      Width = 767
      Height = 8
      Shape = bsTopLine
    end
    object pnlData: TPanel
      Left = 0
      Top = 496
      Width = 763
      Height = 134
      Align = alTop
      BevelEdges = [beLeft, beRight, beBottom]
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      OnClick = pnlDataClick
      DesignSize = (
        763
        134)
      object lblSecureCode: TLabel
        Left = 288
        Top = 56
        Width = 74
        Height = 17
        Caption = 'Secure Code'
      end
      object imgInfoAdditionalMsg: TImage
        Left = 28
        Top = 31
        Width = 16
        Height = 16
      end
      object lblNoteAddFormReq: TLabel
        Left = 47
        Top = 31
        Width = 201
        Height = 17
        Caption = 'An additional form is required for '
      end
      object lblBookSecureLink: TLabel
        Left = 248
        Top = 31
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
        Left = 330
        Top = 31
        Width = 13
        Height = 17
        Caption = 'or'
        ParentShowHint = False
        ShowHint = False
        Transparent = True
      end
      object lbliBizz: TLabel
        Left = 347
        Top = 31
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
        Top = 56
        Width = 253
        Height = 17
        Hint = 'For BankLink Books Secure or BankLink Online Secure clients'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Data sent to existing secure client'
        TabOrder = 1
        OnClick = chkDataSecureExistingClick
      end
      object chkDataSecureNew: TCheckBox
        Left = 28
        Top = 4
        Width = 292
        Height = 17
        Hint = 'For BankLink Books Secure or BankLink Online Secure clients'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Data sent direct to new secure client'
        TabOrder = 0
        OnClick = chkDataSecureNewClick
      end
      object edtSecureCode: TEdit
        Left = 382
        Top = 53
        Width = 140
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 8
        TabOrder = 2
      end
      object chkSupplyAsProvisional: TCheckBox
        Left = 28
        Top = 108
        Width = 445
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Supply as provisional if account(s) are not available from the B' +
          'ank'
        TabOrder = 3
        OnClick = chkDataSecureNewClick
      end
    end
    object pnlInstTop: TPanel
      Left = 0
      Top = 0
      Width = 763
      Height = 83
      Align = alTop
      BevelOuter = bvNone
      BevelWidth = 2
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      DesignSize = (
        763
        83)
      object lblInstitution: TLabel
        Left = 29
        Top = 13
        Width = 56
        Height = 17
        Caption = 'Institution'
      end
      object lblBranch: TLabel
        Left = 28
        Top = 48
        Width = 39
        Height = 17
        Caption = 'Branch'
      end
      object lblAdditionalFormRequired: TLabel
        Left = 545
        Top = 15
        Width = 145
        Height = 17
        Caption = 'Additional form required'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        Visible = False
        OnClick = lblAdditionalFormRequiredClick
        OnMouseEnter = lblAdditionalFormRequiredMouseEnter
        OnMouseLeave = lblAdditionalFormRequiredMouseLeave
      end
      object cmbInstitution: TComboBox
        Left = 153
        Top = 10
        Width = 366
        Height = 25
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 17
        TabOrder = 0
        OnChange = cmbInstitutionChange
      end
      object edtInstitutionName: TEdit
        Left = 263
        Top = 10
        Width = 251
        Height = 25
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 50
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Visible = False
        OnChange = edtInstitutionNameChange
      end
      object edtBranch: TEdit
        Left = 153
        Top = 45
        Width = 361
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
      Top = 83
      Width = 763
      Height = 378
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object Bevel2: TBevel
        Left = -4
        Top = 123
        Width = 767
        Height = 8
        Shape = bsTopLine
      end
      object Bevel3: TBevel
        Left = -4
        Top = 245
        Width = 767
        Height = 8
        Shape = bsTopLine
      end
      object pnlInstData1: TPanel
        Left = 145
        Top = 1
        Width = 615
        Height = 120
        BevelEdges = [beTop, beRight, beBottom]
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        DesignSize = (
          615
          120)
        object lblAccountHintLine1: TLabel
          Left = 6
          Top = 40
          Width = 546
          Height = 31
          Alignment = taCenter
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Account Hint Line'
          Color = clBtnFace
          ParentColor = False
          ExplicitWidth = 604
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
        object lblMaskErrorHint1: TLabel
          Left = 6
          Top = 96
          Width = 608
          Height = 20
          AutoSize = False
          Caption = '<Mask Error Hint>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object edtNameOfAccount1: TEdit
          Left = 8
          Top = 10
          Width = 292
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
          Width = 292
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          TabOrder = 1
          OnChange = mskAccountNumber1Change
          OnEnter = mskAccountNumber1Enter
          OnExit = mskAccountNumber1Exit
          OnKeyUp = mskAccountNumber1KeyUp
          OnMouseDown = mskAccountNumber1MouseDown
          OnValidateError = mskAccountNumber1ValidateError
          OnValidateEdit = mskAccountNumber1ValidateEdit
        end
        object edtAccountNumber1: TEdit
          Left = 30
          Top = 65
          Width = 292
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 20
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnChange = edtAccountNumber1Change
          OnEnter = edtAccountNumber1Enter
          OnExit = edtAccountNumber1Exit
        end
        object edtClientCode1: TEdit
          Left = 464
          Top = 10
          Width = 79
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
          Width = 79
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
      object pnlInstLabels1: TPanel
        Left = 3
        Top = 1
        Width = 144
        Height = 120
        BevelEdges = [beLeft, beTop, beBottom]
        BevelOuter = bvNone
        BevelWidth = 2
        BorderWidth = 1
        Color = clWhite
        ParentBackground = False
        TabOrder = 4
        object lblAccount1: TLabel
          Left = 24
          Top = 68
          Width = 98
          Height = 17
          Caption = 'Account Number'
        end
        object lblNameOfAccount1: TLabel
          Left = 24
          Top = 13
          Width = 101
          Height = 17
          Caption = 'Name of Account'
        end
      end
      object pnlInstData2: TPanel
        Left = 145
        Top = 125
        Width = 615
        Height = 120
        BevelEdges = [beTop, beRight, beBottom]
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
        DesignSize = (
          615
          120)
        object lblAccountHintLine2: TLabel
          Left = 6
          Top = 40
          Width = 546
          Height = 31
          Alignment = taCenter
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Account Hint Line'
          Color = clBtnFace
          ParentColor = False
          ExplicitWidth = 606
        end
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
        object lblMaskErrorHint2: TLabel
          Left = 6
          Top = 96
          Width = 608
          Height = 19
          AutoSize = False
          Caption = '<Mask Error Hint>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object edtNameOfAccount2: TEdit
          Left = 8
          Top = 10
          Width = 292
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 100
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = edtNameOfAccount2Change
          OnEnter = edt2Exit
        end
        object mskAccountNumber2: TMaskValidateEdit
          Left = 8
          Top = 65
          Width = 292
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          TabOrder = 1
          OnChange = mskAccountNumber2Change
          OnEnter = mskAccountNumber2Enter
          OnExit = mskAccountNumber2Exit
          OnKeyUp = mskAccountNumber2KeyUp
          OnMouseDown = mskAccountNumber2MouseDown
          OnValidateError = mskAccountNumber2ValidateError
          OnValidateEdit = mskAccountNumber2ValidateEdit
        end
        object edtAccountNumber2: TEdit
          Left = 30
          Top = 65
          Width = 292
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 20
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnChange = edtAccountNumber2Change
          OnEnter = edtAccountNumber2Enter
          OnExit = edtAccountNumber2Exit
        end
        object edtClientCode2: TEdit
          Left = 464
          Top = 10
          Width = 79
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
          Width = 79
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
      end
      object pnlInstLabels2: TPanel
        Left = 3
        Top = 125
        Width = 144
        Height = 120
        BevelEdges = [beLeft, beTop, beBottom]
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblAccount2: TLabel
          Left = 24
          Top = 68
          Width = 98
          Height = 17
          Caption = 'Account Number'
        end
        object lblNameOfAccount2: TLabel
          Left = 24
          Top = 13
          Width = 101
          Height = 17
          Caption = 'Name of Account'
        end
      end
      object pnlInstData3: TPanel
        Left = 145
        Top = 249
        Width = 615
        Height = 120
        BevelEdges = [beTop, beRight, beBottom]
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 3
        DesignSize = (
          615
          120)
        object lblAccountHintLine3: TLabel
          Left = 6
          Top = 40
          Width = 546
          Height = 31
          Alignment = taCenter
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 'Account Hint Line'
          Color = clBtnFace
          ParentColor = False
          ExplicitWidth = 606
        end
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
        object lblMaskErrorHint3: TLabel
          Left = 6
          Top = 96
          Width = 608
          Height = 20
          AutoSize = False
          Caption = '<Mask Error Hint>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object edtNameOfAccount3: TEdit
          Left = 8
          Top = 10
          Width = 292
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 100
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnEnter = edt3Exit
        end
        object mskAccountNumber3: TMaskValidateEdit
          Left = 8
          Top = 65
          Width = 292
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          TabOrder = 1
          OnChange = mskAccountNumber3Change
          OnEnter = mskAccountNumber3Enter
          OnExit = mskAccountNumber3Exit
          OnKeyUp = mskAccountNumber3KeyUp
          OnMouseDown = mskAccountNumber3MouseDown
          OnValidateError = mskAccountNumber3ValidateError
          OnValidateEdit = mskAccountNumber3ValidateEdit
        end
        object edtAccountNumber3: TEdit
          Left = 30
          Top = 65
          Width = 292
          Height = 25
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 20
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnChange = edtAccountNumber3Change
          OnEnter = edtAccountNumber3Enter
          OnExit = edtAccountNumber3Exit
        end
        object edtClientCode3: TEdit
          Left = 464
          Top = 10
          Width = 79
          Height = 25
          Hint = 'The client code from BankLink or your general ledger'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          MaxLength = 8
          TabOrder = 3
          OnExit = edt3Exit
          OnKeyPress = edt3KeyPress
        end
        object edtCostCode3: TEdit
          Left = 464
          Top = 65
          Width = 79
          Height = 25
          Hint = 'The cost code from your practice management or billing system'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          MaxLength = 10
          TabOrder = 4
          OnExit = edt3Exit
          OnKeyPress = edt3KeyPress
        end
      end
      object pnlInstLabels3: TPanel
        Left = 3
        Top = 249
        Width = 144
        Height = 120
        BevelEdges = [beLeft, beTop, beBottom]
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 5
        object lblAccount3: TLabel
          Left = 24
          Top = 68
          Width = 98
          Height = 17
          Caption = 'Account Number'
        end
        object lblNameOfAccount3: TLabel
          Left = 24
          Top = 13
          Width = 101
          Height = 17
          Caption = 'Name of Account'
        end
      end
    end
    object pnlClient: TPanel
      Left = 0
      Top = 461
      Width = 763
      Height = 35
      Align = alTop
      BevelEdges = [beLeft, beTop, beRight]
      BevelOuter = bvNone
      TabOrder = 2
      object pnlClientLabel: TPanel
        Left = 1
        Top = 5
        Width = 144
        Height = 28
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblStartDate: TLabel
          Left = 28
          Top = 3
          Width = 58
          Height = 17
          Caption = 'Start Date'
        end
      end
      object pnlClientData: TPanel
        Left = 145
        Top = 5
        Width = 273
        Height = 28
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        object edtClientStartDte: TOvcPictureField
          Left = 8
          Top = 0
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
        Left = 419
        Top = 0
        Width = 344
        Height = 35
        Align = alRight
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
      end
    end
  end
  object Opendlg: TOpenDialog
    Filter = 'Excel file*.xls|*.xls'
    Left = 728
    Top = 40
  end
end
