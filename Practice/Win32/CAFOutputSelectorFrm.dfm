object frmCAFOutputSelector: TfrmCAFOutputSelector
  Left = 0
  Top = 0
  ActiveControl = edtSaveTo
  BorderStyle = bsDialog
  Caption = 'Save Customer Authority Forms To Folder'
  ClientHeight = 127
  ClientWidth = 434
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 21
    Top = 24
    Width = 34
    Height = 13
    Caption = 'Format'
  end
  object Label2: TLabel
    Left = 21
    Top = 57
    Width = 39
    Height = 13
    Caption = 'Save To'
  end
  object btnToFolder: TSpeedButton
    Left = 402
    Top = 52
    Width = 25
    Height = 24
    Hint = 'Click to Select a Folder'
    OnClick = btnToFolderClick
  end
  object cmbFileFormat: TComboBox
    Left = 111
    Top = 21
    Width = 201
    Height = 21
    Hint = 'Select the format of the Customer Authority Forms.'
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 0
    Text = 'Adobe Acrobat Format (PDF)'
    Items.Strings = (
      'Adobe Acrobat Format (PDF)')
  end
  object edtSaveTo: TEdit
    Left = 111
    Top = 54
    Width = 285
    Height = 21
    Hint = 
      'Enter the directory path the save the Customer Authority Forms t' +
      'o.'
    TabOrder = 1
  end
  object btnSave: TButton
    Left = 271
    Top = 92
    Width = 75
    Height = 25
    Caption = '&Save'
    Default = True
    TabOrder = 2
    OnClick = btnSaveClick
  end
  object btnCancel: TButton
    Left = 352
    Top = 92
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
