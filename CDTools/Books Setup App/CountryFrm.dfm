object frmLocation: TfrmLocation
  Scaled = False
Left = 359
  Top = 284
  BorderStyle = bsDialog
  Caption = 'Select Country'
  ClientHeight = 96
  ClientWidth = 390
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  DesignSize = (
    390
    96)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 13
    Width = 94
    Height = 13
    Caption = 'Select your country:'
  end
  object Button1: TButton
    Left = 150
    Top = 65
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object cmbCountry: TComboBox
    Left = 8
    Top = 32
    Width = 377
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 1
    Text = 'Australia'
    Items.Strings = (
      'Australia'
      'New Zealand')
  end
end
