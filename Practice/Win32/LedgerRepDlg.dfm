object dlgLedgerRep: TdlgLedgerRep
  Scaled = False
Left = 357
  Top = 331
  BorderStyle = bsDialog
  Caption = 'Ledger Report'
  ClientHeight = 513
  ClientWidth = 600
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 600
    Height = 472
    ActivePage = tsOptions
    Align = alClient
    TabOrder = 0
    object tsOptions: TTabSheet
      Caption = '&Options'
      object GroupBox4: TGroupBox
        Left = 8
        Top = 249
        Width = 329
        Height = 136
        TabOrder = 3
        object Label9: TLabel
          Left = 19
          Top = 33
          Width = 34
          Height = 13
          Caption = 'Format'
        end
        object rbSummarised: TRadioButton
          Left = 201
          Top = 33
          Width = 113
          Height = 17
          Caption = '&Summarised'
          TabOrder = 1
          OnClick = rbDetailedClick
        end
        object rbDetailed: TRadioButton
          Left = 86
          Top = 33
          Width = 81
          Height = 17
          Caption = 'De&tailed'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbDetailedClick
        end
        object chkBalances: TCheckBox
          Left = 19
          Top = 64
          Width = 241
          Height = 17
          Hint = 'Check to include opening and closing balances on the report'
          Caption = 'Show Opening/Closing &Balances'
          TabOrder = 2
          OnClick = chkBalancesClick
        end
        object chkSuperfundDetails: TCheckBox
          Left = 19
          Top = 92
          Width = 241
          Height = 17
          Hint = 'Check to include superfund details on the report'
          Caption = 'Show Super&fund Details'
          TabOrder = 3
          OnClick = chkSuperfundDetailsClick
        end
      end
      object GroupBox5: TGroupBox
        Left = 8
        Top = 6
        Width = 329
        Height = 120
        TabOrder = 0
        object Label1: TLabel
          Left = 19
          Top = 35
          Width = 44
          Height = 13
          Caption = 'Accounts'
        end
        object rbAllCodes: TRadioButton
          Left = 86
          Top = 35
          Width = 73
          Height = 17
          Hint = 'Show all accounts on Report'
          Caption = '&All'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          TabStop = True
          OnClick = rbAllCodesClick
        end
        object rbSelectedCodes: TRadioButton
          Left = 201
          Top = 35
          Width = 89
          Height = 17
          Hint = 'Show selected accounts on Report'
          Caption = 'Sele&cted'
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnClick = rbSelectedCodesClick
        end
        object chkEmptyCodes: TCheckBox
          Left = 19
          Top = 72
          Width = 235
          Height = 17
          Hint = 'Check to include inactive codes on the Report'
          Caption = 'Include Accou&nts with no movement'
          TabOrder = 2
        end
      end
      object GroupBox6: TGroupBox
        Left = 8
        Top = 128
        Width = 329
        Height = 120
        TabOrder = 2
        inline DateSelector: TfmeDateSelector
          Left = 11
          Top = 26
          Width = 268
          Height = 62
          TabOrder = 0
          TabStop = True
          ExplicitLeft = 11
          ExplicitTop = 26
          ExplicitWidth = 268
          ExplicitHeight = 62
          inherited Label2: TLabel
            Left = 8
            Top = 11
            ExplicitLeft = 8
            ExplicitTop = 11
          end
          inherited btnPrev: TSpeedButton
            Top = 11
            ExplicitTop = 11
          end
          inherited btnNext: TSpeedButton
            Top = 11
            ExplicitTop = 11
          end
          inherited btnQuik: TSpeedButton
            Top = 11
            ExplicitTop = 11
          end
          inherited Label3: TLabel
            Left = 8
            Top = 37
            ExplicitLeft = 8
            ExplicitTop = 37
          end
          inherited eDateFrom: TOvcPictureField
            Left = 69
            Top = 11
            Epoch = 0
            ExplicitLeft = 69
            ExplicitTop = 11
            RangeHigh = {25600D00000000000000}
            RangeLow = {00000000000000000000}
          end
          inherited eDateTo: TOvcPictureField
            Left = 69
            Top = 37
            Epoch = 0
            ExplicitLeft = 69
            ExplicitTop = 37
            RangeHigh = {25600D00000000000000}
            RangeLow = {00000000000000000000}
          end
          inherited pmDates: TPopupMenu
            Top = 35
          end
          inherited OvcController1: TOvcController
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
            Top = 35
          end
        end
      end
      object pnlAllCodes: TGroupBox
        Left = 368
        Top = 6
        Width = 241
        Height = 363
        TabOrder = 4
        object Label3: TLabel
          Left = 40
          Top = 16
          Width = 121
          Height = 26
          Caption = 'All Account Codes will be reported on.'
          WordWrap = True
        end
      end
      object pnlSelectedCodes: TGroupBox
        Left = 344
        Top = 6
        Width = 245
        Height = 379
        TabOrder = 1
        Visible = False
        object Label6: TLabel
          Left = 12
          Top = 12
          Width = 24
          Height = 13
          Caption = 'From'
        end
        object Label7: TLabel
          Left = 114
          Top = 12
          Width = 12
          Height = 13
          Caption = 'To'
        end
        object btnChart: TSpeedButton
          Left = 175
          Top = 10
          Width = 65
          Height = 21
          Hint = 'Lookup an account code'
          Caption = 'Chart'
          Flat = True
          OnClick = btnChartClick
        end
        object tgRanges: TtsGrid
          Left = 8
          Top = 37
          Width = 231
          Height = 302
          Hint = 'Choose account ranges to show on report'
          AutoScale = True
          CheckBoxStyle = stCheck
          Cols = 2
          DefaultColWidth = 105
          DefaultRowHeight = 20
          ExportDelimiter = ','
          HeadingFont.Charset = DEFAULT_CHARSET
          HeadingFont.Color = clWindowText
          HeadingFont.Height = -15
          HeadingFont.Name = 'MS Sans Serif'
          HeadingFont.Style = []
          HeadingHeight = 20
          HeadingOn = False
          HeadingParentFont = False
          ParentShowHint = False
          RowBarIndicator = False
          RowBarOn = False
          Rows = 20
          ScrollBars = ssVertical
          ShowHint = True
          StoreData = True
          TabOrder = 0
          Version = '2.20.26'
          WantTabs = False
          XMLExport.Version = '1.0'
          XMLExport.DataPacketVersion = '2.0'
          OnCellLoaded = tgRangesCellLoaded
          OnEndCellEdit = tgRangesEndCellEdit
          OnKeyDown = tgRangesKeyDown
          OnKeyUp = tgRangesKeyUp
          OnResize = tgRangesResize
          ColProperties = <
            item
              DataCol = 1
              Col.ControlType = ctText
              Col.MaxLength = 10
              Col.Width = 105
            end
            item
              DataCol = 2
              Col.ControlType = ctText
              Col.MaxLength = 10
              Col.Width = 104
            end>
          Data = {0100000002000000010000000001000000000000000000000000}
        end
        object btnSaveTemplate: TButton
          Left = 8
          Top = 345
          Width = 110
          Height = 25
          Caption = 'Save Te&mplate'
          TabOrder = 1
          OnClick = btnSaveTemplateClick
        end
        object btnLoad: TButton
          Left = 124
          Top = 345
          Width = 110
          Height = 25
          Caption = '&Load Template'
          TabOrder = 2
          OnClick = btnLoadClick
        end
      end
    end
    object tsAdvanced: TTabSheet
      Caption = 'A&dvanced'
      ImageIndex = 1
      object GroupBox1: TGroupBox
        Left = 8
        Top = 207
        Width = 583
        Height = 178
        Caption = 'Layout'
        TabOrder = 1
        object Label5: TLabel
          Left = 16
          Top = 24
          Width = 30
          Height = 13
          Caption = 'Show:'
        end
        object rbGSTContraAll: TRadioButton
          Left = 323
          Top = 135
          Width = 121
          Height = 17
          Hint = 'Show all GST control account entries in the Report'
          Caption = 'All Entr&ies'
          TabOrder = 7
        end
        object rbGSTContraTotal: TRadioButton
          Left = 242
          Top = 136
          Width = 58
          Height = 17
          Hint = 'Show GST control account totals in the Report'
          Caption = 'Total&s'
          Checked = True
          TabOrder = 6
          TabStop = True
        end
        object chkQuantity: TCheckBox
          Left = 63
          Top = 45
          Width = 128
          Height = 17
          Hint = 'Check to show quantities in the Report'
          Caption = '&Quantities'
          TabOrder = 1
          OnClick = chkQuantityClick
        end
        object chkNotes: TCheckBox
          Left = 63
          Top = 67
          Width = 129
          Height = 17
          Hint = 'Check to show notes in the Report'
          Caption = '&Notes'
          TabOrder = 2
          OnClick = chkNotesClick
        end
        object chkGross: TCheckBox
          Left = 63
          Top = 24
          Width = 185
          Height = 17
          Hint = 'Check to show Gross Amount and GST Amount in the Report'
          Caption = '&Gross and GST Amounts'
          TabOrder = 0
          OnClick = chkGrossClick
        end
        object Panel1: TPanel
          Left = 63
          Top = 109
          Width = 366
          Height = 21
          BevelOuter = bvNone
          TabOrder = 4
          object rbBankContraTotal: TRadioButton
            Left = 179
            Top = 3
            Width = 58
            Height = 17
            Hint = 'Show bank contra totals in the Report'
            Caption = '&Totals'
            Checked = True
            TabOrder = 1
            TabStop = True
          end
          object rbBankContraAll: TRadioButton
            Left = 260
            Top = 3
            Width = 102
            Height = 17
            Hint = 'Show all bank contra entries in the Report'
            Caption = 'A&ll Entries'
            TabOrder = 2
          end
          object cbBankContra: TCheckBox
            Left = 0
            Top = 3
            Width = 153
            Height = 17
            Caption = '&Bank Contra(s)'
            TabOrder = 0
            OnClick = cbBankContraClick
          end
        end
        object cbGSTContra: TCheckBox
          Left = 63
          Top = 135
          Width = 159
          Height = 17
          Caption = 'GST Control Acco&unt(s)'
          TabOrder = 5
          OnClick = cbGSTContraClick
        end
        object chkWrap: TCheckBox
          Left = 63
          Top = 89
          Width = 186
          Height = 17
          Hint = 'Check to show wrapped narrations in the Report'
          Caption = 'W&rap Narration and Notes'
          TabOrder = 3
          OnClick = chkWrapClick
        end
      end
      object GroupBox3: TGroupBox
        Left = 8
        Top = 6
        Width = 582
        Height = 202
        Caption = 'Select Bank Accounts'
        TabOrder = 0
        inline fmeAccountSelector1: TfmeAccountSelector
          Left = 48
          Top = 16
          Width = 481
          Height = 177
          TabOrder = 0
          TabStop = True
          ExplicitLeft = 48
          ExplicitTop = 16
          ExplicitWidth = 481
          ExplicitHeight = 177
          inherited lblSelectAccounts: TLabel
            Left = 12
            ExplicitLeft = 12
          end
          inherited chkAccounts: TCheckListBox
            Left = 12
            Height = 93
            Hint = 'Enable bank accounts to include in the Report'
            ParentShowHint = False
            ShowHint = True
            ExplicitLeft = 12
            ExplicitHeight = 93
          end
          inherited btnSelectAllAccounts: TButton
            Left = 393
            Hint = 'Enable all bank accounts'
            ParentShowHint = False
            ShowHint = True
            ExplicitLeft = 393
          end
          inherited btnClearAllAccounts: TButton
            Left = 393
            Hint = 'Disable all bank accounts'
            ExplicitLeft = 393
          end
        end
        object chkIncludeNonTransferring: TCheckBox
          Left = 64
          Top = 171
          Width = 310
          Height = 17
          Hint = 'Check to include non-transferring journal entires on the Report'
          Caption = 'Include Non-Transferring &Journals'
          TabOrder = 1
        end
      end
    end
    object tbsSuperDetails: TTabSheet
      Caption = 'S&uper Details'
      ImageIndex = 2
      object Label2: TLabel
        Left = 17
        Top = 59
        Width = 345
        Height = 13
        Caption = 
          '(Note: The default title will be used if the user defined title ' +
          'is left blank.)'
      end
      inline fmeCustomColumn1: TfmeCustomColumn
        Left = 3
        Top = 91
        Width = 460
        Height = 350
        TabOrder = 1
        ExplicitLeft = 3
        ExplicitTop = 91
        inherited gbTemplates: TGroupBox
          inherited btnSaveTemplate: TBitBtn
            OnClick = fmeCustomColumn1btnSaveTemplateClick
          end
        end
      end
      object pTitle: TPanel
        Left = 17
        Top = 8
        Width = 563
        Height = 45
        BevelOuter = bvNone
        TabOrder = 0
        object Pleft: TPanel
          Left = 0
          Top = 0
          Width = 233
          Height = 45
          Align = alLeft
          BevelOuter = bvNone
          TabOrder = 0
          object PRtitle: TPanel
            Left = 0
            Top = 0
            Width = 233
            Height = 20
            Align = alTop
            Alignment = taLeftJustify
            BevelOuter = bvLowered
            Caption = 'Default Report Title'
            Padding.Left = 4
            TabOrder = 0
          end
          object Panel3: TPanel
            Left = 0
            Top = 20
            Width = 233
            Height = 25
            Align = alClient
            Alignment = taLeftJustify
            BevelOuter = bvLowered
            Caption = 'LEDGER REPORT WITH SUPER DETAILS'
            Color = clWindow
            Padding.Left = 4
            ParentBackground = False
            TabOrder = 1
          end
        end
        object pRight: TPanel
          Left = 233
          Top = 0
          Width = 330
          Height = 45
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object pUTitle: TPanel
            Left = 0
            Top = 0
            Width = 330
            Height = 20
            Align = alTop
            Alignment = taLeftJustify
            BevelOuter = bvLowered
            Caption = 'User Defined Report Title'
            Padding.Left = 4
            TabOrder = 0
          end
          object ETitle: TEdit
            Left = 0
            Top = 20
            Width = 330
            Height = 25
            Align = alClient
            BevelInner = bvNone
            BevelOuter = bvNone
            MaxLength = 200
            TabOrder = 1
            ExplicitHeight = 21
          end
        end
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 472
    Width = 600
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      600
      41)
    object btnPreview: TButton
      Left = 5
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Previe&w'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 93
      Top = 8
      Width = 75
      Height = 25
      Hint = 'Send the Report to a file'
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnOK: TButton
      Left = 422
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Print'
      TabOrder = 3
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 509
      Top = 8
      Width = 75
      Height = 25
      Hint = 'Cancel the Report'
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      OnClick = btnCancelClick
    end
    object btnSave: TBitBtn
      Left = 335
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Sa&ve'
      TabOrder = 2
      OnClick = BtnSaveClick
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.lrt'
    Filter = 'Ledger Report Template (*.lrt)|*.lrt'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Load Ledger Report Template'
    Left = 248
    Top = 400
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.lrt'
    Filter = 'Ledger Report Template (*.lrt)|*.lrt'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Ledger Report Template'
    Left = 288
    Top = 400
  end
end
