object dlgEditBGLSF360Fields: TdlgEditBGLSF360Fields
  Left = 415
  Top = 256
  BorderStyle = bsDialog
  Caption = 'Superfund Details'
  ClientHeight = 450
  ClientWidth = 720
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PrintScale = poPrintToFit
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlDistribution: TPanel
    Left = 0
    Top = 145
    Width = 720
    Height = 267
    Align = alClient
    ParentColor = True
    TabOrder = 3
    Visible = False
    object pcDistribution: TPageControl
      Left = 1
      Top = 1
      Width = 718
      Height = 265
      ActivePage = tsAustralianIncome
      Align = alClient
      TabOrder = 0
      object tsAustralianIncome: TTabSheet
        Caption = 'Australian Income'
        object lblLessOtherAllowableTrustDeductions: TLabel
          Left = 6
          Top = 176
          Width = 184
          Height = 13
          Caption = 'Less Other Allowable Trust Deductions'
          FocusControl = nfLessOtherAllowableTrustDeductions
        end
        object lpLessOtherAllowableTrustDeductions: TLabel
          Left = 383
          Top = 176
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfLessOtherAllowableTrustDeductions
          Visible = False
        end
        inline fmeInterestIncome: TfmeBGLInterestIncome
          Left = 3
          Top = 108
          Width = 442
          Height = 54
          TabOrder = 1
          ExplicitLeft = 3
          ExplicitTop = 108
          inherited nfInterest: TOvcNumericField
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfOtherIncome: TOvcNumericField
            Top = 34
            ExplicitTop = 34
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
        inline fmeFranking: TfmeBGLFranking
          Left = 3
          Top = 11
          Width = 442
          Height = 90
          TabOrder = 0
          ExplicitLeft = 3
          ExplicitTop = 11
          inherited lblFrankingCredits: TLabel
            Top = 69
            ExplicitTop = 69
          end
          inherited btnFrankingCredits: TSpeedButton
            OnClick = frameFrankingbtnCalcClick
          end
          inherited nfFranked: TOvcNumericField
            OnChange = frameFrankingFrankedChange
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfUnfranked: TOvcNumericField
            OnChange = frameFrankingUnfrankedChange
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfFrankingCredits: TOvcNumericField
            OnChange = frameFrankingFrankingCreditsChange
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
        object nfLessOtherAllowableTrustDeductions: TOvcNumericField
          Left = 253
          Top = 174
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 2
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {00000000000000000000}
        end
      end
      object tsCapitalGains: TTabSheet
        Caption = 'Capital Gains'
        ImageIndex = 1
        object lblCGTConcession: TLabel
          Left = 6
          Top = 99
          Width = 206
          Height = 13
          Caption = 'Capital Gain Tax (CGT) Concession Amount'
          FocusControl = nfCGTConcession
        end
        object lpCGTConcession: TLabel
          Left = 409
          Top = 99
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfCGTConcession
          Visible = False
        end
        object nfCGTConcession: TOvcNumericField
          Left = 279
          Top = 97
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 1
          OnKeyPress = nfTFNCreditsKeyPress
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {00000000000000000000}
        end
        inline fmeBGLCashCapitalGainsTax: TfmeBGLCapitalGainsTax
          Left = 3
          Top = 3
          Width = 442
          Height = 90
          TabOrder = 0
          ExplicitLeft = 3
          ExplicitTop = 3
          inherited lpCGTDiscounted: TLabel
            Left = 406
            ExplicitLeft = 406
          end
          inherited lpCGTIndexation: TLabel
            Left = 406
            ExplicitLeft = 406
          end
          inherited lpCGTOther: TLabel
            Left = 406
            ExplicitLeft = 406
          end
          inherited nfCGTDiscounted: TOvcNumericField
            Left = 276
            ExplicitLeft = 276
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTIndexation: TOvcNumericField
            Left = 276
            ExplicitLeft = 276
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTOther: TOvcNumericField
            Left = 276
            ExplicitLeft = 276
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
        object grpForeign: TGroupBox
          Left = 0
          Top = 124
          Width = 710
          Height = 113
          Align = alBottom
          TabOrder = 2
          object lblForeignCGT: TLabel
            Left = 279
            Top = 9
            Width = 101
            Height = 13
            Caption = 'Foreign Capital Gains'
          end
          object lblTaxPaid: TLabel
            Left = 447
            Top = 9
            Width = 151
            Height = 13
            Caption = 'Income Tax Paid Offset/Credits'
          end
          object lblBeforeDiscount: TLabel
            Left = 6
            Top = 33
            Width = 132
            Height = 13
            Caption = 'Discounted Before Discount'
          end
          object lblIndexationMethod: TLabel
            Left = 6
            Top = 61
            Width = 91
            Height = 13
            Caption = 'Indexation Method'
          end
          object lblOtherMethod: TLabel
            Left = 6
            Top = 89
            Width = 67
            Height = 13
            Caption = 'Other Method'
          end
          object nfForeignCGTBeforeDiscount: TOvcNumericField
            Left = 279
            Top = 26
            Width = 129
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            PictureMask = '#,###,###,###.##'
            TabOrder = 0
            OnKeyPress = nfTFNCreditsKeyPress
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          object nfForeignCGTIndexationMethod: TOvcNumericField
            Left = 279
            Top = 54
            Width = 129
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            PictureMask = '#,###,###,###.##'
            TabOrder = 1
            OnKeyPress = nfTFNCreditsKeyPress
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          object nfForeignCGTOtherMethod: TOvcNumericField
            Left = 279
            Top = 82
            Width = 129
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            PictureMask = '#,###,###,###.##'
            TabOrder = 2
            OnKeyPress = nfTFNCreditsKeyPress
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          object nfTaxPaidBeforeDiscount: TOvcNumericField
            Left = 447
            Top = 26
            Width = 129
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            PictureMask = '#,###,###,###.##'
            TabOrder = 3
            OnKeyPress = nfTFNCreditsKeyPress
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          object nfTaxPaidIndexationMethod: TOvcNumericField
            Left = 447
            Top = 54
            Width = 129
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            PictureMask = '#,###,###,###.##'
            TabOrder = 4
            OnKeyPress = nfTFNCreditsKeyPress
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          object nfTaxPaidOtherMethod: TOvcNumericField
            Left = 447
            Top = 82
            Width = 129
            Height = 20
            Cursor = crIBeam
            DataType = nftDouble
            AutoSize = False
            BorderStyle = bsNone
            CaretOvr.Shape = csBlock
            EFColors.Disabled.BackColor = clWindow
            EFColors.Disabled.TextColor = clGrayText
            EFColors.Error.BackColor = clRed
            EFColors.Error.TextColor = clBlack
            EFColors.Highlight.BackColor = clHighlight
            EFColors.Highlight.TextColor = clHighlightText
            Options = []
            PictureMask = '#,###,###,###.##'
            TabOrder = 5
            OnKeyPress = nfTFNCreditsKeyPress
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
      end
      object tsForeignIncome: TTabSheet
        Caption = 'Foreign Income'
        ImageIndex = 2
        object lblAssessableForeignSourceIncome: TLabel
          Left = 0
          Top = 6
          Width = 166
          Height = 13
          Caption = 'Assessable Foreign Source Income'
          FocusControl = nfAssessableForeignSourceIncome
        end
        object lpAssessableForeignSourceIncome: TLabel
          Left = 379
          Top = 6
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfAssessableForeignSourceIncome
          Visible = False
        end
        object lblOtherNetForeignSourceIncome: TLabel
          Left = 0
          Top = 32
          Width = 161
          Height = 13
          Caption = 'Other Net Foreign Source Income'
          FocusControl = nfOtherNetForeignSourceIncome
        end
        object lpOtherNetForeignSourceIncome: TLabel
          Left = 379
          Top = 32
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfOtherNetForeignSourceIncome
          Visible = False
        end
        object lblCashDistribution: TLabel
          Left = 0
          Top = 59
          Width = 81
          Height = 13
          Caption = 'Cash Distribution'
          FocusControl = nfCashDistribution
        end
        object lpCashDistribution: TLabel
          Left = 379
          Top = 59
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfCashDistribution
          Visible = False
        end
        object lblTaxExemptedAmounts: TLabel
          Left = 407
          Top = 6
          Width = 114
          Height = 13
          Caption = 'Tax Exempted Amounts'
          FocusControl = nfTaxExemptedAmounts
        end
        object lpTaxExemptedAmounts: TLabel
          Left = 684
          Top = 6
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfTaxExemptedAmounts
          Visible = False
        end
        object lblTaxFreeAmounts: TLabel
          Left = 407
          Top = 32
          Width = 88
          Height = 13
          Caption = 'Tax Free Amounts'
          FocusControl = nfTaxFreeAmounts
        end
        object lpTaxFreeAmounts: TLabel
          Left = 684
          Top = 31
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfTaxFreeAmounts
          Visible = False
        end
        object lblTaxDeferredAmounts: TLabel
          Left = 407
          Top = 59
          Width = 109
          Height = 13
          Caption = 'Tax Deferred Amounts'
          FocusControl = nfTaxDeferredAmounts
        end
        object lpTaxDeferredAmounts: TLabel
          Left = 684
          Top = 59
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfTaxDeferredAmounts
          Visible = False
        end
        object lblOtherExpenses: TLabel
          Left = 407
          Top = 88
          Width = 77
          Height = 13
          Caption = 'Other Expenses'
          FocusControl = nfOtherExpenses
        end
        object lpOtherExpenses: TLabel
          Left = 684
          Top = 88
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfOtherExpenses
          Visible = False
        end
        object nfAssessableForeignSourceIncome: TOvcNumericField
          Left = 250
          Top = 3
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 0
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {5C8FC2F5FF276BEE1CC0}
        end
        object nfOtherNetForeignSourceIncome: TOvcNumericField
          Left = 250
          Top = 29
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 1
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {5C8FC2F5FF276BEE1CC0}
        end
        object nfCashDistribution: TOvcNumericField
          Left = 250
          Top = 55
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 2
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {5C8FC2F5FF276BEE1CC0}
        end
        object nfTaxExemptedAmounts: TOvcNumericField
          Left = 555
          Top = 3
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 4
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {5C8FC2F5FF276BEE1CC0}
        end
        object nfTaxFreeAmounts: TOvcNumericField
          Left = 555
          Top = 29
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 5
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {5C8FC2F5FF276BEE1CC0}
        end
        object nfTaxDeferredAmounts: TOvcNumericField
          Left = 555
          Top = 55
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 6
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {5C8FC2F5FF276BEE1CC0}
        end
        inline fmeBGLForeignTax1: TfmeBGLForeignTax
          Left = 0
          Top = 77
          Width = 401
          Height = 134
          TabOrder = 3
          ExplicitTop = 77
          ExplicitWidth = 401
          ExplicitHeight = 134
          inherited lblForeignIncomeTaxOffset: TLabel
            Left = 0
            ExplicitLeft = 0
          end
          inherited lblAUFrankingCreditsFromNZCompany: TLabel
            Left = 0
            Top = 31
            ExplicitLeft = 0
            ExplicitTop = 31
          end
          inherited lpAUFrankingCreditsFromNZCompany: TLabel
            Top = 31
            ExplicitTop = 31
          end
          inherited lblTFNAmountsWithheld: TLabel
            Left = 0
            Top = 57
            ExplicitLeft = 0
            ExplicitTop = 57
          end
          inherited lpTFNAmountsWithheld: TLabel
            Top = 57
            ExplicitTop = 57
          end
          inherited lblNonResidentWithholdingTax: TLabel
            Left = 0
            Top = 83
            ExplicitLeft = 0
            ExplicitTop = 83
          end
          inherited lpNonResidentWithholdingTax: TLabel
            Top = 83
            ExplicitTop = 83
          end
          inherited lblLICDeductions: TLabel
            Left = 0
            Top = 109
            ExplicitLeft = 0
            ExplicitTop = 109
          end
          inherited lpLICDeductions: TLabel
            Top = 109
            ExplicitTop = 109
          end
          inherited nfForeignIncomeTaxOffset: TOvcNumericField
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfAUFrankingCreditsFromNZCompany: TOvcNumericField
            Top = 29
            ExplicitTop = 29
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfTFNAmountsWithheld: TOvcNumericField
            Top = 55
            ExplicitTop = 55
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfNonResidentWithholdingTax: TOvcNumericField
            Top = 81
            ExplicitTop = 81
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfLICDeductions: TOvcNumericField
            Top = 107
            ExplicitTop = 107
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
        end
        object nfOtherExpenses: TOvcNumericField
          Left = 555
          Top = 86
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 7
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {00000000000000000000}
        end
      end
      object tsNonCashCapitalGains: TTabSheet
        Caption = 'Non-Cash Capital Gains/Losses'
        ImageIndex = 3
        object lpCGTCapitalLosses: TLabel
          Left = 380
          Top = 99
          Width = 11
          Height = 13
          Caption = '%'
          FocusControl = nfCGTCapitalLosses
          Visible = False
        end
        object lblCGTCapitalLosses: TLabel
          Left = 3
          Top = 99
          Width = 68
          Height = 13
          Caption = 'Capital Losses'
        end
        object nfCGTCapitalLosses: TOvcNumericField
          Left = 250
          Top = 97
          Width = 129
          Height = 20
          Cursor = crIBeam
          DataType = nftDouble
          AutoSize = False
          BorderStyle = bsNone
          CaretOvr.Shape = csBlock
          EFColors.Disabled.BackColor = clWindow
          EFColors.Disabled.TextColor = clGrayText
          EFColors.Error.BackColor = clRed
          EFColors.Error.TextColor = clBlack
          EFColors.Highlight.BackColor = clHighlight
          EFColors.Highlight.TextColor = clHighlightText
          Options = []
          PictureMask = '#,###,###,###.##'
          TabOrder = 1
          OnKeyPress = nfTFNCreditsKeyPress
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {00000000000000000000}
        end
        inline fmeBGLNonCashCapitalGainsTax: TfmeBGLCapitalGainsTax
          Left = 0
          Top = 3
          Width = 442
          Height = 90
          TabOrder = 0
          ExplicitTop = 3
          inherited nfCGTDiscounted: TOvcNumericField
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTIndexation: TOvcNumericField
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTOther: TOvcNumericField
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
      end
    end
  end
  object pnlDividend: TPanel
    Left = 0
    Top = 145
    Width = 720
    Height = 267
    Align = alClient
    TabOrder = 4
    Visible = False
    object lpForeignIncome: TLabel
      Left = 383
      Top = 90
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = fmeBGLForeignTax2.nfForeignIncomeTaxOffset
      Visible = False
    end
    object lblForeignIncome: TLabel
      Left = 5
      Top = 90
      Width = 74
      Height = 13
      Caption = 'Foreign Income'
      FocusControl = nfForeignIncome
    end
    inline fmeBGLFranking: TfmeBGLFranking
      Left = 3
      Top = 3
      Width = 442
      Height = 81
      TabOrder = 0
      ExplicitLeft = 3
      ExplicitTop = 3
      ExplicitHeight = 81
      inherited lblUnfranked: TLabel
        Top = 31
        ExplicitTop = 31
      end
      inherited lpUnfranked: TLabel
        Top = 31
        ExplicitTop = 31
      end
      inherited lblFrankingCredits: TLabel
        Left = 2
        Top = 58
        ExplicitLeft = 2
        ExplicitTop = 58
      end
      inherited btnFrankingCredits: TSpeedButton
        Top = 54
        OnClick = frameFrankingbtnCalcClick
        ExplicitTop = 54
      end
      inherited nfFranked: TOvcNumericField
        OnClick = frameFrankingFrankedChange
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {00000000000000000000}
      end
      inherited nfUnfranked: TOvcNumericField
        Top = 29
        OnClick = frameFrankingUnfrankedChange
        ExplicitTop = 29
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {00000000000000000000}
      end
      inherited nfFrankingCredits: TOvcNumericField
        Top = 56
        OnClick = frameFrankingFrankingCreditsChange
        ExplicitTop = 56
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {00000000000000000000}
      end
    end
    inline fmeBGLForeignTax2: TfmeBGLForeignTax
      Left = 1
      Top = 117
      Width = 390
      Height = 147
      TabOrder = 2
      ExplicitLeft = 1
      ExplicitTop = 117
      ExplicitWidth = 390
      ExplicitHeight = 147
      inherited lblForeignIncomeTaxOffset: TLabel
        Left = 4
        Top = 2
        Width = 166
        Caption = 'Foreign Income Tax Offset Credits'
        ExplicitLeft = 4
        ExplicitTop = 2
        ExplicitWidth = 166
      end
      inherited lpForeignIncomeTaxOffset: TLabel
        Top = 2
        ExplicitTop = 2
      end
      inherited lblAUFrankingCreditsFromNZCompany: TLabel
        Left = 4
        Top = 31
        ExplicitLeft = 4
        ExplicitTop = 31
      end
      inherited lpAUFrankingCreditsFromNZCompany: TLabel
        Top = 31
        ExplicitTop = 31
      end
      inherited lblTFNAmountsWithheld: TLabel
        Left = 4
        Top = 61
        ExplicitLeft = 4
        ExplicitTop = 61
      end
      inherited lpTFNAmountsWithheld: TLabel
        Top = 61
        ExplicitTop = 61
      end
      inherited lblNonResidentWithholdingTax: TLabel
        Left = 4
        Top = 91
        ExplicitLeft = 4
        ExplicitTop = 91
      end
      inherited lpNonResidentWithholdingTax: TLabel
        Top = 91
        ExplicitTop = 91
      end
      inherited lblLICDeductions: TLabel
        Left = 4
        Top = 120
        ExplicitLeft = 4
        ExplicitTop = 120
      end
      inherited lpLICDeductions: TLabel
        Top = 120
        ExplicitTop = 120
      end
      inherited nfForeignIncomeTaxOffset: TOvcNumericField
        Left = 252
        Top = 0
        ExplicitLeft = 252
        ExplicitTop = 0
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      inherited nfAUFrankingCreditsFromNZCompany: TOvcNumericField
        Left = 252
        Top = 29
        ExplicitLeft = 252
        ExplicitTop = 29
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      inherited nfTFNAmountsWithheld: TOvcNumericField
        Left = 252
        Top = 59
        ExplicitLeft = 252
        ExplicitTop = 59
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      inherited nfNonResidentWithholdingTax: TOvcNumericField
        Left = 252
        Top = 89
        ExplicitLeft = 252
        ExplicitTop = 89
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      inherited nfLICDeductions: TOvcNumericField
        Left = 252
        Top = 118
        ExplicitLeft = 252
        ExplicitTop = 118
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
    end
    object nfForeignIncome: TOvcNumericField
      Left = 253
      Top = 88
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 1
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
  end
  object pnlInterest: TPanel
    Left = 0
    Top = 145
    Width = 720
    Height = 267
    Align = alClient
    TabOrder = 5
    Visible = False
    object lblInterest: TLabel
      Left = 3
      Top = 7
      Width = 69
      Height = 13
      Caption = 'Gross Interest'
      FocusControl = nfInterest
    end
    object lpInterest: TLabel
      Left = 352
      Top = 7
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = fmeInterestIncome.nfInterest
      Visible = False
    end
    object lblOtherIncome: TLabel
      Left = 3
      Top = 39
      Width = 66
      Height = 13
      Caption = 'Other Income'
      FocusControl = nfOtherIncome
    end
    object lpOtherIncome: TLabel
      Left = 352
      Top = 39
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = fmeInterestIncome.nfOtherIncome
      Visible = False
    end
    object lblTFNAmountsWithheld: TLabel
      Left = 3
      Top = 67
      Width = 103
      Height = 13
      Caption = 'TFN Amounts Witheld'
      FocusControl = nfTFNAmountsWithheld
    end
    object lpTFNAmountsWithheld: TLabel
      Left = 352
      Top = 67
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = fmeBGLForeignTax2.nfTFNAmountsWithheld
      Visible = False
    end
    object lblNonResidentWithholdingTax: TLabel
      Left = 3
      Top = 97
      Width = 145
      Height = 13
      Caption = 'Non-Resident Withholding Tax'
      FocusControl = nfNonResidentWithholdingTax
    end
    object lpNonResidentWithholdingTax: TLabel
      Left = 352
      Top = 97
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = fmeBGLForeignTax2.nfNonResidentWithholdingTax
      Visible = False
    end
    object nfInterest: TOvcNumericField
      Left = 222
      Top = 5
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 0
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfOtherIncome: TOvcNumericField
      Left = 222
      Top = 37
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 1
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfTFNAmountsWithheld: TOvcNumericField
      Left = 222
      Top = 65
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 2
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object nfNonResidentWithholdingTax: TOvcNumericField
      Left = 222
      Top = 95
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 3
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
  end
  object pnlShareTrade: TPanel
    Left = 0
    Top = 145
    Width = 720
    Height = 267
    Align = alClient
    TabOrder = 6
    Visible = False
    object lblShareBrokerage: TLabel
      Left = 3
      Top = 42
      Width = 49
      Height = 13
      Caption = 'Brokerage'
      FocusControl = fmeInterestIncome.nfInterest
    end
    object lpShareBrokerage: TLabel
      Left = 352
      Top = 42
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = fmeInterestIncome.nfInterest
      Visible = False
    end
    object lblShareConsideration: TLabel
      Left = 3
      Top = 71
      Width = 66
      Height = 13
      Caption = 'Consideration'
      FocusControl = fmeInterestIncome.nfOtherIncome
    end
    object lpShareConsideration: TLabel
      Left = 352
      Top = 71
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = fmeInterestIncome.nfOtherIncome
      Visible = False
    end
    object lblShareGSTAmount: TLabel
      Left = 3
      Top = 99
      Width = 59
      Height = 13
      Caption = 'GST Amount'
      FocusControl = fmeBGLForeignTax2.nfTFNAmountsWithheld
    end
    object lpShareGSTAmount: TLabel
      Left = 352
      Top = 99
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = fmeBGLForeignTax2.nfTFNAmountsWithheld
      Visible = False
    end
    object lblShareGSTRate: TLabel
      Left = 3
      Top = 129
      Width = 45
      Height = 13
      Caption = 'GST Rate'
      FocusControl = fmeBGLForeignTax2.nfNonResidentWithholdingTax
    end
    object lpShareTradeUnits: TLabel
      Left = 352
      Top = 14
      Width = 11
      Height = 13
      Caption = '%'
      FocusControl = fmeInterestIncome.nfInterest
      Visible = False
    end
    object lblShareTradeUnits: TLabel
      Left = 3
      Top = 14
      Width = 24
      Height = 13
      Caption = 'Units'
      FocusControl = fmeInterestIncome.nfInterest
    end
    object nfShareBrokerage: TOvcNumericField
      Left = 222
      Top = 39
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 1
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfShareConsideration: TOvcNumericField
      Left = 222
      Top = 68
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 2
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfShareGSTAmount: TOvcNumericField
      Left = 222
      Top = 96
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 3
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object cmbxShareGSTRate: TcxComboBox
      Left = 222
      Top = 126
      Properties.Alignment.Horz = taLeftJustify
      Properties.DropDownAutoWidth = False
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownWidth = 300
      Properties.Items.Strings = (
        ''
        '100'
        '75'
        '0')
      Properties.OnChange = cmbxAccountPropertiesChange
      Properties.OnDrawItem = cmbxAccountPropertiesDrawItem
      Style.BorderStyle = ebs3D
      Style.LookAndFeel.Kind = lfStandard
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.TransparentBorder = True
      Style.ButtonStyle = bts3D
      Style.PopupBorderStyle = epbsDefault
      StyleDisabled.LookAndFeel.Kind = lfStandard
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfStandard
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfStandard
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 4
      Width = 130
    end
    object nfShareTradeUnits: TOvcNumericField
      Left = 222
      Top = 11
      Width = 129
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###,###,###.##'
      TabOrder = 0
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
  end
  object pnlTransactionInfo: TPanel
    Left = 0
    Top = 73
    Width = 720
    Height = 72
    Align = alTop
    TabOrder = 2
    object lblAccount: TLabel
      Left = 8
      Top = 9
      Width = 39
      Height = 13
      Caption = 'Account'
    end
    object btnChart: TSpeedButton
      Left = 202
      Top = 6
      Width = 28
      Height = 22
      Glyph.Data = {
        36060000424D3606000000000000360000002800000020000000100000000100
        18000000000000060000C21E0000C21E00000000000000000000FF00FF844200
        8442004242424242424242424242424242424242424242424242424242424242
        42000000FF00FFFF00FFFFFFFFE6E6E622222222222242424242424242424242
        4242424242424242424242424242424242424242000000E6E6E6FF00FF844200
        C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6C6C6C6C6C6C6C6C6C6C6
        C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200844200844200844200844200844200424242C6C6C6C6C6C6C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C622222222222222222222
        2222222222222222424242C6C6C6C6C6C6C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF844200FFFFFF000000C6C6C6C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFF222222FFFFFF000000C6C6C6C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200FFFFFF00FFFFFFFFFF00FFFF84420000FFFFFFFFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FFFFFFFDFDFDFF
        FFFFFDFDFD222222FDFDFDFFFFFF222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF844200844200844200844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFF222222222222222222222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200FFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FFFFFFFDFDFDFF
        FFFFFDFDFDFFFFFFFDFDFDFFFFFF222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFFFDFDFDFFFFFFFDFDFD222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200FFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FFFFFFFDFDFDFF
        FFFFFDFDFDFFFFFFFDFDFDFFFFFF222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFFFDFDFDFFFFFFFDFDFD222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200FFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FFFFFFFDFDFDFF
        FFFFFDFDFDFFFFFFFDFDFDFFFFFF222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C684420000FFFFFFFFFF00FFFFFFFFFF00FFFFFFFFFF00FFFF844200C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C6222222FDFDFDFFFFFFFD
        FDFDFFFFFFFDFDFDFFFFFFFDFDFD222222C6C6C6000000E6E6E6FF00FF844200
        C6C6C6844200424242846363846363846363846363846363424242424242C6C6
        C6000000FF00FFFF00FFFFFFFFE6E6E6222222C6C6C622222242424264646464
        6464646464646464646464424242424242C6C6C6000000E6E6E6FF00FF844200
        844200844200424242000000FFFFFFFFFFFFFFFFFF8484840000000000000000
        00000000FF00FFFF00FFFFFFFFE6E6E6222222222222222222424242000000FF
        FFFFFFFFFFFFFFFF848484000000000000000000000000E6E6E6FF00FFFF00FF
        FF00FFFF00FFFF00FF000000C6C6C6C6C6C6C6C6C6424242FF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFFFFFFE6E6E6E6E6E6E6E6E6E6E6E6E6E6E6000000C6
        C6C6C6C6C6C6C6C6424242E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6FF00FFFF00FF
        FF00FFFF00FFFF00FF000000424242000000424242422121FF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFFFFFFE6E6E6E6E6E6E6E6E6E6E6E6E6E6E600000042
        4242000000424242222222E6E6E6E6E6E6E6E6E6E6E6E6E6E6E6}
      NumGlyphs = 2
      OnClick = btnChartClick
    end
    object lblUnits: TLabel
      Left = 244
      Top = 9
      Width = 24
      Height = 13
      Caption = 'Units'
      Visible = False
    end
    object lblEntryType: TLabel
      Left = 8
      Top = 42
      Width = 53
      Height = 13
      Caption = 'Entry Type'
      Visible = False
    end
    object lbldispEntryType: TLabel
      Left = 73
      Top = 42
      Width = 79
      Height = 13
      Caption = 'lbldispEntryType'
      Visible = False
    end
    object lblCashDate: TLabel
      Left = 505
      Top = 9
      Width = 50
      Height = 13
      Caption = 'Cash Date'
      Visible = False
    end
    object lblAccrualDate: TLabel
      Left = 244
      Top = 42
      Width = 61
      Height = 13
      Caption = 'Accrual Date'
      Visible = False
    end
    object lblRecordDate: TLabel
      Left = 505
      Top = 42
      Width = 60
      Height = 13
      Caption = 'Record Date'
      Visible = False
    end
    object cmbxAccount: TcxComboBox
      Left = 67
      Top = 6
      Properties.Alignment.Horz = taLeftJustify
      Properties.DropDownAutoWidth = False
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownWidth = 300
      Properties.OnChange = cmbxAccountPropertiesChange
      Properties.OnDrawItem = cmbxAccountPropertiesDrawItem
      Style.BorderStyle = ebs3D
      Style.LookAndFeel.Kind = lfStandard
      Style.LookAndFeel.NativeStyle = True
      Style.Shadow = False
      Style.TransparentBorder = True
      Style.ButtonStyle = bts3D
      Style.PopupBorderStyle = epbsDefault
      StyleDisabled.LookAndFeel.Kind = lfStandard
      StyleDisabled.LookAndFeel.NativeStyle = True
      StyleFocused.LookAndFeel.Kind = lfStandard
      StyleFocused.LookAndFeel.NativeStyle = True
      StyleHot.LookAndFeel.Kind = lfStandard
      StyleHot.LookAndFeel.NativeStyle = True
      TabOrder = 0
      OnKeyDown = cmbxAccountKeyDown
      Width = 131
    end
    object nfUnits: TOvcNumericField
      Left = 325
      Top = 9
      Width = 121
      Height = 20
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '###,###,###.####'
      TabOrder = 1
      Visible = False
      OnKeyDown = nfUnitsKeyDown
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
    object eCashDate: TOvcPictureField
      Left = 583
      Top = 8
      Width = 107
      Height = 20
      Cursor = crIBeam
      DataType = pftDate
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      ControlCharColor = clRed
      DecimalPlaces = 0
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Epoch = 1970
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
      PictureMask = 'DD/mm/yy'
      TabOrder = 2
      Visible = False
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object eAccrualDate: TOvcPictureField
      Left = 325
      Top = 40
      Width = 121
      Height = 20
      Cursor = crIBeam
      DataType = pftDate
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      ControlCharColor = clRed
      DecimalPlaces = 0
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Epoch = 1970
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
      PictureMask = 'DD/mm/yy'
      TabOrder = 3
      Visible = False
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object eRecordDate: TOvcPictureField
      Left = 583
      Top = 40
      Width = 107
      Height = 20
      Cursor = crIBeam
      DataType = pftDate
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      ControlCharColor = clRed
      DecimalPlaces = 0
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Epoch = 1970
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
      PictureMask = 'DD/mm/yy'
      TabOrder = 4
      Visible = False
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
  end
  object pnlFooters: TPanel
    Left = 0
    Top = 412
    Width = 720
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TButton
      Left = 463
      Top = 6
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 544
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnClear: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Clear All'
      TabOrder = 2
      OnClick = btnClearClick
    end
    object btnBack: TBitBtn
      Left = 283
      Top = 6
      Width = 75
      Height = 25
      Caption = '&Prev'
      TabOrder = 3
      OnClick = btnBackClick
      Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF0000000000000000000000000000000000BDBD0000BDBD0000BDBD00000000
        0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF0000000000BDBD0000BDBD0000BDBD0000BDBD0000BDBD0000BDBD
        0000BDBD000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD0000BDBD0000BDBD
        000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD000000000000FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
    end
    object btnNext: TBitBtn
      Left = 364
      Top = 6
      Width = 75
      Height = 25
      Caption = '&Next'
      TabOrder = 4
      OnClick = btnNextClick
      Glyph.Data = {
        36040000424D3604000000000000360000002800000010000000100000000100
        2000000000000004000000000000000000000000000000000000FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD000000000000FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD0000BDBD0000BDBD
        000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF0000000000BDBD0000BDBD0000BDBD0000BDBD0000BDBD0000BDBD
        0000BDBD000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF0000000000000000000000000000000000BDBD0000BDBD0000BDBD00000000
        0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF0000000000BDBD0000BDBD0000BDBD00000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
        0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
        FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
      Layout = blGlyphRight
    end
  end
  object pnlHeaderInfo: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 73
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      720
      73)
    object lblDate: TLabel
      Left = 8
      Top = 16
      Width = 23
      Height = 13
      Caption = 'Date'
    end
    object lbldispDate: TLabel
      Left = 8
      Top = 40
      Width = 52
      Height = 13
      Caption = 'lbldispDate'
    end
    object lbldispAmount: TLabel
      Left = 72
      Top = 40
      Width = 113
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lbldispAmount'
    end
    object lblAmount: TLabel
      Left = 136
      Top = 16
      Width = 37
      Height = 13
      Caption = 'Amount'
    end
    object lblNarration: TLabel
      Left = 200
      Top = 16
      Width = 45
      Height = 13
      Caption = 'Narration'
    end
    object lbldispNarration: TLabel
      Left = 200
      Top = 40
      Width = 511
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'lbldispNarration'
      ExplicitWidth = 407
    end
  end
end
