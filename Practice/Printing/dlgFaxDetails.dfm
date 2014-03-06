object FaxDetailsDlg: TFaxDetailsDlg
  Scaled = False
Left = 378
  Top = 301
  BorderStyle = bsDialog
  Caption = 'Recipient Details'
  ClientHeight = 131
  ClientWidth = 410
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    410
    131)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 24
    Width = 27
    Height = 13
    Caption = 'Name'
  end
  object Label2: TLabel
    Left = 16
    Top = 56
    Width = 58
    Height = 13
    Caption = 'Fax Number'
  end
  object Button1: TButton
    Left = 238
    Top = 92
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object Button2: TButton
    Left = 326
    Top = 92
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object edtToName: TEdit
    Left = 104
    Top = 24
    Width = 297
    Height = 24
    BorderStyle = bsNone
    TabOrder = 2
  end
  object edtFaxNumber: TEdit
    Left = 104
    Top = 56
    Width = 297
    Height = 24
    BorderStyle = bsNone
    TabOrder = 3
  end
end
