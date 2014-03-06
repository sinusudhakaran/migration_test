inherited frmPassword: TfrmPassword
  Left = 404
  Top = 311
  BorderStyle = bsDialog
  Caption = 'Password'
  ClientHeight = 236
  ClientWidth = 359
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  ExplicitWidth = 365
  ExplicitHeight = 268
  PixelsPerInch = 96
  TextHeight = 16
  object pnlPanel: TPanel
    Left = 0
    Top = 73
    Width = 359
    Height = 163
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      359
      163)
    object lblPassword: TLabel
      Left = 12
      Top = 53
      Width = 90
      Height = 16
      Alignment = taRightJustify
      Caption = '&New Password'
      FocusControl = rzPassword
    end
    object lblCase: TLabel
      Left = 12
      Top = 107
      Width = 298
      Height = 13
      Caption = '(Passwords are Case Sensitive and a maximum of 8 characters)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object lblMessage: TLabel
      Left = 12
      Top = 9
      Width = 337
      Height = 28
      AutoSize = False
      Caption = 'A password is required to open this file.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      WordWrap = True
    end
    object lblConfirm: TLabel
      Left = 12
      Top = 85
      Width = 108
      Height = 16
      Alignment = taRightJustify
      Caption = 'Con&firm Password'
      FocusControl = rzConfirm
    end
    object rzPassword: TRzEdit
      Left = 157
      Top = 48
      Width = 153
      Height = 25
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Wingdings'
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 0
    end
    object btnOK: TButton
      Left = 184
      Top = 134
      Width = 81
      Height = 25
      Cursor = crHandPoint
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 272
      Top = 134
      Width = 81
      Height = 25
      Cursor = crHandPoint
      Anchors = [akRight, akBottom]
      Caption = '&Cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 3
    end
    object rzConfirm: TRzEdit
      Left = 157
      Top = 80
      Width = 153
      Height = 25
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Wingdings'
      Font.Style = []
      MaxLength = 8
      ParentFont = False
      TabOrder = 1
    end
  end
  object pnlBack: TPanel
    Left = 0
    Top = 0
    Width = 359
    Height = 73
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    BevelEdges = []
    BevelOuter = bvNone
    Color = 10459904
    Ctl3D = False
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 1
    object imgBankLinkB: TImage
      Left = 0
      Top = -33
      Width = 200
      Height = 106
      Center = True
      Stretch = True
      Transparent = True
    end
  end
end
