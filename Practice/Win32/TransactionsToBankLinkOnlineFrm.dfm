object frmTransactionsToBankLinkOnline: TfrmTransactionsToBankLinkOnline
  Left = 0
  Top = 0
  ActiveControl = edtTransactionsToDate
  BorderStyle = bsDialog
  Caption = 'Export data to BankLink Online'
  ClientHeight = 222
  ClientWidth = 571
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 392
    Height = 13
    Caption = 
      'BankLink Practice will send all eligible transactions for all cl' +
      'ients to BankLink Online.'
  end
  object Label2: TLabel
    Left = 16
    Top = 48
    Width = 454
    Height = 13
    Caption = 
      'Any transactions which have been updated since they were last se' +
      'nt will be transferred again.'
  end
  object lblTransactionsExportableTo: TLabel
    Left = 16
    Top = 80
    Width = 248
    Height = 13
    Caption = 'There are exportable transactions to <exportable>'
  end
  object Label3: TLabel
    Left = 16
    Top = 112
    Width = 111
    Height = 13
    Caption = 'Export transactions to:'
  end
  object edtTransactionsToDate: TOvcPictureField
    Left = 152
    Top = 108
    Width = 105
    Height = 20
    Cursor = crIBeam
    DataType = pftDate
    AutoSize = False
    BorderStyle = bsNone
    CaretOvr.Shape = csBlock
    ControlCharColor = clRed
    DecimalPlaces = 0
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Epoch = 0
    InitDateTime = False
    MaxLength = 8
    Options = [efoCaretToEnd]
    PictureMask = 'DD/mm/yy'
    TabOrder = 0
    RangeHigh = {25600D00000000000000}
    RangeLow = {00000000000000000000}
  end
  object chkExportChartOfAccounts: TCheckBox
    Left = 16
    Top = 147
    Width = 217
    Height = 17
    Caption = 'Include Chart of Accounts for each Client'
    TabOrder = 1
  end
  object Button1: TButton
    Left = 397
    Top = 187
    Width = 75
    Height = 25
    Caption = '&OK'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 478
    Top = 187
    Width = 75
    Height = 25
    Caption = 'Cancel'
    TabOrder = 3
    OnClick = Button2Click
  end
  object BtnCal: TButton
    Left = 263
    Top = 108
    Width = 21
    Height = 20
    Caption = '...'
    TabOrder = 4
    OnClick = BtnCalClick
  end
  object pmDates: TPopupMenu
    Left = 200
    Top = 176
    object LastMonth1: TMenuItem
      Caption = 'Last &Month'
      Hint = 'Select Last Calendar Month'
    end
    object Last2Months1: TMenuItem
      Caption = 'Last &2 Month Period'
    end
    object LastQuarter1: TMenuItem
      Caption = 'Last &Quarter'
      Hint = 'Select This Quarter'
    end
    object Last6months1: TMenuItem
      Caption = 'Last &6 Month Period'
    end
    object ThisYear1: TMenuItem
      Caption = '&This Year'
      Hint = 'Select This Financial Year'
    end
    object LastYear1: TMenuItem
      Caption = '&Last Year'
      Hint = 'Select Last Financial Year'
    end
    object AllData1: TMenuItem
      Caption = '&All Data'
      Hint = 'Select ALL transactions for client'
    end
  end
end
