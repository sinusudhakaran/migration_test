inherited frmMailSettings: TfrmMailSettings
  Scaled = False
Left = 336
  Top = 195
  Caption = 'Mail Settings'
  ClientHeight = 396
  ClientWidth = 572
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  ExplicitWidth = 588
  ExplicitHeight = 432
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 12
    Top = 8
    Width = 205
    Height = 16
    Caption = 'Select a method for sending email:'
  end
  object rbMAPI: TRadioButton
    Left = 12
    Top = 32
    Width = 177
    Height = 17
    Caption = 'Microsoft'#174' Outlook'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbMAPIClick
  end
  object rbSMTP: TRadioButton
    Left = 192
    Top = 32
    Width = 177
    Height = 17
    Caption = 'Use this application'
    TabOrder = 1
    OnClick = rbMAPIClick
  end
  object pnlSMTPUserInfo: TPanel
    Left = 8
    Top = 56
    Width = 553
    Height = 101
    TabOrder = 2
    object Label2: TLabel
      Left = 4
      Top = 4
      Width = 97
      Height = 16
      Caption = 'User Information'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 16
      Top = 36
      Width = 37
      Height = 16
      Caption = 'Name'
    end
    object Label4: TLabel
      Left = 16
      Top = 68
      Width = 91
      Height = 16
      Caption = 'E-mail address'
    end
    object rzName: TRzEdit
      Left = 160
      Top = 32
      Width = 281
      Height = 24
      TabOrder = 0
    end
    object rzAddress: TRzEdit
      Left = 160
      Top = 64
      Width = 281
      Height = 24
      TabOrder = 1
    end
  end
  object pnlSMTPServerInfo: TPanel
    Left = 8
    Top = 164
    Width = 553
    Height = 197
    TabOrder = 3
    DesignSize = (
      553
      197)
    object Label12: TLabel
      Left = 4
      Top = 4
      Width = 108
      Height = 16
      Caption = 'Server Information'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Label13: TLabel
      Left = 16
      Top = 40
      Width = 131
      Height = 16
      Caption = 'Outgoing mail (SMTP)'
    end
    object lblUser: TLabel
      Left = 16
      Top = 132
      Width = 85
      Height = 16
      Caption = 'Account name'
    end
    object lblPassword: TLabel
      Left = 16
      Top = 164
      Width = 60
      Height = 16
      Caption = 'Password'
    end
    object Label5: TLabel
      Left = 448
      Top = 40
      Width = 24
      Height = 16
      Caption = 'Port'
    end
    object Label6: TLabel
      Left = 16
      Top = 72
      Width = 101
      Height = 16
      Caption = 'Connect Timeout'
    end
    object Label7: TLabel
      Left = 237
      Top = 71
      Width = 25
      Height = 16
      Caption = 'sec.'
    end
    object chkAuthReq: TCheckBox
      Left = 160
      Top = 104
      Width = 241
      Height = 17
      Caption = 'My server requires authentication'
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 3
      OnClick = chkAuthReqClick
    end
    object rzsmtp: TRzEdit
      Left = 160
      Top = 36
      Width = 281
      Height = 24
      TabOrder = 0
    end
    object rzuserId: TRzEdit
      Left = 160
      Top = 128
      Width = 281
      Height = 24
      TabOrder = 4
    end
    object rzPassword: TRzEdit
      Left = 160
      Top = 160
      Width = 281
      Height = 24
      PasswordChar = '*'
      TabOrder = 5
    end
    object rnSMTPPort: TRzNumericEdit
      Left = 480
      Top = 36
      Width = 50
      Height = 24
      Anchors = [akTop, akRight]
      TabOrder = 1
      Value = 25.000000000000000000
      DisplayFormat = '0;(0)'
    end
    object rnTimeout: TRzNumericEdit
      Left = 160
      Top = 68
      Width = 73
      Height = 24
      Anchors = [akTop, akRight]
      TabOrder = 2
      Value = 60.000000000000000000
      DisplayFormat = '0;(0)'
    end
  end
  object btnCancel: TButton
    Left = 483
    Top = 366
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
    TabOrder = 5
  end
  object btnOK: TButton
    Left = 395
    Top = 366
    Width = 81
    Height = 25
    Cursor = crHandPoint
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 4
  end
end
