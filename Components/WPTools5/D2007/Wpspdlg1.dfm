object WPSpDialog: TWPSpDialog
  Left = 119
  Top = 116
  ActiveControl = Ignore
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'SpellCheck Example'
  ClientHeight = 214
  ClientWidth = 455
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'System'
  Font.Style = []
  OldCreateOrder = True
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 20
  object WordList: TListBox
    Left = 15
    Top = 84
    Width = 250
    Height = 116
    ItemHeight = 20
    TabOrder = 0
  end
  object Word: TEdit
    Left = 15
    Top = 9
    Width = 250
    Height = 28
    Enabled = False
    TabOrder = 1
    Text = 'Word'
  end
  object ReplaceAs: TEdit
    Left = 15
    Top = 46
    Width = 250
    Height = 28
    TabOrder = 2
    Text = 'ReplaceAs'
  end
  object Ignore: TBitBtn
    Left = 293
    Top = 64
    Width = 153
    Height = 41
    Caption = '&Continue'
    TabOrder = 3
    OnClick = IgnoreClick
    Kind = bkIgnore
  end
  object Replace: TBitBtn
    Left = 293
    Top = 111
    Width = 152
    Height = 42
    Caption = '&Replace'
    TabOrder = 4
    OnClick = ReplaceClick
    Kind = bkRetry
  end
  object Cancel: TBitBtn
    Left = 293
    Top = 159
    Width = 153
    Height = 41
    Caption = '&Cancel'
    TabOrder = 5
    OnClick = CancelClick
    Kind = bkAbort
  end
end
