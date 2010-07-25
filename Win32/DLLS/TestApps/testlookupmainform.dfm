object Form1: TForm1
  Left = 421
  Top = 153
  BorderStyle = bsDialog
  Caption = 'Test Application for  bkLookup DLL'
  ClientHeight = 375
  ClientWidth = 487
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnShow = FormShow
  DesignSize = (
    487
    375)
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 24
    Top = 32
    Width = 62
    Height = 13
    Caption = 'Default Code'
  end
  object btnTestLookup: TButton
    Left = 344
    Top = 32
    Width = 129
    Height = 25
    Caption = 'Test 1. Lookup Code'
    Default = True
    TabOrder = 1
    OnClick = btnTestLookupClick
  end
  object Edit1: TEdit
    Left = 120
    Top = 32
    Width = 209
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object btnRetrieveList: TButton
    Left = 344
    Top = 80
    Width = 129
    Height = 25
    Caption = 'Test 2. Retrieve List'
    TabOrder = 2
    OnClick = btnRetrieveListClick
  end
  object btnSetDBLocation: TButton
    Left = 344
    Top = 128
    Width = 129
    Height = 25
    Caption = 'Test 3. Set DB Location'
    TabOrder = 3
    OnClick = btnSetDBLocationClick
  end
  object Button4: TButton
    Left = 390
    Top = 343
    Width = 89
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    TabOrder = 5
    OnClick = Button4Click
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 184
    Width = 465
    Height = 121
    Caption = 'Directories'
    TabOrder = 4
    object Label1: TLabel
      Left = 8
      Top = 28
      Width = 64
      Height = 13
      Caption = 'DLL Location'
    end
    object Label2: TLabel
      Left = 8
      Top = 68
      Width = 92
      Height = 13
      Caption = 'System.DB location'
    end
    object txtDll_Location: TEdit
      Left = 112
      Top = 28
      Width = 347
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = 'c:\localcode\bk5\build\bklookup.dll'
    end
    object txtDBLocation: TEdit
      Left = 112
      Top = 68
      Width = 347
      Height = 21
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Text = 'c:\localcode\bk5\build\'
    end
  end
end
