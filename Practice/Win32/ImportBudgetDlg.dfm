object frmImportBudget: TfrmImportBudget
  Left = 0
  Top = 0
  Caption = 'Import Budget'
  ClientHeight = 101
  ClientWidth = 568
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    568
    101)
  PixelsPerInch = 96
  TextHeight = 13
  object lblFilename: TLabel
    Left = 12
    Top = 12
    Width = 115
    Height = 16
    Caption = 'Import Budget From'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object btnToFile: TSpeedButton
    Left = 535
    Top = 8
    Width = 25
    Height = 24
    Hint = 'Click to Select a Folder'
    Anchors = [akTop, akRight]
    ParentShowHint = False
    ShowHint = True
    OnClick = btnToFileClick
    ExplicitLeft = 489
  end
  object edtBudgetFile: TEdit
    Left = 133
    Top = 8
    Width = 396
    Height = 24
    Hint = 'Enter the filename to import from'
    Anchors = [akLeft, akTop, akRight]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
  end
  object btnOk: TButton
    Left = 404
    Top = 68
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 485
    Top = 68
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 2
  end
  object OpenTextFileDialog: TOpenTextFileDialog
    DefaultExt = 'csv'
    Filter = 'CSV Files (*.csv)|*.csv|All Files (*.*)|*.*'
    Left = 8
    Top = 64
  end
end
