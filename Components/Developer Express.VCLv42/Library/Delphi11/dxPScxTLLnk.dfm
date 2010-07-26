object dxfmTreeListReportLinkDesignWindow: TdxfmTreeListReportLinkDesignWindow
  Left = 426
  Top = 272
  BorderStyle = bsDialog
  Caption = 'Property Sheets'
  ClientHeight = 391
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 4
    Top = 4
    Width = 618
    Height = 353
    ActivePage = tshStyles
    TabOrder = 0
    OnChange = PageControl1Change
    object tshView: TTabSheet
      Caption = 'View'
      object lblShow: TLabel
        Left = 5
        Top = 8
        Width = 26
        Height = 13
        Caption = 'Show'
      end
      object imgShow: TImage
        Left = 8
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
      object bvlShow: TBevel
        Left = 43
        Top = 12
        Width = 253
        Height = 4
        Shape = bsBottomLine
      end
      object lblOnEveryPage: TLabel
        Left = 5
        Top = 166
        Width = 72
        Height = 13
        Caption = 'On Every Page'
      end
      object imgOnEveryPage: TImage
        Left = 8
        Top = 192
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
      object bvlOnEveryPage: TBevel
        Left = 90
        Top = 171
        Width = 205
        Height = 4
        Shape = bsBottomLine
      end
      object bvlWarningHost: TBevel
        Left = 5
        Top = 251
        Width = 293
        Height = 70
        Visible = False
      end
      object Bevel2: TBevel
        Left = 90
        Top = 91
        Width = 205
        Height = 4
        Shape = bsBottomLine
      end
      object chbxShowBands: TCheckBox
        Left = 90
        Top = 26
        Width = 200
        Height = 17
        Caption = 'Ba&nds'
        TabOrder = 0
        OnClick = OptionsViewClick
      end
      object chbxShowHeaders: TCheckBox
        Tag = 1
        Left = 90
        Top = 47
        Width = 200
        Height = 17
        Caption = '&Headers'
        TabOrder = 1
        OnClick = OptionsViewClick
      end
      object chbxShowFooters: TCheckBox
        Tag = 2
        Left = 90
        Top = 68
        Width = 200
        Height = 17
        Caption = 'Foo&ters'
        TabOrder = 2
        OnClick = OptionsViewClick
      end
      object chbxShowExpandButtons: TCheckBox
        Tag = 3
        Left = 90
        Top = 124
        Width = 200
        Height = 17
        Caption = 'Expand Buttons'
        TabOrder = 4
        OnClick = OptionsViewClick
      end
      object chbxBandsOnEveryPage: TCheckBox
        Left = 90
        Top = 184
        Width = 200
        Height = 17
        Caption = 'Ba&nds'
        TabOrder = 6
        OnClick = OptionsOnEveryPageClick
      end
      object chbxHeadersOnEveryPage: TCheckBox
        Tag = 1
        Left = 90
        Top = 205
        Width = 200
        Height = 17
        Caption = 'Headers'
        TabOrder = 7
        OnClick = OptionsOnEveryPageClick
      end
      object chbxFootersOnEveryPage: TCheckBox
        Tag = 2
        Left = 90
        Top = 226
        Width = 200
        Height = 17
        Caption = 'Footers'
        TabOrder = 8
        OnClick = OptionsOnEveryPageClick
      end
      object chbxShowTreeLines: TCheckBox
        Tag = 4
        Left = 90
        Top = 145
        Width = 200
        Height = 17
        Caption = 'TreeLines'
        TabOrder = 5
        OnClick = OptionsViewClick
      end
      object chbxShowBorders: TCheckBox
        Tag = 5
        Left = 90
        Top = 103
        Width = 200
        Height = 17
        Caption = 'Borders'
        TabOrder = 3
        OnClick = OptionsViewClick
      end
      object lblPreviewWindow: TStaticText
        Left = 305
        Top = 0
        Width = 82
        Height = 14
        AutoSize = False
        Caption = 'Preview'
        TabOrder = 9
      end
    end
    object tshBehaviors: TTabSheet
      Caption = 'Behaviors'
      ImageIndex = 1
      object pnlBehaviors: TPanel
        Left = 0
        Top = 0
        Width = 299
        Height = 325
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
        object pnlSelection: TPanel
          Left = 0
          Top = 0
          Width = 299
          Height = 75
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object lblSelection: TLabel
            Left = 5
            Top = 8
            Width = 43
            Height = 13
            Caption = 'Selection'
          end
          object imgSelection: TImage
            Left = 8
            Top = 32
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
          object bvlSelection: TBevel
            Left = 57
            Top = 12
            Width = 239
            Height = 4
            Shape = bsBottomLine
          end
          object chbxProcessSelection: TCheckBox
            Left = 90
            Top = 26
            Width = 205
            Height = 17
            Caption = 'Process Selection'
            TabOrder = 0
            OnClick = OptionsSelectionClick
          end
          object chbxProcessExactSelection: TCheckBox
            Tag = 1
            Left = 90
            Top = 51
            Width = 205
            Height = 17
            Caption = 'Process Exact Selection'
            TabOrder = 1
            OnClick = OptionsSelectionClick
          end
        end
        object pnlExpanding: TPanel
          Left = 0
          Top = 75
          Width = 299
          Height = 70
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object lblExpanding: TLabel
            Left = 5
            Top = 8
            Width = 50
            Height = 13
            Caption = 'Expanding'
          end
          object imgExpanding: TImage
            Left = 8
            Top = 32
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
          object bvlExpanding: TBevel
            Left = 62
            Top = 13
            Width = 234
            Height = 4
            Shape = bsBottomLine
          end
          object chbxExpandNodes: TCheckBox
            Left = 90
            Top = 26
            Width = 205
            Height = 17
            Caption = 'Nodes'
            TabOrder = 0
            OnClick = OptionsExpandingClick
          end
          object chbxExplicitlyExpandNodes: TCheckBox
            Tag = 1
            Left = 90
            Top = 51
            Width = 205
            Height = 17
            Caption = 'Explicitly Expand Nodes'
            TabOrder = 1
            OnClick = OptionsExpandingClick
          end
        end
        object pnlSize: TPanel
          Left = 0
          Top = 145
          Width = 299
          Height = 68
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 2
          object lblSize: TLabel
            Left = 5
            Top = 8
            Width = 19
            Height = 13
            Caption = 'Size'
          end
          object bvlSize: TBevel
            Left = 33
            Top = 13
            Width = 262
            Height = 4
            Shape = bsBottomLine
          end
          object imgGridSize: TImage
            Left = 8
            Top = 32
            Width = 64
            Height = 32
            Picture.Data = {
              07544269746D617076040000424D760400000000000076000000280000004000
              0000200000000100040000000000000400000000000000000000100000001000
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
          object chbxAutoWidth: TCheckBox
            Left = 90
            Top = 26
            Width = 205
            Height = 17
            Caption = '&Auto Width'
            TabOrder = 0
            OnClick = OptionsSizeClick
          end
        end
        object pnlSeparators: TPanel
          Left = 0
          Top = 213
          Width = 299
          Height = 94
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 3
          object lblSeparators: TLabel
            Left = 5
            Top = 8
            Width = 53
            Height = 13
            Caption = 'Separators'
          end
          object bvlSeparator: TBevel
            Left = 68
            Top = 13
            Width = 229
            Height = 4
            Shape = bsBottomLine
          end
          object lblSeparatorsThickness: TLabel
            Left = 90
            Top = 38
            Width = 50
            Height = 13
            Caption = 'Thickness:'
          end
          object lblSeparatorsColor: TLabel
            Left = 90
            Top = 67
            Width = 29
            Height = 13
            Caption = 'Color:'
          end
          object bvlSeparatorThicknessHost: TBevel
            Left = 152
            Top = 34
            Width = 80
            Height = 21
          end
          object bvlSeparatorColorHost: TBevel
            Left = 152
            Top = 62
            Width = 143
            Height = 21
          end
          object imgSeparators: TImage
            Left = 8
            Top = 32
            Width = 64
            Height = 32
            Picture.Data = {
              07544269746D617076040000424D760400000000000076000000280000004000
              0000200000000100040000000000000400000000000000000000100000001000
              0000000000000000800000800000008080008000000080008000808000008080
              8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
              FF00DD777777777777777777777777DDDDDDDDDDDDD777777777777777777777
              777DD0000000000000000000000007DDDDDDDDDDDD0000000000000000000000
              007DD0F8FFFFFFFFFFFFFFFFFF8F07DDDDDDDDDDDD0F8FFFFFFFFFFFFFFFFFF8
              F07DD0F8FFFFFFFFFFFFFFFFFF8F07DDDDDDDDDDDD0F8FFFFFFFFFFFFFFFFFF8
              F07DD0800000000000000000000F07DDDDDDDDDDDD0800000000000000000000
              807DD0F0F77FFF8F777F8F777F0F07DDDDDDDDDDDD0F0FFFFFF8FFFFF8FFFFF0
              F07DD0F0FFFFFF8FFFFF8FFFFF0F07DDDDDDDDDDDD0F0F00FFF8F00FF8F000F0
              F07DD0F08888888888888888880F07DDDDDDDDDDDD0F0FFFFFF8FFFFF8FFFFF0
              F07DD0F0FFFFFF8FFFFF8FFFFF0F07DDDDDDDDDDDD0F0F0000F8F000F8F000F0
              F07DD0F0F00FFF8F00FF8F00FF0F07DDCDDDDCDDDD0F0FFFFFF8FFFFF8FFFFF0
              F07DD0F0FFFFFF8FFFFF8FFFFF0F07DDCCCCDCCDDD0F00000000000000000000
              F07DD0F08888888888888888880F07DDCCCCCCCCDD0F00000000000000000000
              F07DD0F0FFFFFF8FFFFF8FFFFF0F07DDCCCCDCCDDD0F0FFFFFF8FFFFF8FFFFF0
              F07DD0F0FFFFFF8F000F8F000F0F07DDCDDDDCDDDD0F0FFFFFF8FFFFF8FFFFF0
              F07DD0F0FFFFFF8FFFFF8FFFFF0F07DDDDDDDDDDDD0F0F000FF8F000F8F00FF0
              F07DD0F0F00FFF8F000F8F000F0F07DDDDDDDDDDDD0F0FFFFFF8FFFFF8FFFFF0
              F07DD0F0FFFFFF8FFFFF8FFFFF0F07DDCDDDDCDDDD0F00000000000000000000
              F07DD0F08888888888888888880F07DDCCCCDCCDDD0F00000000000000000000
              F07DD0F0FFFFFF8FFFFF8FFFFF0F07DDCCCCCCCCDD0F0FFFFFF8FFFFF8FFFFF0
              F07DD0F0FFFFFF8F0FFF8F0FFF0F07DDCCCCDCCDDD0F0FFFFFF8F0FFF8F0FFF0
              F07DD0F0FFFFFF8FFFFF8FFFFF0F07DDCDDDDCDDDD0F0FFFFFF8FFFFF8FFFFF0
              F07DD0F0F00FFF8F000F8F000F0F07DDDDDDDDDDDD0F0F00FFF8F000F8F000F0
              F07DD0F0FFFFFF8FFFFF8FFFFF0F07DDDDDDDDDDDD0F0FFFFFF8FFFFF8FFFFF0
              F07DD0F07777777777777777770F07DDDDDDDDDDDD0F07777777777777777770
              F07DD0F0F888887F88887F88880F07DDDDDDDDDDDD0F0F888887F88887F88880
              F07DD0F0F800087F80087F80080F07DDDDDDDDDDDD0F0F800087F80087F80080
              F07DD0F0FFFFFF7FFFFF7FFFFF0F07DDDDDDDDDDDD0F0FFFFFF7FFFFF7FFFFF0
              F07DD0800000000000000000000807DDDDDDDDDDDD0800000000000000000000
              807DD0F8FFFFFFFFFFFFFFFFFF8F07DDDDDDDDDDDD0F8FFFFFFFFFFFFFFFFFF8
              F07DD0F8FFFFFFFFFFFFFFFFFF8F07DDDDDDDDDDDD0F8FFFFFFFFFFFFFFFFFF8
              F07DD000000000000000000000000DDDDDDDDDDDDD0000000000000000000000
              00DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
              DDDD}
            Transparent = True
          end
        end
      end
    end
    object tshFormatting: TTabSheet
      Caption = 'Formatting'
      ImageIndex = 4
      object lblLookAndFeel: TLabel
        Left = 5
        Top = 8
        Width = 66
        Height = 13
        Caption = 'Look and Feel'
      end
      object bvlLookAndFeel: TBevel
        Left = 85
        Top = 12
        Width = 211
        Height = 4
        Shape = bsBottomLine
      end
      object imgLookAndFeel: TImage
        Left = 8
        Top = 32
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
      object imgRefinements: TImage
        Left = 7
        Top = 100
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
      object lblRefinements: TLabel
        Left = 5
        Top = 78
        Width = 60
        Height = 13
        Caption = 'Refinements'
      end
      object bvlRefinements: TBevel
        Left = 70
        Top = 83
        Width = 226
        Height = 4
        Shape = bsBottomLine
      end
      object bvlRefinementsSeparator: TBevel
        Left = 90
        Top = 168
        Width = 205
        Height = 4
        Shape = bsBottomLine
      end
      object cbxLookAndFeel: TComboBox
        Left = 90
        Top = 37
        Width = 202
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = LookAndFeelChange
      end
      object chbxFlatCheckMarks: TCheckBox
        Tag = 2
        Left = 90
        Top = 145
        Width = 210
        Height = 17
        Caption = 'Flat Check &Marks'
        TabOrder = 3
        OnClick = OptionsRefinementsClick
      end
      object chbxDisplayGraphicsAsText: TCheckBox
        Tag = 1
        Left = 90
        Top = 122
        Width = 210
        Height = 17
        Caption = 'Display Graphics As &Text'
        TabOrder = 2
        OnClick = OptionsRefinementsClick
      end
      object chbxTransparentGraphics: TCheckBox
        Left = 90
        Top = 100
        Width = 210
        Height = 17
        Caption = 'Transparent &Graphics'
        TabOrder = 1
        OnClick = OptionsRefinementsClick
      end
      object chbxSuppressBackgroundBitmaps: TCheckBox
        Tag = 1
        Left = 90
        Top = 181
        Width = 210
        Height = 17
        Caption = 'Suppress Background Textures'
        TabOrder = 4
        OnClick = OptionsFormattingClick
      end
      object chbxConsumeSelectionStyle: TCheckBox
        Tag = 2
        Left = 90
        Top = 204
        Width = 210
        Height = 17
        Caption = 'Consume Selection Style'
        TabOrder = 5
        OnClick = OptionsFormattingClick
      end
    end
    object tshStyles: TTabSheet
      Caption = 'Styles'
      ImageIndex = 4
      object bvlStyles: TBevel
        Left = 115
        Top = 13
        Width = 181
        Height = 4
        Shape = bsBottomLine
      end
      object bvlStyleSheets: TBevel
        Left = 72
        Top = 249
        Width = 224
        Height = 5
        Shape = bsBottomLine
      end
      object lblStyleSheets: TLabel
        Left = 6
        Top = 246
        Width = 60
        Height = 13
        Caption = 'Style Sheets'
      end
      object bvlStylesHost: TBevel
        Left = 6
        Top = 33
        Width = 214
        Height = 173
      end
      object Label1: TLabel
        Left = 79
        Top = 110
        Width = 68
        Height = 13
        Caption = '[ Styles Host ]'
        Visible = False
      end
      object lblUseNativeStyles: TLabel
        Left = 24
        Top = 9
        Width = 84
        Height = 13
        Caption = '&Use Native Styles'
        FocusControl = chbxUseNativeStyles
        OnClick = lblUseNativeStylesClick
      end
      object btnStyleColor: TButton
        Left = 229
        Top = 61
        Width = 68
        Height = 23
        Caption = 'Co&lor...'
        TabOrder = 2
        OnClick = StyleColorClick
      end
      object btnStyleFont: TButton
        Left = 229
        Top = 33
        Width = 68
        Height = 23
        Caption = '&Font...'
        TabOrder = 1
        OnClick = StyleFontClick
      end
      object btnStyleBackgroundBitmap: TButton
        Left = 229
        Top = 97
        Width = 68
        Height = 23
        Caption = '&Texture...'
        TabOrder = 3
        OnClick = StyleBackgroundBitmapClick
      end
      object chbxUseNativeStyles: TCheckBox
        Left = 5
        Top = 8
        Width = 15
        Height = 17
        TabOrder = 0
        OnClick = OptionsFormattingClick
      end
      object cbxStyleSheets: TComboBox
        Left = 6
        Top = 265
        Width = 288
        Height = 24
        Style = csOwnerDrawFixed
        ItemHeight = 18
        TabOrder = 7
        OnClick = cbxStyleSheetsClick
        OnDrawItem = cbxStyleSheetsDrawItem
        OnKeyDown = cbxStyleSheetsKeyDown
      end
      object btnStyleSheetNew: TButton
        Left = 6
        Top = 297
        Width = 68
        Height = 23
        Caption = '&New...'
        TabOrder = 8
        OnClick = btnStyleSheetNewClick
      end
      object btnStyleSheetCopy: TButton
        Left = 79
        Top = 297
        Width = 68
        Height = 23
        Caption = '&Copy...'
        TabOrder = 9
        OnClick = btnStyleSheetCopyClick
      end
      object btnStyleSheetDelete: TButton
        Left = 153
        Top = 297
        Width = 68
        Height = 23
        Caption = '&Delete...'
        TabOrder = 10
        OnClick = btnStyleSheetDeleteClick
      end
      object btnStylesSaveAs: TButton
        Left = 116
        Top = 213
        Width = 104
        Height = 23
        Caption = 'Save &As...'
        TabOrder = 6
        OnClick = StylesSaveAsClick
      end
      object btnStyleSheetRename: TButton
        Left = 226
        Top = 297
        Width = 68
        Height = 23
        Caption = '&Rename...'
        TabOrder = 11
        OnClick = btnStyleSheetRenameClick
      end
      object btnStyleBackgroundBitmapClear: TButton
        Left = 229
        Top = 125
        Width = 68
        Height = 23
        Caption = 'Clear'
        TabOrder = 4
        OnClick = StyleBackgroundBitmapClearClick
      end
      object btnStyleRestoreDefaults: TButton
        Left = 6
        Top = 213
        Width = 105
        Height = 23
        Caption = 'Restore Defaults'
        TabOrder = 5
        OnClick = StyleRestoreDefaultsClick
      end
    end
    object tshPreview: TTabSheet
      Caption = 'Preview'
      ImageIndex = 2
      object lblPreviewOptions: TLabel
        Left = 5
        Top = 8
        Width = 37
        Height = 13
        Caption = 'Options'
      end
      object bvlPreviewOptions: TBevel
        Left = 54
        Top = 12
        Width = 242
        Height = 5
        Shape = bsBottomLine
      end
      object lblPreviewMaxLineCount: TLabel
        Left = 90
        Top = 75
        Width = 78
        Height = 13
        Caption = 'Max Line Count:'
      end
      object bvlPreviewMaxLineCountHost: TBevel
        Left = 215
        Top = 71
        Width = 68
        Height = 21
        Visible = False
      end
      object imgPreview: TImage
        Left = 8
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
          7DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F07DDDDDD0F7FC9F77777777777777F7F0
          7DDDDDD0F7F9CF77777777777777F7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7F7FFCCFFCCCCFFCCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7F7FFCCCCCFCCCCFCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7F7FFCCCCCCCFCCFCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7F7FFCCCCCCCCCCCCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7F7FFCCCCCCCCFCCFCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7F7FFCCCCCFFCCCFCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7F7FFCCCCCCCCCCCCCCF7F07DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F0
          7DDDDDD0F7FC9F77777777777777F7F07DDDDDD0F7F9CF77777777777777F7F0
          7DDDDDD0F7FFFFFFFFFFFFFFFFFFF7F07DDDDDD0F777777777777777777777F0
          7DDDDDD0F7F88887F888887F888887F07DDDDDD0F7F00087F000087F000087F0
          7DDDDDD0F7FFFFF7FFFFFF7FFFFFF7F07DDDDDD0F777777777777777777777F0
          7DDDDDD0FFFFFFFFFFFFFFFFFFFFFFF07DDDDDD0000000000000000000000000
          DDDD}
        Transparent = True
      end
      object chbxPreviewVisible: TCheckBox
        Left = 90
        Top = 30
        Width = 207
        Height = 17
        Caption = 'Visible'
        TabOrder = 0
        OnClick = PreviewVisibleClick
      end
      object chbxPreviewAutoHeight: TCheckBox
        Left = 90
        Top = 51
        Width = 207
        Height = 17
        Caption = 'Auto Height'
        TabOrder = 1
        OnClick = PreviewAutoHeightClick
      end
    end
  end
  object pnlPreview: TPanel
    Left = 313
    Top = 44
    Width = 300
    Height = 304
    BevelOuter = bvLowered
    Color = clWindow
    TabOrder = 1
    object PreviewTreeList: TcxTreeList
      Left = 5
      Top = 5
      Width = 291
      Height = 294
      Bands = <
        item
          Caption.Text = 'Manufacturer Data'
          Width = 173
        end
        item
          Caption.Text = 'Car Data'
          Width = 116
        end>
      BufferedPaint = False
      DefaultRowHeight = 17
      Enabled = False
      OptionsBehavior.AutomateLeftMostIndent = False
      OptionsView.CellAutoHeight = True
      OptionsView.ScrollBars = ssNone
      OptionsView.Bands = True
      OptionsView.ColumnAutoWidth = True
      OptionsView.GridLines = tlglBoth
      OptionsView.UseNodeColorForIndent = False
      Preview.Column = colManufacturerCountry
      TabOrder = 0
      OnCustomDrawBandHeader = PreviewTreeListCustomDrawBandHeader
      OnCustomDrawCell = PreviewTreeListCustomDrawCell
      OnCustomDrawFooterCell = PreviewTreeListCustomDrawFooterCell
      OnCustomDrawHeaderCell = PreviewTreeListCustomDrawHeader
      object colManufacturerName: TcxTreeListColumn
        Caption.Text = 'Name'
        DataBinding.ValueType = 'String'
        Width = 113
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object colManufacturerLogo: TcxTreeListColumn
        Caption.Text = 'Logo'
        DataBinding.ValueType = 'String'
        Width = 60
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object colManufacturerCountry: TcxTreeListColumn
        Caption.Text = 'Country'
        DataBinding.ValueType = 'String'
        Width = 167
        Position.ColIndex = 2
        Position.RowIndex = 0
        Position.BandIndex = 0
      end
      object colCarModel: TcxTreeListColumn
        Caption.Text = 'Model'
        DataBinding.ValueType = 'String'
        Width = 86
        Position.ColIndex = 0
        Position.RowIndex = 0
        Position.BandIndex = 1
      end
      object colCarIsSUV: TcxTreeListColumn
        Caption.Text = 'SUV'
        DataBinding.ValueType = 'String'
        Width = 30
        Position.ColIndex = 1
        Position.RowIndex = 0
        Position.BandIndex = 1
      end
    end
  end
  object cxStyleRepository1: TcxStyleRepository
    Left = 4
    Top = 362
    object styleBandHeaders: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
    end
    object styleStandard: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object stylePreview: TcxStyle
      AssignedValues = [svFont]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
    end
    object styleCardShadow: TcxStyle
    end
  end
  object pmStyles: TPopupMenu
    Images = ilStylesPopup
    OnPopup = pmStylesPopup
    Left = 32
    Top = 362
    object miStyleFont: TMenuItem
      Caption = '&Font...'
      ImageIndex = 0
      ShortCut = 16454
      OnClick = StyleFontClick
    end
    object miStyleColor: TMenuItem
      Caption = '&Color...'
      OnClick = StyleColorClick
    end
    object miLine3: TMenuItem
      Caption = '-'
    end
    object miStyleBackgroundBitmap: TMenuItem
      Caption = '&Texture...'
      ImageIndex = 1
      OnClick = StyleBackgroundBitmapClick
    end
    object miStyleBackgroundBitmapClear: TMenuItem
      Caption = 'Clear'
      ImageIndex = 3
      ShortCut = 16430
      OnClick = StyleBackgroundBitmapClearClick
    end
    object milLine: TMenuItem
      Caption = '-'
    end
    object miStylesSelectAll: TMenuItem
      Caption = 'Select A&ll'
      ShortCut = 16449
      OnClick = miStylesSelectAllClick
    end
    object miLine2: TMenuItem
      Caption = '-'
    end
    object miStyleRestoreDefaults: TMenuItem
      Caption = 'Restore Defaults'
      OnClick = StyleRestoreDefaultsClick
    end
    object miLine4: TMenuItem
      Caption = '-'
    end
    object miStylesSaveAs: TMenuItem
      Caption = 'Save &As...'
      ImageIndex = 2
      ShortCut = 16467
      OnClick = StylesSaveAsClick
    end
  end
  object ilStylesPopup: TImageList
    Left = 60
    Top = 362
    Bitmap = {
      494C010104000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
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
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000000000000080800000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00000000000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000000000000080800000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000008080
      8000808080008080800080808000808080008080800000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF000000
      0000008080000080800000808000008080000080800000808000008080000080
      8000008080000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000080800000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF008080
      8000000000000080800000808000008080000080800000808000008080000080
      8000008080000080800000000000000000000000000000000000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000008080000080800000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF008080
      8000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008080000080
      8000000000000000000000000000000000000000000000000000000000000000
      0000008080000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF008080
      8000FFFFFF00FFFF0000FFFFFF00FFFF0000FFFFFF00FFFF0000FFFFFF00FFFF
      0000FFFFFF00FFFFFF0000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF008080
      8000FFFFFF00FFFFFF00FFFF0000FFFFFF00FFFF0000FFFFFF00FFFF0000FFFF
      FF00FFFF0000FFFFFF0000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000000000000080800000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF008080
      8000FFFFFF00FFFF0000C0C0C000FFFF0000FFFFFF00FFFF0000FFFFFF00FFFF
      0000FFFFFF00FFFFFF0000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000808080000000
      0000000000008080800080808000000000000000000080808000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000FFFFFF00C0C0C00000FFFF00C0C0C000FFFF0000FFFFFF00FFFF0000FFFF
      FF00FFFF0000FFFFFF0000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000000000000080800000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000808080008080
      8000000000008080800080808000000000008080800080808000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000FFFFFF00FFFF0000C0C0C000FFFF0000FFFFFF00FFFF0000FFFFFF00FFFF
      0000FFFFFF00FFFFFF0000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000808080008080
      8000808080008080800080808000808080008080800080808000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000008080000000
      0000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C00000000000C0C0C00000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFC001FFFF
      FE07001F8001FFF9FF9F000F8001E7FFFF9F00078001C3F3E01F00038001C3E7
      F99F00018001E1C7F99B00008001F08FF99B00018001F81FF89300018001FC3F
      D80300018001F81FD9BF80018001F09FC93FE0018001C1C7C03FE001800183E3
      FFFFE00180018FF1FFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
end
