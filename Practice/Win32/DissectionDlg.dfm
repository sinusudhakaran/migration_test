object dlgDissection: TdlgDissection
  Left = 348
  Top = 289
  ActiveControl = tblDissect
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Dissect a Transaction'
  ClientHeight = 747
  ClientWidth = 956
  Color = clBtnFace
  Constraints.MinHeight = 420
  Constraints.MinWidth = 630
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnResize = FormResize
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object Shape4: TShape
    AlignWithMargins = True
    Left = 953
    Top = 142
    Width = 0
    Height = 432
    Margins.Left = 0
    Margins.Top = 0
    Margins.Bottom = 0
    Align = alRight
    Pen.Color = clSilver
    ExplicitLeft = 952
    ExplicitTop = 140
    ExplicitHeight = 434
  end
  object Shape9: TShape
    Left = 3
    Top = 142
    Width = 1
    Height = 432
    Align = alLeft
    Pen.Color = clSilver
    ExplicitLeft = 0
    ExplicitTop = 137
    ExplicitHeight = 440
  end
  object Shape11: TShape
    Left = 952
    Top = 142
    Width = 1
    Height = 432
    Align = alRight
    Pen.Color = clSilver
    ExplicitLeft = 891
    ExplicitTop = 0
    ExplicitHeight = 36
  end
  object Shape12: TShape
    AlignWithMargins = True
    Left = 3
    Top = 142
    Width = 0
    Height = 432
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alLeft
    Pen.Color = clSilver
    ExplicitTop = 140
    ExplicitHeight = 434
  end
  object pnlTotals: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 664
    Width = 950
    Height = 60
    Margins.Top = 0
    Margins.Bottom = 0
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 5
    DesignSize = (
      950
      60)
    object lblForBSTotal: TLabel
      Left = 8
      Top = 6
      Width = 107
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Total :'
      ExplicitTop = 647
    end
    object lblBSTotal: TLabel
      Left = 121
      Top = 6
      Width = 97
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = '$0.00'
      ExplicitTop = 647
    end
    object lblForBSRemaining: TLabel
      Left = 9
      Top = 30
      Width = 106
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Remaining :'
      ExplicitTop = 669
    end
    object lblBSRemaining: TLabel
      Left = 121
      Top = 30
      Width = 97
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = '$0.00'
      ExplicitTop = 669
    end
    object Label2: TLabel
      Left = 667
      Top = 6
      Width = 29
      Height = 16
      Anchors = [akLeft, akBottom]
      Caption = 'GST:'
    end
    object lblGSTAmt: TLabel
      Left = 702
      Top = 6
      Width = 89
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = '$0.00'
    end
    object Label8: TLabel
      Left = 287
      Top = 6
      Width = 54
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      Caption = 'Total % :'
      ExplicitTop = 647
    end
    object lblPercentTotal: TLabel
      Left = 347
      Top = 6
      Width = 64
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = '0.0000'
    end
    object Label10: TLabel
      Left = 256
      Top = 30
      Width = 85
      Height = 16
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      Caption = 'Remaining % :'
      ExplicitTop = 669
    end
    object lblPercentRemain: TLabel
      Left = 347
      Top = 30
      Width = 64
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = '0.0000'
    end
    object lblLCTotalField: TLabel
      Left = 539
      Top = 6
      Width = 89
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = '$0.00'
    end
    object lblLCTotal: TLabel
      Left = 426
      Top = 6
      Width = 107
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Total :'
    end
    object lblLCRemaining: TLabel
      Left = 426
      Top = 30
      Width = 107
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = 'Remaining :'
    end
    object lblLCRemainingField: TLabel
      Left = 539
      Top = 30
      Width = 89
      Height = 18
      Alignment = taRightJustify
      Anchors = [akLeft, akBottom]
      AutoSize = False
      Caption = '$0.00'
    end
    object Bevel2: TBevel
      Left = 224
      Top = 6
      Width = 3
      Height = 50
      Anchors = [akLeft, akBottom]
      Shape = bsLeftLine
    end
    object Bevel3: TBevel
      Left = 417
      Top = 6
      Width = 3
      Height = 50
      Anchors = [akLeft, akBottom]
      Shape = bsLeftLine
    end
    object Bevel4: TBevel
      Left = 634
      Top = 6
      Width = 3
      Height = 50
      Anchors = [akLeft, akBottom]
      Shape = bsLeftLine
    end
    object Shape15: TShape
      Left = 0
      Top = 0
      Width = 1
      Height = 60
      Margins.Left = 0
      Margins.Bottom = 0
      Align = alLeft
      Pen.Color = clSilver
      ExplicitHeight = 57
    end
    object Shape16: TShape
      Left = 949
      Top = 0
      Width = 1
      Height = 60
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 891
      ExplicitTop = 1
      ExplicitHeight = 99
    end
    object btnOK: TButton
      Left = 782
      Top = 27
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 863
      Top = 27
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object stbDissect: TStatusBar
    AlignWithMargins = True
    Left = 3
    Top = 724
    Width = 950
    Height = 20
    Margins.Top = 0
    Panels = <
      item
        Alignment = taCenter
        Text = 'C'
        Width = 220
      end
      item
        Text = '1 of 100'
        Width = 75
      end
      item
        Text = '309 - Bank Charges'
        Width = 200
      end>
    ParentFont = True
    UseSystemFont = False
    OnMouseUp = stbDissectMouseUp
    ExplicitLeft = 0
    ExplicitTop = 727
    ExplicitWidth = 956
  end
  object tblDissect: TOvcTable
    AlignWithMargins = True
    Left = 4
    Top = 142
    Width = 948
    Height = 432
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
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
    Controller = DissectController
    GridPenSet.NormalGrid.NormalColor = clBtnShadow
    GridPenSet.NormalGrid.Style = psSolid
    GridPenSet.NormalGrid.Effect = geVertical
    GridPenSet.LockedGrid.NormalColor = clBtnShadow
    GridPenSet.LockedGrid.Style = psSolid
    GridPenSet.LockedGrid.Effect = ge3D
    GridPenSet.CellWhenFocused.NormalColor = clBlack
    GridPenSet.CellWhenFocused.Style = psSolid
    GridPenSet.CellWhenFocused.Effect = geNone
    GridPenSet.CellWhenUnfocused.NormalColor = clWindowText
    GridPenSet.CellWhenUnfocused.Style = psSolid
    GridPenSet.CellWhenUnfocused.Effect = geBoth
    LockedRowsCell = hdrColumnHeadings
    Options = [otoEnterToArrow, otoNoSelection, otoThumbTrack]
    ParentShowHint = False
    ShowHint = False
    TabOrder = 1
    OnDblClick = tblDissectDblClick
    OnEnter = tblDissectEnter
    OnExit = tblDissectExit
    OnKeyDown = tblDissectKeyDown
    OnMouseDown = tblDissectMouseDown
    OnMouseUp = tblDissectMouseUp
    OnTopLeftCellChanging = tblDissectTopLeftCellChanging
    ExplicitLeft = 5
    CellData = (
      'dlgDissection.hdrColumnHeadings')
    RowData = (
      23)
    ColData = (
      65
      False
      False)
  end
  object pnlTranDetails: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 950
    Height = 139
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    OnResize = pnlTranDetailsResize
    DesignSize = (
      950
      139)
    object Shape1: TShape
      Left = 3
      Top = 24
      Width = 944
      Height = 32
      Anchors = [akLeft, akTop, akRight]
      Brush.Color = clWindow
      Shape = stRoundRect
      ExplicitWidth = 616
    end
    object Label1: TLabel
      Left = 30
      Top = 5
      Width = 26
      Height = 16
      Caption = 'Date'
      Transparent = True
    end
    object Label3: TLabel
      Left = 88
      Top = 5
      Width = 58
      Height = 16
      Caption = 'Reference'
      Transparent = True
    end
    object lblForBSAmount: TLabel
      Left = 313
      Top = 5
      Width = 32
      Height = 16
      Alignment = taRightJustify
      Caption = 'Value'
      Transparent = True
    end
    object lblAnalysis: TLabel
      Left = 184
      Top = 5
      Width = 46
      Height = 16
      Caption = 'Analysis'
      Transparent = True
    end
    object lblNarration: TLabel
      Left = 569
      Top = 5
      Width = 53
      Height = 16
      Caption = 'Narration'
    end
    object Label7: TLabel
      Left = 904
      Top = 4
      Width = 34
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Payee'
      ExplicitLeft = 883
    end
    object lblDate: TLabel
      Left = 32
      Top = 32
      Width = 54
      Height = 16
      AutoSize = False
      Caption = '29/01/99'
      ShowAccelChar = False
      Transparent = True
    end
    object lblRef: TLabel
      Left = 88
      Top = 32
      Width = 92
      Height = 16
      AutoSize = False
      Caption = 'REF'
      ShowAccelChar = False
      Transparent = True
    end
    object lblAnalysisField: TLabel
      Left = 184
      Top = 32
      Width = 60
      Height = 16
      AutoSize = False
      Caption = 'ANALYSIS'
      ShowAccelChar = False
      Transparent = True
    end
    object lblBSAmount: TLabel
      Left = 243
      Top = 32
      Width = 104
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = '$240.00'
      ShowAccelChar = False
      Transparent = True
    end
    object lblNarrationField: TLabel
      Left = 569
      Top = 32
      Width = 295
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'NARRATION'
      ShowAccelChar = False
      Transparent = True
      ExplicitWidth = 552
    end
    object lblPayee: TLabel
      Left = 895
      Top = 32
      Width = 48
      Height = 16
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      ShowAccelChar = False
      Transparent = True
      ExplicitLeft = 567
    end
    object imgStatus: TImage
      Left = 8
      Top = 29
      Width = 20
      Height = 20
      Center = True
      Transparent = True
    end
    object lbltxECodingNotes: TLabel
      Left = 8
      Top = 64
      Width = 932
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'lbltxECodingNotes'
      ParentShowHint = False
      ShowAccelChar = False
      ShowHint = True
      ExplicitWidth = 604
    end
    object lbltxNotes: TLabel
      Left = 7
      Top = 81
      Width = 932
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'lbltxNotes'
      ParentShowHint = False
      ShowAccelChar = False
      ShowHint = True
    end
    object lblLocalCurrencyAmount: TLabel
      Left = 455
      Top = 32
      Width = 92
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = '$240.00'
      ShowAccelChar = False
      Transparent = True
    end
    object lblForLocalCurrencyAmount: TLabel
      Left = 515
      Top = 5
      Width = 32
      Height = 16
      Alignment = taRightJustify
      Caption = 'Value'
      Transparent = True
    end
    object lblRate: TLabel
      Left = 378
      Top = 32
      Width = 71
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = '1.65424'
      ShowAccelChar = False
      Transparent = True
    end
    object lblForRate: TLabel
      Left = 423
      Top = 5
      Width = 26
      Height = 16
      Alignment = taRightJustify
      Caption = 'Rate'
      Transparent = True
    end
    object Shape3: TShape
      Left = 0
      Top = 0
      Width = 950
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 956
    end
    object Shape5: TShape
      Left = 949
      Top = 1
      Width = 1
      Height = 110
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 891
      ExplicitHeight = 99
    end
    object Shape7: TShape
      Left = 0
      Top = 1
      Width = 1
      Height = 110
      Align = alLeft
      Pen.Color = clSilver
      ExplicitHeight = 99
    end
    object pnlHeaderButtons: TPanel
      Left = 0
      Top = 111
      Width = 950
      Height = 28
      Align = alBottom
      Anchors = [akLeft, akTop, akRight]
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        950
        28)
      object btnChart: TSpeedButton
        Left = 9
        Top = 3
        Width = 80
        Height = 22
        Caption = 'Chart'
        Flat = True
        OnClick = btnChartClick
      end
      object btnPayee: TSpeedButton
        Left = 95
        Top = 3
        Width = 80
        Height = 22
        Caption = 'Payee'
        Flat = True
        OnClick = btnPayeeClick
      end
      object lblStatus: TLabel
        Left = 439
        Top = 9
        Width = 68
        Height = 16
        Anchors = [akLeft, akBottom]
        Caption = ' FINALISED '
        Color = clActiveCaption
        ParentColor = False
        Visible = False
        ExplicitTop = 8
      end
      object sbtnSuper: TSpeedButton
        Left = 353
        Top = 3
        Width = 80
        Height = 22
        Caption = 'Super'
        Flat = True
        OnClick = sbtnSuperClick
      end
      object btnView: TRzToolButton
        Left = 267
        Top = 3
        Width = 80
        Height = 22
        DropDownMenu = popView
        ImageIndex = 8
        Images = AppImages.Coding
        ShowCaption = True
        UseToolbarButtonSize = False
        UseToolbarShowCaption = False
        ToolStyle = tsDropDown
        Caption = 'View'
      end
      object btnJob: TSpeedButton
        Left = 181
        Top = 3
        Width = 80
        Height = 22
        Caption = 'Job'
        Flat = True
        OnClick = btnJobClick
      end
      object Shape2: TShape
        Left = 0
        Top = 27
        Width = 950
        Height = 1
        Align = alBottom
        Pen.Color = clSilver
        ExplicitTop = 26
        ExplicitWidth = 956
      end
      object Shape6: TShape
        Left = 949
        Top = 0
        Width = 1
        Height = 27
        Align = alRight
        Pen.Color = clSilver
        ExplicitLeft = 891
        ExplicitHeight = 36
      end
      object Shape8: TShape
        Left = 0
        Top = 0
        Width = 1
        Height = 27
        Align = alLeft
        Pen.Color = clSilver
        ExplicitHeight = 36
      end
    end
  end
  object pfHiddenAmount: TOvcPictureField
    Left = 378
    Top = 189
    Width = 89
    Height = 24
    Cursor = crIBeam
    DataType = pftDouble
    CaretOvr.Shape = csBlock
    Controller = DissectController
    ControlCharColor = clRed
    DecimalPlaces = 0
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Epoch = 0
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    InitDateTime = False
    MaxLength = 16
    Options = []
    ParentFont = False
    PictureMask = '#,###,###,###.##'
    TabOrder = 3
    Visible = False
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object pNotes: TRzSizePanel
    AlignWithMargins = True
    Left = 3
    Top = 574
    Width = 950
    Height = 90
    Margins.Top = 0
    Margins.Bottom = 0
    Align = alBottom
    HotSpotSizePercent = 10
    HotSpotVisible = True
    ShowDockClientCaptions = False
    SizeBarStyle = ssBump
    SizeBarWidth = 9
    TabOrder = 2
    VisualStyle = vsGradient
    OnResize = pNotesResize
    ExplicitLeft = 0
    ExplicitTop = 577
    ExplicitWidth = 956
    object Shape10: TShape
      Left = 0
      Top = 89
      Width = 950
      Height = 1
      Align = alBottom
      Pen.Color = clSilver
      ExplicitTop = 26
      ExplicitWidth = 956
    end
    object Shape13: TShape
      Left = 0
      Top = 10
      Width = 1
      Height = 79
      Align = alLeft
      Pen.Color = clSilver
      ExplicitTop = 137
      ExplicitHeight = 440
    end
    object Shape14: TShape
      Left = 949
      Top = 10
      Width = 1
      Height = 79
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 891
      ExplicitTop = 0
      ExplicitHeight = 36
    end
    object pnlNotes: TPanel
      Left = 1
      Top = 10
      Width = 948
      Height = 79
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      OnEnter = pnlNotesEnter
      OnExit = pnlNotesExit
      ExplicitLeft = 0
      ExplicitWidth = 956
      ExplicitHeight = 80
      object Panel2: TPanel
        Left = 21
        Top = 0
        Width = 927
        Height = 79
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel2'
        TabOrder = 0
        ExplicitWidth = 935
        ExplicitHeight = 80
        object memImportNotes: TMemo
          Left = 0
          Top = 0
          Width = 927
          Height = 41
          TabStop = False
          Align = alTop
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          Ctl3D = False
          ParentCtl3D = False
          PopupMenu = popNotes
          ReadOnly = True
          ScrollBars = ssVertical
          TabOrder = 0
          ExplicitWidth = 935
        end
        object memNotes: TMemo
          Left = 0
          Top = 41
          Width = 927
          Height = 38
          TabStop = False
          Align = alClient
          BevelInner = bvNone
          BevelOuter = bvNone
          BorderStyle = bsNone
          Ctl3D = False
          Lines.Strings = (
            '')
          ParentCtl3D = False
          PopupMenu = popNotes
          ScrollBars = ssVertical
          TabOrder = 1
          OnChange = memNotesChange
        end
      end
      object pnlNotesTitle: TPanel
        Left = 0
        Top = 0
        Width = 21
        Height = 79
        Align = alLeft
        BevelOuter = bvNone
        Ctl3D = False
        ParentCtl3D = False
        TabOrder = 1
        ExplicitHeight = 80
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
  object DissectController: TOvcController
    EntryCommands.TableList = (
      'Grid'
      True
      ())
    Epoch = 1900
    Left = 536
    Top = 152
  end
  object hdrColumnHeadings: TOvcTCColHead
    Headings.Strings = (
      'None')
    ShowLetters = False
    Table = tblDissect
    Left = 160
    Top = 214
  end
  object celAccount: TOvcTCString
    MaxLength = 10
    ShowHint = True
    Table = tblDissect
    OnExit = celAccountExit
    OnKeyDown = celAccountKeyDown
    OnKeyPress = celAccountKeyPress
    OnKeyUp = celAccountKeyUp
    OnOwnerDraw = celAccountOwnerDraw
    Left = 304
    Top = 152
  end
  object celAmount: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '###,###,###.##'
    Table = tblDissect
    OnChange = celAmountChange
    OnKeyPress = celAmountKeyPress
    OnOwnerDraw = celAmountOwnerDraw
    Left = 336
    Top = 152
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
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
    PictureMask = '###,###,###.##'
    Table = tblDissect
    OnChange = celGstAmtChange
    OnKeyPress = celGstAmtKeyPress
    OnOwnerDraw = celGstAmtOwnerDraw
    Left = 400
    Top = 152
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
    PictureMask = '###,###,###.####'
    Table = tblDissect
    OnChange = celQuantityChange
    OnExit = celQuantityExit
    Left = 464
    Top = 152
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celNarration: TOvcTCString
    MaxLength = 200
    Table = tblDissect
    Left = 496
    Top = 152
  end
  object popGST: TPopupMenu
    Left = 152
    Top = 152
    object mniRecalcGST: TMenuItem
      Caption = '&Recalculate GST'
      OnClick = mniRecalcGSTClick
    end
  end
  object celMoneyIn: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '###,###,###.##'
    Table = tblDissect
    Left = 336
    Top = 184
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celMoneyOut: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '###,###,###.##'
    Table = tblDissect
    Left = 336
    Top = 216
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celGSTCode: TOvcTCString
    MaxLength = 3
    OnKeyDown = celGSTCodeKeyDown
    OnOwnerDraw = celGSTCodeOwnerDraw
    Left = 368
    Top = 152
  end
  object celPayee: TOvcTCNumericField
    Adjust = otaCenterLeft
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    PictureMask = '999999'
    ShowHint = True
    OnKeyDown = celPayeeKeyDown
    Left = 432
    Top = 153
    RangeHigh = {3F420F00000000000000}
    RangeLow = {00000000000000000000}
  end
  object ActionList1: TActionList
    Left = 128
    Top = 319
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
    object actConfigure: TAction
      Caption = 'C&onfigure Columns'
      OnExecute = actConfigureExecute
    end
    object actRestore: TAction
      Caption = '&Restore Column Defaults'
      OnExecute = actRestoreExecute
    end
  end
  object popNotes: TPopupMenu
    Left = 160
    Top = 319
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
  object popDissect: TPopupMenu
    Images = AppImages.Coding
    OnPopup = popDissectPopup
    Left = 200
    Top = 160
    object LookupChart1: TMenuItem
      Caption = '&Lookup Chart                                           F2'
      ImageIndex = 0
      OnClick = LookupChart1Click
    end
    object LookupPayee1: TMenuItem
      Caption = 'Lookup &Payee                                          F3'
      ImageIndex = 1
      OnClick = LookupPayee1Click
    end
    object LookupJobF51: TMenuItem
      Caption = 'Lookup &Job                                              F5'
      ImageIndex = 18
      OnClick = btnJobClick
    end
    object LookupGST1: TMenuItem
      Caption = 'Lookup &GST Class                                    F7'
      OnClick = LookupGST1Click
    end
    object EditSuperFields1: TMenuItem
      Caption = 'Edit &Superfund Details                           F11'
      ImageIndex = 11
      OnClick = EditSuperFields1Click
    end
    object ClearSuperfundDetails1: TMenuItem
      Caption = '&Clear Superfund Details '
      OnClick = ClearSuperfundDetails1Click
    end
    object Sep1: TMenuItem
      Caption = '-'
    end
    object GotoNextUncoded1: TMenuItem
      Caption = 'Goto Next &Uncoded                                F8'
      ImageIndex = 5
      OnClick = GotoNextUncoded1Click
    end
    object Gotonextnote1: TMenuItem
      Caption = 'Goto Ne&xt Note                                      F12'
      OnClick = Gotonextnote1Click
    end
    object GotoNotes1: TMenuItem
      Caption = 'Edit &Notes                                              Ctrl+B'
      ImageIndex = 19
      OnClick = GotoNotes1Click
    end
    object Notes1: TMenuItem
      Caption = 'Notes'
      object mniNoteMark: TMenuItem
        Caption = '&Mark Note as Read/Unread    Shift+Ctrl+M'
        ImageIndex = 14
        OnClick = mniNoteMarkClick
      end
      object mniNoteMarkAll: TMenuItem
        Caption = 'Mark &All Notes as Read           Shift+Ctrl+A'
        OnClick = mniNoteMarkAllClick
      end
      object mniNoteDelete: TMenuItem
        Caption = '&Delete Note                             Shift+Ctrl+X'
        ImageIndex = 15
        OnClick = mniNoteDeleteClick
      end
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Configurecolumns1: TMenuItem
      Caption = 'C&onfigure Columns'
      OnClick = actConfigureExecute
    end
    object Restorecolumndefaults1: TMenuItem
      Caption = '&Restore Column Defaults'
      OnClick = actRestoreExecute
    end
    object Sep2: TMenuItem
      Caption = '-'
    end
    object Insertanewline1: TMenuItem
      Caption = 
        '&Insert a New Line                                      Shift+In' +
        's'
      OnClick = Insertanewline1Click
    end
    object CopyContentoftheCellAbove1: TMenuItem
      Caption = 'C&opy Contents of the Cell Above              +'
      ImageIndex = 6
      OnClick = CopyContentoftheCellAbove1Click
    end
    object Amount1: TMenuItem
      Caption = 'Amount'
      object AmountFixed: TMenuItem
        Caption = 'Apply &Fixed Amount                        $'
        OnClick = AmountFixedClick
      end
      object AmountPercentage: TMenuItem
        Caption = 'Apply &Percentage Split                    %'
        OnClick = AmountPercentageClick
      end
      object AmountApplyRemainingAmount1: TMenuItem
        Caption = 'Appl&y Remaining Amount                ='
        OnClick = AmountApplyRemainingAmount1Click
      end
      object AmountGrossupfromGSTAmount1: TMenuItem
        Caption = '&Gross-up from GST Amount            *'
        OnClick = AmountGrossupfromGSTAmount1Click
      end
      object AmountGrossupfromNetAmount1: TMenuItem
        Caption = 'G&ross-up from Net Amount            @'
        OnClick = AmountGrossupfromNetAmount1Click
      end
    end
    object Narration1: TMenuItem
      Caption = 'Narration'
      object NarrationReplacewithNotes1: TMenuItem
        Caption = 'Replace &With Notes             Ctrl+J'
        OnClick = NarrationReplacewithNotes1Click
      end
      object NarrationAppendNotes1: TMenuItem
        Caption = 'App&end Notes                     Shift+Ctrl+J'
        OnClick = NarrationAppendNotes1Click
      end
    end
    object ConvertAmount1: TMenuItem
      Caption = 'Con&vert Amount'
      OnClick = ConvertAmount1Click
    end
  end
  object popView: TPopupMenu
    OnPopup = popViewPopup
    Left = 96
    Top = 184
    object EditAccountOnly1: TMenuItem
      Caption = 'Edit A&ccounts and Amounts Only'
      OnClick = EditAccountOnly1Click
    end
    object EditAllColumns1: TMenuItem
      Caption = 'E&dit All Columns'
      OnClick = EditAllColumns1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object mniConfigureCols: TMenuItem
      Action = actConfigure
      GroupIndex = 3
    end
    object mniRestoreCols: TMenuItem
      Action = actRestore
      GroupIndex = 3
    end
  end
  object celPercent: TOvcTCNumericField
    Adjust = otaCenterRight
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '###,###,###.####'
    Table = tblDissect
    OnKeyPress = celPercentKeyPress
    Left = 448
    Top = 224
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object celAmountType: TOvcTCString
    Access = otxReadOnly
    MaxLength = 200
    Table = tblDissect
    Left = 496
    Top = 216
  end
  object celDescription: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 10
    ShowHint = True
    Left = 240
    Top = 257
  end
  object celPayeeName: TOvcTCString
    Adjust = otaCenterLeft
    MaxLength = 10
    ShowHint = True
    Left = 480
    Top = 193
  end
  object tmrPayee: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmrPayeeTimer
    Left = 248
    Top = 208
  end
  object CelJob: TOvcTCString
    MaxLength = 8
    Table = tblDissect
    Left = 376
    Top = 216
  end
  object CelJobName: TOvcTCString
    MaxLength = 200
    Table = tblDissect
    Left = 408
    Top = 216
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
    Table = tblDissect
    Left = 564
    Top = 218
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
    Table = tblDissect
    Left = 336
    Top = 256
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {00000000000000000000}
  end
  object celLocalAmount: TOvcTCNumericField
    DataType = nftDouble
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = [efoCaretToEnd]
    PictureMask = '##########.##'
    Table = tblDissect
    OnChange = celAmountChange
    OnKeyPress = celLocalAmountKeyPress
    OnOwnerDraw = celLocalAmountOwnerDraw
    Left = 376
    Top = 256
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object CelAltChartCode: TOvcTCString
    MaxLength = 200
    Table = tblDissect
    Left = 496
    Top = 264
  end
end
