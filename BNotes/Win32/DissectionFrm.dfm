inherited frmDissection: TfrmDissection
  Left = 307
  Top = 201
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Dissect Entry'
  ClientHeight = 446
  ClientWidth = 766
  Constraints.MinHeight = 430
  Constraints.MinWidth = 640
  KeyPreview = True
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnKeyPress = FormKeyPress
  OnResize = FormResize
  OnShortCut = FormShortCut
  OnShow = FormShow
  ExplicitWidth = 782
  ExplicitHeight = 484
  PixelsPerInch = 96
  TextHeight = 16
  object pnlTop: TPanel
    Left = 0
    Top = 41
    Width = 766
    Height = 24
    Align = alTop
    BevelOuter = bvNone
    Color = 10050048
    ParentBackground = False
    TabOrder = 1
    DesignSize = (
      766
      24)
    object chkShowPanel: TRzCheckBox
      Left = 661
      Top = 5
      Width = 97
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Show Panel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      State = cbUnchecked
      TabOrder = 0
      OnClick = chkShowPanelClick
    end
    object btnSuper: TButton
      AlignWithMargins = True
      Left = 8
      Top = 4
      Width = 160
      Height = 17
      Cursor = crHandPoint
      Margins.Left = 8
      Margins.Top = 4
      Align = alLeft
      Caption = '&Edit Superfund Details'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      Visible = False
      OnClick = btnSuperClick
    end
  end
  object pnlCoding: TPanel
    Left = 8
    Top = 65
    Width = 750
    Height = 373
    Align = alClient
    BevelOuter = bvNone
    Color = clWindow
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 0
    object tgDissect: TtsGrid
      Left = 0
      Top = 0
      Width = 750
      Height = 104
      Align = alClient
      AlwaysShowEditor = False
      AlwaysShowFocus = True
      CellSelectMode = cmNone
      CheckBoxStyle = stCheck
      Cols = 4
      Ctl3D = False
      DefaultRowHeight = 25
      ExportDelimiter = ','
      FocusBorder = fbDouble
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      GridLines = glVertLines
      HeadingButton = hbCell
      HeadingFont.Charset = DEFAULT_CHARSET
      HeadingFont.Color = clBtnText
      HeadingFont.Height = -12
      HeadingFont.Name = 'MS Sans Serif'
      HeadingFont.Style = []
      HeadingHeight = 25
      HeadingParentFont = False
      HeadingVertAlignment = vtaCenter
      HeadingWordWrap = wwOff
      ParentCtl3D = False
      ParentFont = False
      ParentShowHint = False
      PopupMenu = PopupMenu1
      RowBarIndicator = False
      RowBarOn = False
      RowChangedIndicator = riOff
      RowMoving = False
      Rows = 3
      RowSelectMode = rsNone
      ShowHint = True
      SkipReadOnly = False
      StretchPicture = False
      TabOrder = 0
      ThumbTracking = True
      Version = '2.20.26'
      VertAlignment = vtaCenter
      WantTabs = False
      WordWrap = wwOff
      XMLExport.Version = '1.0'
      XMLExport.DataPacketVersion = '2.0'
      OnButtonClick = tgDissectButtonClick
      OnCellChanged = tgDissectCellChanged
      OnCellEdit = tgDissectCellEdit
      OnCellLoaded = tgDissectCellLoaded
      OnColMoved = tgDissectColMoved
      OnComboDropDown = tgDissectComboDropDown
      OnComboInit = tgDissectComboInit
      OnComboRollUp = tgDissectComboRollUp
      OnEndCellEdit = tgDissectEndCellEdit
      OnEnter = tgDissectEnter
      OnExit = tgDissectExit
      OnInvalidMaskValue = tgDissectInvalidMaskValue
      OnKeyDown = tgDissectKeyDown
      OnKeyPress = tgDissectKeyPress
      OnKeyUp = tgDissectKeyUp
      OnMouseMove = tgDissectMouseMove
      OnMouseWheel = tgDissectMouseWheel
      OnRowChanged = tgDissectRowChanged
      OnRowLoaded = tgDissectRowLoaded
    end
    object Panel1: TPanel
      Left = 0
      Top = 332
      Width = 750
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 2
      DesignSize = (
        748
        39)
      object Label5: TLabel
        Left = 16
        Top = 13
        Width = 30
        Height = 13
        Caption = 'Total :'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object lblTotal: TLabel
        Left = 64
        Top = 12
        Width = 105
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        Caption = '$0.00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        Transparent = True
      end
      object Label14: TLabel
        Left = 192
        Top = 12
        Width = 56
        Height = 13
        Caption = 'Remaining :'
        Transparent = True
      end
      object lblRemain: TLabel
        Left = 272
        Top = 11
        Width = 97
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        Caption = '$0.00'
        Transparent = True
      end
      object btnOK: TButton
        Left = 538
        Top = 1
        Width = 81
        Height = 29
        Cursor = crHandPoint
        Anchors = [akRight]
        Caption = '&OK'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ModalResult = 1
        ParentFont = False
        TabOrder = 0
        ExplicitLeft = 540
        ExplicitTop = 2
      end
      object btnCancel: TButton
        Left = 625
        Top = 1
        Width = 81
        Height = 29
        Cursor = crHandPoint
        Anchors = [akRight]
        Caption = '&Cancel'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ModalResult = 2
        ParentFont = False
        TabOrder = 1
        ExplicitLeft = 627
        ExplicitTop = 2
      end
    end
    object pnlPanel: TPanel
      Left = 0
      Top = 104
      Width = 750
      Height = 228
      Align = alBottom
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 1
      DesignSize = (
        748
        226)
      object lblAccount: TLabel
        Left = 176
        Top = 12
        Width = 40
        Height = 13
        Alignment = taRightJustify
        Caption = 'Account'
      end
      object lblAccountName: TLabel
        Left = 372
        Top = 12
        Width = 78
        Height = 13
        Caption = 'lblAccountName'
        ShowAccelChar = False
      end
      object lblPayee: TLabel
        Left = 186
        Top = 36
        Width = 30
        Height = 13
        Alignment = taRightJustify
        Caption = 'Payee'
      end
      object Label9: TLabel
        Left = 20
        Top = 84
        Width = 36
        Height = 13
        Alignment = taRightJustify
        Caption = 'Amount'
      end
      object lblGST: TLabel
        Left = 194
        Top = 84
        Width = 22
        Height = 13
        Caption = 'GST'
      end
      object lblQuantity: TLabel
        Left = 15
        Top = 60
        Width = 39
        Height = 13
        Caption = 'Quantity'
      end
      object lblNarration: TLabel
        Left = 12
        Top = 108
        Width = 43
        Height = 13
        Alignment = taRightJustify
        Caption = 'Narration'
      end
      object Label2: TLabel
        Left = 28
        Top = 132
        Width = 28
        Height = 13
        Alignment = taRightJustify
        Caption = 'Notes'
      end
      object lblJob: TLabel
        Left = 199
        Top = 60
        Width = 17
        Height = 13
        Alignment = taRightJustify
        Caption = 'Job'
      end
      object lblJobName: TLabel
        Left = 372
        Top = 60
        Width = 55
        Height = 13
        Caption = 'lblJobName'
        ShowAccelChar = False
      end
      object rzFakePayeeBorder: TRzEdit
        Left = 221
        Top = 32
        Width = 233
        Height = 21
        TabStop = False
        Ctl3D = True
        Enabled = False
        FrameController = RzFrameController1
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 11
      end
      object rzFakeAccountBorder: TRzEdit
        Left = 221
        Top = 8
        Width = 145
        Height = 21
        TabStop = False
        Ctl3D = True
        Enabled = False
        FrameController = RzFrameController1
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 10
      end
      object tgAccountLookup: TtsGrid
        Left = 222
        Top = 9
        Width = 143
        Height = 19
        AlwaysShowEditor = False
        BorderStyle = bsNone
        ButtonEdgeWidth = 0
        CellSelectMode = cmNone
        CenterPicture = False
        CheckBoxStyle = stCheck
        Cols = 1
        ColSelectMode = csNone
        DefaultButtonHeight = 18
        DefaultButtonWidth = 18
        DefaultColWidth = 143
        DefaultRowHeight = 20
        ExportDelimiter = ','
        FocusColor = clHighlight
        FocusFontColor = clHighlightText
        HeadingFont.Charset = DEFAULT_CHARSET
        HeadingFont.Color = clWindowText
        HeadingFont.Height = -11
        HeadingFont.Name = 'MS Sans Serif'
        HeadingFont.Style = []
        HeadingOn = False
        HeadingParentFont = False
        InactiveButtonState = ibsPicture
        ParentShowHint = False
        ResizeRows = rrNone
        RowBarIndicator = False
        RowBarOn = False
        RowMoving = False
        Rows = 1
        RowSelectMode = rsNone
        ScrollBars = ssNone
        ShowHint = True
        TabOrder = 0
        Version = '2.20.26'
        WantTabs = False
        XMLExport.Version = '1.0'
        XMLExport.DataPacketVersion = '2.0'
        OnCellEdit = tgAccountLookupCellEdit
        OnCellLoaded = tgAccountLookupCellLoaded
        OnComboDropDown = tgDissectComboInit
        OnComboInit = tgDissectComboInit
        OnEndCellEdit = tgAccountLookupEndCellEdit
        OnEnter = tgAccountLookupEnter
        OnExit = tgAccountLookupExit
        OnKeyDown = tgAccountLookupKeyDown
        OnKeyPress = tgAccountLookupKeyPress
        ColProperties = <
          item
            DataCol = 1
            Col.ButtonType = btCombo
            Col.CenterPicture = dopOn
            Col.Width = 143
          end>
        RowProperties = <
          item
            DataRow = 1
            DisplayRow = 1
            Row.Height = 20
            Row.VertAlignment = vtaCenter
          end>
      end
      object rzAmount: TRzNumericEdit
        Left = 60
        Top = 80
        Width = 105
        Height = 21
        Ctl3D = True
        FrameController = RzFrameController1
        MaxLength = 14
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 4
        OnChange = pfEdited
        OnEnter = pfEnter
        OnExit = pfExit
        OnKeyPress = rzAmountKeyPress
        IntegersOnly = False
        DisplayFormat = '#,##0.00;(#,##0.00)'
      end
      object rzGSTAmount: TRzNumericEdit
        Left = 222
        Top = 80
        Width = 105
        Height = 21
        Ctl3D = True
        FrameController = RzFrameController1
        MaxLength = 14
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 5
        OnChange = pfEdited
        OnEnter = pfEnter
        OnExit = pfExit
        OnKeyPress = rzGSTAmountKeyPress
        AllowBlank = True
        IntegersOnly = False
        DisplayFormat = '#,##0.00;(#,##0.00)'
      end
      object rzQuantity: TRzNumericEdit
        Left = 60
        Top = 56
        Width = 105
        Height = 21
        Ctl3D = True
        FrameController = RzFrameController1
        MaxLength = 14
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 2
        OnChange = pfEdited
        OnEnter = pfEnter
        OnExit = pfExit
        OnKeyPress = rzQuantityKeyPress
        IntegersOnly = False
        DisplayFormat = '#,##0.####'
      end
      object rzNarration: TRzEdit
        Left = 60
        Top = 105
        Width = 545
        Height = 21
        Ctl3D = True
        FrameController = RzFrameController1
        MaxLength = 200
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 6
        OnChange = pfEdited
        OnEnter = pfEnter
        OnExit = pfExit
      end
      object rzNotes: TRzMemo
        Left = 60
        Top = 128
        Width = 679
        Height = 93
        Anchors = [akLeft, akTop, akRight, akBottom]
        Ctl3D = True
        ParentCtl3D = False
        ScrollBars = ssVertical
        TabOrder = 7
        OnChange = pfEdited
        OnEnter = pfEnter
        OnExit = pfExit
        FrameController = RzFrameController1
        TabOnEnter = True
      end
      object tgPayeeLookup: TtsGrid
        Left = 222
        Top = 33
        Width = 231
        Height = 19
        AlwaysShowEditor = False
        BorderStyle = bsNone
        ButtonEdgeWidth = 0
        CellSelectMode = cmNone
        CenterPicture = False
        CheckBoxStyle = stCheck
        Cols = 1
        ColSelectMode = csNone
        Ctl3D = False
        DefaultButtonHeight = 18
        DefaultButtonWidth = 18
        DefaultColWidth = 231
        DefaultRowHeight = 20
        ExportDelimiter = ','
        FocusColor = clHighlight
        FocusFontColor = clHighlightText
        GridLines = glNone
        HeadingFont.Charset = DEFAULT_CHARSET
        HeadingFont.Color = clWindowText
        HeadingFont.Height = -11
        HeadingFont.Name = 'MS Sans Serif'
        HeadingFont.Style = []
        HeadingOn = False
        HeadingParentFont = False
        InactiveButtonState = ibsPicture
        ParentCtl3D = False
        ParentShowHint = False
        ResizeRows = rrNone
        RowBarIndicator = False
        RowBarOn = False
        RowMoving = False
        Rows = 1
        RowSelectMode = rsNone
        ScrollBars = ssNone
        ShowHint = True
        TabOrder = 1
        Version = '2.20.26'
        WantTabs = False
        XMLExport.Version = '1.0'
        XMLExport.DataPacketVersion = '2.0'
        OnCellLoaded = tgPayeeLookupCellLoaded
        OnComboDropDown = tgDissectComboInit
        OnComboInit = tgDissectComboInit
        OnEndCellEdit = tgPayeeLookupEndCellEdit
        OnEnter = tgPayeeLookupEnter
        OnExit = tgPayeeLookupExit
        OnKeyPress = tgPayeeLookupKeyPress
        ColProperties = <
          item
            DataCol = 1
            Col.ButtonType = btCombo
            Col.CenterPicture = dopOn
            Col.Width = 231
          end>
        RowProperties = <
          item
            DataRow = 1
            DisplayRow = 1
            Row.Height = 20
            Row.VertAlignment = vtaCenter
          end>
      end
      object rbtnPrev: TButton
        Left = 571
        Top = 6
        Width = 81
        Height = 29
        Cursor = crHandPoint
        Anchors = [akTop, akRight]
        Caption = '&Previous'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 9
        OnClick = rbtnPrevClick
      end
      object rbtnNext: TButton
        Left = 658
        Top = 6
        Width = 81
        Height = 29
        Cursor = crHandPoint
        Anchors = [akTop, akRight]
        Caption = '&Next'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 8
        OnClick = rbtnNextClick
      end
      object rzFakeJobBorder: TRzEdit
        Left = 221
        Top = 56
        Width = 145
        Height = 21
        TabStop = False
        Ctl3D = True
        Enabled = False
        FrameController = RzFrameController1
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 12
      end
      object tgJobLookup: TtsGrid
        Left = 222
        Top = 57
        Width = 143
        Height = 19
        AlwaysShowEditor = False
        BorderStyle = bsNone
        ButtonEdgeWidth = 0
        CellSelectMode = cmNone
        CenterPicture = False
        CheckBoxStyle = stCheck
        Cols = 1
        ColSelectMode = csNone
        Ctl3D = False
        DefaultButtonHeight = 18
        DefaultButtonWidth = 18
        DefaultColWidth = 143
        DefaultRowHeight = 20
        ExportDelimiter = ','
        FocusColor = clHighlight
        FocusFontColor = clHighlightText
        GridLines = glNone
        HeadingFont.Charset = DEFAULT_CHARSET
        HeadingFont.Color = clWindowText
        HeadingFont.Height = -11
        HeadingFont.Name = 'MS Sans Serif'
        HeadingFont.Style = []
        HeadingOn = False
        HeadingParentFont = False
        InactiveButtonState = ibsPicture
        ParentCtl3D = False
        ParentShowHint = False
        ResizeRows = rrNone
        RowBarIndicator = False
        RowBarOn = False
        RowMoving = False
        Rows = 1
        RowSelectMode = rsNone
        ScrollBars = ssNone
        ShowHint = True
        TabOrder = 3
        Version = '2.20.26'
        WantTabs = False
        XMLExport.Version = '1.0'
        XMLExport.DataPacketVersion = '2.0'
        OnCellLoaded = tgJobLookupCellLoaded
        OnComboDropDown = tgDissectComboInit
        OnComboInit = tgDissectComboInit
        OnEndCellEdit = tgJobLookupEndCellEdit
        OnEnter = tgJobLookupEnter
        OnExit = tgJobLookupExit
        OnKeyPress = tgJobLookupKeyPress
        ColProperties = <
          item
            DataCol = 1
            Col.ButtonType = btCombo
            Col.CenterPicture = dopOn
            Col.Width = 143
          end>
        RowProperties = <
          item
            DataRow = 1
            DisplayRow = 1
            Row.Height = 20
            Row.VertAlignment = vtaCenter
          end>
      end
      object chkTaxInv: TCheckBox
        Left = 333
        Top = 84
        Width = 140
        Height = 17
        Caption = 'Tax Invoice Available'
        TabOrder = 13
        OnClick = pfEdited
        OnEnter = pfEnter
        OnExit = pfExit
        OnKeyPress = chkTaxInvKeyPress
      end
    end
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 65
    Width = 8
    Height = 373
    Align = alLeft
    BevelOuter = bvNone
    Color = 10050048
    ParentBackground = False
    TabOrder = 2
  end
  object pnlRight: TPanel
    Left = 758
    Top = 65
    Width = 8
    Height = 373
    Align = alRight
    BevelOuter = bvNone
    Color = 10050048
    ParentBackground = False
    TabOrder = 3
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 438
    Width = 766
    Height = 8
    Align = alBottom
    BevelOuter = bvNone
    Color = 10050048
    ParentBackground = False
    TabOrder = 4
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 766
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 5
    DesignSize = (
      766
      41)
    object Label1: TLabel
      Left = 24
      Top = 4
      Width = 34
      Height = 16
      Caption = 'Date'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label7: TLabel
      Left = 80
      Top = 4
      Width = 65
      Height = 16
      Caption = 'Narration'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label8: TLabel
      Left = 570
      Top = 4
      Width = 46
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Payee'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      ExplicitLeft = 436
    end
    object lblDate: TLabel
      Left = 24
      Top = 21
      Width = 49
      Height = 16
      AutoSize = False
      Caption = '29/1/99'
      Transparent = True
    end
    object lblNarrationField: TLabel
      Left = 80
      Top = 21
      Width = 263
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'NARRATION'
      Transparent = True
      ExplicitWidth = 129
    end
    object lblPayeeName: TLabel
      Left = 570
      Top = 21
      Width = 185
      Height = 16
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '0'
      Transparent = True
      ExplicitLeft = 436
    end
    object Label3: TLabel
      Left = 346
      Top = 4
      Width = 73
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Reference'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      ExplicitLeft = 212
    end
    object Label6: TLabel
      Left = 510
      Top = 4
      Width = 41
      Height = 16
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
      ExplicitLeft = 376
    end
    object lblAmount: TLabel
      Left = 446
      Top = 21
      Width = 104
      Height = 16
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '$240.00'
      Transparent = True
      ExplicitLeft = 312
    end
    object lblRef: TLabel
      Left = 346
      Top = 21
      Width = 105
      Height = 16
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'REF'
      Transparent = True
      ExplicitLeft = 212
    end
    object imgCoded: TImage
      Left = 6
      Top = 23
      Width = 12
      Height = 12
      Hint = 'Coded By Accountant'
      AutoSize = True
      ParentShowHint = False
      Picture.Data = {
        07544269746D6170D6000000424DD60000000000000076000000280000000C00
        00000C000000010004000000000060000000C40E0000C40E0000100000000000
        0000000000000000BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00300000000033000030FFFFFFF033000030F44444F033000030FFFFFFF033
        000030F44444F033000030FFFFFFF033000030F44444F033000030FFFFFFF033
        000030F44444F033000030FFFFFFF03300003000000000330000333333333333
        0000}
      ShowHint = True
      Transparent = True
      Visible = False
    end
  end
  object RzFrameController1: TRzFrameController
    FlatButtons = False
    FrameColor = 10050048
    FrameHotStyle = fsFlat
    FrameVisible = True
    FramingPreference = fpCustomFraming
    Left = 24
    Top = 84
  end
  object MaskSet: TtsMaskDefs
    Masks = <
      item
        Name = 'DateMask'
        Picture = '##/##/##'
      end
      item
        Name = 'MoneyMask'
        Picture = '[-]*9[#][.##]'
      end
      item
        Name = 'QtyMask'
        Picture = '[-]*8[#][.*4[#]]'
      end>
    Left = 33
    Top = 128
  end
  object tmrHideHint: TTimer
    Interval = 5000
    OnTimer = tmrHideHintTimer
    Left = 8
    Top = 144
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 3
    Top = 154
    object Copy1: TMenuItem
      Caption = 'Copy                                                Ctrl+C'
      OnClick = Copy1Click
    end
    object Paste1: TMenuItem
      Caption = 'Paste                                               Ctrl+V'
      OnClick = Paste1Click
    end
    object Copycontentsofthecellabove1: TMenuItem
      Caption = 'Copy contents of the cell above     +'
      OnClick = Copycontentsofthecellabove1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object EditSuperFields1: TMenuItem
      Caption = '&Edit Superfund Details'
      OnClick = EditSuperFields1Click
    end
  end
end
