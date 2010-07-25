object frmGST101: TfrmGST101
  Left = 450
  Top = 189
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Goods and Services Tax Return'
  ClientHeight = 766
  ClientWidth = 633
  Color = clBtnFace
  Constraints.MaxHeight = 802
  Constraints.MinHeight = 400
  Constraints.MinWidth = 606
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label21: TLabel
    Left = 0
    Top = 680
    Width = 8
    Height = 10
    Caption = '    '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -8
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 685
    Width = 633
    Height = 81
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      633
      81)
    object LblSubmit: TLabel
      Left = 14
      Top = 59
      Width = 32
      Height = 13
      Cursor = crHandPoint
      Anchors = [akLeft, akBottom]
      Caption = 'Submit'
      OnClick = LblSubmitClick
    end
    object chkDraft: TCheckBox
      Left = 12
      Top = 8
      Width = 493
      Height = 17
      Anchors = [akLeft, akBottom]
      Caption = 'Print as Work Paper   (Show Debtors and Creditors)'
      TabOrder = 0
    end
    object btnPreview: TButton
      Left = 10
      Top = 32
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Pre&view'
      TabOrder = 1
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 97
      Top = 32
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      TabOrder = 2
      OnClick = btnFileClick
    end
    object btnPrint: TButton
      Left = 184
      Top = 32
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Print'
      TabOrder = 3
      OnClick = btnPrintClick
    end
    object btnIR372: TButton
      Left = 272
      Top = 31
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'IR&372'
      TabOrder = 4
      OnClick = GST372Action
    end
    object btnOK: TButton
      Left = 462
      Top = 32
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      TabOrder = 5
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 550
      Top = 32
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 6
      OnClick = btnCancelClick
    end
  end
  object pgForm: TPageControl
    Left = 0
    Top = 0
    Width = 633
    Height = 685
    ActivePage = TsPart1B
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object TSPart1: TTabSheet
      Caption = 'Part 1 - GST'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object sbGST: TScrollBox
        Left = 0
        Top = 0
        Width = 625
        Height = 654
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        TabOrder = 0
        object GBGST: TGroupBox
          Left = 0
          Top = 0
          Width = 603
          Height = 650
          Color = clWhite
          Ctl3D = True
          ParentBackground = False
          ParentColor = False
          ParentCtl3D = False
          TabOrder = 0
          object lMain1: TLabel
            Left = 6
            Top = 0
            Width = 227
            Height = 18
            Caption = 'Goods and Services Tax Return'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Image15: TImage
            Left = 442
            Top = 60
            Width = 28
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170C6060000424DC60600000000000036000000280000001C00
              0000140000000100180000000000900600000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000008080808080808080808080808080808080808080808080808080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              8080808080808080808080808080808080808080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000FFFFFF000000000000000000000000000000808080808080808080
              8080808080808080800000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000000000FFFFFFFFFFFF00
              0000000000000000000000000000808080808080808080808080808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
              0000000000808080808080808080808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808080
              8080808080000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
              FFFFFFFF00000000000000000000000080808080808080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
              0000000080808080808080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000008080808080808080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFF0000000000000000008080808080808080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
              8080808080808080800000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
              FFFFFFFFFF000000000000000000000000808080808080808080808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
              0000000000808080808080808080808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFF00000000000000000000000000000080808080808080808080
              8080808080000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFF0000000000000000
              0000000000000080808080808080808080808080808080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000008080808080808080
              8080808080808080808080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080808080}
            Transparent = True
          end
          object Label50: TLabel
            Left = 294
            Top = 42
            Width = 87
            Height = 16
            Caption = 'Period Covered'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
          end
          object Label52: TLabel
            Left = 294
            Top = 62
            Width = 25
            Height = 16
            Caption = 'from'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
          end
          object Label55: TLabel
            Left = 448
            Top = 62
            Width = 6
            Height = 14
            Caption = '2'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object Label24: TLabel
            Left = 506
            Top = 58
            Width = 11
            Height = 16
            Caption = 'to'
          end
          object Label11: TLabel
            Left = 294
            Top = 82
            Width = 167
            Height = 16
            Caption = 'Return and any payment due'
          end
          object Image16: TImage
            Left = 442
            Top = 20
            Width = 28
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170C6060000424DC60600000000000036000000280000001C00
              0000140000000100180000000000900600000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000008080808080808080808080808080808080808080808080808080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              8080808080808080808080808080808080808080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000FFFFFF000000000000000000000000000000808080808080808080
              8080808080808080800000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000000000FFFFFFFFFFFF00
              0000000000000000000000000000808080808080808080808080808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
              0000000000808080808080808080808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808080
              8080808080000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
              FFFFFFFF00000000000000000000000080808080808080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
              0000000080808080808080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000008080808080808080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFF0000000000000000008080808080808080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
              8080808080808080800000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
              FFFFFFFFFF000000000000000000000000808080808080808080808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
              0000000000808080808080808080808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFF00000000000000000000000000000080808080808080808080
              8080808080000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFF0000000000000000
              0000000000000080808080808080808080808080808080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000008080808080808080
              8080808080808080808080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080808080}
            Transparent = True
          end
          object LSmall1: TLabel
            Left = 515
            Top = 0
            Width = 71
            Height = 18
            Alignment = taRightJustify
            Caption = 'GST 103B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label19: TLabel
            Left = 294
            Top = 22
            Width = 116
            Height = 16
            Caption = 'Registration number'
          end
          object Label20: TLabel
            Left = 448
            Top = 22
            Width = 6
            Height = 14
            Caption = '1'
            Color = clWhite
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            Transparent = True
          end
          object lblBasis: TLabel
            Left = 11
            Top = 178
            Width = 78
            Height = 14
            Caption = 'INVOICE BASIS'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPeriod: TStaticText
            Left = 476
            Top = 40
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            Caption = '2 MONTHS'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            ShowAccelChar = False
            TabOrder = 5
          end
          object lblDateFrom: TStaticText
            Left = 350
            Top = 60
            Width = 76
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            Caption = '01/01/98'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            ShowAccelChar = False
            TabOrder = 6
          end
          object lblDateTo: TStaticText
            Left = 506
            Top = 60
            Width = 80
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            Caption = '28/02/98'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            ShowAccelChar = False
            TabOrder = 7
          end
          object lblDueDate: TStaticText
            Left = 506
            Top = 80
            Width = 80
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            Caption = '28 FEB 2002'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            ShowAccelChar = False
            TabOrder = 8
          end
          object lblGSTno: TStaticText
            Left = 488
            Top = 20
            Width = 98
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            Caption = '12-345-678'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            ShowAccelChar = False
            TabOrder = 9
          end
          object pnlDebtors: TGroupBox
            Left = 121
            Top = 106
            Width = 480
            Height = 78
            Color = clWhite
            ParentColor = False
            TabOrder = 1
            object Label1: TLabel
              Left = 8
              Top = 9
              Width = 129
              Height = 16
              Caption = 'Income from Ledger'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label2: TLabel
              Left = 8
              Top = 33
              Width = 118
              Height = 16
              Caption = 'Plus closing debtors'
            end
            object Label7: TLabel
              Left = 8
              Top = 56
              Width = 124
              Height = 16
              Caption = 'Less opening debtors'
            end
            object lblIncome: TStaticText
              Left = 362
              Top = 11
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 2
            end
            object nClosingDebt: TOvcNumericField
              Left = 362
              Top = 33
              Width = 110
              Height = 20
              Cursor = crIBeam
              DataType = nftDouble
              AutoSize = False
              BorderStyle = bsNone
              CaretOvr.Shape = csBlock
              Controller = OvcController1
              Ctl3D = False
              EFColors.Disabled.BackColor = clWindow
              EFColors.Disabled.TextColor = clGrayText
              EFColors.Error.BackColor = clRed
              EFColors.Error.TextColor = clBlack
              EFColors.Highlight.BackColor = clHighlight
              EFColors.Highlight.TextColor = clHighlightText
              Options = []
              ParentCtl3D = False
              PictureMask = '###,###,###.##'
              TabOrder = 0
              OnChange = nClosingDebtChange
              OnKeyDown = nClosingDebtKeyDown
              RangeHigh = {73B2DBB9838916F2FE43}
              RangeLow = {73B2DBB9838916F2FEC3}
            end
            object nOpeningDebt: TOvcNumericField
              Left = 362
              Top = 56
              Width = 110
              Height = 20
              Cursor = crIBeam
              DataType = nftDouble
              AutoSize = False
              BorderStyle = bsNone
              CaretOvr.Shape = csBlock
              Controller = OvcController1
              Ctl3D = False
              EFColors.Disabled.BackColor = clWindow
              EFColors.Disabled.TextColor = clGrayText
              EFColors.Error.BackColor = clRed
              EFColors.Error.TextColor = clBlack
              EFColors.Highlight.BackColor = clHighlight
              EFColors.Highlight.TextColor = clHighlightText
              Options = []
              ParentCtl3D = False
              PictureMask = '###,###,###.##'
              TabOrder = 1
              OnChange = nFringeChange
              OnKeyDown = nClosingDebtKeyDown
              RangeHigh = {73B2DBB9838916F2FE43}
              RangeLow = {73B2DBB9838916F2FEC3}
            end
          end
          object pnlCreditors: TGroupBox
            Left = 121
            Top = 396
            Width = 479
            Height = 79
            Color = clWhite
            ParentColor = False
            TabOrder = 3
            object Label6: TLabel
              Left = 8
              Top = 9
              Width = 147
              Height = 16
              Caption = 'Purchases from Ledger'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Label8: TLabel
              Left = 8
              Top = 33
              Width = 125
              Height = 16
              Caption = 'Plus closing creditors'
            end
            object Label14: TLabel
              Left = 8
              Top = 56
              Width = 131
              Height = 16
              Caption = 'Less opening creditors'
            end
            object lblPurchases: TStaticText
              Left = 362
              Top = 11
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 2
            end
            object nClosingCR: TOvcNumericField
              Left = 362
              Top = 33
              Width = 110
              Height = 20
              Cursor = crIBeam
              DataType = nftDouble
              AutoSize = False
              BorderStyle = bsNone
              CaretOvr.Shape = csBlock
              Controller = OvcController1
              Ctl3D = False
              EFColors.Disabled.BackColor = clWindow
              EFColors.Disabled.TextColor = clGrayText
              EFColors.Error.BackColor = clRed
              EFColors.Error.TextColor = clBlack
              EFColors.Highlight.BackColor = clHighlight
              EFColors.Highlight.TextColor = clHighlightText
              Options = []
              ParentCtl3D = False
              PictureMask = '###,###,###.##'
              TabOrder = 0
              OnChange = nClosingDebtChange
              OnKeyDown = nClosingDebtKeyDown
              RangeHigh = {73B2DBB9838916F2FE43}
              RangeLow = {73B2DBB9838916F2FEC3}
            end
            object nOpeningCR: TOvcNumericField
              Left = 362
              Top = 56
              Width = 110
              Height = 20
              Cursor = crIBeam
              DataType = nftDouble
              AutoSize = False
              BorderStyle = bsNone
              CaretOvr.Shape = csBlock
              Controller = OvcController1
              Ctl3D = False
              EFColors.Disabled.BackColor = clWindow
              EFColors.Disabled.TextColor = clGrayText
              EFColors.Error.BackColor = clRed
              EFColors.Error.TextColor = clBlack
              EFColors.Highlight.BackColor = clHighlight
              EFColors.Highlight.TextColor = clHighlightText
              Options = []
              ParentCtl3D = False
              PictureMask = '###,###,###.##'
              TabOrder = 1
              OnChange = nFringeChange
              OnKeyDown = nClosingDebtKeyDown
              RangeHigh = {73B2DBB9838916F2FE43}
              RangeLow = {73B2DBB9838916F2FEC3}
            end
          end
          object pnlSales: TGroupBox
            Left = 3
            Top = 190
            Width = 597
            Height = 213
            Color = 15197925
            ParentBackground = False
            ParentColor = False
            TabOrder = 2
            object Image5: TImage
              Left = 435
              Top = 104
              Width = 35
              Height = 20
              AutoSize = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                8080808080808080808080808080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                0000000000000000000000000000008080808080808080808080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
                8080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
                0000000000000000808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFF0000000000000000008080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
                0080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFF00000000000000000000000000000080
                8080808080808080808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
            end
            object imgFBT: TImage
              Left = 435
              Top = 127
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
                80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
                C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
                00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
                8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
              Visible = False
            end
            object Image3: TImage
              Left = 435
              Top = 45
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
                80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
                C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
                00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
                8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
            end
            object Image2: TImage
              Left = 435
              Top = 16
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
                80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
                C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
                00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
                8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
            end
            object Image1: TImage
              Left = 435
              Top = 72
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                8080808080808080808080808080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                0000000000000000000000000000008080808080808080808080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
                8080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
                0000000000000000808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFF0000000000000000008080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
                0080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFF00000000000000000000000000000080
                8080808080808080808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
            end
            object L6: TLabel
              Left = 124
              Top = 48
              Width = 162
              Height = 16
              Caption = 'Zero rated supplies in Box 5'
            end
            object L5: TLabel
              Left = 124
              Top = 19
              Width = 216
              Height = 16
              Caption = 'Total Sales and Income (incl GST)'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
              WordWrap = True
            end
            object L7: TLabel
              Left = 124
              Top = 72
              Width = 154
              Height = 16
              Caption = 'Subtract Box 6 from Box 5'
            end
            object lblFringeBenefits: TLabel
              Left = 124
              Top = 128
              Width = 168
              Height = 16
              Caption = 'Adjustment for fringe benefits'
              Visible = False
            end
            object L8: TLabel
              Left = 124
              Top = 104
              Width = 131
              Height = 16
              Caption = 'Divide Box 7 by nine'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object LI5: TLabel
              Left = 448
              Top = 19
              Width = 6
              Height = 13
              Alignment = taRightJustify
              Caption = '5'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object LI6: TLabel
              Left = 448
              Top = 48
              Width = 6
              Height = 13
              Alignment = taRightJustify
              Caption = '6'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object LI7: TLabel
              Left = 447
              Top = 75
              Width = 6
              Height = 13
              Alignment = taRightJustify
              Caption = '7'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object LI8: TLabel
              Left = 447
              Top = 107
              Width = 6
              Height = 13
              Alignment = taRightJustify
              Caption = '8'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object Label42: TLabel
              Left = 8
              Top = 24
              Width = 78
              Height = 56
              Caption = 'Goods and services tax on your sales and income'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              WordWrap = True
            end
            object Bevel3: TBevel
              Left = 124
              Top = 62
              Width = 310
              Height = 6
              Shape = bsBottomLine
            end
            object Bevel4: TBevel
              Left = 124
              Top = 84
              Width = 310
              Height = 15
              Shape = bsBottomLine
            end
            object lblTotalSalesInc: TStaticText
              Left = 478
              Top = 16
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 2
            end
            object lblZeroRated: TStaticText
              Left = 478
              Top = 42
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 3
            end
            object lblSubtract6: TStaticText
              Left = 478
              Top = 72
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 4
            end
            object lblDivide7: TStaticText
              Left = 478
              Top = 104
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 5
            end
            object nFringe: TOvcNumericField
              Left = 478
              Top = 127
              Width = 110
              Height = 19
              Cursor = crIBeam
              DataType = nftDouble
              AutoSize = False
              BorderStyle = bsNone
              CaretOvr.Shape = csBlock
              Controller = OvcController1
              Ctl3D = False
              EFColors.Disabled.BackColor = clWindow
              EFColors.Disabled.TextColor = clGrayText
              EFColors.Error.BackColor = clRed
              EFColors.Error.TextColor = clBlack
              EFColors.Highlight.BackColor = clHighlight
              EFColors.Highlight.TextColor = clHighlightText
              Options = []
              ParentCtl3D = False
              PictureMask = '###,###,###.##'
              TabOrder = 0
              Visible = False
              OnChange = nFringeChange
              OnKeyDown = nClosingDebtKeyDown
              RangeHigh = {73B2DBB9838916F2FE43}
              RangeLow = {73B2DBB9838916F2FEC3}
            end
            object pnlTotalGST: TPanel
              Left = 124
              Top = 145
              Width = 470
              Height = 65
              BevelOuter = bvNone
              Color = 15197925
              TabOrder = 1
              object I372: TImage
                Left = 311
                Top = 8
                Width = 35
                Height = 20
                AutoSize = True
                IncrementalDisplay = True
                Picture.Data = {
                  07544269746D6170A6080000424DA60800000000000036000000280000002300
                  0000140000000100180000000000700800000000000000000000000000000000
                  0000808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080000000808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080000000808080000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000808080808080808080808080808080808080
                  808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                  808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                  C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
                  80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
                  80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                  C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
                  0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
                  C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                  FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
                  808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                  FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                  FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
                  80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
                  00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                  C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
                  0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
                  8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0000000000000808080808080808080808080808080000000808080000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000808080808080808080808080808080808080
                  8080800000008080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  808080808080808080808080808080000000}
                Transparent = True
                OnClick = GST372Action
              end
              object L9: TLabel
                Left = 0
                Top = 8
                Width = 204
                Height = 16
                Caption = 'Adjustments from calculation sheet'
              end
              object LI9: TLabel
                Left = 325
                Top = 11
                Width = 6
                Height = 13
                Alignment = taRightJustify
                Caption = '9'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
                Transparent = True
                OnClick = GST372Action
              end
              object Image6: TImage
                Left = 311
                Top = 40
                Width = 35
                Height = 20
                AutoSize = True
                IncrementalDisplay = True
                Picture.Data = {
                  07544269746D6170A6080000424DA60800000000000036000000280000002300
                  0000140000000100180000000000700800000000000000000000000000000000
                  0000808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080000000808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080000000808080000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000808080808080808080808080808080808080
                  8080800000008080800000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  8080808080808080808080808080800000008080800000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000FFFFFF
                  0000000000000000000000000000008080808080808080808080800000008080
                  8000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
                  8080808080808000000080808000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                  0000000000000000000000000080808080808000000080808000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
                  0000808080000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
                  0000000000000000808080000000808080000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                  FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
                  8080800000008080800000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                  FFFFFF0000000000000000008080800000008080800000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000FFFFFF
                  FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
                  8000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
                  0080808080808000000080808000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                  0000000000000000000000000080808080808000000080808000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
                  0000808080000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  00000000000000000000000000FFFFFF00000000000000000000000000000080
                  8080808080808080808080000000808080000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000808080808080808080808080808080000000808080000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000808080808080808080808080808080808080
                  8080800000008080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  808080808080808080808080808080000000}
                Transparent = True
              end
              object LI10: TLabel
                Left = 318
                Top = 43
                Width = 12
                Height = 13
                Alignment = taRightJustify
                Caption = '10'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWhite
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
                Transparent = True
              end
              object L10: TLabel
                Left = 0
                Top = 40
                Width = 125
                Height = 16
                Caption = 'Total GST collected'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -13
                Font.Name = 'Arial'
                Font.Style = [fsBold]
                ParentFont = False
              end
              object Bevel5: TBevel
                Left = 0
                Top = 27
                Width = 310
                Height = 6
                Shape = bsBottomLine
              end
              object lblTotalGSTCollected: TStaticText
                Left = 354
                Top = 39
                Width = 110
                Height = 20
                Alignment = taRightJustify
                AutoSize = False
                BevelInner = bvNone
                BevelKind = bkFlat
                BevelOuter = bvRaised
                Caption = '$000,000,000.00'
                Color = clWhite
                ParentColor = False
                ShowAccelChar = False
                TabOrder = 1
              end
              object nDrAdjust: TOvcNumericField
                Left = 354
                Top = 7
                Width = 110
                Height = 19
                Cursor = crIBeam
                DataType = nftDouble
                AutoSize = False
                BorderStyle = bsNone
                CaretOvr.Shape = csBlock
                Controller = OvcController1
                Ctl3D = False
                EFColors.Disabled.BackColor = clWindow
                EFColors.Disabled.TextColor = clGrayText
                EFColors.Error.BackColor = clRed
                EFColors.Error.TextColor = clBlack
                EFColors.Highlight.BackColor = clHighlight
                EFColors.Highlight.TextColor = clHighlightText
                Options = []
                ParentCtl3D = False
                PictureMask = '###,###,###.##'
                TabOrder = 0
                OnChange = nDrAdjustChange
                OnKeyDown = nClosingDebtKeyDown
                RangeHigh = {0090C2F5FF276BEE1C40}
                RangeLow = {00D8A3703D0AD7A3F8BF}
              end
            end
          end
          object pnlPurchases: TGroupBox
            Left = 3
            Top = 474
            Width = 597
            Height = 171
            Color = 15197925
            ParentBackground = False
            ParentColor = False
            TabOrder = 4
            object L12: TLabel
              Left = 124
              Top = 37
              Width = 125
              Height = 16
              Caption = 'Divide Box 11 by nine'
            end
            object L11: TLabel
              Left = 124
              Top = 9
              Width = 192
              Height = 16
              Caption = 'Total purchases and expenses'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object L13: TLabel
              Left = 124
              Top = 60
              Width = 109
              Height = 16
              Caption = 'Credit adjustments'
            end
            object L14: TLabel
              Left = 124
              Top = 89
              Width = 105
              Height = 16
              Caption = 'Total GST Credit'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Image8: TImage
              Left = 435
              Top = 8
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
                80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
                C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
                00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
                8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
            end
            object I372C: TImage
              Left = 435
              Top = 60
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
                80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
                C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
                00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
                8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
              OnClick = GST372Action
            end
            object Image10: TImage
              Left = 435
              Top = 89
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                8080808080808080808080808080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                0000000000000000000000000000008080808080808080808080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
                8080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
                0000000000000000808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFF0000000000000000008080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
                0080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFF00000000000000000000000000000080
                8080808080808080808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
            end
            object Image11: TImage
              Left = 435
              Top = 37
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                8080808080808080808080808080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                0000000000000000000000000000008080808080808080808080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
                8080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
                0000000000000000808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFF0000000000000000008080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
                0080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFF00000000000000000000000000000080
                8080808080808080808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
            end
            object LI11: TLabel
              Left = 445
              Top = 11
              Width = 12
              Height = 13
              Alignment = taRightJustify
              Caption = '11'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object LI12: TLabel
              Left = 443
              Top = 40
              Width = 12
              Height = 13
              Alignment = taRightJustify
              Caption = '12'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object LI13: TLabel
              Left = 445
              Top = 63
              Width = 12
              Height = 13
              Alignment = taRightJustify
              Caption = '13'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
              OnClick = GST372Action
            end
            object LI14: TLabel
              Left = 443
              Top = 92
              Width = 12
              Height = 13
              Alignment = taRightJustify
              Caption = '14'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object Label43: TLabel
              Left = 8
              Top = 10
              Width = 73
              Height = 70
              Caption = 'Goods and services tax on your purchases and expenses'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              WordWrap = True
            end
            object Bevel6: TBevel
              Left = 124
              Top = 28
              Width = 310
              Height = 6
              Shape = bsBottomLine
            end
            object Bevel7: TBevel
              Left = 124
              Top = 82
              Width = 310
              Height = 3
              Shape = bsBottomLine
            end
            object Bevel8: TBevel
              Left = 124
              Top = 111
              Width = 310
              Height = 6
              Shape = bsBottomLine
            end
            object lblTotalPurch: TStaticText
              Left = 478
              Top = 10
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 1
            end
            object lblDivide12: TStaticText
              Left = 478
              Top = 37
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 2
            end
            object lblTotalGSTCredit: TStaticText
              Left = 478
              Top = 89
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 3
            end
            object nCRAdjust: TOvcNumericField
              Left = 478
              Top = 60
              Width = 110
              Height = 19
              Cursor = crIBeam
              DataType = nftDouble
              AutoSize = False
              BorderStyle = bsNone
              CaretOvr.Shape = csBlock
              Color = clWhite
              Controller = OvcController1
              Ctl3D = False
              EFColors.Disabled.BackColor = clWindow
              EFColors.Disabled.TextColor = clGrayText
              EFColors.Error.BackColor = clRed
              EFColors.Error.TextColor = clBlack
              EFColors.Highlight.BackColor = clHighlight
              EFColors.Highlight.TextColor = clHighlightText
              Options = []
              ParentCtl3D = False
              PictureMask = '###,###,###.##'
              TabOrder = 0
              OnChange = nDrAdjustChange
              OnKeyDown = nClosingDebtKeyDown
              RangeHigh = {0090C2F5FF276BEE1C40}
              RangeLow = {00000000000000000000}
            end
            object p15A: TPanel
              Left = 2
              Top = 117
              Width = 593
              Height = 52
              Align = alBottom
              BevelOuter = bvNone
              TabOrder = 4
              object L15: TLabel
                Left = 124
                Top = 1
                Width = 246
                Height = 16
                Caption = 'Difference between Box 10 and Box 14'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -13
                Font.Name = 'Arial'
                Font.Style = [fsBold]
                ParentFont = False
                WordWrap = True
              end
              object I15: TImage
                Left = 433
                Top = 0
                Width = 35
                Height = 20
                AutoSize = True
                IncrementalDisplay = True
                Picture.Data = {
                  07544269746D6170A6080000424DA60800000000000036000000280000002300
                  0000140000000100180000000000700800000000000000000000000000000000
                  0000808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080000000808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080000000808080000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000808080808080808080808080808080808080
                  808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                  808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                  C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
                  80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
                  80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                  C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
                  0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
                  C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                  FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
                  808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                  FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                  FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
                  80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
                  00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                  C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
                  0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
                  8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                  C0C0000000000000808080808080808080808080808080000000808080000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000000000000000000000000000000000000000
                  0000000000000000000000000000808080808080808080808080808080808080
                  8080800000008080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  8080808080808080808080808080808080808080808080808080808080808080
                  808080808080808080808080808080000000}
                Transparent = True
              end
              object LI15: TLabel
                Left = 441
                Top = 4
                Width = 12
                Height = 13
                Alignment = taRightJustify
                Caption = '15'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -11
                Font.Name = 'MS Sans Serif'
                Font.Style = []
                ParentFont = False
                Transparent = True
              end
              object cirGSTtoPay: TShape
                Left = 540
                Top = 32
                Width = 8
                Height = 20
                Brush.Color = clBlack
                Shape = stCircle
              end
              object Shape2: TShape
                Left = 536
                Top = 32
                Width = 16
                Height = 20
                Shape = stCircle
              end
              object lblToPay: TLabel
                Left = 464
                Top = 32
                Width = 68
                Height = 16
                Caption = 'GST to Pay'
              end
              object Shape1: TShape
                Left = 439
                Top = 32
                Width = 16
                Height = 20
                Shape = stCircle
              end
              object cirRefund: TShape
                Left = 443
                Top = 32
                Width = 8
                Height = 21
                Brush.Color = clBlack
                Shape = stCircle
              end
              object lblRefund: TLabel
                Left = 392
                Top = 32
                Width = 40
                Height = 16
                Caption = 'Refund'
              end
              object lblDifference: TStaticText
                Left = 478
                Top = 0
                Width = 110
                Height = 20
                Alignment = taRightJustify
                AutoSize = False
                BevelInner = bvNone
                BevelKind = bkFlat
                BevelOuter = bvRaised
                Caption = '$000,000,000.00'
                Color = clWhite
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -13
                Font.Name = 'MS Sans Serif'
                Font.Style = [fsBold]
                ParentColor = False
                ParentFont = False
                ShowAccelChar = False
                TabOrder = 0
              end
            end
          end
          object GBAddress: TGroupBox
            Left = 3
            Top = 16
            Width = 278
            Height = 81
            Color = clWhite
            ParentColor = False
            TabOrder = 0
            object lblName: TLabel
              Left = 8
              Top = 8
              Width = 257
              Height = 14
              AutoSize = False
              Caption = 'COMPANY NAME'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
              ShowAccelChar = False
            end
            object lblAddr1: TLabel
              Left = 8
              Top = 28
              Width = 260
              Height = 14
              AutoSize = False
              Caption = 'Address Line 1'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              ShowAccelChar = False
            end
            object lblAddr2: TLabel
              Left = 8
              Top = 45
              Width = 260
              Height = 14
              AutoSize = False
              Caption = 'Address Line 2'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              ShowAccelChar = False
            end
            object lblAddr3: TLabel
              Left = 8
              Top = 61
              Width = 260
              Height = 14
              AutoSize = False
              Caption = 'Address Line 3'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              ShowAccelChar = False
            end
          end
        end
      end
    end
    object TsPart1B: TTabSheet
      Caption = 'Part 1B - GST after  01/10/10'
      ImageIndex = 3
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object GroupBox1: TGroupBox
        Left = 0
        Top = 0
        Width = 603
        Height = 650
        Color = clWhite
        Ctl3D = True
        ParentBackground = False
        ParentColor = False
        ParentCtl3D = False
        TabOrder = 0
        object lMain1B: TLabel
          Left = 6
          Top = 0
          Width = 227
          Height = 18
          Caption = 'Goods and Services Tax Return'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object LSmall1B: TLabel
          Left = 515
          Top = 0
          Width = 71
          Height = 18
          Alignment = taRightJustify
          Caption = 'GST 103B'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -15
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblBasisB: TLabel
          Left = 11
          Top = 95
          Width = 78
          Height = 14
          Caption = 'INVOICE BASIS'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Arial'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object pnlDebtorsB: TGroupBox
          Left = 121
          Top = 30
          Width = 480
          Height = 78
          Color = clWhite
          ParentColor = False
          TabOrder = 0
          object Label60: TLabel
            Left = 8
            Top = 9
            Width = 129
            Height = 16
            Caption = 'Income from Ledger'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label62: TLabel
            Left = 8
            Top = 33
            Width = 118
            Height = 16
            Caption = 'Plus closing debtors'
          end
          object Label63: TLabel
            Left = 8
            Top = 56
            Width = 124
            Height = 16
            Caption = 'Less opening debtors'
          end
          object lblIncomeB: TStaticText
            Left = 362
            Top = 11
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            ParentColor = False
            ShowAccelChar = False
            TabOrder = 2
          end
          object nClosingDebtB: TOvcNumericField
            Left = 362
            Top = 33
            Width = 110
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            Controller = OvcController1
            Ctl3D = False
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            ParentCtl3D = False
            PictureMask = '###,###,###.##'
            TabOrder = 0
            OnChange = nFringeChange
            OnKeyDown = nClosingDebtKeyDown
            RangeHigh = {73B2DBB9838916F2FE43}
            RangeLow = {73B2DBB9838916F2FEC3}
          end
          object nOpeningDebtB: TOvcNumericField
            Left = 362
            Top = 56
            Width = 110
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            Controller = OvcController1
            Ctl3D = False
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            ParentCtl3D = False
            PictureMask = '###,###,###.##'
            TabOrder = 1
            OnChange = nOpeningDebtBChange
            OnKeyDown = nClosingDebtKeyDown
            RangeHigh = {73B2DBB9838916F2FE43}
            RangeLow = {73B2DBB9838916F2FEC3}
          end
        end
        object pnlCreditorsB: TGroupBox
          Left = 121
          Top = 320
          Width = 479
          Height = 79
          Color = clWhite
          ParentColor = False
          TabOrder = 2
          object Label64: TLabel
            Left = 8
            Top = 9
            Width = 147
            Height = 16
            Caption = 'Purchases from Ledger'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label65: TLabel
            Left = 8
            Top = 33
            Width = 125
            Height = 16
            Caption = 'Plus closing creditors'
          end
          object Label66: TLabel
            Left = 8
            Top = 56
            Width = 131
            Height = 16
            Caption = 'Less opening creditors'
          end
          object lblPurchasesB: TStaticText
            Left = 362
            Top = 11
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            ParentColor = False
            ShowAccelChar = False
            TabOrder = 2
          end
          object nClosingCRB: TOvcNumericField
            Left = 362
            Top = 33
            Width = 110
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            Controller = OvcController1
            Ctl3D = False
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            ParentCtl3D = False
            PictureMask = '###,###,###.##'
            TabOrder = 0
            OnChange = nFringeChange
            OnKeyDown = nClosingDebtKeyDown
            RangeHigh = {73B2DBB9838916F2FE43}
            RangeLow = {73B2DBB9838916F2FEC3}
          end
          object nOpeningCRB: TOvcNumericField
            Left = 362
            Top = 56
            Width = 110
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            Controller = OvcController1
            Ctl3D = False
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            ParentCtl3D = False
            PictureMask = '###,###,###.##'
            TabOrder = 1
            OnChange = nOpeningDebtBChange
            OnKeyDown = nClosingDebtKeyDown
            RangeHigh = {73B2DBB9838916F2FE43}
            RangeLow = {73B2DBB9838916F2FEC3}
          end
        end
        object pnlSalesB: TGroupBox
          Left = 3
          Top = 110
          Width = 597
          Height = 213
          Color = 15197925
          ParentBackground = False
          ParentColor = False
          TabOrder = 1
          object Image28: TImage
            Left = 435
            Top = 104
            Width = 35
            Height = 20
            AutoSize = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080800000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              8080808080808080808080808080800000008080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              0000000000000000000000000000008080808080808080808080800000008080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
              8080808080808000000080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
              0000000000000000000000000080808080808000000080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
              0000808080000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
              0000000000000000808080000000808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
              8080800000008080800000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFF0000000000000000008080800000008080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
              0080808080808000000080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
              0000000000000000000000000080808080808000000080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
              0000808080000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFF00000000000000000000000000000080
              8080808080808080808080000000808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object imgFBTB: TImage
            Left = 435
            Top = 127
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
              808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
              80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
              C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
              00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
              8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
            Visible = False
          end
          object Image31: TImage
            Left = 435
            Top = 45
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
              808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
              80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
              C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
              00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
              8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object Image32: TImage
            Left = 435
            Top = 16
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
              808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
              80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
              C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
              00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
              8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object Image33: TImage
            Left = 435
            Top = 72
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080800000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              8080808080808080808080808080800000008080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              0000000000000000000000000000008080808080808080808080800000008080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
              8080808080808000000080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
              0000000000000000000000000080808080808000000080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
              0000808080000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
              0000000000000000808080000000808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
              8080800000008080800000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFF0000000000000000008080800000008080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
              0080808080808000000080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
              0000000000000000000000000080808080808000000080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
              0000808080000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFF00000000000000000000000000000080
              8080808080808080808080000000808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object L6B: TLabel
            Left = 124
            Top = 48
            Width = 171
            Height = 16
            Caption = 'Zero rated supplies in Box 5B'
          end
          object L5B: TLabel
            Left = 124
            Top = 19
            Width = 216
            Height = 16
            Caption = 'Total Sales and Income (incl GST)'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object L7B: TLabel
            Left = 124
            Top = 74
            Width = 172
            Height = 16
            Caption = 'Subtract Box 6B from Box 5B'
          end
          object lblFringeBenefitsB: TLabel
            Left = 124
            Top = 128
            Width = 168
            Height = 16
            Caption = 'Adjustment for fringe benefits'
            Visible = False
          end
          object L8B: TLabel
            Left = 126
            Top = 106
            Width = 241
            Height = 16
            Caption = 'Multiply Box 7B by 3 then divide by 23'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object LI5B: TLabel
            Left = 445
            Top = 19
            Width = 13
            Height = 13
            Alignment = taRightJustify
            Caption = '5B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object LI6B: TLabel
            Left = 445
            Top = 48
            Width = 13
            Height = 13
            Caption = '6B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object LI7B: TLabel
            Left = 445
            Top = 75
            Width = 13
            Height = 13
            Caption = '7B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object LI8B: TLabel
            Left = 445
            Top = 107
            Width = 13
            Height = 13
            Caption = '8B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object Label79: TLabel
            Left = 8
            Top = 20
            Width = 78
            Height = 56
            Caption = 'Goods and services tax on your sales and income'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            WordWrap = True
          end
          object Bevel15: TBevel
            Left = 124
            Top = 62
            Width = 310
            Height = 6
            Shape = bsBottomLine
          end
          object Bevel19: TBevel
            Left = 124
            Top = 84
            Width = 310
            Height = 15
            Shape = bsBottomLine
          end
          object lblTotalSalesIncB: TStaticText
            Left = 478
            Top = 16
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            ParentColor = False
            ShowAccelChar = False
            TabOrder = 2
          end
          object lblZeroRatedB: TStaticText
            Left = 478
            Top = 40
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            ParentColor = False
            ShowAccelChar = False
            TabOrder = 3
          end
          object lblSubtract6B: TStaticText
            Left = 478
            Top = 72
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            ParentColor = False
            ShowAccelChar = False
            TabOrder = 4
          end
          object lblDivide7B: TStaticText
            Left = 478
            Top = 104
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            ParentColor = False
            ShowAccelChar = False
            TabOrder = 5
          end
          object nFringeB: TOvcNumericField
            Left = 478
            Top = 127
            Width = 110
            Height = 19
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            Controller = OvcController1
            Ctl3D = False
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            ParentCtl3D = False
            PictureMask = '###,###,###.##'
            TabOrder = 0
            Visible = False
            OnChange = nFringeChange
            OnKeyDown = nClosingDebtKeyDown
            RangeHigh = {73B2DBB9838916F2FE43}
            RangeLow = {73B2DBB9838916F2FEC3}
          end
          object pnlTotalGSTB: TPanel
            Left = 124
            Top = 145
            Width = 470
            Height = 65
            BevelOuter = bvNone
            Color = 15197925
            TabOrder = 1
            object I372B: TImage
              Left = 311
              Top = 8
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
                80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
                C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
                808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
                00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
                C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
                0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
                8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
              OnClick = GST372Action
            end
            object L9B: TLabel
              Left = 0
              Top = 8
              Width = 204
              Height = 16
              Caption = 'Adjustments from calculation sheet'
            end
            object LI9B: TLabel
              Left = 320
              Top = 11
              Width = 13
              Height = 13
              Caption = '9B'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
              OnClick = GST372Action
            end
            object Image35: TImage
              Left = 311
              Top = 40
              Width = 35
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170A6080000424DA60800000000000036000000280000002300
                0000140000000100180000000000700800000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080000000808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                8080808080808080808080808080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                0000000000000000000000000000008080808080808080808080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
                8080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
                0000000000000000808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
                8080800000008080800000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFF0000000000000000008080800000008080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
                0080808080808000000080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
                0000000000000000000000000080808080808000000080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
                0000808080000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFF00000000000000000000000000000080
                8080808080808080808080000000808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000808080808080808080808080808080000000808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000808080808080808080808080808080808080
                8080800000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080000000}
              Transparent = True
            end
            object LI10B: TLabel
              Left = 314
              Top = 43
              Width = 19
              Height = 13
              Caption = '10B'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -11
              Font.Name = 'MS Sans Serif'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object L10B: TLabel
              Left = 0
              Top = 40
              Width = 125
              Height = 16
              Caption = 'Total GST collected'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object Bevel20: TBevel
              Left = 0
              Top = 27
              Width = 310
              Height = 6
              Shape = bsBottomLine
            end
            object lblTotalGSTCollectedB: TStaticText
              Left = 354
              Top = 39
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 1
            end
            object nDrAdjustB: TOvcNumericField
              Left = 354
              Top = 7
              Width = 110
              Height = 19
              Cursor = crIBeam
              DataType = nftDouble
              AutoSize = False
              BorderStyle = bsNone
              CaretOvr.Shape = csBlock
              Controller = OvcController1
              Ctl3D = False
              EFColors.Disabled.BackColor = clWindow
              EFColors.Disabled.TextColor = clGrayText
              EFColors.Error.BackColor = clRed
              EFColors.Error.TextColor = clBlack
              EFColors.Highlight.BackColor = clHighlight
              EFColors.Highlight.TextColor = clHighlightText
              Options = []
              ParentCtl3D = False
              PictureMask = '###,###,###.##'
              TabOrder = 0
              OnChange = nDrAdjustChange
              OnKeyDown = nClosingDebtKeyDown
              RangeHigh = {0090C2F5FF276BEE1C40}
              RangeLow = {00D8A3703D0AD7A3F8BF}
            end
          end
        end
        object pnlPurchasesB: TGroupBox
          Left = 3
          Top = 402
          Width = 597
          Height = 245
          Color = 15197925
          ParentBackground = False
          ParentColor = False
          TabOrder = 3
          object L12B: TLabel
            Left = 124
            Top = 37
            Width = 229
            Height = 16
            Caption = 'Multiply Box 11B by 3 then divide by 23'
          end
          object L11B: TLabel
            Left = 124
            Top = 9
            Width = 192
            Height = 16
            Caption = 'Total purchases and expenses'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object L13B: TLabel
            Left = 124
            Top = 60
            Width = 109
            Height = 16
            Caption = 'Credit adjustments'
          end
          object L15B: TLabel
            Left = 124
            Top = 123
            Width = 229
            Height = 16
            Caption = 'Total GST collected for both periods'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object L14B: TLabel
            Left = 124
            Top = 89
            Width = 105
            Height = 16
            Caption = 'Total GST Credit'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Image36: TImage
            Left = 435
            Top = 8
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
              808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
              80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
              C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
              00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
              8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object I372DB: TImage
            Left = 435
            Top = 60
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
              808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
              80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
              C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
              00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
              8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
            OnClick = GST372Action
          end
          object Image38: TImage
            Left = 435
            Top = 89
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080800000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              8080808080808080808080808080800000008080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              0000000000000000000000000000008080808080808080808080800000008080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
              8080808080808000000080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
              0000000000000000000000000080808080808000000080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
              0000808080000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
              0000000000000000808080000000808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
              8080800000008080800000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFF0000000000000000008080800000008080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
              0080808080808000000080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
              0000000000000000000000000080808080808000000080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
              0000808080000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFF00000000000000000000000000000080
              8080808080808080808080000000808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object Image39: TImage
            Left = 435
            Top = 37
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080800000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              8080808080808080808080808080800000008080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              0000000000000000000000000000008080808080808080808080800000008080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFF0000000000000000000000000000008080
              8080808080808000000080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
              0000000000000000000000000080808080808000000080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808000
              0000808080000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000
              0000000000000000808080000000808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFF000000000000000000808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000
              8080800000008080800000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFF0000000000000000008080800000008080800000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000008080800000008080
              8000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000
              0080808080808000000080808000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFF0000
              0000000000000000000000000080808080808000000080808000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00FFFFFFFFFFFF00000000000000000000000000000080808080808080808000
              0000808080000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              00000000000000000000000000FFFFFF00000000000000000000000000000080
              8080808080808080808080000000808080000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object Image40: TImage
            Left = 435
            Top = 123
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
              808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
              80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
              C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
              00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
              8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object LI11B: TLabel
            Left = 439
            Top = 11
            Width = 19
            Height = 13
            Caption = '11B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object LI12B: TLabel
            Left = 439
            Top = 40
            Width = 19
            Height = 13
            Caption = '12B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object LI13B: TLabel
            Left = 439
            Top = 64
            Width = 19
            Height = 13
            Caption = '13B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
            OnClick = GST372Action
          end
          object LI14B: TLabel
            Left = 439
            Top = 91
            Width = 19
            Height = 13
            Caption = '14B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object LI15B: TLabel
            Left = 443
            Top = 126
            Width = 12
            Height = 13
            Caption = '15'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object Label94: TLabel
            Left = 8
            Top = 10
            Width = 73
            Height = 70
            Caption = 'Goods and services tax on your purchases and expenses'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            WordWrap = True
          end
          object Bevel21: TBevel
            Left = 124
            Top = 28
            Width = 310
            Height = 6
            Shape = bsBottomLine
          end
          object Bevel22: TBevel
            Left = 124
            Top = 82
            Width = 310
            Height = 3
            Shape = bsBottomLine
          end
          object Bevel23: TBevel
            Left = 8
            Top = 111
            Width = 426
            Height = 6
            Shape = bsBottomLine
          end
          object lblRefundB: TLabel
            Left = 392
            Top = 216
            Width = 40
            Height = 16
            Caption = 'Refund'
          end
          object Label96: TLabel
            Left = 464
            Top = 216
            Width = 68
            Height = 16
            Caption = 'GST to Pay'
          end
          object Shape3: TShape
            Left = 439
            Top = 213
            Width = 16
            Height = 20
            Shape = stCircle
          end
          object Shape4: TShape
            Left = 536
            Top = 213
            Width = 16
            Height = 20
            Shape = stCircle
          end
          object cirRefundB: TShape
            Left = 443
            Top = 213
            Width = 8
            Height = 21
            Brush.Color = clBlack
            Shape = stCircle
          end
          object cirGSTtoPayB: TShape
            Left = 540
            Top = 213
            Width = 8
            Height = 20
            Brush.Color = clBlack
            Shape = stCircle
          end
          object L16B: TLabel
            Left = 124
            Top = 146
            Width = 207
            Height = 16
            Caption = 'Total GST credit for both periods'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object L17B: TLabel
            Left = 124
            Top = 170
            Width = 246
            Height = 16
            Caption = 'Difference between Box 15 and Box 16'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
            WordWrap = True
          end
          object Image7: TImage
            Left = 435
            Top = 149
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
              808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
              80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
              C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
              00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
              8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object Image9: TImage
            Left = 435
            Top = 173
            Width = 35
            Height = 20
            AutoSize = True
            IncrementalDisplay = True
            Picture.Data = {
              07544269746D6170A6080000424DA60800000000000036000000280000002300
              0000140000000100180000000000700800000000000000000000000000000000
              0000808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080000000808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
              808080808080808080808080808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              C0C0C0C0C0C0C0C0C0C0C0C00000008080808080808080808080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C00000008080
              80808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0
              C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
              FFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0000000808080000000808080000000
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0000000
              808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
              FFFFFFC0C0C0C0C0C0000000808080000000808080000000C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
              FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000008080800000008080
              80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C00000
              00808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0
              C0C0C0C0C0C0C0C0C0C0000000808080808080000000808080000000C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808000
              0000808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080
              8080808080808080808080000000808080000000C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
              C0C0000000000000808080808080808080808080808080000000808080000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000000000000000000000000000000000000000
              0000000000000000000000000000808080808080808080808080808080808080
              8080800000008080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              8080808080808080808080808080808080808080808080808080808080808080
              808080808080808080808080808080000000}
            Transparent = True
          end
          object LI16B: TLabel
            Left = 443
            Top = 152
            Width = 12
            Height = 13
            Caption = '16'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object LI17B: TLabel
            Left = 444
            Top = 176
            Width = 12
            Height = 13
            Caption = '17'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object lblTotalPurchB: TStaticText
            Left = 478
            Top = 10
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            ParentColor = False
            ShowAccelChar = False
            TabOrder = 1
          end
          object lblDivide12B: TStaticText
            Left = 478
            Top = 37
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            ParentColor = False
            ShowAccelChar = False
            TabOrder = 2
          end
          object lblTotalGSTCreditB: TStaticText
            Left = 478
            Top = 89
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            ParentColor = False
            ShowAccelChar = False
            TabOrder = 3
          end
          object lblGSTCollected: TStaticText
            Left = 478
            Top = 123
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentColor = False
            ParentFont = False
            ShowAccelChar = False
            TabOrder = 4
          end
          object nCRAdjustB: TOvcNumericField
            Left = 478
            Top = 60
            Width = 110
            Height = 19
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            Color = clWhite
            Controller = OvcController1
            Ctl3D = False
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            ParentCtl3D = False
            PictureMask = '###,###,###.##'
            TabOrder = 0
            OnChange = nDrAdjustChange
            OnKeyDown = nClosingDebtKeyDown
            RangeHigh = {0090C2F5FF276BEE1C40}
            RangeLow = {00000000000000000000}
          end
          object lblGSTCredit: TStaticText
            Left = 478
            Top = 147
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentColor = False
            ParentFont = False
            ShowAccelChar = False
            TabOrder = 5
          end
          object lblDifferenceB: TStaticText
            Left = 478
            Top = 171
            Width = 110
            Height = 20
            Alignment = taRightJustify
            AutoSize = False
            BevelInner = bvNone
            BevelKind = bkFlat
            BevelOuter = bvRaised
            Caption = '$000,000,000.00'
            Color = clWhite
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = [fsBold]
            ParentColor = False
            ParentFont = False
            ShowAccelChar = False
            TabOrder = 6
          end
        end
      end
    end
    object TsPart2: TTabSheet
      Caption = 'Part 2 - Provisional tax '
      ImageIndex = 1
      object SBProvisional: TScrollBox
        Left = 0
        Top = 0
        Width = 625
        Height = 654
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        TabOrder = 0
        object GbProvisional: TGroupBox
          Left = 0
          Top = 0
          Width = 603
          Height = 493
          Color = clWhite
          Ctl3D = True
          ParentBackground = False
          ParentColor = False
          ParentCtl3D = False
          TabOrder = 0
          object lMain2: TLabel
            Left = 6
            Top = 0
            Width = 218
            Height = 18
            Caption = 'GST and provisional tax return'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object LSmall2: TLabel
            Left = 515
            Top = 0
            Width = 71
            Height = 18
            Alignment = taRightJustify
            Caption = 'GST 103B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object GroupBox4: TGroupBox
            Left = 3
            Top = 24
            Width = 597
            Height = 465
            Color = 15197925
            ParentBackground = False
            ParentColor = False
            TabOrder = 0
            object PLeft: TPanel
              Left = 2
              Top = 18
              Width = 103
              Height = 445
              Align = alLeft
              BevelOuter = bvNone
              TabOrder = 0
              object WPRichTextLabel6: TWPRichTextLabel
                Left = 3
                Top = 374
                Width = 100
                Height = 41
                RTFText.Data = {
                  3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                  617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                  43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                  733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                  6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                  50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                  65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                  64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                  54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                  6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                  707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                  543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                  5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                  756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                  74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                  756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                  3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                  3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                  3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                  6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                  3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                  33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                  74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                  36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                  0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                  3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                  652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                  6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                  2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                  4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                  3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                  303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                  6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                  3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                  6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                  7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                  3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                  696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                  44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                  7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                  6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                  724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                  3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                  54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                  6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                  494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                  67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                  64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                  626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                  31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                  724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                  4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                  643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                  6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                  393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                  652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                  5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                  262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                  74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                  793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                  393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                  3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                  69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                  756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                  33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                  6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                  332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                  4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                  756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                  454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                  75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                  313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                  54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                  36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                  6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                  62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                  3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                  2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                  3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                  686172466F6E743A262333393B48656C766574696361262333393B3B43686172
                  466F6E7453697A653A3830303B5D5D2F3E3C6469762063733D313E3C63206E72
                  3D312F3E456E74657220796F757220726174696F20253C2F6469763E0D0A3C64
                  69762063733D313E3C63206E723D312F3E2866726F6D20796F75723C2F646976
                  3E0D0A3C6469762063733D313E3C63206E723D312F3E6E6F7469666963617469
                  6F6E206C6574746572293C2F6469763E0D0A}
                LayoutMode = wplayNormal
                AutoZoom = wpAutoZoomOff
                ViewOptions = [wpHideSelection]
                FormatOptions = [wpDisableAutosizeTables]
                FormatOptionsEx = []
                PaperColor = clWindow
                DeskColor = clBtnShadow
                TextSaveFormat = 'AUTO'
                TextLoadFormat = 'AUTO'
              end
              object Label29: TLabel
                Left = 0
                Top = 0
                Width = 103
                Height = 95
                Align = alTop
                AutoSize = False
                Caption = 'Part 2 - Provisional tax calculated when using the ratio option'
                Font.Charset = DEFAULT_CHARSET
                Font.Color = clWindowText
                Font.Height = -13
                Font.Name = 'Arial'
                Font.Style = [fsBold]
                ParentFont = False
                WordWrap = True
                ExplicitLeft = -1
                ExplicitTop = 1
              end
              object ERatio: TOvcNumericField
                Left = 7
                Top = 421
                Width = 59
                Height = 19
                Cursor = crIBeam
                DataType = nftDouble
                AutoSize = False
                BorderStyle = bsNone
                CaretOvr.Shape = csBlock
                Controller = OvcController1
                Ctl3D = False
                EFColors.Disabled.BackColor = clWindow
                EFColors.Disabled.TextColor = clGrayText
                EFColors.Error.BackColor = clRed
                EFColors.Error.TextColor = clBlack
                EFColors.Highlight.BackColor = clHighlight
                EFColors.Highlight.TextColor = clHighlightText
                Options = []
                ParentCtl3D = False
                PictureMask = '###.#'
                TabOrder = 0
                OnChange = nFringeChange
                OnKeyDown = nClosingDebtKeyDown
                RangeHigh = {73B2DBB9838916F2FE43}
                RangeLow = {73B2DBB9838916F2FEC3}
              end
            end
            object PRight: TPanel
              Left = 105
              Top = 18
              Width = 490
              Height = 445
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 1
              object P16: TPanel
                Left = 0
                Top = 0
                Width = 490
                Height = 35
                Align = alTop
                BevelOuter = bvNone
                TabOrder = 0
                ExplicitLeft = 1
                ExplicitTop = 1
                ExplicitWidth = 488
                object I16: TImage
                  Left = 338
                  Top = 0
                  Width = 28
                  Height = 20
                  AutoSize = True
                  Picture.Data = {
                    07544269746D6170C6060000424DC60600000000000036000000280000001C00
                    0000140000000100180000000000900600000000000000000000000000000000
                    0000808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    8080808080808080808080808080808080808080800000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000FFFFFF000000000000000000000000000000808080808080808080
                    8080808080808080800000000000000000000000000000000000000000000000
                    00000000000000000000000000000000000000000000000000FFFFFFFFFFFF00
                    0000000000000000000000000000808080808080808080808080808080000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                    0000000000808080808080808080808080000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808080
                    8080808080000000000000000000000000000000000000000000000000000000
                    000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFFF00000000000000000000000080808080808080808000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
                    0000000080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000FFFFFF
                    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000008080808080808080
                    8000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    FFFFFF0000000000000000008080808080808080800000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
                    8080808080808080800000000000000000000000000000000000000000000000
                    00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                    FFFFFFFFFF000000000000000000000000808080808080808080808080000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                    0000000000808080808080808080808080000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00FFFFFFFFFFFF00000000000000000000000000000080808080808080808080
                    8080808080000000000000000000000000000000000000000000000000000000
                    000000000000000000000000000000000000000000FFFFFF0000000000000000
                    0000000000000080808080808080808080808080808080808000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000008080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    808080808080808080808080808080808080}
                  Transparent = True
                end
                object LI16: TLabel
                  Left = 340
                  Top = 2
                  Width = 12
                  Height = 13
                  Caption = '16'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWhite
                  Font.Height = -11
                  Font.Name = 'MS Sans Serif'
                  Font.Style = []
                  ParentFont = False
                  Transparent = True
                end
                object Bevel24: TBevel
                  Left = 0
                  Top = 25
                  Width = 332
                  Height = 6
                  Shape = bsBottomLine
                end
                object L16: TLabel
                  Left = 4
                  Top = 2
                  Width = 233
                  Height = 16
                  Caption = 'Enter total sales and income from Box 5'
                end
                object lbl16: TStaticText
                  Left = 372
                  Top = 0
                  Width = 110
                  Height = 20
                  Alignment = taRightJustify
                  AutoSize = False
                  BevelInner = bvNone
                  BevelKind = bkFlat
                  BevelOuter = bvRaised
                  Caption = '$000,000,000.00'
                  Color = clWhite
                  ParentColor = False
                  ShowAccelChar = False
                  TabOrder = 0
                end
              end
              object P17: TPanel
                Left = 0
                Top = 35
                Width = 490
                Height = 53
                Align = alTop
                BevelOuter = bvNone
                TabOrder = 1
                object LR17: TWPRichTextLabel
                  Left = 0
                  Top = 0
                  Width = 280
                  Height = 51
                  RTFText.Data = {
                    3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                    617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                    43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                    733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                    6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                    50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                    65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                    64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                    54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                    707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                    543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                    5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                    756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                    74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                    756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                    3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                    3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                    3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                    6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                    3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                    33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                    74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                    36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                    0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                    3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                    2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                    4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                    3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                    303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                    6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                    3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                    6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                    7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                    3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                    696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                    44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                    7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                    6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                    724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                    3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                    54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                    494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                    67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                    64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                    626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                    31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                    724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                    4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                    643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                    6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                    393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                    5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                    262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                    74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                    793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                    393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                    3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                    69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                    756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                    33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                    332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                    4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                    756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                    454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                    75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                    313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                    54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                    36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                    6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                    62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                    3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                    2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                    3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                    686172466F6E743A262333393B48656C7665746963614E6575652D426F6C6426
                    2333393B3B43686172466F6E7453697A653A3830303B436861725374796C654D
                    61736B3A313B436861725374796C654F4E3A313B5D5D2F3E3C6469762063733D
                    313E3C6373206E723D322077707374793D5B5B43686172466F6E743A26233339
                    3B48656C766574696361262333393B3B43686172466F6E7453697A653A393030
                    3B5D5D2F3E3C63206E723D322F3E446F20796F752066696C6520475354207265
                    7475726E73206D6F6E74686C793F20496620736F20656E746572203C6373206E
                    723D332077707374793D5B5B43686172466F6E743A262333393B48656C766574
                    6963614E6575652D426F6C64262333393B3B43686172466F6E7453697A653A39
                    30303B436861725374796C654D61736B3A313B436861725374796C654F4E3A31
                    3B5D5D2F3E3C63206E723D332F3E746F74616C3C2F6469763E0D0A3C6373206E
                    723D342077707374793D5B5B43686172466F6E743A262333393B48656C766574
                    696361262333393B3B43686172466F6E7453697A653A3830303B5D5D2F3E3C64
                    69762063733D343E3C63206E723D332F3E73616C657320616E6420696E636F6D
                    65203C63206E723D322F3E28426F782035292066726F6D20796F757220707265
                    76696F75733C2F6469763E0D0A3C6469762063733D343E3C63206E723D322F3E
                    6D6F6E74682623383231373B732072657475726E2C206F746865727769736520
                    656E746572207A65726F202830293C2F6469763E0D0A}
                  LayoutMode = wplayNormal
                  AutoZoom = wpAutoZoomOff
                  ViewOptions = [wpHideSelection]
                  FormatOptions = [wpDisableAutosizeTables]
                  FormatOptionsEx = []
                  PaperColor = clWindow
                  DeskColor = clBtnShadow
                  TextSaveFormat = 'AUTO'
                  TextLoadFormat = 'AUTO'
                end
                object I17: TImage
                  Left = 338
                  Top = 14
                  Width = 28
                  Height = 20
                  AutoSize = True
                  IncrementalDisplay = True
                  Picture.Data = {
                    07544269746D6170C6060000424DC60600000000000036000000280000001C00
                    0000140000000100180000000000900600000000000000000000000000000000
                    0000808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                    808080808080808080808080808080808080808080000000C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080
                    808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0
                    C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080808080808080000000
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                    C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808080
                    8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080000000C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0
                    C0000000808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C00000008080808080808080
                    80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFC0C0C0C0C0C0000000808080808080808080000000C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0000000
                    808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                    FFFFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080808080000000
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                    C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808080
                    8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0
                    C0C0C0C0000000808080808080808080808080808080808080000000C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000008080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    808080808080808080808080808080808080}
                  Transparent = True
                end
                object LI17: TLabel
                  Left = 340
                  Top = 17
                  Width = 12
                  Height = 13
                  Caption = '17'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clBlack
                  Font.Height = -11
                  Font.Name = 'MS Sans Serif'
                  Font.Style = []
                  ParentFont = False
                  Transparent = True
                end
                object Bevel1: TBevel
                  Left = 0
                  Top = 40
                  Width = 332
                  Height = 6
                  Shape = bsBottomLine
                end
                object E17: TOvcNumericField
                  Left = 372
                  Top = 14
                  Width = 110
                  Height = 19
                  Cursor = crIBeam
                  DataType = nftDouble
                  AutoSize = False
                  BorderStyle = bsNone
                  CaretOvr.Shape = csBlock
                  Controller = OvcController1
                  Ctl3D = False
                  EFColors.Disabled.BackColor = clWindow
                  EFColors.Disabled.TextColor = clGrayText
                  EFColors.Error.BackColor = clRed
                  EFColors.Error.TextColor = clBlack
                  EFColors.Highlight.BackColor = clHighlight
                  EFColors.Highlight.TextColor = clHighlightText
                  Options = []
                  ParentCtl3D = False
                  PictureMask = '###,###,###.##'
                  TabOrder = 0
                  OnChange = nFringeChange
                  OnKeyDown = nClosingDebtKeyDown
                  RangeHigh = {73B2DBB9838916F2FE43}
                  RangeLow = {73B2DBB9838916F2FEC3}
                end
              end
              object P18: TPanel
                Left = 0
                Top = 88
                Width = 490
                Height = 35
                Align = alTop
                BevelOuter = bvNone
                TabOrder = 2
                object LR18: TWPRichTextLabel
                  Left = 0
                  Top = 0
                  Width = 300
                  Height = 22
                  RTFText.Data = {
                    3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                    617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                    43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                    733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                    6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                    50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                    65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                    64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                    54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                    707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                    543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                    5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                    756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                    74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                    756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                    3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                    3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                    3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                    6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                    3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                    33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                    74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                    36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                    0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                    3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                    2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                    4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                    3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                    303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                    6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                    3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                    6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                    7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                    3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                    696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                    44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                    7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                    6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                    724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                    3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                    54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                    494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                    67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                    64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                    626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                    31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                    724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                    4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                    643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                    6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                    393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                    5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                    262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                    74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                    793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                    393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                    3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                    69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                    756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                    33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                    332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                    4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                    756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                    454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                    75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                    313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                    54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                    36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                    6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                    62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                    3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                    2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                    3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                    686172466F6E743A262333393B417269616C262333393B3B43686172466F6E74
                    53697A653A313130303B5D5D2F3E3C6469762063733D313E3C6373206E723D32
                    2077707374793D5B5B43686172466F6E743A262333393B48656C766574696361
                    262333393B3B43686172466F6E7453697A653A3930303B5D5D2F3E3C63206E72
                    3D322F3E41646420426F7820313620616E6420426F782031373C2F6469763E0D
                    0A}
                  LayoutMode = wplayNormal
                  AutoZoom = wpAutoZoomOff
                  ViewOptions = [wpHideSelection]
                  FormatOptions = [wpDisableAutosizeTables]
                  FormatOptionsEx = []
                  PaperColor = clWindow
                  DeskColor = clBtnShadow
                  TextSaveFormat = 'AUTO'
                  TextLoadFormat = 'AUTO'
                end
                object Bevel9: TBevel
                  Left = 0
                  Top = 21
                  Width = 332
                  Height = 6
                  Shape = bsBottomLine
                end
                object I18: TImage
                  Left = 338
                  Top = 0
                  Width = 28
                  Height = 20
                  AutoSize = True
                  IncrementalDisplay = True
                  Picture.Data = {
                    07544269746D6170C6060000424DC60600000000000036000000280000001C00
                    0000140000000100180000000000900600000000000000000000000000000000
                    0000808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    8080808080808080808080808080808080808080800000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000FFFFFF000000000000000000000000000000808080808080808080
                    8080808080808080800000000000000000000000000000000000000000000000
                    00000000000000000000000000000000000000000000000000FFFFFFFFFFFF00
                    0000000000000000000000000000808080808080808080808080808080000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                    0000000000808080808080808080808080000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808080
                    8080808080000000000000000000000000000000000000000000000000000000
                    000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFFF00000000000000000000000080808080808080808000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
                    0000000080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000FFFFFF
                    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000008080808080808080
                    8000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    FFFFFF0000000000000000008080808080808080800000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
                    8080808080808080800000000000000000000000000000000000000000000000
                    00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                    FFFFFFFFFF000000000000000000000000808080808080808080808080000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                    0000000000808080808080808080808080000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00FFFFFFFFFFFF00000000000000000000000000000080808080808080808080
                    8080808080000000000000000000000000000000000000000000000000000000
                    000000000000000000000000000000000000000000FFFFFF0000000000000000
                    0000000000000080808080808080808080808080808080808000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000008080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    808080808080808080808080808080808080}
                  Transparent = True
                end
                object LI18: TLabel
                  Left = 340
                  Top = 3
                  Width = 12
                  Height = 13
                  Caption = '18'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWhite
                  Font.Height = -11
                  Font.Name = 'MS Sans Serif'
                  Font.Style = []
                  ParentFont = False
                  Transparent = True
                end
                object lbl18: TStaticText
                  Left = 372
                  Top = 0
                  Width = 110
                  Height = 20
                  Alignment = taRightJustify
                  AutoSize = False
                  BevelInner = bvNone
                  BevelKind = bkFlat
                  BevelOuter = bvRaised
                  Caption = '$000,000,000.00'
                  Color = clWhite
                  ParentColor = False
                  ShowAccelChar = False
                  TabOrder = 0
                end
              end
              object P19: TPanel
                Left = 0
                Top = 123
                Width = 490
                Height = 93
                Align = alTop
                BevelOuter = bvNone
                TabOrder = 3
                object LR19: TWPRichTextLabel
                  Left = 0
                  Top = 0
                  Width = 308
                  Height = 90
                  RTFText.Data = {
                    3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                    617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                    43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                    733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                    6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                    50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                    65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                    64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                    54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                    707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                    543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                    5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                    756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                    74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                    756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                    3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                    3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                    3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                    6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                    3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                    33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                    74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                    36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                    0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                    3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                    2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                    4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                    3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                    303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                    6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                    3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                    6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                    7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                    3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                    696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                    44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                    7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                    6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                    724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                    3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                    54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                    494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                    67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                    64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                    626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                    31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                    724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                    4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                    643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                    6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                    393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                    5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                    262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                    74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                    793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                    393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                    3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                    69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                    756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                    33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                    332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                    4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                    756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                    454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                    75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                    313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                    54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                    36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                    6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                    62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                    3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                    2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                    3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                    686172466F6E743A262333393B48656C766574696361262333393B3B43686172
                    466F6E7453697A653A3830303B5D5D2F3E3C6469762063733D313E3C6373206E
                    723D322077707374793D5B5B43686172466F6E743A262333393B48656C766574
                    696361262333393B3B43686172466F6E7453697A653A3930303B5D5D2F3E3C63
                    206E723D322F3E446F20796F752066696C65204753542072657475726E732066
                    6F72206D6F7265207468616E206F6E65206272616E63683C2F6469763E0D0A3C
                    6373206E723D332077707374793D5B5B43686172466F6E743A262333393B4865
                    6C7665746963614E6575652D426F6C64262333393B3B43686172466F6E745369
                    7A653A3830303B436861725374796C654D61736B3A313B436861725374796C65
                    4F4E3A313B5D5D2F3E3C6469762063733D333E3C63206E723D322F3E6F722064
                    69766973696F6E3F20496620736F20656E746572203C6373206E723D34207770
                    7374793D5B5B43686172466F6E743A262333393B48656C7665746963614E6575
                    652D426F6C64262333393B3B43686172466F6E7453697A653A3930303B436861
                    725374796C654D61736B3A313B436861725374796C654F4E3A313B5D5D2F3E3C
                    63206E723D342F3E746F74616C2073616C657320616E6420696E636F6D653C2F
                    6469763E0D0A3C6469762063733D313E3C63206E723D322F3E2866726F6D2042
                    6F782035292066726F6D20616C6C206F74686572206272616E636865732F6469
                    766973696F6E732C3C2F6469763E0D0A3C6469762063733D313E3C63206E723D
                    322F3E6F746865727769736520656E746572207A65726F202830292E20285265
                    6D656D62657220746F20696E636C7564653C2F6469763E0D0A3C646976206373
                    3D313E3C63206E723D322F3E616D6F756E74732066726F6D2074686520707265
                    76696F7573206D6F6E746820696620746865206F74686572206272616E636865
                    733C2F6469763E0D0A3C6469762063733D313E3C63206E723D322F3E66696C65
                    206F6E652D6D6F6E74686C79293C2F6469763E0D0A}
                  LayoutMode = wplayNormal
                  AutoZoom = wpAutoZoomOff
                  ViewOptions = [wpHideSelection]
                  FormatOptions = [wpDisableAutosizeTables]
                  FormatOptionsEx = []
                  PaperColor = clWindow
                  DeskColor = clBtnShadow
                  TextSaveFormat = 'AUTO'
                  TextLoadFormat = 'AUTO'
                end
                object I19: TImage
                  Left = 338
                  Top = 26
                  Width = 28
                  Height = 20
                  AutoSize = True
                  IncrementalDisplay = True
                  Picture.Data = {
                    07544269746D6170C6060000424DC60600000000000036000000280000001C00
                    0000140000000100180000000000900600000000000000000000000000000000
                    0000808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                    808080808080808080808080808080808080808080000000C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080
                    808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0
                    C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080808080808080000000
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                    C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808080
                    8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080000000C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0
                    C0000000808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C00000008080808080808080
                    80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFC0C0C0C0C0C0000000808080808080808080000000C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0000000
                    808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                    FFFFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080808080000000
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                    C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808080
                    8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0
                    C0C0C0C0000000808080808080808080808080808080808080000000C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000008080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    808080808080808080808080808080808080}
                  Transparent = True
                end
                object LI19: TLabel
                  Left = 340
                  Top = 30
                  Width = 12
                  Height = 13
                  Caption = '19'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clBlack
                  Font.Height = -11
                  Font.Name = 'MS Sans Serif'
                  Font.Style = []
                  ParentFont = False
                  Transparent = True
                end
                object Bevel2: TBevel
                  Left = 0
                  Top = 82
                  Width = 332
                  Height = 6
                  Shape = bsBottomLine
                end
                object E19: TOvcNumericField
                  Left = 372
                  Top = 27
                  Width = 110
                  Height = 19
                  Cursor = crIBeam
                  DataType = nftDouble
                  AutoSize = False
                  BorderStyle = bsNone
                  CaretOvr.Shape = csBlock
                  Controller = OvcController1
                  Ctl3D = False
                  EFColors.Disabled.BackColor = clWindow
                  EFColors.Disabled.TextColor = clGrayText
                  EFColors.Error.BackColor = clRed
                  EFColors.Error.TextColor = clBlack
                  EFColors.Highlight.BackColor = clHighlight
                  EFColors.Highlight.TextColor = clHighlightText
                  Options = []
                  ParentCtl3D = False
                  PictureMask = '###,###,###.##'
                  TabOrder = 0
                  OnChange = nFringeChange
                  OnKeyDown = nClosingDebtKeyDown
                  RangeHigh = {73B2DBB9838916F2FE43}
                  RangeLow = {73B2DBB9838916F2FEC3}
                end
              end
              object p20: TPanel
                Left = 0
                Top = 216
                Width = 490
                Height = 238
                Align = alTop
                BevelOuter = bvNone
                TabOrder = 4
                object Image21: TImage
                  Left = 338
                  Top = 0
                  Width = 28
                  Height = 20
                  AutoSize = True
                  IncrementalDisplay = True
                  Picture.Data = {
                    07544269746D6170C6060000424DC60600000000000036000000280000001C00
                    0000140000000100180000000000900600000000000000000000000000000000
                    0000808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    8080808080808080808080808080808080808080800000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000FFFFFF000000000000000000000000000000808080808080808080
                    8080808080808080800000000000000000000000000000000000000000000000
                    00000000000000000000000000000000000000000000000000FFFFFFFFFFFF00
                    0000000000000000000000000000808080808080808080808080808080000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                    0000000000808080808080808080808080000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808080
                    8080808080000000000000000000000000000000000000000000000000000000
                    000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFFF00000000000000000000000080808080808080808000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
                    0000000080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000FFFFFF
                    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000008080808080808080
                    8000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    FFFFFF0000000000000000008080808080808080800000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
                    8080808080808080800000000000000000000000000000000000000000000000
                    00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                    FFFFFFFFFF000000000000000000000000808080808080808080808080000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                    0000000000808080808080808080808080000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00FFFFFFFFFFFF00000000000000000000000000000080808080808080808080
                    8080808080000000000000000000000000000000000000000000000000000000
                    000000000000000000000000000000000000000000FFFFFF0000000000000000
                    0000000000000080808080808080808080808080808080808000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000008080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    808080808080808080808080808080808080}
                  Transparent = True
                end
                object L20: TLabel
                  Left = 340
                  Top = 3
                  Width = 12
                  Height = 13
                  Caption = '20'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWhite
                  Font.Height = -11
                  Font.Name = 'MS Sans Serif'
                  Font.Style = []
                  ParentFont = False
                  Transparent = True
                end
                object LR20: TWPRichTextLabel
                  Left = 0
                  Top = 0
                  Width = 282
                  Height = 24
                  RTFText.Data = {
                    3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                    617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                    43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                    733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                    6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                    50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                    65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                    64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                    54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                    707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                    543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                    5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                    756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                    74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                    756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                    3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                    3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                    3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                    6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                    3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                    33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                    74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                    36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                    0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                    3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                    2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                    4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                    3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                    303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                    6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                    3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                    6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                    7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                    3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                    696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                    44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                    7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                    6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                    724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                    3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                    54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                    494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                    67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                    64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                    626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                    31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                    724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                    4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                    643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                    6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                    393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                    5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                    262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                    74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                    793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                    393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                    3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                    69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                    756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                    33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                    332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                    4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                    756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                    454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                    75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                    313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                    54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                    36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                    6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                    62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                    3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                    2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                    3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                    686172466F6E743A262333393B417269616C262333393B3B43686172466F6E74
                    53697A653A313130303B5D5D2F3E3C6469762063733D313E3C6373206E723D32
                    2077707374793D5B5B43686172466F6E743A262333393B48656C766574696361
                    262333393B3B43686172466F6E7453697A653A3930303B5D5D2F3E3C63206E72
                    3D322F3E41646420426F7820313820616E6420426F782031393C2F6469763E0D
                    0A}
                  LayoutMode = wplayNormal
                  AutoZoom = wpAutoZoomOff
                  ViewOptions = [wpHideSelection]
                  FormatOptions = [wpDisableAutosizeTables]
                  FormatOptionsEx = []
                  PaperColor = clWindow
                  DeskColor = clBtnShadow
                  TextSaveFormat = 'AUTO'
                  TextLoadFormat = 'AUTO'
                end
                object Bevel10: TBevel
                  Left = 0
                  Top = 21
                  Width = 332
                  Height = 6
                  Shape = bsBottomLine
                end
                object LR21: TWPRichTextLabel
                  Left = 0
                  Top = 35
                  Width = 308
                  Height = 75
                  RTFText.Data = {
                    3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                    617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                    43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                    733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                    6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                    50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                    65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                    64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                    54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                    707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                    543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                    5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                    756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                    74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                    756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                    3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                    3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                    3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                    6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                    3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                    33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                    74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                    36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                    0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                    3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                    2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                    4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                    3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                    303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                    6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                    3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                    6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                    7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                    3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                    696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                    44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                    7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                    6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                    724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                    3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                    54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                    494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                    67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                    64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                    626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                    31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                    724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                    4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                    643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                    6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                    393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                    5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                    262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                    74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                    793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                    393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                    3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                    69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                    756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                    33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                    332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                    4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                    756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                    454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                    75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                    313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                    54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                    36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                    6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                    62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                    3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                    2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                    3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                    686172466F6E743A262333393B48656C766574696361262333393B3B43686172
                    466F6E7453697A653A3830303B5D5D2F3E3C6469762063733D313E3C6373206E
                    723D322077707374793D5B5B43686172466F6E743A262333393B48656C766574
                    696361262333393B3B43686172466F6E7453697A653A3930303B5D5D2F3E3C63
                    206E723D322F3E496620796F752623383231373B766520736F6C6420616E2061
                    7373657420696E20746865206C6173742074776F206D6F6E7468732C20796F75
                    2063616E3C2F6469763E0D0A3C6469762063733D313E3C63206E723D322F3E6D
                    616B6520616E203C6373206E723D332077707374793D5B5B43686172466F6E74
                    3A262333393B48656C7665746963612D426F6C64262333393B3B43686172466F
                    6E7453697A653A3930303B436861725374796C654D61736B3A313B4368617253
                    74796C654F4E3A313B5D5D2F3E3C63206E723D332F3E61646A7573746D656E74
                    20666F72207468652061737365743C6373206E723D342077707374793D5B5B43
                    686172466F6E743A262333393B48656C7665746963614E6575652D426F6C6426
                    2333393B3B43686172466F6E7453697A653A3930303B436861725374796C654D
                    61736B3A313B436861725374796C654F4E3A313B5D5D2F3E3C63206E723D342F
                    3E2623383231373B3C63206E723D332F3E7320776F7274683C63206E723D322F
                    3E2C2069662069742623383231373B73206F7665723C2F6469763E0D0A3C6469
                    762063733D313E3C63206E723D322F3E24312C3030302C206F72206974262338
                    3231373B73206F766572203525206F6620796F757220746F74616C2074617861
                    626C6520737570706C69657320696E3C2F6469763E0D0A3C6469762063733D31
                    3E3C63206E723D322F3E746865206C617374203132206D6F6E7468732C207768
                    6963686576657220697320677265617465722E20456E746572207468653C2F64
                    69763E0D0A3C6469762063733D313E3C63206E723D322F3E616D6F756E742068
                    6572652C206F746865727769736520656E746572207A65726F202830293C2F64
                    69763E0D0A}
                  LayoutMode = wplayNormal
                  AutoZoom = wpAutoZoomOff
                  ViewOptions = [wpHideSelection]
                  FormatOptions = [wpDisableAutosizeTables]
                  FormatOptionsEx = []
                  PaperColor = clWindow
                  DeskColor = clBtnShadow
                  TextSaveFormat = 'AUTO'
                  TextLoadFormat = 'AUTO'
                end
                object Bevel13: TBevel
                  Left = 0
                  Top = 108
                  Width = 332
                  Height = 6
                  Shape = bsBottomLine
                end
                object Image19: TImage
                  Left = 338
                  Top = 65
                  Width = 28
                  Height = 20
                  AutoSize = True
                  IncrementalDisplay = True
                  Picture.Data = {
                    07544269746D6170C6060000424DC60600000000000036000000280000001C00
                    0000140000000100180000000000900600000000000000000000000000000000
                    0000808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                    808080808080808080808080808080808080808080000000C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080
                    808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0
                    C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080808080808080000000
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                    C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808080
                    8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080000000C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0
                    C0000000808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C00000008080808080808080
                    80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFC0C0C0C0C0C0000000808080808080808080000000C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0000000
                    808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                    FFFFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080808080000000
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                    C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808080
                    8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0
                    C0C0C0C0000000808080808080808080808080808080808080000000C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000008080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    808080808080808080808080808080808080}
                  Transparent = True
                end
                object LI21: TLabel
                  Left = 340
                  Top = 68
                  Width = 12
                  Height = 13
                  Caption = '21'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clBlack
                  Font.Height = -11
                  Font.Name = 'MS Sans Serif'
                  Font.Style = []
                  ParentFont = False
                  Transparent = True
                end
                object Bevel14: TBevel
                  Left = 0
                  Top = 138
                  Width = 332
                  Height = 6
                  Shape = bsBottomLine
                end
                object LR22: TWPRichTextLabel
                  Left = 0
                  Top = 119
                  Width = 257
                  Height = 26
                  RTFText.Data = {
                    3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                    617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                    43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                    733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                    6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                    50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                    65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                    64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                    54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                    707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                    543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                    5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                    756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                    74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                    756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                    3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                    3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                    3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                    6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                    3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                    33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                    74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                    36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                    0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                    3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                    2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                    4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                    3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                    303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                    6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                    3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                    6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                    7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                    3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                    696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                    44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                    7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                    6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                    724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                    3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                    54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                    494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                    67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                    64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                    626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                    31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                    724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                    4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                    643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                    6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                    393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                    5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                    262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                    74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                    793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                    393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                    3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                    69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                    756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                    33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                    332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                    4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                    756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                    454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                    75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                    313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                    54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                    36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                    6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                    62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                    3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                    2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                    3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                    686172466F6E743A262333393B417269616C262333393B3B43686172466F6E74
                    53697A653A313130303B5D5D2F3E3C6469762063733D313E3C6373206E723D32
                    2077707374793D5B5B43686172466F6E743A262333393B48656C766574696361
                    262333393B3B43686172466F6E7453697A653A3930303B5D5D2F3E3C63206E72
                    3D322F3E537562747261637420426F782032312066726F6D20426F782032303C
                    2F6469763E0D0A}
                  LayoutMode = wplayNormal
                  AutoZoom = wpAutoZoomOff
                  ViewOptions = [wpHideSelection]
                  FormatOptions = [wpDisableAutosizeTables]
                  FormatOptionsEx = []
                  PaperColor = clWindow
                  DeskColor = clBtnShadow
                  TextSaveFormat = 'AUTO'
                  TextLoadFormat = 'AUTO'
                end
                object I22: TImage
                  Left = 338
                  Top = 117
                  Width = 28
                  Height = 20
                  AutoSize = True
                  IncrementalDisplay = True
                  Picture.Data = {
                    07544269746D6170C6060000424DC60600000000000036000000280000001C00
                    0000140000000100180000000000900600000000000000000000000000000000
                    0000808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    8080808080808080808080808080808080808080800000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000FFFFFF000000000000000000000000000000808080808080808080
                    8080808080808080800000000000000000000000000000000000000000000000
                    00000000000000000000000000000000000000000000000000FFFFFFFFFFFF00
                    0000000000000000000000000000808080808080808080808080808080000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                    0000000000808080808080808080808080000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808080
                    8080808080000000000000000000000000000000000000000000000000000000
                    000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFFF00000000000000000000000080808080808080808000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
                    0000000080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000FFFFFF
                    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000008080808080808080
                    8000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    FFFFFF0000000000000000008080808080808080800000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
                    8080808080808080800000000000000000000000000000000000000000000000
                    00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                    FFFFFFFFFF000000000000000000000000808080808080808080808080000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                    0000000000808080808080808080808080000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    00FFFFFFFFFFFF00000000000000000000000000000080808080808080808080
                    8080808080000000000000000000000000000000000000000000000000000000
                    000000000000000000000000000000000000000000FFFFFF0000000000000000
                    0000000000000080808080808080808080808080808080808000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000008080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    808080808080808080808080808080808080}
                  Transparent = True
                end
                object LI22: TLabel
                  Left = 340
                  Top = 120
                  Width = 12
                  Height = 13
                  Caption = '22'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clWhite
                  Font.Height = -11
                  Font.Name = 'MS Sans Serif'
                  Font.Style = []
                  ParentFont = False
                  Transparent = True
                end
                object LR23: TWPRichTextLabel
                  Left = 0
                  Top = 151
                  Width = 300
                  Height = 73
                  RTFText.Data = {
                    3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                    617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                    43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                    733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                    6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                    50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                    65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                    64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                    54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                    707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                    543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                    5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                    756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                    74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                    756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                    3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                    3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                    3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                    6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                    3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                    33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                    74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                    36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                    0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                    3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                    2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                    4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                    3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                    303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                    6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                    3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                    6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                    7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                    3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                    696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                    44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                    7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                    6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                    724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                    3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                    54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                    6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                    494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                    67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                    64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                    626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                    31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                    724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                    4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                    643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                    6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                    393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                    652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                    5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                    262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                    74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                    793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                    393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                    3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                    69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                    756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                    33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                    6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                    332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                    4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                    756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                    454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                    75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                    313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                    54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                    36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                    6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                    62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                    3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                    2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                    3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                    686172466F6E743A262333393B48656C7665746963614E6575652D426F6C6426
                    2333393B3B43686172466F6E7453697A653A3830303B436861725374796C654D
                    61736B3A313B436861725374796C654F4E3A313B5D5D2F3E3C6469762063733D
                    313E3C6373206E723D322077707374793D5B5B43686172466F6E743A26233339
                    3B48656C766574696361262333393B3B43686172466F6E7453697A653A393030
                    3B5D5D2F3E3C63206E723D322F3E4D756C7469706C792074686520616D6F756E
                    7420696E20426F7820323220627920796F7572203C6373206E723D3320777073
                    74793D5B5B43686172466F6E743A262333393B48656C7665746963614E657565
                    2D426F6C64262333393B3B43686172466F6E7453697A653A3930303B43686172
                    5374796C654D61736B3A313B436861725374796C654F4E3A313B5D5D2F3E3C63
                    206E723D332F3E726174696F3C2F6469763E0D0A3C6373206E723D3420777073
                    74793D5B5B43686172466F6E743A262333393B48656C76657469636126233339
                    3B3B43686172466F6E7453697A653A3830303B5D5D2F3E3C6469762063733D34
                    3E3C63206E723D332F3E70657263656E74616765203C63206E723D322F3E2874
                    686973206973207072696E746564206F6E20796F7572206E6F74696669636174
                    696F6E3C2F6469763E0D0A3C6469762063733D343E3C63206E723D322F3E6C65
                    74746572292E205468697320697320796F75722070726F766973696F6E616C20
                    74617820696E7374616C6D656E74206475652623383231323B3C2F6469763E0D
                    0A3C6469762063733D343E3C63206E723D322F3E636F7079207468697320616D
                    6F756E7420746F20426F782032343C2F6469763E0D0A}
                  LayoutMode = wplayNormal
                  AutoZoom = wpAutoZoomOff
                  ViewOptions = [wpHideSelection]
                  FormatOptions = [wpDisableAutosizeTables]
                  FormatOptionsEx = []
                  PaperColor = clWindow
                  DeskColor = clBtnShadow
                  TextSaveFormat = 'AUTO'
                  TextLoadFormat = 'AUTO'
                end
                object I23: TImage
                  Left = 338
                  Top = 165
                  Width = 28
                  Height = 20
                  AutoSize = True
                  IncrementalDisplay = True
                  Picture.Data = {
                    07544269746D6170C6060000424DC60600000000000036000000280000001C00
                    0000140000000100180000000000900600000000000000000000000000000000
                    0000808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                    808080808080808080808080808080808080808080000000C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080
                    808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0
                    C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080808080808080000000
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                    C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808080
                    8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080000000C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0
                    C0000000808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                    FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C00000008080808080808080
                    80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                    FFFFFFC0C0C0C0C0C0000000808080808080808080000000C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0000000
                    808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                    FFFFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080808080000000
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                    C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808080
                    8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0
                    C0C0C0C0000000808080808080808080808080808080808080000000C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                    C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000008080808080808080
                    8080808080808080808080808000000000000000000000000000000000000000
                    0000000000000000000000000000000000000000000000000000000000000000
                    0000000000008080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    8080808080808080808080808080808080808080808080808080808080808080
                    808080808080808080808080808080808080}
                  Transparent = True
                end
                object LI23: TLabel
                  Left = 340
                  Top = 168
                  Width = 12
                  Height = 13
                  Caption = '23'
                  Font.Charset = DEFAULT_CHARSET
                  Font.Color = clBlack
                  Font.Height = -11
                  Font.Name = 'MS Sans Serif'
                  Font.Style = []
                  ParentFont = False
                  Transparent = True
                end
                object lbl20: TStaticText
                  Left = 372
                  Top = 0
                  Width = 110
                  Height = 20
                  Alignment = taRightJustify
                  AutoSize = False
                  BevelInner = bvNone
                  BevelKind = bkFlat
                  BevelOuter = bvRaised
                  Caption = '$000,000,000.00'
                  Color = clWhite
                  ParentColor = False
                  ShowAccelChar = False
                  TabOrder = 0
                end
                object E21: TOvcNumericField
                  Left = 372
                  Top = 66
                  Width = 110
                  Height = 19
                  Cursor = crIBeam
                  DataType = nftDouble
                  AutoSize = False
                  BorderStyle = bsNone
                  CaretOvr.Shape = csBlock
                  Controller = OvcController1
                  Ctl3D = False
                  EFColors.Disabled.BackColor = clWindow
                  EFColors.Disabled.TextColor = clGrayText
                  EFColors.Error.BackColor = clRed
                  EFColors.Error.TextColor = clBlack
                  EFColors.Highlight.BackColor = clHighlight
                  EFColors.Highlight.TextColor = clHighlightText
                  Options = []
                  ParentCtl3D = False
                  PictureMask = '###,###,###.##'
                  TabOrder = 1
                  OnChange = nFringeChange
                  OnKeyDown = nClosingDebtKeyDown
                  RangeHigh = {73B2DBB9838916F2FE43}
                  RangeLow = {73B2DBB9838916F2FEC3}
                end
                object lbl22: TStaticText
                  Left = 372
                  Top = 117
                  Width = 110
                  Height = 20
                  Alignment = taRightJustify
                  AutoSize = False
                  BevelInner = bvNone
                  BevelKind = bkFlat
                  BevelOuter = bvRaised
                  Caption = '$000,000,000.00'
                  Color = clWhite
                  ParentColor = False
                  ShowAccelChar = False
                  TabOrder = 2
                end
                object lbProvTax: TStaticText
                  Left = 372
                  Top = 165
                  Width = 110
                  Height = 20
                  Alignment = taRightJustify
                  AutoSize = False
                  BevelInner = bvNone
                  BevelKind = bkFlat
                  BevelOuter = bvRaised
                  Caption = '$000,000,000.00'
                  Color = clWhite
                  ParentColor = False
                  ShowAccelChar = False
                  TabOrder = 3
                end
              end
            end
          end
        end
      end
    end
    object TSPart3: TTabSheet
      Caption = 'Part 3 - Payment'
      ImageIndex = 2
      object SBPayment: TScrollBox
        Left = 0
        Top = 0
        Width = 625
        Height = 654
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        TabOrder = 0
        object gbPayment: TGroupBox
          Left = 0
          Top = 0
          Width = 603
          Height = 493
          Color = clWhite
          Ctl3D = True
          ParentBackground = False
          ParentColor = False
          ParentCtl3D = False
          TabOrder = 0
          object LMain3: TLabel
            Left = 6
            Top = 0
            Width = 218
            Height = 18
            Caption = 'GST and provisional tax return'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label56: TLabel
            Left = 429
            Top = 64
            Width = 6
            Height = 14
            Caption = '2'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object LSmall3: TLabel
            Left = 515
            Top = 0
            Width = 71
            Height = 18
            Alignment = taRightJustify
            Caption = 'GST 103B'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Arial'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object Label61: TLabel
            Left = 429
            Top = 24
            Width = 6
            Height = 14
            Caption = '1'
            Color = clWhite
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWhite
            Font.Height = -11
            Font.Name = 'Arial'
            Font.Style = []
            ParentColor = False
            ParentFont = False
            Transparent = True
          end
          object GroupBox3: TGroupBox
            Left = 3
            Top = 24
            Width = 597
            Height = 465
            Color = 15197925
            ParentBackground = False
            ParentColor = False
            TabOrder = 0
            object Image23: TImage
              Left = 440
              Top = 106
              Width = 28
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170C6060000424DC60600000000000036000000280000001C00
                0000140000000100180000000000900600000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                808080808080808080808080808080808080808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080
                808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0
                C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080808080808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808080
                8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFF
                FFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0
                C0000000808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C00000008080808080808080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFFC0C0C0C0C0C0000000808080808080808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0000000
                808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                FFFFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808080
                8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0
                C0C0C0C0000000808080808080808080808080808080808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000008080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080808080}
              Transparent = True
              OnClick = Image23Click
            end
            object Image24: TImage
              Left = 440
              Top = 40
              Width = 28
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170C6060000424DC60600000000000036000000280000001C00
                0000140000000100180000000000900600000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                808080808080808080808080808080808080808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080
                808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0
                C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080808080808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808080
                8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFF
                FFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0
                C0000000808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C00000008080808080808080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFFC0C0C0C0C0C0000000808080808080808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0000000
                808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                FFFFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808080
                8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0
                C0C0C0C0000000808080808080808080808080808080808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000008080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080808080}
              Transparent = True
            end
            object Image25: TImage
              Left = 440
              Top = 258
              Width = 28
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170C6060000424DC60600000000000036000000280000001C00
                0000140000000100180000000000900600000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0000000000000
                808080808080808080808080808080808080808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080
                808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFC0
                C0C0C0C0C0C0C0C0C0C0C0000000808080808080808080808080808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C000000080808080808080
                8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFF
                FFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0
                C0000000808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C00000008080808080808080
                80000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFFC0C0C0C0C0C0000000808080808080808080000000C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0000000
                808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFF
                FFFFFFFFFFC0C0C0C0C0C0C0C0C0000000808080808080808080808080000000
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFFFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0
                C0C0000000808080808080808080808080000000C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0FFFFFFFFFFFFC0C0C0C0C0C0C0C0C0C0C0C000000080808080808080808080
                8080808080000000C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0FFFFFFC0C0C0C0C0C0C0C0
                C0C0C0C0000000808080808080808080808080808080808080000000C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0
                C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C0C00000000000008080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080808080}
              Transparent = True
            end
            object Bevel16: TBevel
              Left = 124
              Top = 138
              Width = 310
              Height = 12
              Shape = bsBottomLine
            end
            object Bevel17: TBevel
              Left = 124
              Top = 77
              Width = 310
              Height = 13
              Shape = bsBottomLine
            end
            object Bevel18: TBevel
              Left = 124
              Top = 193
              Width = 310
              Height = 8
              Shape = bsBottomLine
            end
            object Image27: TImage
              Left = 440
              Top = 213
              Width = 28
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170C6060000424DC60600000000000036000000280000001C00
                0000140000000100180000000000900600000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                8080808080808080808080808080808080808080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000FFFFFF000000000000000000000000000000808080808080808080
                8080808080808080800000000000000000000000000000000000000000000000
                00000000000000000000000000000000000000000000000000FFFFFFFFFFFF00
                0000000000000000000000000000808080808080808080808080808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                0000000000808080808080808080808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808080
                8080808080000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
                FFFFFFFF00000000000000000000000080808080808080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
                0000000080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000008080808080808080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFF0000000000000000008080808080808080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
                8080808080808080800000000000000000000000000000000000000000000000
                00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                FFFFFFFFFF000000000000000000000000808080808080808080808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                0000000000808080808080808080808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFF00000000000000000000000000000080808080808080808080
                8080808080000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFF0000000000000000
                0000000000000080808080808080808080808080808080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000008080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080808080}
              Transparent = True
            end
            object Image29: TImage
              Left = 440
              Top = 165
              Width = 28
              Height = 20
              AutoSize = True
              IncrementalDisplay = True
              Picture.Data = {
                07544269746D6170C6060000424DC60600000000000036000000280000001C00
                0000140000000100180000000000900600000000000000000000000000000000
                0000808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                8080808080808080808080808080808080808080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000FFFFFF000000000000000000000000000000808080808080808080
                8080808080808080800000000000000000000000000000000000000000000000
                00000000000000000000000000000000000000000000000000FFFFFFFFFFFF00
                0000000000000000000000000000808080808080808080808080808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                0000000000808080808080808080808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000080808080808080
                8080808080000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFF
                FFFFFFFF00000000000000000000000080808080808080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000
                0000000080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000FFFFFF
                FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000008080808080808080
                8000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
                FFFFFF0000000000000000008080808080808080800000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
                8080808080808080800000000000000000000000000000000000000000000000
                00000000000000000000000000000000000000000000000000FFFFFFFFFFFFFF
                FFFFFFFFFF000000000000000000000000808080808080808080808080000000
                0000000000000000000000000000000000000000000000000000000000000000
                00000000000000000000000000FFFFFFFFFFFFFFFFFF00000000000000000000
                0000000000808080808080808080808080000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                00FFFFFFFFFFFF00000000000000000000000000000080808080808080808080
                8080808080000000000000000000000000000000000000000000000000000000
                000000000000000000000000000000000000000000FFFFFF0000000000000000
                0000000000000080808080808080808080808080808080808000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000008080808080808080
                8080808080808080808080808000000000000000000000000000000000000000
                0000000000000000000000000000000000000000000000000000000000000000
                0000000000008080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                8080808080808080808080808080808080808080808080808080808080808080
                808080808080808080808080808080808080}
              Transparent = True
            end
            object Label73: TLabel
              Left = 443
              Top = 166
              Width = 14
              Height = 16
              Caption = '26'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object Label74: TLabel
              Left = 443
              Top = 215
              Width = 14
              Height = 16
              Caption = '27'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWhite
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object Label75: TLabel
              Left = 443
              Top = 42
              Width = 14
              Height = 16
              Caption = '24'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object WPRichTextLabel1: TWPRichTextLabel
              Left = 124
              Top = 20
              Width = 296
              Height = 65
              RTFText.Data = {
                3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                686172466F6E743A262333393B48656C7665746963614E6575652D426F6C6426
                2333393B3B43686172466F6E7453697A653A3830303B436861725374796C654D
                61736B3A313B436861725374796C654F4E3A313B5D5D2F3E3C6469762063733D
                313E3C6373206E723D322077707374793D5B5B43686172466F6E743A26233339
                3B48656C7665746963614E6575652D426F6C64262333393B3B43686172466F6E
                7453697A653A3930303B436861725374796C654D61736B3A313B436861725374
                796C654F4E3A313B5D5D2F3E3C63206E723D322F3E436F6D70756C736F727920
                70726F766973696F6E616C2074617820706572696F643C2F6469763E0D0A3C64
                69762063733D313E3C6373206E723D332077707374793D5B5B43686172466F6E
                743A262333393B48656C766574696361262333393B3B43686172466F6E745369
                7A653A3930303B5D5D2F3E3C63206E723D332F3E2623383231313B2050726F76
                6973696F6E616C2074617820696E7374616C6D656E7420647565203C63206E72
                3D322F3E6F723C2F6469763E0D0A3C6469762063733D313E3C63206E723D322F
                3E566F6C756E746172792070726F766973696F6E616C2074617820706572696F
                643C2F6469763E0D0A3C6469762063733D313E3C63206E723D332F3E26233832
                31313B20546F74616C20766F6C756E7461727920616D6F756E7420796F752077
                6F756C64206C696B6520746F206D616B653C2F6469763E0D0A}
              LayoutMode = wplayNormal
              AutoZoom = wpAutoZoomOff
              ViewOptions = [wpHideSelection]
              FormatOptions = [wpDisableAutosizeTables]
              FormatOptionsEx = []
              PaperColor = clWindow
              DeskColor = clBtnShadow
              TextSaveFormat = 'AUTO'
              TextLoadFormat = 'AUTO'
            end
            object WPRichTextLabel3: TWPRichTextLabel
              Left = 124
              Top = 156
              Width = 296
              Height = 34
              RTFText.Data = {
                3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                686172466F6E743A262333393B48656C766574696361262333393B3B43686172
                466F6E7453697A653A3830303B5D5D2F3E3C6469762063733D313E3C6373206E
                723D322077707374793D5B5B43686172466F6E743A262333393B48656C766574
                696361262333393B3B43686172466F6E7453697A653A3930303B5D5D2F3E3C63
                206E723D322F3E537562747261637420426F782032352066726F6D20426F7820
                32342E20496620426F78203235206973206C6172676572207468616E3C2F6469
                763E0D0A3C6469762063733D313E3C63206E723D322F3E426F782032342C2065
                6E746572207A65726F202830293C2F6469763E0D0A}
              LayoutMode = wplayNormal
              AutoZoom = wpAutoZoomOff
              ViewOptions = [wpHideSelection]
              FormatOptions = [wpDisableAutosizeTables]
              FormatOptionsEx = []
              PaperColor = clWindow
              DeskColor = clBtnShadow
              TextSaveFormat = 'AUTO'
              TextLoadFormat = 'AUTO'
            end
            object Bevel12: TBevel
              Left = 124
              Top = 238
              Width = 310
              Height = 7
              Shape = bsBottomLine
            end
            object WPRichTextLabel5: TWPRichTextLabel
              Left = 124
              Top = 256
              Width = 310
              Height = 37
              RTFText.Data = {
                3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                686172466F6E743A262333393B48656C766574696361262333393B3B43686172
                466F6E7453697A653A3830303B5D5D2F3E3C6469762063733D313E3C6373206E
                723D322077707374793D5B5B43686172466F6E743A262333393B48656C766574
                696361262333393B3B43686172466F6E7453697A653A3930303B5D5D2F3E3C63
                206E723D322F3E41646420426F7820323620616E6420426F782032373C2F6469
                763E0D0A3C6469762063733D313E3C6373206E723D332077707374793D5B5B43
                686172466F6E743A262333393B48656C7665746963614E6575652D426F6C6426
                2333393B3B43686172466F6E7453697A653A3930303B436861725374796C654D
                61736B3A313B436861725374796C654F4E3A313B5D5D2F3E3C63206E723D332F
                3E5468697320697320796F75722047535420616E642F6F722070726F76697369
                6F6E616C2074617820746F207061793C2F6469763E0D0A}
              LayoutMode = wplayNormal
              AutoZoom = wpAutoZoomOff
              ViewOptions = [wpHideSelection]
              FormatOptions = [wpDisableAutosizeTables]
              FormatOptionsEx = []
              PaperColor = clWindow
              DeskColor = clBtnShadow
              TextSaveFormat = 'AUTO'
              TextLoadFormat = 'AUTO'
            end
            object WPRichTextLabel7: TWPRichTextLabel
              Left = 3
              Top = 15
              Width = 94
              Height = 80
              RTFText.Data = {
                3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
                617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
                43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
                733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
                6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
                50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
                65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
                64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
                54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
                6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
                707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
                543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
                5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
                756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
                74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
                756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
                3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
                3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
                3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
                6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
                3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
                33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
                74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
                36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
                0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
                3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
                6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
                2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
                4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
                3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
                303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
                6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
                3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
                6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
                7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
                3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
                696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
                44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
                7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
                6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
                724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
                3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
                54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
                6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
                494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
                67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
                64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
                626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
                31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
                724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
                4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
                643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
                6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
                393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
                652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
                5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
                262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
                74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
                793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
                393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
                3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
                69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
                756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
                33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
                6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
                332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
                4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
                756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
                454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
                75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
                313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
                54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
                36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
                6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
                62657254455854413A262333393B29262333393B3B4E756D6265725445585442
                3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
                2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
                3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
                686172466F6E743A262333393B48656C7665746963614E6575652D426F6C6426
                2333393B3B43686172466F6E7453697A653A313035303B436861725374796C65
                4D61736B3A313B436861725374796C654F4E3A313B5D5D2F3E3C646976206373
                3D313E3C63206E723D312F3E506172742033202623383231313B3C2F6469763E
                0D0A3C6469762063733D313E3C63206E723D312F3E5061796D656E74203C2F64
                69763E0D0A3C6469763E3C63206E723D312F3E63616C63756C6174696F6E3C2F
                6469763E0D0A}
              LayoutMode = wplayNormal
              AutoZoom = wpAutoZoomOff
              ViewOptions = [wpHideSelection]
              FormatOptions = [wpDisableAutosizeTables]
              FormatOptionsEx = []
              PaperColor = clWindow
              DeskColor = clBtnShadow
              TextSaveFormat = 'AUTO'
              TextLoadFormat = 'AUTO'
            end
            object Label23: TLabel
              Left = 443
              Top = 108
              Width = 14
              Height = 16
              Caption = '25'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              Transparent = True
              OnClick = Image23Click
            end
            object Label25: TLabel
              Left = 443
              Top = 259
              Width = 14
              Height = 16
              Caption = '28'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clBlack
              Font.Height = -13
              Font.Name = 'Arial'
              Font.Style = []
              ParentFont = False
              Transparent = True
            end
            object L25: TLabel
              Left = 127
              Top = 96
              Width = 307
              Height = 54
              AutoSize = False
              Caption = 
                'If Box 10 from page 1 is a refund, enter the amount you would li' +
                'ke to transfer to provisional tax, otherwise enter zero (0).'
              WordWrap = True
            end
            object L27: TLabel
              Left = 127
              Top = 207
              Width = 293
              Height = 38
              AutoSize = False
              Caption = 
                'If Box 15 from page 2 is GST to pay enter the amount here, other' +
                'wise enter zero (0).'
              WordWrap = True
            end
            object lbl27: TStaticText
              Left = 478
              Top = 213
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 0
            end
            object lbl26: TStaticText
              Left = 478
              Top = 165
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 1
            end
            object lbTaxToPay: TStaticText
              Left = 478
              Top = 258
              Width = 110
              Height = 20
              Alignment = taRightJustify
              AutoSize = False
              BevelInner = bvNone
              BevelKind = bkFlat
              BevelOuter = bvRaised
              Caption = '$000,000,000.00'
              Color = clWhite
              ParentColor = False
              ShowAccelChar = False
              TabOrder = 2
            end
            object E25: TOvcNumericField
              Left = 478
              Top = 106
              Width = 110
              Height = 19
              Cursor = crIBeam
              DataType = nftDouble
              AutoSize = False
              BorderStyle = bsNone
              CaretOvr.Shape = csBlock
              Controller = OvcController1
              Ctl3D = False
              EFColors.Disabled.BackColor = clWindow
              EFColors.Disabled.TextColor = clGrayText
              EFColors.Error.BackColor = clRed
              EFColors.Error.TextColor = clBlack
              EFColors.Highlight.BackColor = clHighlight
              EFColors.Highlight.TextColor = clHighlightText
              Options = []
              ParentCtl3D = False
              PictureMask = '###,###,###.##'
              TabOrder = 3
              OnChange = E25Change
              OnKeyDown = nClosingDebtKeyDown
              RangeHigh = {73B2DBB9838916F2FE43}
              RangeLow = {73B2DBB9838916F2FEC3}
            end
            object E24: TOvcNumericField
              Left = 478
              Top = 40
              Width = 110
              Height = 19
              Cursor = crIBeam
              DataType = nftDouble
              AutoSize = False
              BorderStyle = bsNone
              CaretOvr.Shape = csBlock
              Controller = OvcController1
              Ctl3D = False
              EFColors.Disabled.BackColor = clWindow
              EFColors.Disabled.TextColor = clGrayText
              EFColors.Error.BackColor = clRed
              EFColors.Error.TextColor = clBlack
              EFColors.Highlight.BackColor = clHighlight
              EFColors.Highlight.TextColor = clHighlightText
              Options = []
              ParentCtl3D = False
              PictureMask = '###,###,###.##'
              TabOrder = 4
              OnChange = nFringeChange
              OnKeyDown = nClosingDebtKeyDown
              RangeHigh = {73B2DBB9838916F2FE43}
              RangeLow = {73B2DBB9838916F2FEC3}
            end
          end
        end
      end
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
    Left = 80
    Top = 600
  end
end
