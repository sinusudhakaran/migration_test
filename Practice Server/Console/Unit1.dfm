object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Practice Server Administrator'
  ClientHeight = 503
  ClientWidth = 1235
  Color = clBtnFace
  Constraints.MinHeight = 233
  Constraints.MinWidth = 343
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 745
    Top = 0
    Height = 484
    ExplicitLeft = 527
    ExplicitTop = 8
    ExplicitHeight = 608
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 484
    Width = 1235
    Height = 19
    Panels = <
      item
        Text = 'Disconnected'
        Width = 500
      end
      item
        Text = 'Queue Count: 0'
        Width = 150
      end
      item
        Text = 'Connection Count: 0'
        Width = 50
      end>
    ExplicitWidth = 1039
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 159
    Height = 484
    Align = alLeft
    TabOrder = 1
    object Label2: TLabel
      Left = 5
      Top = 31
      Width = 74
      Height = 13
      Caption = 'Discovery Port:'
    end
    object Label3: TLabel
      Left = 5
      Top = 58
      Width = 88
      Height = 13
      Caption = 'Statistics Interval:'
    end
    object Label1: TLabel
      Left = 37
      Top = 2
      Width = 75
      Height = 13
      Caption = 'Control Panel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnConnect: TButton
      Left = 37
      Top = 132
      Width = 75
      Height = 25
      Caption = 'Connect'
      TabOrder = 0
      OnClick = btnConnectClick
    end
    object chkStatistics: TCheckBox
      Left = 5
      Top = 82
      Width = 108
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Enable Statistics'
      TabOrder = 1
      OnClick = chkStatisticsClick
    end
    object chkEnableLogging: TCheckBox
      Left = 5
      Top = 106
      Width = 108
      Height = 17
      Alignment = taLeftJustify
      Caption = 'Enable Logging'
      Enabled = False
      TabOrder = 2
      OnClick = chkEnableLoggingClick
    end
    object edtStatsInterval: TEdit
      Left = 99
      Top = 55
      Width = 56
      Height = 21
      TabOrder = 3
      Text = '500'
    end
    object edtDiscoveryPort: TEdit
      Left = 99
      Top = 28
      Width = 56
      Height = 21
      TabOrder = 4
      Text = '4323'
    end
  end
  object Panel2: TPanel
    Left = 748
    Top = 0
    Width = 487
    Height = 484
    Align = alClient
    TabOrder = 2
    ExplicitLeft = 644
    ExplicitWidth = 395
    DesignSize = (
      487
      484)
    object Label5: TLabel
      Left = 202
      Top = 2
      Width = 86
      Height = 13
      Anchors = [akTop]
      Caption = 'Connection List'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitLeft = 156
    end
    object lvConnectionList: TListView
      Left = 5
      Top = 26
      Width = 476
      Height = 452
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Ip Address'
          Width = 100
        end
        item
          Caption = 'User Code'
          Width = 100
        end
        item
          Caption = 'Workstation Name'
          Width = 150
        end
        item
          Caption = 'Group Id'
          Width = 100
        end>
      RowSelect = True
      PopupMenu = PopupMenu2
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitWidth = 384
    end
  end
  object Panel3: TPanel
    Left = 159
    Top = 0
    Width = 586
    Height = 484
    Align = alLeft
    TabOrder = 3
    DesignSize = (
      586
      484)
    object Label4: TLabel
      Left = 251
      Top = 2
      Width = 65
      Height = 13
      Anchors = [akTop]
      Caption = 'Lock Queue'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitLeft = 201
    end
    object lvLockQueue: TListView
      Left = 4
      Top = 26
      Width = 576
      Height = 452
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          Caption = 'Ip Address'
          Width = 100
        end
        item
          Caption = 'Group Id'
          Width = 100
        end
        item
          Caption = 'Lock Type'
          Width = 100
        end
        item
          Caption = 'Status'
          Width = 100
        end
        item
          Caption = 'Time waiting (milliseconds)'
          Width = 150
        end>
      RowSelect = True
      PopupMenu = PopupMenu1
      TabOrder = 0
      ViewStyle = vsReport
      ExplicitWidth = 472
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = Timer1Timer
    Left = 32
    Top = 244
  end
  object MainMenu1: TMainMenu
    Left = 64
    Top = 240
    object ools1: TMenuItem
      Caption = 'Tools'
      object Disconnectionallusers1: TMenuItem
        Caption = 'Disconnection all users'
        OnClick = Disconnectionallusers1Click
      end
      object Releaseallheldlocks1: TMenuItem
        Caption = 'Release all held locks'
        OnClick = Releaseallheldlocks1Click
      end
      object Clearlockqueue1: TMenuItem
        Caption = 'Clear the lock queue'
        OnClick = Clearlockqueue1Click
      end
      object Disconnectselecteduser1: TMenuItem
        Caption = 'Disconnect selected user'
        OnClick = Disconnectselecteduser1Click
      end
      object Removeselectedlock1: TMenuItem
        Caption = 'Remove selected lock'
        OnClick = Removeselectedlock1Click
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 88
    Top = 296
    object RemoveLock1: TMenuItem
      Caption = 'Remove selected lock'
      OnClick = RemoveLock1Click
    end
  end
  object PopupMenu2: TPopupMenu
    Left = 88
    Top = 336
    object Disconnectselecteduser2: TMenuItem
      Caption = 'Disconnect selected user'
      OnClick = Disconnectselecteduser2Click
    end
  end
end
