object WPTColorSelector: TWPTColorSelector
  Left = 41
  Top = 158
  BorderStyle = bsNone
  Caption = 'Colors'
  ClientHeight = 90
  ClientWidth = 252
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = True
  OnKeyPress = FormKeyPress
  OnMouseMove = FormMouseMove
  OnMouseUp = FormMouseUp
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Shape1: TShape
    Left = 0
    Top = 0
    Width = 252
    Height = 90
    Brush.Color = clBtnFace
  end
  object PaintBox1: TPaintBox
    Left = 6
    Top = 6
    Width = 190
    Height = 44
    OnPaint = PaintBox1Paint
  end
end
