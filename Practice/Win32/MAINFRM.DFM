object frmMain: TfrmMain
  Left = 315
  Top = 258
  Caption = 'TT'
  ClientHeight = 854
  ClientWidth = 965
  Color = 10459904
  Constraints.MinHeight = 360
  Constraints.MinWidth = 512
  ParentFont = True
  FormStyle = fsMDIForm
  Menu = MainMenu
  OldCreateOrder = False
  Scaled = False
  ShowHint = True
  WindowMenu = mnsWindow
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnMouseUp = FormMouseUp
  OnResize = FormResize
  OnShow = FormShow
  DesignSize = (
    965
    854)
  PixelsPerInch = 96
  TextHeight = 13
  object imgPracticeLogo: TImage
    Left = 640
    Top = 136
    Width = 317
    Height = 79
    Anchors = [akTop, akRight]
    Stretch = True
    Visible = False
    ExplicitLeft = 556
  end
  object Image1: TImage
    Left = 80
    Top = 237
    Width = 512
    Height = 256
    AutoSize = True
    Stretch = True
    Transparent = True
    Visible = False
  end
  object lblClientName: TLabel
    Left = 2
    Top = 185
    Width = 791
    Height = 30
    Alignment = taCenter
    AutoSize = False
    Caption = 'lblClientName'
    Color = 10525952
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    ShowAccelChar = False
    Transparent = True
  end
  object imgLogo: TImage
    Left = 0
    Top = 136
    Width = 317
    Height = 79
    AutoSize = True
    Proportional = True
    Stretch = True
  end
  object lblVersion: TLabel
    Left = 896
    Top = 59
    Width = 45
    Height = 13
    Alignment = taRightJustify
    Anchors = [akTop, akRight]
    Caption = 'lblVersion'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Transparent = True
    ExplicitLeft = 830
  end
  object MainStatus: TStatusBar
    Left = 0
    Top = 830
    Width = 965
    Height = 24
    Panels = <
      item
        Text = 'F1  Help'
        Width = 0
      end
      item
        Width = 300
      end
      item
        Width = 100
      end
      item
        Alignment = taCenter
        Width = 180
      end>
    ParentFont = True
    UseSystemFont = False
  end
  object rzToolbars: TPanel
    Left = 0
    Top = 0
    Width = 965
    Height = 129
    Align = alTop
    AutoSize = True
    BevelEdges = []
    BevelOuter = bvNone
    UseDockManager = False
    ParentBackground = False
    TabOrder = 1
    OnResize = rzToolbarsResize
    object rztFile: TRzToolbar
      Left = 4
      Top = 0
      Width = 814
      Align = alNone
      AutoResize = False
      AutoStyle = False
      Images = AppImages.Client
      Margin = 0
      TopMargin = 0
      ButtonWidth = 60
      ShowButtonCaptions = True
      TextOptions = ttoCustom
      WrapControls = False
      OnVisibleChanged = tbarVisibleChanged
      BorderInner = fsNone
      BorderOuter = fsGroove
      BorderSides = []
      BorderWidth = 0
      FlatColor = clBtnFace
      TabOrder = 0
      VisualStyle = vsClassic
      ToolbarControls = (
        tbOpen
        tbHome
        tbSave
        tbGetClientFiles
        tbSendClientFiles
        tbOnline
        tbAbout
        tbClose
        RzSpacer1)
      object tbOpen: TRzToolButton
        Left = 0
        Top = 0
        Width = 74
        Hint = 'Open Clients (Shift+F12)'
        DropDownMenu = popOpen
        ImageIndex = 16
        ToolStyle = tsDropDown
        Caption = 'Clients'
        OnClick = mniFileOpenClick
      end
      object tbSave: TRzToolButton
        Left = 134
        Top = 0
        ImageIndex = 2
        Caption = 'Save'
        OnClick = mniFileSaveClick
      end
      object tbGetClientFiles: TRzToolButton
        Left = 194
        Top = 0
        Width = 113
        DropDownMenu = PopGetClients
        ImageIndex = 9
        ToolStyle = tsDropDown
        Caption = 'Get Client Files'
      end
      object tbSendClientFiles: TRzToolButton
        Left = 307
        Top = 0
        Width = 120
        DropDownMenu = PopSendClients
        ImageIndex = 10
        ToolStyle = tsDropDown
        Caption = 'Send Client Files'
      end
      object tbHome: TRzToolButton
        Left = 74
        Top = 0
        Action = ActHomePage
      end
      object RzSpacer1: TRzSpacer
        Left = 717
        Top = 0
      end
      object tbOnline: TRzToolButton
        Left = 427
        Top = 0
        Width = 170
        ImageIndex = 20
        Caption = 'MYOB Banklink Online'
        Constraints.MinWidth = 170
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        OnClick = tbOnlineClick
      end
      object tbAbout: TRzToolButton
        Left = 597
        Top = 0
        Caption = 'About'
        Visible = False
        OnClick = mniHelpAboutClick
      end
      object tbClose: TRzToolButton
        Left = 657
        Top = 0
        ImageIndex = 2
        Images = AppImages.Maintain
        Caption = 'Close'
        Visible = False
        OnClick = tbCloseClick
      end
    end
    object rztClient: TRzToolbar
      Left = 2
      Top = 34
      Width = 536
      Align = alNone
      AutoResize = False
      AutoStyle = False
      Images = AppImages.Client
      Margin = 1
      TopMargin = 0
      ButtonWidth = 60
      ShowButtonCaptions = True
      TextOptions = ttoCustom
      WrapControls = False
      OnVisibleChanged = tbarVisibleChanged
      BorderInner = fsPopup
      BorderOuter = fsNone
      BorderSides = [sdLeft, sdRight]
      BorderWidth = 0
      TabOrder = 1
      VisualStyle = vsClassic
      ToolbarControls = (
        tbCoding
        tbBudget
        tbReport
        tbGraph
        tbGST
        RzToolButton13
        RzSpacer2)
      object tbCoding: TRzToolButton
        Left = 1
        Top = 0
        Width = 61
        ImageIndex = 11
        Caption = 'Coding'
        OnClick = mniDECodeEntriesClick
      end
      object tbBudget: TRzToolButton
        Left = 62
        Top = 0
        Width = 62
        ImageIndex = 12
        Caption = 'Budget'
        OnClick = mniDEEnterBudgetsClick
      end
      object tbReport: TRzToolButton
        Left = 124
        Top = 0
        Width = 80
        DropDownMenu = popReport
        ImageIndex = 13
        ToolStyle = tsDropDown
        Caption = 'Reports'
      end
      object tbGraph: TRzToolButton
        Left = 204
        Top = 0
        Width = 76
        DropDownMenu = popGraph
        ImageIndex = 14
        ToolStyle = tsDropDown
        Caption = 'Graphs'
      end
      object tbGST: TRzToolButton
        Left = 280
        Top = 0
        Width = 74
        DropDownMenu = popGST
        ImageIndex = 15
        ToolStyle = tsDropDown
        Caption = 'GST'
      end
      object RzToolButton13: TRzToolButton
        Left = 354
        Top = 0
        Action = actTasks
        Caption = 'Tasks'
      end
      object RzSpacer2: TRzSpacer
        Left = 414
        Top = 0
      end
    end
    object rztCoding: TRzToolbar
      Left = 18
      Top = 97
      Width = 919
      Align = alNone
      AutoResize = False
      AutoStyle = False
      Images = AppImages.Coding
      Margin = 1
      TopMargin = 0
      ButtonWidth = 60
      ShowButtonCaptions = True
      TextOptions = ttoSelectiveTextOnRight
      OnVisibleChanged = tbarVisibleChanged
      BorderInner = fsPopup
      BorderOuter = fsNone
      BorderSides = [sdLeft, sdRight]
      BorderWidth = 0
      TabOrder = 2
      VisualStyle = vsClassic
      ToolbarControls = (
        tbNew
        tbChart
        tbPayee
        tbJob
        tbMemorise
        tbRecommendedMemorisations
        tbDissect
        tbSuper
        tbSort
        tbGoto
        tbRepeat
        tbView
        tbFind
        tbUPI
        tbQuery
        tbCodingHelp
        tbCodingClose
        RzSpacer4)
      object tbCodingHelp: TRzToolButton
        Left = 135
        Top = 25
        ImageIndex = 10
        Caption = 'Help'
        OnClick = tbCodingHelpClick
      end
      object tbUPI: TRzToolButton
        Left = 1
        Top = 25
        Width = 74
        DropDownMenu = popUPI
        ImageIndex = 9
        ToolStyle = tsDropDown
        Caption = 'UPC'
        OnClick = tbUPIClick
      end
      object tbFind: TRzToolButton
        Left = 828
        Top = 0
        AllowAllUp = True
        GroupIndex = 44
        ImageIndex = 7
        Caption = 'Find'
        OnClick = tbFindClick
      end
      object tbView: TRzToolButton
        Left = 754
        Top = 0
        Width = 74
        DropDownMenu = popView
        ImageIndex = 8
        ToolStyle = tsDropDown
        Caption = 'View'
      end
      object tbRepeat: TRzToolButton
        Left = 691
        Top = 0
        Width = 63
        ImageIndex = 6
        Caption = 'Repeat'
        OnClick = tbRepeatClick
      end
      object tbGoto: TRzToolButton
        Left = 631
        Top = 0
        ImageIndex = 5
        Caption = 'Goto'
        OnClick = tbGotoClick
      end
      object tbSort: TRzToolButton
        Left = 557
        Top = 0
        Width = 74
        DropDownMenu = popSortBy
        ImageIndex = 4
        ToolStyle = tsDropDown
        Caption = 'Sort'
      end
      object tbSuper: TRzToolButton
        Left = 497
        Top = 0
        ImageIndex = 11
        Caption = 'Super'
        OnClick = tbSuperClick
      end
      object tbDissect: TRzToolButton
        Left = 435
        Top = 0
        Width = 62
        ImageIndex = 3
        Caption = 'Dissect'
        OnClick = tbDissectClick
      end
      object tbMemorise: TRzToolButton
        Left = 241
        Top = 0
        ImageIndex = 2
        Caption = 'Mem'
        OnClick = tbMemoriseClick
      end
      object tbPayee: TRzToolButton
        Left = 121
        Top = 0
        ImageIndex = 1
        Caption = 'Payee'
        OnClick = tbPayeeClick
      end
      object tbNew: TRzToolButton
        Left = 1
        Top = 0
        ImageIndex = 15
        Caption = 'New'
        OnClick = tbNewClick
      end
      object tbChart: TRzToolButton
        Left = 61
        Top = 0
        ImageIndex = 0
        Caption = 'Chart'
        OnClick = tbChartClick
      end
      object tbQuery: TRzToolButton
        Left = 75
        Top = 25
        ImageIndex = 17
        Caption = 'Query'
        OnClick = tbQueryClick
      end
      object RzSpacer4: TRzSpacer
        Left = 255
        Top = 25
      end
      object tbJob: TRzToolButton
        Left = 181
        Top = 0
        ImageIndex = 18
        Caption = 'Job'
        OnClick = tbJobClick
      end
      object tbCodingClose: TRzToolButton
        Left = 195
        Top = 25
        ImageIndex = 2
        Images = AppImages.Maintain
        Caption = 'Close'
        Visible = False
        OnClick = tbCodingCloseClick
      end
      object tbRecommendedMemorisations: TRzToolButton
        Left = 301
        Top = 0
        Width = 134
        Hint = 'Suggest Memorisations'
        ImageIndex = 20
        Caption = 'Suggested Mems'
        Constraints.MinWidth = 134
        Visible = False
        OnClick = tbRecommendedMemorisationsClick
      end
    end
    object rztBudget: TRzToolbar
      Left = 3
      Top = 69
      Width = 955
      Align = alNone
      AutoResize = False
      AutoStyle = False
      Images = AppImages.Budgets
      Margin = 1
      TopMargin = 0
      ButtonWidth = 60
      ShowButtonCaptions = True
      TextOptions = ttoCustom
      WrapControls = False
      OnVisibleChanged = tbarVisibleChanged
      BorderInner = fsPopup
      BorderOuter = fsNone
      BorderSides = [sdLeft, sdRight]
      BorderWidth = 0
      TabOrder = 3
      VisualStyle = vsClassic
      ToolbarControls = (
        tbBudgetChart
        tbZero
        tbGenerate
        tbSmooth
        tbAverage
        tbCopy
        tbIncrease
        tbSplit
        tbBudgetHide
        tbBudgetShow
        tbBudgetClose
        tbBudgetImport
        tbBudgetExport
        tbBudgetHelp
        RzSpacer5)
      object tbZero: TRzToolButton
        Left = 61
        Top = 0
        Width = 88
        DropDownMenu = PopGetClients
        ImageIndex = 5
        ToolStyle = tsDropDown
        Caption = 'Clear'
        Constraints.MinWidth = 88
      end
      object tbGenerate: TRzToolButton
        Left = 149
        Top = 0
        Width = 73
        ImageIndex = 0
        Caption = 'Generate'
        OnClick = tbGenerateClick
      end
      object tbSmooth: TRzToolButton
        Left = 222
        Top = 0
        Width = 64
        ImageIndex = 4
        Caption = 'Smooth'
        OnClick = tbSmoothClick
      end
      object tbAverage: TRzToolButton
        Left = 286
        Top = 0
        Width = 69
        ImageIndex = 3
        Caption = 'Average'
        OnClick = tbAverageClick
      end
      object tbCopy: TRzToolButton
        Left = 355
        Top = 0
        ImageIndex = 1
        Caption = 'Copy'
        OnClick = tbCopyClick
      end
      object tbIncrease: TRzToolButton
        Left = 415
        Top = 0
        Width = 65
        ImageIndex = 6
        Caption = 'Inc/Dec'
        OnClick = tbIncreaseClick
      end
      object tbSplit: TRzToolButton
        Left = 480
        Top = 0
        ImageIndex = 2
        Caption = 'Split'
        OnClick = tbSplitClick
      end
      object tbBudgetHelp: TRzToolButton
        Left = 879
        Top = 0
        ImageIndex = 20
        Images = AppImages.Maintain
        Caption = 'Help'
        OnClick = tbBudgetHelpClick
      end
      object tbBudgetHide: TRzToolButton
        Left = 540
        Top = 0
        Width = 91
        ImageIndex = 7
        Caption = 'Hide Unused '
        OnClick = tbBudgetHideClick
      end
      object tbBudgetShow: TRzToolButton
        Left = 631
        Top = 0
        Width = 68
        Hint = 'Show all rows'
        ImageIndex = 8
        Caption = 'Show All'
        OnClick = tbBudgetShowClick
      end
      object tbBudgetChart: TRzToolButton
        Left = 1
        Top = 0
        ImageIndex = 9
        Caption = 'Chart'
        OnClick = tbBudgetChartClick
      end
      object tbBudgetClose: TRzToolButton
        Left = 699
        Top = 0
        ImageIndex = 2
        Images = AppImages.Maintain
        Caption = 'Close'
        Visible = False
        OnClick = tbBudgetCloseClick
      end
      object tbBudgetImport: TRzToolButton
        Left = 759
        Top = 0
        Hint = 'Import Budget'
        ImageIndex = 11
        Images = AppImages.Budgets
        Caption = 'Import'
        OnClick = tbBudgetImportClick
      end
      object tbBudgetExport: TRzToolButton
        Left = 819
        Top = 0
        Hint = 'Export Budget'
        ImageIndex = 10
        Images = AppImages.Budgets
        Caption = 'Export'
        OnClick = tbBudgetExportClick
      end
      object RzSpacer5: TRzSpacer
        Left = 939
        Top = 0
      end
    end
  end
  object MainMenu: TMainMenu
    Images = AppImages.Client
    Left = 544
    Top = 192
    object mnsFile: TMenuItem
      Caption = '&File'
      object mniFileNew: TMenuItem
        Caption = '&New'
        ImageIndex = 0
        OnClick = mniFileNewClick
      end
      object mniFileOpen: TMenuItem
        Caption = 'C&lients'
        ImageIndex = 16
        ShortCut = 8315
        OnClick = mniFileOpenClick
      end
      object mniHome: TMenuItem
        Caption = 'Ho&me'
        ImageIndex = 22
        ShortCut = 8314
        OnClick = ActHomePageExecute
      end
      object mniFileClose: TMenuItem
        Caption = '&Close'
        OnClick = mniFileCloseClick
      end
      object mniSeparator: TMenuItem
        Caption = '-'
      end
      object mniFileSave: TMenuItem
        Caption = '&Save'
        ImageIndex = 2
        ShortCut = 16467
        OnClick = mniFileSaveClick
      end
      object mniFileSaveAs: TMenuItem
        Caption = 'Save &As'
        OnClick = mniFileSaveAsClick
      end
      object N36: TMenuItem
        Caption = '-'
      end
      object mniBackup: TMenuItem
        Caption = 'Bac&kup'
        OnClick = mniBackupClick
      end
      object mniRestore: TMenuItem
        Caption = '&Restore'
        OnClick = mniRestoreClick
      end
      object NA2: TMenuItem
        Caption = '-'
      end
      object mniChangePassword: TMenuItem
        Caption = 'Change &Password'
        OnClick = mniChangePasswordClick
      end
      object mniFileInformation: TMenuItem
        Caption = '&Information'
        ImageIndex = 6
        OnClick = mniFileInformationClick
      end
      object mniFilePreferences: TMenuItem
        Caption = 'Pre&ferences'
        OnClick = mniFilePreferenceClick
      end
      object NA4: TMenuItem
        Caption = '-'
      end
      object mniFileCheckIn: TMenuItem
        Caption = '&Get Client Files'
        ImageIndex = 9
        OnClick = mniFileCheckInClick
        object fromFile1: TMenuItem
          Action = actGetFromFolder
        end
        object viaBankLinkOnline3: TMenuItem
          Action = actGetFromOnline
        end
      end
      object mniSendClientFiles: TMenuItem
        Caption = 'S&end Client Files'
        ImageIndex = 10
        OnClick = mniSendClientFilesClick
        object oFile1: TMenuItem
          Action = actSendToFile
        end
        object viaEmail2: TMenuItem
          Action = actSendViaEmail
        end
        object viaBankLinkOnline2: TMenuItem
          Action = actSendViaOnline
        end
      end
      object NA5: TMenuItem
        Caption = '-'
      end
      object mniFileAbandonChanges: TMenuItem
        Caption = 'A&bandon Changes'
        ImageIndex = 5
        OnClick = mniFileAbandonChangesClick
      end
      object mniFileExchangeRates: TMenuItem
        Caption = 'Main&tain Exchange Rates'
        OnClick = mniFileExchangeRatesClick
      end
      object MRUStart: TMenuItem
        Caption = '-'
        Visible = False
        OnClick = MRUStartClick
      end
      object MRUEnd: TMenuItem
        Caption = '-'
      end
      object mniFileExit: TMenuItem
        Caption = 'E&xit'
        OnClick = mniFileExitClick
      end
    end
    object mnsDataEntry: TMenuItem
      Caption = '&Data Entry'
      object mniDECodeEntries: TMenuItem
        Caption = '&Code Entries'
        ImageIndex = 11
        OnClick = mniDECodeEntriesClick
      end
      object mniAddHistorical: TMenuItem
        Caption = '&Historical Entries'
        OnClick = mniAddHistoricalClick
      end
      object mniAddManual: TMenuItem
        Caption = '&Manual Entries'
        OnClick = mniAddManualClick
      end
      object NB1: TMenuItem
        Caption = '-'
      end
      object mniDEEnterBudgets: TMenuItem
        Caption = '&Budgets'
        ImageIndex = 12
        OnClick = mniDEEnterBudgetsClick
      end
      object NB2: TMenuItem
        Caption = '-'
      end
      object mniDECashJournals: TMenuItem
        Caption = 'Cash &Journals'
        OnClick = mniDECashJournalsClick
      end
      object mniDEAccrualJournals: TMenuItem
        Caption = '&Accrual Journals'
        OnClick = mniDEAccrualJournalsClick
      end
      object NB3: TMenuItem
        Caption = '-'
      end
      object mnsDENoTransJournals: TMenuItem
        Caption = '&Non-Transferring Journals'
        object mniOpeningsBalanceJnls: TMenuItem
          Caption = '&Opening Balances'
          OnClick = mniOpeningsBalanceJnlsClick
        end
        object mniStockBalancesJnls: TMenuItem
          Caption = '&Stock Balances'
          OnClick = mniStockBalancesJnlsClick
        end
        object mniDENTJStockJournals: TMenuItem
          Caption = 'Stock/&Adjustment Journals'
          OnClick = mniDENTJStockJournalsClick
        end
        object mniYearEndAdjustments: TMenuItem
          Caption = '&Year End Adjustments'
          OnClick = mniYearEndAdjustmentsClick
        end
        object N32: TMenuItem
          Caption = '-'
        end
        object mniDENTJGSTJournals: TMenuItem
          Caption = '&GST Journals'
          OnClick = mniDENTJGSTJournalsClick
        end
      end
      object N31: TMenuItem
        Caption = '-'
      end
      object mniDEOpeningBalances: TMenuItem
        Caption = '&Opening Balances'
        OnClick = mniDEOpeningBalancesClick
      end
      object mniYearEnd: TMenuItem
        Caption = '&Year End Balances'
        OnClick = mniYearEndClick
      end
      object N46: TMenuItem
        Caption = '-'
      end
      object mniExchangeGainLossWizard: TMenuItem
        Caption = 'Calculate &Exchange Gain/Loss'
        OnClick = mniExchangeGainLossWizardClick
      end
      object N44: TMenuItem
        Caption = '-'
      end
      object mniFindandReplace: TMenuItem
        Caption = '&Find and Replace'
        OnClick = mniFindandReplaceClick
      end
    end
    object mnsReport: TMenuItem
      Caption = '&Reports'
      OnClick = mnsReportClick
      object mniCodingReport: TMenuItem
        Caption = '&Coding Report'
        ImageIndex = 20
        OnClick = mniCodingReportClick
      end
      object mniListLedger: TMenuItem
        Caption = '&Ledger Report'
        OnClick = mniListLedgerClick
      end
      object N33: TMenuItem
        Caption = '-'
        Visible = False
      end
      object mniBatchReports: TMenuItem
        Caption = '&Favourite Reports'
        ImageIndex = 25
        OnClick = mniBatchReportsClick
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object mnsCashFlowReports: TMenuItem
        Caption = 'C&ash Flow Reports'
        object mniCFRActual: TMenuItem
          Caption = '&1 Actual'
          OnClick = mniCFRActualClick
        end
        object mniCFRActualandBudget: TMenuItem
          Caption = '&2 Actual and Budget'
          OnClick = mniCFRActualandBudgetClick
        end
        object mniCFRActualBudgetandVariance: TMenuItem
          Caption = '&3 Actual, Budget and Variance'
          OnClick = mniCFRActualBudgetandVarianceClick
        end
        object mniCFR12MonthsActual: TMenuItem
          Caption = '&4 12 Months Actual'
          OnClick = mniCFR12MonthsActualClick
        end
        object mniBudgetReport: TMenuItem
          Caption = '&5 12 Months Budget'
          OnClick = mniBudgetReportClick
        end
        object mniCFR12MonthsActualandBudget: TMenuItem
          Caption = '&6 12 Months Actual or Budget'
          OnClick = mniCFR12MonthsActualandBudgetClick
        end
        object mniCFRFromDatetoDate: TMenuItem
          Caption = '&7 From Date to Date'
          OnClick = mniCFRFromDatetoDateClick
        end
        object mniCFRBudgetRemaining: TMenuItem
          Caption = '&8 Budget Remaining'
          OnClick = mniCFRBudgetRemainingClick
        end
        object miCFRActualLastYearVariance: TMenuItem
          Caption = '&9 This Year, Last Year and Variance'
          OnClick = miCFRActualLastYearVarianceClick
        end
        object mniCFCustom: TMenuItem
          Caption = '1&0 Custom'
          OnClick = mniCFCustomClick
        end
        object mniCFExportSeperator: TMenuItem
          Caption = '-'
        end
        object mniCFExport: TMenuItem
          Caption = 'E&xport'
          OnClick = mniCFExportClick
        end
        object N11: TMenuItem
          Caption = '-'
        end
        object mniCFRSetupReportHeadings: TMenuItem
          Caption = '&Set Up Titles and Headings'
          OnClick = mniCFRSetupReportHeadingsClick
        end
      end
      object mnsProfitabilityReports: TMenuItem
        Caption = '&Profit and Loss Reports'
        object mniPRActual: TMenuItem
          Caption = '&1 Actual'
          OnClick = mniPRActualClick
        end
        object mniPRActualAndBudget: TMenuItem
          Caption = '&2 Actual and Budget'
          OnClick = mniPRActualAndBudgetClick
        end
        object mniPRActualBudgetAndVariance: TMenuItem
          Caption = '&3 Actual, Budget and Variance'
          OnClick = mniPRActualBudgetAndVarianceClick
        end
        object mniPR12MonthsActual: TMenuItem
          Caption = '&4 12 Months Actual'
          OnClick = mniPR12MonthsActualClick
        end
        object mniPR12MonthsActualandBudget: TMenuItem
          Caption = '&5 12 Months Actual or Budget'
          OnClick = mniPR12MonthsActualandBudgetClick
        end
        object mniRP12MonthsBudget: TMenuItem
          Caption = '&6 12 Months Budget'
          OnClick = mniRP12MonthsBudgetClick
        end
        object mniPRCustom: TMenuItem
          Caption = '&7 Custom'
          OnClick = mniPRCustomClick
        end
        object mniPRExportSeperator: TMenuItem
          Caption = '-'
        end
        object mniPRExport: TMenuItem
          Caption = 'E&xport'
          OnClick = mniPRExportClick
        end
        object N12: TMenuItem
          Caption = '-'
        end
        object mniPRSetupReportHeadings: TMenuItem
          Caption = '&Set Up Titles and Headings'
          OnClick = mniPRSetupReportHeadingsClick
        end
      end
      object mnsTrialBalance: TMenuItem
        Caption = '&Trial Balance Report'
        OnClick = mnsTrialBalanceClick
      end
      object mnsBalanceSheet: TMenuItem
        Caption = 'Balance &Sheet'
        object mniBalanceSheet: TMenuItem
          Caption = '&1 Balance Sheet Report'
          OnClick = mniBalanceSheetClick
        end
        object mniBalanceExportSeperator: TMenuItem
          Caption = '-'
        end
        object mniBalanceExport: TMenuItem
          Caption = 'E&xport'
          OnClick = mniBalanceExportClick
        end
        object N30: TMenuItem
          Caption = '-'
        end
        object mniSetUpReportHeadings: TMenuItem
          Caption = '&Set Up Titles and Headings'
          OnClick = mniSetUpReportHeadingsClick
        end
      end
      object N29: TMenuItem
        Caption = '-'
      end
      object mnsBankReconciliation: TMenuItem
        Caption = '&Bank Reconciliation'
        object mniBRRSummarised: TMenuItem
          Caption = '&Summarised'
          OnClick = mniBRRSummarisedClick
        end
        object mniBRRDetailed: TMenuItem
          Caption = '&Detailed'
          OnClick = mniBRRDetailedClick
        end
        object mniForexReport: TMenuItem
          Caption = '&Foreign Exchange'
          OnClick = mniForexReportClick
        end
        object N35: TMenuItem
          Caption = '-'
        end
        object mniUnpresentedItems: TMenuItem
          Caption = 'List &Unpresented Items'
          OnClick = mniUnpresentedItemsClick
        end
      end
      object mnsGSTReports: TMenuItem
        Caption = '&GST Reports'
        object mniGSTReturn: TMenuItem
          Caption = 'GST &Return'
          OnClick = mniGSTReturnClick
        end
        object mniGSTAuditTrail: TMenuItem
          Caption = 'GST &Audit Trail'
          OnClick = mniGSTAuditTrailClick
        end
        object mniGSTSummary: TMenuItem
          Caption = 'GST &Summary'
          OnClick = mniGSTSummaryClick
        end
        object mniGSTAllocationSummary: TMenuItem
          Caption = 'GST Allocation Summary'
          Visible = False
          OnClick = mniGSTAllocationSummaryClick
        end
        object mniGST12MonthSummary: TMenuItem
          Caption = 'GST Re&conciliation'
          OnClick = mniGST12MonthSummaryClick
        end
        object GSTOverrides1: TMenuItem
          Caption = 'GST &Overrides'
          OnClick = GSTOverrides1Click
        end
        object N25: TMenuItem
          Caption = '-'
        end
        object mniAnnualGSTreport: TMenuItem
          Caption = 'Annual GST &Information Report'
          OnClick = mniAnnualGSTreportClick
        end
        object mniAnnualGSTReturn: TMenuItem
          Caption = 'Annual GST R&eturn'
          OnClick = mniAnnualGSTReturnClick
        end
        object N27: TMenuItem
          Caption = '-'
        end
        object mniBusinessNorms: TMenuItem
          Caption = 'Business &Norm Percentages Report'
          OnClick = mniBusinessNormsClick
        end
        object N13: TMenuItem
          Caption = '-'
        end
        object mniGSTSetupReportOptions: TMenuItem
          Caption = '&GST Set Up'
          OnClick = mniGSTSetupReportOptionsClick
        end
      end
      object mnsSpendingbyPayee: TMenuItem
        Caption = '&Spending by Payee'
        OnClick = mnsSpendingbyPayeeClick
      end
      object mmiTaxablePaymentsReport: TMenuItem
        Caption = 'Taxable Payments Annual Report'
        OnClick = mmiTaxablePaymentsReportClick
      end
      object mnsJobReport: TMenuItem
        Caption = 'Coding by &Job'
        OnClick = mnsJobReportClick
      end
      object mnsExceptions: TMenuItem
        Caption = '&Exception Report'
        object mniExPrintExceptionReport: TMenuItem
          Caption = '&Print Exception Report'
          OnClick = mniExPrintExceptionReportClick
        end
        object N14: TMenuItem
          Caption = '-'
        end
        object mniSetupExceptionCriteria: TMenuItem
          Caption = '&Setup Exception Criteria'
          OnClick = mniSetupExceptionCriteriaClick
        end
      end
      object mniOffsiteDownloadLog: TMenuItem
        Caption = '&Download Log Report'
        OnClick = mniOffsiteDownloadLogClick
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object mnsListings: TMenuItem
        Caption = 'L&istings'
        object mniListBankAccounts: TMenuItem
          Caption = 'List &Bank Accounts'
          OnClick = mniListBankAccountsClick
        end
        object mniListChartofAccounts: TMenuItem
          Caption = 'List &Chart of Accounts'
          OnClick = mniListChartofAccountsClick
        end
        object mniListDivisions: TMenuItem
          Caption = 'List &Divisions'
          OnClick = mniListDivisionsClick
        end
        object ListJobs1: TMenuItem
          Caption = 'List J&obs'
          OnClick = ListJobs1Click
        end
        object mniListEntries: TMenuItem
          Caption = 'List &Entries'
          OnClick = mniListEntriesClick
        end
        object mniListGSTDetails: TMenuItem
          Caption = 'List &GST Details'
          OnClick = mniListGSTDetailsClick
        end
        object mniListJournals: TMenuItem
          Caption = 'List &Journals'
          OnClick = mniListJournalsClick
        end
        object mniListMemorisations: TMenuItem
          Caption = 'List &Memorisations'
          OnClick = mniListMemorisationsClick
        end
        object mniMissingCheques: TMenuItem
          Caption = 'List M&issing Cheques'
          OnClick = mniMissingChequesClick
        end
        object mniListPayees: TMenuItem
          Caption = 'List &Payees'
          OnClick = mniListPayeesClick
        end
        object mniListSubGroups: TMenuItem
          Caption = 'List &Sub-groups'
          OnClick = mniListSubGroupsClick
        end
      end
      object SepReportSchedule: TMenuItem
        Caption = '-'
      end
      object mniReportSchedule: TMenuItem
        Caption = '&Report Schedule'
        ImageIndex = 24
        OnClick = mniReportScheduleClick
      end
      object N41: TMenuItem
        Caption = '-'
      end
      object mniReportOption: TMenuItem
        Caption = 'Re&port and Graph Options'
        Visible = False
        OnClick = mniReportStyleClick
      end
    end
    object mnsGraph: TMenuItem
      Caption = '&Graphs'
      object mniGraphSales: TMenuItem
        Caption = '&Sales'
        OnClick = mniGraphSalesClick
      end
      object mniGraphPayments: TMenuItem
        Caption = '&Payments'
        OnClick = mniGraphPaymentsClick
      end
      object mniGraphTradingResults: TMenuItem
        Caption = '&Trading Results'
        OnClick = mniGraphTradingResultsClick
      end
      object mniGraphBankBalances: TMenuItem
        Caption = 'Total &Bank Balance'
        OnClick = mniGraphBankBalancesClick
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object mniGraphOnePageSummary: TMenuItem
        Caption = '&One Page Summary'
        OnClick = mniGraphOnePageSummaryClick
      end
      object N42: TMenuItem
        Caption = '-'
      end
      object mniSetupGraphHeadings: TMenuItem
        Caption = 'Set &Up Titles and Headings'
        OnClick = mniSetupGraphHeadingsClick
      end
    end
    object mnsOtherFunctions: TMenuItem
      Caption = '&Other Functions'
      object mniOFClientDetails: TMenuItem
        Caption = 'Client &Details'
        OnClick = mniOFClientDetailsClick
      end
      object mniOFAccountingSystem: TMenuItem
        Caption = '&Accounting System'
        OnClick = mniOFAccountingSystemClick
      end
      object N15: TMenuItem
        Caption = '-'
      end
      object mniOFGSTDetailsandRates: TMenuItem
        Caption = '&GST Set Up'
        ImageIndex = 15
        OnClick = mniOFGSTDetailsandRatesClick
      end
      object mnsOFChartofAccounts: TMenuItem
        Caption = '&Chart of Accounts'
        OnClick = mnsOFChartofAccountsClick
        object mniMaintainChart: TMenuItem
          Caption = 'Maintain &Chart'
          OnClick = mniMaintainChartClick
        end
        object mniSetupDivisions: TMenuItem
          Caption = 'Set Up &Divisions'
          OnClick = mniSetupDivisionsClick
        end
        object mniSetupSubgroups: TMenuItem
          Caption = 'Set Up &Sub-groups'
          OnClick = mniSetupSubgroupsClick
        end
        object mniExportCharttoMYOBCashBooks1: TMenuItem
          Caption = 'E&xport Chart to MYOB Essentials Cashbook'
          OnClick = mniExportCharttoMYOBCashBooks1Click
        end
      end
      object mniOFPayees: TMenuItem
        Caption = '&Payees'
        ImageIndex = 30
        OnClick = mniOFPayeesClick
      end
      object mniJobs: TMenuItem
        Caption = '&Jobs'
        ImageIndex = 28
        OnClick = mniJobsClick
      end
      object mniOFBankAccounts: TMenuItem
        Caption = '&Bank Accounts'
        OnClick = mniOFBankAccountsClick
      end
      object mniOFMemorisedEntries: TMenuItem
        Caption = '&Memorised Entries'
        OnClick = mniOFMemorisedEntriesClick
      end
      object mniOFMacros: TMenuItem
        Caption = 'Ma&cros'
        Enabled = False
        Visible = False
      end
      object mnsTemplates: TMenuItem
        Caption = '&Templates'
        object mniLoadBASTemplate: TMenuItem
          Caption = '&Load BAS Template'
          OnClick = mniLoadBASTemplateClick
        end
        object mniSaveBASTemplate: TMenuItem
          Caption = '&Save BAS Template'
          OnClick = mniSaveBASTemplateClick
        end
      end
      object N16: TMenuItem
        Caption = '-'
      end
      object mniOFRefreshChart: TMenuItem
        Caption = '&Refresh Chart'
        OnClick = mniOFRefreshChartClick
      end
      object mniOFExtractData: TMenuItem
        Caption = '&Extract Data'
        ImageIndex = 23
        OnClick = mniOFExtractDataClick
      end
      object mniOffsiteDownload: TMenuItem
        Caption = 'Download &New Data'
        ImageIndex = 26
        OnClick = mniOffsiteDownloadClick
      end
      object N26: TMenuItem
        Caption = '-'
      end
      object mnsExportBNoteFile: TMenuItem
        Caption = 'E&xport BNote File'
        ImageIndex = 20
        object mniExportBNToFile: TMenuItem
          Caption = 'To &File'
          OnClick = mniExportBNToFileClick
        end
        object mniExportBNtoMail: TMenuItem
          Caption = 'Via &Email'
          OnClick = mniExportBNtoMailClick
        end
      end
      object mnsImportBNotes: TMenuItem
        Caption = 'Imp&ort BNotes File'
        ImageIndex = 20
        OnClick = mnsImportBNotesClick
      end
      object mniExportWebX: TMenuItem
        Caption = 'Export to Web&XOffice'
        OnClick = mniExportWebXClick
      end
      object mniImportWebX: TMenuItem
        Caption = 'Import from &WebXOffice'
        OnClick = mniImportWebXClick
      end
      object N39: TMenuItem
        Caption = '-'
      end
      object mniQuery: TMenuItem
        Caption = '&Query Uncoded Transactions'
        ImageIndex = 8
        OnClick = mniQueryClick
      end
      object N17: TMenuItem
        Caption = '-'
      end
      object mnsOFHouseKeeping: TMenuItem
        Caption = '&House Keeping'
        object mniClearTransferFlags: TMenuItem
          Caption = '&Clear the Transfer Flags for a Period'
          OnClick = mniClearTransferFlagsClick
        end
        object SettheTransferFlagsforaPeriod1: TMenuItem
          Caption = '&Set the Transfer Flags for a Period'
          OnClick = SettheTransferFlagsforaPeriod1Click
        end
        object mniDeleteNotes: TMenuItem
          Caption = '&Delete Notes for a Period'
          OnClick = mniDeleteNotesClick
        end
        object mniDEFinalisePeriod: TMenuItem
          Caption = '&Lock Accounting Period'
          OnClick = mniDEFinalisePeriodClick
        end
        object mniOFUnlockaFinalisedPeriod: TMenuItem
          Caption = '&Unlock Accounting Period'
          OnClick = mniOFUnlockaFinalisedPeriodClick
        end
        object N37: TMenuItem
          Caption = '-'
        end
        object mniImportUpdate: TMenuItem
          Caption = '&Import an Update File'
          OnClick = mniImportUpdateClick
        end
        object mniCombineAccounts: TMenuItem
          Caption = 'Co&mbine System Bank Accounts'
          OnClick = mniCombineAccountsClick
        end
        object mniCombineManual: TMenuItem
          Caption = 'Com&bine Manual Bank Accounts'
          OnClick = mniCombineManualClick
        end
        object mniTransferEntries: TMenuItem
          Caption = 'Combi&ne Manual && System Bank Accounts'
          OnClick = mniTransferEntriesClick
        end
        object N2: TMenuItem
          Caption = '-'
        end
        object mniOFPurgeOldEntries: TMenuItem
          Caption = '&Purge Old Entries'
          OnClick = mniOFPurgeOldEntriesClick
        end
        object N21: TMenuItem
          Caption = '-'
        end
        object mniSyncroniseMyClient: TMenuItem
          Caption = '&Synchronise'
          OnClick = mniSyncroniseMyClientClick
        end
        object N99: TMenuItem
          Caption = '-'
        end
        object mniRemapChart: TMenuItem
          Caption = 'Con&vert Chart'
          OnClick = mniReMapChartClick
        end
      end
      object mniViewTasks: TMenuItem
        Action = actTasks
      end
      object N40: TMenuItem
        Caption = '-'
      end
      object mniResetFingerTipsLinks: TMenuItem
        Caption = 'Reset Attachment Links'
        OnClick = mniResetFingerTipsLinksClick
      end
    end
    object mnsSystem: TMenuItem
      Caption = '&System'
      object mniSystemPracticeDetails: TMenuItem
        Caption = '&Practice Details'
        OnClick = mniSystemPracticeDetailsClick
      end
      object mniSystemGSTDefaults: TMenuItem
        Caption = 'Practice &GST Defaults'
        OnClick = mniSystemGSTDefaultsClick
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object PracticeBankAccounts1: TMenuItem
        Caption = '&Bank Accounts'
        OnClick = PracticeBankAccounts1Click
      end
      object mnsSystemClients: TMenuItem
        Caption = 'Maintain &Clients'
        SubMenuImages = AppImages.Client
        ImageIndex = 16
        OnClick = mnsSystemClientsClick
      end
      object MasterMemorisedEntries1: TMenuItem
        Caption = '&Master Memorised Entries'
        OnClick = MasterMemorisedEntries1Click
      end
      object mniSystemTranTypes: TMenuItem
        Caption = '&Transaction Types'
        Visible = False
        OnClick = mniSystemTranTypesClick
      end
      object mniSystemUsers: TMenuItem
        Caption = '&Users'
        ImageIndex = 21
        OnClick = mniSystemUsersClick
      end
      object mniSystemGroups: TMenuItem
        Caption = 'Gr&oups'
        ImageIndex = 27
        OnClick = mniSystemGroupsClick
      end
      object ClientTypes1: TMenuItem
        Caption = 'Clie&nt Types'
        ImageIndex = 29
        OnClick = ClientTypes1Click
      end
      object N19: TMenuItem
        Caption = '-'
      end
      object mnsSystemStartNewMonth: TMenuItem
        Caption = '&Start New Period'
        object mniSystemBankLinkConnect: TMenuItem
          Caption = 'Download from &BankLink Secure'
          ImageIndex = 26
          OnClick = mniSystemBankLinkConnectClick
        end
        object mniSystemDownloadfromFloppy: TMenuItem
          Caption = 'Download from &Floppy'
          ImageIndex = 26
          Visible = False
          OnClick = mniSystemDownloadfromFloppyClick
        end
        object N20: TMenuItem
          Caption = '-'
          Enabled = False
        end
        object mnsDownloadReport: TMenuItem
          Caption = 'Download &Report'
          object DownloadReport1: TMenuItem
            Caption = '&Detailed'
            OnClick = DownloadReport1Click
          end
          object DownloadReportSummarised1: TMenuItem
            Caption = '&Summarised'
            OnClick = DownloadReportSummarised1Click
          end
        end
        object mniSystemNewAccounts: TMenuItem
          Caption = 'Setup &New Accounts'
          OnClick = mniSystemNewAccountsClick
        end
        object N3: TMenuItem
          Caption = '-'
        end
        object ListReportsDue1: TMenuItem
          Caption = 'List Reports &Due'
          Visible = False
          OnClick = ListReportsDue1Click
        end
        object mniSystemMonthlyReports: TMenuItem
          Caption = 'S&cheduled Reports'
          ImageIndex = 24
          OnClick = mniSystemMonthlyReportsClick
        end
      end
      object mniSystemReports: TMenuItem
        Caption = 'System &Reports'
        OnClick = mniSystemReportsClick
        object Viewdownloaddocuments1: TMenuItem
          Caption = 'Statements and Download Documents'
          OnClick = Viewdownloaddocuments1Click
        end
        object N8: TMenuItem
          Caption = '-'
        end
        object mniListAdminBankAccounts: TMenuItem
          Caption = 'List &Bank Accounts'
          OnClick = mniListAdminBankAccountsClick
        end
        object mniListProvisional: TMenuItem
          Caption = 'List Provisional Bank Accounts'
          OnClick = mniListProvisionalClick
        end
        object mniListInactive: TMenuItem
          Caption = 'List &Inactive Bank Accounts'
          OnClick = mniListInactiveClick
        end
        object mniListManual: TMenuItem
          Caption = 'List &Manual Bank Accounts'
          OnClick = mniListManualClick
        end
        object mniClientsByStaff: TMenuItem
          Caption = 'List &Clients by Staff Member'
          OnClick = mniClientsByStaffClick
        end
        object mniClientReportOptions: TMenuItem
          Caption = 'List Client &Report Options'
          OnClick = mniClientReportOptionsClick
        end
        object ListGroups1: TMenuItem
          Caption = 'List &Groups'
          OnClick = ListGroups1Click
        end
        object ListClientTypes1: TMenuItem
          Caption = 'List Client &Types'
          OnClick = ListClientTypes1Click
        end
        object mniClientStatusReport: TMenuItem
          Caption = 'Client &Status Report'
          OnClick = mniClientStatusReportClick
        end
        object mniClientFileAccessReport: TMenuItem
          Caption = 'Client &File Access Report'
          OnClick = mniClientFileAccessReportClick
        end
        object mniCodingOptimisationReport: TMenuItem
          Caption = 'Coding &Optimisation Report'
          OnClick = mniCodingOptimisationReportClick
        end
        object N24: TMenuItem
          Caption = '-'
        end
        object mniSystemAuditReport: TMenuItem
          Caption = 'Audit Report'
          OnClick = mniSystemAuditReportClick
        end
        object N45: TMenuItem
          Caption = '-'
        end
        object mniDownloadLog: TMenuItem
          Caption = '&Download Log'
          OnClick = mniDownloadLogClick
        end
      end
      object N34: TMenuItem
        Caption = '-'
      end
      object Options1: TMenuItem
        Caption = 'Opt&ions'
        OnClick = Options1Click
      end
      object mniReportStyle: TMenuItem
        AutoHotkeys = maAutomatic
        Caption = 'Re&port and Graph Options'
        OnClick = mniReportStyleClick
      end
      object mniCustomDocs: TMenuItem
        Caption = 'Custom Documents'
        OnClick = mniCustomDocsClick
      end
      object mniStatistics: TMenuItem
        Caption = '&View Statistics'
        Visible = False
        OnClick = mniStatisticsClick
      end
      object N22: TMenuItem
        Caption = '-'
        Visible = False
      end
      object mniSystemUtilities: TMenuItem
        Caption = 'Uti&lities'
        Visible = False
        object mniResyncroniseClient: TMenuItem
          Caption = '&Syncronise Client File'
          OnClick = mniResyncroniseClientClick
        end
      end
      object N38: TMenuItem
        Caption = '-'
      end
      object mniCharges: TMenuItem
        Caption = 'Ch&arges'
        object mniExportCharges: TMenuItem
          Caption = '&Export Charges'
          OnClick = mniExportChargesClick
        end
        object mniListCharges: TMenuItem
          Caption = 'List Charges'
          OnClick = mniListChargesClick
        end
        object mniMaintainFileCostCodes: TMenuItem
          Caption = 'Maintain File and Cost Codes'
          OnClick = mniMaintainFileCostCodesClick
        end
      end
      object mniExtractBulkData: TMenuItem
        Caption = 'Bulk Data Export'
        Hint = 'Extract Bulk Data'
        Visible = False
        OnClick = mniExtractBulkDataClick
        object mniBulkExportData: TMenuItem
          Caption = 'Export Data'
          OnClick = mniBulkExportDataClick
        end
        object mniBulkClearTransferFlags: TMenuItem
          Caption = 'Clear Transfer Flags'
          OnClick = mniBulkClearTransferFlagsClick
        end
      end
      object mniExportdatatoBanklinkOnline: TMenuItem
        Caption = 'E&xport data to Banklink Online'
        Visible = False
        OnClick = mniExportdatatoBanklinkOnlineClick
      end
    end
    object mnsWindow: TMenuItem
      Caption = '&Window'
      object mniWindowCascade: TMenuItem
        Caption = '&Cascade'
        Visible = False
        OnClick = mniWindowCascadeClick
      end
      object mniWindowTile: TMenuItem
        Caption = '&Tile'
        Visible = False
        OnClick = mniWindowTileClick
      end
    end
    object mnsHelp: TMenuItem
      Caption = '&Help'
      object mniBKHelp: TMenuItem
        Caption = '&Help'
        ImageIndex = 17
        ShortCut = 112
        OnClick = mniBKHelpClick
      end
      object mniTutorialsTOC: TMenuItem
        Caption = '&Tutorials'
        OnClick = mniTutorialsTOCClick
      end
      object mniPromos: TMenuItem
        Caption = 'MYOB &Communications'
        OnClick = mniPromosClick
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mniHelpProvideFeedback: TMenuItem
        Caption = 'Provide &Feedback'
        OnClick = mniHelpProvideFeedbackClick
      end
      object EmailSupport1: TMenuItem
        Caption = '&Email Support'
        OnClick = EmailSupport1Click
      end
      object EmailSystemLog1: TMenuItem
        Caption = 'E&mail System Log'
        OnClick = EmailSystemLog1Click
      end
      object mniHelpViewSystemLog: TMenuItem
        Caption = '&View System Log'
        OnClick = mniHelpViewSystemLogClick
      end
      object N28: TMenuItem
        Caption = '-'
      end
      object mniHelpAbout: TMenuItem
        Caption = '&About'
        OnClick = mniHelpAboutClick
      end
      object mniInstallCheckInExtn: TMenuItem
        Caption = 'Install Client File Handler...'
        OnClick = mniInstallCheckInExtnClick
      end
      object CRCFileCheck: TMenuItem
        Caption = 'CRC File Check'
        Visible = False
        OnClick = CRCFileCheckClick
      end
      object mniImportFromCSV: TMenuItem
        Caption = 'CSV Export and Import'
        Visible = False
        OnClick = mniImportFromCSVClick
      end
      object nUpdates: TMenuItem
        Caption = '-'
      end
      object mniCheckForUpdates: TMenuItem
        Caption = 'Check for &updates'
        OnClick = mniCheckForUpdatesClick
      end
    end
    object mnsTest: TMenuItem
      Caption = 'TestCode'
      Visible = False
      OnClick = mnsTestClick
      object mniTestAdminLocking: TMenuItem
        Caption = 'Test Locking'
        Visible = False
        OnClick = mniTestAdminLockingClick
      end
      object mniRaiseException: TMenuItem
        Caption = 'Raise Exception'
        OnClick = mniRaiseExceptionClick
      end
      object mniAssert: TMenuItem
        Caption = 'Assert'
        OnClick = mniAssertClick
      end
      object N10: TMenuItem
        Caption = '-'
      end
      object Utilities1: TMenuItem
        Caption = 'Utilities'
        Visible = False
        object IncrementDates1: TMenuItem
          Caption = 'Increment Dates'
          OnClick = IncrementDates1Click
        end
        object CreateAnalysisCodingTest1: TMenuItem
          Caption = 'Create Analysis Coding Test '
          OnClick = CreateAnalysisCodingTest1Click
        end
        object ChangetoUK1: TMenuItem
          Caption = 'Change to UK'
          OnClick = ChangetoUK1Click
        end
        object mniImportHSBC: TMenuItem
          Caption = 'Import HSBC Files'
          OnClick = mniImportHSBCClick
        end
      end
    end
  end
  object tmClock: TTimer
    Enabled = False
    OnTimer = tmClockTimer
    Left = 96
    Top = 224
  end
  object popView: TPopupMenu
    OnPopup = popViewPopup
    Left = 640
    Top = 216
    object mniViewAllEntries: TMenuItem
      Caption = '&All Entries'
      GroupIndex = 1
      OnClick = mniViewAllEntriesClick
    end
    object mniViewUncodedEntriesOnly: TMenuItem
      Caption = '&Uncoded Entries Only'
      GroupIndex = 1
      OnClick = mniViewUncodedEntriesOnlyClick
    end
    object N43: TMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object mniEntrieswithNotes: TMenuItem
      Caption = 'Entries with N&otes '
      GroupIndex = 1
      OnClick = mniEntrieswithNotesClick
    end
    object mniViewNotesOnly: TMenuItem
      Caption = 'Entries with Unread &Notes'
      GroupIndex = 1
      OnClick = mniViewNotesOnlyClick
    end
    object mniEntrieswithoutNotes: TMenuItem
      Caption = 'Entries without No&tes'
      GroupIndex = 1
      OnClick = mniEntrieswithoutNotesClick
    end
    object N1: TMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object mniViewEditCodesOnly: TMenuItem
      Caption = 'Edit A&ccounts Only'
      GroupIndex = 3
      OnClick = mniViewEditCodesOnlyClick
    end
    object mniViewEditAllCol: TMenuItem
      Caption = 'E&dit All Columns'
      GroupIndex = 3
      OnClick = mniViewEditAllColClick
    end
    object N23: TMenuItem
      Caption = '-'
      GroupIndex = 3
    end
    object mniConfigureColumns: TMenuItem
      Caption = 'Conf&igure Columns'
      GroupIndex = 3
      OnClick = mniConfigureColumnsClick
    end
    object RestoreColumnDefaults: TMenuItem
      Caption = '&Restore Column Defaults'
      GroupIndex = 3
      OnClick = RestoreColumnDefaultsClick
    end
  end
  object popSortBy: TPopupMenu
    OnPopup = popSortByPopup
    Left = 608
    Top = 216
  end
  object popOpen: TPopupMenu
    Left = 608
    Top = 184
  end
  object popReport: TPopupMenu
    Images = AppImages.Client
    Left = 672
    Top = 184
  end
  object popGraph: TPopupMenu
    Left = 704
    Top = 184
  end
  object popGST: TPopupMenu
    Left = 736
    Top = 184
  end
  object popUPI: TPopupMenu
    Left = 672
    Top = 216
    object mniUPIAddOutChq: TMenuItem
      Caption = 'Add Unpresented &Cheques'
      OnClick = AddOutChqClick
    end
    object mniUPIAddWith: TMenuItem
      Caption = 'Add Unpresented &Withdrawals'
      OnClick = mniUPIAddWithClick
    end
    object mniUPIAddOutDep: TMenuItem
      Caption = 'Add Unpresented &Deposits'
      OnClick = AddOutDepClick
    end
    object mniUPIMatchEntry: TMenuItem
      Caption = '&Match Unpresented Items'
      OnClick = MatchEntryClick
    end
    object mniUPISep1: TMenuItem
      Caption = '-'
    end
    object mniUPIAddInitChq: TMenuItem
      Caption = 'Add &Initial Cheques'
      OnClick = AddInitChqClick
    end
    object mniUPIAddInitWith: TMenuItem
      Caption = 'Add Initial Wi&thdrawals'
      OnClick = mniUPIAddInitWithClick
    end
    object mniUPIAddInitDep: TMenuItem
      Caption = 'Add Initial De&posits'
      OnClick = mniUPIAddInitDepClick
    end
    object N18: TMenuItem
      Caption = '-'
    end
    object mniRecombine: TMenuItem
      Caption = '&Recombine Entries'
      OnClick = mniRecombineClick
    end
  end
  object tmAutoSave: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = tmAutoSaveTimer
    Left = 44
    Top = 224
  end
  object actClients: TActionList
    Images = AppImages.Client
    Left = 504
    Top = 192
    object actClientManager: TAction
      Caption = '&Client Manager'
      Hint = 'Open Client Manager'
      ImageIndex = 16
      ShortCut = 8315
      OnExecute = actClientManagerExecute
    end
    object actTasks: TAction
      Caption = 'Ta&sks'
      Hint = 'Show Tasks List for this client'
      ImageIndex = 4
      OnExecute = actTasksExecute
    end
    object ActHomePage: TAction
      Caption = 'Home'
      Hint = 'Open Client Home Page'
      ImageIndex = 22
      ShortCut = 8314
      OnExecute = ActHomePageExecute
    end
    object actSendToFile: TAction
      Category = 'SendClientFiles'
      Caption = 'to &File'
      ImageIndex = 1
      OnExecute = actSendToFileExecute
    end
    object actSendViaEmail: TAction
      Category = 'SendClientFiles'
      Caption = 'via &Email'
      ImageIndex = 8
      OnExecute = actSendViaEmailExecute
    end
    object actSendViaOnline: TAction
      Category = 'SendClientFiles'
      Caption = 'via &BankLink Online'
      ImageIndex = 20
      OnExecute = actSendViaOnlineExecute
    end
    object actGetFromFolder: TAction
      Category = 'GetClientFiles'
      Caption = 'from &Folder'
      ImageIndex = 1
      OnExecute = actGetFromFolderExecute
    end
    object actGetFromOnline: TAction
      Category = 'GetClientFiles'
      Caption = 'from &BankLink Online'
      ImageIndex = 20
      OnExecute = actGetFromOnlineExecute
    end
  end
  object bk5win: TDdeServerConv
    OnExecuteMacro = bk5winExecuteMacro
    Left = 704
    Top = 336
  end
  object DdeStatus: TDdeServerItem
    ServerConv = bk5win
    OnPokeData = DdeStatusPokeData
    Left = 664
    Top = 336
  end
  object tmProcessStartupCmds: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmProcessStartupCmdsTimer
    Left = 152
    Top = 224
  end
  object tmrDataThread: TTimer
    Interval = 3000
    OnTimer = tmrDataThreadTimer
    Left = 224
    Top = 224
  end
  object tmrReportRun: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = tmrReportRunTimer
    Left = 40
    Top = 272
  end
  object PopGetClients: TPopupMenu
    Images = AppImages.Client
    Left = 640
    Top = 256
    object fromFolder1: TMenuItem
      Action = actGetFromFolder
    end
    object fromBankLinkOnline1: TMenuItem
      Action = actGetFromOnline
    end
  end
  object PopSendClients: TPopupMenu
    Images = AppImages.Client
    Left = 672
    Top = 256
    object toFile1: TMenuItem
      Action = actSendToFile
    end
    object viaEmail1: TMenuItem
      Action = actSendViaEmail
    end
    object viaBankLinkOnline1: TMenuItem
      Action = actSendViaOnline
    end
  end
end
