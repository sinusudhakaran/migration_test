object frmCAF: TfrmCAF
  Left = 256
  Top = 163
  ActiveControl = edtInstitutionName
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Client Authority Form'
  ClientHeight = 706
  ClientWidth = 783
  Color = clBtnFace
  Constraints.MinWidth = 350
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel6: TPanel
    Left = 0
    Top = 665
    Width = 783
    Height = 41
    Align = alBottom
    BevelOuter = bvLowered
    TabOrder = 1
    object btnPreview: TButton
      Left = 8
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Preview the Client Authority Form'
      Caption = 'Previe&w'
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
      Left = 96
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Save the Client Authority Form to a file'
      Caption = 'Fil&e'
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
    object btnCancel: TButton
      Left = 692
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Close the Client Authority Form'
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
    object btnPrint: TButton
      Left = 272
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Print the Client Authority Form'
      Caption = '&Print'
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
    object btnEmail: TButton
      Left = 183
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Email the Client Authority Form to the client'
      Caption = 'E&mail'
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
    object btnClear: TButton
      Left = 604
      Top = 8
      Width = 83
      Height = 25
      Hint = 'Clear the form'
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
    object btnImport: TButton
      Left = 516
      Top = 8
      Width = 83
      Height = 25
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
  end
  object pnlMain: TPanel
    Left = 8
    Top = 8
    Width = 767
    Height = 649
    BevelKind = bkFlat
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 0
    object pnlData: TPanel
      Left = 3
      Top = 483
      Width = 757
      Height = 160
      BevelEdges = [beLeft, beRight, beBottom]
      BevelKind = bkFlat
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      DesignSize = (
        753
        158)
      object lblSecureCode: TLabel
        Left = 283
        Top = 75
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
      object imgInfoAdditionalMsg: TImage
        Left = 24
        Top = 50
        Width = 16
        Height = 16
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
        ParentShowHint = False
        ShowHint = False
        Transparent = True
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
        Left = 24
        Top = 75
        Width = 214
        Height = 17
        Hint = 'For BankLink Books Secure or BankLink Online Secure clients'
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
        Left = 24
        Top = 27
        Width = 310
        Height = 17
        Hint = 'For BankLink Books Secure or BankLink Online Secure clients'
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
        Left = 382
        Top = 72
        Width = 243
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
      object chkSupplyAsProvisional: TCheckBox
        Left = 24
        Top = 123
        Width = 463
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Supply as provisional if account is not available from the Bank'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 3
        OnClick = chkDataSecureNewClick
      end
    end
    object pnlInstTop: TPanel
      Left = 3
      Top = 2
      Width = 757
      Height = 80
      BevelKind = bkFlat
      BevelOuter = bvNone
      BevelWidth = 2
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      DesignSize = (
        753
        76)
      object lblInstitution: TLabel
        Left = 23
        Top = 13
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
      object lblBranch: TLabel
        Left = 23
        Top = 48
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
      object lblAdditionalFormRequired: TLabel
        Left = 545
        Top = 15
        Width = 142
        Height = 16
        Caption = 'Additional form required'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
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
        Left = 148
        Top = 10
        Width = 384
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
        Left = 263
        Top = 10
        Width = 269
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
        OnChange = edtInstitutionNameChange
      end
      object edtBranch: TEdit
        Left = 148
        Top = 45
        Width = 384
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
        TabOrder = 2
        OnExit = edt1Exit
      end
    end
    object pnlInstitution: TPanel
      Left = 0
      Top = 85
      Width = 763
      Height = 377
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = 11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      object pnlInstData1: TPanel
        Left = 145
        Top = 1
        Width = 615
        Height = 120
        BevelEdges = [beTop, beRight, beBottom]
        BevelKind = bkFlat
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        DesignSize = (
          613
          116)
        object lblAccountHintLine1: TLabel
          Left = 6
          Top = 40
          Width = 558
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
          ExplicitWidth = 604
        end
        object lblClientCode1: TLabel
          Left = 375
          Top = 13
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
        object lblCostCode1: TLabel
          Left = 375
          Top = 68
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
        object lblMaskErrorHint1: TLabel
          Left = 6
          Top = 95
          Width = 608
          Height = 13
          AutoSize = False
          Caption = '<Mask Error Hint>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object edtNameOfAccount1: TEdit
          Left = 8
          Top = 10
          Width = 304
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
          OnChange = edtNameOfAccount1Change
          OnEnter = edt1Exit
        end
        object mskAccountNumber1: TMaskValidateEdit
          Left = 8
          Top = 65
          Width = 304
          Height = 24
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
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
          Width = 304
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
          TabOrder = 2
          OnChange = edtAccountNumber1Change
          OnExit = edtAccountNumber1Exit
        end
        object edtClientCode1: TEdit
          Left = 464
          Top = 10
          Width = 91
          Height = 24
          Hint = 'The client code from BankLink or your general ledger'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 8
          ParentFont = False
          TabOrder = 3
          OnChange = edtClientCode1Change
          OnExit = edt1Exit
          OnKeyPress = edt1KeyPress
        end
        object edtCostCode1: TEdit
          Left = 464
          Top = 65
          Width = 91
          Height = 24
          Hint = 'The cost code from your practice management or billing system'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 10
          ParentFont = False
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
        BevelKind = bkFlat
        BevelOuter = bvNone
        BevelWidth = 2
        BorderWidth = 1
        Color = clWhite
        ParentBackground = False
        TabOrder = 4
        object lblAccount1: TLabel
          Left = 23
          Top = 68
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
        object lblNameOfAccount1: TLabel
          Left = 23
          Top = 13
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
      object pnlInstData2: TPanel
        Left = 145
        Top = 125
        Width = 615
        Height = 120
        BevelEdges = [beTop, beRight, beBottom]
        BevelKind = bkFlat
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
        DesignSize = (
          613
          116)
        object lblAccountHintLine2: TLabel
          Left = 6
          Top = 40
          Width = 558
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
          ExplicitWidth = 606
        end
        object lblClientCode2: TLabel
          Left = 375
          Top = 13
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
        object lblCostCode2: TLabel
          Left = 375
          Top = 68
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
        object lblMaskErrorHint2: TLabel
          Left = 6
          Top = 95
          Width = 608
          Height = 13
          AutoSize = False
          Caption = '<Mask Error Hint>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object edtNameOfAccount2: TEdit
          Left = 8
          Top = 10
          Width = 304
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
          OnChange = edtNameOfAccount2Change
          OnEnter = edt2Exit
        end
        object mskAccountNumber2: TMaskValidateEdit
          Left = 8
          Top = 65
          Width = 304
          Height = 24
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
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
          Width = 304
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
          TabOrder = 2
          OnChange = edtAccountNumber2Change
          OnExit = edtAccountNumber2Exit
        end
        object edtClientCode2: TEdit
          Left = 464
          Top = 10
          Width = 91
          Height = 24
          Hint = 'The client code from BankLink or your general ledger'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 8
          ParentFont = False
          TabOrder = 3
          OnChange = edtClientCode2Change
          OnExit = edt2Exit
          OnKeyPress = edt2KeyPress
        end
        object edtCostCode2: TEdit
          Left = 464
          Top = 65
          Width = 91
          Height = 24
          Hint = 'The cost code from your practice management or billing system'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 10
          ParentFont = False
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
        BevelKind = bkFlat
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblAccount2: TLabel
          Left = 23
          Top = 68
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
        object lblNameOfAccount2: TLabel
          Left = 23
          Top = 13
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
      object pnlInstData3: TPanel
        Left = 145
        Top = 249
        Width = 615
        Height = 120
        BevelEdges = [beTop, beRight, beBottom]
        BevelKind = bkFlat
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 3
        DesignSize = (
          613
          116)
        object lblAccountHintLine3: TLabel
          Left = 6
          Top = 40
          Width = 558
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
          ExplicitWidth = 606
        end
        object lblClientCode3: TLabel
          Left = 375
          Top = 13
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
        object lblCostCode3: TLabel
          Left = 375
          Top = 68
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
        object lblMaskErrorHint3: TLabel
          Left = 6
          Top = 95
          Width = 608
          Height = 13
          AutoSize = False
          Caption = '<Mask Error Hint>'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clRed
          Font.Height = -13
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object edtNameOfAccount3: TEdit
          Left = 8
          Top = 10
          Width = 304
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
          OnEnter = edt3Exit
        end
        object mskAccountNumber3: TMaskValidateEdit
          Left = 8
          Top = 65
          Width = 304
          Height = 24
          Anchors = [akLeft, akTop, akRight]
          AutoSelect = False
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
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
          Width = 304
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
          TabOrder = 2
          OnChange = edtAccountNumber3Change
          OnExit = edtAccountNumber3Exit
        end
        object edtClientCode3: TEdit
          Left = 464
          Top = 10
          Width = 91
          Height = 24
          Hint = 'The client code from BankLink or your general ledger'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 8
          ParentFont = False
          TabOrder = 3
          OnExit = edt3Exit
          OnKeyPress = edt3KeyPress
        end
        object edtCostCode3: TEdit
          Left = 464
          Top = 65
          Width = 91
          Height = 24
          Hint = 'The cost code from your practice management or billing system'
          Anchors = [akLeft, akTop, akRight]
          CharCase = ecUpperCase
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          MaxLength = 10
          ParentFont = False
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
        BevelKind = bkFlat
        BevelOuter = bvNone
        BevelWidth = 2
        Color = clWhite
        ParentBackground = False
        TabOrder = 5
        object lblAccount3: TLabel
          Left = 23
          Top = 68
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
        object lblNameOfAccount3: TLabel
          Left = 23
          Top = 13
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
    end
    object pnlClient: TPanel
      Left = 3
      Top = 458
      Width = 757
      Height = 35
      BevelEdges = [beLeft, beTop, beRight]
      BevelKind = bkFlat
      BevelOuter = bvNone
      TabOrder = 2
      object pnlClientLabel: TPanel
        Left = 1
        Top = 5
        Width = 144
        Height = 28
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblStartDate: TLabel
          Left = 23
          Top = 3
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
        Top = 5
        Width = 273
        Height = 28
        Color = clWhite
        ParentBackground = False
        TabOrder = 1
        object edtClientStartDte: TOvcPictureField
          Left = 3
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
          TabOrder = 0
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
      end
      object pnlClientSpacer: TPanel
        Left = 409
        Top = 0
        Width = 344
        Height = 33
        Align = alRight
        Color = clWhite
        ParentBackground = False
        TabOrder = 2
      end
    end
  end
  object Opendlg: TOpenDialog
    Filter = 'Excel file*.xls|*.xls'
    Left = 728
    Top = 56
  end
end
