object WPSymbolDialog: TWPSymbolDialog
  Left = 45
  Top = 142
  Width = 607
  Height = 244
  Caption = 'Symbol'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnMouseMove = FormMouseMove
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object labFont: TLabel
    Left = 18
    Top = 7
    Width = 26
    Height = 16
    Caption = 'Font'
  end
  object CharacterGrid: TStringGrid
    Left = 14
    Top = 40
    Width = 472
    Height = 158
    ColCount = 32
    DefaultColWidth = 13
    DefaultRowHeight = 16
    FixedCols = 0
    RowCount = 7
    FixedRows = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -15
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected]
    ParentFont = False
    ScrollBars = ssNone
    TabOrder = 0
    OnClick = CharacterGridClick
    OnDblClick = CharacterGridDblClick
    OnMouseMove = CharacterGridMouseMove
  end
  object Panel1: TPanel
    Left = 489
    Top = 0
    Width = 110
    Height = 213
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object CharCode: TLabel
      Left = 12
      Top = 96
      Width = 88
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = '  '
    end
    object Bevel2: TBevel
      Left = 14
      Top = 10
      Width = 87
      Height = 84
    end
    object PaintBox1: TPaintBox
      Left = 18
      Top = 14
      Width = 77
      Height = 72
      Visible = False
      OnPaint = PaintBox1Paint
    end
    object OKButton: TButton
      Left = 12
      Top = 134
      Width = 93
      Height = 31
      Anchors = [akLeft, akBottom]
      Caption = 'OK'
      TabOrder = 0
      OnClick = OKButtonClick
    end
    object btnCancel: TButton
      Left = 12
      Top = 174
      Width = 93
      Height = 30
      Anchors = [akLeft, akBottom]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object cbxFontList: TComboBox
    Left = 56
    Top = 8
    Width = 426
    Height = 24
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 16
    TabOrder = 2
    OnChange = cbxFontListChange
    OnClick = cbxFontListChange
  end
end
