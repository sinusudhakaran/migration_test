object cxSSStyleDesigner: TcxSSStyleDesigner
  Left = 467
  Top = 63
  BorderStyle = bsDialog
  ClientHeight = 343
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pcSheets: TPageControl
    Left = 0
    Top = 0
    Width = 392
    Height = 305
    ActivePage = tbsCellStyle
    Align = alTop
    TabOrder = 0
    object tbsCellStyle: TTabSheet
      object gbStyle: TGroupBox
        Left = 0
        Top = 0
        Width = 130
        Height = 277
        Align = alLeft
        TabOrder = 0
        object rbNumber: TRadioButton
          Tag = 1
          Left = 12
          Top = 53
          Width = 113
          Height = 17
          TabOrder = 1
          OnClick = rbStyleTypeClick
        end
        object rbGeneral: TRadioButton
          Left = 12
          Top = 28
          Width = 113
          Height = 17
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbStyleTypeClick
        end
        object rbDateTime: TRadioButton
          Tag = 3
          Left = 12
          Top = 103
          Width = 113
          Height = 17
          TabOrder = 3
          OnClick = rbStyleTypeClick
        end
        object rbText: TRadioButton
          Tag = 4
          Left = 12
          Top = 128
          Width = 113
          Height = 17
          TabOrder = 4
          OnClick = rbStyleTypeClick
        end
        object rbCurrency: TRadioButton
          Tag = 2
          Left = 12
          Top = 78
          Width = 113
          Height = 17
          TabOrder = 2
          OnClick = rbStyleTypeClick
        end
      end
      object gbStyleSet: TGroupBox
        Left = 130
        Top = 0
        Width = 254
        Height = 277
        Align = alClient
        TabOrder = 1
        object lbStyleDescription: TLabel
          Left = 10
          Top = 24
          Width = 230
          Height = 46
          AutoSize = False
          WordWrap = True
        end
        object lbStyleTypes: TcxSSStyleListBox
          Left = 2
          Top = 78
          Width = 250
          Height = 197
          Style = lbOwnerDrawFixed
          Align = alBottom
          ItemHeight = 16
          TabOrder = 0
          Visible = False
        end
      end
    end
    object tbsAlign: TTabSheet
      object lbHorzAlign: TLabel
        Left = 16
        Top = 32
        Width = 3
        Height = 13
        FocusControl = cbxHorzAlign
      end
      object lbVertAlign: TLabel
        Left = 16
        Top = 101
        Width = 3
        Height = 13
        FocusControl = cbxVertAlign
      end
      object bvlTextAlignment: TcxLabelBevel
        Left = 11
        Top = 8
        Width = 365
        Height = 15
      end
      object bvlTextControl: TcxLabelBevel
        Left = 11
        Top = 163
        Width = 365
        Height = 15
      end
      object cbxHorzAlign: TComboBox
        Left = 16
        Top = 52
        Width = 165
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 0
        OnChange = OnAlignmentChange
      end
      object cbxVertAlign: TComboBox
        Tag = 1
        Left = 16
        Top = 120
        Width = 165
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 1
        OnChange = OnAlignmentChange
      end
      object chxWordWrap: TCheckBox
        Tag = 2
        Left = 16
        Top = 189
        Width = 97
        Height = 17
        TabOrder = 2
        OnClick = OnAlignmentChange
      end
      object btnFont: TButton
        Tag = 3
        Left = 249
        Top = 187
        Width = 81
        Height = 22
        TabOrder = 4
        OnClick = OnbtnFontClick
      end
      object gbFontSample: TGroupBox
        Left = 201
        Top = 46
        Width = 164
        Height = 97
        TabOrder = 3
        object ppFontPaint: TcxPaintPanel
          Left = 2
          Top = 15
          Width = 160
          Height = 80
          OnPaint = ppFontPaintPaint
          Align = alClient
        end
      end
    end
    object tbsBorder: TTabSheet
      ImageIndex = 1
      object lbNone: TLabel
        Left = 70
        Top = 65
        Width = 3
        Height = 13
        Alignment = taCenter
        FocusControl = btnNone
      end
      object lbOuter: TLabel
        Left = 126
        Top = 65
        Width = 3
        Height = 13
        Alignment = taCenter
        FocusControl = btnOuter
      end
      object lbInner: TLabel
        Left = 186
        Top = 65
        Width = 3
        Height = 13
        Alignment = taCenter
        FocusControl = btnInner
      end
      object bvlBorders: TcxLabelBevel
        Left = 13
        Top = 3
        Width = 218
        Height = 14
      end
      object bvlItems: TcxLabelBevel
        Left = 13
        Top = 79
        Width = 218
        Height = 14
      end
      object btnTop: TBitBtn
        Tag = 7
        Left = 19
        Top = 98
        Width = 26
        Height = 26
        TabOrder = 3
        OnClick = OnClickBorderButtons
        Glyph.Data = {
          EE000000424DEE0000000000000076000000280000000F0000000F0000000100
          0400000000007800000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7770787878787878787077777777777777707877777877777870777777777777
          7770787777787777787077777777777777707878787878787870777777777777
          7770787777787777787077777777777777707877777877777870777777777777
          777070000000000000707777777777777770}
        Style = bsNew
      end
      object btnVMiddle: TBitBtn
        Tag = 8
        Left = 19
        Top = 147
        Width = 26
        Height = 26
        TabOrder = 4
        OnClick = OnClickBorderButtons
        Glyph.Data = {
          EE000000424DEE0000000000000076000000280000000F0000000F0000000100
          0400000000007800000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7770787878787878787077777777777777707877777877777870777777777777
          7770787777787777787077777777777777707000000000000070777777777777
          7770787777787777787077777777777777707877777877777870777777777777
          777078787878787878707777777777777770}
        Style = bsNew
      end
      object btnDown: TBitBtn
        Tag = 9
        Left = 19
        Top = 196
        Width = 26
        Height = 26
        TabOrder = 5
        OnClick = OnClickBorderButtons
        Glyph.Data = {
          EE000000424DEE0000000000000076000000280000000F0000000F0000000100
          0400000000007800000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7770700000000000007077777777777777707877777877777870777777777777
          7770787777787777787077777777777777707878787878787870777777777777
          7770787777787777787077777777777777707877777877777870777777777777
          777078787878787878707777777777777770}
        Style = bsNew
      end
      object btnRight: TBitBtn
        Tag = 12
        Left = 191
        Top = 237
        Width = 26
        Height = 26
        TabOrder = 8
        OnClick = OnClickBorderButtons
        Glyph.Data = {
          EE000000424DEE0000000000000076000000280000000F0000000F0000000100
          0400000000007800000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7770787878787878707077777777777770707877777877777070777777777777
          7070787777787777707077777777777770707878787878787070777777777777
          7070787777787777707077777777777770707877777877777070777777777777
          707078787878787870707777777777777770}
        Style = bsNew
      end
      object btnMiddle: TBitBtn
        Tag = 11
        Left = 129
        Top = 237
        Width = 26
        Height = 26
        TabOrder = 7
        OnClick = OnClickBorderButtons
        Glyph.Data = {
          EE000000424DEE0000000000000076000000280000000F0000000F0000000100
          0400000000007800000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7770787878707878787077777770777777707877777077777870777777707777
          7770787777707777787077777770777777707878787078787870777777707777
          7770787777707777787077777770777777707877777077777870777777707777
          777078787870787878707777777777777770}
        Style = bsNew
      end
      object btnLeft: TBitBtn
        Tag = 10
        Left = 67
        Top = 237
        Width = 26
        Height = 26
        TabOrder = 6
        OnClick = OnClickBorderButtons
        Glyph.Data = {
          EE000000424DEE0000000000000076000000280000000F0000000F0000000100
          0400000000007800000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7770707878787878787070777777777777707077777877777870707777777777
          7770707777787777787070777777777777707078787878787870707777777777
          7770707777787777787070777777777777707077777877777870707777777777
          777070787878787878707777777777777770}
        Style = bsNew
      end
      object btnNone: TBitBtn
        Tag = 4
        Left = 65
        Top = 21
        Width = 40
        Height = 40
        TabOrder = 0
        OnClick = OnClickBorderButtons
        Glyph.Data = {
          56020000424D560200000000000076000000280000001E0000001E0000000100
          040000000000E001000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777777777777777770077777777777777777777777777777700778877887788
          7788778877887788770077887788778877887788778877887700777777777777
          7777777777777777770077777777777777777777777777777700778877777777
          7788777777777788770077887777777777887777777777887700777777777777
          7777777777777777770077777777777777777777777777777700778877777777
          7788777777777788770077887777777777887777777777887700777777777777
          7777777777777777770077777777777777777777777777777700778877887788
          7788778877887788770077887788778877887788778877887700777777777777
          7777777777777777770077777777777777777777777777777700778877777777
          7788777777777788770077887777777777887777777777887700777777777777
          7777777777777777770077777777777777777777777777777700778877777777
          7788777777777788770077887777777777887777777777887700777777777777
          7777777777777777770077777777777777777777777777777700778877887788
          7788778877887788770077887788778877887788778877887700777777777777
          7777777777777777770077777777777777777777777777777700}
      end
      object btnOuter: TBitBtn
        Tag = 5
        Left = 122
        Top = 21
        Width = 40
        Height = 40
        TabOrder = 1
        OnClick = OnClickBorderButtons
        Glyph.Data = {
          56020000424D560200000000000076000000280000001E0000001E0000000100
          040000000000E001000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777777777777777770077777777777777777777777777777700770000000000
          0000000000000000770077000000000000000000000000007700770077777777
          7777777777777700770077007777777777777777777777007700770077777777
          7788777777777700770077007777777777887777777777007700770077777777
          7777777777777700770077007777777777777777777777007700770077777777
          7788777777777700770077007777777777887777777777007700770077777777
          7777777777777700770077007777777777777777777777007700770077887788
          7788778877887700770077007788778877887788778877007700770077777777
          7777777777777700770077007777777777777777777777007700770077777777
          7788777777777700770077007777777777887777777777007700770077777777
          7777777777777700770077007777777777777777777777007700770077777777
          7788777777777700770077007777777777887777777777007700770077777777
          7777777777777700770077007777777777777777777777007700770000000000
          0000000000000000770077000000000000000000000000007700777777777777
          7777777777777777770077777777777777777777777777777700}
      end
      object btnInner: TBitBtn
        Tag = 6
        Left = 179
        Top = 21
        Width = 40
        Height = 40
        TabOrder = 2
        OnClick = OnClickBorderButtons
        Glyph.Data = {
          56020000424D560200000000000076000000280000001E0000001E0000000100
          040000000000E001000000000000000000001000000010000000000000000000
          80000080000000808000800000008000800080800000C0C0C000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
          7777777777777777770077777777777777777777777777777700778877887788
          7700778877887788770077887788778877007788778877887700777777777777
          7700777777777777770077777777777777007777777777777700778877777777
          7700777777777788770077887777777777007777777777887700777777777777
          7700777777777777770077777777777777007777777777777700778877777777
          7700777777777788770077887777777777007777777777887700777777777777
          7700777777777777770077777777777777007777777777777700770000000000
          0000000000000000770077000000000000000000000000007700777777777777
          7700777777777777770077777777777777007777777777777700778877777777
          7700777777777788770077887777777777007777777777887700777777777777
          7700777777777777770077777777777777007777777777777700778877777777
          7700777777777788770077887777777777007777777777887700777777777777
          7700777777777777770077777777777777007777777777777700778877887788
          7700778877887788770077887788778877007788778877887700777777777777
          7777777777777777770077777777777777777777777777777700}
      end
      object gbBorderStyle: TGroupBox
        Left = 237
        Top = 6
        Width = 133
        Height = 240
        TabOrder = 9
        TabStop = True
        object lbStyle: TLabel
          Left = 9
          Top = 18
          Width = 3
          Height = 13
          FocusControl = drwgLineStyle
        end
        object lbColor: TLabel
          Left = 7
          Top = 198
          Width = 3
          Height = 13
          FocusControl = cbxBorderColor
        end
        object drwgLineStyle: TDrawGrid
          Left = 2
          Top = 36
          Width = 129
          Height = 156
          ColCount = 2
          DefaultColWidth = 62
          DefaultRowHeight = 21
          FixedCols = 0
          RowCount = 7
          FixedRows = 0
          GridLineWidth = 0
          Options = [goVertLine, goHorzLine, goDrawFocusSelected]
          ScrollBars = ssNone
          TabOrder = 0
          OnDrawCell = drwgLineStyleDrawCell
          OnSelectCell = drwgLineStyleSelectCell
        end
        object cbxBorderColor: TcxSSColorComboBox
          Left = 2
          Top = 216
          Width = 129
          Height = 22
          AutomaticColor = 0
          IncludeBrushes = False
          SelectedBrush = fsSolid
          SelectedColor = 248
          Align = alBottom
        end
      end
      object ppPaintBorders: TcxPaintPanel
        Left = 67
        Top = 98
        Width = 150
        Height = 124
        OnPaint = ppPaintBordersPaint
        OnMouseDown = ppPaintBordersMouseDown
      end
    end
    object tbsPatterns: TTabSheet
      ImageIndex = 2
      object lbPatColor: TLabel
        Left = 12
        Top = 26
        Width = 3
        Height = 13
        FocusControl = cplPatColor
      end
      object lbPattern: TLabel
        Left = 16
        Top = 219
        Width = 3
        Height = 13
        FocusControl = cbxPattern
      end
      object bvlCellShading: TcxLabelBevel
        Left = 11
        Top = 8
        Width = 365
        Height = 15
      end
      object gbPatSample: TGroupBox
        Left = 193
        Top = 31
        Width = 168
        Height = 122
        TabOrder = 0
        object ppPattern: TcxPaintPanel
          Left = 2
          Top = 15
          Width = 164
          Height = 105
          OnPaint = ppPatternPaint
          Align = alClient
        end
      end
      object cplPatColor: TcxSSColorPanel
        Tag = 13
        Left = 12
        Top = 40
        Width = 158
        Height = 181
        AutomaticColor = 0
        IncludeBrushes = False
        OnChange = OnPatternChange
        SelectedBrush = fsSolid
        SelectedColor = 248
      end
      object cbxPattern: TcxSSColorComboBox
        Tag = 14
        Left = 16
        Top = 237
        Width = 151
        Height = 23
        AutomaticColor = 0
        IncludeBrushes = True
        OnChange = OnPatternChange
        SelectedBrush = fsSolid
        SelectedColor = 248
      end
    end
  end
  object btnOk: TButton
    Left = 202
    Top = 313
    Width = 85
    Height = 24
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 298
    Top = 313
    Width = 85
    Height = 24
    ModalResult = 2
    TabOrder = 2
  end
  object FontDialog: TFontDialog
    Tag = 3
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 352
  end
end
