object frmCoding: TfrmCoding
  Left = 281
  Top = 293
  Anchors = []
  Caption = 'Code Bank Statements'
  ClientHeight = 478
  ClientWidth = 728
  Color = clBtnFace
  ParentFont = True
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Scaled = False
  Visible = True
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnResize = FormResize
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object barCodingStatus: TStatusBar
    Left = 0
    Top = 454
    Width = 728
    Height = 24
    AutoHint = True
    Panels = <
      item
        Alignment = taCenter
        Text = 'x'
        Width = 150
      end
      item
        Text = 'X of XXX'
        Width = 85
      end
      item
        Alignment = taCenter
        Text = 'XXX%'
        Width = 70
      end
      item
        Text = 'XXX - Account Desc'
        Width = 350
      end
      item
        Text = 'Gst  X | $XX.XX'
        Width = 135
      end
      item
        Text = 'Closing Balance $XX.XX'
        Width = 235
      end>
    ParentFont = True
    ParentShowHint = False
    ShowHint = True
    SizeGrip = False
    UseSystemFont = False
    OnClick = barCodingStatusClick
    OnMouseUp = barCodingStatusMouseUp
  end
  object tblCoding: TOvcTable
    Left = 0
    Top = 63
    Width = 728
    Height = 301
    RowLimit = 2
    LockedCols = 0
    LeftCol = 0
    ActiveCol = 0
    Align = alClient
    BorderStyle = bsNone
    Color = clWindow
    Colors.ActiveUnfocused = clBtnFace
    Colors.ActiveUnfocusedText = clWindowText
    Colors.Locked = clGray
    Colors.LockedText = clWhite
    Colors.Editing = clWindow
    Controller = cntController
    Ctl3D = False
    GridPenSet.NormalGrid.NormalColor = clSilver
    GridPenSet.NormalGrid.Style = psSolid
    GridPenSet.NormalGrid.Effect = geVertical
    GridPenSet.LockedGrid.NormalColor = clBtnShadow
    GridPenSet.LockedGrid.Style = psSolid
    GridPenSet.LockedGrid.Effect = ge3D
    GridPenSet.CellWhenFocused.NormalColor = clBlack
    GridPenSet.CellWhenFocused.Style = psSolid
    GridPenSet.CellWhenFocused.Effect = geBoth
    GridPenSet.CellWhenUnfocused.NormalColor = clWindowText
    GridPenSet.CellWhenUnfocused.Style = psSolid
    GridPenSet.CellWhenUnfocused.Effect = geBoth
    LockedRowsCell = hdrColumnHeadings
    Options = [otoTabToArrow, otoEnterToArrow, otoNoSelection]
    ParentCtl3D = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    OnActiveCellChanged = tblCodingActiveCellChanged
    OnDblClick = tblCodingDblClick
    OnEnter = tblCodingEnter
    OnExit = tblCodingExit
    OnKeyDown = tblCodingKeyDown
    OnKeyPress = tblCodingKeyPress
    OnKeyUp = tblCodingKeyUp
    OnMouseUp = tblCodingMouseUp
    OnMouseWheel = BkMouseWheelHandler
    OnTopLeftCellChanged = tblCodingTopLeftCellChanged
    CellData = (
      'frmCoding.hdrColumnHeadings')
    RowData = (
      28)
    ColData = (
      32
      False
      False)
  end
  object pfHiddenAmount: TOvcPictureField
    Left = 672
    Top = 400
    Width = 89
    Height = 21
    Cursor = crIBeam
    DataType = pftDouble
    CaretOvr.Shape = csBlock
    Controller = cntController
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
    MaxLength = 12
    Options = []
    PictureMask = '#########.##'
    TabOrder = 2
    Visible = False
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object RzSizePanel1: TRzSizePanel
    Left = 0
    Top = 364
    Width = 728
    Height = 90
    Align = alBottom
    HotSpotSizePercent = 10
    HotSpotVisible = True
    ShowDockClientCaptions = False
    SizeBarStyle = ssBump
    SizeBarWidth = 9
    TabOrder = 3
    VisualStyle = vsGradient
    OnResize = RzSizePanel1Resize
    object pnlNotes: TPanel
      Left = 0
      Top = 10
      Width = 728
      Height = 80
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      OnEnter = pnlNotesEnter
      OnExit = pnlNotesExit
      object Panel2: TPanel
        Left = 21
        Top = 0
        Width = 707
        Height = 80
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel2'
        TabOrder = 0
        object memImportNotes: TMemo
          Left = 0
          Top = 0
          Width = 707
          Height = 41
          TabStop = False
          Align = alTop
          Ctl3D = False
          ParentCtl3D = False
          PopupMenu = popNotes
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          OnKeyUp = memImportNotesKeyUp
        end
        object memNotes: TMemo
          Left = 0
          Top = 41
          Width = 707
          Height = 39
          Align = alClient
          Ctl3D = False
          Lines.Strings = (
            '')
          ParentCtl3D = False
          PopupMenu = popNotes
          ScrollBars = ssVertical
          TabOrder = 1
          OnChange = memNotesChange
          OnExit = memNotesExit
          OnKeyUp = memImportNotesKeyUp
        end
      end
      object pnlNotesTitle: TPanel
        Left = 0
        Top = 0
        Width = 21
        Height = 80
        Align = alLeft
        BevelOuter = bvNone
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 1
        object rzPinBtn: TRzBmpButton
          Left = 1
          Top = 3
          Width = 18
          Height = 18
          Hint = 'Click Pin to Keep Visible'
          Bitmaps.Down.Data = {
            06050000424D060500000000000036040000280000000E0000000D0000000100
            080000000000D0000000C40E0000C40E00000001000000000000000000000000
            80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
            A6000020400000206000002080000020A0000020C0000020E000004000000040
            20000040400000406000004080000040A0000040C0000040E000006000000060
            20000060400000606000006080000060A0000060C0000060E000008000000080
            20000080400000806000008080000080A0000080C0000080E00000A0000000A0
            200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
            200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
            200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
            20004000400040006000400080004000A0004000C0004000E000402000004020
            20004020400040206000402080004020A0004020C0004020E000404000004040
            20004040400040406000404080004040A0004040C0004040E000406000004060
            20004060400040606000406080004060A0004060C0004060E000408000004080
            20004080400040806000408080004080A0004080C0004080E00040A0000040A0
            200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
            200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
            200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
            20008000400080006000800080008000A0008000C0008000E000802000008020
            20008020400080206000802080008020A0008020C0008020E000804000008040
            20008040400080406000804080008040A0008040C0008040E000806000008060
            20008060400080606000806080008060A0008060C0008060E000808000008080
            20008080400080806000808080008080A0008080C0008080E00080A0000080A0
            200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
            200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
            200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
            2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
            2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
            2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
            2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
            2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
            2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
            2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00F9F9F9F9F9F9
            F9F9F9F9F9F9F9F90000F9F9F9F9F9F9F9F9F9F9F9F9F9F90000F9F9F900F9F9
            F9F9F9F9F9F9F9F90000F9F9F9F9000000000000F9F9F9F90000F9F9F9F90000
            A4A4000000F9F9F90000F9F9F9F900A4A4A4A4000000F9F90000F9F9F9F900A4
            FFFB00000000F9F90000F9F9F9F900FFFB00A4A4A40000F90000F9F9F9F900FB
            FF00FBFFA4A400F90000F9F9F9F9F900FB00FFFBFFA400F90000F9F9F9F9F9F9
            0000FBFFFBA400F90000F9F9F9F9F9F9F9F900000000F9F90000F9F9F9F9F9F9
            F9F9F9F9F9F9F9F90000}
          Bitmaps.TransparentColor = clRed
          Bitmaps.Up.Data = {
            36050000424D3605000000000000360400002800000010000000100000000100
            08000000000000010000C40E0000C40E00000001000000000000000000000000
            80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
            A6000020400000206000002080000020A0000020C0000020E000004000000040
            20000040400000406000004080000040A0000040C0000040E000006000000060
            20000060400000606000006080000060A0000060C0000060E000008000000080
            20000080400000806000008080000080A0000080C0000080E00000A0000000A0
            200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
            200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
            200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
            20004000400040006000400080004000A0004000C0004000E000402000004020
            20004020400040206000402080004020A0004020C0004020E000404000004040
            20004040400040406000404080004040A0004040C0004040E000406000004060
            20004060400040606000406080004060A0004060C0004060E000408000004080
            20004080400040806000408080004080A0004080C0004080E00040A0000040A0
            200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
            200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
            200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
            20008000400080006000800080008000A0008000C0008000E000802000008020
            20008020400080206000802080008020A0008020C0008020E000804000008040
            20008040400080406000804080008040A0008040C0008040E000806000008060
            20008060400080606000806080008060A0008060C0008060E000808000008080
            20008080400080806000808080008080A0008080C0008080E00080A0000080A0
            200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
            200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
            200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
            2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
            2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
            2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
            2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
            2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
            2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
            2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00F9F9F9F9F9F9
            F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9
            F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9
            F900F9F9F9F9F9F9F9F9F9F9F9F9F9F9F90000F9F9F90000F9F9F9F9F9F9F9F9
            F900A4000000A400F9F9F9F9F9F9F9F9F900FB00A400FB00F9F9F9F9F9000000
            0000FFFBFFA4FF00F9F9F9F9F9F9F9F9F900FBFFFBFBFB00F9F9F9F9F9F9F9F9
            F900FF000000FF00F9F9F9F9F9F9F9F9F90000F9F9F90000F9F9F9F9F9F9F9F9
            F900F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9
            F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9F9}
          Color = clBtnFace
          ButtonBorder = bbButton
          ButtonSize = bszNeither
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          TabStop = False
          Visible = False
          OnClick = rzPinBtnClick
        end
        object rzXBtn: TRzBmpButton
          Left = 2
          Top = 3
          Width = 18
          Height = 18
          Hint = 'Click to Close'
          Bitmaps.TransparentColor = clRed
          Bitmaps.Up.Data = {
            E6000000424DE6000000000000007600000028000000100000000E0000000100
            04000000000070000000C40E0000C40E00001000000000000000000000000000
            8000008000000080800080000000800080008080000080808000C0C0C0000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00999999999999
            9999999999999999999999999999999999999999999999999999999900999900
            9999999990099009999999999900009999999999999009999999999999000099
            9999999990099009999999990099990099999999999999999999999999999999
            99999999999999999999}
          Color = clBtnFace
          ButtonBorder = bbButton
          ButtonSize = bszNeither
          ButtonStyle = bsNew
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          TabStop = False
          OnClick = rzXBtnClick
        end
      end
    end
  end
  object pnlExtraTitleBar: TRzPanel
    Left = 0
    Top = 0
    Width = 728
    Height = 41
    Align = alTop
    BorderSides = []
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    GradientColorStyle = gcsCustom
    GradientColorStop = 10525952
    ParentFont = False
    TabOrder = 4
    VisualStyle = vsGradient
    object lblAcctDetails: TLabel
      Left = 3
      Top = 1
      Width = 244
      Height = 21
      Caption = 'Bank Account Number and Name'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ShowAccelChar = False
      Transparent = True
    end
    object lblTransRange: TLabel
      Left = 4
      Top = 25
      Width = 237
      Height = 16
      AutoSize = False
      Caption = 'Coding Range 1/1/90 - 12/12/99'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
    end
    object lblFinalised: TLabel
      Left = 237
      Top = 25
      Width = 83
      Height = 14
      Caption = ' | FINALISED '
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsBold, fsItalic]
      ParentColor = False
      ParentFont = False
      Transparent = True
      Visible = False
    end
    object imgRight: TImage
      Left = 495
      Top = 0
      Width = 233
      Height = 41
      Align = alRight
      Anchors = [akTop, akRight]
      AutoSize = True
      Center = True
      Transparent = True
      ExplicitLeft = 0
      ExplicitHeight = 43
    end
  end
  object pnlSearch: TPanel
    Left = 0
    Top = 41
    Width = 728
    Height = 22
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 5
    object Label1: TLabel
      AlignWithMargins = True
      Left = 31
      Top = 2
      Width = 20
      Height = 13
      Margins.Left = 9
      Margins.Top = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'Find'
      Layout = tlCenter
    end
    object tbtnClose: TRzToolButton
      Left = 2
      Top = 2
      Width = 20
      Height = 18
      GradientColorStyle = gcsCustom
      ImageIndex = 0
      Images = AppImages.ToolBtn
      UseToolbarButtonSize = False
      UseToolbarVisualStyle = False
      VisualStyle = vsGradient
      Align = alLeft
      Caption = 'Show Legend'
      OnClick = tbtnCloseClick
      ExplicitHeight = 19
    end
    object lblRecommendedMemorisations: TLabel
      Left = 312
      Top = 4
      Width = 141
      Height = 13
      Cursor = crHandPoint
      Caption = 'Recommended Memorisations'
      Visible = False
      OnClick = lblRecommendedMemorisationsClick
    end
    object EBFind: TEdit
      AlignWithMargins = True
      Left = 57
      Top = 2
      Width = 161
      Height = 18
      Margins.Top = 0
      Margins.Bottom = 0
      Align = alLeft
      AutoSize = False
      MaxLength = 12
      TabOrder = 0
      OnChange = EBFindChange
      OnKeyPress = EBFindKeyPress
    end
    object btnFind: TButton
      AlignWithMargins = True
      Left = 224
      Top = 2
      Width = 75
      Height = 18
      Margins.Top = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'Clear'
      Enabled = False
      TabOrder = 1
      OnClick = btnFindClick
    end
  end
  object cntController: TOvcController
    EntryCommands.TableList = (
      'Grid'
      True
      (
        113
        0))
    Epoch = 1900
    Left = 26
    Top = 160
  end
  object celStatus: TOvcTCBitMap
    Table = tblCoding
    Left = 48
    Top = 217
  end
  object celDate: TOvcTCString
    Access = otxReadOnly
    MaxLength = 8
    Table = tblCoding
    UseASCIIZStrings = True
    Left = 112
    Top = 217
  end
  object celRef: TOvcTCString
    Access = otxReadOnly
    MaxLength = 12
    Table = tblCoding
    UseASCIIZStrings = True
    OnOwnerDraw = celRefOwnerDraw
    Left = 144
    Top = 217
  end
  object celAnalysis: TOvcTCString
    Access = otxReadOnly
    MaxLength = 100
    Table = tblCoding
    OnChange = celAnalysisChange
    Left = 176
    Top = 217
  end
  object celAmount: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterRight
    Table = tblCoding
    UseASCIIZStrings = True
    OnExit = celAmountExit
    OnOwnerDraw = celAmountOwnerDraw
    Left = 240
    Top = 217
  end
  object celEntryType: TOvcTCString
    Access = otxReadOnly
    Table = tblCoding
    UseASCIIZStrings = True
    Left = 464
    Top = 217
  end
  object celBSDate: TOvcTCString
    Access = otxReadOnly
    Table = tblCoding
    UseASCIIZStrings = True
    Left = 496
    Top = 217
  end
  object celCoded: TOvcTCString
    Access = otxReadOnly
    Table = tblCoding
    Left = 528
    Top = 217
  end
  object celPayee: TOvcTCNumericField
    Adjust = otaCenterLeft
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd, efoTrimBlanks]
    PictureMask = '999999'
    ShowHint = True
    Table = tblCoding
    OnKeyDown = celPayeeKeyDown
    OnOwnerDraw = celPayeeOwnerDraw
    Left = 432
    Top = 257
    RangeHigh = {3F420F00000000000000}
    RangeLow = {00000000000000000000}
  end
  object celGstAmt: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '#########.##'
    ShowHint = True
    Table = tblCoding
    OnChange = celGstAmtChange
    OnKeyPress = celGstAmtKeyPress
    OnOwnerDraw = celGstAmtOwnerDraw
    Left = 400
    Top = 257
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celQuantity: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '#########.####'
    ShowHint = True
    Table = tblCoding
    OnChange = celQuantityChange
    OnExit = celQuantityExit
    Left = 336
    Top = 257
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celPart: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 12
    ShowHint = True
    Table = tblCoding
    Left = 304
    Top = 257
  end
  object celNarration: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 200
    ShowHint = True
    Table = tblCoding
    UseASCIIZStrings = True
    Left = 304
    Top = 165
  end
  object celOther: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 20
    ShowHint = True
    Table = tblCoding
    Left = 272
    Top = 257
  end
  object celAccount: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 10
    ShowHint = True
    Table = tblCoding
    OnExit = celAccountExit
    OnKeyDown = celAccountKeyDown
    OnKeyPress = celAccountKeyPress
    OnKeyUp = celAccountKeyUp
    OnOwnerDraw = celAccountOwnerDraw
    Left = 208
    Top = 257
  end
  object hdrColumnHeadings: TOvcTCColHead
    Headings.Strings = (
      'S')
    ShowLetters = False
    Table = tblCoding
    OnClick = hdrColumnHeadingsClick
    Left = 64
    Top = 162
  end
  object popGST: TPopupMenu
    Left = 160
    Top = 88
    object mniRecalcGST: TMenuItem
      Caption = '&Recalculate GST'
      OnClick = mniRecalcGSTClick
    end
  end
  object popTransfer: TPopupMenu
    Left = 160
    Top = 120
    object mniSetTransferFlags: TMenuItem
      Caption = '&Set Transfer Flags'
      OnClick = mniSetTransferFlagsClick
    end
    object mniClearTransferFlags: TMenuItem
      Caption = '&Clear Transfer Flags'
      OnClick = mniClearTransferFlagsClick
    end
  end
  object popCoding: TPopupMenu
    Images = AppImages.Coding
    OnPopup = popCodingPopup
    Left = 160
    Top = 152
  end
  object celGSTCode: TOvcTCString
    MaxLength = 3
    ShowHint = True
    Table = tblCoding
    OnKeyDown = celGSTCodeKeyDown
    OnOwnerDraw = celGSTCodeOwnerDraw
    Left = 368
    Top = 257
  end
  object popNotes: TPopupMenu
    Left = 608
    Top = 295
    object pmiNotesUndo: TMenuItem
      Action = EditUndo1
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object pmiNotesCut: TMenuItem
      Action = EditCut1
    end
    object pmiNotesCopy: TMenuItem
      Action = EditCopy1
    end
    object pmiNotesPaste: TMenuItem
      Action = EditPaste1
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object pmiNotesSelectAll: TMenuItem
      Action = EditSelectAll1
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object pmiNotesVisible: TMenuItem
      Caption = 'Notes Always Visible'
      Checked = True
      ShortCut = 16462
      OnClick = pmiNotesVisibleClick
    end
    object mniReset: TMenuItem
      Caption = 'Reset'
      OnClick = mniResetClick
    end
    object N100: TMenuItem
      Caption = '-'
    end
    object pmiGotoGrid: TMenuItem
      Caption = 'Return to Grid'
      ShortCut = 16450
      OnClick = pmiGotoGridClick
    end
  end
  object ActionList1: TActionList
    Left = 656
    Top = 271
    object EditCopy1: TEditCopy
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy'
      ImageIndex = 1
      ShortCut = 16451
    end
    object EditCut1: TEditCut
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut'
      ImageIndex = 0
      ShortCut = 16472
    end
    object EditPaste1: TEditPaste
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste'
      ImageIndex = 2
      ShortCut = 16470
    end
    object EditSelectAll1: TEditSelectAll
      Category = 'Edit'
      Caption = 'Select &All'
    end
    object EditUndo1: TEditUndo
      Category = 'Edit'
      Caption = '&Undo'
      ImageIndex = 3
      ShortCut = 16474
    end
  end
  object celStatementDetails: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 200
    ShowHint = True
    Table = tblCoding
    UseASCIIZStrings = True
    Left = 304
    Top = 197
  end
  object celTaxInv: TOvcTCCheckBox
    Adjust = otaCenter
    CellGlyphs.IsDefault = False
    CellGlyphs.BitMap.Data = {
      36070000424D360700000000000036000000280000002A0000000E0000000100
      1800000000000007000000000000000000000000000000000000FF00FFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00FFFFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFFFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFF008000008000FFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFF008000008000008000008000FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFF008000008000008000008000008000008000FFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFF008000008000FFFFFFFFFFFF008000008000008000FF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFF008000FFFFFFFFFFFFFFFFFFFFFFFF00800000800000
      8000FFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00800000
      8000008000FFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00
      8000008000FFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFF008000FFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000
      00FFFFFF000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFF000000FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00FFFFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFFFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000}
    CellGlyphs.GlyphCount = 3
    CellGlyphs.ActiveGlyphCount = 2
    Table = tblCoding
    OnKeyUp = celTaxInvKeyUp
    OnMouseUp = celTaxInvMouseUp
    Left = 564
    Top = 218
  end
  object celBalance: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterRight
    Table = tblCoding
    UseASCIIZStrings = True
    OnOwnerDraw = celBalanceOwnerDraw
    Left = 600
    Top = 217
  end
  object dlgSaveCLS: TSaveDialog
    FileName = '*.cls'
    Filter = 'Coding Layout Settings (*.cls)|*.cls'
    Left = 36
    Top = 304
  end
  object dlgLoadCLS: TOpenDialog
    FileName = '*.cls'
    Filter = 'Coding Layout Settings (*.cls)|*.cls'
    Left = 4
    Top = 304
  end
  object celDescription: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 10
    ShowHint = True
    Table = tblCoding
    Left = 240
    Top = 257
  end
  object popReference: TPopupMenu
    Left = 192
    Top = 88
    object SortbyChequeNumber1: TMenuItem
      Caption = 'Sort by Cheque Number'
      OnClick = SortbyChequeNumber1Click
    end
    object SortbyReference1: TMenuItem
      Caption = 'Sort by Reference'
      OnClick = SortbyReference1Click
    end
  end
  object celPayeeName: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 10
    ShowHint = True
    Table = tblCoding
    OnOwnerDraw = celPayeeNameOwnerDraw
    Left = 432
    Top = 289
  end
  object celDocument: TOvcTCString
    Adjust = otaCenterLeft
    ShowHint = True
    Table = tblCoding
    UseASCIIZStrings = True
    OnOwnerDraw = celDocumentOwnerDraw
    Left = 639
    Top = 218
  end
  object celEditDate: TOvcTCPictureField
    DataType = pftDate
    PictureMask = 'dd/mm/yy'
    MaxLength = 8
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Epoch = 1970
    Options = [efoForceOvertype]
    Table = tblCoding
    OnOwnerDraw = celEditDateOwnerDraw
    Left = 120
    Top = 264
    RangeHigh = {25600D00000000000000}
    RangeLow = {00000000000000000000}
  end
  object tmrPayee: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrPayeeTimer
    Left = 472
    Top = 112
  end
  object CelJob: TOvcTCString
    MaxLength = 8
    ShowHint = True
    Table = tblCoding
    OnKeyDown = CelJobKeyDown
    OnOwnerDraw = CelJobOwnerDraw
    Left = 488
    Top = 289
  end
  object CelJobName: TOvcTCString
    MaxLength = 8
    ShowHint = True
    Table = tblCoding
    OnOwnerDraw = CelJobOwnerDraw
    Left = 528
    Top = 290
  end
  object CelAction: TOvcTCString
    ShowHint = True
    Table = tblCoding
    Left = 568
    Top = 290
  end
  object celForexAmount: TOvcTCString
    Table = tblCoding
    OnOwnerDraw = celForexAmountOwnerDraw
    Left = 656
    Top = 48
  end
  object celForexRate: TOvcTCNumericField
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '####.####'
    Table = tblCoding
    Left = 624
    Top = 48
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {00000000000000000000}
  end
  object celLocalCurrencyAmount: TOvcTCNumericField
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '########.##'
    Table = tblCoding
    OnChange = celLocalCurrencyAmountChange
    OnExit = celAmountExit
    OnOwnerDraw = celLocalCurrencyAmountOwnerDraw
    Left = 624
    Top = 88
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object SearchTimer: TTimer
    Enabled = False
    OnTimer = SearchTimerTimer
    Left = 344
    Top = 96
  end
  object CelAltCode: TOvcTCString
    Access = otxReadOnly
    MaxLength = 100
    Table = tblCoding
    Left = 608
    Top = 257
  end
  object popFind: TPopupMenu
    Left = 192
    Top = 120
    object miFind: TMenuItem
      Caption = 'Find'
      OnClick = miFindClick
    end
    object miSearch: TMenuItem
      Caption = 'Search'
      Checked = True
      OnClick = miSearchClick
    end
  end
  object celTransferedToOnline: TOvcTCCheckBox
    Access = otxReadOnly
    Adjust = otaCenter
    CellGlyphs.IsDefault = False
    CellGlyphs.BitMap.Data = {
      36070000424D360700000000000036000000280000002A0000000E0000000100
      1800000000000007000000000000000000000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFDBE8DA7986787F8E7FE6F1E5FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFDFFFDFCFFFC6AA6704A855046834C6AA370E3F3E3FFFFFFFE
      FFFEFFFFFFFFFFFFFFFFFFFFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFDCEADB4C9E546DC17565BA6E3E8E467E937EE7ECE6FF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFEFFFED9F2DB7BB47F76C47E7ECD867BCA836BB8734B84516FA374E1
      F1E1FEFFFEFFFFFFFFFFFFFFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFDBEADA89B58C5BB0657BCD846ABC736BBD747ACC826ABE733D91457D
      997EFFFFFFFFFFFFFFFFFFFFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFB8CEB77099727BCD8475AE79CBE1CBCBE1CB77B17B7EC9856FBE774D
      82527D997EFFFFFFFEFFFEFFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFAFFFAD4EFD690C895E0F3E0FBFFFBF8FFF8CBE1CB7EB88375B47A81
      CC894F825379A07CDDEEDFFFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFDFCFDE9ECE9FFFFFFFFFFFFFFFFFFFFFFFFCADFCA8CAD8B72
      B87873C57C3E954777A37BE1E7E0000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFEFFFEFFFFFFFFFFFFFFFFFFFFFFFFF8FFF8CAE1CA7F
      BA8385CF8C72C57B517E5495A795000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFCA
      E0CA78BB7D71C97A73AA7697B696000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8
      FFF8CBE1CB66AF6E99C79CDDEFDD000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFCBE1CBE4ECE4FFFFFF000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
      C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000FFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000}
    CellGlyphs.GlyphCount = 3
    CellGlyphs.ActiveGlyphCount = 2
    Table = tblCoding
    Left = 372
    Top = 314
  end
  object celCoreTransactionId: TOvcTCString
    Access = otxReadOnly
    Adjust = otaCenterLeft
    MaxLength = 30
    ShowHint = True
    Table = tblCoding
    Left = 336
    Top = 313
  end
end
