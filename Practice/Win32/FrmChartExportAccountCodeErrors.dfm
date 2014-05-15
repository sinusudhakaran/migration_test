object frmChartExportAccountCodeErrors: TfrmChartExportAccountCodeErrors
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Export Chart to MYOB Essentials Cashbook'
  ClientHeight = 412
  ClientWidth = 501
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    501
    412)
  PixelsPerInch = 96
  TextHeight = 13
  object lblErrors: TLabel
    Left = 8
    Top = 8
    Width = 465
    Height = 16
    Caption = 
      'The following chart of account codes are not valid for MYOB Esse' +
      'ntials Cashbook,'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblErrors2: TLabel
    Left = 8
    Top = 26
    Width = 274
    Height = 16
    Caption = 'please change code to be 10 characters or less.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LstErrors: TListBox
    Left = 6
    Top = 52
    Width = 487
    Height = 324
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 418
    Top = 382
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&OK'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 1
  end
end
