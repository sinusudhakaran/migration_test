object PickNewPrimaryUser: TPickNewPrimaryUser
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Confirmation'
  ClientHeight = 136
  ClientWidth = 440
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 15
    Top = 17
    Width = 40
    Height = 40
    AutoSize = True
    Stretch = True
    Transparent = True
  end
  object lblText: TLabel
    Left = 76
    Top = 10
    Width = 352
    Height = 47
    AutoSize = False
    Caption = 
      'This user is the current primary contact for this practice. Anot' +
      'her user will need to be set as the primary contact before the u' +
      'ser can be deleted. '
    ShowAccelChar = False
    Transparent = True
    WordWrap = True
  end
  object Label1: TLabel
    Left = 76
    Top = 65
    Width = 109
    Height = 18
    AutoSize = False
    Caption = 'New Primary Contact'
    ShowAccelChar = False
    Transparent = True
    WordWrap = True
  end
  object Label2: TLabel
    Left = 76
    Top = 97
    Width = 186
    Height = 18
    AutoSize = False
    Caption = 'Are you sure you want to continue?'
    ShowAccelChar = False
    Transparent = True
    WordWrap = True
  end
  object btnYes: TButton
    Left = 261
    Top = 98
    Width = 75
    Height = 25
    Caption = '&Yes'
    ModalResult = 6
    TabOrder = 0
  end
  object btnNo: TButton
    Left = 353
    Top = 98
    Width = 75
    Height = 25
    Cancel = True
    Caption = '&No'
    Default = True
    ModalResult = 7
    TabOrder = 1
  end
  object cmbPrimaryContact: TComboBox
    Left = 191
    Top = 63
    Width = 237
    Height = 21
    ItemHeight = 13
    TabOrder = 2
  end
end
