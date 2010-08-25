object dxChlbxReportLinkDesignWindow: TdxChlbxReportLinkDesignWindow
  Left = 548
  Top = 365
  BorderStyle = bsDialog
  Caption = 'dxCLbReportLinkDesigner'
  ClientHeight = 243
  ClientWidth = 552
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
    Top = 3
    Width = 544
    Height = 204
    ActivePage = tshColor
    MultiLine = True
    TabOrder = 1
    OnChange = PageControl1Change
    object tshOptions: TTabSheet
      Caption = '&Options'
      object pnlOptions: TPanel
        Left = 0
        Top = 0
        Width = 536
        Height = 176
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Bevel11: TBevel
          Left = 41
          Top = 18
          Width = 207
          Height = 4
          Shape = bsBottomLine
        end
        object Bevel4: TBevel
          Left = 79
          Top = 90
          Width = 167
          Height = 4
          Shape = bsBottomLine
        end
        object Image5: TImage
          Left = 10
          Top = 109
          Width = 64
          Height = 32
          Picture.Data = {
            07544269746D617076040000424D760400000000000076000000280000004000
            0000200000000100040000000000000400000000000000000000100000001000
            0000000000000000800000800000008080008000000080008000808000008080
            8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
            FF00DD777777777777777777777777DDDDDDDDDDDDD777777777777777777777
            777DD0000000000000000000000007DDDDDDDDDDDD0000000000000000000000
            007DD0FFFFFFF7FFFFFFFFFFFFFF07DDDDDDDDDDDD0FFFFFFFFFFFFFFFFFFFFF
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDDDDDDDDDDD0F77777777777777777777
            F07DD0F0000FF7F0000000FF000F07DDDDDDDDDDDD0F7FFF77777FF77777FFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDDDDDDDDDDD0F77777777777777777777
            F07DD0777777777777777777777707DDDDDDDDDDDD0FFFFFFFFFFFFFFFFFFFFF
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDDDDDDDDDDD0F77777777777777777777
            F07DD0F0000FF7F00000000000FF07DDDDDDDDDDDD0F7FFFFFFF7FFFFFFFFFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDDDDDDDDDDD0F7F000FFF7F00000F00F7
            F07DD0777777777777777777777707DDCDDDDCDDDD0F7FFFFFFF7FFFFFFFFFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDCCCCDCCDDD0F7F00000F7F00000000F7
            F07DD0F00000F7F0000000FF000F07DDCCCCCCCCDD0F7FFFFFFF7FFFFFFFFFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDCCCCDCCDDD0F77777777777777777777
            F07DD0777777777777777777777707DDCDDDDCDDDD0F7FFFFFFF7FFFFFFFFFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDDDDDDDDDDD0F7FFFFFFF7F000000FFF7
            F07DD0F00FFFF7F000000000000F07DDDDDDDDDDDD0F7FFFFFFF7FFFFFFFFFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDDDDDDDDDDD0F7FFFFFFF7F0000F000F7
            F07DD0F00000F7F00000000F000F07DDDDDDDDDDDD0F7FFFFFFF7FFFFFFFFFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDDDDDDDDDDD0F7F00000F7F00000000F7
            F07DD0777777777777777777777707DDDDDDDDDDDD0F7FFFFFFF7FFFFFFFFFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDCDDDDCDDDD0F7F00F00F7F000000FFF7
            F07DD0F00FFFF7F000000FF000FF07DDCCCCDCCDDD0F7FFFFFFF7FFFFFFFFFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDCCCCCCCCDD0F7F00000F7F00000000F7
            F07DD0F00000F7F000000000000F07DDCCCCDCCDDD0F7FFFFFFF7FFFFFFFFFF7
            F07DD0FFFFFFF7FFFFFFFFFFFFFF07DDCDDDDCDDDD0F77777777777777777777
            F07DD0000000000000000000000007DDDDDDDDDDDD0FFFFFFFFFFFFFFFFFFFFF
            F07DD0888888808888888888888807DDDDDDDDDDDD0F77777777777777777777
            F07DD0880000808800000088888807DDDDDDDDDDDD0F77777777777777777777
            F07DD0888888808888888888888807DDDDDDDDDDDD0FFFFFFFFFFFFFFFFFFFFF
            F07DD000000000000000000000000DDDDDDDDDDDDD0000000000000000000000
            00DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
            DDDD}
          Transparent = True
        end
        object imgGrid: TImage
          Left = 10
          Top = 34
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
        object lblShow: TLabel
          Left = 6
          Top = 14
          Width = 26
          Height = 13
          Caption = 'Show'
        end
        object lblMiscellaneous: TLabel
          Left = 6
          Top = 85
          Width = 65
          Height = 13
          Caption = 'Miscellaneous'
        end
        object chbxShowBorders: TCheckBox
          Left = 95
          Top = 31
          Width = 148
          Height = 17
          Caption = 'Border'
          TabOrder = 0
          OnClick = chbxShowBordersClick
        end
        object chbxShowHorzLines: TCheckBox
          Tag = 1
          Left = 95
          Top = 54
          Width = 148
          Height = 17
          Caption = 'Horizontal Lines'
          TabOrder = 1
          OnClick = chbxShowBordersClick
        end
        object chbxFlatCheckMarks: TCheckBox
          Tag = 2
          Left = 95
          Top = 107
          Width = 148
          Height = 17
          Caption = 'Flat Check &Marks'
          TabOrder = 2
          OnClick = chbxShowBordersClick
        end
        object chbxRowAutoHeight: TCheckBox
          Left = 95
          Top = 153
          Width = 148
          Height = 17
          Caption = '&Row Auto Height'
          TabOrder = 4
          OnClick = chbxRowAutoHeightClick
        end
        object lblPreview: TStaticText
          Left = 256
          Top = 1
          Width = 42
          Height = 17
          Caption = 'Preview'
          TabOrder = 5
        end
        object chbxAutoWidth: TCheckBox
          Left = 95
          Top = 130
          Width = 148
          Height = 17
          Caption = 'AutoWidth'
          TabOrder = 3
          OnClick = chbxAutoWidthClick
        end
      end
    end
    object tshColor: TTabSheet
      Caption = '&Color'
      object pnlColor: TPanel
        Left = 0
        Top = 0
        Width = 536
        Height = 176
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object lblGridLinesColor: TLabel
          Left = 14
          Top = 143
          Width = 79
          Height = 13
          Caption = 'Grid Lines color: '
          OnClick = lblComboClick
        end
        object bvlLineColorHolder: TBevel
          Left = 100
          Top = 137
          Width = 126
          Height = 21
          Visible = False
        end
        object lblDrawMode: TLabel
          Left = 6
          Top = 13
          Width = 58
          Height = 13
          Caption = 'Draw &Mode:'
          FocusControl = cbxDrawMode
          OnClick = lblComboClick
        end
        object gbxTransparent: TGroupBox
          Left = 6
          Top = 45
          Width = 232
          Height = 82
          Caption = '  '
          TabOrder = 2
          object lblColor: TLabel
            Left = 9
            Top = 24
            Width = 35
            Height = 13
            Caption = 'Co&lor : '
            OnClick = lblComboClick
          end
          object bvlColorHolder: TBevel
            Left = 94
            Top = 20
            Width = 126
            Height = 21
            Visible = False
          end
          object lblEvenColor: TLabel
            Left = 9
            Top = 50
            Width = 59
            Height = 13
            Caption = 'E&ven Color: '
            OnClick = lblComboClick
          end
          object bvlEvenColorHolder: TBevel
            Left = 94
            Top = 46
            Width = 126
            Height = 21
            Visible = False
          end
        end
        object chbxTransparent: TCheckBox
          Left = 18
          Top = 42
          Width = 15
          Height = 17
          Caption = 'T&ransparent'
          TabOrder = 1
          OnClick = chbxTransparentClick
        end
        object cbxDrawMode: TComboBox
          Left = 77
          Top = 8
          Width = 161
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
          Top = 43
          Width = 69
          Height = 17
          Caption = ' Transparent '
          FocusControl = chbxTransparent
          TabOrder = 3
          OnClick = stTransparentClick
        end
      end
    end
    object tshFont: TTabSheet
      Caption = '&Font'
      object pnlFont: TPanel
        Left = 0
        Top = 0
        Width = 536
        Height = 176
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
          Top = 37
          Width = 231
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 1
          Text = 'edFont'
        end
        object btnEvenFont: TButton
          Tag = 1
          Left = 9
          Top = 70
          Width = 110
          Height = 23
          Caption = 'E&ven Font ...'
          TabOrder = 2
          OnClick = btnFontClick
        end
        object edEvenFont: TEdit
          Left = 9
          Top = 98
          Width = 231
          Height = 21
          TabStop = False
          Color = clBtnFace
          ReadOnly = True
          TabOrder = 3
          Text = 'edFont'
        end
      end
    end
  end
  object pnlPreview: TPanel
    Left = 265
    Top = 46
    Width = 273
    Height = 150
    BevelInner = bvLowered
    BevelOuter = bvNone
    Color = clWindow
    TabOrder = 0
  end
end
