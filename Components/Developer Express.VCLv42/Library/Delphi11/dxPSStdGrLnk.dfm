object dxGridReportLinkDesignWindow: TdxGridReportLinkDesignWindow
  Left = 346
  Top = 298
  BorderStyle = bsDialog
  Caption = 'dxGridReportLinkDesigner'
  ClientHeight = 314
  ClientWidth = 579
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
    Top = 6
    Width = 571
    Height = 273
    ActivePage = tshColor
    MultiLine = True
    TabOrder = 0
    OnChange = PageControl1Change
    object tshOptions: TTabSheet
      Caption = '&Options'
      object pnlOptions: TPanel
        Left = 0
        Top = 0
        Width = 563
        Height = 245
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object lblShow: TLabel
          Left = 5
          Top = 13
          Width = 26
          Height = 13
          Caption = 'Show'
        end
        object Bevel11: TBevel
          Left = 40
          Top = 18
          Width = 210
          Height = 4
          Shape = bsBottomLine
        end
        object imgGrid: TImage
          Left = 6
          Top = 32
          Width = 32
          Height = 32
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
        object lblOnEveryPage: TLabel
          Left = 8
          Top = 151
          Width = 72
          Height = 13
          Caption = 'On Every Page'
        end
        object Image1: TImage
          Left = 10
          Top = 172
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
        object Bevel10: TBevel
          Left = 88
          Top = 156
          Width = 162
          Height = 4
          Shape = bsBottomLine
        end
        object chbxShowVertLines: TCheckBox
          Tag = 2
          Left = 90
          Top = 75
          Width = 161
          Height = 17
          Caption = 'Vertical Lines'
          TabOrder = 2
          OnClick = chbxShowBordersClick
        end
        object chbxShowFixedHorzLines: TCheckBox
          Tag = 3
          Left = 90
          Top = 98
          Width = 161
          Height = 17
          Caption = 'Fixed &Horizontal Lines'
          TabOrder = 3
          OnClick = chbxShowBordersClick
        end
        object chbxShowFixedVertLines: TCheckBox
          Tag = 4
          Left = 90
          Top = 121
          Width = 161
          Height = 17
          Caption = 'Fixed &Vertical Lines'
          TabOrder = 4
          OnClick = chbxShowBordersClick
        end
        object chbxShowBorders: TCheckBox
          Left = 90
          Top = 30
          Width = 161
          Height = 17
          Caption = 'Border'
          TabOrder = 0
          OnClick = chbxShowBordersClick
        end
        object chbxShowHorzLines: TCheckBox
          Tag = 1
          Left = 90
          Top = 52
          Width = 161
          Height = 17
          Caption = 'Horizontal Lines'
          TabOrder = 1
          OnClick = chbxShowBordersClick
        end
        object chbxFixedRowsOnEveryPage: TCheckBox
          Left = 91
          Top = 173
          Width = 161
          Height = 17
          Caption = 'Fi&xed Rows'
          TabOrder = 5
          OnClick = chbxFixedRowsOnEveryPageClick
        end
        object lblPreview: TStaticText
          Left = 264
          Top = 2
          Width = 42
          Height = 17
          Caption = 'Preview'
          TabOrder = 6
        end
      end
    end
    object tshColor: TTabSheet
      Caption = '&Color'
      object pnlColor: TPanel
        Left = 0
        Top = 0
        Width = 563
        Height = 245
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object lblGridLinesColor: TLabel
          Left = 6
          Top = 218
          Width = 79
          Height = 13
          Caption = '&Grid lines color : '
          OnClick = lblColorClick
        end
        object bvlLineColorHolder: TBevel
          Left = 91
          Top = 214
          Width = 146
          Height = 21
          Visible = False
        end
        object lblDrawMode: TLabel
          Left = 5
          Top = 21
          Width = 58
          Height = 13
          Caption = 'Draw &Mode:'
          FocusControl = cbxDrawMode
          OnClick = lblColorClick
        end
        object gbxFixedTransparent: TGroupBox
          Left = 5
          Top = 144
          Width = 243
          Height = 58
          Caption = '  '
          TabOrder = 4
          object lblFixedColor: TLabel
            Left = 6
            Top = 24
            Width = 62
            Height = 13
            Caption = 'F&ixed color : '
            OnClick = lblColorClick
          end
          object bvlFixedColorHolder: TBevel
            Left = 86
            Top = 22
            Width = 146
            Height = 21
            Visible = False
          end
        end
        object gbxTransparent: TGroupBox
          Left = 5
          Top = 52
          Width = 243
          Height = 84
          Caption = '  '
          TabOrder = 2
          object lblColor: TLabel
            Left = 6
            Top = 24
            Width = 35
            Height = 13
            Caption = 'Co&lor : '
            OnClick = lblColorClick
          end
          object bvlColorHolder: TBevel
            Left = 86
            Top = 20
            Width = 146
            Height = 21
            Visible = False
          end
          object lblEvenColor: TLabel
            Left = 6
            Top = 51
            Width = 59
            Height = 13
            Caption = 'E&ven Color: '
            OnClick = lblColorClick
          end
          object bvlEvenColorHolder: TBevel
            Left = 86
            Top = 47
            Width = 146
            Height = 21
            Visible = False
          end
        end
        object chbxTransparent: TCheckBox
          Left = 18
          Top = 50
          Width = 15
          Height = 17
          Caption = 'T&ransparent'
          TabOrder = 1
          OnClick = chbxTransparentClick
        end
        object chbxFixedTransparent: TCheckBox
          Tag = 1
          Left = 18
          Top = 142
          Width = 15
          Height = 17
          Caption = 'Fixed T&ransparent'
          TabOrder = 3
          OnClick = chbxTransparentClick
        end
        object cbxDrawMode: TComboBox
          Left = 69
          Top = 16
          Width = 179
          Height = 24
          Style = csOwnerDrawFixed
          ItemHeight = 18
          TabOrder = 0
          OnClick = cbxDrawModeClick
          OnDrawItem = cbxDrawModeDrawItem
          Items.Strings = (
            'Simpe'
            'Odd\Even Rows Mode'
            'Chess'
            'Borrow From Source')
        end
        object stTransparent: TStaticText
          Left = 33
          Top = 51
          Width = 76
          Height = 17
          Caption = ' &Transparent '
          FocusControl = chbxTransparent
          TabOrder = 5
          OnClick = stTransparentClick
        end
        object stFixedTransparent: TStaticText
          Left = 33
          Top = 143
          Width = 105
          Height = 17
          Caption = ' Fixed T&ransparent '
          FocusControl = chbxFixedTransparent
          TabOrder = 6
          OnClick = stFixedTransparentClick
        end
      end
    end
    object tshFont: TTabSheet
      Caption = '&Font'
      object pnlFont: TPanel
        Left = 0
        Top = 0
        Width = 563
        Height = 245
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object btnFont: TButton
          Left = 8
          Top = 9
          Width = 110
          Height = 23
          Caption = 'Fo&nt ...'
          TabOrder = 0
          OnClick = btnFontClick
        end
        object edFont: TEdit
          Left = 8
          Top = 38
          Width = 239
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
        end
        object btnFixedFont: TButton
          Tag = 2
          Left = 8
          Top = 133
          Width = 110
          Height = 23
          Caption = 'Fi&xed Font ...'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
          TabOrder = 4
          OnClick = btnFontClick
        end
        object edFixedFont: TEdit
          Left = 8
          Top = 162
          Width = 239
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 5
        end
        object btnEvenFont: TButton
          Tag = 1
          Left = 7
          Top = 71
          Width = 110
          Height = 23
          Caption = 'E&ven Font ...'
          TabOrder = 2
          OnClick = btnFontClick
        end
        object edEvenFont: TEdit
          Left = 8
          Top = 100
          Width = 239
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 3
        end
      end
    end
    object tshBehaviors: TTabSheet
      Caption = '&Behaviors'
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 563
        Height = 245
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Image3: TImage
          Left = 7
          Top = 34
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
        object lblSelection: TLabel
          Left = 5
          Top = 13
          Width = 43
          Height = 13
          Caption = 'Selection'
        end
        object Bevel3: TBevel
          Left = 55
          Top = 18
          Width = 195
          Height = 4
          Shape = bsBottomLine
        end
        object lblLookAndFeel: TLabel
          Left = 5
          Top = 85
          Width = 67
          Height = 13
          Caption = 'Look And Feel'
        end
        object Bevel15: TBevel
          Left = 84
          Top = 89
          Width = 166
          Height = 4
          Shape = bsBottomLine
        end
        object Image8: TImage
          Left = 7
          Top = 106
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
        object bvlMiscellaneous: TBevel
          Left = 81
          Top = 160
          Width = 169
          Height = 3
          Shape = bsBottomLine
        end
        object lblMiscellaneous: TLabel
          Left = 5
          Top = 154
          Width = 65
          Height = 13
          Caption = 'Miscellaneous'
        end
        object imgMiscellaneous: TImage
          Left = 7
          Top = 177
          Width = 64
          Height = 32
          Picture.Data = {
            07544269746D617076040000424D760400000000000076000000280000004000
            0000200000000100040000000000000400000000000000000000100000000000
            0000000000000000800000800000008080008000000080008000808000008080
            8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
            FF00DD777777777777777777777777DDDDDDDDDDDDD777777777777777777777
            777DD0000000000000000000000007DDDDDDDDDDDD0000000000000000000000
            007DD0F8FFFFFFFFFFFFFFFFFF8F07DDDDDDDDDDDD0F8FFFFFFFFFFFFFFFFFF8
            F07DD0F8FFFFFFFFFFFFFFFFFF8F07DDDDDDDDDDDD0F8FFFFFFFFFFFFFFFFFF8
            F07DD0800000000000000008088F07DDDDDDDDDDDD0800000000000000000000
            807DD0F0FFFF8FFFF8FFFF0FFF0F07DDDDDDDDDDDD0F0F77FFF8F777F8F777F0
            F07DD0F0FFFF8FFFF8FFFF0FFF8F07DDDDDDDDDDDD0F0FFFFFF8FFFFF8FFFFF0
            F07DD0F0F00F8F00F8F00F0FFF0F07DDDDDDDDDDDD0F08888888888888888880
            F07DD0F0FFFF8FFFF8FFFF0FFF8F07DDDDDDDDDDDD0F0FFFFFF8FFFFF8FFFFF0
            F07DD0F0888888888888880FFF0F07DDCDDDDCDDDD0F0F00FFF8F00FF8F00FF0
            F07DD0F0FFFF8FFFF8FFFF0FFF8F07DDCCCCDCCDDD0F0FFFFFF8FFFFF8FFFFF0
            F07DD0F0FFFF8F00F8F00F0FFF0F07DDCCCCCCCCDD0F08888888888888888880
            F07DD0F0FFFF8FFFF8FFFF0FFF8F07DDCCCCDCCDDD0F0FFFFFF8FFFFF8FFFFF0
            F07DD0F0FFFF8F00F8F00F0FFF0F07DDCDDDDCDDDD0F0FFFFFF8F000F8F000F0
            F07DD0F0FFFF8FFFF8FFFF0FFF8F07DDDDDDDDDDDD0F0FFFFFF8FFFFF8FFFFF0
            F07DD0F0F00F8F00F8F00F0FFF0F07DDDDDDDDDDDD0F0F00FFF8F000F8F000F0
            F07DD0F0FFFF8FFFF8FFFF0FFF8F07DDCDDDDCDDDD0F0FFFFFF8FFFFF8FFFFF0
            F07DD0F0888888888888880FFF0F07DDCCCCDCCDDD0F08888888888888888880
            F07DD0F0FFFF8FFFF8FFFF0FFF8F07DDCCCCCCCCDD0F0FFFFFF8FFFFF8FFFFF0
            F07DD0F0FFFF8F00F8F00F0FFF0F07DDCCCCDCCDDD0F0FFFFFF8F0FFF8F0FFF0
            F07DD0F0FFFF8FFFF8FFFF0FFF8F07DDCDDDDCDDDD0F0FFFFFF8FFFFF8FFFFF0
            F07DD0F0F00F8F00F8F00F0FFF0F07DDDDDDDDDDDD0F0F00FFF8F000F8F000F0
            F07DD0F0FFFF8FFFF8FFFF0FFF8F07DDDDDDDDDDDD0F0FFFFFF8FFFFF8FFFFF0
            F07DD0F0777777777777770FFF0F07DDDDDDDDDDDD0F07777777777777777770
            F07DD0F0F8887F8887F8880FFF8F07DDDDDDDDDDDD0F0F888887F88887F88880
            F07DD0F0F0087F0087F0080FFF0F07DDDDDDDDDDDD0F0F800087F80087F80080
            F07DD0F0FFFF7FFFF7FFFF0FFF8F07DDDDDDDDDDDD0F0FFFFFF7FFFFF7FFFFF0
            F07DD0800000000000000008080807DDDDDDDDDDDD0800000000000000000000
            807DD0F8FFFFFFFFFFFFFFFFFF8F07DDDDDDDDDDDD0F8FFFFFFFFFFFFFFFFFF8
            F07DD0F8FFFFFFFFFFFFFFFFFF8F07DDDDDDDDDDDD0F8FFFFFFFFFFFFFFFFFF8
            F07DD000000000000000000000000DDDDDDDDDDDDD0000000000000000000000
            00DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
            DDDD}
          Transparent = True
        end
        object chbxIncludeFixed: TCheckBox
          Left = 90
          Top = 52
          Width = 161
          Height = 17
          Caption = '&Including fixed cells'
          TabOrder = 1
          OnClick = chbxIncludeFixedClick
        end
        object chbxOnlySelected: TCheckBox
          Left = 90
          Top = 30
          Width = 161
          Height = 17
          Caption = 'Only &selected cells'
          TabOrder = 0
          OnClick = chbxOnlySelectedClick
        end
        object chbxUse3DEffects: TCheckBox
          Tag = 12
          Left = 91
          Top = 100
          Width = 161
          Height = 17
          Caption = '&Use 3D Effects'
          TabOrder = 2
          OnClick = chbxUse3DEffectsClick
        end
        object chbxUseSoft3D: TCheckBox
          Tag = 13
          Left = 91
          Top = 122
          Width = 161
          Height = 17
          Caption = 'Soft &3D'
          TabOrder = 3
          OnClick = chbxUseSoft3DClick
        end
        object chbxRowAutoHeight: TCheckBox
          Left = 90
          Top = 200
          Width = 161
          Height = 17
          Caption = '&Row Auto Height'
          TabOrder = 5
          OnClick = chbxRowAutoHeightClick
        end
        object chbxAutoWidth: TCheckBox
          Left = 90
          Top = 178
          Width = 161
          Height = 17
          Caption = 'AutoWidth'
          TabOrder = 4
          OnClick = chbxAutoWidthClick
        end
      end
    end
  end
  object pnlPreview: TPanel
    Left = 272
    Top = 50
    Width = 294
    Height = 215
    BevelInner = bvLowered
    BevelOuter = bvNone
    Color = clWindow
    TabOrder = 1
  end
end
