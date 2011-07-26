object dlgEditPracGST: TdlgEditPracGST
  Left = 218
  Top = 112
  BorderStyle = bsDialog
  Caption = 'Practice Tax Defaults'
  ClientHeight = 416
  ClientWidth = 639
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pctax: TPageControl
    Left = 0
    Top = 0
    Width = 639
    Height = 375
    ActivePage = tsOther
    Align = alClient
    TabOrder = 0
    object tsGST: TTabSheet
      Caption = 'GST Rates'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label1: TLabel
        Left = 8
        Top = 4
        Width = 311
        Height = 13
        Caption = 
          'These rates will be used as the Default settings for a New Clien' +
          't.'
      end
      object gbxRates: TGroupBox
        Left = 0
        Top = 24
        Width = 625
        Height = 305
        Caption = 'Rates'
        TabOrder = 0
        object Label5: TLabel
          Left = 208
          Top = 36
          Width = 74
          Height = 13
          Caption = 'Effective Dates'
        end
        object Label7: TLabel
          Left = 326
          Top = 13
          Width = 32
          Height = 13
          Caption = 'Rate 1'
        end
        object Label8: TLabel
          Left = 414
          Top = 13
          Width = 32
          Height = 13
          Caption = 'Rate 2'
        end
        object Label9: TLabel
          Left = 502
          Top = 13
          Width = 32
          Height = 13
          Caption = 'Rate 3'
        end
        object tblRates: TOvcTable
          Left = 6
          Top = 61
          Width = 613
          Height = 239
          RowLimit = 20
          LockedCols = 0
          LeftCol = 0
          ActiveCol = 0
          BorderStyle = bsNone
          Color = clWindow
          Colors.ActiveUnfocused = clWindow
          Colors.ActiveUnfocusedText = clWindowText
          Colors.Editing = clWindow
          Controller = OvcController1
          GridPenSet.NormalGrid.NormalColor = clBtnShadow
          GridPenSet.NormalGrid.Style = psSolid
          GridPenSet.NormalGrid.Effect = geVertical
          GridPenSet.LockedGrid.NormalColor = clBtnShadow
          GridPenSet.LockedGrid.Style = psSolid
          GridPenSet.LockedGrid.Effect = ge3D
          GridPenSet.CellWhenFocused.NormalColor = clBlack
          GridPenSet.CellWhenFocused.Style = psSolid
          GridPenSet.CellWhenFocused.Effect = geBoth
          GridPenSet.CellWhenUnfocused.NormalColor = clBlack
          GridPenSet.CellWhenUnfocused.Style = psClear
          GridPenSet.CellWhenUnfocused.Effect = geBoth
          LockedRowsCell = OvcTCColHead1
          Options = [otoNoRowResizing, otoNoColResizing, otoEnterToArrow]
          TabOrder = 3
          OnActiveCellChanged = tblRatesActiveCellChanged
          OnActiveCellMoving = tblRatesActiveCellMoving
          OnBeginEdit = tblRatesBeginEdit
          OnDoneEdit = tblRatesDoneEdit
          OnEndEdit = tblRatesEndEdit
          OnEnter = tblRatesEnter
          OnExit = tblRatesExit
          OnGetCellData = tblRatesGetCellData
          OnGetCellAttributes = tblRatesGetCellAttributes
          OnUserCommand = tblRatesUserCommand
          CellData = (
            'dlgEditPracGST.OvcTCColHead1')
          RowData = (
            22)
          ColData = (
            32
            False
            True
            'dlgEditPracGST.ColID'
            130
            False
            True
            'dlgEditPracGST.colDesc'
            143
            False
            True
            'dlgEditPracGST.celGSTType'
            66
            False
            True
            'dlgEditPracGST.colRate1'
            65
            False
            True
            'dlgEditPracGST.colRate2'
            65
            False
            True
            'dlgEditPracGST.colRate3'
            100
            False
            True
            'dlgEditPracGST.colAccount')
        end
        object eDate1: TOvcPictureField
          Left = 305
          Top = 32
          Width = 80
          Height = 22
          Cursor = crIBeam
          DataType = pftDate
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          Controller = OvcController1
          ControlCharColor = clRed
          DecimalPlaces = 0
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Epoch = 0
          InitDateTime = False
          MaxLength = 8
          Options = [efoCaretToEnd]
          PictureMask = 'DD/mm/yy'
          TabOrder = 0
          OnDblClick = eDateT1DblClick
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
        object eDate2: TOvcPictureField
          Left = 396
          Top = 32
          Width = 78
          Height = 22
          Cursor = crIBeam
          DataType = pftDate
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          Controller = OvcController1
          ControlCharColor = clRed
          DecimalPlaces = 0
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Epoch = 0
          InitDateTime = False
          MaxLength = 8
          Options = [efoCaretToEnd]
          PictureMask = 'DD/mm/yy'
          TabOrder = 1
          OnDblClick = eDateT1DblClick
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
        object eDate3: TOvcPictureField
          Left = 485
          Top = 32
          Width = 81
          Height = 22
          Cursor = crIBeam
          DataType = pftDate
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          Controller = OvcController1
          ControlCharColor = clRed
          DecimalPlaces = 0
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Epoch = 0
          InitDateTime = False
          MaxLength = 8
          Options = [efoCaretToEnd]
          PictureMask = 'DD/mm/yy'
          TabOrder = 2
          OnDblClick = eDateT1DblClick
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
      end
    end
    object tsOther: TTabSheet
      Caption = 'Tax Rates'
      ImageIndex = 1
      object Label2: TLabel
        Left = 311
        Top = 49
        Width = 32
        Height = 13
        Caption = 'Rate 3'
      end
      object Label3: TLabel
        Left = 231
        Top = 49
        Width = 32
        Height = 13
        Caption = 'Rate 2'
      end
      object Label4: TLabel
        Left = 143
        Top = 49
        Width = 32
        Height = 13
        Caption = 'Rate 1'
      end
      object lh10: TLabel
        Left = 16
        Top = 27
        Width = 66
        Height = 13
        Caption = 'Company Tax'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Bevel7: TBevel
        Left = 114
        Top = 33
        Width = 457
        Height = 9
        Shape = bsTopLine
      end
      object Label11: TLabel
        Left = 20
        Top = 69
        Width = 74
        Height = 13
        Caption = 'Effective Dates'
      end
      object Label13: TLabel
        Left = 20
        Top = 103
        Width = 23
        Height = 13
        Caption = 'Rate'
      end
      object Label6: TLabel
        Left = 8
        Top = 4
        Width = 311
        Height = 13
        Caption = 
          'These rates will be used as the Default settings for a New Clien' +
          't.'
      end
      object eDateT3: TOvcPictureField
        Left = 296
        Top = 68
        Width = 86
        Height = 22
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
        ControlCharColor = clRed
        DecimalPlaces = 0
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Epoch = 0
        InitDateTime = False
        MaxLength = 8
        Options = [efoCaretToEnd]
        PictureMask = 'DD/mm/yy'
        TabOrder = 4
        OnDblClick = eDateT1DblClick
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object eDateT2: TOvcPictureField
        Left = 213
        Top = 68
        Width = 77
        Height = 22
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
        ControlCharColor = clRed
        DecimalPlaces = 0
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Epoch = 0
        InitDateTime = False
        MaxLength = 8
        Options = [efoCaretToEnd]
        PictureMask = 'DD/mm/yy'
        TabOrder = 2
        OnDblClick = eDateT1DblClick
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object eDateT1: TOvcPictureField
        Left = 128
        Top = 68
        Width = 79
        Height = 22
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
        ControlCharColor = clRed
        DecimalPlaces = 0
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Epoch = 0
        InitDateTime = False
        MaxLength = 8
        Options = [efoCaretToEnd]
        PictureMask = 'DD/mm/yy'
        TabOrder = 0
        OnDblClick = eDateT1DblClick
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object eRate3: TOvcPictureField
        Left = 296
        Top = 100
        Width = 86
        Height = 22
        Cursor = crIBeam
        DataType = pftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
        ControlCharColor = clRed
        DecimalPlaces = 0
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Epoch = 0
        InitDateTime = False
        MaxLength = 9
        Options = [efoCaretToEnd]
        PictureMask = '####.####'
        TabOrder = 5
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
      object ERate2: TOvcPictureField
        Left = 213
        Top = 100
        Width = 77
        Height = 22
        Cursor = crIBeam
        DataType = pftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
        ControlCharColor = clRed
        DecimalPlaces = 0
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Epoch = 0
        InitDateTime = False
        MaxLength = 9
        Options = [efoCaretToEnd]
        PictureMask = '####.####'
        TabOrder = 3
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
      object eRate1: TOvcPictureField
        Left = 128
        Top = 100
        Width = 79
        Height = 22
        Cursor = crIBeam
        DataType = pftDouble
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        Controller = OvcController1
        ControlCharColor = clRed
        DecimalPlaces = 0
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Epoch = 0
        InitDateTime = False
        MaxLength = 9
        Options = [efoCaretToEnd]
        PictureMask = '####.####'
        TabOrder = 1
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
    end
  end
  object pnlBtn: TPanel
    Left = 0
    Top = 375
    Width = 639
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      639
      41)
    object btnOk: TButton
      Left = 464
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 548
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
  object OvcController1: TOvcController
    EntryCommands.TableList = (
      'Default'
      True
      ()
      'WordStar'
      False
      ()
      'Grid'
      False
      ())
    Epoch = 1900
    Left = 72
    Top = 328
  end
  object colDesc: TOvcTCString
    MaxLength = 60
    Table = tblRates
    Left = 104
    Top = 328
  end
  object colRate1: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '###.####'
    Table = tblRates
    Left = 168
    Top = 328
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object colRate2: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '###.####'
    Table = tblRates
    Left = 208
    Top = 328
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object colRate3: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '###.####'
    Table = tblRates
    Left = 248
    Top = 328
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object colAccount: TOvcTCString
    MaxLength = 10
    Table = tblRates
    OnKeyDown = colAccountKeyDown
    Left = 288
    Top = 328
  end
  object OvcTCColHead1: TOvcTCColHead
    Headings.Strings = (
      'ID'
      'Class Description'
      'GST Type'
      'Rate 1'
      'Rate 2'
      'Rate 3'
      'Control Account')
    ShowLetters = False
    Table = tblRates
    Left = 40
    Top = 328
  end
  object ColID: TOvcTCString
    MaxLength = 3
    Table = tblRates
    Left = 8
    Top = 328
  end
  object celGSTType: TOvcTCComboBox
    DropDownCount = 10
    Items.Strings = (
      'Income'
      'Expenditure'
      'Exempt'
      'Zero Rated')
    MaxLength = 15
    Style = csOwnerDrawFixed
    Table = tblRates
    OnDropDown = celGSTTypeDropDown
    Left = 136
    Top = 328
  end
end
