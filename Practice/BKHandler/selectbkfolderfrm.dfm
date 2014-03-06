object frmSelectBK5Folder: TfrmSelectBK5Folder
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Select a MYOB BankLink folder'
  ClientHeight = 288
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblCheckin: TLabel
    Left = 16
    Top = 40
    Width = 187
    Height = 13
    Caption = 'Where do you want to update this file?'
  end
  object lblBK5File: TLabel
    Left = 16
    Top = 16
    Width = 128
    Height = 13
    Caption = 'MYOB BankLink Client File: '
  end
  object lblFilename: TLabel
    Left = 152
    Top = 17
    Width = 52
    Height = 13
    Caption = 'lblFilename'
  end
  object btnOK: TButton
    Left = 264
    Top = 248
    Width = 75
    Height = 25
    Caption = 'Update'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 344
    Top = 248
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object cbPaths: TListBox
    Left = 16
    Top = 64
    Width = 393
    Height = 169
    ItemHeight = 13
    TabOrder = 0
    OnDblClick = cbPathsDblClick
  end
end
