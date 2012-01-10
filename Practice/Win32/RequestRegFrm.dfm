object RequestregForm: TRequestregForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Request BankLink Online Registration'
  ClientHeight = 403
  ClientWidth = 549
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  DesignSize = (
    549
    403)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel10: TBevel
    Left = 128
    Top = 17
    Width = 401
    Height = 8
    Shape = bsTopLine
  end
  object imgInfo: TImage
    Left = 16
    Top = 270
    Width = 49
    Height = 66
    Transparent = True
  end
  object lblPleaseAllow: TLabel
    Left = 80
    Top = 270
    Width = 449
    Height = 23
    AutoSize = False
    Caption = 
      'Please allow three working days for your application to be proce' +
      'ssed'
  end
  object lblInfo: TLabel
    Left = 80
    Top = 302
    Width = 433
    Height = 50
    AutoSize = False
    Caption = 
      'When your secure area has been created, a member of the BankLink' +
      ' Support Team will contact the above BankLink Online Administrat' +
      'or to provide assistance with using the BankLink Online service'
    WordWrap = True
  end
  object lblPracticeName: TLabel
    Left = 16
    Top = 40
    Width = 27
    Height = 13
    Caption = 'Name'
  end
  object lblSecureCode: TLabel
    Left = 16
    Top = 75
    Width = 105
    Height = 13
    Caption = 'BankLink Secure Code'
  end
  object Label5: TLabel
    Left = 16
    Top = 115
    Width = 187
    Height = 13
    Caption = 'Administrator Details (Primary Contact)'
  end
  object lblAdminName: TLabel
    Left = 16
    Top = 152
    Width = 27
    Height = 13
    Caption = 'Name'
  end
  object lblPh: TLabel
    Left = 16
    Top = 192
    Width = 70
    Height = 13
    Caption = 'Phone Number'
  end
  object lblEmail: TLabel
    Left = 16
    Top = 232
    Width = 66
    Height = 13
    Caption = 'Email Address'
  end
  object Bevel1: TBevel
    Left = 264
    Top = 123
    Width = 265
    Height = 8
    Shape = bsTopLine
  end
  object Label9: TLabel
    Left = 16
    Top = 8
    Width = 73
    Height = 13
    Caption = 'Practice Details'
  end
  object btnSubmit: TButton
    Left = 365
    Top = 370
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Submit'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 454
    Top = 370
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object edtPracticeName: TEdit
    Left = 160
    Top = 37
    Width = 369
    Height = 21
    TabOrder = 2
  end
  object edtSecureCode: TEdit
    Left = 160
    Top = 72
    Width = 369
    Height = 21
    TabOrder = 3
  end
  object edtPh: TEdit
    Left = 160
    Top = 192
    Width = 369
    Height = 21
    TabOrder = 4
  end
  object edtEmail: TEdit
    Left = 160
    Top = 227
    Width = 369
    Height = 21
    TabOrder = 5
  end
  object cbAdminName: TComboBox
    Left = 160
    Top = 149
    Width = 369
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 6
    OnChange = cbAdminNameChange
  end
end
