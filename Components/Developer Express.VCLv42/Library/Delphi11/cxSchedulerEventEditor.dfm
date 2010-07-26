object cxSchedulerEventEditorForm: TcxSchedulerEventEditorForm
  Left = 313
  Top = 267
  AutoScroll = False
  ClientHeight = 376
  ClientWidth = 450
  Color = clBtnFace
  Constraints.MinHeight = 410
  Constraints.MinWidth = 458
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 338
    Width = 450
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 0
    object pnlThreeButtons: TPanel
      Left = 0
      Top = 0
      Width = 340
      Height = 38
      Align = alClient
      BevelOuter = bvNone
      FullRepaint = False
      ParentColor = True
      TabOrder = 0
      object btnOk: TcxButton
        Left = 15
        Top = 7
        Width = 95
        Height = 23
        Anchors = [akTop, akRight]
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object btnCancel: TcxButton
        Left = 125
        Top = 7
        Width = 95
        Height = 23
        Anchors = [akTop, akRight]
        Cancel = True
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 1
      end
      object btnDelete: TcxButton
        Left = 235
        Top = 7
        Width = 95
        Height = 23
        Anchors = [akTop, akRight]
        Caption = '&Delete'
        TabOrder = 2
        OnClick = btnDeleteClick
      end
    end
    object pnlRecurrence: TPanel
      Left = 340
      Top = 0
      Width = 110
      Height = 38
      Align = alRight
      BevelOuter = bvNone
      FullRepaint = False
      ParentColor = True
      TabOrder = 1
      object btnRecurrence: TcxButton
        Left = 5
        Top = 7
        Width = 95
        Height = 23
        Caption = '&Recurrence'
        TabOrder = 0
        OnClick = btnRecurrenceClick
      end
    end
  end
  object pnlInformation: TPanel
    Left = 0
    Top = 0
    Width = 450
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 7
    object Bevel6: TBevel
      Left = 11
      Top = 33
      Width = 429
      Height = 7
      Anchors = [akLeft, akTop, akRight]
      Shape = bsBottomLine
    end
    object btnFindTime: TcxButton
      Left = 320
      Top = 8
      Width = 120
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Find available time'
      TabOrder = 0
      OnClick = btnFindTimeClick
    end
    object cxGroupBox1: TcxGroupBox
      Left = 13
      Top = 8
      Alignment = alCenterCenter
      Anchors = [akLeft, akTop, akRight]
      ParentBackground = False
      ParentColor = False
      Style.Color = clInfoBk
      Style.TransparentBorder = False
      TabOrder = 1
      Height = 23
      Width = 298
      object lbInformation: TLabel
        Left = 4
        Top = 4
        Width = 290
        Height = 15
        AutoSize = False
        Caption = 'Conflicts with another event in your schedule.'
      end
    end
  end
  object pnlCaption: TPanel
    Left = 0
    Top = 41
    Width = 450
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 1
    object lbSubject: TLabel
      Left = 16
      Top = 13
      Width = 40
      Height = 13
      Caption = 'Subject:'
      FocusControl = teSubject
    end
    object lbLocation: TLabel
      Left = 16
      Top = 38
      Width = 44
      Height = 13
      Caption = 'Location:'
      FocusControl = teLocation
    end
    object lbLabel: TLabel
      Left = 239
      Top = 38
      Width = 29
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'La&bel:'
      FocusControl = icbLabel
    end
    object teSubject: TcxTextEdit
      Left = 72
      Top = 9
      Anchors = [akLeft, akTop, akRight]
      Properties.OnChange = OnChanged
      TabOrder = 0
      Width = 369
    end
    object teLocation: TcxTextEdit
      Left = 72
      Top = 34
      Anchors = [akLeft, akTop, akRight]
      Properties.OnChange = OnChanged
      TabOrder = 1
      Width = 145
    end
    object icbLabel: TcxImageComboBox
      Left = 272
      Top = 34
      Anchors = [akTop, akRight]
      Properties.Items = <>
      Properties.OnChange = OnChanged
      TabOrder = 2
      Width = 169
    end
  end
  object pnlTime: TPanel
    Left = 0
    Top = 106
    Width = 450
    Height = 67
    Align = alTop
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 2
    object Bevel4: TBevel
      Left = 11
      Top = 0
      Width = 429
      Height = 8
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
    end
    object lbStartTime: TLabel
      Left = 16
      Top = 15
      Width = 51
      Height = 13
      Caption = 'Start time:'
      FocusControl = deStart
    end
    object lbEndTime: TLabel
      Left = 16
      Top = 40
      Width = 45
      Height = 13
      Caption = 'End time:'
      FocusControl = deEnd
    end
    object deStart: TcxDateEdit
      Left = 96
      Top = 11
      Properties.DateButtons = [btnToday]
      Properties.InputKind = ikStandard
      Properties.OnChange = OnChanged
      Properties.OnEditValueChanged = StartDateChanged
      TabOrder = 0
      Width = 121
    end
    object teStart: TcxTimeEdit
      Left = 224
      Top = 11
      EditValue = 0.000000000000000000
      Properties.TimeFormat = tfHourMin
      Properties.OnChange = OnEventTimeChanged
      TabOrder = 1
      Width = 78
    end
    object deEnd: TcxDateEdit
      Left = 96
      Top = 36
      Properties.DateButtons = [btnToday]
      Properties.InputKind = ikStandard
      Properties.OnChange = OnChanged
      TabOrder = 2
      Width = 121
    end
    object teEnd: TcxTimeEdit
      Left = 224
      Top = 36
      EditValue = 0.000000000000000000
      Properties.TimeFormat = tfHourMin
      Properties.OnChange = OnEventTimeChanged
      TabOrder = 3
      Width = 78
    end
    object cbAllDayEvent: TcxCheckBox
      Left = 320
      Top = 12
      Caption = 'All day event'
      Properties.OnChange = cbAllDayEventPropertiesChange
      TabOrder = 4
      Width = 121
    end
  end
  object pnlRecurrenceInfo: TPanel
    Left = 0
    Top = 173
    Width = 450
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 3
    object Bevel7: TBevel
      Left = 11
      Top = 0
      Width = 429
      Height = 8
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
    end
    object lbRecurrence: TLabel
      Left = 16
      Top = 15
      Width = 59
      Height = 13
      Caption = 'Recurrence:'
    end
    object lbRecurrencePattern: TLabel
      Left = 88
      Top = 16
      Width = 353
      Height = 13
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'PatternInfo'
      WordWrap = True
    end
  end
  object pnlPlaceHolder: TPanel
    Left = 0
    Top = 256
    Width = 450
    Height = 43
    Align = alTop
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 5
    object pnlReminder: TPanel
      Left = 0
      Top = 4
      Width = 224
      Height = 39
      Align = alLeft
      BevelOuter = bvNone
      FullRepaint = False
      ParentColor = True
      TabOrder = 0
      object cbReminder: TcxCheckBox
        Left = 11
        Top = 9
        Caption = 'Reminder:'
        Properties.OnChange = OnChanged
        State = cbsChecked
        TabOrder = 0
        OnClick = cbReminderClick
        Width = 81
      end
      object cbReminderMinutesBeforeStart: TcxComboBox
        Left = 96
        Top = 8
        Properties.ImmediateDropDown = False
        Properties.ImmediatePost = True
        Properties.IncrementalSearch = False
        Properties.OnChange = OnChanged
        Properties.OnPopup = cbReminderMinutesBeforeStartPropertiesPopup
        Properties.OnValidate = cbReminderMinutesBeforeStartPropertiesValidate
        TabOrder = 1
        Width = 121
      end
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 450
      Height = 4
      Align = alTop
      BevelOuter = bvNone
      FullRepaint = False
      ParentColor = True
      TabOrder = 1
      object Bevel3: TBevel
        Left = 11
        Top = 0
        Width = 439
        Height = 4
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
    end
    object pnlShowTimeAs: TPanel
      Left = 224
      Top = 4
      Width = 281
      Height = 39
      Align = alLeft
      BevelOuter = bvNone
      FullRepaint = False
      ParentColor = True
      TabOrder = 2
      object lbShowTimeAs: TLabel
        Left = 16
        Top = 12
        Width = 67
        Height = 13
        Caption = 'Show time as:'
        FocusControl = icbShowTimeAs
      end
      object icbShowTimeAs: TcxImageComboBox
        Left = 96
        Top = 8
        Properties.Items = <>
        Properties.OnChange = OnEventTimeChanged
        TabOrder = 0
        Width = 121
      end
    end
  end
  object pnlMessage: TPanel
    Left = 0
    Top = 299
    Width = 450
    Height = 39
    Align = alClient
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 6
    object Bevel2: TBevel
      Left = 11
      Top = 0
      Width = 429
      Height = 9
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
    end
    object Bevel1: TBevel
      Left = 11
      Top = 31
      Width = 429
      Height = 7
      Anchors = [akLeft, akRight, akBottom]
      Shape = bsBottomLine
    end
    object meMessage: TcxMemo
      Left = 10
      Top = 12
      Anchors = [akLeft, akTop, akRight, akBottom]
      Properties.OnChange = OnChanged
      TabOrder = 0
      Height = 13
      Width = 431
    end
  end
  object pnlResource: TPanel
    Left = 0
    Top = 213
    Width = 450
    Height = 43
    Align = alTop
    BevelOuter = bvNone
    FullRepaint = False
    ParentColor = True
    TabOrder = 4
    object lbResource: TLabel
      Left = 16
      Top = 17
      Width = 62
      Height = 13
      Caption = 'Resource(s):'
    end
    object Bevel5: TBevel
      Left = 11
      Top = -4
      Width = 429
      Height = 7
      Anchors = [akLeft, akTop, akRight]
      Shape = bsBottomLine
    end
    object cbResources: TcxCheckComboBox
      Left = 96
      Top = 13
      Anchors = [akLeft, akTop, akRight]
      Properties.DropDownAutoWidth = False
      Properties.EditValueFormat = cvfIndices
      Properties.Items = <>
      Properties.OnChange = OnResourceIDChanged
      TabOrder = 0
      Width = 346
    end
  end
end
