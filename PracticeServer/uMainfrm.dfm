object frmServer: TfrmServer
  Left = 0
  Top = 0
  Caption = 'Practice Server'
  ClientHeight = 437
  ClientWidth = 614
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 24
    Top = 32
    Width = 56
    Height = 13
    Caption = 'Root Folder'
  end
  object Label1: TLabel
    Left = 24
    Top = 62
    Width = 56
    Height = 13
    Caption = 'Default Doc'
  end
  object Label3: TLabel
    Left = 24
    Top = 86
    Width = 57
    Height = 13
    Caption = 'Server Host'
  end
  object Label4: TLabel
    Left = 24
    Top = 116
    Width = 55
    Height = 13
    Caption = 'Server Port'
  end
  object edtRootFolder: TEdit
    Left = 112
    Top = 32
    Width = 435
    Height = 21
    TabOrder = 0
    Text = 'C:\Testing\DOWDLE_5.28.0.5855_UpToDate'
  end
  object btnGetFolder: TBitBtn
    Left = 552
    Top = 30
    Width = 44
    Height = 25
    Caption = '...'
    TabOrder = 1
    OnClick = btnGetFolderClick
  end
  object edtDefaultDoc: TEdit
    Left = 112
    Top = 59
    Width = 435
    Height = 21
    TabOrder = 2
  end
  object lstLog: TListBox
    Left = 0
    Top = 181
    Width = 614
    Height = 256
    Align = alBottom
    ItemHeight = 13
    TabOrder = 3
  end
  object btnClearLog: TBitBtn
    Left = 204
    Top = 140
    Width = 58
    Height = 25
    Caption = 'Clear Log'
    TabOrder = 4
    OnClick = btnClearLogClick
  end
  object btnConnect: TButton
    Left = 112
    Top = 140
    Width = 75
    Height = 25
    Caption = 'Start Server'
    TabOrder = 5
    OnClick = btnConnectClick
  end
  object edtHost: TEdit
    Left = 112
    Top = 86
    Width = 97
    Height = 21
    TabOrder = 6
    Text = '10.72.20.184'
  end
  object edtPort: TEdit
    Left = 112
    Top = 113
    Width = 97
    Height = 21
    TabOrder = 7
    Text = '4567'
  end
  object HTTPServer: TIdHTTPServer
    Bindings = <>
    DefaultPort = 4567
    OnCommandGet = HTTPServerCommandGet
    Left = 240
    Top = 192
  end
  object pgpEHTML: TPageProducer
    Left = 160
    Top = 192
  end
end
