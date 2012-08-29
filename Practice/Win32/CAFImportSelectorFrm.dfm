object frmCAFImportSelector: TfrmCAFImportSelector
  Left = 0
  Top = 0
  ActiveControl = cmbInstitution
  BorderStyle = bsDialog
  Caption = 'Select a File to Import'
  ClientHeight = 127
  ClientWidth = 434
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 21
    Top = 24
    Width = 49
    Height = 13
    Caption = 'Institution'
  end
  object Label2: TLabel
    Left = 21
    Top = 57
    Width = 59
    Height = 13
    Caption = 'Import From'
  end
  object btnToFolder: TSpeedButton
    Left = 399
    Top = 53
    Width = 25
    Height = 24
    Hint = 'Click to Select a Folder'
    OnClick = btnToFolderClick
  end
  object cmbInstitution: TComboBox
    Left = 108
    Top = 21
    Width = 204
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = 'Other'
    Items.Strings = (
      'Other'
      'HSBC')
  end
  object edtImportFile: TEdit
    Left = 108
    Top = 54
    Width = 285
    Height = 21
    TabOrder = 1
  end
  object btnImport: TButton
    Left = 268
    Top = 92
    Width = 75
    Height = 25
    Caption = '&Import'
    Default = True
    TabOrder = 2
    OnClick = btnImportClick
  end
  object btnCancel: TButton
    Left = 349
    Top = 92
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object dlgOpen: TOpenDialog
    Filter = 'Import File|*.xls'
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 376
    Top = 8
  end
end
