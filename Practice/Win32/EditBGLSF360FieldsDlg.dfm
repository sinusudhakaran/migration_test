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
          Left = 383
          Top = 200
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfLessOtherAllowableTrustDeductions
          Visible = False
        end
        inline fmeInterestIncome: TfmeBGLInterestIncome
          Left = 3
          Top = 132
          Width = 442
          Height = 54
          TabOrder = 1
          ExplicitLeft = 3
          ExplicitTop = 132
          inherited lblInterest: TLabel
            Width = 81
            Height = 17
            ExplicitWidth = 81
            ExplicitHeight = 17
          end
          inherited lpInterest: TLabel
            Height = 17
            ExplicitHeight = 17
          end
          inherited lpOtherIncome: TLabel
            Height = 17
            ExplicitHeight = 17
          end
          inherited lblOtherIncome: TLabel
            Width = 79
            Height = 17
            ExplicitWidth = 79
            ExplicitHeight = 17
          end
          inherited nfInterest: TOvcNumericField
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfOtherIncome: TOvcNumericField
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
          inherited lblFranked: TLabel
            Width = 95
            Height = 17
            ExplicitWidth = 95
            ExplicitHeight = 17
          end
          inherited lpFranked: TLabel
            Height = 17
            ExplicitHeight = 17
          end
          inherited lblUnfranked: TLabel
            Width = 109
            Height = 17
            ExplicitWidth = 109
            ExplicitHeight = 17
          end
          inherited lpUnfranked: TLabel
            Height = 17
            ExplicitHeight = 17
          end
          inherited lblFrankingCredits: TLabel
            Width = 94
            Height = 17
            ExplicitWidth = 94
            ExplicitHeight = 17
          end
          inherited btnFrankingCredits: TSpeedButton
            Top = 64
            OnClick = frameFrankingbtnCalcClick
            ExplicitTop = 64
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
          Top = 198
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
          Top = 86
          Width = 249
          Height = 17
          Caption = 'Capital Gain Tax (CGT) Concession Amount'
          FocusControl = nfCGTConcession
        end
        object lpCGTConcession: TLabel
          Left = 409
          Top = 86
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfCGTConcession
          Visible = False
        end
        object lblForeignCGT: TLabel
          Left = 288
          Top = 133
          Width = 124
          Height = 17
          Caption = 'Foreign Capital Gains'
        end
        object lblTaxPaid: TLabel
          Left = 560
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
        object Label1: TLabel
          Left = 560
          Top = 133
          Width = 81
          Height = 17
          Caption = 'Offset/Credits'
        end
        object nfCGTConcession: TOvcNumericField
          Left = 279
          Top = 84
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
          OnKeyPress = nfTFNCreditsKeyPress
          RangeHigh = {F6285CFFFFF802952040}
          RangeLow = {00000000000000000000}
        end
        inline fmeBGLCashCapitalGainsTax: TfmeBGLCapitalGainsTax
          Left = 3
          Top = 3
          Width = 442
          Height = 80
          TabOrder = 7
          ExplicitLeft = 3
          ExplicitTop = 3
          ExplicitHeight = 80
          inherited lblCGTDiscounted: TLabel
            Width = 243
            Height = 17
            ExplicitWidth = 243
            ExplicitHeight = 17
          end
          inherited lpCGTDiscounted: TLabel
            Left = 406
            Height = 17
            ExplicitLeft = 406
            ExplicitHeight = 17
          end
          inherited lblCGTIndexation: TLabel
            Top = 30
            Width = 149
            Height = 17
            ExplicitTop = 30
            ExplicitWidth = 149
            ExplicitHeight = 17
          end
          inherited lpCGTIndexation: TLabel
            Left = 406
            Top = 30
            Height = 17
            ExplicitLeft = 406
            ExplicitTop = 30
            ExplicitHeight = 17
          end
          inherited lblCGTOther: TLabel
            Top = 57
            Width = 172
            Height = 17
            ExplicitTop = 57
            ExplicitWidth = 172
            ExplicitHeight = 17
          end
          inherited lpCGTOther: TLabel
            Left = 406
            Top = 57
            Height = 17
            ExplicitLeft = 406
            ExplicitTop = 57
            ExplicitHeight = 17
          end
          inherited nfCGTDiscounted: TOvcNumericField
            Left = 276
            ExplicitLeft = 276
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTIndexation: TOvcNumericField
            Left = 276
            Top = 28
            ExplicitLeft = 276
            ExplicitTop = 28
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
          inherited nfCGTOther: TOvcNumericField
            Left = 276
            Top = 55
            ExplicitLeft = 276
            ExplicitTop = 55
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {00000000000000000000}
          end
        end
        object nfForeignCGTBeforeDiscount: TOvcNumericField
          Left = 286
          Top = 156
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
          Left = 286
          Top = 182
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
          Left = 286
          Top = 208
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
          Left = 542
          Top = 156
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
          Left = 542
          Top = 182
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
          Left = 542
          Top = 208
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
      object tsForeignIncome: TTabSheet
        Caption = 'Foreign Income'
        ImageIndex = 2
        object lblAssessableForeignSourceIncome: TLabel
          Left = 1
          Top = 5
          Width = 202
          Height = 17
          Caption = 'Assessable Foreign Source Income'
          FocusControl = nfAssessableForeignSourceIncome
        end
        object lpAssessableForeignSourceIncome: TLabel
          Left = 379
          Top = 5
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfAssessableForeignSourceIncome
          Visible = False
        end
        object lblOtherNetForeignSourceIncome: TLabel
          Left = 0
          Top = 31
          Width = 196
          Height = 17
          Caption = 'Other Net Foreign Source Income'
          FocusControl = nfOtherNetForeignSourceIncome
        end
        object lpOtherNetForeignSourceIncome: TLabel
          Left = 379
          Top = 31
          Width = 11
          Height = 17
          Caption = '%'
          FocusControl = nfOtherNetForeignSourceIncome
          Visible = False
        end
        object lblCashDistribution: TLabel
          Left = 0
          Top = 57
          Width = 99
          Height = 17
          Caption = 'Cash Distribution'
          FocusControl = nfCashDistribution
        end
        object lpCashDistribution: TLabel
          Left = 379
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
          Left = 684
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
          Left = 684
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
          Left = 684
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
          Left = 684
          Top = 82
          Width = 11
          Height = 17
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
          Top = 90
          Width = 401
          Height = 144
          TabOrder = 3
          ExplicitTop = 90
          ExplicitWidth = 401
          ExplicitHeight = 144
          inherited lblForeignIncomeTaxOffset: TLabel
            Left = 0
            Width = 153
            Height = 17
            ExplicitLeft = 0
            ExplicitWidth = 153
            ExplicitHeight = 17
          end
          inherited lpForeignIncomeTaxOffset: TLabel
            Height = 17
            ExplicitHeight = 17
          end
          inherited lblAUFrankingCreditsFromNZCompany: TLabel
            Left = 0
            Top = 31
            Width = 245
            Height = 17
            Caption = 'AU Franking Credits from an NZ Company'
            ExplicitLeft = 0
            ExplicitTop = 31
            ExplicitWidth = 245
            ExplicitHeight = 17
          end
          inherited lpAUFrankingCreditsFromNZCompany: TLabel
            Top = 31
            Height = 17
            ExplicitTop = 31
            ExplicitHeight = 17
          end
          inherited lblTFNAmountsWithheld: TLabel
            Left = 0
            Top = 71
            Width = 133
            Height = 17
            Caption = 'TFN Amounts Withheld'
            ExplicitLeft = 0
            ExplicitTop = 71
            ExplicitWidth = 133
            ExplicitHeight = 17
          end
          inherited lpTFNAmountsWithheld: TLabel
            Top = 71
            Height = 17
            ExplicitTop = 71
            ExplicitHeight = 17
          end
          inherited lblNonResidentWithholdingTax: TLabel
            Left = 0
            Top = 97
            Width = 178
            Height = 17
            ExplicitLeft = 0
            ExplicitTop = 97
            ExplicitWidth = 178
            ExplicitHeight = 17
          end
          inherited lpNonResidentWithholdingTax: TLabel
            Top = 97
            Height = 17
            ExplicitTop = 97
            ExplicitHeight = 17
          end
          inherited lblLICDeductions: TLabel
            Left = 1
            Top = 122
            Width = 86
            Height = 17
            ExplicitLeft = 1
            ExplicitTop = 122
            ExplicitWidth = 86
            ExplicitHeight = 17
          end
          inherited lpLICDeductions: TLabel
            Top = 122
            Height = 17
            ExplicitTop = 122
            ExplicitHeight = 17
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
            Top = 69
            ExplicitTop = 69
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfNonResidentWithholdingTax: TOvcNumericField
            Top = 95
            ExplicitTop = 95
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
          inherited nfLICDeductions: TOvcNumericField
            Top = 120
            ExplicitTop = 120
            RangeHigh = {F6285CFFFFF802952040}
            RangeLow = {5C8FC2F5FF276BEE1CC0}
          end
        end
        object nfOtherExpenses: TOvcNumericField
          Left = 555
          Top = 80
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
          Height = 17
          Caption = '%'
          FocusControl = nfCGTCapitalLosses
          Visible = False
        end
        object lblCGTCapitalLosses: TLabel
          Left = 3
          Top = 99
          Width = 83
          Height = 17
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
          inherited lblCGTDiscounted: TLabel
            Width = 243
            Height = 17
            ExplicitWidth = 243
            ExplicitHeight = 17
          end
          inherited lpCGTDiscounted: TLabel
            Height = 17
            ExplicitHeight = 17
          end
          inherited lblCGTIndexation: TLabel
            Width = 149
            Height = 17
            ExplicitWidth = 149
            ExplicitHeight = 17
          end
          inherited lpCGTIndexation: TLabel
            Height = 17
            ExplicitHeight = 17
          end
          inherited lblCGTOther: TLabel
            Width = 172
            Height = 17
            ExplicitWidth = 172
            ExplicitHeight = 17
          end
          inherited lpCGTOther: TLabel
            Height = 17
            ExplicitHeight = 17
          end
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
      Left = 3
      Top = 7
      Width = 81
      Height = 17
      Caption = 'Gross Interest'
      FocusControl = nfInterest
    end
    object lpInterest: TLabel
      Left = 352
      Top = 7
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeInterestIncome.nfInterest
      Visible = False
    end
    object lblOtherIncome: TLabel
      Left = 3
      Top = 39
      Width = 79
      Height = 17
      Caption = 'Other Income'
      FocusControl = nfOtherIncome
    end
    object lpOtherIncome: TLabel
      Left = 352
      Top = 39
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeInterestIncome.nfOtherIncome
      Visible = False
    end
    object lblTFNAmountsWithheld: TLabel
      Left = 3
      Top = 67
      Width = 126
      Height = 17
      Caption = 'TFN Amounts Witheld'
      FocusControl = nfTFNAmountsWithheld
    end
    object lpTFNAmountsWithheld: TLabel
      Left = 352
      Top = 67
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeBGLForeignTax2.nfTFNAmountsWithheld
      Visible = False
    end
    object lblNonResidentWithholdingTax: TLabel
      Left = 3
      Top = 97
      Width = 178
      Height = 17
      Caption = 'Non-Resident Withholding Tax'
      FocusControl = nfNonResidentWithholdingTax
    end
    object lpNonResidentWithholdingTax: TLabel
      Left = 352
      Top = 97
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeBGLForeignTax2.nfNonResidentWithholdingTax
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
    Width = 709
    Height = 267
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 5
    Visible = False
    object lblShareBrokerage: TLabel
      Left = 3
      Top = 10
      Width = 60
      Height = 17
      Caption = 'Brokerage'
      FocusControl = fmeInterestIncome.nfInterest
    end
    object lpShareBrokerage: TLabel
      Left = 352
      Top = 10
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeInterestIncome.nfInterest
      Visible = False
    end
    object lblShareConsideration: TLabel
      Left = 3
      Top = 38
      Width = 81
      Height = 17
      Caption = 'Consideration'
      FocusControl = fmeInterestIncome.nfOtherIncome
    end
    object lpShareConsideration: TLabel
      Left = 352
      Top = 38
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeInterestIncome.nfOtherIncome
      Visible = False
    end
    object lblShareGSTAmount: TLabel
      Left = 3
      Top = 66
      Width = 72
      Height = 17
      Caption = 'GST Amount'
      FocusControl = fmeBGLForeignTax2.nfTFNAmountsWithheld
    end
    object lpShareGSTAmount: TLabel
      Left = 352
      Top = 66
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeBGLForeignTax2.nfTFNAmountsWithheld
      Visible = False
    end
    object lblShareGSTRate: TLabel
      Left = 3
      Top = 98
      Width = 53
      Height = 17
      Caption = 'GST Rate'
      FocusControl = fmeBGLForeignTax2.nfNonResidentWithholdingTax
    end
    object lpShareTradeUnits: TLabel
      Left = 352
      Top = 197
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeInterestIncome.nfInterest
      Visible = False
    end
    object lblShareTradeUnits: TLabel
      Left = 3
      Top = 197
      Width = 29
      Height = 17
      Caption = 'Units'
      FocusControl = fmeInterestIncome.nfInterest
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
    object nfShareBrokerage: TOvcNumericField
      Left = 222
      Top = 8
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
      Top = 36
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
      Top = 64
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
      Top = 94
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
      Top = 195
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
      Visible = False
      RangeHigh = {F6285CFFFFF802952040}
      RangeLow = {00000000000000000000}
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
    object lpForeignIncome: TLabel
      Left = 383
      Top = 90
      Width = 11
      Height = 17
      Caption = '%'
      FocusControl = fmeBGLForeignTax2.nfForeignIncomeTaxOffset
      Visible = False
    end
    object lblForeignIncome: TLabel
      Left = 5
      Top = 90
      Width = 90
      Height = 17
      Caption = 'Foreign Income'
      FocusControl = nfForeignIncome
    end
    object lineDividend: TShape
      Left = 0
      Top = 0
      Width = 709
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 720
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
      inherited lblFranked: TLabel
        Width = 95
        Height = 17
        ExplicitWidth = 95
        ExplicitHeight = 17
      end
      inherited lpFranked: TLabel
        Height = 17
        ExplicitHeight = 17
      end
      inherited lblUnfranked: TLabel
        Top = 31
        Width = 109
        Height = 17
        ExplicitTop = 31
        ExplicitWidth = 109
        ExplicitHeight = 17
      end
      inherited lpUnfranked: TLabel
        Top = 31
        Height = 17
        ExplicitTop = 31
        ExplicitHeight = 17
      end
      inherited lblFrankingCredits: TLabel
        Left = 2
        Top = 59
        Width = 94
        Height = 17
        ExplicitLeft = 2
        ExplicitTop = 59
        ExplicitWidth = 94
        ExplicitHeight = 17
      end
      inherited btnFrankingCredits: TSpeedButton
        Top = 56
        OnClick = frameFrankingbtnCalcClick
        ExplicitTop = 56
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
        Top = 57
        OnClick = frameFrankingFrankingCreditsChange
        ExplicitTop = 57
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
        Width = 198
        Height = 17
        Caption = 'Foreign Income Tax Offset Credits'
        ExplicitLeft = 4
        ExplicitTop = 2
        ExplicitWidth = 198
        ExplicitHeight = 17
      end
      inherited lpForeignIncomeTaxOffset: TLabel
        Top = 2
        Height = 17
        ExplicitTop = 2
        ExplicitHeight = 17
      end
      inherited lblAUFrankingCreditsFromNZCompany: TLabel
        Left = 4
        Top = 31
        Width = 229
        Height = 17
        ExplicitLeft = 4
        ExplicitTop = 31
        ExplicitWidth = 229
        ExplicitHeight = 17
      end
      inherited lpAUFrankingCreditsFromNZCompany: TLabel
        Top = 31
        Height = 17
        ExplicitTop = 31
        ExplicitHeight = 17
      end
      inherited lblTFNAmountsWithheld: TLabel
        Left = 4
        Top = 61
        Width = 126
        Height = 17
        ExplicitLeft = 4
        ExplicitTop = 61
        ExplicitWidth = 126
        ExplicitHeight = 17
      end
      inherited lpTFNAmountsWithheld: TLabel
        Top = 61
        Height = 17
        ExplicitTop = 61
        ExplicitHeight = 17
      end
      inherited lblNonResidentWithholdingTax: TLabel
        Left = 4
        Top = 91
        Width = 178
        Height = 17
        ExplicitLeft = 4
        ExplicitTop = 91
        ExplicitWidth = 178
        ExplicitHeight = 17
      end
      inherited lpNonResidentWithholdingTax: TLabel
        Top = 91
        Height = 17
        ExplicitTop = 91
        ExplicitHeight = 17
      end
      inherited lblLICDeductions: TLabel
        Left = 4
        Top = 120
        Width = 86
        Height = 17
        ExplicitLeft = 4
        ExplicitTop = 120
        ExplicitWidth = 86
        ExplicitHeight = 17
      end
      inherited lpLICDeductions: TLabel
        Top = 120
        Height = 17
        ExplicitTop = 120
        ExplicitHeight = 17
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
      Left = 8
      Top = 9
      Width = 46
      Height = 17
      Caption = 'Account'
    end
    object btnChart: TSpeedButton
      Left = 214
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
      Left = 289
      Top = 9
      Width = 29
      Height = 17
      Caption = 'Units'
      Visible = False
    end
    object lblEntryType: TLabel
      Left = 8
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
      Left = 510
      Top = 9
      Width = 59
      Height = 17
      Caption = 'Cash Date'
      Visible = False
    end
    object lblAccrualDate: TLabel
      Left = 289
      Top = 43
      Width = 73
      Height = 17
      Caption = 'Accrual Date'
      Visible = False
    end
    object lblRecordDate: TLabel
      Left = 510
      Top = 43
      Width = 73
      Height = 17
      Caption = 'Record Date'
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
      Top = 5
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
      OnKeyDown = cmbxAccountKeyDown
      Width = 138
    end
    object nfUnits: TOvcNumericField
      Left = 368
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
      Left = 589
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
      TabOrder = 3
      Visible = False
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object eAccrualDate: TOvcPictureField
      Left = 368
      Top = 42
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
      TabOrder = 2
      Visible = False
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object eRecordDate: TOvcPictureField
      Left = 589
      Top = 42
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
    object sfEntryType: TOvcPictureField
      Left = 74
      Top = 42
      Width = 138
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
      TabOrder = 5
      Visible = False
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
      Left = 8
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
      Left = 8
      Top = 16
      Width = 27
      Height = 17
      Caption = 'Date'
    end
    object lbldispDate: TLabel
      Left = 8
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
