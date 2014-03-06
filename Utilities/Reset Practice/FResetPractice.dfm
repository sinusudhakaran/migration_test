object frmResetPractice: TfrmResetPractice
  Scaled = False
Left = 0
  Top = 0
  Caption = 'Reset Practice'
  ClientHeight = 190
  ClientWidth = 427
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object SpeedButton1: TSpeedButton
    Left = 392
    Top = 19
    Width = 23
    Height = 22
    Caption = '...'
    OnClick = SpeedButton1Click
  end
  object Label1: TLabel
    Left = 8
    Top = 19
    Width = 54
    Height = 13
    Caption = 'Practice DB'
  end
  object Label2: TLabel
    Left = 8
    Top = 56
    Width = 66
    Height = 13
    Caption = 'Practice Code'
  end
  object Label3: TLabel
    Left = 8
    Top = 83
    Width = 73
    Height = 13
    Caption = 'Password Hash'
  end
  object Label4: TLabel
    Left = 8
    Top = 120
    Width = 67
    Height = 13
    Caption = 'Country Code'
  end
  object Button1: TButton
    Left = 176
    Top = 157
    Width = 75
    Height = 25
    Caption = 'Update'
    TabOrder = 0
    OnClick = Button1Click
  end
  object edtPath: TEdit
    Left = 87
    Top = 16
    Width = 299
    Height = 21
    TabOrder = 1
  end
  object edtPracticeCode: TEdit
    Left = 87
    Top = 53
    Width = 121
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 2
    Text = 'RALPH1'
  end
  object edtPasswordHash: TEdit
    Left = 87
    Top = 80
    Width = 292
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 3
    Text = '94-E8-CD-E4-61-2B-3F-D3-90-67-7D-42-E7-B2-20-02'
  end
  object cmbCountryCode: TComboBox
    Left = 87
    Top = 117
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 4
    Text = 'NZ'
    Items.Strings = (
      'NZ'
      'AU'
      'UK')
  end
  object FileOpenDialog1: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoNoChangeDir, fdoPickFolders]
    Left = 360
    Top = 48
  end
end
