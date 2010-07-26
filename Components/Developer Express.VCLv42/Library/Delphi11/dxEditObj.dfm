object FEditObject: TFEditObject
  Left = 368
  Top = 185
  BorderStyle = bsDialog
  Caption = 'Edit Object'
  ClientHeight = 318
  ClientWidth = 324
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 324
    Height = 290
    ActivePage = tsGeneral
    Align = alClient
    TabOrder = 0
    object tsGeneral: TTabSheet
      Caption = 'General'
      object Label1: TLabel
        Left = 62
        Top = 56
        Width = 21
        Height = 13
        Caption = 'Text'
      end
      object Label2: TLabel
        Left = 22
        Top = 132
        Width = 56
        Height = 13
        Caption = 'Text Layout'
      end
      object Label3: TLabel
        Left = 26
        Top = 154
        Width = 58
        Height = 13
        Caption = 'Shape Type'
      end
      object Label4: TLabel
        Left = 32
        Top = 178
        Width = 51
        Height = 13
        Caption = 'Line Width'
      end
      object Label6: TLabel
        Left = 52
        Top = 6
        Width = 31
        Height = 13
        Caption = 'Height'
      end
      object Label7: TLabel
        Left = 56
        Top = 32
        Width = 28
        Height = 13
        Caption = 'Width'
      end
      object sbFont: TSpeedButton
        Left = 292
        Top = 54
        Width = 23
        Height = 22
        Hint = 'Font'
        Flat = True
        Glyph.Data = {
          E6000000424DE60000000000000076000000280000000D0000000E0000000100
          0400000000007000000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDDDDD
          D00000DDDDDDDDDDD00000DDDDD000DDD000000DDDDD0DDDD00000DDDDDD0D0D
          D00000DDDDDD000DD0000000DDDD0D0DD000DDDDDDDD0DDD0000DDD00DD00000
          0000DDDDD0DDDDDDD000DDDDD0DDDDDDD000DDDD000DDDDDD000DDDDD0DDDDDD
          D000DDDDDD00DDDDD000}
        ParentShowHint = False
        ShowHint = True
        OnClick = sbFontClick
      end
      object Label8: TLabel
        Left = 24
        Top = 198
        Width = 58
        Height = 13
        Caption = 'Shape Color'
      end
      object Label9: TLabel
        Left = 2
        Top = 218
        Width = 81
        Height = 13
        Caption = 'BackGroud Color'
      end
      object memoText: TMemo
        Left = 88
        Top = 54
        Width = 203
        Height = 69
        Lines.Strings = (
          'memoText')
        TabOrder = 0
        OnChange = seHeightChange
      end
      object cbTextPosition: TComboBox
        Left = 88
        Top = 126
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        Items.Strings = (
          'Top-Left'
          'Top'
          'Top-Right'
          'Left'
          'Center'
          'Right'
          'Bottom-Left'
          'Bottom'
          'Bottom-Right')
        TabOrder = 1
        OnChange = seHeightChange
      end
      object cbShapeStyle: TComboBox
        Left = 88
        Top = 150
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        Items.Strings = (
          'None'
          'Rectangle'
          'Ellipse'
          'Round Rect'
          'Diamond'
          'North Triangle'
          'South Triangle'
          'East Triangle'
          'West Triangle'
          'Hexagon')
        TabOrder = 2
        OnChange = seHeightChange
      end
      object pColor: TPanel
        Left = 88
        Top = 196
        Width = 19
        Height = 19
        BevelOuter = bvLowered
        TabOrder = 3
        OnClick = pColorClick
      end
      object pBkColor: TPanel
        Left = 88
        Top = 216
        Width = 19
        Height = 19
        BevelOuter = bvLowered
        TabOrder = 4
        OnClick = pColorClick
      end
      object cbTransparent: TCheckBox
        Left = 24
        Top = 238
        Width = 77
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Transparent'
        TabOrder = 5
        OnClick = seHeightChange
      end
      object seHeight: TEdit
        Left = 88
        Top = 4
        Width = 145
        Height = 21
        TabOrder = 6
        Text = 'seHeight'
        OnChange = seHeightChange
        OnKeyPress = seHeightKeyPress
      end
      object seWidth: TEdit
        Left = 88
        Top = 28
        Width = 145
        Height = 21
        TabOrder = 7
        Text = 'seWidth'
        OnChange = seHeightChange
        OnKeyPress = seHeightKeyPress
      end
      object seShapeWidth: TEdit
        Left = 88
        Top = 172
        Width = 145
        Height = 21
        TabOrder = 8
        Text = 'seShapeWidth'
        OnChange = seHeightChange
        OnKeyPress = seHeightKeyPress
      end
    end
    object tsImage: TTabSheet
      Caption = 'Image'
      object lwImage: TListView
        Left = 0
        Top = 0
        Width = 316
        Height = 234
        Align = alClient
        OnClick = seHeightChange
        Columns = <>
        ReadOnly = True
        HideSelection = False
        TabOrder = 0
      end
      object Panel3: TPanel
        Left = 0
        Top = -28
        Width = 0
        Height = 28
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        object Label5: TLabel
          Left = 2
          Top = 8
          Width = 64
          Height = 13
          Caption = 'Image Layout'
        end
        object cbImagePosition: TComboBox
          Left = 74
          Top = 4
          Width = 145
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          Items.Strings = (
            'Top-Left'
            'Top'
            'Top-Right'
            'Left'
            'Center'
            'Right'
            'Bottom-Left'
            'Bottom'
            'Bottom-Right')
          TabOrder = 0
          OnChange = seHeightChange
        end
        object btnClear: TButton
          Left = 240
          Top = 2
          Width = 75
          Height = 25
          Caption = 'Clear Image'
          TabOrder = 1
          OnClick = btnClearClick
        end
      end
    end
    object tsFrame: TTabSheet
      Caption = 'Frame'
      object GroupBox1: TGroupBox
        Left = 2
        Top = 4
        Width = 311
        Height = 63
        Caption = ' Edge Style '
        TabOrder = 0
        object cbRaisedOut: TCheckBox
          Left = 10
          Top = 20
          Width = 73
          Height = 12
          Caption = 'RaisedOut'
          TabOrder = 0
          OnClick = seHeightChange
        end
        object cbSunkenOut: TCheckBox
          Left = 10
          Top = 38
          Width = 73
          Height = 12
          Caption = 'SunkenOut'
          TabOrder = 1
          OnClick = seHeightChange
        end
        object cbRaisedIn: TCheckBox
          Left = 116
          Top = 20
          Width = 73
          Height = 12
          Caption = 'RaisedIn'
          TabOrder = 2
          OnClick = seHeightChange
        end
        object cbSunkenIn: TCheckBox
          Left = 116
          Top = 39
          Width = 73
          Height = 12
          Caption = 'SunkenIn'
          TabOrder = 3
          OnClick = seHeightChange
        end
      end
      object GroupBox2: TGroupBox
        Left = 2
        Top = 70
        Width = 309
        Height = 89
        Caption = ' Border Style '
        TabOrder = 1
        object cbLeft: TCheckBox
          Left = 116
          Top = 19
          Width = 41
          Height = 12
          Caption = 'Left'
          State = cbChecked
          TabOrder = 0
          OnClick = seHeightChange
        end
        object cbTop: TCheckBox
          Left = 116
          Top = 35
          Width = 41
          Height = 12
          Caption = 'Top'
          State = cbChecked
          TabOrder = 1
          OnClick = seHeightChange
        end
        object cbRight: TCheckBox
          Left = 116
          Top = 53
          Width = 49
          Height = 12
          Caption = 'Right'
          State = cbChecked
          TabOrder = 2
          OnClick = seHeightChange
        end
        object cbBottom: TCheckBox
          Left = 116
          Top = 69
          Width = 57
          Height = 12
          Caption = 'Bottom'
          State = cbChecked
          TabOrder = 3
          OnClick = seHeightChange
        end
        object cbDiag: TCheckBox
          Left = 228
          Top = 69
          Width = 60
          Height = 12
          Caption = 'Diagonal'
          TabOrder = 4
          OnClick = seHeightChange
        end
        object cbMiddle: TCheckBox
          Left = 228
          Top = 53
          Width = 57
          Height = 12
          Caption = 'Middle'
          TabOrder = 5
          OnClick = seHeightChange
        end
        object cbSoft: TCheckBox
          Left = 228
          Top = 19
          Width = 41
          Height = 12
          Caption = 'Soft'
          TabOrder = 6
          OnClick = seHeightChange
        end
        object cbAdjust: TCheckBox
          Left = 228
          Top = 35
          Width = 49
          Height = 12
          Caption = 'Adjust'
          TabOrder = 7
          OnClick = seHeightChange
        end
        object cbMono: TCheckBox
          Left = 10
          Top = 33
          Width = 49
          Height = 12
          Caption = 'Mono'
          TabOrder = 8
          OnClick = seHeightChange
        end
        object cbFlat: TCheckBox
          Left = 10
          Top = 17
          Width = 41
          Height = 12
          Caption = 'Flat'
          TabOrder = 9
          OnClick = seHeightChange
        end
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 290
    Width = 324
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object Panel2: TPanel
      Left = 164
      Top = 0
      Width = 160
      Height = 28
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOK: TButton
        Left = 4
        Top = 2
        Width = 75
        Height = 25
        Caption = '&OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object btnCancel: TButton
        Left = 82
        Top = 2
        Width = 75
        Height = 25
        Caption = '&Cancel'
        ModalResult = 2
        TabOrder = 1
      end
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 294
    Top = 102
  end
  object ColorDialog: TColorDialog
    Ctl3D = True
    Left = 294
    Top = 130
  end
end
