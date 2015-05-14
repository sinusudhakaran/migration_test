object FrmCashbookWarning: TFrmCashbookWarning
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Warning'
  ClientHeight = 366
  ClientWidth = 534
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    534
    366)
  PixelsPerInch = 96
  TextHeight = 13
  object lblYouHave: TLabel
    Left = 50
    Top = 15
    Width = 440
    Height = 16
    Caption = 
      'You have Provisional Bank Accounts attached to the following cli' +
      'ents:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object lblProvisinalAccounts: TLabel
    Left = 50
    Top = 247
    Width = 442
    Height = 74
    Anchors = [akLeft, akRight, akBottom]
    AutoSize = False
    Caption = 'Provisional accounts are available in'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object Image1: TImage
    Left = 6
    Top = 5
    Width = 36
    Height = 36
    AutoSize = True
    Stretch = True
    Transparent = True
  end
  object stgSelectedClients: TStringGrid
    Left = 50
    Top = 47
    Width = 440
    Height = 194
    Anchors = [akLeft, akTop, akRight, akBottom]
    ColCount = 2
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Options = [goRangeSelect, goRowSelect]
    ParentFont = False
    TabOrder = 0
    ColWidths = (
      122
      583)
  end
  object btnOK: TButton
    Left = 232
    Top = 333
    Width = 76
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
