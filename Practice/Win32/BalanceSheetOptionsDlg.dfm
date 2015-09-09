inherited dlgBalanceSheet: TdlgBalanceSheet
  Caption = 'Balance Sheet Report Options'
  ClientHeight = 439
  OldCreateOrder = True
  ExplicitWidth = 639
  ExplicitHeight = 467
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlButtons: TPanel
    Top = 401
    ExplicitTop = 401
  end
  inherited PageControl1: TPageControl
    Height = 401
    ExplicitHeight = 401
    inherited tbsOptions: TTabSheet
      ExplicitLeft = 4
      ExplicitTop = 24
      ExplicitWidth = 625
      ExplicitHeight = 373
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
        Height = 66
        ExplicitHeight = 66
        inherited Bevel3: TBevel
          Top = 65
          ExplicitTop = 65
        end
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
        Top = 326
        ExplicitTop = 326
        inherited chkPromptToUseBudget: TCheckBox
          Top = 10
          ExplicitTop = 10
        end
      end
      inherited pnlCheckBoxes: TPanel
        Top = 260
        ExplicitTop = 260
        inherited pnlInclude: TPanel
          inherited cbPercentage: TCheckBox
            Visible = False
          end
        end
      end
    end
    inherited tbsAdvanced: TTabSheet
      ExplicitHeight = 373
    end
    inherited tsbDivisions: TTabSheet
      ExplicitHeight = 373
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
