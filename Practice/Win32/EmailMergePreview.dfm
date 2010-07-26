object frmMailMergePreview: TfrmMailMergePreview
  Left = 325
  Top = 326
  BorderStyle = bsDialog
  Caption = 'E-mail Merge Preview'
  ClientHeight = 368
  ClientWidth = 495
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 17
    Top = 10
    Width = 89
    Height = 16
    Caption = 'The document:'
  end
  object lblDocument: TLabel
    Left = 17
    Top = 30
    Width = 473
    Height = 17
    AutoSize = False
    Caption = '<doc name>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    OnClick = lblDocumentClick
  end
  object Label3: TLabel
    Left = 17
    Top = 50
    Width = 415
    Height = 16
    Caption = 
      'will be merged and sent to the following clients in an email wit' +
      'h Subject:'
  end
  object lblSubject: TLabel
    Left = 17
    Top = 70
    Width = 470
    Height = 17
    AutoSize = False
    Caption = '<subject>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object mmoClients: TMemo
    Left = 17
    Top = 98
    Width = 462
    Height = 225
    Color = clBtnFace
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
    OnEnter = mmoClientsEnter
  end
  object btnOk: TButton
    Left = 166
    Top = 333
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 254
    Top = 333
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object WordPreview: TOpWord
    Version = '1.64'
    Documents = <>
    Visible = True
    ScreenUpdating = False
    PrintPreview = False
    DisplayRecentFiles = False
    DisplayScrollBars = False
    ServerLeft = 0
    ServerTop = 0
    ServerWidth = 640
    ServerHeight = 480
    WindowState = wdwsNormal
    DisplayAlerts = wdalNone
    DisplayScreenTips = False
    EnableCancelKey = wdeckDisabled
    Left = 384
    Top = 328
  end
end
