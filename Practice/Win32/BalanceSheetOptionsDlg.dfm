inherited dlgBalanceSheet: TdlgBalanceSheet
  Caption = 'Balance Sheet Report Options'
  OldCreateOrder = True
  ExplicitWidth = 320
  ExplicitHeight = 240
  PixelsPerInch = 96
  TextHeight = 13
  inherited PageControl1: TPageControl
    inherited tbsOptions: TTabSheet
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      inherited pnlReportStyle: TPanel
        inherited Label6: TLabel
          Top = 10
          FocusControl = cmbStyle
          ExplicitTop = 10
        end
        inherited Label2: TLabel
          FocusControl = cmbDetail
        end
        inherited Label1: TLabel
          Top = 10
          FocusControl = cmbStartMonth
          ExplicitTop = 10
        end
        inherited cmbStyle: TComboBox
          Top = 7
          ExplicitTop = 7
        end
        inherited cmbStartMonth: TComboBox
          Top = 7
          ExplicitTop = 7
        end
        inherited spnStartYear: TRzSpinEdit
          Top = 7
          ExplicitTop = 7
        end
        inherited rbDetailedFormat: TRadioButton
          Caption = 'De&tailed'
        end
        inherited pnlPeriodDates: TPanel
          Width = 625
          ExplicitWidth = 625
          inherited Label4: TLabel
            FocusControl = cmbPeriod
          end
          inherited stReportStarts: TLabel
            Width = 347
            ExplicitWidth = 347
          end
        end
      end
      inherited pnlCompare: TPanel
        Height = 64
        ExplicitHeight = 64
        inherited chkCompare: TCheckBox
          Width = 257
          Caption = 'Compare &Actual Values To Last Year'
          ExplicitWidth = 257
        end
        inherited rbToLastYear: TRadioButton
          Left = 340
          Top = 27
          ExplicitLeft = 340
          ExplicitTop = 27
        end
        inherited chkIncludeVariance: TCheckBox
          Caption = 'Incl&ude Variance'
        end
        inherited chkIncludeYTD: TCheckBox
          Left = 340
          Top = 45
          Width = 161
          Caption = 'I&nclude Year-to-Date'
          ExplicitLeft = 340
          ExplicitTop = 45
          ExplicitWidth = 161
        end
      end
      inherited pnlInclude: TPanel
        Top = 258
        ExplicitTop = 258
        inherited chkIncludeCodes: TCheckBox
          Top = 8
          Caption = 'Include &Chart Codes'
          ExplicitTop = 8
        end
        inherited chkIncludeQuantity: TCheckBox
          Left = 448
          Top = 2
          ExplicitLeft = 448
          ExplicitTop = 2
        end
        inherited chkGSTInclusive: TCheckBox
          Top = 8
          ExplicitTop = 8
        end
        inherited cbPercentage: TCheckBox
          Left = 430
          Top = 25
          Visible = False
          ExplicitLeft = 430
          ExplicitTop = 25
        end
      end
      inherited pnlDivision: TPanel
        inherited Label8: TLabel
          Top = 11
          ExplicitTop = 11
        end
        inherited ckAllJobs: TCheckBox
          Top = 10
          Caption = 'Include c&ompleted'
          ExplicitTop = 10
        end
      end
      inherited pnlAdvBudget: TPanel
        Top = 316
        ExplicitTop = 316
        inherited chkPromptToUseBudget: TCheckBox
          Left = 8
          Top = 10
          ExplicitLeft = 8
          ExplicitTop = 10
        end
      end
      inherited pnlIncludeNonPost: TPanel
        Top = 258
        ExplicitTop = 258
      end
    end
    inherited tsbDivisions: TTabSheet
      inherited Panel1: TPanel
        inherited fmeDivisionSelector1: TfmeDivisionSelector
          Left = 26
          ExplicitLeft = 26
          inherited chkSplitByDivision: TCheckBox
            Left = 3
            Top = 220
            ExplicitLeft = 3
            ExplicitTop = 220
          end
        end
      end
    end
  end
end
