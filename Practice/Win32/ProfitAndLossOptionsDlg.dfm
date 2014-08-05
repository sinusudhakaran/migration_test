object dlgProfitAndLossOptions: TdlgProfitAndLossOptions
  Left = 365
  Top = 268
  BorderStyle = bsDialog
  Caption = 'Custom Profit and Loss Reports'
  ClientHeight = 448
  ClientWidth = 633
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 413
    Width = 633
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 415
    DesignSize = (
      633
      35)
    object btnPrint: TButton
      Left = 472
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Print'
      TabOrder = 4
      OnClick = btnPrintClick
    end
    object btnCancel: TButton
      Left = 552
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 5
      OnClick = btnCancelClick
    end
    object btnPreview: TButton
      Left = 10
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Previe&w'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 90
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnSave: TBitBtn
      Left = 392
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Sa&ve'
      TabOrder = 3
      OnClick = BtnSaveClick
    end
    object btnEmail: TButton
      Left = 170
      Top = 4
      Width = 75
      Height = 25
      Caption = 'E&mail'
      TabOrder = 2
      OnClick = btnEmailClick
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 633
    Height = 413
    ActivePage = tbsOptions
    Align = alClient
    TabOrder = 0
    object tbsOptions: TTabSheet
      Caption = 'Options'
      object pnlReportStyle: TPanel
        Left = 0
        Top = 0
        Width = 623
        Height = 145
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        object Label6: TLabel
          Left = 8
          Top = 11
          Width = 60
          Height = 13
          Caption = 'Report Style'
        end
        object Label2: TLabel
          Left = 8
          Top = 51
          Width = 66
          Height = 13
          Caption = 'Report Period'
        end
        object Label1: TLabel
          Left = 296
          Top = 12
          Width = 104
          Height = 13
          Caption = 'Reporting Year Starts'
        end
        object Label5: TLabel
          Left = 296
          Top = 51
          Width = 70
          Height = 13
          Caption = 'Report Format'
        end
        object cmbDetail: TComboBox
          Left = 104
          Top = 48
          Width = 177
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 1
          Text = 'One Month'
          OnChange = cmbDetailChange
          Items.Strings = (
            'One Month'
            'Two Months'
            'Quarter'
            'Half Year'
            'Year'
            'Custom...')
        end
        object cmbStyle: TComboBox
          Left = 104
          Top = 8
          Width = 177
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = 'Single Period (Actual)'
          OnChange = cmbStyleChange
          Items.Strings = (
            'Single Period (Actual)'
            'Multiple Periods (12 Month Actual)'
            'Budget Remaining')
        end
        object cmbStartMonth: TComboBox
          Left = 430
          Top = 8
          Width = 90
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
          OnChange = cmbStartMonthChange
        end
        object spnStartYear: TRzSpinEdit
          Left = 528
          Top = 8
          Width = 73
          Height = 21
          Max = 2070.000000000000000000
          Min = 1980.000000000000000000
          Value = 2002.000000000000000000
          TabOrder = 3
          OnChange = spnStartYearChange
        end
        object rbDetailedFormat: TRadioButton
          Left = 430
          Top = 50
          Width = 75
          Height = 17
          Caption = '&Detailed'
          Checked = True
          TabOrder = 4
          TabStop = True
          OnClick = rbDetailedFormatClick
        end
        object rbSummarisedFormat: TRadioButton
          Left = 512
          Top = 50
          Width = 98
          Height = 17
          Caption = '&Summarised'
          TabOrder = 5
          OnClick = rbDetailedFormatClick
        end
        object pnlPeriodDates: TPanel
          Left = 0
          Top = 73
          Width = 617
          Height = 70
          BevelOuter = bvNone
          TabOrder = 6
          object Label3: TLabel
            Left = 8
            Top = 13
            Width = 38
            Height = 13
            Caption = 'Starting'
          end
          object Label4: TLabel
            Left = 8
            Top = 46
            Width = 32
            Height = 13
            Caption = 'Ending'
          end
          object lblLast: TLabel
            Left = 322
            Top = 46
            Width = 209
            Height = 13
            Caption = 'This last period of  CODED data is Dec 1998'
          end
          object stReportStarts: TLabel
            Left = 104
            Top = 13
            Width = 497
            Height = 16
            AutoSize = False
            Caption = 'stReportStarts'
          end
          object cmbPeriod: TComboBox
            Left = 104
            Top = 43
            Width = 210
            Height = 22
            Style = csOwnerDrawFixed
            DropDownCount = 12
            ItemHeight = 16
            TabOrder = 0
            OnChange = cmbPeriodChange
            OnDrawItem = cmbPeriodDrawItem
            Items.Strings = (
              '1'
              '2'
              '3'
              '4'
              '5'
              '6'
              '7'
              '8'
              '9'
              '10'
              '11'
              '12')
          end
        end
      end
      object pnlCompare: TPanel
        Left = 0
        Top = 191
        Width = 623
        Height = 85
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 2
        object chkCompare: TCheckBox
          Left = 8
          Top = 8
          Width = 185
          Height = 17
          Caption = 'Compare Actual Values &To'
          TabOrder = 0
          OnClick = chkCompareClick
        end
        object rbToBudget: TRadioButton
          Left = 340
          Top = 8
          Width = 65
          Height = 17
          Caption = '&Budget'
          Enabled = False
          TabOrder = 2
          OnClick = rbToBudgetClick
        end
        object rbToLastYear: TRadioButton
          Left = 200
          Top = 8
          Width = 81
          Height = 17
          Caption = '&Last Year'
          Checked = True
          Enabled = False
          TabOrder = 1
          TabStop = True
          OnClick = rbToBudgetClick
        end
        object chkIncludeVariance: TCheckBox
          Left = 8
          Top = 33
          Width = 225
          Height = 17
          Caption = 'Include V&ariance'
          Enabled = False
          TabOrder = 4
        end
        object chkIncludeYTD: TCheckBox
          Left = 8
          Top = 58
          Width = 257
          Height = 17
          Caption = 'In&clude Year-to-Date'
          TabOrder = 5
        end
        object cmbBudget: TComboBox
          Left = 426
          Top = 6
          Width = 186
          Height = 21
          Style = csDropDownList
          Enabled = False
          ItemHeight = 13
          TabOrder = 3
          OnChange = cmbBudgetChange
        end
      end
      object pnlInclude: TPanel
        Left = 0
        Top = 279
        Width = 352
        Height = 55
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 3
        object chkIncludeCodes: TCheckBox
          Left = 8
          Top = 7
          Width = 180
          Height = 17
          Caption = 'Include C&hart Codes'
          TabOrder = 0
        end
        object chkIncludeQuantity: TCheckBox
          Left = 8
          Top = 30
          Width = 180
          Height = 17
          Caption = 'Include &Quantities'
          TabOrder = 1
        end
        object chkGSTInclusive: TCheckBox
          Left = 194
          Top = 7
          Width = 150
          Height = 17
          Caption = '&GST Inclusive'
          TabOrder = 2
        end
        object cbPercentage: TCheckBox
          Left = 194
          Top = 30
          Width = 150
          Height = 17
          Caption = 'Show &% of Income'
          TabOrder = 3
        end
      end
      object pnlDivision: TPanel
        Left = 0
        Top = 148
        Width = 623
        Height = 40
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 1
        object Label8: TLabel
          Left = 8
          Top = 12
          Width = 17
          Height = 13
          Caption = 'Job'
        end
        object cbJobs: TComboBox
          Left = 104
          Top = 8
          Width = 210
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          Sorted = True
          TabOrder = 0
        end
        object ckAllJobs: TCheckBox
          Left = 340
          Top = 11
          Width = 145
          Height = 17
          Caption = 'Include C&ompleted'
          TabOrder = 1
          OnClick = ckAllJobsClick
        end
      end
      object pnlAdvBudget: TPanel
        Left = 0
        Top = 337
        Width = 623
        Height = 37
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 4
        object chkPromptToUseBudget: TCheckBox
          Left = 7
          Top = 8
          Width = 433
          Height = 17
          Caption = 
            'Pro&mpt to use budgeted figures when no actual figures are avail' +
            'able.'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
      end
      object pnlIncludeNonPost: TPanel
        Left = 355
        Top = 279
        Width = 268
        Height = 55
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 5
        object rbSummarisedNonPost: TRadioButton
          Left = 133
          Top = 30
          Width = 113
          Height = 17
          Caption = 'Summarised'
          TabOrder = 0
        end
        object rbDetailedNonPost: TRadioButton
          Left = 25
          Top = 30
          Width = 94
          Height = 17
          Caption = 'Detailed'
          Checked = True
          TabOrder = 1
          TabStop = True
        end
        object chkPrintNonPostingChartCodeTitles: TCheckBox
          Left = 8
          Top = 7
          Width = 253
          Height = 17
          Caption = 'Include Non-Posting Chart Code Titles'
          TabOrder = 2
          OnClick = chkPrintNonPostingChartCodeTitlesClick
        end
      end
    end
    object tbsAdvanced: TTabSheet
      Caption = 'Advanced'
      ImageIndex = 1
      object Panel2: TPanel
        Left = 0
        Top = 4
        Width = 623
        Height = 333
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        inline fmeAccountSelector1: TfmeAccountSelector
          Left = 24
          Top = 12
          Width = 460
          Height = 245
          TabOrder = 0
          TabStop = True
          ExplicitLeft = 24
          ExplicitTop = 12
          ExplicitHeight = 245
          inherited chkAccounts: TCheckListBox
            Left = 5
            Height = 186
            Ctl3D = True
            ExplicitLeft = 5
            ExplicitHeight = 186
          end
        end
      end
    end
    object tsbDivisions: TTabSheet
      Caption = 'Divisions'
      ImageIndex = 2
      object Panel1: TPanel
        Left = 0
        Top = 4
        Width = 623
        Height = 333
        BevelInner = bvRaised
        BevelOuter = bvLowered
        TabOrder = 0
        inline fmeDivisionSelector1: TfmeDivisionSelector
          Left = 24
          Top = 12
          Width = 460
          Height = 269
          TabOrder = 0
          ExplicitLeft = 24
          ExplicitTop = 12
        end
      end
    end
  end
end
