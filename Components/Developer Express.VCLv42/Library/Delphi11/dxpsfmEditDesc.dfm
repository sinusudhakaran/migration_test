object dxfmEditDescription: TdxfmEditDescription
  Left = 383
  Top = 205
  BorderStyle = bsDialog
  Caption = 'Edit Description'
  ClientHeight = 294
  ClientWidth = 333
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 90
    Top = 265
    Width = 75
    Height = 23
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 171
    Top = 265
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 252
    Top = 265
    Width = 75
    Height = 23
    Caption = '&Help'
    TabOrder = 3
  end
  object gbxMemoHost: TGroupBox
    Left = 5
    Top = 6
    Width = 322
    Height = 249
    TabOrder = 0
    object memDescription: TMemo
      Left = 8
      Top = 18
      Width = 305
      Height = 218
      TabOrder = 0
    end
  end
end
