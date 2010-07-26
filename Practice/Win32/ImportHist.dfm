object frmImportHist: TfrmImportHist
  Left = 219
  Top = 128
  BorderIcons = []
  Caption = 'Import Historical Data'
  ClientHeight = 296
  ClientWidth = 582
  Color = clBtnFace
  Constraints.MinHeight = 140
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  DesignSize = (
    582
    296)
  PixelsPerInch = 96
  TextHeight = 13
  object Filename: TLabel
    Left = 8
    Top = 39
    Width = 66
    Height = 13
    Caption = 'Import File '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
  end
  object lblAccountNo: TLabel
    Left = 8
    Top = 8
    Width = 82
    Height = 13
    Caption = 'Bank Account '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
  end
  object lblAccountName: TLabel
    Left = 192
    Top = 8
    Width = 115
    Height = 13
    Caption = 'Bank Account Name'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
  end
  object LblError: TLabel
    Left = 8
    Top = 72
    Width = 332
    Height = 13
    Caption = 'Errors were encounted while attempting to import the file:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clRed
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    Visible = False
  end
  object btnOK: TButton
    Left = 416
    Top = 263
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Import'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 499
    Top = 263
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Close'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 3
  end
  object edtFilename: TEdit
    Left = 89
    Top = 37
    Width = 440
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 535
    Top = 35
    Width = 25
    Height = 25
    Anchors = [akTop, akRight]
    Caption = '...'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object btnView: TButton
    Left = 8
    Top = 263
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&View File'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    OnClick = btnViewClick
  end
  object ListBoxErrors: TListBox
    Left = 8
    Top = 91
    Width = 566
    Height = 158
    Anchors = [akLeft, akTop, akRight]
    Constraints.MinHeight = 100
    ItemHeight = 13
    TabOrder = 5
    Visible = False
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.csv'
    Filter = 'CSV Files (*.csv)|*.csv'
    Options = [ofFileMustExist, ofEnableSizing]
    Left = 112
  end
end
