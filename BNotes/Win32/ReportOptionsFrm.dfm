inherited frmReportOptions: TfrmReportOptions
  BorderStyle = bsDialog
  Caption = 'Report Options'
  ClientHeight = 101
  ClientWidth = 222
  ExplicitWidth = 228
  ExplicitHeight = 133
  PixelsPerInch = 96
  TextHeight = 16
  object btnOk: TButton
    Left = 32
    Top = 60
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 113
    Top = 60
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object chkLine: TCheckBox
    Left = 16
    Top = 24
    Width = 208
    Height = 17
    Caption = '&Rule a line between entries'
    TabOrder = 0
  end
end
