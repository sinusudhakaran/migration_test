object dxMVReportLinkDesignWindow: TdxMVReportLinkDesignWindow
  Left = 386
  Top = 219
  BorderStyle = bsDialog
  Caption = 'dxMVReportLinkDesignWindow'
  ClientHeight = 414
  ClientWidth = 597
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
    Top = 5
    Width = 589
    Height = 373
    ActivePage = tshColors
    TabOrder = 0
    OnChange = PageControl1Change
    object tshOptions: TTabSheet
      Caption = '&Options'
      object Bevel11: TBevel
        Left = 40
        Top = 13
        Width = 242
        Height = 4
        Shape = bsBottomLine
      end
      object imgShow: TImage
        Left = 9
        Top = 34
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
        Top = 8
        Width = 26
        Height = 13
        Caption = 'Show'
      end
      object Bevel16: TBevel
        Left = 90
        Top = 102
        Width = 193
        Height = 4
        Shape = bsBottomLine
      end
      object chbxShowGrid: TCheckBox
        Tag = 3
        Left = 90
        Top = 119
        Width = 173
        Height = 17
        Caption = '&Grid'
        TabOrder = 3
        OnClick = ShowClick
      end
      object chbxShowGroupFooterGrid: TCheckBox
        Tag = 5
        Left = 90
        Top = 163
        Width = 173
        Height = 17
        Caption = 'Group Footers Grid'
        TabOrder = 5
        OnClick = ShowClick
      end
      object chbxShowHeaders: TCheckBox
        Left = 90
        Top = 31
        Width = 173
        Height = 17
        Caption = '&Headers'
        TabOrder = 0
        OnClick = ShowClick
      end
      object chbxShowFooters: TCheckBox
        Tag = 1
        Left = 90
        Top = 53
        Width = 173
        Height = 17
        Caption = 'Foo&ters'
        TabOrder = 1
        OnClick = ShowClick
      end
      object chbxShowPreviewGrid: TCheckBox
        Tag = 4
        Left = 90
        Top = 141
        Width = 173
        Height = 17
        Caption = 'Nodes Grid'
        TabOrder = 4
        OnClick = ShowClick
      end
      object chbxShowExpandButtons: TCheckBox
        Tag = 12
        Left = 90
        Top = 75
        Width = 173
        Height = 17
        Caption = 'ExpandButtons'
        TabOrder = 2
        OnClick = ShowClick
      end
      object lblPreviewWindow: TStaticText
        Left = 295
        Top = 0
        Width = 88
        Height = 12
        AutoSize = False
        Caption = 'Preview'
        TabOrder = 6
      end
    end
    object tshColors: TTabSheet
      Caption = '&Color'
      object lblGridLineColor: TLabel
        Left = 11
        Top = 304
        Width = 74
        Height = 13
        Caption = '&Grid Line color :'
      end
      object bvlGridLineColorHolder: TBevel
        Left = 129
        Top = 299
        Width = 152
        Height = 22
        Visible = False
      end
      object lblDrawMode: TLabel
        Left = 8
        Top = 21
        Width = 58
        Height = 13
        Caption = 'Draw &Mode:'
        FocusControl = cbxDrawMode
      end
      object gbxFixedTransparent: TGroupBox
        Left = 6
        Top = 164
        Width = 283
        Height = 126
        Caption = '  '
        TabOrder = 4
        object lblHeaderColor: TLabel
          Left = 5
          Top = 49
          Width = 71
          Height = 13
          Caption = '&Header color : '
        end
        object lblFooterColor: TLabel
          Left = 5
          Top = 75
          Width = 65
          Height = 13
          Caption = 'Footer color :'
        end
        object bvlHeaderColorHolder: TBevel
          Left = 123
          Top = 44
          Width = 152
          Height = 22
          Visible = False
        end
        object bvlFooterColorHolder: TBevel
          Left = 123
          Top = 70
          Width = 152
          Height = 22
          Visible = False
        end
        object lblGroupNodeColor: TLabel
          Left = 5
          Top = 101
          Width = 87
          Height = 13
          Caption = 'Group&Node color :'
        end
        object bvlGroupNodeColorHolder: TBevel
          Left = 123
          Top = 96
          Width = 152
          Height = 22
          Visible = False
        end
        object lblLevelCaptionColor: TLabel
          Left = 5
          Top = 23
          Width = 100
          Height = 13
          Caption = 'CaptionNode Color : '
        end
        object bvlCaptionColorHolder: TBevel
          Left = 123
          Top = 18
          Width = 152
          Height = 22
          Visible = False
        end
      end
      object gbxTransparent: TGroupBox
        Left = 6
        Top = 53
        Width = 283
        Height = 104
        Caption = '  '
        TabOrder = 2
        object lblColor: TLabel
          Left = 5
          Top = 23
          Width = 29
          Height = 13
          Caption = 'C&olor:'
        end
        object bvlColorHolder: TBevel
          Left = 123
          Top = 18
          Width = 152
          Height = 22
          Visible = False
        end
        object lblPreviewColor: TLabel
          Left = 5
          Top = 77
          Width = 71
          Height = 13
          Caption = '&Preview color :'
        end
        object bvlPreviewColorHolder: TBevel
          Tag = 1
          Left = 123
          Top = 72
          Width = 152
          Height = 22
          Visible = False
        end
        object lblEvenColor: TLabel
          Left = 5
          Top = 47
          Width = 59
          Height = 13
          Caption = 'Even Color :'
        end
        object bvlEvenColorHolder: TBevel
          Left = 123
          Top = 43
          Width = 152
          Height = 22
          Visible = False
        end
      end
      object chbxTransparent: TCheckBox
        Left = 17
        Top = 51
        Width = 15
        Height = 17
        Caption = ' Tr&ansparent  '
        TabOrder = 1
        OnClick = chbxTransparentClick
      end
      object chbxFixedTransparent: TCheckBox
        Tag = 1
        Left = 17
        Top = 163
        Width = 15
        Height = 17
        Caption = ' Fi&xed transparent  '
        TabOrder = 3
        OnClick = chbxTransparentClick
      end
      object cbxDrawMode: TComboBox
        Left = 89
        Top = 15
        Width = 193
        Height = 24
        Style = csOwnerDrawFixed
        ItemHeight = 18
        TabOrder = 0
        OnClick = cbxDrawModeClick
        OnDrawItem = cbxDrawModeDrawItem
        Items.Strings = (
          'Simpe'
          'Odd\Even Rows Mode'
          'Borrow From Source')
      end
      object stTransparent: TStaticText
        Left = 32
        Top = 52
        Width = 76
        Height = 17
        Caption = ' &Transparent '
        FocusControl = chbxTransparent
        TabOrder = 5
        OnClick = stTransparentClick
      end
      object stFixedTransparent: TStaticText
        Left = 32
        Top = 164
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
        Top = 170
        Width = 116
        Height = 23
        Caption = 'Change Fo&nt ...'
        TabOrder = 1
        OnClick = btnChangeFontClick
      end
      object lbxFonts: TListBox
        Left = 6
        Top = 15
        Width = 282
        Height = 148
        Style = lbOwnerDrawFixed
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ItemHeight = 16
        MultiSelect = True
        ParentFont = False
        ParentShowHint = False
        PopupMenu = pmChangeFont
        ShowHint = True
        TabOrder = 0
        OnClick = lbxFontsClick
        OnDblClick = lbxFontsDblClick
        OnDrawItem = lbxFontsDrawItem
        OnKeyDown = lbxFontsKeyDown
        OnMouseMove = lbxFontsMouseMove
      end
    end
    object tshBehaviors: TTabSheet
      Caption = '&Behaviors'
      object Bevel12: TBevel
        Left = 57
        Top = 12
        Width = 228
        Height = 4
        Shape = bsBottomLine
      end
      object Bevel13: TBevel
        Left = 92
        Top = 83
        Width = 192
        Height = 4
        Shape = bsBottomLine
      end
      object imgSelection: TImage
        Left = 9
        Top = 30
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
      object imgNodeExpanding: TImage
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
          F07880F877778880F87777777778078888888888880F77777777777777777777
          F07880FFFFFFFFF0FFFFFFFFFFFF078888888888880FFFFFFFFFFFFFFFFFFFFF
          F078800000000000000000000000088888888888880000000000000000000000
          0088888888888888888888888888888888888888888888888888888888888888
          8888}
        Transparent = True
      end
      object lblSelection: TLabel
        Left = 6
        Top = 8
        Width = 43
        Height = 13
        Caption = 'Selection'
      end
      object lblExpanding: TLabel
        Left = 6
        Top = 79
        Width = 78
        Height = 13
        Caption = 'Node Expanding'
      end
      object lblRefinements: TLabel
        Left = 7
        Top = 215
        Width = 60
        Height = 13
        Caption = 'Refinements'
      end
      object bvlGraphic: TBevel
        Left = 76
        Top = 220
        Width = 208
        Height = 4
        Shape = bsBottomLine
      end
      object imgGraphics: TImage
        Left = 9
        Top = 241
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
          F07DD0FFFFFFFFFFF7FF7FFFFFFF07DDCCCCDCCDDD0FFFFFFFFFFF7FF777777F
          F07DD0F77777777FF7FF70888FFF07DDCCCCCCCCDD0F77777777FF7FF7FFFF7F
          F07DD0FFFFFFFFFFF7FF70FF8FFF07DDCCCCDCCDDD0FFFFFFFFFFF7FF7F00F7F
          F07DD0F777777FFFF7FF70FF8FFF07DDCDDDDCDDDD0F777777FFFF7FF7F00F7F
          F07DD0FFFFFFFFFFF7FF70000FFF07DDDDDDDDDDDD0FFFFFFFFFFF7FF7FFFF7F
          F07DD0F77777777FF7FF777777FF07DDDDDDDDDDDD0F77777777FF7FF777777F
          F07DD0FFFFFFFFFFF7FFFFFFFFFF07DDDDDDDDDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0777777777777777777777707DDDDDDDDDDDD0777777777777777777777
          707DD0FFFFFFFFFFF7FFFFFFFFFF07DDCDDDDCDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FFFFFFFFFF07DDCCCCDCCDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FFCCCCCFFF07DDCCCCCCCCDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7FCCCCCCCFF07DDCCCCDCCDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0F7777777FFF7FFCCCCCFFF07DDCDDDDCDDDD0F7777777FFF7FFFFFFFFF
          F07DD0FFFFFFFFFFF7F9999999FF07DDDDDDDDDDDD0FFFFFFFFFFF7FFFFFFFFF
          F07DD0F777777777F7FF99999FFF07DDDDDDDDDDDD0F777777777F7F7777777F
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
        Top = 148
        Width = 67
        Height = 13
        Caption = 'Look And Feel'
      end
      object img3DEffects: TImage
        Left = 9
        Top = 172
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
        Left = 83
        Top = 152
        Width = 200
        Height = 4
        Shape = bsBottomLine
      end
      object chbxTransparentColumnGraphic: TCheckBox
        Tag = 7
        Left = 90
        Top = 239
        Width = 188
        Height = 17
        Caption = 'Transparent Column &Graphics'
        TabOrder = 5
        OnClick = ShowClick
      end
      object chbxDisplayGraphicsAsText: TCheckBox
        Tag = 8
        Left = 90
        Top = 261
        Width = 188
        Height = 17
        Caption = 'Display Graphics As &Text'
        TabOrder = 6
        OnClick = ShowClick
      end
      object chbxOnlySelected: TCheckBox
        Left = 90
        Top = 31
        Width = 188
        Height = 17
        Caption = 'Only &selected'
        TabOrder = 0
        OnClick = chbxOnlySelectedClick
      end
      object chbxExtendedSelect: TCheckBox
        Left = 90
        Top = 53
        Width = 188
        Height = 17
        Caption = '&Extended select'
        TabOrder = 1
        OnClick = chbxExtendedSelectClick
      end
      object chbxAutoNodesExpand: TCheckBox
        Left = 90
        Top = 102
        Width = 188
        Height = 17
        Caption = '&Auto Node Expanded'
        TabOrder = 2
        OnClick = chbxAutoNodesExpandClick
      end
      object chbxUse3DEffects: TCheckBox
        Tag = 9
        Left = 90
        Top = 171
        Width = 188
        Height = 17
        Caption = '&Use 3D Effects'
        TabOrder = 3
        OnClick = ShowClick
      end
      object chbxUseSoft3D: TCheckBox
        Tag = 10
        Left = 90
        Top = 193
        Width = 188
        Height = 17
        Caption = 'Soft &3D'
        TabOrder = 4
        OnClick = ShowClick
      end
      object chbxCheckMarksAsText: TCheckBox
        Tag = 11
        Left = 90
        Top = 305
        Width = 173
        Height = 17
        Caption = 'Display CheckMarks as Text'
        TabOrder = 8
        OnClick = ShowClick
      end
      object chbxFlatCheckMarks: TCheckBox
        Tag = 6
        Left = 90
        Top = 283
        Width = 173
        Height = 17
        Caption = 'Flat Check &Marks'
        TabOrder = 7
        OnClick = ShowClick
      end
    end
    object tshPreview: TTabSheet
      Caption = 'Preview'
      ImageIndex = 4
      object lblPreviewLineCount: TLabel
        Left = 90
        Top = 82
        Width = 99
        Height = 13
        Caption = 'Preview &Line Count: '
      end
      object bvlPreviewLineCountHolder: TBevel
        Left = 193
        Top = 78
        Width = 81
        Height = 21
        Visible = False
      end
      object lblPreview: TLabel
        Left = 6
        Top = 8
        Width = 38
        Height = 13
        Caption = 'Preview'
      end
      object Bevel1: TBevel
        Left = 52
        Top = 13
        Width = 226
        Height = 4
        Shape = bsBottomLine
      end
      object imgPreview: TImage
        Left = 9
        Top = 30
        Width = 32
        Height = 32
        Center = True
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
        Tag = 2
        Left = 90
        Top = 31
        Width = 97
        Height = 17
        Caption = 'Pre&view'
        TabOrder = 0
        OnClick = ShowClick
      end
      object chbxAutoCalcPreviewLines: TCheckBox
        Left = 90
        Top = 53
        Width = 169
        Height = 17
        Caption = '&Auto Calc Preview Lines'
        TabOrder = 1
        OnClick = chbxAutoCalcPreviewLinesClick
      end
    end
  end
  object pnlPreview: TPanel
    Left = 303
    Top = 44
    Width = 281
    Height = 324
    BevelInner = bvLowered
    BevelOuter = bvNone
    Color = clWindow
    TabOrder = 1
    object dxMVPreview: TdxMasterView
      Left = 5
      Top = 5
      Width = 271
      Height = 313
      Enabled = False
      TabOrder = 0
      Visible = False
      OptionsView = [movAutoColumnWidth, movHideFocusRect, movHideSelection, movKeepColumnWidths, movTransparentDragAndDrop, movUseBitmap, movUseBitmapToDrawPreview]
      ScrollBars = sbNone
      object mvsCaptionStyle: TdxMasterViewStyle
      end
      object mvsContentStyle: TdxMasterViewStyle
      end
      object mvsFooterStyle: TdxMasterViewStyle
      end
      object mvsGroupStyle: TdxMasterViewStyle
      end
      object mvsHeaderStyle: TdxMasterViewStyle
      end
      object mvsPreviewStyle: TdxMasterViewStyle
      end
      object mvsAnotherContentStyle: TdxMasterViewStyle
      end
    end
  end
  object pmChangeFont: TPopupMenu
    OnPopup = pmChangeFontPopup
    Left = 4
    Top = 383
    object miChangeFont: TMenuItem
      Caption = 'Change Fo&nt ...'
      Default = True
      ShortCut = 16454
      OnClick = btnChangeFontClick
    end
  end
end
