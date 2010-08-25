object WPStringDialog: TWPStringDialog
  Left = 77
  Top = 126
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Modify Hyperlink'
  ClientHeight = 181
  ClientWidth = 412
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 16
  object Bevel1: TBevel
    Left = 1
    Top = 122
    Width = 409
    Height = 15
    Shape = bsBottomLine
  end
  object Label1: TLabel
    Left = 12
    Top = 15
    Width = 57
    Height = 16
    Caption = 'Hyperlink'
  end
  object Label2: TLabel
    Left = 12
    Top = 73
    Width = 27
    Height = 16
    Caption = 'URL'
  end
  object btnOk: TButton
    Left = 315
    Top = 146
    Width = 92
    Height = 31
    Caption = '&Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 219
    Top = 146
    Width = 92
    Height = 31
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object aText: TEdit
    Left = 12
    Top = 33
    Width = 384
    Height = 24
    TabOrder = 2
    Text = 'aText'
  end
  object aData: TEdit
    Left = 12
    Top = 90
    Width = 387
    Height = 24
    TabOrder = 3
    Text = 'aData'
  end
end
