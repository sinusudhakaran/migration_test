object FrmCashbookWarning: TFrmCashbookWarning
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Warning'
  ClientHeight = 362
  ClientWidth = 518
  Color = clBtnFace
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
    518
    362)
  PixelsPerInch = 96
  TextHeight = 13
  object lblYouHave: TLabel
    Left = 8
    Top = 16
    Width = 393
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
    Left = 8
    Top = 234
    Width = 502
    Height = 82
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
    ExplicitWidth = 512
  end
  object stgSelectedClients: TStringGrid
    Left = 8
    Top = 38
    Width = 502
    Height = 190
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
    ExplicitWidth = 512
    ColWidths = (
      122
      583)
  end
  object btnOK: TButton
    Left = 435
    Top = 329
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
    ExplicitLeft = 445
  end
end
