object frmClientManager: TfrmClientManager
  Left = 0
  Top = 157
  Caption = 'Client Manager'
  ClientHeight = 554
  ClientWidth = 1205
  Color = clBtnFace
  Constraints.MinHeight = 163
  Constraints.MinWidth = 406
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = True
  Position = poMainFormCenter
  Scaled = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbClientManager: TRzGroupBar
    Left = 0
    Top = 33
    Width = 200
    Height = 487
    BorderSides = []
    BorderColor = 15510150
    BorderShadow = 15510150
    GradientColorStyle = gcsCustom
    GradientColorStart = clBtnFace
    GradientColorStop = 7829248
    GroupBorderSize = 8
    SmallImages = AppImages.ilFileActions_ClientMgr
    Color = clBtnShadow
    ParentColor = False
    TabOrder = 2
    object rzgFileTasks: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
          Action = actDataAvailable
          Visible = False
        end
        item
          Action = actDownload
        end
        item
          Action = actNewAccounts
        end
        item
          Action = actUnAttached
        end
        item
          Action = actInActive
        end
        item
          Action = actAccountStatus
        end
        item
          Caption = '-'
        end
        item
          Action = actNewFile
        end
        item
          Action = actOpen
        end
        item
          Caption = '-'
        end
        item
          Action = actScheduled
        end
        item
          Action = actAssignTo
        end
        item
          Action = actGroup
        end
        item
          Action = actClientType
        end
        item
          Caption = '-'
        end
        item
          Action = actPrint
        end
        item
          Caption = '-'
        end
        item
          Action = actHelp
        end>
      Opened = True
      OpenedHeight = 416
      Caption = 'Client Files'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object rzgProspects: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
          Action = actNewProspect
        end
        item
          Action = actImportProspects
        end
        item
          Action = actConvertToBK
        end
        item
          Action = actDeleteProspect
        end
        item
          Action = actAssignTo
        end>
      Opened = True
      OpenedHeight = 128
      Caption = 'Prospect Files'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object RzGroupGlobal: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
          Action = actNewFile
        end
        item
          Action = actUnlockFile
        end
        item
          Action = actDeleteFile
        end
        item
          Action = actMigrate
          Caption = 'Migrate to MYOB Essentials Cashbook'
        end
        item
          Caption = '-'
        end
        item
          Action = actAssignTo
        end
        item
          Action = actGroup
        end
        item
          Action = actClientType
        end
        item
          Caption = '-'
        end
        item
          Action = actScheduled
        end
        item
          Action = actBOSettings
        end
        item
          Action = actCodingScreenLayout
        end
        item
          Action = actPracticeContact
        end
        item
          Action = actFinancialYear
        end
        item
          Action = actAssignBulkExport
        end
        item
          Action = actArchive
        end
        item
          Action = actImportClients
        end
        item
          Caption = '-'
        end
        item
          Action = actTrackTasks
        end
        item
          Caption = '-'
        end
        item
          Action = actHelp
        end>
      Opened = True
      OpenedHeight = 544
      Caption = 'Client Maintenance'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object rzgDetails: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <>
      Opened = True
      OpenedHeight = 40
      Caption = 'Client Details'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object rzgCommunicate: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
          Action = actCreateDoc
        end
        item
          Action = actMergeDoc
        end
        item
          Action = actMergeEmail
        end
        item
          Caption = '-'
        end
        item
          Action = actCAF
        end
        item
          Action = actICAF
        end
        item
          Action = actTPA
        end
        item
          Action = ActShowInstitutions
        end>
      Opened = True
      OpenedHeight = 252
      Caption = 'Contact Clients'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object rzgOptions: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
          Action = actShowLegend
        end
        item
          Action = actUpdateProcessing
        end>
      Opened = True
      OpenedHeight = 84
      Caption = 'Options'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
  end
  object pnlMain: TPanel
    Left = 200
    Top = 33
    Width = 1005
    Height = 487
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 2
    Color = clWindow
    TabOrder = 0
    object Shape5: TShape
      Left = 1002
      Top = 24
      Width = 1
      Height = 461
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 1003
    end
    object Shape6: TShape
      Left = 2
      Top = 24
      Width = 1
      Height = 461
      Align = alLeft
      Pen.Color = clSilver
    end
    object pnlFrameHolder: TPanel
      Left = 3
      Top = 24
      Width = 999
      Height = 461
      Align = alClient
      BevelOuter = bvNone
      Color = clWindow
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 0
      object Shape3: TShape
        Left = 0
        Top = 460
        Width = 999
        Height = 1
        Align = alBottom
        Pen.Color = clSilver
        ExplicitTop = 459
        ExplicitWidth = 1001
      end
      object Shape1: TShape
        Left = 0
        Top = 27
        Width = 999
        Height = 1
        Align = alTop
        Pen.Color = clSilver
        ExplicitLeft = 504
        ExplicitTop = 6
        ExplicitWidth = 400
      end
      object pnlLegend: TPanel
        Left = 0
        Top = 0
        Width = 999
        Height = 27
        Align = alTop
        BevelEdges = []
        BevelOuter = bvNone
        TabOrder = 0
        object pnlLegendA: TPanel
          Left = 0
          Top = 0
          Width = 999
          Height = 27
          Align = alClient
          BevelEdges = []
          BevelOuter = bvNone
          TabOrder = 0
          object Label6: TLabel
            AlignWithMargins = True
            Left = 23
            Top = 1
            Width = 39
            Height = 13
            Margins.Top = 0
            Margins.Bottom = 0
            Align = alLeft
            Caption = 'Legend:'
            Layout = tlCenter
          end
          object tbtnClose: TRzToolButton
            Left = 0
            Top = 1
            Width = 20
            Height = 26
            GradientColorStyle = gcsCustom
            ImageIndex = 0
            Images = AppImages.ToolBtn
            UseToolbarButtonSize = False
            UseToolbarVisualStyle = False
            VisualStyle = vsGradient
            Align = alLeft
            Caption = 'Show Legend'
            OnClick = actShowLegendExecute
            ExplicitLeft = 2
            ExplicitTop = 2
            ExplicitHeight = 19
          end
          object Shape4: TShape
            Left = 0
            Top = 0
            Width = 999
            Height = 1
            Align = alTop
            Pen.Color = clSilver
            ExplicitWidth = 1001
          end
          object sgLegend: TStringGrid
            AlignWithMargins = True
            Left = 68
            Top = 1
            Width = 501
            Height = 26
            Margins.Top = 0
            Margins.Bottom = 0
            Align = alLeft
            BevelInner = bvNone
            BevelOuter = bvNone
            BorderStyle = bsNone
            Color = clBtnFace
            ColCount = 12
            DefaultColWidth = 75
            Enabled = False
            FixedCols = 0
            RowCount = 1
            FixedRows = 0
            Options = []
            ScrollBars = ssNone
            TabOrder = 0
            OnDrawCell = sgLegendDrawCell
            OnSelectCell = sgLegendSelectCell
          end
        end
      end
      inline ClientLookup: TfmeClientLookup
        Left = 0
        Top = 28
        Width = 999
        Height = 432
        Align = alClient
        TabOrder = 1
        TabStop = True
        ExplicitTop = 28
        ExplicitWidth = 999
        ExplicitHeight = 432
        inherited vtClients: TVirtualStringTree
          Width = 999
          Height = 432
          BevelOuter = bvNone
          BorderStyle = bsNone
          ExplicitWidth = 999
          ExplicitHeight = 432
        end
      end
    end
    object pnlFilter: TPanel
      Left = 2
      Top = 2
      Width = 1001
      Height = 22
      Align = alTop
      BevelEdges = []
      BevelOuter = bvNone
      TabOrder = 1
      object pnlFilterA: TPanel
        Left = 0
        Top = 0
        Width = 1001
        Height = 22
        Align = alClient
        BevelEdges = []
        BevelOuter = bvNone
        TabOrder = 0
        object lblCount: TLabel
          AlignWithMargins = True
          Left = 631
          Top = 1
          Width = 96
          Height = 13
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alLeft
          Caption = '99999 Clients Listed'
          Layout = tlCenter
          Visible = False
        end
        object Label1: TLabel
          AlignWithMargins = True
          Left = 344
          Top = 1
          Width = 33
          Height = 13
          Margins.Left = 9
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alLeft
          Caption = 'Search'
          Layout = tlCenter
        end
        object imgCannotConnect: TImage
          AlignWithMargins = True
          Left = 733
          Top = 5
          Width = 16
          Height = 17
          Hint = 
            'BankLink Practice will not display any BankLink Online related s' +
            'ettings or functions'
          Margins.Top = 4
          Margins.Bottom = 0
          Align = alLeft
          ParentShowHint = False
          ShowHint = True
          Transparent = True
          Visible = False
          ExplicitLeft = 734
          ExplicitTop = 4
          ExplicitHeight = 18
        end
        object lblCannotConnect: TLabel
          AlignWithMargins = True
          Left = 755
          Top = 1
          Width = 163
          Height = 13
          Hint = 
            'BankLink Practice will not display any BankLink Online related s' +
            'ettings or functions'
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alLeft
          Caption = 'Cannot connect to Banklink Online'
          ParentShowHint = False
          ShowHint = True
          Layout = tlCenter
          Visible = False
        end
        object Shape2: TShape
          Left = 0
          Top = 0
          Width = 1001
          Height = 1
          Align = alTop
          Pen.Color = clSilver
          ExplicitLeft = 562
          ExplicitTop = 2
          ExplicitWidth = 400
        end
        object Shape7: TShape
          Left = 1000
          Top = 1
          Width = 1
          Height = 21
          Align = alRight
          Pen.Color = clSilver
          ExplicitLeft = 999
        end
        object Shape8: TShape
          Left = 0
          Top = 1
          Width = 1
          Height = 21
          Align = alLeft
          Pen.Color = clSilver
        end
        object cmbFilter: TComboBox
          AlignWithMargins = True
          Left = 4
          Top = 1
          Width = 116
          Height = 21
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alLeft
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
          OnChange = cmbFilterChange
        end
        object btnFilter: TButton
          AlignWithMargins = True
          Left = 126
          Top = 1
          Width = 100
          Height = 21
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alLeft
          Caption = 'Filter Clients'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnClick = btnFilterClick
        end
        object btnResetFilter: TButton
          AlignWithMargins = True
          Left = 232
          Top = 1
          Width = 100
          Height = 21
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alLeft
          Caption = 'Reset Filter'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 2
          OnClick = mniResetFilterClick
        end
        object EBFind: TEdit
          AlignWithMargins = True
          Left = 383
          Top = 1
          Width = 161
          Height = 21
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alLeft
          MaxLength = 12
          TabOrder = 3
          OnChange = EBFindChange
          OnKeyPress = EBFindKeyPress
        end
        object btnFind: TButton
          AlignWithMargins = True
          Left = 550
          Top = 1
          Width = 75
          Height = 21
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alLeft
          Caption = 'Clear'
          TabOrder = 4
          OnClick = btnFindClick
        end
      end
    end
  end
  object PnlLogo: TRzPanel
    Left = 0
    Top = 0
    Width = 1205
    Height = 33
    Align = alTop
    BorderOuter = fsNone
    BorderSides = []
    GradientColorStyle = gcsCustom
    GradientColorStop = 11183616
    TabOrder = 3
    VisualStyle = vsGradient
    object imgLogo: TImage
      AlignWithMargins = True
      Left = 9
      Top = 9
      Width = 125
      Height = 16
      Margins.Left = 8
      Margins.Top = 8
      Margins.Bottom = 8
      Align = alLeft
      AutoSize = True
      Center = True
      Proportional = True
      Transparent = True
      ExplicitLeft = 8
      ExplicitTop = 0
      ExplicitHeight = 40
    end
    object imgRight: TImage
      Left = 1079
      Top = 1
      Width = 125
      Height = 32
      Align = alRight
      AutoSize = True
      Transparent = True
      ExplicitLeft = 1080
      ExplicitTop = 0
      ExplicitHeight = 40
    end
    object Shape9: TShape
      Left = 0
      Top = 1
      Width = 1
      Height = 32
      Align = alLeft
      Pen.Color = clSilver
      ExplicitLeft = 1
      ExplicitTop = -6
      ExplicitHeight = 33
    end
    object Shape10: TShape
      Left = 0
      Top = 0
      Width = 1205
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 1001
    end
    object Shape11: TShape
      Left = 1204
      Top = 1
      Width = 1
      Height = 32
      Align = alRight
      Pen.Color = clSilver
      ExplicitLeft = 1003
      ExplicitTop = 24
      ExplicitHeight = 461
    end
  end
  object pnlClose: TPanel
    Left = 0
    Top = 520
    Width = 1205
    Height = 34
    Align = alBottom
    TabOrder = 1
    OnResize = pnlCloseResize
    DesignSize = (
      1205
      34)
    object btnClose: TButton
      Left = 1119
      Top = 4
      Width = 77
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Close'
      TabOrder = 0
      OnClick = btnCancelClick
    end
  end
  object ActionList1: TActionList
    Images = AppImages.ilFileActions_ClientMgr
    Left = 368
    Top = 120
    object actNewFile: TAction
      Category = 'FileTasks'
      Caption = 'New'
      ImageIndex = 12
      OnExecute = actNewFileExecute
    end
    object actOpen: TAction
      Category = 'FileTasks'
      Caption = 'Open'
      ImageIndex = 11
      OnExecute = actOpenExecute
    end
    object actCheckIn: TAction
      Category = 'FileTasks'
      Caption = 'Update file(s)'
      ImageIndex = 19
      OnExecute = actCheckInExecute
    end
    object Action1: TAction
      Category = 'GlobalSetup'
      Caption = 'Archive'
      ImageIndex = 29
      OnExecute = actArchiveExecute
    end
    object actCheckOut: TAction
      Category = 'FileTasks'
      Caption = 'Send file(s)'
      ImageIndex = 20
      OnExecute = actCheckOutExecute
    end
    object actSend: TAction
      Category = 'FileTasks'
      Caption = 'Send file(s)'
      ImageIndex = 8
      OnExecute = actSendExecute
    end
    object actScheduled: TAction
      Category = 'FileTasks'
      Caption = 'Set up a Report Schedule'
      ImageIndex = 6
      OnExecute = actScheduledExecute
    end
    object actAssignTo: TAction
      Category = 'FileTasks'
      Caption = 'Assign User'
      ImageIndex = 0
      OnExecute = actAssignToExecute
    end
    object actTasks: TAction
      Category = 'FileTasks'
      Caption = 'Task List and Comments'
      ImageIndex = 13
      OnExecute = actTasksExecute
    end
    object actTrackTasks: TAction
      Category = 'Option Tasks'
      Caption = 'Task Settings'
      ImageIndex = 13
      OnExecute = actTrackTasksExecute
    end
    object actClientEmail: TAction
      Category = 'Details'
      Caption = 'Mail'
      ImageIndex = 8
      OnExecute = actClientEmailExecute
    end
    object actEditClientDetails: TAction
      Category = 'Details'
      Caption = 'Edit Contact Details'
      ImageIndex = 10
      OnExecute = actEditClientDetailsExecute
    end
    object actUnlockFile: TAction
      Category = 'Manage'
      Caption = 'Reset Client Status'
      ImageIndex = 5
      OnExecute = actUnlockFileExecute
    end
    object actCodingScreenLayout: TAction
      Category = 'GlobalSetup'
      Caption = 'Apply Code Entries Screen Layout'
      ImageIndex = 10
      OnExecute = actCodingScreenLayoutExecute
    end
    object actPracticeContact: TAction
      Category = 'GlobalSetup'
      Caption = 'Assign Practice Contact'
      ImageIndex = 7
      OnExecute = actPracticeContactExecute
    end
    object actFinancialYear: TAction
      Category = 'GlobalSetup'
      Caption = 'Change Financial Year'
      ImageIndex = 9
      OnExecute = actFinancialYearExecute
    end
    object actDeleteFile: TAction
      Category = 'Manage'
      Caption = 'Delete a Client'
      ImageIndex = 26
      OnExecute = actDeleteFileExecute
    end
    object actHelp: TAction
      Category = 'Option Tasks'
      Caption = 'Help'
      ImageIndex = 3
      OnExecute = actHelpExecute
    end
    object actMergeDoc: TAction
      Category = 'Prospects'
      Caption = 'Print Document'
      ImageIndex = 14
      OnExecute = actMergeDocExecute
    end
    object actMergeEmail: TAction
      Category = 'Prospects'
      Caption = 'Email Document'
      ImageIndex = 8
      OnExecute = actMergeEmailExecute
    end
    object actNewProspect: TAction
      Category = 'Prospects'
      Caption = 'New'
      ImageIndex = 12
      OnExecute = actNewProspectExecute
    end
    object actImportProspects: TAction
      Category = 'Prospects'
      Caption = 'Import New'
      ImageIndex = 27
      OnExecute = actImportProspectsExecute
    end
    object actConvertToBK: TAction
      Category = 'Prospects'
      Caption = 'Convert to Client File'
      ImageIndex = 28
      OnExecute = actConvertToBKExecute
    end
    object actDeleteProspect: TAction
      Category = 'Prospects'
      Caption = 'Delete'
      ImageIndex = 26
      OnExecute = actDeleteProspectExecute
    end
    object actCreateDoc: TAction
      Category = 'Prospects'
      Caption = 'Create Document'
      ImageIndex = 12
      OnExecute = actCreateDocExecute
    end
    object actCAF: TAction
      Category = 'Option Tasks'
      Caption = 'Open Client Authority Form'
      ImageIndex = 17
      OnExecute = actCAFExecute
    end
    object actICAF: TAction
      Category = 'Option Tasks'
      Caption = 'Import Customer Authority Forms'
      ImageIndex = 17
      OnExecute = actICAFExecute
    end
    object actTPA: TAction
      Category = 'Option Tasks'
      Caption = 'Open Third Party Authority Form'
      ImageIndex = 17
      OnExecute = actTPAExecute
    end
    object actPrint: TAction
      Category = 'FileTasks'
      Caption = 'Print'
      ImageIndex = 14
      OnExecute = actPrintExecute
    end
    object actShowLegend: TAction
      Category = 'Option Tasks'
      Caption = 'Show Legend'
      ImageIndex = 21
      OnExecute = actShowLegendExecute
    end
    object actUpdateProcessing: TAction
      Category = 'Option Tasks'
      Caption = 'Update Processing Statistics'
      OnExecute = actUpdateProcessingExecute
    end
    object actArchive: TAction
      Category = 'GlobalSetup'
      Caption = 'Archive'
      ImageIndex = 29
      OnExecute = actArchiveExecute
    end
    object actDataAvailable: TAction
      Category = 'Accounts'
      Caption = 'There is new BankLink data to download...'
      ImageIndex = 23
      Visible = False
      OnExecute = actDataAvailableExecute
    end
    object actDownload: TAction
      Category = 'FileTasks'
      Caption = 'Download New Data'
      ImageIndex = 32
      OnExecute = actDownloadExecute
    end
    object actGroup: TAction
      Category = 'FileTasks'
      Caption = 'Assign Group'
      ImageIndex = 34
      OnExecute = actGroupExecute
    end
    object actClientType: TAction
      Category = 'FileTasks'
      Caption = 'Assign Client Type'
      ImageIndex = 33
      OnExecute = actClientTypeExecute
    end
    object ActShowInstitutions: TAction
      Category = 'Option Tasks'
      Caption = 'Show Available Institutions'
      ImageIndex = 17
      OnExecute = ActShowInstitutionsExecute
    end
    object actNewAccounts: TAction
      Category = 'Accounts'
      Caption = 'New Accounts Exist'
      ImageIndex = 23
      OnExecute = actNewAccountsExecute
    end
    object actImportClients: TAction
      Category = 'GlobalSetup'
      Caption = 'Import Contact Details'
      ImageIndex = 27
      OnExecute = actImportClientsExecute
    end
    object actMultiTasks: TAction
      Category = 'FileTasks'
      Caption = 'Add Task for Multiple Clients'
      ImageIndex = 13
      OnExecute = actMultiTasksExecute
    end
    object actPrintTasks: TAction
      Category = 'FileTasks'
      Caption = 'Print Open Tasks'
      ImageIndex = 14
      OnExecute = actPrintTasksExecute
    end
    object actAssignBulkExport: TAction
      Category = 'FileTasks'
      Caption = 'Assign Bulk Export Format '
      ImageIndex = 1
      OnExecute = actAssignBulkExportExecute
    end
    object actUnAttached: TAction
      Category = 'Accounts'
      Caption = 'There are unattached accounts'
      ImageIndex = 23
      OnExecute = actNewAccountsExecute
    end
    object actInActive: TAction
      Category = 'Accounts'
      Caption = 'There are inactive accounts'
      ImageIndex = 23
      OnExecute = actInActiveExecute
    end
    object actSendOnline: TAction
      Caption = 'Send via Online'
      ImageIndex = 20
      OnExecute = actSendOnlineExecute
    end
    object actBOSettings: TAction
      Category = 'FileTasks'
      Caption = 'Edit BankLink Online Settings'
      ImageIndex = 17
      OnExecute = actBOSettingsExecute
    end
    object actAccountStatus: TAction
      Category = 'Accounts'
      Caption = 'Account Status'
      ImageIndex = 39
      OnExecute = actAccountStatusExecute
    end
    object actMigrate: TAction
      Category = 'Manage'
      Caption = 'actMigrate'
      ImageIndex = 24
      OnExecute = actMigrateExecute
    end
  end
  object tmrUpdateClientDetails: TTimer
    Interval = 300
    OnTimer = tmrUpdateClientDetailsTimer
    Left = 408
    Top = 120
  end
  object popClientManager: TPopupMenu
    Images = AppImages.ilFileActions_ClientMgr
    Left = 232
    Top = 120
    object mniOpen: TMenuItem
      Action = actOpen
    end
    object mniScheduled: TMenuItem
      Action = actScheduled
    end
    object mniAssignTo: TMenuItem
      Action = actAssignTo
    end
    object AssignGroup1: TMenuItem
      Action = actGroup
    end
    object AssignClientType1: TMenuItem
      Action = actClientType
    end
    object mniEdit: TMenuItem
      Action = actEditClientDetails
    end
    object mniTasks: TMenuItem
      Action = actTasks
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object mniFilter: TMenuItem
      Caption = 'Filter Clients'
      OnClick = mniFilterClick
    end
    object mniResetFilter: TMenuItem
      Caption = 'Reset Filter'
      OnClick = mniResetFilterClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object mniRestoreColumns: TMenuItem
      Caption = 'Restore default column layout'
      OnClick = mniRestoreColumnsClick
    end
  end
  object popHeader: TPopupMenu
    Left = 264
    Top = 112
    object N2: TMenuItem
      Caption = '-'
    end
    object mniRestoreHeader: TMenuItem
      Caption = '&Restore default column layout'
      OnClick = mniRestoreColumnsClick
    end
  end
  object popProspects: TPopupMenu
    Images = AppImages.ilFileActions_ClientMgr
    Left = 304
    Top = 120
    object mniConvert: TMenuItem
      Action = actConvertToBK
    end
    object mniProspectAssignTo: TMenuItem
      Action = actAssignTo
    end
    object mniProspectEdit: TMenuItem
      Action = actEditClientDetails
    end
    object mniProspectTask: TMenuItem
      Action = actTasks
    end
    object mniProspectRestoreCols: TMenuItem
      Caption = '&Restore default column layout'
      OnClick = mniRestoreColumnsClick
    end
  end
  object popGlobal: TPopupMenu
    Images = AppImages.ilFileActions_ClientMgr
    Left = 328
    Top = 114
    object mniGlobalAssign: TMenuItem
      Action = actAssignTo
    end
    object AssignGroup2: TMenuItem
      Action = actGroup
    end
    object AssignClientType2: TMenuItem
      Action = actClientType
    end
    object mniGlobalScheduled: TMenuItem
      Action = actScheduled
    end
    object mniEditBOSettings: TMenuItem
      Action = actBOSettings
    end
    object ApplyCodingScreenLayout1: TMenuItem
      Action = actCodingScreenLayout
    end
    object AssignPracticeContact1: TMenuItem
      Action = actPracticeContact
    end
    object ChangeFinancialYear1: TMenuItem
      Action = actFinancialYear
    end
    object Assignbulkexportformat1: TMenuItem
      Action = actAssignBulkExport
    end
    object Archive1: TMenuItem
      Action = actArchive
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mniGlobalEdit: TMenuItem
      Action = actEditClientDetails
    end
  end
  object owMerge: TOpWord
    Version = '1.64'
    Documents = <>
    Visible = False
    ScreenUpdating = False
    PrintPreview = False
    DisplayRecentFiles = False
    DisplayScrollBars = False
    ServerLeft = 0
    ServerTop = 0
    ServerWidth = 640
    ServerHeight = 480
    WindowState = wdwsNormal
    DisplayAlerts = wdalNone
    DisplayScreenTips = False
    EnableCancelKey = wdeckDisabled
    Left = 443
    Top = 121
  end
  object SearchTimer: TTimer
    Enabled = False
    OnTimer = SearchTimerTimer
    Left = 568
    Top = 240
  end
end
