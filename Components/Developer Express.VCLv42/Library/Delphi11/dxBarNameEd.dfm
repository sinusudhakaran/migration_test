object dxBarNameEd: TdxBarNameEd
  Left = 199
  Top = 196
  BorderIcons = []
  BorderStyle = bsDialog
  ClientHeight = 87
  ClientWidth = 266
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object LName: TLabel
    Left = 8
    Top = 8
    Width = 68
    Height = 13
    Caption = '&Toolbar name:'
  end
  object EName: TEdit
    Left = 8
    Top = 27
    Width = 251
    Height = 21
    TabOrder = 0
    OnChange = ENameChange
  end
  object BOK: TButton
    Left = 106
    Top = 58
    Width = 73
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object BCancel: TButton
    Left = 186
    Top = 58
    Width = 73
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
