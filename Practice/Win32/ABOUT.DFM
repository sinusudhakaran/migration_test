object frmAbout: TfrmAbout
  Left = 545
  Top = 271
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'About'
  ClientHeight = 448
  ClientWidth = 592
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlDetails: TPanel
    Left = 209
    Top = 0
    Width = 383
    Height = 448
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      383
      448)
    object lblTitle: TLabel
      Left = 15
      Top = 3
      Width = 338
      Height = 45
      AutoSize = False
      Caption = 'Application Title'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      ShowAccelChar = False
      Transparent = True
      WordWrap = True
    end
    object lblCopyright: TLabel
      Left = 16
      Top = 56
      Width = 121
      Height = 13
      Caption = 'Copyright (c) 1998, 2002'
      ShowAccelChar = False
      Transparent = True
    end
    object lblCountry: TLabel
      Left = 364
      Top = 0
      Width = 13
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'NZ'
      ShowAccelChar = False
    end
    object lblVersion: TLabel
      Left = 16
      Top = 75
      Width = 118
      Height = 13
      Caption = 'Version 5.2.0 (Build 123)'
      ShowAccelChar = False
    end
    object lblWinVer: TLabel
      Left = 16
      Top = 94
      Width = 70
      Height = 13
      Caption = 'Windows 2000'
      ShowAccelChar = False
    end
    object DebugLabel: TLabel
      Left = 15
      Top = 422
      Width = 3
      Height = 13
    end
    object lblUser: TLabel
      Left = 16
      Top = 298
      Width = 137
      Height = 13
      Caption = 'User Code: WWWWWWWW'
      ShowAccelChar = False
      Transparent = True
    end
    object lblCode: TLabel
      Left = 16
      Top = 318
      Width = 172
      Height = 16
      AutoSize = False
      Caption = 'Practice Code: WWWWWWWW'
      ShowAccelChar = False
    end
    object lblDir: TLabel
      Left = 16
      Top = 338
      Width = 356
      Height = 48
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'BankLink Folder:'
      ParentShowHint = False
      ShowAccelChar = False
      ShowHint = True
      Transparent = True
      WordWrap = True
    end
    object lblServer: TLabel
      Left = 15
      Top = 392
      Width = 361
      Height = 16
      AutoSize = False
      Caption = 'Update Server:'
      ShowAccelChar = False
    end
    object btnClose: TButton
      Left = 292
      Top = 417
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      Default = True
      TabOrder = 0
      OnClick = btnCloseClick
    end
    object Panel1: TPanel
      Left = 16
      Top = 113
      Width = 351
      Height = 170
      BevelOuter = bvNone
      BorderWidth = 1
      BorderStyle = bsSingle
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 1
      object lblForSupport: TLabel
        Left = 13
        Top = 15
        Width = 103
        Height = 13
        Caption = 'For support, contact:'
        ShowAccelChar = False
        Transparent = True
      end
      object lblCountry1: TLabel
        Left = 20
        Top = 40
        Width = 45
        Height = 13
        Caption = 'Country1'
        ShowAccelChar = False
        Transparent = True
      end
      object lblPh1: TLabel
        Left = 20
        Top = 59
        Width = 28
        Height = 13
        Caption = 'lblPh1'
      end
      object lblCountry2: TLabel
        Left = 20
        Top = 81
        Width = 45
        Height = 13
        Caption = 'Country2'
        ShowAccelChar = False
        Transparent = True
      end
      object lblPh2: TLabel
        Left = 20
        Top = 100
        Width = 28
        Height = 13
        Caption = 'lblPh2'
      end
      object lblEmailTo: TLabel
        Left = 61
        Top = 127
        Width = 97
        Height = 13
        Cursor = crHandPoint
        Caption = 'mailto:Email address'
        ShowAccelChar = False
        Transparent = True
        OnClick = lblEmailToClick
      end
      object lblWebPage: TLabel
        Left = 20
        Top = 146
        Width = 85
        Height = 13
        Cursor = crHandPoint
        Caption = 'http:WebAddress'
        ShowAccelChar = False
        Transparent = True
        OnClick = lblWebPageClick
      end
      object lblEmail: TLabel
        Left = 20
        Top = 127
        Width = 28
        Height = 13
        Caption = 'Email:'
      end
    end
    object btnEULA2: TButton
      Left = 184
      Top = 417
      Width = 96
      Height = 25
      Anchors = [akTop]
      Caption = 'View Licence'
      TabOrder = 2
      Visible = False
      OnClick = btnEULAClick
    end
  end
  object pnlGraphic: TPanel
    Left = 0
    Top = 0
    Width = 209
    Height = 448
    Align = alLeft
    BevelOuter = bvNone
    Color = clTeal
    ParentBackground = False
    TabOrder = 1
    object imgAbout: TImage
      Left = 7
      Top = 17
      Width = 196
      Height = 255
      Center = True
      Proportional = True
      Stretch = True
    end
    object btnEULA: TButton
      Left = 56
      Top = 417
      Width = 96
      Height = 25
      Caption = 'View Licence'
      TabOrder = 0
      OnClick = btnEULAClick
    end
  end
end
