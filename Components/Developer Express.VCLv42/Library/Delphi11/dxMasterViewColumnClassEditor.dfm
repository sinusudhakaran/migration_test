object frmColumnClass: TfrmColumnClass
  Left = 364
  Top = 215
  BorderStyle = bsDialog
  ClientHeight = 84
  ClientWidth = 282
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 114
    Top = 56
    Width = 75
    Height = 22
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 201
    Top = 56
    Width = 75
    Height = 22
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object GroupBox1: TGroupBox
    Left = 6
    Top = 4
    Width = 270
    Height = 45
    Caption = ' Column Class  '
    TabOrder = 0
    object cmbColumnClass: TComboBox
      Left = 8
      Top = 16
      Width = 254
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
  end
end
