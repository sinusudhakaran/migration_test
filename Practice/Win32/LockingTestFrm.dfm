object TestLockingFrm: TTestLockingFrm
  Scaled = False
Left = 404
  Top = 70
  AutoScroll = False
  Caption = 'Application Locking Test Utility'
  ClientHeight = 464
  ClientWidth = 512
  Color = clBtnFace
  Constraints.MinHeight = 350
  Constraints.MinWidth = 520
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    512
    464)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 48
    Width = 140
    Height = 13
    Caption = 'Time between calls (ms)'
  end
  object Label4: TLabel
    Left = 45
    Top = 100
    Width = 147
    Height = 13
    Caption = 'Hold admin open for (ms)'
  end
  object Label5: TLabel
    Left = 16
    Top = 8
    Width = 322
    Height = 25
    Caption = 'BK5 Application Test Utility'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Verdana'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label6: TLabel
    Left = 45
    Top = 122
    Width = 137
    Height = 13
    Caption = 'Time to wait for lock (s)'
  end
  object lblVersion: TLabel
    Left = 448
    Top = 16
    Width = 56
    Height = 13
    Alignment = taRightJustify
    Caption = 'lblVersion'
  end
  object lblUsing: TLabel
    Left = 16
    Top = 410
    Width = 36
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Using:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clGrayText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
  end
  object Label10: TLabel
    Left = 45
    Top = 236
    Width = 129
    Height = 13
    Caption = 'Hold file open for (ms)'
  end
  object Label11: TLabel
    Left = 288
    Top = 216
    Width = 31
    Height = 13
    Caption = 'User:'
  end
  object lblUser: TLabel
    Left = 408
    Top = 216
    Width = 65
    Height = 13
    Caption = 'Logged Out'
  end
  object SpeedButton1: TSpeedButton
    Left = 248
    Top = 200
    Width = 23
    Height = 22
    Glyph.Data = {
      4E010000424D4E01000000000000760000002800000012000000120000000100
      040000000000D800000000000000000000001000000010000000000000000000
      BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
      DDDDDD000000DDDDDDDDDDDDDDDDDD000000D000000000000DD00D000000D0FF
      FFFFFFFF0D000D000000D0FFFFFFF0000800DD000000D0FFFFFF0877808DDD00
      0000D0FFFFF0877E880DDD000000D0FFFFF07777870DDD000000D0FFFFF07E77
      870DDD000000D0FFFFF08EE7880DDD000000D0FFFFFF087780DDDD000000D0FF
      FFFFF0000DDDDD000000D0FFFFFFFFFF0DDDDD000000D0FFFFFFF0000DDDDD00
      0000D0FFFFFFF070DDDDDD000000D0FFFFFFF00DDDDDDD000000DD00000000DD
      DDDDDD000000DDDDDDDDDDDDDDDDDD000000}
    OnClick = SpeedButton1Click
  end
  object Edit1: TEdit
    Left = 176
    Top = 48
    Width = 73
    Height = 21
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
    Text = '100'
  end
  object Edit2: TEdit
    Left = 200
    Top = 95
    Width = 49
    Height = 21
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 1
    Text = '50'
  end
  object Panel1: TPanel
    Left = 280
    Top = 48
    Width = 225
    Height = 161
    Anchors = [akTop, akRight]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Color = clWindow
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    object Label2: TLabel
      Left = 8
      Top = 8
      Width = 61
      Height = 16
      Caption = 'Attempts'
      Transparent = True
    end
    object lblAttempts: TLabel
      Left = 152
      Top = 8
      Width = 8
      Height = 16
      Caption = '0'
      Transparent = True
    end
    object Label3: TLabel
      Left = 9
      Top = 66
      Width = 101
      Height = 16
      Caption = 'Avg Lock Time '
      Transparent = True
    end
    object lblErrors: TLabel
      Left = 152
      Top = 37
      Width = 8
      Height = 16
      Caption = '0'
      Transparent = True
    end
    object Label7: TLabel
      Left = 9
      Top = 39
      Width = 38
      Height = 16
      Caption = 'Errors'
      Transparent = True
    end
    object lblAvg: TLabel
      Left = 152
      Top = 66
      Width = 28
      Height = 16
      Caption = '0.0s'
      Transparent = True
    end
    object Label8: TLabel
      Left = 9
      Top = 93
      Width = 104
      Height = 16
      Caption = 'Last Lock Time '
      Transparent = True
    end
    object lblLast: TLabel
      Left = 152
      Top = 93
      Width = 28
      Height = 16
      Caption = '0.0s'
      Transparent = True
    end
    object Label9: TLabel
      Left = 8
      Top = 120
      Width = 50
      Height = 16
      Caption = 'Elapsed'
    end
    object lblTime: TLabel
      Left = 152
      Top = 120
      Width = 28
      Height = 16
      Caption = '0.0s'
    end
    object chkRefresh: TCheckBox
      Left = 116
      Top = 143
      Width = 97
      Height = 13
      Caption = 'Refresh Stats'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'Verdana'
      Font.Style = []
      ParentFont = False
      State = cbChecked
      TabOrder = 0
    end
  end
  object edtWait: TEdit
    Left = 200
    Top = 123
    Width = 49
    Height = 21
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 3
    Text = '30'
  end
  object Panel2: TPanel
    Left = 0
    Top = 425
    Width = 512
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 4
    DesignSize = (
      512
      39)
    object btnStart: TButton
      Left = 8
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Start'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnStartClick
    end
    object btnStop: TButton
      Left = 88
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Stop'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnStopClick
    end
    object btnClose: TButton
      Left = 428
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnCloseClick
    end
    object btnTerminate: TRzButton
      Left = 337
      Top = 8
      Width = 81
      Anchors = [akRight, akBottom]
      Caption = 'Terminate'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 3
      OnClick = btnTerminateClick
    end
    object btnViewLog: TButton
      Left = 170
      Top = 6
      Width = 75
      Height = 25
      Caption = 'View Log'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 4
      OnClick = btnViewLogClick
    end
  end
  object chkCaptureExceptions: TCheckBox
    Left = 320
    Top = 265
    Width = 185
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Capture Exceptions'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object Memo1: TMemo
    Left = 8
    Top = 284
    Width = 497
    Height = 123
    Anchors = [akLeft, akTop, akRight, akBottom]
    Ctl3D = False
    ParentCtl3D = False
    ScrollBars = ssBoth
    TabOrder = 6
  end
  object chkSaveAdmin: TCheckBox
    Left = 46
    Top = 152
    Width = 203
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Force Save of admin system'
    TabOrder = 7
  end
  object edtFileCode: TEdit
    Left = 144
    Top = 200
    Width = 105
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 8
  end
  object chkFileSave: TCheckBox
    Left = 51
    Top = 260
    Width = 198
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Force Save'
    TabOrder = 9
  end
  object rbFileAccess: TRadioButton
    Left = 16
    Top = 200
    Width = 121
    Height = 17
    Caption = 'Test Client Files'
    TabOrder = 10
  end
  object rbLog: TRadioButton
    Left = 16
    Top = 176
    Width = 113
    Height = 17
    Caption = 'Test Log File'
    TabOrder = 11
  end
  object rbAdmin: TRadioButton
    Left = 16
    Top = 80
    Width = 161
    Height = 17
    Caption = 'Test Admin System'
    Checked = True
    TabOrder = 12
    TabStop = True
  end
  object Edit3: TEdit
    Left = 200
    Top = 231
    Width = 49
    Height = 21
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 13
    Text = '0'
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 176
    Top = 408
  end
  object Timer2: TTimer
    OnTimer = Timer2Timer
    Left = 208
    Top = 408
  end
end
