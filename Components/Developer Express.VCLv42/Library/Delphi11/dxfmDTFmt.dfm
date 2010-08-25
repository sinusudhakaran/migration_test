object dxfmDateTimeFormats: TdxfmDateTimeFormats
  Left = 350
  Top = 153
  ActiveControl = lbxDateFormats
  BorderStyle = bsDialog
  Caption = 'Change Date and Time Formats'
  ClientHeight = 342
  ClientWidth = 282
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 41
    Top = 313
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 122
    Top = 313
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 203
    Top = 313
    Width = 75
    Height = 23
    Caption = '&Help'
    TabOrder = 3
  end
  object GroupBox1: TGroupBox
    Left = 4
    Top = 4
    Width = 274
    Height = 301
    TabOrder = 0
    object lblAvailableDateFormats: TLabel
      Left = 10
      Top = 13
      Width = 115
      Height = 13
      Caption = 'Available &Date Formats:'
      FocusControl = lbxDateFormats
      OnClick = lblAvailableDateFormatsClick
    end
    object lblAvailableTimeFormats: TLabel
      Left = 10
      Top = 187
      Width = 114
      Height = 13
      Caption = 'Available Time &Formats:'
      FocusControl = lbxTimeFormats
      OnClick = lblAvailableDateFormatsClick
    end
    object lbxDateFormats: TListBox
      Left = 8
      Top = 28
      Width = 257
      Height = 150
      ItemHeight = 13
      TabOrder = 0
      OnClick = lbxDateFormatsClick
      OnDblClick = lbxDTFormatsDblClick
    end
    object lbxTimeFormats: TListBox
      Left = 8
      Top = 203
      Width = 257
      Height = 59
      ItemHeight = 13
      TabOrder = 1
      OnClick = TimeFormatsChanged
      OnDblClick = lbxDTFormatsDblClick
    end
    object chbxAutoUpdate: TCheckBox
      Left = 8
      Top = 274
      Width = 160
      Height = 17
      Caption = '&Update Automatically '
      TabOrder = 2
      OnClick = chbxAutoUpdateClick
    end
    object btnDefault: TButton
      Left = 175
      Top = 270
      Width = 90
      Height = 23
      Caption = '&Default ...'
      TabOrder = 3
      OnClick = btnDefaultClick
    end
  end
end
