object frmEChartEditor: TfrmEChartEditor
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'TdxOrgChart editor'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Height = 375
  Width = 544
  Left = 8
  Top = 8
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object TreeBox: TGroupBox
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    Left = 0
    Top = 0
    Width = 400
    Height = 300
    object Panel2: TPanel
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      Left = 2
      Top = 257
      Width = 396
      Height = 41
      object Panel5: TPanel
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 0
        Left = 211
        Top = 0
        Width = 185
        Height = 41
        object InsButton: TSpeedButton
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            0400000000000001000000000000000000001000000010000000000000000000
            800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
            33333333FF33333333FF333993333333300033377F3333333777333993333333
            300033F77FFF3333377739999993333333333777777F3333333F399999933333
            33003777777333333377333993333333330033377F3333333377333993333333
            3333333773333333333F333333333333330033333333F33333773333333C3333
            330033333337FF3333773333333CC333333333FFFFF77FFF3FF33CCCCCCCCCC3
            993337777777777F77F33CCCCCCCCCC3993337777777777377333333333CC333
            333333333337733333FF3333333C333330003333333733333777333333333333
            3000333333333333377733333333333333333333333333333333}
          NumGlyphs = 2
          ParentShowHint = False
          ShowHint = True
          Left = 8
          Top = 8
          Width = 25
          Height = 25
          OnClick = InsButtonClick
        end
        object CInsButton: TSpeedButton
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            0400000000000001000000000000000000001000000010000000000000000000
            800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
            333333333333333333333333333333333333333333333333FFF3333333333333
            00333333333333FF77F3333333333300903333333333FF773733333333330099
            0333333333FF77337F3333333300999903333333FF7733337333333700999990
            3333333777333337F3333333099999903333333373F333373333333330999903
            33333333F7F3337F33333333709999033333333F773FF3733333333709009033
            333333F7737737F3333333709073003333333F77377377F33333370907333733
            33333773773337333333309073333333333337F7733333333333370733333333
            3333377733333333333333333333333333333333333333333333}
          NumGlyphs = 2
          ParentShowHint = False
          ShowHint = True
          Left = 40
          Top = 8
          Width = 25
          Height = 25
          OnClick = CInsButtonClick
        end
        object DelButton: TSpeedButton
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            0400000000000001000000000000000000001000000010000000000000000000
            800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
            333333333333333333FF33333333333330003333333333333777333333333333
            300033FFFFFF3333377739999993333333333777777F3333333F399999933333
            3300377777733333337733333333333333003333333333333377333333333333
            3333333333333333333F333333333333330033333F33333333773333C3333333
            330033337F3333333377333CC3333333333333F77FFFFFFF3FF33CCCCCCCCCC3
            993337777777777F77F33CCCCCCCCCC399333777777777737733333CC3333333
            333333377F33333333FF3333C333333330003333733333333777333333333333
            3000333333333333377733333333333333333333333333333333}
          NumGlyphs = 2
          ParentShowHint = False
          ShowHint = True
          Left = 72
          Top = 8
          Width = 25
          Height = 25
          OnClick = DelButtonClick
        end
        object ZoomButton: TSpeedButton
          AllowAllUp = True
          GroupIndex = 1
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            0400000000000001000000000000000000001000000010000000000000000000
            800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
            33033333333333333F7F3333333333333000333333333333F777333333333333
            000333333333333F777333333333333000333333333333F77733333333333300
            033333333FFF3F777333333700073B703333333F7773F77733333307777700B3
            333333773337777333333078F8F87033333337F3333337F33333778F8F8F8773
            333337333333373F333307F8F8F8F70333337F33FFFFF37F3333078999998703
            33337F377777337F333307F8F8F8F703333373F3333333733333778F8F8F8773
            333337F3333337F333333078F8F870333333373FF333F7333333330777770333
            333333773FF77333333333370007333333333333777333333333}
          NumGlyphs = 2
          ParentShowHint = False
          ShowHint = True
          Left = 120
          Top = 8
          Width = 25
          Height = 25
          OnClick = ZoomButtonClick
        end
        object RotateButton: TSpeedButton
          AllowAllUp = True
          GroupIndex = 2
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            0400000000000001000000000000000000001000000010000000000000000000
            800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF003FFFFFFFFFFF
            FFFF33333333333FFFFF3FFFFFFFFF00000F333333333377777F33FFFFFFFF09
            990F33333333337F337F333FFFFFFF09990F33333333337F337F3333FFFFFF09
            990F33333333337FFF7F33333FFFFF00000F3333333333777773333333FFFFFF
            FFFF3333333333333F333333333FFFFF0FFF3333333333337FF333333333FFF0
            00FF33333333333777FF333333333F00000F33FFFFF33777777F300000333000
            0000377777F33777777730EEE033333000FF37F337F3333777F330EEE0333330
            00FF37F337F3333777F330EEE033333000FF37FFF7F333F77733300000333000
            03FF3777773337777333333333333333333F3333333333333333}
          NumGlyphs = 2
          ParentShowHint = False
          ShowHint = True
          Left = 152
          Top = 8
          Width = 25
          Height = 25
          OnClick = RotateButtonClick
        end
      end
    end
    object Tree: TdxOrgChart
      Align = alClient
      Ctl3D = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentCtl3D = False
      Left = 2
      Top = 15
      Width = 396
      Height = 242
      OnChange = TreeChange
    end
  end
  object PropBox: TGroupBox
    Align = alRight
    Caption = 'Node properties'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Left = 400
    Top = 0
    Width = 136
    Height = 300
    object Label1: TLabel
      Caption = '&Width'
      FocusControl = WidthEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Left = 8
      Top = 16
      Width = 28
      Height = 13
      OnClick = Label1Click
    end
    object Label2: TLabel
      Caption = '&Height'
      FocusControl = HeightEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Left = 72
      Top = 16
      Width = 31
      Height = 13
      OnClick = Label1Click
    end
    object Label3: TLabel
      Caption = '&Color'
      FocusControl = ColorEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Left = 8
      Top = 56
      Width = 24
      Height = 13
      OnClick = Label1Click
    end
    object Label4: TLabel
      Caption = 'Child&Align'
      FocusControl = AlignEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Left = 8
      Top = 96
      Width = 46
      Height = 13
      OnClick = Label1Click
    end
    object Label5: TLabel
      Caption = '&Shape'
      FocusControl = ShapeEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Left = 8
      Top = 136
      Width = 31
      Height = 13
      OnClick = Label1Click
    end
    object Label6: TLabel
      Caption = 'ImageIndex'
      FocusControl = IIEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Left = 8
      Top = 176
      Width = 55
      Height = 13
      OnClick = Label1Click
    end
    object Label7: TLabel
      Caption = 'ImageAlign'
      FocusControl = IAEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Left = 72
      Top = 176
      Width = 52
      Height = 13
      OnClick = Label1Click
    end
    object Label8: TLabel
      Caption = 'Text'
      Left = 9
      Top = 217
      Width = 21
      Height = 13
    end
    object WidthEdit: TEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Left = 8
      Top = 32
      Width = 57
      Height = 21
      OnExit = WidthEditExit
      OnKeyDown = WidthEditKeyDown
    end
    object HeightEdit: TEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Left = 72
      Top = 32
      Width = 57
      Height = 21
      OnExit = HeightEditExit
      OnKeyDown = WidthEditKeyDown
    end
    object ColorEdit: TComboBox
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      Sorted = True
      TabOrder = 2
      Left = 8
      Top = 72
      Width = 121
      Height = 21
      OnClick = ColorEditClick
      OnExit = ColorEditExit
      OnKeyDown = ColorEditKeyDown
    end
    object AlignEdit: TComboBox
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      TabOrder = 3
      Items.Strings = (
        'caLeft'
        'caCenter'
        'caRight')
      Left = 8
      Top = 112
      Width = 121
      Height = 21
      OnClick = AlignEditClick
      OnExit = AlignEditExit
    end
    object ShapeEdit: TComboBox
      Style = csDropDownList
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      TabOrder = 4
      Items.Strings = (
        'shRectangle'
        'shRoundRect'
        'shEllipse'
        'shDiamond')
      Left = 8
      Top = 152
      Width = 121
      Height = 21
      OnClick = ShapeEditClick
      OnExit = ShapeEditExit
    end
    object Panel3: TPanel
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 5
      Left = 2
      Top = 257
      Width = 132
      Height = 41
      object MultiButton: TSpeedButton
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          0400000000000001000000000000000000001000000010000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00303333333333
          333337F3333333333333303333333333333337F33FFFFF3FF3FF303300000300
          300337FF77777F77377330000BBB0333333337777F337F33333330330BB00333
          333337F373F773333333303330033333333337F3377333333333303333333333
          333337F33FFFFF3FF3FF303300000300300337FF77777F77377330000BBB0333
          333337777F337F33333330330BB00333333337F373F773333333303330033333
          333337F3377333333333303333333333333337FFFF3FF3FFF333000003003000
          333377777F77377733330BBB0333333333337F337F33333333330BB003333333
          333373F773333333333330033333333333333773333333333333}
        NumGlyphs = 2
        ParentShowHint = False
        ShowHint = True
        Left = 96
        Top = 8
        Width = 25
        Height = 25
        OnClick = MultiButtonClick
      end
    end
    object IIEdit: TEdit
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 6
      Left = 8
      Top = 192
      Width = 57
      Height = 21
      OnExit = IIEditExit
      OnKeyDown = WidthEditKeyDown
    end
    object IAEdit: TComboBox
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ItemHeight = 13
      ParentFont = False
      TabOrder = 7
      Items.Strings = (
        'iaNone'
        'iaLT'
        'iaLC'
        'iaLB'
        'iaRT'
        'iaRC'
        'iaRB'
        'iaTL'
        'iaTC'
        'iaTR'
        'iaBL'
        'iaBC'
        'iaBR')
      Left = 72
      Top = 192
      Width = 57
      Height = 21
      OnClick = IAEditExit
      OnExit = IAEditExit
    end
    object TTEdit: TEdit
      TabOrder = 8
      Left = 9
      Top = 232
      Width = 120
      Height = 21
      OnExit = TTEditExit
    end
  end
  object Panel1: TPanel
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    Left = 0
    Top = 300
    Width = 536
    Height = 41
    object Panel4: TPanel
      Align = alRight
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      Left = 367
      Top = 0
      Width = 169
      Height = 41
      object CancelButton: TButton
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 0
        Left = 86
        Top = 8
        Width = 75
        Height = 25
      end
      object OKButton: TButton
        Caption = 'OK'
        ModalResult = 1
        TabOrder = 1
        Left = 6
        Top = 8
        Width = 75
        Height = 25
      end
    end
  end
end
