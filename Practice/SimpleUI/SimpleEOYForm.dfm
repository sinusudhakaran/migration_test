object frmSimpleEOY: TfrmSimpleEOY
  Scaled = False
Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'End of Year process'
  ClientHeight = 269
  ClientWidth = 554
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  DesignSize = (
    554
    269)
  PixelsPerInch = 96
  TextHeight = 13
  object lblHeaderText: TLabel
    Left = 15
    Top = 22
    Width = 416
    Height = 13
    Caption = 
      'Completing the Year End Process will  update your Financial Year' +
      ' Start Date to <date>'
  end
  object Label2: TLabel
    Left = 42
    Top = 55
    Width = 116
    Height = 13
    Caption = 'Current Financial Year is'
  end
  object Label3: TLabel
    Left = 39
    Top = 160
    Width = 124
    Height = 13
    Caption = 'All transaction are coded?'
  end
  object lblCodedYesNo: TLabel
    Left = 259
    Top = 160
    Width = 34
    Height = 13
    Caption = 'Yes/No'
  end
  object lblAllCodedWarning: TLabel
    Left = 370
    Top = 160
    Width = 108
    Height = 39
    Caption = 'No - You must code all transactions in before proceeding'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label7: TLabel
    Left = 42
    Top = 74
    Width = 83
    Height = 13
    Caption = 'Current Period is '
  end
  object lblCurrentPeriod: TLabel
    Left = 259
    Top = 74
    Width = 56
    Height = 13
    Caption = '31/01/2011'
  end
  object lblFullYearWarning: TLabel
    Left = 370
    Top = 108
    Width = 143
    Height = 39
    Caption = 'You must download a full years data before proceeding'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object lblFinYearStart: TLabel
    Left = 259
    Top = 55
    Width = 56
    Height = 13
    Caption = '31/01/2011'
  end
  object Label1: TLabel
    Left = 42
    Top = 108
    Width = 189
    Height = 36
    AutoSize = False
    Caption = 'All transactions downloaded for the year?'
    WordWrap = True
  end
  object lblLastPeriodDownloaded: TLabel
    Left = 259
    Top = 108
    Width = 34
    Height = 13
    Caption = 'Yes/No'
  end
  object btnCancel: TButton
    Left = 471
    Top = 236
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object btnProceed: TButton
    Left = 289
    Top = 236
    Width = 163
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Proceed with End of Year'
    ModalResult = 1
    TabOrder = 1
    OnClick = btnProceedClick
  end
end
