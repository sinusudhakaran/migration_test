object AttachToReportFrm: TAttachToReportFrm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Attach Report to Email'
  ClientHeight = 148
  ClientWidth = 475
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 34
    Height = 13
    Caption = 'Format'
  end
  object Label2: TLabel
    Left = 24
    Top = 64
    Width = 63
    Height = 13
    Caption = 'Report Name'
  end
  object btnOK: TButton
    Left = 301
    Top = 105
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 382
    Top = 105
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edtReportName: TEdit
    Left = 112
    Top = 61
    Width = 297
    Height = 21
    TabOrder = 0
  end
  object cmbFormat: TComboBox
    Left = 112
    Top = 21
    Width = 297
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
  end
end
