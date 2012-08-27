object frmSelectInstitution: TfrmSelectInstitution
  Left = 0
  Top = 0
  Caption = 'Select Institution'
  ClientHeight = 146
  ClientWidth = 327
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
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
    ItemIndex = 0
    TabOrder = 0
    Text = 'Other'
    Items.Strings = (
      'Other'
      'HSBC')
  end
  object btnOK: TButton
    Left = 151
    Top = 104
    Width = 75
    Height = 25
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 232
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 2
  end
end
