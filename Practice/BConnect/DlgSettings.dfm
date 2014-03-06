object dlgSettings: TdlgSettings
  Scaled = False
Left = 319
  Top = 102
  BorderIcons = [biSystemMenu, biHelp]
  BorderStyle = bsDialog
  Caption = 'Settings'
  ClientHeight = 421
  ClientWidth = 442
  Color = clBtnFace
  Constraints.MaxWidth = 450
  Constraints.MinWidth = 448
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object dbtnButtons: TRzDialogButtons
    Left = 0
    Top = 385
    Width = 442
    CaptionOk = 'OK'
    CaptionCancel = 'Cancel'
    CaptionHelp = '&Help'
    EnableHelp = False
    ModalResultOk = 1
    ModalResultCancel = 2
    ModalResultHelp = 0
    OnClickOk = dbtnButtonsClickOk
    OnClickCancel = dbtnButtonsClickCancel
    ParentShowHint = False
    ShowHint = False
    TabOrder = 2
  end
  object pnlAdvanced: TRzPanel
    Left = 0
    Top = 125
    Width = 442
    Height = 260
    Align = alClient
    BorderOuter = fsNone
    BorderWidth = 3
    TabOrder = 1
    Visible = False
    object gbAdvancedSettings: TGroupBox
      Left = 3
      Top = 3
      Width = 436
      Height = 254
      Align = alClient
      Caption = ' Advanced Settings '
      TabOrder = 0
      object RzPanel1: TRzPanel
        Left = 2
        Top = 15
        Width = 432
        Height = 22
        Align = alTop
        BorderOuter = fsNone
        TabOrder = 0
        object chkUseWinINet: TCheckBox
          Left = 8
          Top = 1
          Width = 393
          Height = 17
          Caption = 'Use Microsoft Windows Internet Settings'
          TabOrder = 0
          OnClick = chkUseWinINetClick
        end
      end
      object pcAdvancedSettings: TPageControl
        Left = 2
        Top = 37
        Width = 432
        Height = 215
        ActivePage = tshtProxySettings
        Align = alClient
        TabOrder = 1
        object tshtProxySettings: TTabSheet
          Caption = 'Proxy Settings'
          DesignSize = (
            424
            187)
          object lblProxyPort: TLabel
            Left = 310
            Top = 40
            Width = 20
            Height = 13
            Anchors = [akTop, akRight]
            Caption = 'Port'
          end
          object lblProxyHost: TLabel
            Left = 24
            Top = 40
            Width = 57
            Height = 13
            Caption = 'Proxy Host:'
          end
          object lblProxyAuthMethod: TLabel
            Left = 24
            Top = 74
            Width = 113
            Height = 13
            Caption = 'Authentication Method:'
          end
          object lblProxyUserName: TLabel
            Left = 64
            Top = 108
            Width = 83
            Height = 13
            Caption = 'Proxy Username:'
            Enabled = False
          end
          object lblProxyPassword: TLabel
            Left = 64
            Top = 140
            Width = 81
            Height = 13
            Caption = 'Proxy Password:'
            Enabled = False
          end
          object chkUseProxy: TCheckBox
            Left = 8
            Top = 6
            Width = 185
            Height = 17
            Caption = 'Use a proxy server'
            TabOrder = 0
            OnClick = chkUseProxyClick
          end
          object rbtnDetect: TRzButton
            Left = 308
            Top = 4
            Width = 89
            Height = 24
            Anchors = [akTop, akRight]
            Caption = 'Auto Detect'
            HotTrack = True
            TabOrder = 1
            OnClick = rbtnDetectClick
          end
          object rnProxyPort: TRzNumericEdit
            Left = 346
            Top = 36
            Width = 50
            Height = 21
            Anchors = [akTop, akRight]
            FrameController = RzFrameController1
            TabOrder = 3
            Value = 80.000000000000000000
            DisplayFormat = '0;(0)'
          end
          object reProxyHost: TRzEdit
            Left = 112
            Top = 36
            Width = 179
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            FrameController = RzFrameController1
            TabOrder = 2
          end
          object cboProxyAuthMethod: TRzComboBox
            Left = 168
            Top = 70
            Width = 177
            Height = 21
            Style = csDropDownList
            Ctl3D = False
            Enabled = False
            FrameController = RzFrameController1
            ItemHeight = 13
            ParentCtl3D = False
            TabOrder = 4
            Text = 'None'
            OnChange = cboProxyAuthMethodChange
            Items.Strings = (
              'None'
              'Basic'
              'NTLM')
            ItemIndex = 0
          end
          object reProxyUserName: TRzEdit
            Left = 200
            Top = 104
            Width = 145
            Height = 21
            Enabled = False
            FrameController = RzFrameController1
            TabOrder = 5
          end
          object reProxyPassword: TRzEdit
            Left = 200
            Top = 136
            Width = 145
            Height = 21
            Enabled = False
            FrameController = RzFrameController1
            MaxLength = 16
            PasswordChar = '*'
            TabOrder = 6
          end
        end
        object tshtFirewallSettings: TTabSheet
          Caption = 'Firewall Settings'
          ImageIndex = 1
          DesignSize = (
            424
            187)
          object lblFirewallType: TLabel
            Left = 24
            Top = 63
            Width = 67
            Height = 13
            Caption = 'Firewall Type:'
            Enabled = False
          end
          object lblFirewallUserName: TLabel
            Left = 64
            Top = 119
            Width = 91
            Height = 13
            Caption = 'Firewall Username:'
            Enabled = False
          end
          object lblFirewallPassword: TLabel
            Left = 64
            Top = 147
            Width = 89
            Height = 13
            Caption = 'Firewall Password:'
            Enabled = False
          end
          object lblFirewallHost: TLabel
            Left = 24
            Top = 33
            Width = 65
            Height = 13
            Caption = 'Firewall Host:'
          end
          object lblFirewallPort: TLabel
            Left = 314
            Top = 33
            Width = 20
            Height = 13
            Anchors = [akTop, akRight]
            Caption = 'Port'
          end
          object cboFirewallType: TRzComboBox
            Left = 117
            Top = 59
            Width = 189
            Height = 21
            Style = csDropDownList
            Ctl3D = False
            Enabled = False
            FrameController = RzFrameController1
            ItemHeight = 13
            ParentCtl3D = False
            TabOrder = 3
            OnChange = cboFirewallTypeChange
            Items.Strings = (
              'CERN HTTP'
              'Socks Version 4.0'
              'Socks Version 5.0'
              'Tunnel')
          end
          object chkUseFirewallAuthentication: TCheckBox
            Left = 24
            Top = 96
            Width = 225
            Height = 17
            Caption = 'Firewall Requires Authentication'
            Enabled = False
            TabOrder = 4
            OnClick = chkUseFirewallAuthenticationClick
          end
          object reFirewallUsername: TRzEdit
            Left = 198
            Top = 115
            Width = 147
            Height = 21
            Enabled = False
            FrameController = RzFrameController1
            TabOrder = 5
          end
          object reFirewallPassword: TRzEdit
            Left = 198
            Top = 143
            Width = 147
            Height = 21
            Enabled = False
            FrameController = RzFrameController1
            PasswordChar = '*'
            TabOrder = 6
          end
          object chkUseFirewall: TCheckBox
            Left = 8
            Top = 6
            Width = 185
            Height = 17
            Caption = 'Use a firewall'
            TabOrder = 0
            OnClick = chkUseFirewallClick
          end
          object reFirewallHost: TRzEdit
            Left = 117
            Top = 29
            Width = 189
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            FrameController = RzFrameController1
            TabOrder = 1
          end
          object rnFirewallPort: TRzNumericEdit
            Left = 346
            Top = 29
            Width = 50
            Height = 21
            Anchors = [akTop, akRight]
            FrameController = RzFrameController1
            TabOrder = 2
            Value = 80.000000000000000000
            DisplayFormat = '0;(0)'
          end
        end
      end
    end
  end
  object pnlBasic: TRzPanel
    Left = 0
    Top = 0
    Width = 442
    Height = 125
    Align = alTop
    BorderOuter = fsNone
    BorderWidth = 3
    TabOrder = 0
    object gbPrimaryServer: TGroupBox
      Left = 3
      Top = 3
      Width = 436
      Height = 119
      Align = alClient
      Caption = ' Settings '
      TabOrder = 0
      DesignSize = (
        436
        119)
      object lblPrimaryHost: TLabel
        Left = 16
        Top = 24
        Width = 65
        Height = 13
        Caption = 'Primary Host:'
      end
      object lblPrimaryPort: TLabel
        Left = 329
        Top = 28
        Width = 24
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Port:'
      end
      object lblSecondaryPort: TLabel
        Left = 329
        Top = 56
        Width = 24
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Port:'
      end
      object lblSecondaryHost: TLabel
        Left = 16
        Top = 56
        Width = 80
        Height = 13
        Caption = 'Secondary Host:'
      end
      object lblTimeout: TLabel
        Left = 16
        Top = 84
        Width = 42
        Height = 13
        Caption = 'Timeout:'
      end
      object rePrimaryHost: TRzEdit
        Left = 120
        Top = 24
        Width = 194
        Height = 21
        Text = 'www.banklink.co.nz'
        Anchors = [akLeft, akTop, akRight]
        FrameController = RzFrameController1
        TabOrder = 0
      end
      object rnPrimaryPort: TRzNumericEdit
        Left = 364
        Top = 24
        Width = 50
        Height = 21
        Anchors = [akTop, akRight]
        FrameController = RzFrameController1
        TabOrder = 1
        Value = 80.000000000000000000
        DisplayFormat = '0;(0)'
      end
      object rnSecondaryPort: TRzNumericEdit
        Left = 364
        Top = 52
        Width = 50
        Height = 21
        Anchors = [akTop, akRight]
        FrameController = RzFrameController1
        TabOrder = 3
        Value = 80.000000000000000000
        DisplayFormat = '0;(0)'
      end
      object reSecondaryHost: TRzEdit
        Left = 120
        Top = 52
        Width = 194
        Height = 21
        Text = 'www.banklink.co.nz'
        Anchors = [akLeft, akTop, akRight]
        FrameController = RzFrameController1
        TabOrder = 2
      end
      object rnTimeout: TRzNumericEdit
        Left = 120
        Top = 80
        Width = 65
        Height = 21
        FrameController = RzFrameController1
        TabOrder = 4
        DisplayFormat = ',0;(,0)'
      end
      object chkUseCustomConfiguration: TCheckBox
        Left = 192
        Top = 84
        Width = 217
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Use Advanced Internet Settings'
        TabOrder = 5
        OnClick = chkUseCustomConfigurationClick
      end
    end
  end
  object RzFrameController1: TRzFrameController
    FrameHotStyle = fsLowered
    FrameHotTrack = True
    FrameStyle = fsStatus
    FrameVisible = True
    Left = 8
    Top = 392
  end
end
