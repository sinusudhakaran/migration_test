object FileTestForm: TFileTestForm
  Scaled = False
Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Client-File Tester'
  ClientHeight = 286
  ClientWidth = 392
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 392
    Height = 105
    Align = alTop
    TabOrder = 0
    ExplicitTop = 8
    ExplicitWidth = 431
    DesignSize = (
      392
      105)
    object Label1: TLabel
      Left = 16
      Top = 48
      Width = 37
      Height = 13
      Caption = 'Tested:'
    end
    object Label2: TLabel
      Left = 21
      Top = 67
      Width = 32
      Height = 13
      Caption = 'Failed:'
    end
    object Label3: TLabel
      Left = 15
      Top = 86
      Width = 38
      Height = 13
      Caption = 'Passed:'
    end
    object lblTested: TLabel
      Left = 59
      Top = 48
      Width = 100
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '9999999999'
      Color = clWindow
      ParentColor = False
    end
    object lblFailed: TLabel
      Left = 59
      Top = 67
      Width = 100
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '9999999999'
      Color = clWindow
      ParentColor = False
    end
    object lblPassed: TLabel
      Left = 59
      Top = 86
      Width = 100
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '9999999999'
      Color = clWindow
      ParentColor = False
    end
    object Label4: TLabel
      Left = 14
      Top = 29
      Width = 39
      Height = 13
      Caption = 'Testing:'
    end
    object lblTesting: TLabel
      Left = 59
      Top = 29
      Width = 4
      Height = 13
      Caption = '-'
      Color = clWindow
      ParentColor = False
    end
    object Label5: TLabel
      Left = 23
      Top = 10
      Width = 30
      Height = 13
      Caption = 'Mode:'
    end
    object lblMode: TLabel
      Left = 59
      Top = 10
      Width = 4
      Height = 13
      Caption = '-'
      Color = clWindow
      ParentColor = False
    end
    object cbFailed: TCheckBox
      Left = 165
      Top = 63
      Width = 97
      Height = 17
      Caption = 'Log each Failure'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbPassed: TCheckBox
      Left = 165
      Top = 82
      Width = 97
      Height = 17
      Caption = 'Log each Pass'
      TabOrder = 1
    end
    object btnClear: TButton
      Left = 302
      Top = 43
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Clear'
      TabOrder = 2
      OnClick = btnClearClick
    end
    object btnClearList: TButton
      Left = 302
      Top = 74
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Clear List'
      TabOrder = 3
      OnClick = btnClearListClick
      ExplicitLeft = 341
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 248
    Width = 392
    Height = 38
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      392
      38)
    object btnOnce: TButton
      Left = 16
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Test Once'
      TabOrder = 0
      OnClick = btnOnceClick
    end
    object btnCont: TButton
      Left = 97
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Continuous'
      TabOrder = 1
      OnClick = btnContClick
    end
    object Button3: TButton
      Left = 302
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Stop'
      TabOrder = 2
      OnClick = Button3Click
      ExplicitLeft = 336
    end
  end
  object lbStatus: TListBox
    Left = 0
    Top = 105
    Width = 392
    Height = 143
    Align = alClient
    ItemHeight = 13
    TabOrder = 2
  end
  object TestTimer: TTimer
    OnTimer = TestTimerTimer
    Left = 128
  end
end
