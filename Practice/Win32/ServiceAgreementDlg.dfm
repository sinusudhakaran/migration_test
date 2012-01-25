object frmServiceAgreement: TfrmServiceAgreement
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Service Agreement'
  ClientHeight = 469
  ClientWidth = 468
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    468
    469)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 218
    Height = 13
    Caption = 'Please read the following Service Agreement.'
  end
  object Label2: TLabel
    Left = 16
    Top = 359
    Width = 435
    Height = 58
    AutoSize = False
    Caption = 
      'Do you accept all the terms of the preceding Service Agreement? ' +
      'If you choose No, you will not be able to submit this registrati' +
      'on. To use BankLink Online you must accept this agreement.'
    WordWrap = True
  end
  object btnOK: TButton
    Left = 289
    Top = 434
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Yes'
    Default = True
    ModalResult = 6
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 378
    Top = 434
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&No'
    ModalResult = 7
    TabOrder = 1
  end
  object memServiceAgreement: TRichEdit
    Left = 16
    Top = 35
    Width = 435
    Height = 310
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
