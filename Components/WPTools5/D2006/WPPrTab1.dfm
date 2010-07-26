object WPTableSelect: TWPTableSelect
  Left = 337
  Top = 158
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'New Table'
  ClientHeight = 143
  ClientWidth = 210
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Scaled = False
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnMouseMove = FormMouseMove
  OnPaint = FormPaint
  OnResize = FormResize
  OnShow = FormResize
  PixelsPerInch = 120
  TextHeight = 16
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 210
    Height = 110
    BevelInner = bvLowered
    Color = clWindow
    TabOrder = 0
    object PaintBox1: TPaintBox
      Left = 2
      Top = 2
      Width = 206
      Height = 106
      Align = alClient
      OnClick = PaintBox1Click
      OnDblClick = PaintBox1DblClick
      OnMouseDown = PaintBox1MouseDown
      OnMouseMove = PaintBox1MouseMove
      OnMouseUp = PaintBox1MouseUp
      OnPaint = FormPaint
    end
  end
  object Status: TPanel
    Left = 0
    Top = 112
    Width = 210
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object ShowBord: TSpeedButton
      Left = 7
      Top = 5
      Width = 21
      Height = 21
      Hint = 'Toggles Grid Lines On/Off'
      AllowAllUp = True
      GroupIndex = 1
      Down = True
      Glyph.Data = {
        F6000000424DF600000000000000760000002800000010000000100000000100
        0400000000008000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFFFFFFFFFFF
        FFFFF00000000000000FF00000000000000FF00FF0FFFFFFFFFFF00FFF03FFFF
        FFFFF00FFF3B0FFFFFFFF00FFFF3B3FFFFFFF00FFFFF3B0FFFFFF00FFFFFF393
        FFFFF00FFFFFFF390FFFF00FFFFFFFF3B3FFF00FFFFFFFFF3B0FF00FFFFFFFFF
        F3B3F00FFFFFFFFFFF30F00FFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
      ParentShowHint = False
      ShowHint = True
    end
    object Button1: TBitBtn
      Left = 179
      Top = 5
      Width = 21
      Height = 21
      Hint = 'Forget It'
      Anchors = [akTop, akRight]
      Caption = 'X'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -16
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ModalResult = 2
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
end
