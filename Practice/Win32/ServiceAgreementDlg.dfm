object frmServiceAgreement: TfrmServiceAgreement
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Service Agreement'
  ClientHeight = 448
  ClientWidth = 644
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnResize = FormResize
  DesignSize = (
    644
    448)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 13
    Width = 261
    Height = 16
    Caption = 'Please read the following Service Agreement.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 16
    Top = 359
    Width = 620
    Height = 34
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'Do you accept all the terms of the preceding Service Agreement? ' +
      'If you choose No, you will not be able to submit this registrati' +
      'on. To use BankLink Online you must accept this agreement.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    WordWrap = True
    ExplicitWidth = 583
  end
  object btnOK: TButton
    Left = 465
    Top = 415
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Yes'
    Default = True
    ModalResult = 6
    TabOrder = 0
    ExplicitLeft = 428
    ExplicitTop = 424
  end
  object btnCancel: TButton
    Left = 561
    Top = 415
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&No'
    ModalResult = 7
    TabOrder = 1
    ExplicitLeft = 524
    ExplicitTop = 424
  end
  object memServiceAgreement: TcxRichEdit
    Left = 8
    Top = 35
    Anchors = [akLeft, akTop, akRight]
    Properties.HideScrollBars = False
    Properties.ReadOnly = True
    Properties.ScrollBars = ssVertical
    Lines.Strings = (
      'memServiceAgreement')
    TabOrder = 2
    ExplicitWidth = 618
    Height = 318
    Width = 628
  end
end
