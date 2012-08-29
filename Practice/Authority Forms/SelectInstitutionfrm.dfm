object frmSelectInstitution: TfrmSelectInstitution
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Select Institution'
  ClientHeight = 145
  ClientWidth = 324
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 282
    Height = 26
    Caption = 
      'Select the financial institution that the Customer Authority For' +
      'm will be generated for:'
    WordWrap = True
  end
  object cmbInstitution: TComboBox
    Left = 16
    Top = 64
    Width = 291
    Height = 21
    ItemHeight = 13
    TabOrder = 0
    OnChange = cmbInstitutionChange
    Items.Strings = (
      '')
  end
  object btnOK: TButton
    Left = 151
    Top = 104
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 232
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
