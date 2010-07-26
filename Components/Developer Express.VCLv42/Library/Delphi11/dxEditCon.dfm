object FEditConnection: TFEditConnection
  Left = 389
  Top = 204
  BorderStyle = bsDialog
  Caption = 'Edit Connection'
  ClientHeight = 225
  ClientWidth = 326
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 2
    Top = 2
    Width = 21
    Height = 13
    Caption = 'Text'
  end
  object sbFont: TSpeedButton
    Left = 300
    Top = 2
    Width = 23
    Height = 23
    Hint = 'Text Font'
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
    Left = 4
    Top = 158
    Width = 24
    Height = 13
    Caption = 'Color'
  end
  object Label9: TLabel
    Left = 4
    Top = 178
    Width = 59
    Height = 13
    Caption = 'Arrows Color'
  end
  object MemoText: TMemo
    Left = 28
    Top = 0
    Width = 271
    Height = 57
    Lines.Strings = (
      'MemoText')
    TabOrder = 0
    OnChange = MemoTextChange
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 62
    Width = 162
    Height = 89
    Caption = ' Source '
    TabOrder = 1
    object Label2: TLabel
      Left = 6
      Top = 18
      Width = 53
      Height = 13
      Caption = 'Arrow Style'
    end
    object Label3: TLabel
      Left = 6
      Top = 40
      Width = 50
      Height = 13
      Caption = 'Arrow Size'
    end
    object Label4: TLabel
      Left = 6
      Top = 66
      Width = 59
      Height = 13
      Caption = 'Linked Point'
    end
    object cbSArrowStyle: TComboBox
      Left = 68
      Top = 14
      Width = 89
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Items.Strings = (
        'None'
        'Arrow'
        'Ellipse Arrow'
        'Rect Arrow')
      TabOrder = 0
      OnChange = MemoTextChange
    end
    object seSArrowSize: TEdit
      Left = 68
      Top = 36
      Width = 89
      Height = 21
      TabOrder = 1
      Text = 'seSArrowSize'
      OnChange = MemoTextChange
      OnKeyPress = seSArrowSizeKeyPress
    end
    object seSPoint: TEdit
      Left = 68
      Top = 60
      Width = 89
      Height = 21
      TabOrder = 2
      Text = 'seSPoint'
      OnChange = MemoTextChange
      OnKeyPress = seSPointKeyPress
    end
  end
  object GroupBox2: TGroupBox
    Left = 164
    Top = 62
    Width = 162
    Height = 89
    Caption = ' Destination '
    TabOrder = 2
    object Label5: TLabel
      Left = 6
      Top = 18
      Width = 53
      Height = 13
      Caption = 'Arrow Style'
    end
    object Label6: TLabel
      Left = 6
      Top = 40
      Width = 50
      Height = 13
      Caption = 'Arrow Size'
    end
    object Label7: TLabel
      Left = 6
      Top = 66
      Width = 59
      Height = 13
      Caption = 'Linked Point'
    end
    object cbDArrowStyle: TComboBox
      Left = 68
      Top = 14
      Width = 89
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Items.Strings = (
        'None'
        'Arrow'
        'Ellipse Arrow'
        'Rect Arrow')
      TabOrder = 0
      OnChange = MemoTextChange
    end
    object seDArrowSize: TEdit
      Left = 68
      Top = 36
      Width = 89
      Height = 21
      TabOrder = 1
      Text = 'seDArrowSize'
      OnChange = MemoTextChange
      OnKeyPress = seSArrowSizeKeyPress
    end
    object seDPoint: TEdit
      Left = 68
      Top = 60
      Width = 89
      Height = 21
      TabOrder = 2
      Text = 'seDPoint'
      OnChange = MemoTextChange
      OnKeyPress = seSPointKeyPress
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 197
    Width = 326
    Height = 28
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object btnOK: TButton
      Left = 172
      Top = 3
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 250
      Top = 3
      Width = 75
      Height = 25
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pColor: TPanel
    Left = 68
    Top = 154
    Width = 19
    Height = 19
    BevelOuter = bvLowered
    TabOrder = 4
    OnClick = pColorClick
  end
  object pBkColor: TPanel
    Left = 68
    Top = 174
    Width = 19
    Height = 19
    BevelOuter = bvLowered
    TabOrder = 5
    OnClick = pColorClick
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    MinFontSize = 0
    MaxFontSize = 0
    Left = 298
    Top = 24
  end
  object ColorDialog: TColorDialog
    Ctl3D = True
    Left = 298
    Top = 154
  end
end
