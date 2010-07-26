object cxSchedulerReminderForm: TcxSchedulerReminderForm
  Left = 288
  Top = 89
  ActiveControl = lvItems
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 294
  ClientWidth = 456
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pbImage: TPaintBox
    Left = 10
    Top = 10
    Width = 16
    Height = 16
    Visible = False
    OnPaint = DrawIcon
  end
  object lbEventCaption: TLabel
    Left = 32
    Top = 10
    Width = 409
    Height = 15
    AutoSize = False
  end
  object lbEventStartTime: TLabel
    Left = 32
    Top = 32
    Width = 3
    Height = 13
  end
  object lvItems: TcxListView
    Left = 9
    Top = 76
    Width = 437
    Height = 129
    ColumnClick = False
    Columns = <
      item
        Width = 290
      end
      item
        Width = 120
      end>
    HideSelection = False
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    Style.HotTrack = False
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvItemsDblClick
    OnKeyDown = lvItemsKeyDown
    OnSelectItem = lvItemsSelectItem
  end
  object btnDismissAll: TcxButton
    Left = 9
    Top = 212
    Width = 90
    Height = 23
    Caption = 'Dismiss &All'
    Enabled = False
    TabOrder = 1
    OnClick = ButtonClick
  end
  object btnOpenItem: TcxButton
    Tag = 1
    Left = 256
    Top = 212
    Width = 90
    Height = 23
    Caption = '&Open Item'
    Enabled = False
    TabOrder = 2
    OnClick = ButtonClick
  end
  object btnDismiss: TcxButton
    Tag = 2
    Left = 355
    Top = 212
    Width = 90
    Height = 23
    Caption = '&Dismiss'
    Enabled = False
    TabOrder = 3
    OnClick = ButtonClick
  end
  object cbSnoozeTime: TcxComboBox
    Left = 9
    Top = 263
    Enabled = False
    Properties.DropDownListStyle = lsFixedList
    TabOrder = 4
    Width = 338
  end
  object btnSnooze: TcxButton
    Tag = 3
    Left = 355
    Top = 262
    Width = 90
    Height = 23
    Caption = '&Snooze'
    Default = True
    Enabled = False
    TabOrder = 5
    OnClick = ButtonClick
  end
  object tmUpdate: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = tmUpdateTimer
  end
end
