object cxSplitEditor: TcxSplitEditor
  Left = 224
  Top = 210
  ActiveControl = cxCbAhd
  BorderStyle = bsDialog
  ClientHeight = 383
  ClientWidth = 466
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object cxGroupBox1: TcxGroupBox
    Left = 8
    Top = 200
    Width = 449
    Height = 145
    Caption = ' Preview '
    TabOrder = 0
    object Panel1: TPanel
      Left = 8
      Top = 16
      Width = 426
      Height = 121
      BevelOuter = bvNone
      TabOrder = 0
      object cxListBox1: TcxListBox
        Left = 0
        Top = 0
        Width = 145
        Height = 121
        TabStop = False
        Align = alLeft
        ItemHeight = 13
        TabOrder = 0
      end
      object cxSplit: TcxSplitter
        Left = 145
        Top = 0
        Width = 8
        Height = 121
        AutoPosition = False
        AutoSnap = True
        Control = cxListBox1
      end
      object cxListBox2: TcxListBox
        Left = 153
        Top = 0
        Width = 273
        Height = 121
        TabStop = False
        Align = alClient
        ItemHeight = 13
        TabOrder = 2
      end
    end
  end
  object cxGroupBox2: TcxGroupBox
    Left = 8
    Top = 8
    Width = 153
    Height = 189
    Caption = ' Operation '
    TabOrder = 1
    object Label1: TLabel
      Left = 27
      Top = 119
      Width = 40
      Height = 13
      Caption = 'Min Size'
    end
    object Label2: TLabel
      Left = 28
      Top = 61
      Width = 88
      Height = 13
      Caption = 'Position after open'
    end
    object cxCbAhd: TcxCheckBox
      Left = 8
      Top = 16
      Width = 121
      Height = 21
      Caption = 'Allow HotZone Drag'
      TabOrder = 0
      OnClick = cxCbAhdClick
    end
    object cxCbAp: TcxCheckBox
      Left = 8
      Top = 40
      Width = 105
      Height = 21
      Caption = 'Auto Position'
      TabOrder = 1
      OnClick = cxCbApClick
    end
    object cxCbSnap: TcxCheckBox
      Left = 8
      Top = 99
      Width = 105
      Height = 21
      Caption = 'Auto Snap'
      TabOrder = 3
      OnClick = cxCbSnapClick
    end
    object cxCbRu: TcxCheckBox
      Left = 8
      Top = 161
      Width = 105
      Height = 21
      Caption = 'Resize Update'
      TabOrder = 5
      OnClick = cxCbRuClick
    end
    object cxSeMs: TcxSpinEdit
      Left = 27
      Top = 133
      Width = 89
      Height = 21
      Properties.MaxValue = 145.000000000000000000
      Properties.SpinButtons.ShowFastButtons = True
      Properties.OnChange = cxSeMsPropertiesChange
      TabOrder = 4
      Value = 30
    end
    object cxSePao: TcxSpinEdit
      Left = 28
      Top = 75
      Width = 89
      Height = 21
      Properties.MaxValue = 200.000000000000000000
      Properties.MinValue = 1.000000000000000000
      Properties.SpinButtons.ShowFastButtons = True
      Properties.OnChange = cxSePaoPropertiesChange
      TabOrder = 2
      Value = 200
    end
  end
  object cxGroupBox3: TcxGroupBox
    Left = 168
    Top = 8
    Width = 289
    Height = 189
    Caption = ' Hot Zone '
    TabOrder = 2
    object Label3: TLabel
      Left = 9
      Top = 120
      Width = 73
      Height = 13
      Caption = 'HotZone Width'
    end
    object cxRbHzNone: TcxRadioButton
      Left = 9
      Top = 40
      Width = 113
      Height = 17
      Caption = 'None'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = cxRbHzNoneClick
    end
    object cxRbHzMp8: TcxRadioButton
      Left = 9
      Top = 65
      Width = 96
      Height = 17
      Hint = 'MediaPlayer8'
      Caption = 'Media Player 8'
      TabOrder = 2
      OnClick = cxRbHzMp8Click
    end
    object cxRbHzMp9: TcxRadioButton
      Left = 106
      Top = 65
      Width = 113
      Height = 17
      Hint = 'MediaPlayer9'
      Caption = 'Media Player 9'
      TabOrder = 3
      OnClick = cxRbHzMp8Click
    end
    object cxRbHzSimple: TcxRadioButton
      Left = 106
      Top = 90
      Width = 113
      Height = 17
      Hint = 'Simple'
      Caption = 'Simple'
      TabOrder = 4
      OnClick = cxRbHzMp8Click
    end
    object cxRbHzXp: TcxRadioButton
      Left = 9
      Top = 90
      Width = 96
      Height = 17
      Hint = 'XPTaskBar'
      Caption = 'XP Task Bar'
      TabOrder = 5
      OnClick = cxRbHzMp8Click
    end
    object cxCbHzVisible: TcxCheckBox
      Left = 9
      Top = 16
      Width = 121
      Height = 21
      Caption = 'Visible'
      Enabled = False
      Properties.OnChange = cxCbHzVisiblePropertiesChange
      TabOrder = 0
    end
    object cxTbHzWidth: TcxTrackBar
      Left = 8
      Top = 136
      Width = 273
      Height = 49
      Position = 10
      Properties.Frequency = 5
      Properties.Min = 10
      Properties.Max = 100
      Properties.SelectionStart = 30
      Properties.SelectionEnd = 60
      Properties.SelectionColor = clGreen
      Properties.OnChange = cxTbHzWidthPropertiesChange
      TabOrder = 6
    end
  end
  object cxBtnOK: TcxButton
    Left = 304
    Top = 352
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 3
  end
  object cxBtnCancel: TcxButton
    Left = 384
    Top = 352
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object cxLookAndFeelController1: TcxLookAndFeelController
    Kind = lfFlat
    NativeStyle = True
    Left = 200
    Top = 344
  end
end
