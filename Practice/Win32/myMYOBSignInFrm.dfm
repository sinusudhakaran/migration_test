object myMYOBSignInForm: TmyMYOBSignInForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'MYOB Login'
  ClientHeight = 219
  ClientWidth = 509
  Color = clWindow
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlLogin: TPanel
    Left = 0
    Top = 0
    Width = 509
    Height = 106
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    DesignSize = (
      509
      106)
    object lblEmail: TLabel
      Left = 24
      Top = 13
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
      Top = 47
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
    object lblForgotPassword: TLabel
      Left = 24
      Top = 78
      Width = 131
      Height = 16
      Caption = 'Forgot your password?'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = lblForgotPasswordClick
    end
    object edtEmail: TEdit
      Left = 128
      Top = 10
      Width = 363
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object edtPassword: TEdit
      Left = 128
      Top = 44
      Width = 363
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
    object btnSignIn: TButton
      Left = 416
      Top = 75
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Login'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnSignInClick
    end
  end
  object pnlClientSelection: TPanel
    Left = 0
    Top = 106
    Width = 509
    Height = 65
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 3
    Visible = False
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 509
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitLeft = 24
      ExplicitTop = 24
      ExplicitWidth = 65
    end
    object Label1: TLabel
      Left = 24
      Top = 21
      Width = 82
      Height = 16
      AutoSize = False
      Caption = 'Select client'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object cmbSelectClient: TComboBox
      Left = 128
      Top = 18
      Width = 363
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
    end
  end
  object pnlControls: TPanel
    Left = 0
    Top = 171
    Width = 509
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 2
    DesignSize = (
      509
      48)
    object Shape2: TShape
      Left = 0
      Top = 0
      Width = 509
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitLeft = 24
      ExplicitTop = 24
      ExplicitWidth = 65
    end
    object btnOK: TButton
      Left = 335
      Top = 13
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      TabOrder = 0
      Visible = False
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 416
      Top = 13
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object pnlFirmSelection: TPanel
    Left = 0
    Top = 106
    Width = 509
    Height = 65
    Align = alClient
    BevelOuter = bvNone
    Caption = ' '
    ParentColor = True
    TabOrder = 1
    Visible = False
    object Label6: TLabel
      Left = 24
      Top = 24
      Width = 82
      Height = 16
      AutoSize = False
      Caption = 'Select firm'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 509
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitLeft = 24
      ExplicitTop = 24
      ExplicitWidth = 65
    end
    object cmbSelectFirm: TComboBox
      Left = 128
      Top = 21
      Width = 363
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
      OnEnter = cmbSelectFirmEnter
    end
  end
end
