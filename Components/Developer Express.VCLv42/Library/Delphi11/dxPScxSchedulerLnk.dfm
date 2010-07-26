object cxfmSchedulerReportLinkDesignWindow: TcxfmSchedulerReportLinkDesignWindow
  Left = 138
  Top = 193
  BorderStyle = bsDialog
  Caption = 'cxfmSchedulerReportLinkDesignWindow'
  ClientHeight = 446
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
    Height = 404
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
        Width = 235
        Height = 21
        EditValue = 38187d
        Properties.OnEditValueChanged = dePrintRangeStartEditValueChanged
        TabOrder = 0
      end
      object dePrintRangeEnd: TcxDateEdit
        Left = 70
        Top = 50
        Width = 235
        Height = 21
        EditValue = 38187d
        Properties.OnEditValueChanged = dePrintRangeEndEditValueChanged
        TabOrder = 1
      end
      object chbxHideDetailsOfPrivateAppointments: TcxCheckBox
        Left = 66
        Top = 113
        Width = 236
        Height = 21
        Caption = 'Hide Details of Private Appointments'
        TabOrder = 2
        Visible = False
      end
    end
    object tshPrintStyles: TTabSheet
      Caption = 'Print Styles'
      object lblPrintStylesOptions: TLabel
        Left = 5
        Top = 72
        Width = 37
        Height = 13
        Caption = 'Options'
      end
      object bvlPrintStyleOptions: TBevel
        Left = 50
        Top = 76
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
        Top = 18
        Width = 299
        Height = 21
        Properties.Alignment.Vert = taVCenter
        Properties.Items = <>
        TabOrder = 1
        OnClick = cbxPrintStylesClick
      end
      object pcPrintStyleOptions: TPageControl
        Left = 4
        Top = 90
        Width = 314
        Height = 284
        ActivePage = tshWeekly
        Style = tsButtons
        TabOrder = 2
        object tshDaily: TTabSheet
          Caption = 'Daily'
          TabVisible = False
          object lblPrintStyleDailyLayout: TLabel
            Left = 14
            Top = 7
            Width = 37
            Height = 13
            Caption = 'La&yout:'
            FocusControl = cbxPrintStyleDailyLayout
          end
          object lblPrintStyleDailyInclude: TLabel
            Left = 14
            Top = 67
            Width = 39
            Height = 13
            Caption = 'Include:'
          end
          object lblPrintStyleDailyPrintFrom: TLabel
            Left = 14
            Top = 139
            Width = 53
            Height = 13
            Caption = 'Print &From:'
            FocusControl = tePrintStyleDailyPrintFrom
          end
          object lblPrintStyleDailyPrintTo: TLabel
            Left = 14
            Top = 168
            Width = 41
            Height = 13
            Caption = 'Print &To:'
            FocusControl = tePrintStyleDailyPrintTo
          end
          object lblPrintStyleDailyResourceCountPerPage: TLabel
            Left = 14
            Top = 37
            Width = 82
            Height = 13
            Caption = 'Resources/Page:'
            FocusControl = sePrintStyleDailyResourceCountPerPage
          end
          object cbxPrintStyleDailyLayout: TcxComboBox
            Left = 115
            Top = 2
            Width = 186
            Height = 23
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              '1 page/day'
              '2 pages/day')
            TabOrder = 0
            OnClick = cbxPrintStyleDailyLayoutClick
          end
          object chbxPrintStyleDailyTaskPad: TcxCheckBox
            Left = 111
            Top = 64
            Width = 190
            Height = 21
            Caption = 'Task&Pad'
            TabOrder = 2
            OnClick = chbxPrintStyleOptionsViewClick
          end
          object chbxPrintStyleDailyNotesAreaBlank: TcxCheckBox
            Tag = 1
            Left = 111
            Top = 85
            Width = 190
            Height = 21
            Caption = 'Notes Area (&Blank)'
            TabOrder = 3
            OnClick = chbxPrintStyleOptionsViewClick
          end
          object chbxPrintStyleDailyNotesAreaLined: TcxCheckBox
            Tag = 2
            Left = 111
            Top = 106
            Width = 190
            Height = 21
            Caption = 'Notes Area (&Lined)'
            TabOrder = 4
            OnClick = chbxPrintStyleOptionsViewClick
          end
          object tePrintStyleDailyPrintFrom: TcxTimeEdit
            Left = 114
            Top = 135
            Width = 100
            Height = 21
            EditValue = 0.000000000000000000
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 5
          end
          object tePrintStyleDailyPrintTo: TcxTimeEdit
            Tag = 1
            Left = 114
            Top = 164
            Width = 100
            Height = 21
            EditValue = 0.000000000000000000
            Properties.ImmediatePost = True
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 6
          end
          object sePrintStyleDailyResourceCountPerPage: TcxSpinEdit
            Left = 115
            Top = 33
            Width = 100
            Height = 21
            Properties.OnChange = sePrintStyleResourceCountPerPagePropertiesChanged
            Properties.OnEditValueChanged = sePrintStyleResourceCountPerPagePropertiesEditValueChanged
            TabOrder = 1
          end
        end
        object tshWeekly: TTabSheet
          Caption = 'Weekly'
          ImageIndex = 1
          TabVisible = False
          object lblPrintStyleWeeklyPrintTo: TLabel
            Left = 14
            Top = 199
            Width = 41
            Height = 13
            Caption = 'Print &To:'
            FocusControl = tePrintStyleWeeklyPrintTo
          end
          object lblPrintStyleWeeklyPrintFrom: TLabel
            Left = 14
            Top = 170
            Width = 53
            Height = 13
            Caption = 'Print &From:'
            FocusControl = tePrintStyleWeeklyPrintFrom
          end
          object lblPrintStyleWeeklyInclude: TLabel
            Left = 14
            Top = 97
            Width = 39
            Height = 13
            Caption = 'Include:'
          end
          object lblPrintStyleWeeklyLayout: TLabel
            Left = 14
            Top = 36
            Width = 37
            Height = 13
            Caption = 'La&yout:'
            FocusControl = cbxPrintStyleWeeklyLayout
          end
          object lblPrintStyleWeeklyArrange: TLabel
            Left = 14
            Top = 7
            Width = 43
            Height = 13
            Caption = '&Arrange:'
            FocusControl = cbxPrintStyleWeeklyArrange
          end
          object lblPrintStyleWeeklyResourceCountPerPage: TLabel
            Left = 14
            Top = 67
            Width = 82
            Height = 13
            Caption = 'Resources/Page:'
            FocusControl = sePrintStyleWeeklyResourceCountPerPage
          end
          object tePrintStyleWeeklyPrintTo: TcxTimeEdit
            Tag = 1
            Left = 114
            Top = 194
            Width = 100
            Height = 21
            EditValue = 0.000000000000000000
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 7
          end
          object tePrintStyleWeeklyPrintFrom: TcxTimeEdit
            Left = 114
            Top = 165
            Width = 100
            Height = 21
            EditValue = 0.000000000000000000
            Properties.TimeFormat = tfHourMin
            Properties.OnChange = tePrintStylePrintRangePropertiesChange
            Properties.OnEditValueChanged = tePrintStylePrintRangePropertiesEditValueChanged
            TabOrder = 6
          end
          object chbxPrintStyleWeeklyNotesAreaLined: TcxCheckBox
            Tag = 2
            Left = 111
            Top = 136
            Width = 190
            Height = 21
            Caption = 'Notes Area (&Lined)'
            TabOrder = 5
            OnClick = chbxPrintStyleOptionsViewClick
          end
          object chbxPrintStyleWeeklyNotesAreaBlank: TcxCheckBox
            Tag = 1
            Left = 111
            Top = 115
            Width = 190
            Height = 21
            Caption = 'Notes Area (&Blank)'
            TabOrder = 4
            OnClick = chbxPrintStyleOptionsViewClick
          end
          object cbxPrintStyleWeeklyArrange: TcxComboBox
            Left = 115
            Top = 2
            Width = 186
            Height = 23
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              'Top to Bottom'
              'Left to Right')
            TabOrder = 0
            OnClick = cbxPrintStyleWeeklyArrangeClick
          end
          object cbxPrintStyleWeeklyLayout: TcxComboBox
            Left = 115
            Top = 32
            Width = 186
            Height = 23
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              '1 page/day'
              '2 pages/day')
            TabOrder = 1
            OnClick = cbxPrintStyleWeeklyLayoutClick
          end
          object chbxPrintStyleWeeklyTaskPad: TcxCheckBox
            Left = 111
            Top = 94
            Width = 190
            Height = 21
            Caption = 'TaskPad'
            TabOrder = 3
            OnClick = chbxPrintStyleOptionsViewClick
          end
          object chbxPrintStyleWeeklyDontPrintWeekends: TcxCheckBox
            Left = 9
            Top = 223
            Width = 285
            Height = 21
            Caption = 'Don'#39't Print &Weekends'
            TabOrder = 8
            OnClick = chbxPrintStyleWeeklyDontPrintWeekendsClick
          end
          object sePrintStyleWeeklyResourceCountPerPage: TcxSpinEdit
            Tag = 1
            Left = 115
            Top = 63
            Width = 100
            Height = 21
            Properties.OnChange = sePrintStyleResourceCountPerPagePropertiesChanged
            Properties.OnEditValueChanged = sePrintStyleResourceCountPerPagePropertiesEditValueChanged
            TabOrder = 2
          end
        end
        object tshMonthly: TTabSheet
          Caption = 'Monthly'
          ImageIndex = 2
          TabVisible = False
          object lblPrintStyleMonthlyLayout: TLabel
            Left = 14
            Top = 7
            Width = 37
            Height = 13
            Caption = 'La&yout:'
            FocusControl = cbxPrintStyleMonthlyLayout
          end
          object lblPrintStyleMonthlyInclude: TLabel
            Left = 14
            Top = 67
            Width = 39
            Height = 13
            Caption = 'Include:'
          end
          object lblPrintStyleMonthlyResourceCountPerPage: TLabel
            Left = 14
            Top = 37
            Width = 82
            Height = 13
            Caption = 'Resources/Page:'
            FocusControl = sePrintStyleMonthlyResourceCountPerPage
          end
          object cbxPrintStyleMonthlyLayout: TcxComboBox
            Left = 115
            Top = 2
            Width = 186
            Height = 23
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              '1 page/month'
              '2 pages/month')
            TabOrder = 0
            OnClick = cbxPrintStyleMonthlyLayoutClick
          end
          object chbxPrintStyleMonthlyTaskPad: TcxCheckBox
            Left = 111
            Top = 64
            Width = 190
            Height = 21
            Caption = 'Task&Pad'
            TabOrder = 2
            OnClick = chbxPrintStyleOptionsViewClick
          end
          object chbxPrintStyleMonthlyNotesAreaBlank: TcxCheckBox
            Tag = 1
            Left = 111
            Top = 85
            Width = 190
            Height = 21
            Caption = 'Notes Area (&Blank)'
            TabOrder = 3
            OnClick = chbxPrintStyleOptionsViewClick
          end
          object chbxPrintStyleMonthlyNotesAreaLined: TcxCheckBox
            Tag = 2
            Left = 111
            Top = 106
            Width = 190
            Height = 21
            Caption = 'Notes Area (&Lined)'
            TabOrder = 4
            OnClick = chbxPrintStyleOptionsViewClick
          end
          object chbxPrintStyleMonthlyDontPrintWeekends: TcxCheckBox
            Left = 9
            Top = 144
            Width = 285
            Height = 21
            Caption = 'Don'#39't Print &Weekends'
            TabOrder = 5
            OnClick = chbxPrintStyleMonthlyDontPrintWeekendsClick
          end
          object chbxPrintStyleMonthlyPrintExactlyOneMonthPerPage: TcxCheckBox
            Left = 9
            Top = 167
            Width = 285
            Height = 21
            Caption = 'Print Exactly One Month Per Page'
            TabOrder = 6
            OnClick = chbxPrintStyleMonthlyPrintExactlyOneMonthPerPageClick
          end
          object sePrintStyleMonthlyResourceCountPerPage: TcxSpinEdit
            Tag = 2
            Left = 115
            Top = 33
            Width = 100
            Height = 21
            Properties.OnChange = sePrintStyleResourceCountPerPagePropertiesChanged
            Properties.OnEditValueChanged = sePrintStyleResourceCountPerPagePropertiesEditValueChanged
            TabOrder = 1
          end
        end
        object tshTrifold: TTabSheet
          Caption = 'Tri-fold'
          ImageIndex = 3
          TabVisible = False
          object lblPrintStyleTrifoldSectionLeft: TLabel
            Left = 14
            Top = 7
            Width = 61
            Height = 13
            Caption = '&Left Section:'
            FocusControl = cbxPrintStyleTrifoldSectionLeft
          end
          object lblPrintStyleTrifoldSectionMiddle: TLabel
            Left = 14
            Top = 41
            Width = 72
            Height = 13
            Caption = '&Middle Section:'
            FocusControl = cbxPrintStyleTrifoldSectionMiddle
          end
          object lblPrintStyleTrifoldSectionRight: TLabel
            Left = 14
            Top = 74
            Width = 67
            Height = 13
            Caption = '&Right Section:'
            FocusControl = cbxPrintStyleTrifoldSectionRight
          end
          object cbxPrintStyleTrifoldSectionLeft: TcxComboBox
            Left = 100
            Top = 2
            Width = 200
            Height = 23
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            TabOrder = 0
            OnClick = cbxPrintStyleTrifoldSectionModeClick
          end
          object cbxPrintStyleTrifoldSectionMiddle: TcxComboBox
            Tag = 1
            Left = 100
            Top = 36
            Width = 200
            Height = 23
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            TabOrder = 1
            OnClick = cbxPrintStyleTrifoldSectionModeClick
          end
          object cbxPrintStyleTrifoldSectionRight: TcxComboBox
            Tag = 2
            Left = 100
            Top = 69
            Width = 200
            Height = 23
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            TabOrder = 2
            OnClick = cbxPrintStyleTrifoldSectionModeClick
          end
        end
        object tshDetails: TTabSheet
          Caption = 'Details'
          ImageIndex = 4
          TabVisible = False
          object chbxPrintStyleDetailsUsePagination: TcxCheckBox
            Left = 14
            Top = 3
            Width = 187
            Height = 21
            Caption = 'Start a New Page Each:'
            TabOrder = 0
            OnClick = chbxPrintStyleDetailsUsePaginationClick
          end
          object cbxPrintStyleDetailsPagination: TcxComboBox
            Left = 203
            Top = 2
            Width = 97
            Height = 23
            AutoSize = False
            Properties.DropDownListStyle = lsFixedList
            Properties.ItemHeight = 15
            Properties.Items.Strings = (
              'Day'
              'Week'
              'Month')
            TabOrder = 1
            OnClick = cbxPrintStyleDetailsPaginationClick
          end
        end
        object tshMemo: TTabSheet
          Caption = 'Memo'
          ImageIndex = 5
          TabVisible = False
          object chbxPrintStyleMemoStartEachItemOnNewPage: TcxCheckBox
            Left = 14
            Top = 3
            Width = 187
            Height = 21
            Caption = 'Start Each Item On New Page'
            TabOrder = 0
            OnClick = chbxPrintStyleMemoStartEachItemOnNewPageClick
          end
          object chbxPrintStyleMemoPrintOnlySelectedEvents: TcxCheckBox
            Left = 14
            Top = 27
            Width = 187
            Height = 21
            Caption = 'Print Only Selected Events'
            State = cbsChecked
            TabOrder = 1
            OnClick = chbxPrintStyleMemoPrintOnlySelectedEventsClick
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
        Width = 215
        Height = 23
        AutoSize = False
        Properties.DropDownListStyle = lsFixedList
        Properties.ItemHeight = 15
        Properties.OnChange = cbxLookAndFeelPropertiesChange
        TabOrder = 0
        OnClick = LookAndFeelChange
      end
      object chbxSuppressBackgroundBitmaps: TcxCheckBox
        Tag = 1
        Left = 90
        Top = 104
        Width = 200
        Height = 21
        Caption = 'Suppress Background Textures'
        TabOrder = 1
        OnClick = OptionsFormattingClick
      end
      object chbxSuppressContentColoration: TcxCheckBox
        Tag = 2
        Left = 90
        Top = 130
        Width = 200
        Height = 21
        Caption = 'Suppress Content Coloration'
        TabOrder = 2
        OnClick = OptionsFormattingClick
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
        Width = 305
        Height = 24
        AutoSize = False
        Properties.DropDownListStyle = lsFixedList
        Properties.ItemHeight = 20
        Properties.OnDrawItem = cbxStyleSheetsPropertiesDrawItem
        TabOrder = 3
        OnClick = cbxStyleSheetsClick
        OnKeyDown = cbxStyleSheetsKeyDown
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
        Width = 22
        Height = 21
        TabOrder = 11
        OnClick = OptionsFormattingClick
      end
    end
  end
  object pnlPreview: TPanel
    Left = 331
    Top = 46
    Width = 275
    Height = 356
    BevelOuter = bvLowered
    Color = clWindow
    TabOrder = 1
    object pbPreview: TPaintBox
      Left = 1
      Top = 1
      Width = 273
      Height = 354
      Align = alClient
      OnPaint = pbPreviewPaint
    end
  end
  object pmStyles: TPopupMenu
    Images = ilStylesPopup
    OnPopup = pmStylesPopup
    Left = 6
    Top = 417
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
    Top = 417
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
    Top = 416
  end
end
