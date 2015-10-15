object dlgEditBGLSF360Fields: TdlgEditBGLSF360Fields
  Left = 415
  Top = 256
  BorderStyle = bsDialog
  Caption = 'Superfund Details'
  ClientHeight = 450
  ClientWidth = 709
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
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
  TextHeight = 17
  object pnlDistribution: TPanel
    Left = 0
    Top = 145
    Width = 709
    Height = 267
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 2
    Visible = False
    object lineDistribution: TShape
      Left = 0
      Top = 0
      Width = 709
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 720
    end
    object pcDistribution: TPageControl
      Left = 0
      Top = 1
      Width = 709
      Height = 266
      ActivePage = tsAustralianIncome
      Align = alClient
      TabOrder = 0
      object tsAustralianIncome: TTabSheet
        Caption = 'Australian Income'
        object lblLessOtherAllowableTrustDeductions: TLabel
          Left = 6
          Top = 200
          Width = 224
          Height = 17
          Caption = 'Less Other Allowable Trust Deductions'
          FocusControl = nfLessOtherAllowableTrustDeductions
        end
        object lpLessOtherAllowableTrustDeductions: TLabel
          Left = 393
          Top = 200
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfLessOtherAllowableTrustDeductions
          Visible = False
        end
        inline fmeDist_AU_Income_InterestIncome: TfmeBGLInterestIncome
          Left = 0
          Top = 132
          Width = 450
          Height = 54
          TabOrder = 1
          ExplicitTop = 132
          ExplicitWidth = 450
          inherited lblInterest: TLabel
            Left = 6
            Width = 81
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 81
            ExplicitHeight = 17
          end
          inherited lpInterest: TLabel
            Left = 393
            Height = 17
            ExplicitLeft = 393
            ExplicitHeight = 17
          end
          inherited lpOtherIncome: TLabel
            Left = 393
            Height = 17
            ExplicitLeft = 393
            ExplicitHeight = 17
          end
          inherited lblOtherIncome: TLabel
            Left = 6
            Width = 79
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 79
            ExplicitHeight = 17
          end
          inherited nfInterest: TOvcNumericField
            Left = 260
            Top = 2
            OnChange = OnFmeInterestIncomeFieldChange
            ExplicitLeft = 260
            ExplicitTop = 2
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfOtherIncome: TOvcNumericField
            Left = 260
            OnChange = OnFmeInterestIncomeFieldChange
            ExplicitLeft = 260
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
        inline fmeDist_AU_Income_Franking: TfmeBGLFranking
          Left = 0
          Top = 11
          Width = 450
          Height = 90
          TabOrder = 0
          ExplicitTop = 11
          ExplicitWidth = 450
          inherited lblFranked: TLabel
            Left = 6
            Width = 46
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 46
            ExplicitHeight = 17
          end
          inherited lpFranked: TLabel
            Left = 393
            Height = 17
            ExplicitLeft = 393
            ExplicitHeight = 17
          end
          inherited lblUnfranked: TLabel
            Left = 6
            Width = 60
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 60
            ExplicitHeight = 17
          end
          inherited lpUnfranked: TLabel
            Left = 393
            Height = 17
            ExplicitLeft = 393
            ExplicitHeight = 17
          end
          inherited lblFrankingCredits: TLabel
            Left = 6
            Width = 94
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 94
            ExplicitHeight = 17
          end
          inherited btnFrankingCredits: TSpeedButton
            Left = 393
            Top = 64
            OnClick = frameFrankingbtnCalcClick
            ExplicitLeft = 393
            ExplicitTop = 64
          end
          inherited nfFranked: TOvcNumericField
            Left = 260
            OnChange = frameFrankingFrankedChange
            ExplicitLeft = 260
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfUnfranked: TOvcNumericField
            Left = 260
            OnChange = frameFrankingUnfrankedChange
            ExplicitLeft = 260
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfFrankingCredits: TOvcNumericField
            Left = 260
            OnChange = frameFrankingFrankingCreditsChange
            ExplicitLeft = 260
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
        object nfLessOtherAllowableTrustDeductions: TOvcNumericField
          Left = 260
          Top = 198
          Width = 132
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
          Top = 86
          Width = 249
          Height = 17
          Caption = 'Capital Gain Tax (CGT) Concession Amount'
          FocusControl = nfCGTConcession
        end
        object lpCGTConcession: TLabel
          Left = 393
          Top = 86
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfCGTConcession
          Visible = False
        end
        object lblForeignCGT: TLabel
          Left = 264
          Top = 133
          Width = 124
          Height = 17
          Caption = 'Foreign Capital Gains'
        end
        object lblTaxPaid: TLabel
          Left = 451
          Top = 114
          Width = 95
          Height = 17
          Caption = 'Income Tax Paid'
        end
        object lblBeforeDiscount: TLabel
          Left = 6
          Top = 158
          Width = 92
          Height = 17
          Caption = 'Before Discount'
        end
        object lblIndexationMethod: TLabel
          Left = 6
          Top = 184
          Width = 110
          Height = 17
          Caption = 'Indexation Method'
        end
        object lblOtherMethod: TLabel
          Left = 6
          Top = 210
          Width = 83
          Height = 17
          Caption = 'Other Method'
        end
        object lineCapitalGainsTab: TShape
          Left = 0
          Top = 113
          Width = 720
          Height = 1
          Pen.Color = clSilver
        end
        object lblOffset_Credits: TLabel
          Left = 458
          Top = 130
          Width = 81
          Height = 17
          Caption = 'Offset/Credits'
        end
        object nfCGTConcession: TOvcNumericField
          Left = 260
          Top = 85
          Width = 132
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
        inline fmeDist_CashCapitalGains_CGT: TfmeBGLCapitalGainsTax
          Left = 0
          Top = 3
          Width = 450
          Height = 80
          TabOrder = 0
          ExplicitTop = 3
          ExplicitWidth = 450
          ExplicitHeight = 80
          inherited lblCGTDiscounted: TLabel
            Left = 6
            Width = 243
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 243
            ExplicitHeight = 17
          end
          inherited lpCGTDiscounted: TLabel
            Left = 393
            Height = 17
            ExplicitLeft = 393
            ExplicitHeight = 17
          end
          inherited lblCGTIndexation: TLabel
            Left = 6
            Top = 30
            Width = 199
            Height = 17
            ExplicitLeft = 6
            ExplicitTop = 30
            ExplicitWidth = 199
            ExplicitHeight = 17
          end
          inherited lpCGTIndexation: TLabel
            Left = 393
            Top = 30
            Height = 17
            ExplicitLeft = 393
            ExplicitTop = 30
            ExplicitHeight = 17
          end
          inherited lblCGTOther: TLabel
            Left = 6
            Top = 57
            Width = 172
            Height = 17
            ExplicitLeft = 6
            ExplicitTop = 57
            ExplicitWidth = 172
            ExplicitHeight = 17
          end
          inherited lpCGTOther: TLabel
            Left = 393
            Top = 57
            Height = 17
            ExplicitLeft = 393
            ExplicitTop = 57
            ExplicitHeight = 17
          end
          inherited nfCGTDiscounted: TOvcNumericField
            Left = 260
            Top = 2
            ExplicitLeft = 260
            ExplicitTop = 2
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTIndexation: TOvcNumericField
            Left = 260
            Top = 29
            ExplicitLeft = 260
            ExplicitTop = 29
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTOther: TOvcNumericField
            Left = 260
            Top = 56
            ExplicitLeft = 260
            ExplicitTop = 56
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
        object nfForeignCGTBeforeDiscount: TOvcNumericField
          Left = 260
          Top = 156
          Width = 132
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
        object nfForeignCGTIndexationMethod: TOvcNumericField
          Left = 260
          Top = 182
          Width = 132
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
        object nfForeignCGTOtherMethod: TOvcNumericField
          Left = 260
          Top = 208
          Width = 132
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
        object nfTaxPaidBeforeDiscount: TOvcNumericField
          Left = 432
          Top = 156
          Width = 132
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
        object nfTaxPaidIndexationMethod: TOvcNumericField
          Left = 432
          Top = 182
          Width = 132
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
          OnKeyPress = nfTFNCreditsKeyPress
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {00000000000000000000}
        end
        object nfTaxPaidOtherMethod: TOvcNumericField
          Left = 432
          Top = 208
          Width = 132
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
          OnKeyPress = nfTFNCreditsKeyPress
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {00000000000000000000}
        end
      end
      object tsForeignIncome: TTabSheet
        Caption = 'Foreign Income'
        ImageIndex = 2
        object lblAssessableForeignSourceIncome: TLabel
          Left = 6
          Top = 5
          Width = 202
          Height = 17
          Caption = 'Assessable Foreign Source Income'
          FocusControl = nfAssessableForeignSourceIncome
        end
        object lpAssessableForeignSourceIncome: TLabel
          Left = 393
          Top = 5
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfAssessableForeignSourceIncome
          Visible = False
        end
        object lblOtherNetForeignSourceIncome: TLabel
          Left = 6
          Top = 31
          Width = 196
          Height = 17
          Caption = 'Other Net Foreign Source Income'
          FocusControl = nfOtherNetForeignSourceIncome
        end
        object lpOtherNetForeignSourceIncome: TLabel
          Left = 393
          Top = 31
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfOtherNetForeignSourceIncome
          Visible = False
        end
        object lblCashDistribution: TLabel
          Left = 6
          Top = 57
          Width = 99
          Height = 17
          Caption = 'Cash Distribution'
          FocusControl = nfCashDistribution
        end
        object lpCashDistribution: TLabel
          Left = 393
          Top = 57
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfCashDistribution
          Visible = False
        end
        object lblTaxExemptedAmounts: TLabel
          Left = 407
          Top = 5
          Width = 137
          Height = 17
          Caption = 'Tax Exempted Amounts'
          FocusControl = nfTaxExemptedAmounts
        end
        object lpTaxExemptedAmounts: TLabel
          Left = 688
          Top = 5
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfTaxExemptedAmounts
          Visible = False
        end
        object lblTaxFreeAmounts: TLabel
          Left = 407
          Top = 31
          Width = 104
          Height = 17
          Caption = 'Tax Free Amounts'
          FocusControl = nfTaxFreeAmounts
        end
        object lpTaxFreeAmounts: TLabel
          Left = 688
          Top = 31
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfTaxFreeAmounts
          Visible = False
        end
        object lblTaxDeferredAmounts: TLabel
          Left = 407
          Top = 57
          Width = 131
          Height = 17
          Caption = 'Tax Deferred Amounts'
          FocusControl = nfTaxDeferredAmounts
        end
        object lpTaxDeferredAmounts: TLabel
          Left = 688
          Top = 57
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfTaxDeferredAmounts
          Visible = False
        end
        object lblOtherExpenses: TLabel
          Left = 407
          Top = 82
          Width = 91
          Height = 17
          Caption = 'Other Expenses'
          FocusControl = nfOtherExpenses
        end
        object lpOtherExpenses: TLabel
          Left = 688
          Top = 82
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfOtherExpenses
          Visible = False
        end
        object nfAssessableForeignSourceIncome: TOvcNumericField
          Left = 260
          Top = 3
          Width = 132
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
          Left = 260
          Top = 29
          Width = 132
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
          Left = 260
          Top = 55
          Width = 132
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
          Width = 132
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
          Width = 132
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
          Width = 132
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
        inline fmeDist_ForeignIncome_Tax: TfmeBGLForeignTax
          Left = 0
          Top = 90
          Width = 405
          Height = 144
          TabOrder = 3
          ExplicitTop = 90
          ExplicitWidth = 405
          ExplicitHeight = 144
          inherited lblForeignIncomeTaxOffset: TLabel
            Left = 6
            Width = 153
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 153
            ExplicitHeight = 17
          end
          inherited lpForeignIncomeTaxOffset: TLabel
            Left = 393
            Height = 17
            ExplicitLeft = 393
            ExplicitHeight = 17
          end
          inherited lblAUFrankingCreditsFromNZCompany: TLabel
            Left = 6
            Top = 31
            Width = 227
            Height = 17
            ExplicitLeft = 6
            ExplicitTop = 31
            ExplicitWidth = 227
            ExplicitHeight = 17
          end
          inherited lpAUFrankingCreditsFromNZCompany: TLabel
            Left = 393
            Top = 31
            Height = 17
            ExplicitLeft = 393
            ExplicitTop = 31
            ExplicitHeight = 17
          end
          inherited lblTFNAmountsWithheld: TLabel
            Left = 6
            Top = 68
            Width = 133
            Height = 17
            Caption = 'TFN Amounts Withheld'
            ExplicitLeft = 6
            ExplicitTop = 68
            ExplicitWidth = 133
            ExplicitHeight = 17
          end
          inherited lpTFNAmountsWithheld: TLabel
            Left = 393
            Top = 68
            Height = 17
            ExplicitLeft = 393
            ExplicitTop = 68
            ExplicitHeight = 17
          end
          inherited lblNonResidentWithholdingTax: TLabel
            Left = 6
            Top = 94
            Width = 178
            Height = 17
            ExplicitLeft = 6
            ExplicitTop = 94
            ExplicitWidth = 178
            ExplicitHeight = 17
          end
          inherited lpNonResidentWithholdingTax: TLabel
            Left = 393
            Top = 94
            Height = 17
            ExplicitLeft = 393
            ExplicitTop = 94
            ExplicitHeight = 17
          end
          inherited lblLICDeductions: TLabel
            Left = 6
            Top = 119
            Width = 80
            Height = 17
            ExplicitLeft = 6
            ExplicitTop = 119
            ExplicitWidth = 80
            ExplicitHeight = 17
          end
          inherited lpLICDeductions: TLabel
            Left = 393
            Top = 119
            Height = 17
            ExplicitLeft = 393
            ExplicitTop = 119
            ExplicitHeight = 17
          end
          inherited nfForeignIncomeTaxOffset: TOvcNumericField
            Left = 260
            ExplicitLeft = 260
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfAUFrankingCreditsFromNZCompany: TOvcNumericField
            Left = 260
            Top = 29
            ExplicitLeft = 260
            ExplicitTop = 29
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfTFNAmountsWithheld: TOvcNumericField
            Left = 260
            Top = 66
            ExplicitLeft = 260
            ExplicitTop = 66
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfNonResidentWithholdingTax: TOvcNumericField
            Left = 260
            Top = 92
            ExplicitLeft = 260
            ExplicitTop = 92
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfLICDeductions: TOvcNumericField
            Left = 260
            Top = 117
            ExplicitLeft = 260
            ExplicitTop = 117
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
        end
        object nfOtherExpenses: TOvcNumericField
          Left = 555
          Top = 80
          Width = 132
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
          Left = 393
          Top = 99
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfCGTCapitalLosses
          Visible = False
        end
        object lblCGTCapitalLosses: TLabel
          Left = 6
          Top = 99
          Width = 83
          Height = 17
          Caption = 'Capital Losses'
        end
        object nfCGTCapitalLosses: TOvcNumericField
          Left = 260
          Top = 97
          Width = 132
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
        inline fmeDist_NonCashCapitalGains_CGT: TfmeBGLCapitalGainsTax
          Left = 0
          Top = 3
          Width = 450
          Height = 90
          TabOrder = 0
          ExplicitTop = 3
          ExplicitWidth = 450
          inherited lblCGTDiscounted: TLabel
            Left = 6
            Width = 243
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 243
            ExplicitHeight = 17
          end
          inherited lpCGTDiscounted: TLabel
            Left = 393
            Height = 17
            ExplicitLeft = 393
            ExplicitHeight = 17
          end
          inherited lblCGTIndexation: TLabel
            Left = 6
            Width = 199
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 199
            ExplicitHeight = 17
          end
          inherited lpCGTIndexation: TLabel
            Left = 393
            Height = 17
            ExplicitLeft = 393
            ExplicitHeight = 17
          end
          inherited lblCGTOther: TLabel
            Left = 6
            Width = 172
            Height = 17
            ExplicitLeft = 6
            ExplicitWidth = 172
            ExplicitHeight = 17
          end
          inherited lpCGTOther: TLabel
            Left = 393
            Height = 17
            ExplicitLeft = 393
            ExplicitHeight = 17
          end
          inherited nfCGTDiscounted: TOvcNumericField
            Left = 260
            ExplicitLeft = 260
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTIndexation: TOvcNumericField
            Left = 260
            ExplicitLeft = 260
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTOther: TOvcNumericField
            Left = 260
            ExplicitLeft = 260
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
      end
    end
  end
  object pnlInterest: TPanel
    Left = 0
    Top = 145
    Width = 709
    Height = 267
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 4
    Visible = False
    object lblInterest: TLabel
      Left = 10
      Top = 7
      Width = 81
      Height = 17
      Caption = 'Gross Interest'
      FocusControl = nfInterest
    end
    object lpInterest: TLabel
      Left = 393
      Top = 7
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeDist_AU_Income_InterestIncome.nfInterest
      Visible = False
    end
    object lblOtherIncome: TLabel
      Left = 10
      Top = 39
      Width = 79
      Height = 17
      Caption = 'Other Income'
      FocusControl = nfOtherIncome
    end
    object lpOtherIncome: TLabel
      Left = 393
      Top = 39
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeDist_AU_Income_InterestIncome.nfOtherIncome
      Visible = False
    end
    object lblTFNAmountsWithheld: TLabel
      Left = 10
      Top = 67
      Width = 133
      Height = 17
      Caption = 'TFN Amounts Withheld'
      FocusControl = nfTFNAmountsWithheld
    end
    object lpTFNAmountsWithheld: TLabel
      Left = 393
      Top = 67
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeDividend_ForeignIncome_Tax.nfTFNAmountsWithheld
      Visible = False
    end
    object lblNonResidentWithholdingTax: TLabel
      Left = 10
      Top = 97
      Width = 178
      Height = 17
      Caption = 'Non-Resident Withholding Tax'
      FocusControl = nfNonResidentWithholdingTax
    end
    object lpNonResidentWithholdingTax: TLabel
      Left = 393
      Top = 97
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeDividend_ForeignIncome_Tax.nfNonResidentWithholdingTax
      Visible = False
    end
    object lineInterest: TShape
      Left = 0
      Top = 0
      Width = 709
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 720
    end
    object nfInterest: TOvcNumericField
      Left = 260
      Top = 5
      Width = 132
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
      Left = 260
      Top = 37
      Width = 132
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
      Left = 260
      Top = 65
      Width = 132
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
      Left = 260
      Top = 95
      Width = 132
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
    Width = 709
    Height = 267
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 5
    Visible = False
    object lblShareBrokerage: TLabel
      Left = 10
      Top = 48
      Width = 60
      Height = 17
      Caption = 'Brokerage'
      FocusControl = fmeDist_AU_Income_InterestIncome.nfInterest
    end
    object lpShareBrokerage: TLabel
      Left = 280
      Top = 48
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeDist_AU_Income_InterestIncome.nfInterest
      Visible = False
    end
    object lblShareConsideration: TLabel
      Left = 10
      Top = 77
      Width = 81
      Height = 17
      Caption = 'Consideration'
      FocusControl = fmeDist_AU_Income_InterestIncome.nfOtherIncome
    end
    object lpShareConsideration: TLabel
      Left = 280
      Top = 77
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeDist_AU_Income_InterestIncome.nfOtherIncome
      Visible = False
    end
    object lblShareGSTAmount: TLabel
      Left = 417
      Top = 18
      Width = 72
      Height = 17
      Caption = 'GST Amount'
      FocusControl = fmeDividend_ForeignIncome_Tax.nfTFNAmountsWithheld
    end
    object lpShareGSTAmount: TLabel
      Left = 684
      Top = 18
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeDividend_ForeignIncome_Tax.nfTFNAmountsWithheld
      Visible = False
    end
    object lblShareGSTRate: TLabel
      Left = 417
      Top = 48
      Width = 53
      Height = 17
      Caption = 'GST Rate'
      FocusControl = fmeDividend_ForeignIncome_Tax.nfNonResidentWithholdingTax
    end
    object lpShareTradeUnits: TLabel
      Left = 392
      Top = 223
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeDist_AU_Income_InterestIncome.nfInterest
      Visible = False
    end
    object lblShareTradeUnits: TLabel
      Left = 9
      Top = 223
      Width = 29
      Height = 17
      Caption = 'Units'
      FocusControl = fmeDist_AU_Income_InterestIncome.nfInterest
      Visible = False
    end
    object lineShareTrade: TShape
      Left = 0
      Top = 0
      Width = 709
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 720
    end
    object lblUnits: TLabel
      Left = 10
      Top = 18
      Width = 29
      Height = 17
      Caption = 'Units'
    end
    object nfShareBrokerage: TOvcNumericField
      Left = 147
      Top = 46
      Width = 132
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
      OnChange = nfShareBrokerageChange
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfShareConsideration: TOvcNumericField
      Left = 147
      Top = 75
      Width = 132
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
      OnChange = nfShareConsiderationChange
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfShareGSTAmount: TOvcNumericField
      Left = 551
      Top = 16
      Width = 132
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
      Left = 551
      Top = 46
      Properties.Alignment.Horz = taLeftJustify
      Properties.DropDownAutoWidth = False
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownWidth = 300
      Properties.Items.Strings = (
        ''
        '100'
        '75'
        '0')
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
      Width = 132
    end
    object nfShareTradeUnits: TOvcNumericField
      Left = 259
      Top = 221
      Width = 132
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
      Visible = False
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
    end
    object nfUnits: TOvcNumericField
      Left = 147
      Top = 16
      Width = 132
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
      TabOrder = 5
      OnKeyDown = nfUnitsKeyDown
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {5C8FC2F5FF276BEE1CC0}
    end
  end
  object pnlDividend: TPanel
    Left = 0
    Top = 145
    Width = 709
    Height = 267
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 3
    Visible = False
    object lineDividend: TShape
      Left = 0
      Top = 0
      Width = 709
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 720
    end
    object lpForeignIncome: TLabel
      Left = 540
      Top = 125
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = nfForeignIncome
      Visible = False
    end
    object lblForeignIncome: TLabel
      Left = 157
      Top = 128
      Width = 90
      Height = 17
      Caption = 'Foreign Income'
      FocusControl = nfForeignIncome
    end
    inline fmeDividend_ForeignIncome_Tax: TfmeBGLForeignTax
      Left = 0
      Top = 1
      Width = 709
      Height = 266
      Align = alClient
      TabOrder = 1
      ExplicitTop = 1
      ExplicitWidth = 709
      ExplicitHeight = 266
      inherited lblForeignIncomeTaxOffset: TLabel
        Left = 157
        Top = 154
        Width = 198
        Height = 17
        Caption = 'Foreign Income Tax Offset Credits'
        ExplicitLeft = 157
        ExplicitTop = 154
        ExplicitWidth = 198
        ExplicitHeight = 17
      end
      inherited lpForeignIncomeTaxOffset: TLabel
        Left = 540
        Top = 153
        Height = 17
        ExplicitLeft = 540
        ExplicitTop = 153
        ExplicitHeight = 17
      end
      inherited lblAUFrankingCreditsFromNZCompany: TLabel
        Left = 157
        Top = 183
        Width = 227
        Height = 17
        ExplicitLeft = 157
        ExplicitTop = 183
        ExplicitWidth = 227
        ExplicitHeight = 17
      end
      inherited lpAUFrankingCreditsFromNZCompany: TLabel
        Left = 540
        Top = 183
        Height = 17
        ExplicitLeft = 540
        ExplicitTop = 183
        ExplicitHeight = 17
      end
      inherited lblTFNAmountsWithheld: TLabel
        Left = 357
        Top = 9
        Width = 133
        Height = 17
        Caption = 'TFN Amounts Withheld'
        ExplicitLeft = 357
        ExplicitTop = 9
        ExplicitWidth = 133
        ExplicitHeight = 17
      end
      inherited lpTFNAmountsWithheld: TLabel
        Left = 684
        Top = 9
        Height = 17
        ExplicitLeft = 684
        ExplicitTop = 9
        ExplicitHeight = 17
      end
      inherited lblNonResidentWithholdingTax: TLabel
        Left = 357
        Top = 39
        Width = 178
        Height = 17
        ExplicitLeft = 357
        ExplicitTop = 39
        ExplicitWidth = 178
        ExplicitHeight = 17
      end
      inherited lpNonResidentWithholdingTax: TLabel
        Left = 684
        Top = 39
        Height = 17
        ExplicitLeft = 684
        ExplicitTop = 39
        ExplicitHeight = 17
      end
      inherited lblLICDeductions: TLabel
        Left = 357
        Top = 68
        Width = 80
        Height = 17
        ExplicitLeft = 357
        ExplicitTop = 68
        ExplicitWidth = 80
        ExplicitHeight = 17
      end
      inherited lpLICDeductions: TLabel
        Left = 684
        Top = 68
        Height = 17
        ExplicitLeft = 684
        ExplicitTop = 68
        ExplicitHeight = 17
      end
      inherited nfForeignIncomeTaxOffset: TOvcNumericField
        Left = 407
        Top = 153
        ExplicitLeft = 407
        ExplicitTop = 153
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      inherited nfAUFrankingCreditsFromNZCompany: TOvcNumericField
        Left = 407
        Top = 182
        ExplicitLeft = 407
        ExplicitTop = 182
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      inherited nfTFNAmountsWithheld: TOvcNumericField
        Left = 551
        Top = 8
        ExplicitLeft = 551
        ExplicitTop = 8
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      inherited nfNonResidentWithholdingTax: TOvcNumericField
        Left = 551
        Top = 38
        ExplicitLeft = 551
        ExplicitTop = 38
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
      inherited nfLICDeductions: TOvcNumericField
        Left = 551
        Top = 67
        ExplicitLeft = 551
        ExplicitTop = 67
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {5C8FC2F5FF276BEE1CC0}
      end
    end
    inline fmeDividend_Franking: TfmeBGLFranking
      Left = 0
      Top = 3
      Width = 329
      Height = 90
      TabOrder = 0
      ExplicitTop = 3
      ExplicitWidth = 329
      inherited lblFranked: TLabel
        Left = 10
        Top = 7
        Width = 46
        Height = 17
        ExplicitLeft = 10
        ExplicitTop = 7
        ExplicitWidth = 46
        ExplicitHeight = 17
      end
      inherited lpFranked: TLabel
        Left = 281
        Top = 7
        Height = 17
        ExplicitLeft = 281
        ExplicitTop = 7
        ExplicitHeight = 17
      end
      inherited lblUnfranked: TLabel
        Left = 10
        Width = 60
        Height = 17
        ExplicitLeft = 10
        ExplicitWidth = 60
        ExplicitHeight = 17
      end
      inherited lpUnfranked: TLabel
        Left = 281
        Height = 17
        ExplicitLeft = 281
        ExplicitHeight = 17
      end
      inherited lblFrankingCredits: TLabel
        Left = 10
        Top = 63
        Width = 94
        Height = 17
        ExplicitLeft = 10
        ExplicitTop = 63
        ExplicitWidth = 94
        ExplicitHeight = 17
      end
      inherited btnFrankingCredits: TSpeedButton
        Left = 281
        Top = 61
        OnClick = frameFrankingbtnCalcClick
        ExplicitLeft = 281
        ExplicitTop = 61
      end
      inherited nfFranked: TOvcNumericField
        Left = 148
        Top = 6
        OnChange = frameFrankingFrankedChange
        ExplicitLeft = 148
        ExplicitTop = 6
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {00000000000000000000}
      end
      inherited nfUnfranked: TOvcNumericField
        Left = 148
        Top = 34
        OnChange = frameFrankingUnfrankedChange
        ExplicitLeft = 148
        ExplicitTop = 34
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {00000000000000000000}
      end
      inherited nfFrankingCredits: TOvcNumericField
        Left = 148
        Top = 62
        OnChange = frameFrankingFrankingCreditsChange
        ExplicitLeft = 148
        ExplicitTop = 62
        RangeHigh = {F6285CFFFFF802952040}
        RangeLow = {00000000000000000000}
      end
    end
    object nfForeignIncome: TOvcNumericField
      Left = 407
      Top = 125
      Width = 132
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
  end
  object pnlTransactionInfo: TPanel
    Left = 0
    Top = 73
    Width = 709
    Height = 72
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object lblAccount: TLabel
      Left = 10
      Top = 9
      Width = 46
      Height = 17
      Caption = 'Account'
    end
    object btnChart: TSpeedButton
      Left = 261
      Top = 7
      Width = 28
      Height = 26
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
    object lblEntryType: TLabel
      Left = 10
      Top = 43
      Width = 61
      Height = 17
      Caption = 'Entry Type'
      Visible = False
    end
    object lbldispEntryType: TLabel
      Left = 73
      Top = 42
      Width = 96
      Height = 17
      Caption = 'lbldispEntryType'
      Visible = False
    end
    object lblCashDate: TLabel
      Left = 504
      Top = 9
      Width = 80
      Height = 17
      Caption = 'Contract Date'
      Visible = False
    end
    object lblAccrualDate: TLabel
      Left = 305
      Top = 43
      Width = 73
      Height = 17
      Caption = 'Accrual Date'
      Visible = False
    end
    object lblRecordDate: TLabel
      Left = 504
      Top = 43
      Width = 92
      Height = 17
      Caption = 'Settlement Date'
      Visible = False
    end
    object lineTransactionInfo: TShape
      Left = 0
      Top = 0
      Width = 709
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 720
    end
    object cmbxAccount: TcxComboBox
      Left = 74
      Top = 6
      Properties.Alignment.Horz = taLeftJustify
      Properties.DropDownAutoWidth = False
      Properties.DropDownListStyle = lsFixedList
      Properties.DropDownSizeable = True
      Properties.DropDownWidth = 500
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
      Visible = False
      OnKeyDown = cmbxAccountKeyDown
      Width = 184
    end
    object eCashDate: TOvcPictureField
      Left = 603
      Top = 8
      Width = 80
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
      Left = 384
      Top = 42
      Width = 80
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
      TabOrder = 1
      Visible = False
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object eRecordDate: TOvcPictureField
      Left = 603
      Top = 42
      Width = 80
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
    object sfEntryType: TOvcPictureField
      Left = 74
      Top = 42
      Width = 185
      Height = 20
      Cursor = crIBeam
      DataType = pftString
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
      Enabled = False
      Epoch = 1970
      InitDateTime = False
      Options = [efoCaretToEnd]
      PictureMask = 'XXXXXXXXXXXXXXX'
      TabOrder = 4
      Visible = False
    end
    object edtAccount: TEdit
      Left = 74
      Top = 8
      Width = 186
      Height = 25
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 5
      Text = 'edtAccount'
      OnChange = edtAccountChange
      OnKeyDown = edtAccountKeyDown
      OnKeyPress = edtAccountKeyPress
      OnKeyUp = edtAccountKeyUp
    end
  end
  object pnlFooters: TPanel
    Left = 0
    Top = 412
    Width = 709
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 6
    object lineFooter: TShape
      Left = 0
      Top = 0
      Width = 709
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 720
    end
    object btnOK: TButton
      Left = 545
      Top = 7
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 626
      Top = 7
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnClear: TButton
      Left = 10
      Top = 7
      Width = 75
      Height = 25
      Caption = 'Clear All'
      TabOrder = 2
      OnClick = btnClearClick
    end
    object btnBack: TBitBtn
      Left = 243
      Top = 7
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
      Left = 324
      Top = 7
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
    Width = 709
    Height = 73
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      709
      73)
    object lblDate: TLabel
      Left = 10
      Top = 16
      Width = 27
      Height = 17
      Caption = 'Date'
    end
    object lbldispDate: TLabel
      Left = 10
      Top = 40
      Width = 66
      Height = 17
      Caption = 'lbldispDate'
    end
    object lbldispAmount: TLabel
      Left = 81
      Top = 40
      Width = 113
      Height = 16
      Alignment = taRightJustify
      AutoSize = False
      Caption = 'lbldispAmount'
    end
    object lblAmount: TLabel
      Left = 149
      Top = 16
      Width = 45
      Height = 17
      Caption = 'Amount'
    end
    object lblNarration: TLabel
      Left = 200
      Top = 16
      Width = 56
      Height = 17
      Caption = 'Narration'
    end
    object lbldispNarration: TLabel
      Left = 200
      Top = 40
      Width = 500
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'lbldispNarration'
      ExplicitWidth = 407
    end
  end
end
