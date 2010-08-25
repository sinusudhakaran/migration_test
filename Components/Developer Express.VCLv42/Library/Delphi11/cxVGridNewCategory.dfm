object fmCreateCategory: TfmCreateCategory
  Left = 669
  Top = 113
  BorderStyle = bsDialog
  ClientHeight = 87
  ClientWidth = 279
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbCaption: TLabel
    Left = 11
    Top = 13
    Width = 3
    Height = 13
    FocusControl = edCaption
  end
  object Bevel: TBevel
    Left = 11
    Top = 42
    Width = 260
    Height = 4
    Shape = bsTopLine
  end
  object btOK: TcxButton
    Left = 113
    Top = 55
    Width = 75
    Height = 24
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btCancel: TcxButton
    Left = 196
    Top = 55
    Width = 75
    Height = 24
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edCaption: TcxTextEdit
    Left = 72
    Top = 10
    Width = 199
    Height = 21
    Properties.OnChange = edCaptionPropertiesChange
    TabOrder = 0
  end
end
