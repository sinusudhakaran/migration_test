object frmImportCAF: TfrmImportCAF
  Left = 0
  Top = 0
  Caption = 'Select a File to Import'
  ClientHeight = 142
  ClientWidth = 423
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblInstitution: TLabel
    Left = 24
    Top = 24
    Width = 49
    Height = 13
    Caption = 'Institution'
  end
  object lblImportFrom: TLabel
    Left = 24
    Top = 64
    Width = 59
    Height = 13
    Caption = 'Import From'
  end
  object cmbInstitution: TComboBox
    Left = 96
    Top = 21
    Width = 313
    Height = 21
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = 'Other'
    Items.Strings = (
      'Other'
      'HSBC')
  end
  object edtImportFrom: TEdit
    Left = 96
    Top = 61
    Width = 225
    Height = 21
    TabOrder = 1
  end
  object btnImport: TButton
    Left = 246
    Top = 109
    Width = 75
    Height = 25
    Caption = 'Import'
    ModalResult = 1
    TabOrder = 2
    OnClick = btnImportClick
  end
  object btnBrowse: TButton
    Left = 334
    Top = 59
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 3
    OnClick = btnBrowseClick
  end
  object btnCancel: TButton
    Left = 334
    Top = 109
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
end
