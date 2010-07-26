object cxfmSchedulerReportLinkDesignWindow: TcxfmSchedulerReportLinkDesignWindow
  Left = 349
  Top = 267
  BorderStyle = bsDialog
  Caption = 'cxfmSchedulerReportLinkDesignWindow'
  ClientHeight = 487
  ClientWidth = 618
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 4
    Top = 5
    Width = 610
    Height = 445
    ActivePage = tshPrintStyles
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    OnChange = PageControl1Change
    object tshPrintRange: TTabSheet
      Caption = 'Print Range'
      ImageIndex = 3
      object lblPrintRangeStart: TLabel
        Left = 17
        Top = 22
        Width = 28
        Height = 13
        Caption = '&Start:'
      end
      object lblPrintRangeEnd: TLabel
        Left = 18
        Top = 54
        Width = 22
        Height = 13
        Caption = '&End:'
      end
      object lblPrintRangesMiscellaneous: TLabel
        Left = 5
        Top = 91
        Width = 65
        Height = 13
        Caption = 'Miscellaneous'
        Visible = False
      end
      object Bevel1: TBevel
        Left = 80
        Top = 95
        Width = 231
        Height = 4
        Shape = bsBottomLine
        Visible = False
      end
      object dePrintRangeStart: TcxDateEdit
        Left = 70
        Top = 18
        EditValue = 38187d
        Properties.OnEditValueChanged = dePrintRangeStartEditValueChanged
        TabOrder = 0
        Width = 235
      end
      object dePrintRangeEnd: TcxDateEdit
        Left = 70
        Top = 50
        EditValue = 38187d
        Properties.OnEditValueChanged = dePrintRangeEndEditValueChanged
        TabOrder = 1
        Width = 235
      end
      object chbxHideDetailsOfPrivateAppointments: TcxCheckBox
        Left = 66
        Top = 113
        Caption = 'Hide Details of Private Appointments'
        TabOrder = 2
        Visible = False
        Width = 236
      end
    end
    object tshPrintStyles: TTabSheet
      Caption = 'Print Styles'
      object lblPrintStylesOptions: TLabel
        Left = 5
        Top = 48
        Width = 37
        Height = 13
        Caption = 'Options'
      end
      object bvlPrintStyleOptions: TBevel
        Left = 50
        Top = 52
        Width = 258
        Height = 4
        Shape = bsBottomLine
      end
      object lblPreviewWindow: TStaticText
        Left = 324
        Top = 0
        Width = 42
        Height = 17
        Caption = 'Preview'
        TabOrder = 0
      end
      object cbxPrintStyles: TcxImageComboBox
        Left = 6
        Top = 7
        Properties.Alignment.Vert = taVCenter
        Properties.Items = <>
        TabOrder = 1
        OnClick = cbxPrintStylesClick
        Width = 303
      end
      object pcPrintStyleOptions: TPageControl
        Left = 4
        Top = 64
        Width = 314
        Height = 348
        ActivePage = tshTimeLine
        Style = tsButtons
        TabOrder = 2
        TabStop = False
        object tshDaily: TTabSheet
          Caption = 'Daily'
          TabVisible = False
          object lblPrintStyleDailyLayout: TLabel
            Left = 14
            Top = 4
            Width = 37
            Height = 13
            Caption = 'La&yout:'
            FocusControl = cbxPrintStyleDailyLayout
          end
          object lblPrintStyleDailyInclude: TLabel
            Left = 14
            Top = 64
            Width = 39
            Height = 13
            Caption = 'Include:'
          end
          object lblPrintStyleDailyPrintFrom: TLabel
            Left = 14
            Top = 136
            Width = 53
            Height = 13
            Caption = 'Print &From:'
            FocusControl = tePrintStyleDailyPrintFrom
          end
          object lblPrintStyleDailyPrintTo: TLabel
            Left = 14
            Top = 165
            Width = 41
            Height = 13
            Caption = 'Print &To:'
            FocusControl = tePrintStyleDailyPrintTo
          end
          object lblPrintStyleDailyResourceCountPerPage: TLabel
            Left = 14
            Top = 34
            Width = 82
            Height = 13
            Caption = 'Resources/Page:'
            FocusControl = sePrintStyleDailyResourceCountPerPage
          end
          object Bevel2: TBevel
            Left = 32
            Top = 194
            Width = 274
            Height = 4
            Shape = bsBottomLine
          end
          object lbViewDaily: TLabel
            Left = 1
            Top = 190
            Width = 22
            Height = 13
            Caption = 'View'
          end
          object Bevel7: TBevel
            Left = 48
            Top = 237
            Width = 258
            Height = 4
            Shape = bsBottomLine
          end
          object lbImagesDaily: TLabel
            Left = 3
            Top = 232
            Width = 38
            Height = 13
            Caption = 'Images '
          end
          object cbxPrintStyleDailyLayout: TcxComboBox
            Left = 115
            Top = -1
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              '1 page/day'
              '2 pages/day')
            TabOrder = 0
            OnClick = cbxPrintStyleDailyLayoutClick
            Height = 23
            Width = 186
          end
          object chbxPrintStyleDailyTaskPad: TcxCheckBox
            Left = 111
            Top = 61
            Caption = 'Task&Pad'
            TabOrder = 2
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleDailyNotesAreaBlank: TcxCheckBox
            Tag = 1
            Left = 111
            Top = 82
            Caption = 'Notes Area (&Blank)'
            TabOrder = 3
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleDailyNotesAreaLined: TcxCheckBox
            Tag = 2
            Left = 111
            Top = 103
            Caption = 'Notes Area (&Lined)'
            TabOrder = 4
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object tePrintStyleDailyPrintFrom: TcxTimeEdit
            Left = 114
            Top = 132
            EditValue = 0.000000000000000000
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 5
            Width = 100
          end
          object tePrintStyleDailyPrintTo: TcxTimeEdit
            Tag = 1
            Left = 114
            Top = 161
            EditValue = 0.000000000000000000
            Properties.ImmediatePost = True
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 6
            Width = 100
          end
          object sePrintStyleDailyResourceCountPerPage: TcxSpinEdit
            Left = 115
            Top = 30
            Properties.OnChange = sePrintStyleResourceCountPerPagePropertiesChanged
            Properties.OnEditValueChanged = sePrintStyleResourceCountPerPagePropertiesEditValueChanged
            TabOrder = 1
            Width = 100
          end
          object chbxPrintStyleDailyShowResourceImages: TcxCheckBox
            Left = 15
            Top = 206
            Caption = 'Show resource images'
            TabOrder = 7
            OnClick = chbxPrintStyleShowResourceImagesClick
            Width = 306
          end
          object chbxPrintStyleDailyShowEventImages: TcxCheckBox
            Left = 15
            Top = 251
            Caption = 'Show event images'
            TabOrder = 8
            OnClick = chbxPrintStyleShowEventImagesClick
            Width = 306
          end
        end
        object tshWeekly: TTabSheet
          Caption = 'Weekly'
          ImageIndex = 1
          TabVisible = False
          object lblPrintStyleWeeklyPrintTo: TLabel
            Left = 14
            Top = 218
            Width = 41
            Height = 13
            Caption = 'Print &To:'
            FocusControl = tePrintStyleWeeklyPrintTo
          end
          object lblPrintStyleWeeklyPrintFrom: TLabel
            Left = 14
            Top = 189
            Width = 53
            Height = 13
            Caption = 'Print &From:'
            FocusControl = tePrintStyleWeeklyPrintFrom
          end
          object lblPrintStyleWeeklyInclude: TLabel
            Left = 14
            Top = 119
            Width = 39
            Height = 13
            Caption = 'Include:'
          end
          object lblPrintStyleWeeklyLayout: TLabel
            Left = 14
            Top = 33
            Width = 37
            Height = 13
            Caption = 'La&yout:'
            FocusControl = cbxPrintStyleWeeklyLayout
          end
          object lblPrintStyleWeeklyArrange: TLabel
            Left = 14
            Top = 4
            Width = 43
            Height = 13
            Caption = '&Arrange:'
            FocusControl = cbxPrintStyleWeeklyArrange
          end
          object lblPrintStyleWeeklyResourceCountPerPage: TLabel
            Left = 14
            Top = 94
            Width = 82
            Height = 13
            Caption = 'Resources/Page:'
            FocusControl = sePrintStyleWeeklyResourceCountPerPage
          end
          object lblPrintStyleWeeklyDaysLayout: TLabel
            Left = 14
            Top = 63
            Width = 61
            Height = 13
            Caption = '&Days layout:'
            FocusControl = cbxPrintStyleWeeklyDaysLayout
          end
          object Bevel3: TBevel
            Left = 32
            Top = 245
            Width = 274
            Height = 4
            Shape = bsBottomLine
          end
          object Label5: TLabel
            Left = 1
            Top = 241
            Width = 22
            Height = 13
            Caption = 'View'
          end
          object Bevel8: TBevel
            Left = 48
            Top = 287
            Width = 258
            Height = 4
            Shape = bsBottomLine
          end
          object Label6: TLabel
            Left = 3
            Top = 282
            Width = 38
            Height = 13
            Caption = 'Images '
          end
          object tePrintStyleWeeklyPrintTo: TcxTimeEdit
            Tag = 1
            Left = 114
            Top = 213
            EditValue = 0.000000000000000000
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 8
            Width = 100
          end
          object tePrintStyleWeeklyPrintFrom: TcxTimeEdit
            Left = 114
            Top = 184
            EditValue = 0.000000000000000000
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 7
            Width = 100
          end
          object chbxPrintStyleWeeklyNotesAreaLined: TcxCheckBox
            Tag = 2
            Left = 111
            Top = 158
            Caption = 'Notes Area (&Lined)'
            TabOrder = 6
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleWeeklyNotesAreaBlank: TcxCheckBox
            Tag = 1
            Left = 111
            Top = 137
            Caption = 'Notes Area (&Blank)'
            TabOrder = 5
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object cbxPrintStyleWeeklyArrange: TcxComboBox
            Left = 115
            Top = -1
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              'Top to Bottom'
              'Left to Right')
            TabOrder = 0
            OnClick = cbxPrintStyleWeeklyArrangeClick
            Height = 23
            Width = 186
          end
          object cbxPrintStyleWeeklyLayout: TcxComboBox
            Left = 115
            Top = 29
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              '1 page/day'
              '2 pages/day')
            TabOrder = 1
            OnClick = cbxPrintStyleWeeklyLayoutClick
            Height = 23
            Width = 186
          end
          object chbxPrintStyleWeeklyTaskPad: TcxCheckBox
            Left = 111
            Top = 116
            Caption = 'TaskPad'
            TabOrder = 4
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleWeeklyDontPrintWeekends: TcxCheckBox
            Left = 15
            Top = 257
            Caption = 'Don'#39't Print &Weekends'
            TabOrder = 9
            OnClick = chbxPrintStyleWeeklyDontPrintWeekendsClick
            Width = 285
          end
          object sePrintStyleWeeklyResourceCountPerPage: TcxSpinEdit
            Tag = 1
            Left = 115
            Top = 90
            Properties.OnChange = sePrintStyleResourceCountPerPagePropertiesChanged
            Properties.OnEditValueChanged = sePrintStyleResourceCountPerPagePropertiesEditValueChanged
            TabOrder = 3
            Width = 100
          end
          object cbxPrintStyleWeeklyDaysLayout: TcxComboBox
            Left = 115
            Top = 59
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              'Two columns'
              'One column')
            TabOrder = 2
            OnClick = cbxPrintStyleWeeklyDaysLayoutClick
            Height = 23
            Width = 186
          end
          object chbxPrintStyleWeeklyShowEventImages: TcxCheckBox
            Left = 15
            Top = 320
            Caption = 'Show Event Images'
            TabOrder = 11
            OnClick = chbxPrintStyleShowEventImagesClick
            Width = 306
          end
          object chbxPrintStyleWeeklyShowResourceImages: TcxCheckBox
            Left = 15
            Top = 299
            Caption = 'Show Resource Images'
            TabOrder = 10
            OnClick = chbxPrintStyleShowResourceImagesClick
            Width = 306
          end
        end
        object tshMonthly: TTabSheet
          Caption = 'Monthly'
          ImageIndex = 2
          TabVisible = False
          object lblPrintStyleMonthlyLayout: TLabel
            Left = 14
            Top = 4
            Width = 37
            Height = 13
            Caption = 'La&yout:'
            FocusControl = cbxPrintStyleMonthlyLayout
          end
          object lblPrintStyleMonthlyInclude: TLabel
            Left = 14
            Top = 62
            Width = 39
            Height = 13
            Caption = 'Include:'
          end
          object lblPrintStyleMonthlyResourceCountPerPage: TLabel
            Left = 14
            Top = 34
            Width = 82
            Height = 13
            Caption = 'Resources/Page:'
            FocusControl = sePrintStyleMonthlyResourceCountPerPage
          end
          object Bevel9: TBevel
            Left = 32
            Top = 129
            Width = 274
            Height = 4
            Shape = bsBottomLine
          end
          object Label7: TLabel
            Left = 1
            Top = 125
            Width = 22
            Height = 13
            Caption = 'View'
          end
          object Bevel10: TBevel
            Left = 48
            Top = 191
            Width = 258
            Height = 4
            Shape = bsBottomLine
          end
          object Label8: TLabel
            Left = 3
            Top = 186
            Width = 38
            Height = 13
            Caption = 'Images '
          end
          object cbxPrintStyleMonthlyLayout: TcxComboBox
            Left = 115
            Top = -1
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              '1 page/month'
              '2 pages/month')
            TabOrder = 0
            OnClick = cbxPrintStyleMonthlyLayoutClick
            Height = 23
            Width = 186
          end
          object chbxPrintStyleMonthlyTaskPad: TcxCheckBox
            Left = 111
            Top = 59
            Caption = 'Task&Pad'
            TabOrder = 2
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleMonthlyNotesAreaBlank: TcxCheckBox
            Tag = 1
            Left = 111
            Top = 80
            Caption = 'Notes Area (&Blank)'
            TabOrder = 3
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleMonthlyNotesAreaLined: TcxCheckBox
            Tag = 2
            Left = 111
            Top = 101
            Caption = 'Notes Area (&Lined)'
            TabOrder = 4
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleMonthlyDontPrintWeekends: TcxCheckBox
            Left = 15
            Top = 141
            Caption = 'Don'#39't Print &Weekends'
            TabOrder = 5
            OnClick = chbxPrintStyleDontPrintWeekEndsClick
            Width = 285
          end
          object chbxPrintStyleMonthlyPrintExactlyOneMonthPerPage: TcxCheckBox
            Left = 15
            Top = 162
            Caption = 'Print Exactly One Month Per Page'
            TabOrder = 6
            OnClick = chbxPrintStyleMonthlyPrintExactlyOneMonthPerPageClick
            Width = 285
          end
          object sePrintStyleMonthlyResourceCountPerPage: TcxSpinEdit
            Tag = 2
            Left = 115
            Top = 29
            Properties.OnChange = sePrintStyleResourceCountPerPagePropertiesChanged
            Properties.OnEditValueChanged = sePrintStyleResourceCountPerPagePropertiesEditValueChanged
            TabOrder = 1
            Width = 100
          end
          object chbxPrintStyleMonthlyShowEventImages: TcxCheckBox
            Left = 15
            Top = 224
            Caption = 'Show Event Images'
            TabOrder = 7
            OnClick = chbxPrintStyleShowEventImagesClick
            Width = 306
          end
          object chbxPrintStyleMonthlyShowResourceImages: TcxCheckBox
            Left = 15
            Top = 203
            Caption = 'Show Resource Images'
            TabOrder = 8
            OnClick = chbxPrintStyleShowResourceImagesClick
            Width = 306
          end
        end
        object tshTrifold: TTabSheet
          Caption = 'Tri-fold'
          ImageIndex = 3
          TabVisible = False
          object lblPrintStyleTrifoldSectionLeft: TLabel
            Left = 14
            Top = 4
            Width = 61
            Height = 13
            Caption = '&Left Section:'
            FocusControl = cbxPrintStyleTrifoldSectionLeft
          end
          object lblPrintStyleTrifoldSectionMiddle: TLabel
            Left = 14
            Top = 38
            Width = 72
            Height = 13
            Caption = '&Middle Section:'
            FocusControl = cbxPrintStyleTrifoldSectionMiddle
          end
          object lblPrintStyleTrifoldSectionRight: TLabel
            Left = 14
            Top = 71
            Width = 67
            Height = 13
            Caption = '&Right Section:'
            FocusControl = cbxPrintStyleTrifoldSectionRight
          end
          object cbxPrintStyleTrifoldSectionLeft: TcxComboBox
            Left = 100
            Top = -1
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            TabOrder = 0
            OnClick = cbxPrintStyleTrifoldSectionModeClick
            Height = 23
            Width = 201
          end
          object cbxPrintStyleTrifoldSectionMiddle: TcxComboBox
            Tag = 1
            Left = 100
            Top = 33
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            TabOrder = 1
            OnClick = cbxPrintStyleTrifoldSectionModeClick
            Height = 23
            Width = 201
          end
          object cbxPrintStyleTrifoldSectionRight: TcxComboBox
            Tag = 2
            Left = 100
            Top = 66
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            TabOrder = 2
            OnClick = cbxPrintStyleTrifoldSectionModeClick
            Height = 23
            Width = 201
          end
        end
        object tshDetails: TTabSheet
          Caption = 'Details'
          ImageIndex = 4
          TabVisible = False
          object chbxPrintStyleDetailsUsePagination: TcxCheckBox
            Left = 14
            Top = 0
            Caption = 'Start a New Page Each:'
            TabOrder = 0
            OnClick = chbxPrintStyleDetailsUsePaginationClick
            Width = 187
          end
          object cbxPrintStyleDetailsPagination: TcxComboBox
            Left = 203
            Top = -1
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              'Day'
              'Week'
              'Month')
            TabOrder = 1
            OnClick = cbxPrintStyleDetailsPaginationClick
            Height = 23
            Width = 98
          end
        end
        object tshMemo: TTabSheet
          Caption = 'Memo'
          ImageIndex = 5
          TabVisible = False
          object chbxPrintStyleMemoStartEachItemOnNewPage: TcxCheckBox
            Left = 14
            Top = 0
            Caption = 'Start Each Item On New Page'
            TabOrder = 0
            OnClick = chbxPrintStyleMemoStartEachItemOnNewPageClick
            Width = 187
          end
          object chbxPrintStyleMemoPrintOnlySelectedEvents: TcxCheckBox
            Left = 14
            Top = 22
            Caption = 'Print Only Selected Events'
            State = cbsChecked
            TabOrder = 1
            OnClick = chbxPrintStyleMemoPrintOnlySelectedEventsClick
            Width = 187
          end
        end
        object tshYearly: TTabSheet
          Caption = 'Yearly'
          ImageIndex = 6
          TabVisible = False
          object lblPrintStyleYearlyMonthPerPage: TLabel
            Left = 14
            Top = 38
            Width = 67
            Height = 13
            Caption = '&Months/Page:'
            FocusControl = cbxPrintStyleYearlyMonthPerPage
          end
          object lblPrintStyleYearlyResourceCountPerPage: TLabel
            Left = 14
            Top = 72
            Width = 82
            Height = 13
            Caption = 'Resources/Page:'
            FocusControl = sePrintStyleYearlyResourceCountPerPage
            Visible = False
          end
          object lblPrintStyleYearlyInclude: TLabel
            Left = 14
            Top = 102
            Width = 39
            Height = 13
            Caption = 'Include:'
          end
          object lblPrintStyleYearlyLayout: TLabel
            Left = 14
            Top = 4
            Width = 37
            Height = 13
            Caption = 'La&yout:'
            FocusControl = cbxPrintStyleYearlyLayout
          end
          object Bevel4: TBevel
            Left = 32
            Top = 171
            Width = 274
            Height = 4
            Shape = bsBottomLine
          end
          object Label9: TLabel
            Left = 1
            Top = 167
            Width = 22
            Height = 13
            Caption = 'View'
          end
          object Bevel5: TBevel
            Left = 48
            Top = 216
            Width = 258
            Height = 4
            Shape = bsBottomLine
          end
          object Label10: TLabel
            Left = 3
            Top = 211
            Width = 38
            Height = 13
            Caption = 'Images '
          end
          object cbxPrintStyleYearlyMonthPerPage: TcxComboBox
            Left = 115
            Top = 33
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              '1 page/year'
              '2 pages/year'
              '3 pages/year'
              '4 pages/year'
              '6 pages/year'
              '12 pages/year')
            TabOrder = 1
            Text = '12 pages/year'
            OnClick = cbxPrintStyleYearlyMonthPagesPerYearClick
            Height = 23
            Width = 186
          end
          object sePrintStyleYearlyResourceCountPerPage: TcxSpinEdit
            Tag = 3
            Left = 115
            Top = 68
            Properties.OnChange = sePrintStyleResourceCountPerPagePropertiesChanged
            Properties.OnEditValueChanged = sePrintStyleResourceCountPerPagePropertiesEditValueChanged
            TabOrder = 2
            Visible = False
            Width = 100
          end
          object chbxPrintStyleYearlyTaskPad: TcxCheckBox
            Left = 111
            Top = 99
            Caption = 'Task&Pad'
            TabOrder = 3
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleYearlyNotesAreaBlank: TcxCheckBox
            Tag = 1
            Left = 111
            Top = 120
            Caption = 'Notes Area (&Blank)'
            TabOrder = 4
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleYearlyNotesAreaLined: TcxCheckBox
            Tag = 2
            Left = 111
            Top = 141
            Caption = 'Notes Area (&Lined)'
            TabOrder = 5
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object cbxPrintStyleYearlyLayout: TcxComboBox
            Left = 115
            Top = -1
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              '1 page/month'
              '2 pages/month')
            TabOrder = 0
            Text = '1 page/month'
            OnClick = cbxPrintStyleYearlyLayoutClick
            Height = 23
            Width = 186
          end
          object chbxPrimaryPageHeadersOnly: TcxCheckBox
            Left = 15
            Top = 184
            Caption = 'Primary Page Headers Only'
            TabOrder = 6
            OnClick = chbxPrimaryPageHeadersOnlyClick
            Width = 153
          end
          object chbxPrintStyleYearlyShowEventImages: TcxCheckBox
            Left = 15
            Top = 230
            Caption = 'Show Event Images'
            TabOrder = 7
            OnClick = chbxPrintStyleShowEventImagesClick
            Width = 306
          end
        end
        object tshTimeLine: TTabSheet
          Caption = 'TimeLine'
          ImageIndex = 7
          TabVisible = False
          object lblPrintStyleTimeLineResourceCountPerPage: TLabel
            Left = 14
            Top = 3
            Width = 82
            Height = 13
            Caption = 'Resources/Page:'
            FocusControl = sePrintStyleTimeLineResourceCountPerPage
          end
          object lblPrintStyleTimeLineInclude: TLabel
            Left = 14
            Top = 33
            Width = 39
            Height = 13
            Caption = 'Include:'
          end
          object lblPrintStyleTimeLinePrintFrom: TLabel
            Left = 14
            Top = 106
            Width = 53
            Height = 13
            Caption = 'Print &From:'
            FocusControl = tePrintStyleTimeLinePrintFrom
          end
          object lblPrintStyleTimeLinePrintTo: TLabel
            Left = 14
            Top = 135
            Width = 41
            Height = 13
            Caption = 'Print &To:'
            FocusControl = tePrintStyleTimeLinePrintTo
          end
          object Bevel6: TBevel
            Left = 32
            Top = 165
            Width = 274
            Height = 4
            Shape = bsBottomLine
          end
          object bvlTimeLineImages: TBevel
            Left = 48
            Top = 274
            Width = 258
            Height = 4
            Shape = bsBottomLine
          end
          object Label2: TLabel
            Left = 1
            Top = 161
            Width = 22
            Height = 13
            Caption = 'View'
          end
          object lbTimeLineImages: TLabel
            Left = 3
            Top = 269
            Width = 38
            Height = 13
            Caption = 'Images '
          end
          object sePrintStyleTimeLineResourceCountPerPage: TcxSpinEdit
            Tag = 4
            Left = 115
            Top = -1
            Properties.OnChange = sePrintStyleResourceCountPerPagePropertiesChanged
            Properties.OnEditValueChanged = sePrintStyleResourceCountPerPagePropertiesEditValueChanged
            TabOrder = 0
            Width = 100
          end
          object chbxPrintStyleTimeLineTaskPad: TcxCheckBox
            Left = 111
            Top = 30
            Caption = 'Task&Pad'
            TabOrder = 1
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleTimeLineNotesAreaBlank: TcxCheckBox
            Tag = 1
            Left = 111
            Top = 51
            Caption = 'Notes Area (&Blank)'
            TabOrder = 2
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object chbxPrintStyleTimeLineNotesAreaLined: TcxCheckBox
            Tag = 2
            Left = 111
            Top = 72
            Caption = 'Notes Area (&Lined)'
            TabOrder = 3
            OnClick = chbxPrintStyleOptionsViewClick
            Width = 190
          end
          object tePrintStyleTimeLinePrintFrom: TcxTimeEdit
            Left = 114
            Top = 101
            EditValue = 0.000000000000000000
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 4
            Width = 100
          end
          object tePrintStyleTimeLinePrintTo: TcxTimeEdit
            Tag = 1
            Left = 114
            Top = 130
            EditValue = 0.000000000000000000
            Properties.ImmediatePost = True
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 5
            Width = 100
          end
          object chbxPrintStyleTimeLineShowResourceImages: TcxCheckBox
            Left = 15
            Top = 288
            Caption = 'Show Resource Images'
            TabOrder = 10
            OnClick = chbxPrintStyleShowResourceImagesClick
            Width = 306
          end
          object chbxPrintStyleTimeLineShowEventImages: TcxCheckBox
            Left = 15
            Top = 309
            Caption = 'Show Event Images'
            TabOrder = 11
            OnClick = chbxPrintStyleShowEventImagesClick
            Width = 306
          end
          object chbxPrintStyleTimeLinePrimaryPageHeadersOnly: TcxCheckBox
            Left = 15
            Top = 201
            Caption = 'Primary Page Headers Only'
            TabOrder = 7
            OnClick = chbxPrimaryPageHeadersOnlyClick
            Width = 170
          end
          object chbxPrintStyleTimeLinePrimaryPageScalesOnly: TcxCheckBox
            Left = 15
            Top = 180
            Caption = 'Primary Page Scales Only'
            TabOrder = 6
            OnClick = chbxPrimaryPageScalesOnlyClick
            Width = 162
          end
          object chbxPrintStyleTimeLineDontPrintWeekends: TcxCheckBox
            Left = 15
            Top = 222
            Caption = 'Don'#39't Print &Weekends'
            TabOrder = 8
            OnClick = chbxPrintStyleDontPrintWeekEndsClick
            Width = 194
          end
          object chbxPrintStyleTimeLineWorkTimeOnly: TcxCheckBox
            Left = 15
            Top = 243
            Caption = 'W&ork Time Only'
            TabOrder = 9
            OnClick = chbxPrintStyleWorkTimeOnlyClick
            Width = 194
          end
        end
      end
      object pnlPrintStylesPreview: TPanel
        Left = 323
        Top = 17
        Width = 275
        Height = 356
        BevelOuter = bvLowered
        Color = clWindow
        TabOrder = 3
        object pbxPrintStylesPreview: TPaintBox
          Left = 1
          Top = 1
          Width = 273
          Height = 354
          Align = alClient
          OnPaint = pbxPrintStylesPreviewPaint
        end
      end
    end
    object tshFormatting: TTabSheet
      Caption = 'Formatting'
      ImageIndex = 2
      object bvlLookAndFeel: TBevel
        Left = 85
        Top = 13
        Width = 226
        Height = 4
        Shape = bsBottomLine
      end
      object lblLookAndFeel: TLabel
        Left = 5
        Top = 8
        Width = 66
        Height = 13
        Caption = 'Look and Feel'
      end
      object imgLookAndFeel: TImage
        Left = 8
        Top = 32
        Width = 64
        Height = 32
        Picture.Data = {
          07544269746D617076040000424D760400000000000076000000280000004000
          0000200000000100040000000000000400000000000000000000100000000000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00DD777777777777777777777777DDDDDDDDDDDDDD77777777777777777777
          7777D0000000000000000000000007DDDDDDDDDDDDD000000000000000000000
          0007D0FFFFFFFFFF7FFFFFFFFFFF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0888888888877777777777707DDDDDDDDDDDDD088888888887777777777
          7707D0FFFFFFFFFF78888877787807DDDDDDDDDDDDD0FFFFFFFFFF7888887778
          7807D0FFFFFFFFFF7FFFFFFFFFFF07DDDDDDDDDDDDD0FFFFFFFFFF7888888888
          8807D0888888888877777777777707DDDDDDDDDDDDD088888888887777777777
          7707D0FFFFFFFFFF7FFFFFFFFFFF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0FFFFFFFFFF7FFFFFFFFFFF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0777777777777777777777707DDDCDDDDCDDDD077777777777777777777
          7707D0888877787878888877787807DDDCCCCDCCDDD088887778787888887778
          7807D0FFFFFFFFFF7FFFFFFFFFFF07DDDCCCCCCCCDD088888888887888888888
          8807D0777777777777777777777707DDDCCCCDCCDDD077777777777777777777
          7707D0FFFFFFFFFF7FFFFFFFFFFF07DDDCDDDDCDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0FFFFFFFFFF7FFFFFFFFFFF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0888888888878888888888807DDDDDDDDDDDDD088888888887888888888
          8807D0FFFFFFFFFF7FFFFFFFFFFF07DDDCDDDDCDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0FFFFFFFFFF7FFFFFFFFFFF07DDDCCCCDCCDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0777777777777777777777707DDDCCCCCCCCDD077777777777777777777
          7707D0888877787878888877787807DDDCCCCDCCDDD088887778787888887778
          7807D0FFFFFFFFFF7FFFFFFFFFFF07DDDCDDDDCDDDD088888888887888888888
          8807D0777777777777777777777707DDDDDDDDDDDDD077777777777777777777
          7707D0FFFFFFFFFF7FFFFFFFFFFF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0FFFFFFFFFF7FFFFFFFFFFF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0888888888878888888888807DDDDDDDDDDDDD088888888887888888888
          8807D0FFFFFFFFFF7FFFFFFFFFFF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0FFFFFFFFFF7FFFFFFFFFFF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0777777777777777777777707DDDDDDDDDDDDD077777777777777777777
          7707D0888877787878888877787807DDDDDDDDDDDDD088887778787888887778
          7807D0FFFFFFFFFF7FFFFFFFFFFF0DDDDDDDDDDDDDD088888888887888888888
          8807D000000000000000000000000DDDDDDDDDDDDDD000000000000000000000
          000DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
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
        Left = 75
        Top = 82
        Width = 236
        Height = 4
        Shape = bsBottomLine
      end
      object imgRefinements: TImage
        Left = 8
        Top = 100
        Width = 64
        Height = 32
        Picture.Data = {
          07544269746D617076040000424D760400000000000076000000280000004000
          0000200000000100040000000000000400000000000000000000100000000000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00DD777777777777777777777777DDDDDDDDDDDDDD77777777777777777777
          7777D0000000000000000000000007DDDDDDDDDDDDD000000000000000000000
          0007D0FAFAFAFAFA7AFAFAFAFAFA07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0888888888877777777777707DDDDDDDDDDDDD088888888887777777777
          7707D0FAFAFAFAFA788888777CC807DDDDDDDDDDDDD0FFFFFFFFFF7888887778
          7807D0AFAFAFAFAF78888888888807DDDDDDDDDDDDD0FFFFFFFFFF7888888888
          8807D0888888888877777777777707DDDDDDDDDDDDD088888888887777777777
          7707D0AFAFAFAFAF7FAFAFAFAFAF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0FAFAFAFAFA7AFAFAFAFAFA07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0777777777777777777777707DDDCDDDDCDDDD077777777777777777777
          7707D08888777CC8788888777CC807DDDCCCCDCCDDD088887778787888887778
          7807D0888888888878888888888807DDDCCCCCCCCDD088888888887888888888
          8807D0777777777777777777777707DDDCCCCDCCDDD077777777777777777777
          7707D0FEFEFEFEFE7EFEFEFEFEFE07DDDCDDDDCDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0EFEFEFEFEF7FEFEFEFEFEF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0888888888878888888888807DDDDDDDDDDDDD088888888887888888888
          8807D0EFEFEFEFEF7FEFEFEFEFEF07DDDCDDDDCDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0FEFEFEFEFE7EFEFEFEFEFE07DDDCCCCDCCDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0777777777777777777777707DDDCCCCCCCCDD077777777777777777777
          7707D08888777CC8788888777CC807DDDCCCCDCCDDD088887778787888887778
          7807D0888888888878888888888807DDDCDDDDCDDDD088888888887888888888
          8807D0777777777777777777777707DDDDDDDDDDDDD077777777777777777777
          7707D0FBFBFBFBFB7BFBFBFBFBFF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0BFBFBFBFBF7FBFBFBFBFBF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0888888888878888888888807DDDDDDDDDDDDD088888888887888888888
          8807D0BFBFBFBFBF7FBFBFBFBFBF07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0FBFBFBFBFB7BFBFBFBFBFB07DDDDDDDDDDDDD0FFFFFFFFFF7FFFFFFFFF
          FF07D0777777777777777777777707DDDDDDDDDDDDD077777777777777777777
          7707D08888777CC8788888777CC807DDDDDDDDDDDDD088887778787888887778
          7807D088888888887888888888880DDDDDDDDDDDDDD088888888887888888888
          8807D000000000000000000000000DDDDDDDDDDDDDD000000000000000000000
          000DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
          DDDD}
        Transparent = True
      end
      object cbxLookAndFeel: TcxComboBox
        Left = 90
        Top = 37
        AutoSize = False
        Properties.DropDownListStyle = lsFixedList
        Properties.ItemHeight = 15
        Properties.OnChange = cbxLookAndFeelPropertiesChange
        TabOrder = 0
        OnClick = LookAndFeelChange
        Height = 23
        Width = 215
      end
      object chbxSuppressBackgroundBitmaps: TcxCheckBox
        Tag = 1
        Left = 90
        Top = 104
        Caption = 'Suppress Background Textures'
        TabOrder = 1
        OnClick = OptionsFormattingClick
        Width = 200
      end
      object chbxSuppressContentColoration: TcxCheckBox
        Tag = 2
        Left = 90
        Top = 130
        Caption = 'Suppress Content Coloration'
        TabOrder = 2
        OnClick = OptionsFormattingClick
        Width = 200
      end
    end
    object tshStyles: TTabSheet
      Caption = 'Styles'
      ImageIndex = 1
      object bvlStyles: TBevel
        Left = 118
        Top = 13
        Width = 193
        Height = 4
        Shape = bsBottomLine
      end
      object bvlStyleSheets: TBevel
        Left = 72
        Top = 302
        Width = 239
        Height = 5
        Shape = bsBottomLine
      end
      object lblStyleSheets: TLabel
        Left = 6
        Top = 298
        Width = 60
        Height = 13
        Caption = 'Style Sheets'
      end
      object bvlStylesHost: TBevel
        Left = 6
        Top = 33
        Width = 228
        Height = 222
      end
      object Label1: TLabel
        Left = 85
        Top = 140
        Width = 64
        Height = 13
        Caption = '[ Styles Site ]'
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
        Left = 243
        Top = 61
        Width = 68
        Height = 23
        Caption = 'Co&lor...'
        TabOrder = 0
        OnClick = btnStyleColorClick
      end
      object btnStyleFont: TButton
        Left = 243
        Top = 33
        Width = 68
        Height = 23
        Caption = '&Font...'
        TabOrder = 1
        OnClick = btnStyleFontClick
      end
      object btnStyleBackgroundBitmap: TButton
        Left = 243
        Top = 97
        Width = 68
        Height = 23
        Caption = '&Bitmap...'
        TabOrder = 2
        OnClick = btnStyleBackgroundBitmapClick
      end
      object cbxStyleSheets: TcxComboBox
        Left = 6
        Top = 318
        AutoSize = False
        Properties.DropDownListStyle = lsFixedList
        Properties.ItemHeight = 20
        Properties.OnDrawItem = cbxStyleSheetsPropertiesDrawItem
        TabOrder = 3
        OnClick = cbxStyleSheetsClick
        OnKeyDown = cbxStyleSheetsKeyDown
        Height = 24
        Width = 305
      end
      object btnStyleSheetNew: TButton
        Left = 6
        Top = 350
        Width = 71
        Height = 23
        Caption = '&New...'
        TabOrder = 4
        OnClick = btnStyleSheetNewClick
      end
      object btnStyleSheetCopy: TButton
        Left = 84
        Top = 350
        Width = 71
        Height = 23
        Caption = '&Copy...'
        TabOrder = 5
        OnClick = btnStyleSheetCopyClick
      end
      object btnStyleSheetDelete: TButton
        Left = 162
        Top = 350
        Width = 71
        Height = 23
        Caption = '&Delete...'
        TabOrder = 6
        OnClick = btnStyleSheetDeleteClick
      end
      object btnStylesSaveAs: TButton
        Left = 123
        Top = 263
        Width = 112
        Height = 23
        Caption = 'Save &As...'
        TabOrder = 7
        OnClick = btnStylesSaveAsClick
      end
      object btnStyleSheetRename: TButton
        Left = 240
        Top = 350
        Width = 71
        Height = 23
        Caption = '&Rename...'
        TabOrder = 8
        OnClick = btnStyleSheetRenameClick
      end
      object btnStyleBackgroundBitmapClear: TButton
        Left = 243
        Top = 125
        Width = 68
        Height = 23
        Caption = 'Cle&ar'
        TabOrder = 9
        OnClick = btnStyleBackgroundBitmapClearClick
      end
      object btnStyleRestoreDefaults: TButton
        Left = 6
        Top = 263
        Width = 112
        Height = 23
        Caption = 'Rest&ore Defaults'
        TabOrder = 10
        OnClick = btnStyleRestoreDefaultsClick
      end
      object chbxUseNativeStyles: TcxCheckBox
        Left = 3
        Top = 6
        TabOrder = 11
        OnClick = OptionsFormattingClick
        Width = 22
      end
    end
  end
  object pnlPreview: TPanel
    Left = 331
    Top = 46
    Width = 275
    Height = 395
    BevelOuter = bvLowered
    Color = clWindow
    TabOrder = 1
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 273
      Height = 393
      Align = alClient
      Color = clWindow
      TabOrder = 0
      object pbPreview: TPaintBox
        Left = 1
        Top = 1
        Width = 271
        Height = 391
        Align = alClient
        OnPaint = pbPreviewPaint
      end
    end
  end
  object pmStyles: TPopupMenu
    Images = ilStylesPopup
    OnPopup = pmStylesPopup
    Left = 6
    Top = 441
    object miStyleFont: TMenuItem
      Caption = '&Font...'
      ImageIndex = 0
      OnClick = btnStyleFontClick
    end
    object miStyleColor: TMenuItem
      Caption = '&Color...'
      OnClick = btnStyleColorClick
    end
    object miLine3: TMenuItem
      Caption = '-'
    end
    object miStyleBackgroundBitmap: TMenuItem
      Caption = '&Bitmap...'
      ImageIndex = 1
      ShortCut = 16463
      OnClick = btnStyleBackgroundBitmapClick
    end
    object miStyleBackgroundBitmapClear: TMenuItem
      Caption = 'Clear'
      ImageIndex = 3
      ShortCut = 16430
      OnClick = btnStyleBackgroundBitmapClearClick
    end
    object miLine2: TMenuItem
      Caption = '-'
    end
    object miStyleRestoreDefaults: TMenuItem
      Caption = 'Restore Defaults'
      OnClick = btnStyleRestoreDefaultsClick
    end
    object milLine: TMenuItem
      Caption = '-'
    end
    object miStylesSelectAll: TMenuItem
      Caption = 'Select A&ll'
      ShortCut = 16449
      OnClick = miStylesSelectAllClick
    end
    object miLine4: TMenuItem
      Caption = '-'
    end
    object miStylesSaveAs: TMenuItem
      Caption = 'Save &As...'
      ImageIndex = 2
      ShortCut = 16467
      OnClick = btnStylesSaveAsClick
    end
  end
  object ilStylesPopup: TImageList
    Left = 34
    Top = 441
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
  object cxEditStyleController1: TcxEditStyleController
    OnStyleChanged = StyleController1StyleChanged
    Left = 64
    Top = 440
  end
end
