object dxTLReportLinkDesignWindow: TdxTLReportLinkDesignWindow
  Left = 485
  Top = 220
  BorderStyle = bsDialog
  Caption = 'dxTLReportLinkDesigner'
  ClientHeight = 434
  ClientWidth = 582
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
  object PageControl1: TPageControl
    Left = 4
    Top = 4
    Width = 574
    Height = 395
    ActivePage = tshColors
    TabOrder = 0
    OnChange = PageControl1Change
    object tshOptions: TTabSheet
      Caption = '&Options'
      object Bevel11: TBevel
        Left = 46
        Top = 13
        Width = 221
        Height = 4
        Shape = bsBottomLine
      end
      object imgShow: TImage
        Left = 9
        Top = 35
        Width = 32
        Height = 32
        Center = True
        Picture.Data = {
          07544269746D617076020000424D760200000000000076000000280000002000
          0000200000000100040000000000000200000000000000000000100000001000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00888888888888888888888888888888888888888888888888888888888888
          8888888888000000000000000000000888888888880FFFFFFFFFFFFFFFFFFFC8
          8C888888880F77777700000077777FCC8CC88888880F77777777777777777FCC
          CCCC8888880FFFFFFFFFFFFFFFFFFFCC8CC88888880F77777777777777777FC8
          8C888888880F7FFFFF7FFFFFFFFF7F0888888888880F7F000F7F0000000F7F08
          88888888880F7FFFFF7FFFFFFFFF7F0888888888880F77777777777777777F08
          88888888880F7FFFFF7FFFFFFFFF7F0888888888880F7F000F7F00000FFF7F08
          88888888880F7FFFFF7FFFFFFFFF7F0888888888880F77777777777777777F08
          88888888880F7FFFFF7FFFFFFFFF7F0888888888880F7F000F7F0000000F7F08
          88888888880F7FFFFF7FFFFFFFFF7F0888888888880F77777777777777777F08
          88888888880F7FFFFF7FFFFFFFFF7F0888888888880F7F000F7F00000F0F7F08
          88888888880F7FFFFF7FFFFFFFFF7F08888888C888CF77777777777777777F08
          88888CC8CCCFFFFFFFFFFFFFFFFFFF088888CCCCCCCF70000000770000007F08
          88888CC8CCCF77777777777777777F08888888C888CFFFFFFFFFFFFFFFFFFF08
          8888888888000000000000000000000888888888888888888888888888888888
          8888888888888888888888888888888888888888888888888888888888888888
          8888}
        Transparent = True
      end
      object lblShow: TLabel
        Left = 6
        Top = 9
        Width = 26
        Height = 13
        Caption = 'Show'
      end
      object Bevel16: TBevel
        Left = 89
        Top = 107
        Width = 178
        Height = 4
        Shape = bsBottomLine
      end
      object bvlShowImages: TBevel
        Left = 89
        Top = 223
        Width = 178
        Height = 4
        Shape = bsBottomLine
      end
      object Bevel2: TBevel
        Left = 89
        Top = 164
        Width = 178
        Height = 3
        Shape = bsBottomLine
      end
      object Bevel10: TBevel
        Left = 90
        Top = 282
        Width = 177
        Height = 4
        Shape = bsBottomLine
      end
      object Image1: TImage
        Left = 9
        Top = 303
        Width = 32
        Height = 32
        Picture.Data = {
          07544269746D617076020000424D760200000000000076000000280000002000
          0000200000000100040000000000000200000000000000000000100000001000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00888888888888888888888888888888888777777777777777708888888888
          888887FFFFFFFFFFFFFFF08888888888888887F7777777777777F07777708888
          888887F7777777777777F0FFFFF08888888887F7777777777777F07777F07777
          708887FFFFFFFFFFFFFFF07777F0FFFFF08887F777777777777FF07777F07777
          F08887FFFFFFFFFFFFFFF0FFFFF07777F08887F77777777777FFF077FFF07777
          F08887FFFFFFFFFFFFFFF0FFFFF0FFFFF08887F777777777FFFFF0777FF07FFF
          F08887FFFFFFFFFFFFFFF0FFFFF0FFFFF08887F777777FFFFFFFF07FFFF0777F
          F08887FFFFFFFFFFFFFFF0FFFFF0FFFFF08887F7777777777FFFF0777FF0777F
          F08887FFFFFFFFFFFFFFF0FFFFF0FFFFF08887F7777777777FFFF077FFF07FFF
          F08887FFFFFFFFFFFFFFF0FFFFF0FFFFF08887F7777777777777F077FFF077FF
          F08887F7777777777777F0FFFFF0FFFFF08887F7777777777777F0FFFFF07FFF
          F08887FFFFFFFFFFFFFFF07777F0FFFFF0888000000000000000007777F077FF
          F08888888887F7777777777777F0FFFFF08888888887FFFFFFFFFFFFFFF07777
          F0888888888000000000000000007777F08888888888888887F7777777777777
          F08888888888888887FFFFFFFFFFFFFFF0888888888888888000000000000000
          0088888888888888888888888888888888888888888888888888888888888888
          8888}
        Transparent = True
      end
      object lblOnEveryPage: TLabel
        Left = 8
        Top = 278
        Width = 72
        Height = 13
        Caption = 'On Every Page'
      end
      object chbxShowGrid: TCheckBox
        Tag = 6
        Left = 90
        Top = 177
        Width = 165
        Height = 17
        Caption = '&Grid Lines'
        TabOrder = 6
        OnClick = chbxShowClick
      end
      object chbxShowNodeGrid: TCheckBox
        Tag = 5
        Left = 90
        Top = 198
        Width = 165
        Height = 17
        Caption = 'Node Grid Lines'
        TabOrder = 7
        OnClick = chbxShowClick
      end
      object chbxShowBands: TCheckBox
        Left = 90
        Top = 23
        Width = 165
        Height = 17
        Caption = 'Ba&nds'
        TabOrder = 0
        OnClick = chbxShowClick
      end
      object chbxShowHeaders: TCheckBox
        Tag = 1
        Left = 90
        Top = 43
        Width = 165
        Height = 17
        Caption = '&Headers'
        TabOrder = 1
        OnClick = chbxShowClick
      end
      object chbxShowFooters: TCheckBox
        Tag = 2
        Left = 90
        Top = 64
        Width = 165
        Height = 17
        Caption = 'Foo&ters'
        TabOrder = 2
        OnClick = chbxShowClick
      end
      object chbxShowGroupFooters: TCheckBox
        Tag = 3
        Left = 90
        Top = 84
        Width = 165
        Height = 17
        Caption = 'G&roup Footers'
        TabOrder = 3
        OnClick = chbxShowClick
      end
      object chbxShowStateImages: TCheckBox
        Tag = 9
        Left = 90
        Top = 236
        Width = 165
        Height = 17
        Caption = 'State Images'
        TabOrder = 8
        OnClick = chbxShowClick
      end
      object chbxShowImages: TCheckBox
        Tag = 8
        Left = 90
        Top = 256
        Width = 165
        Height = 17
        Caption = 'Images'
        TabOrder = 9
        OnClick = chbxShowClick
      end
      object chbxShowExpandButtons: TCheckBox
        Tag = 17
        Left = 90
        Top = 119
        Width = 165
        Height = 17
        Caption = 'Expand Buttons'
        TabOrder = 4
        OnClick = chbxShowClick
      end
      object chbxShowTreeLines: TCheckBox
        Tag = 16
        Left = 90
        Top = 140
        Width = 165
        Height = 17
        Caption = 'TreeLines'
        TabOrder = 5
        OnClick = chbxShowClick
      end
      object chbxBandsOnEveryPage: TCheckBox
        Left = 90
        Top = 300
        Width = 165
        Height = 17
        Caption = 'Ba&nds On Every Page'
        TabOrder = 10
        OnClick = chbxBandsOnEveryPageClick
      end
      object chbxHeadersOnEveryPage: TCheckBox
        Left = 90
        Top = 322
        Width = 165
        Height = 17
        Caption = 'Headers On Every &Page'
        TabOrder = 11
        OnClick = chbxHeadersOnEveryPageClick
      end
      object chbxFootersOnEveryPage: TCheckBox
        Left = 90
        Top = 344
        Width = 165
        Height = 17
        Caption = 'Footers On E&very Page'
        TabOrder = 12
        OnClick = chbxFootersOnEveryPageClick
      end
      object lblPreviewWindow: TStaticText
        Left = 279
        Top = 0
        Width = 82
        Height = 14
        AutoSize = False
        Caption = 'Preview'
        TabOrder = 13
      end
    end
    object tshColors: TTabSheet
      Caption = '&Color'
      object lblGridlineColor: TLabel
        Left = 9
        Top = 296
        Width = 74
        Height = 13
        Caption = '&Grid Line color :'
        OnClick = lblColorClick
      end
      object bvlGridLineColorHolder: TBevel
        Left = 122
        Top = 291
        Width = 145
        Height = 22
        Visible = False
      end
      object bvlTreeLineColorHolder: TBevel
        Left = 122
        Top = 320
        Width = 145
        Height = 22
      end
      object lblTreeLineColor: TLabel
        Left = 9
        Top = 325
        Width = 78
        Height = 13
        Caption = 'TreeLines Color:'
      end
      object lblDrawMode: TLabel
        Left = 7
        Top = 21
        Width = 58
        Height = 13
        Caption = 'Draw &Mode:'
        FocusControl = cbxDrawMode
        OnClick = lblDrawModeClick
      end
      object gbxFixedTransparent: TGroupBox
        Left = 4
        Top = 162
        Width = 269
        Height = 121
        Caption = '   '
        TabOrder = 4
        object lblBandColor: TLabel
          Left = 5
          Top = 23
          Width = 60
          Height = 13
          Caption = '&Band color : '
          OnClick = lblColorClick
        end
        object lblHeaderColor: TLabel
          Left = 5
          Top = 47
          Width = 71
          Height = 13
          Caption = '&Header color : '
          OnClick = lblColorClick
        end
        object lblRowFooterColor: TLabel
          Left = 5
          Top = 96
          Width = 94
          Height = 13
          Caption = 'Gro&upFooter color :'
          OnClick = lblColorClick
        end
        object bvlBandColorHolder: TBevel
          Tag = 2
          Left = 118
          Top = 17
          Width = 145
          Height = 22
          Visible = False
        end
        object bvlHeaderColorHolder: TBevel
          Left = 118
          Top = 42
          Width = 145
          Height = 22
          Visible = False
        end
        object bvlRowFooterColorHolder: TBevel
          Left = 118
          Top = 92
          Width = 145
          Height = 22
          Visible = False
        end
        object lblGroupNodeColor: TLabel
          Left = 5
          Top = 72
          Width = 87
          Height = 13
          Caption = 'Group&Node color :'
          OnClick = lblColorClick
        end
        object bvlGroupNodeColorHolder: TBevel
          Left = 118
          Top = 67
          Width = 145
          Height = 22
          Visible = False
        end
      end
      object gbxTransparent: TGroupBox
        Left = 4
        Top = 51
        Width = 269
        Height = 104
        Caption = '  '
        TabOrder = 2
        object lblColor: TLabel
          Left = 5
          Top = 23
          Width = 29
          Height = 13
          Caption = 'C&olor:'
          OnClick = lblColorClick
        end
        object bvlColorHolder: TBevel
          Left = 118
          Top = 18
          Width = 145
          Height = 22
          Visible = False
        end
        object lblPreviewColor: TLabel
          Left = 5
          Top = 77
          Width = 71
          Height = 13
          Caption = '&Preview color :'
          OnClick = lblColorClick
        end
        object bvlPreviewColorHolder: TBevel
          Tag = 1
          Left = 118
          Top = 72
          Width = 145
          Height = 22
          Visible = False
        end
        object lblEvenColor: TLabel
          Left = 5
          Top = 47
          Width = 59
          Height = 13
          Caption = 'Even Color :'
          OnClick = lblColorClick
        end
        object bvlEvenColorHolder: TBevel
          Left = 118
          Top = 43
          Width = 145
          Height = 22
          Visible = False
        end
      end
      object chbxTransparent: TCheckBox
        Left = 15
        Top = 49
        Width = 15
        Height = 17
        Caption = ' Tr&ansparent  '
        TabOrder = 1
        OnClick = chbxTransparentClick
      end
      object chbxFixedTransparent: TCheckBox
        Tag = 1
        Left = 15
        Top = 160
        Width = 15
        Height = 17
        TabOrder = 3
        OnClick = chbxTransparentClick
      end
      object cbxDrawMode: TComboBox
        Left = 104
        Top = 15
        Width = 169
        Height = 25
        Style = csOwnerDrawFixed
        ItemHeight = 19
        TabOrder = 0
        OnChange = cbxDrawModeChange
        OnDrawItem = cbxDrawModeDrawItem
        Items.Strings = (
          'Simpe'
          'Odd\Even Rows Mode'
          'Borrow From Source')
      end
      object stTransparent: TStaticText
        Left = 30
        Top = 50
        Width = 76
        Height = 17
        Caption = ' &Transparent '
        FocusControl = chbxTransparent
        TabOrder = 5
        OnClick = stTransparentClick
      end
      object stFixedTransparent: TStaticText
        Left = 30
        Top = 161
        Width = 98
        Height = 17
        Caption = ' Fixed Transparent '
        FocusControl = chbxFixedTransparent
        TabOrder = 6
        OnClick = stFixedTransparentClick
      end
    end
    object tshFonts: TTabSheet
      Caption = '&Font'
      object btnChangeFont: TButton
        Left = 6
        Top = 189
        Width = 116
        Height = 23
        Caption = 'Change Fo&nt ...'
        TabOrder = 0
        OnClick = btnChangeFontClick
      end
      object lbxFonts: TListBox
        Left = 6
        Top = 16
        Width = 268
        Height = 167
        Style = lbOwnerDrawFixed
        ItemHeight = 16
        MultiSelect = True
        ParentShowHint = False
        PopupMenu = pmChangeFont
        ShowHint = True
        TabOrder = 1
        OnClick = lbxFontsClick
        OnDblClick = lbxFontsDblClick
        OnDrawItem = lbxFontsDrawItem
        OnKeyDown = FontsKeyDown
        OnMouseMove = FontsMouseMove
      end
    end
    object tshBehaviors: TTabSheet
      Caption = '&Behaviors'
      object Bevel12: TBevel
        Left = 57
        Top = 13
        Width = 210
        Height = 4
        Shape = bsBottomLine
      end
      object Bevel13: TBevel
        Left = 63
        Top = 85
        Width = 204
        Height = 4
        Shape = bsBottomLine
      end
      object Image3: TImage
        Left = 9
        Top = 33
        Width = 64
        Height = 32
        Picture.Data = {
          07544269746D617076040000424D760400000000000076000000280000004000
          0000200000000100040000000000000400000000000000000000100000001000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00887777777777777777777777778888888888888777777777777777777777
          77788000000000000000000000000788C8888C88880000000000000000000000
          00788088888887888888888888880788CCCC8CC8880FFFFFFFFFFFFFFFFFFFFF
          F0788088888887887777778888880788CCCCCCCC880F77777777777777777777
          F0788087777787887777777777880788CCCC8CC8880F7FFF77777FF77777FFF7
          F0788088888887888888888888880788C8888C88880F77777777777777777777
          F078807777777777777777777777078888888888880FFFFFFFFFFFFFFFFFFFFF
          F07880FFFFFFF7FFFFFFFFFFFFFF078888888888880F77777777777777777777
          F07880F00000F7FF0000000000FF078888888888880F7F8888888888F7F888F7
          F07880FFFFFFF7FFFFFFFFFFFFFF078888888888880F7FFFFFFFFFFFF7FFFFF7
          F078807777777777777777777777078888888888880F77777777777777777777
          F078808888888788888888888888078888888888880F7F888888888FF7F888F7
          F0788087777887887777777788880788C8888C88880F7FFFFFFFFFFFF7FFFFF7
          F0788088888887888888888888880788CCCC8CC8880F77777777777777777777
          F0788077777777777777777777770788CCCCCCCC880F7F888888888FF7F888F7
          F0788088888887888888888888880788CCCC8CC8880F7FFFFFFFFFFFF7FFFFF7
          F0788087777787887777777788880788C8888C88880F77777777777777777777
          F078808888888788888888888888078888888888880F7F8888888888F7F888F7
          F078807777777777777777777777078888888888880F7FFFFFFFFFFFF7FFFFF7
          F07880FFFFFFF7FFFFFFFFFFFFFF078888888888880F77777777777777777777
          F07880F0000FF7FF0000000000FF078888888888880F7F888888888FF7F888F7
          F07880FFFFFFF7FFFFFFFFFFFFFF078888888888880F7FFFFFFFFFFFF7FFFFF7
          F078807777777777777777777777078888888888880F77777777777777777777
          F07880FFFFFFF7FFFFFFFFFFFFFF078888888888880F7F888888888FF7F888F7
          F07880F00000F7FF0000000000FF078888888888880F7FFFFFFFFFFFF7FFFFF7
          F07880FFFFFFF7FFFFFFFFFFFFFF078888888888880F77777777777777777777
          F0788000000000000000000000000788C8888C88880FFFFFFFFFFFFFFFFFFFFF
          F07880F8888880F88888888888880788CCCC8CC8880F77777777777777777777
          F07880F8000080F80000008888880788CCCCCCCC880F77777777777777777777
          F07880FFFFFFF0FFFFFFFFFFFFFF0788CCCC8CC8880FFFFFFFFFFFFFFFFFFFFF
          F0788000000000000000000000000888C8888C88880000000000000000000000
          0088888888888888888888888888888888888888888888888888888888888888
          8888}
        Transparent = True
      end
      object Image4: TImage
        Left = 9
        Top = 104
        Width = 64
        Height = 32
        Picture.Data = {
          07544269746D617076040000424D760400000000000076000000280000004000
          0000200000000100040000000000000400000000000000000000100000001000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00887777777777777777777777778888888888888777777777777777777777
          7778800000000000000000000000078888888888880000000000000000000000
          007880FFF7777777777777777777078888888888880FFFFFFFFFFFFFFFFFFFFF
          F07880FFF7FFFFF7FFFFFFFFFFFF078888888888880F77777777777777777777
          F07880F8F7F777F7F777777777FF078888888888880F7FF777777FFF77777FF7
          F07880FFF7FFFFF7FFFFFFFFFFFF078888888888880F77777777777777777777
          F07880F8F7777777777777777777078888888888880FFFFFFFFFFFFFFFFFFFFF
          F07880F8F7FFFFF7FFFFFFFFFFFF078888888888880F77777777777777777777
          F07880F8F7F777F7F777777777FF078888888888880F7F7F8888FF7F88888FF7
          F07880FFF7FFFFF7FFFFFFFFFFFF078888888888880F7F777777777777777777
          F07880F8F7777777777777777777078888888888880F7F7F888FFF7F888888F7
          F07880FFFFFFFFFFFFFFFFFFFFFF078888888888880F7F777777777777777777
          F07880F0F7777777FFFFFFFFFFFF078888888888880F7F7F8888FF7F888888F7
          F07880FFFFFFFFFFFFFFFFFFFFFF078888888888880F7F777777777777777777
          F0788077777777777777777777770788C8888C88880F7FF888888FFFFFFFFFF7
          F07880FFFFFFFFFFFFFFFFFFFFFF0788CCCC8CC8880F7FFFFFFFFFFFFFFFFFF7
          F07880F0F7777777FFFFFFFFFFFF0788CCCCCCCC880F77777777777777777777
          F07880FFFFFFFFFFFFFFFFFFFFFF0788CCCC8CC8880F7F7F8888FF7F88888FF7
          F0788077777777777777777777770788C8888C88880F7F777777777777777777
          F07880FFFFFFFFFFFFFFFFFFFFFF078888888888880F7F7F8888FF7F888888F7
          F07880F0F7777777FFFFFFFFFFFF078888888888880F7F777777777777777777
          F07880FFFFFFFFFFFFFFFFFFFFFF0788C8888C88880F7F7F8888FF7F888888F7
          F0788077777777777777777777770788CCCC8CC8880F7F777777777777777777
          F07880FFFFFFFFFFFFFFFFFFFFFF0788CCCCCCCC880F7FF88888FFFFFFFFFFF7
          F07880F0F777777FFFFFFFFFFFFF0788CCCC8CC8880F7FFFFFFFFFFFFFFFFFF7
          F07880FFFFFFFFFFFFFFFFFFFFFF0788C8888C88880F77777777777777777777
          F078800000000000000000000000078888888888880FFFFFFFFFFFFFFFFFFFFF
          F07880F888888880F88888888888078888888888880F77777777777777777777
          F07880F800008880F80000000008078888888888880F77777777777777777777
          F07880FFFFFFFFF0FFFFFFFFFFFF078888888888880FFFFFFFFFFFFFFFFFFFFF
          F078800000000000000000000000088888888888880000000000000000000000
          0088888888888888888888888888888888888888888888888888888888888888
          8888}
        Transparent = True
      end
      object lblExpandLevel: TLabel
        Left = 90
        Top = 124
        Width = 68
        Height = 13
        Caption = 'Expand &level: '
        OnClick = lblExpandLevelClick
      end
      object bvlExpandLevelHolder: TBevel
        Left = 210
        Top = 122
        Width = 58
        Height = 21
        Visible = False
      end
      object lblSelection: TLabel
        Left = 6
        Top = 9
        Width = 43
        Height = 13
        Caption = 'Selection'
      end
      object lblExpanding: TLabel
        Left = 6
        Top = 81
        Width = 50
        Height = 13
        Caption = 'Expanding'
      end
      object lblRefinements: TLabel
        Left = 7
        Top = 225
        Width = 60
        Height = 13
        Caption = 'Refinements'
      end
      object bvlRefinements: TBevel
        Left = 73
        Top = 230
        Width = 194
        Height = 4
        Shape = bsBottomLine
      end
      object imgRefinements: TImage
        Left = 9
        Top = 248
        Width = 64
        Height = 32
        Picture.Data = {
          07544269746D617076040000424D760400000000000076000000280000004000
          0000200000000100040000000000000400000000000000000000100000001000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00DD777777777777777777777777DDDDDDDDDDDDD777777777777777777777
          777DD0000000000000000000000007DDDDDDDDDDDD0000000000000000000000
          007DD0FFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0777777777777777777777707DDDDDDDDDDDD0777777777777777777777
          707DD0FFFFFFFFFFF7FFFFFFFFFF07DDCDDDDCDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FFF99999FF07DDCCCCDCCDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0F77777777FF7FCC99999FF07DDCCCCCCCCDD0F77777777FF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FCC99999FF07DDCCCCDCCDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0F777777FFFF7FCC99999FF07DDCDDDDCDDDD0F777777FFFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FCC99999FF07DDDDDDDDDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0F77777777FF7FCCCCCFFFF07DDDDDDDDDDDD0F77777777FF7F7777777F
          F07DD0FFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0777777777777777777777707DDDDDDDDDDDD0777777777777777777777
          707DD0FFFFFFFFFFF7FFFFFFFFFF07DDCDDDDCDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FFFCCCCCFF07DDCCCCDCCDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FFCCCCCCCF07DDCCCCCCCCDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FFFCCCCCFF07DDCCCCDCCDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0F7777777FFF7FF9999999F07DDCDDDDCDDDD0F7777777FFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FFF99999FF07DDDDDDDDDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0F777777777F7FFFFFFFFFF07DDDDDDDDDDDD0F777777777F7F7777777F
          F07DD0FFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0777777777777777777777707DDDDDDDDDDDD0777777777777777777777
          707DD0F88888888887F88888888707DDDDDDDDDDDD0F88888888887F88888888
          707DD0F88888888887F88888888707DDDDDDDDDDDD0F88888888887F88888888
          707DD0F88888888887F88888888707DDDDDDDDDDDD0F88888888887F88888888
          707DD0F80000888887F88888888707DDDDDDDDDDDD0F80000888887F88888888
          707DD0F80000000087F80000008707DDDDDDDDDDDD0F80000000087F80000008
          707DD0F88888888887F88888888707DDDDDDDDDDDD0F88888888887F88888888
          707DD0FFFFFFFFFFF7FFFFFFFFF707DDDDDDDDDDDD0FFFFFFFFFFF7FFFFFFFFF
          707DD000000000000000000000000DDDDDDDDDDDDD0000000000000000000000
          00DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
          DDDD}
        Transparent = True
      end
      object lblLookAndFeel: TLabel
        Left = 6
        Top = 152
        Width = 67
        Height = 13
        Caption = 'Look And Feel'
      end
      object Image8: TImage
        Left = 9
        Top = 174
        Width = 64
        Height = 32
        Picture.Data = {
          07544269746D617076040000424D760400000000000076000000280000004000
          0000200000000100040000000000000400000000000000000000100000001000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00DD7777777777777777777777777DDDDDDDDDDDD777777777777777777777
          7777D00000000000000000000000007DDDDDDDDDDD0000000000000000000000
          0007D08888888888880888888888807DCDDDDCDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D08777777777780877777788807DCCCCDCCDDD0877777777778787777788
          8F07D08888888888880888888888807DCCCCCCCCDD0888888888888788888888
          8F07D00000000000000000000000007DCCCCDCCDDD0777777777777777777777
          7707D0FFFFFFFFFFFF7FFFFFFFFFF07DCDDDDCDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D0F77777777FFF7F7777777FF07DDDDDDDDDDD0F777777777FF7F7777777
          FF07D0FFFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D07777777777777777777777707DDDDDDDDDDD0777777777777777777777
          7707D0FFFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D0F777777FFFFF7F777777FFF07DDDDDDDDDDD0F777777FFFFF7F777777F
          FF07D0FFFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D07777777777777777777777707DDDDDDDDDDD0777777777777777777777
          7707D0FFFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D0F7777777777F7F77777777F07DDDDDDDDDDD0F777777FFFFF7F7777777
          7F07D0FFFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D07777777777777777777777707DDDDDDDDDDD0777777777777777777777
          7707D0FFFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D0F77777777FFF7F77777FFFF07DDDDDDDDDDD0F77777777FFF7F77777FF
          FF07D0FFFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D07777777777777777777777707DDDDDDDDDDD0777777777777777777777
          7707D0FFFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D0F777777FFFFF7F77777777F07DDDDDDDDDDD0F777777FFFFF7F7777777
          7F07D0FFFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDD0FFFFFFFFFFFF7FFFFFFFF
          FF07D00000000000000000000000007DCDDDDCDDDD0000000000000000000000
          0007D08888888888880888888888807DCCCCDCCDDD0777777777777777777777
          7707D08888888888880888888888807DCCCCCCCCDD0F88888888888788888888
          8707D08000000008880880000000807DCCCCDCCDDD0F00000000888788000000
          8707D08888888888880888888888807DCDDDDCDDDD0FFFFFFFFFFFF7FFFFFFFF
          F707D0000000000000000000000000DDDDDDDDDDDD0000000000000000000000
          000DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
          DDDD}
        Transparent = True
      end
      object Bevel15: TBevel
        Left = 82
        Top = 156
        Width = 185
        Height = 4
        Shape = bsBottomLine
      end
      object chbxTransparentColumnGraphic: TCheckBox
        Tag = 10
        Left = 90
        Top = 246
        Width = 179
        Height = 17
        Caption = 'Transparent &Graphics'
        TabOrder = 5
        OnClick = chbxShowClick
      end
      object chbxDisplayGraphicsAsText: TCheckBox
        Tag = 11
        Left = 90
        Top = 268
        Width = 179
        Height = 17
        Caption = 'Display Graphics As &Text'
        TabOrder = 6
        OnClick = chbxShowClick
      end
      object chbxOnlySelected: TCheckBox
        Left = 90
        Top = 31
        Width = 179
        Height = 17
        Caption = 'Only &selected'
        TabOrder = 0
        OnClick = chbxOnlySelectedClick
      end
      object chbxExtendedSelect: TCheckBox
        Left = 90
        Top = 53
        Width = 179
        Height = 17
        Caption = '&Extended select'
        TabOrder = 1
        OnClick = chbxExtendedSelectClick
      end
      object chbxAutoNodesExpand: TCheckBox
        Left = 90
        Top = 98
        Width = 179
        Height = 17
        Caption = '&Auto Node Expanded'
        TabOrder = 2
        OnClick = chbxAutoNodesExpandClick
      end
      object chbxUse3DEffects: TCheckBox
        Tag = 12
        Left = 90
        Top = 172
        Width = 179
        Height = 17
        Caption = '&Use 3D Effects'
        TabOrder = 3
        OnClick = chbxShowClick
      end
      object chbxUseSoft3D: TCheckBox
        Tag = 13
        Left = 90
        Top = 194
        Width = 179
        Height = 17
        Caption = 'Soft &3D'
        TabOrder = 4
        OnClick = chbxShowClick
      end
      object chbxCheckMarksAsText: TCheckBox
        Tag = 15
        Left = 90
        Top = 312
        Width = 179
        Height = 17
        Caption = 'Display Check Marks as Text'
        TabOrder = 8
        OnClick = chbxShowClick
      end
      object chbxFlatCheckMarks: TCheckBox
        Tag = 7
        Left = 90
        Top = 290
        Width = 179
        Height = 17
        Caption = 'Flat Check &Marks'
        TabOrder = 7
        OnClick = chbxShowClick
      end
    end
    object tshPreview: TTabSheet
      Caption = 'Preview'
      object Bevel9: TBevel
        Left = 54
        Top = 13
        Width = 213
        Height = 4
        Shape = bsBottomLine
      end
      object lblPreviewLineCount: TLabel
        Left = 90
        Top = 69
        Width = 99
        Height = 13
        Caption = 'Preview &Line Count: '
        OnClick = lblExpandLevelClick
      end
      object bvlPreviewLineCountHolder: TBevel
        Left = 196
        Top = 66
        Width = 67
        Height = 21
        Visible = False
      end
      object lblPreview: TLabel
        Left = 6
        Top = 9
        Width = 38
        Height = 13
        Caption = 'Preview'
      end
      object imgPreview: TImage
        Left = 9
        Top = 33
        Width = 32
        Height = 32
        Picture.Data = {
          07544269746D617076020000424D760200000000000076000000280000002000
          0000200000000100040000000000000200000000000000000000100000001000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00DDDD7777777777777777777777777DDDDDD0000000000000000000000000
          7DDDDDD0FFFFFFFFFFFFFFFFFFFFFFF07DDDDDD0F777777777777777777777F0
          7DDDDDD0F7F888F7FF888F7F8888F7F07DDDDDD0F7FFFFF7FFFFFF7FFFFFF7F0
          7DDDDDD0F777777777777777777777F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7FCCCCCFFCCCCFFCCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7FCCCCCCCCFCCCCFCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7FCCCCCCCCCCFCCFCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7FCCCCCCCCCCCCCCCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7FCCCCCCCCCCCFCCFCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7FCCCCCCCCFFCCCFCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7FCCCCCCCCCCCCCCCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F777777777777777777777F07DDDDDD0F7F888F7FF888F7FF888F7F0
          7DDDDDD0F7FFFFF7FFFFFF7FFFFFF7F07DDDDDD0F777777777777777777777F0
          7DDDDDD0F7F88887F888887F888887F07DDDDDD0F7F00087F000087F000087F0
          7DDDDDD0F7FFFFF7FFFFFF7FFFFFF7F07DDDDDD0F777777777777777777777F0
          7DDDDDD0FFFFFFFFFFFFFFFFFFFFFFF07DDDDDD0000000000000000000000000
          DDDD}
        Transparent = True
      end
      object chbxShowPreview: TCheckBox
        Tag = 4
        Left = 90
        Top = 23
        Width = 169
        Height = 17
        Caption = 'Pre&view'
        TabOrder = 0
        OnClick = chbxShowClick
      end
      object chbxAutoCalcPreviewLines: TCheckBox
        Left = 90
        Top = 43
        Width = 169
        Height = 17
        Caption = '&Auto Calc Preview Lines'
        TabOrder = 1
        OnClick = chbxAutoCalcPreviewLinesClick
      end
    end
  end
  object pnlPreview: TPanel
    Left = 287
    Top = 44
    Width = 282
    Height = 343
    BevelInner = bvLowered
    BevelOuter = bvNone
    Color = clWindow
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 1
    object dxTLPreview: TdxTreeList
      Left = 7
      Top = 4
      Width = 268
      Height = 330
      Bands = <
        item
          Caption = 'Item Data'
          Width = 201
        end>
      DefaultLayout = False
      HeaderPanelRowCount = 1
      BorderStyle = bsNone
      Ctl3D = True
      Enabled = False
      ParentCtl3D = False
      TabOrder = 0
      Visible = False
      Images = ilTLImages
      LookAndFeel = lfFlat
      Options = [aoColumnSizing, aoColumnMoving, aoEditing, aoTabThrough, aoRowSelect, aoPreview, aoAutoWidth]
      OptionsEx = [aoBandHeaderWidth, aoAutoCalcPreviewLines, aoBandSizing, aoBandMoving, aoDragScroll, aoDragExpand]
      PaintStyle = psOutlook
      StateImages = ilTLImages
      TreeLineColor = clGrayText
      ScrollBars = ssNone
      ShowBands = True
      ShowButtons = False
      ShowGrid = True
      ShowRowFooter = True
      ShowFooter = True
      OnCustomDrawBand = dxTLPreviewCustomDrawBand
      OnCustomDrawColumnHeader = dxTLPreviewCustomDrawColumnHeader
      OnCustomDrawCell = dxTLPreviewCustomDrawCell
      OnCustomDrawFooterNode = dxTLPreviewCustomDrawFooterNode
      OnCustomDrawFooter = dxTLPreviewCustomDrawFooter
      OnCustomDrawPreviewCell = dxTLPreviewCustomDrawPreviewCell
      OnGetFooterCellText = dxTLPreviewGetFooterCellText
      OnGetPreviewLineCount = dxTLPreviewGetPreviewLineCount
      OnGetPreviewText = dxTLPreviewGetPreviewText
      OnIsExistRowFooterCell = dxTLPreviewIsExistRowFooterCell
      OnIsExistFooterCell = dxTLPreviewIsExistFooterCell
      OnIsLevelFooter = dxTLPreviewIsLevelFooter
      Data = {
        FFFFFFFF03000000180000000000000000000000010000000000000000000000
        020000000D0000004E6F6465203120436F6C2023310D0000004E6F6465203120
        436F6C2023331800000000000000000000000100000000000000020000000200
        00000D0000004E6F6465203220436F6C20233104000000547275651800000000
        0000000000000001000000000000000000000002000000090000005375624E6F
        6465203100000000180000000000000000000000010000000000000000000000
        01000000090000005375624E6F64652032180000000000000000000000010000
        000000000001000000020000000D0000004E6F6465203320436F6C2023310400
        0000547275651800000000000000000000000100000000000000000000000200
        0000090000005375624E6F64652033090000005375624E6F64652033}
      object dxTLPreviewColumn1: TdxTreeListColumn
        Alignment = taLeftJustify
        Width = 117
        BandIndex = 0
        RowIndex = 0
      end
      object dxTLPreviewColumn3: TdxTreeListCheckColumn
        Caption = 'Axisymmetric'
        Width = 83
        BandIndex = 0
        RowIndex = 0
        OnCustomDrawCell = dxTLPreviewColumn3CustomDrawCell
        AllowGrayed = True
        ShowNullFieldStyle = nsInactive
        ValueChecked = 'True'
        ValueUnchecked = 'False'
      end
      object dxTLPreviewColumn4: TdxTreeListImageColumn
        Alignment = taLeftJustify
        Caption = 'Shape'
        MinWidth = 16
        Width = 68
        BandIndex = 0
        RowIndex = 0
        OnCustomDrawCell = dxTLPreviewColumn4CustomDrawCell
        Images = ilTLImages
        ImageIndexes.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6')
        Values.Strings = (
          ''
          ''
          '2'
          '3'
          '4'
          '5'
          '6')
      end
    end
  end
  object ilTLImages: TImageList
    Left = 5
    Top = 404
    Bitmap = {
      494C010107000A00040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000000000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF000000FF000000FF000000000000008400000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000000000008400000084000000840000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF00000000000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000008400000084000000840000008400
      0000840000008400000000000000000000000000000000000000FF000000FF00
      0000FF00000000000000FF000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF00000000000000FF000000FF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000000000008400000084000000840000008400
      0000840000000000000000000000000000000000000000000000FF000000FF00
      0000FF00000000000000FF000000FF000000FF00000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF00000000000000FF000000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000000000008400000084000000840000008400
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000000084000000000000008400FF000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF00000000000000FF000000FF00
      0000FF000000FF00000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000000000008400000084000000840000008400
      000000000000000000000000000000000000000000000000000000000000FF00
      0000000084000000840000000000000084000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FF0000008400
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF000000FF000000FF000000000000008400000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000000000008400
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000000000008400000084000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000840000008400000084000000000000008400000084000000
      8400000000000000000000000000000000000000000000000000000000000000
      0000FF000000FF000000FF000000FF000000FF00000084000000840000000000
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000000000008400000084000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000008400000084000000840000000000000084000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF00000084000000840000008400
      0000000000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000000000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000008400000084000000840000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF0000008400000084000000840000008400
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000084000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF00000084000000FF00000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF00000084000000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000840000008400000084000000FF000000840000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000848484008484840084848400C6C6C60084848400000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF0000008400000084000000000000008400
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF00000084000000FF00000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000084
      000000840000FFFFFF0000FF0000FFFFFF0000FF000000840000008400000000
      0000000000000000000000000000000000000000000000000000000000008484
      840084848400FFFFFF00C6C6C600FFFFFF00C6C6C60084848400848484000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF00000084000000FF00000084000000840000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF0000008400000084000000000000000000
      00000000000000000000000000000000000000000000000000000084000000FF
      0000FFFFFF0000FF0000FFFFFF0000FF000000FF000000840000008400000084
      000000000000000000000000000000000000000000000000000084848400C6C6
      C600FFFFFF00C6C6C600FFFFFF00C6C6C600C6C6C60084848400848484008484
      840000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF00000084000000FF0000008400000084000000840000008400
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF00000084000000FF00000084000000840000000000
      000000000000000000000000000000000000000000000000000000840000FFFF
      FF0000FF0000FFFFFF0000FF0000FFFFFF0000FF000000840000008400000084
      000000840000000000000000000000000000000000000000000084848400FFFF
      FF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C60084848400848484008484
      840084848400000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF00000084000000FF00000084000000840000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF0000008400000084000000000000000000
      00000000000000000000000000000000000000000000000000000084000000FF
      0000FFFFFF00FFFFFF0000FF000000FF000000FF000000840000008400000084
      000000840000000000000000000000000000000000000000000084848400C6C6
      C600FFFFFF00FFFFFF00C6C6C600C6C6C600C6C6C60084848400848484008484
      840084848400000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF0000008400000084000000000000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF000000FF000000FF00000084000000FF00000084000000840000000000
      000000000000000000000000000000000000000000000000000000840000FFFF
      FF0000FF000000FF000000FF000000FF000000FF000000FF0000008400000084
      000000840000000000000000000000000000000000000000000084848400FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600848484008484
      840084848400000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF00000084000000FF00000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FF000000FF000000FF000000FF0000008400000000000000840000000000
      00000000000000000000000000000000000000000000000000000084000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000084
      000000840000000000000000000000000000000000000000000084848400C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      840084848400000000000000000000000000000000000000000000000000FF00
      0000FF000000FF00000084000000FF0000008400000084000000840000008400
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF0000008400000084000000000000000000
      00000000000000000000000000000000000000000000000000000084000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF00000084
      000000840000000000000000000000000000000000000000000084848400C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6008484
      840084848400000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF00000084000000FF00000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF0000008400000084000000000000000000
      0000000000000000000000000000000000000000000000000000000000000084
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      0000008400000084000000000000000000000000000000000000000000008484
      8400C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C60084848400848484000000000000000000000000000000000000000000FF00
      0000FF0000000000000000000000000000000000000000000000000000008400
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000084000000FF000000FF000000FF000000FF000000FF0000008400000084
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600848484008484
      8400000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FF000000FF0000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000084000000FF000000FF00000084000000840000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000084848400C6C6C600C6C6C6008484840084848400000000000000
      000000000000000000000000000000000000000000000000000000000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF0000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000840000008400000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FF000000FF000000FF000000FF000000FF000000FF0000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFF0000FC7F003FFFFF0000
      F01F7FDF803F0000C0077FEF801F000000010077800F00000001003B80070000
      8003003D80030000C007400180010000C007401D80010000E00F600DC0010000
      F01F7001E0010000F01FB805F0010000F83FDC0DF8010000FC7FEDFDFC010000
      FC7FF5FDFE010000FEFFF801FFFF0000FFFFFFFFFFFFFFFFFFFFFFFFF81FF83F
      FF3FFF3FE007E00FF81FF81FC003C007E00FE00FC003C007C007C007C003C007
      C003C003C003C007C003C003C003E00FC003C003C003E00FC003C003C003F01F
      C003C003C003F01FE003E003C003F83FF00FF00FC003F83FF83FF83FC003FC7F
      FCFFFCFFE007FC7FFFFFFFFFF81FFEFF00000000000000000000000000000000
      000000000000}
  end
  object pmChangeFont: TPopupMenu
    OnPopup = pmChangeFontPopup
    Left = 33
    Top = 404
    object miChangeFont: TMenuItem
      Caption = 'Change Fo&nt ...'
      Default = True
      ShortCut = 16454
      OnClick = btnChangeFontClick
    end
  end
end
