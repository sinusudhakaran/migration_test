object dxfmPageNumberFormat: TdxfmPageNumberFormat
  Left = 434
  Top = 210
  BorderStyle = bsDialog
  Caption = 'Change Page Number Format'
  ClientHeight = 209
  ClientWidth = 247
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object lblPageNumberFormat: TLabel
    Left = 6
    Top = 15
    Width = 78
    Height = 13
    Caption = 'Number &Format:'
    FocusControl = cbxPageNumberingFormat
    OnClick = lblPageNumberFormatClick
  end
  object bvlStartAtHolder: TBevel
    Left = 113
    Top = 93
    Width = 129
    Height = 22
    Visible = False
  end
  object bvlPageNumbering: TBevel
    Left = 111
    Top = 49
    Width = 132
    Height = 5
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object Bevel2: TBevel
    Left = 6
    Top = 119
    Width = 237
    Height = 5
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object lblPageNumbering: TLabel
    Left = 7
    Top = 45
    Width = 78
    Height = 13
    Caption = 'Page Numbering'
  end
  object Bevel3: TBevel
    Left = 6
    Top = 166
    Width = 237
    Height = 4
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
  end
  object btnOK: TButton
    Left = 6
    Top = 180
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 87
    Top = 180
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 168
    Top = 180
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 2
  end
  object cbxPageNumberingFormat: TComboBox
    Left = 113
    Top = 12
    Width = 130
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 3
    OnChange = cbxPageNumberingFormatChange
    Items.Strings = (
      '1, 2, 3, 3, 4, ...'
      'a, b, c, d, e, ...'
      'A, B, C, D, E, ...'
      'i, ii, iii, iv, v, ...'
      'I, II, III, IV, V, ...')
  end
  object btnDefault: TButton
    Left = 154
    Top = 135
    Width = 89
    Height = 23
    Anchors = [akTop, akRight]
    Caption = '&Default...'
    TabOrder = 4
    OnClick = btnDefaultClick
  end
  object rbtnContinueFromPrevSection: TRadioButton
    Left = 13
    Top = 69
    Width = 228
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Continue from Previous Section'
    Checked = True
    TabOrder = 5
    TabStop = True
    OnClick = rbtnContinueFromPrevSectionClick
  end
  object rbtnStartAt: TRadioButton
    Left = 13
    Top = 96
    Width = 92
    Height = 17
    Caption = 'Start &at:'
    TabOrder = 6
    OnClick = rbtnStartAtClick
  end
end
