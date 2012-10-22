object frmTaxablePaymentsRptDlg: TfrmTaxablePaymentsRptDlg
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Taxable Payments Report'
  ClientHeight = 294
  ClientWidth = 592
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  DesignSize = (
    592
    294)
  PixelsPerInch = 96
  TextHeight = 13
  object pnlAllCodes: TPanel
    Left = 351
    Top = 8
    Width = 241
    Height = 249
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    object Label3: TLabel
      Left = 32
      Top = 24
      Width = 139
      Height = 26
      Caption = 'All Contractor Payees will be reported on.'
      WordWrap = True
    end
  end
  object btnOK: TButton
    Left = 431
    Top = 263
    Width = 75
    Height = 25
    Hint = 'Print the Report'
    Anchors = [akRight, akBottom]
    Caption = '&Print'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 512
    Top = 263
    Width = 75
    Height = 25
    Hint = 'Cancel the report'
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
    OnClick = btnCancelClick
  end
  object btnPreview: TButton
    Left = 8
    Top = 263
    Width = 75
    Height = 25
    Hint = 'Preview the Report'
    Anchors = [akLeft, akBottom]
    Caption = 'Previe&w'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = btnPreviewClick
  end
  object btnFile: TButton
    Left = 88
    Top = 263
    Width = 75
    Height = 25
    Hint = 'Send the Report to a file'
    Anchors = [akLeft, akBottom]
    Caption = 'Fil&e'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    OnClick = btnFileClick
  end
  object pnlAccounts: TPanel
    Left = 8
    Top = 8
    Width = 329
    Height = 49
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 28
      Top = 16
      Width = 35
      Height = 13
      Caption = 'Payees'
    end
    object rbAllCodes: TRadioButton
      Left = 106
      Top = 16
      Width = 73
      Height = 17
      Hint = 'Show all contractor payees on Report'
      Caption = '&All'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      TabStop = True
      OnClick = rbAllCodesClick
    end
    object rbSelectedCodes: TRadioButton
      Left = 202
      Top = 16
      Width = 89
      Height = 17
      Hint = 'Show selected contractor payees on Report'
      Caption = 'Sele&cted'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = rbSelectedCodesClick
    end
  end
  object pnlDates: TPanel
    Left = 9
    Top = 65
    Width = 328
    Height = 84
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 3
    inline DateSelector: TfmeDateSelector
      Left = 19
      Top = 14
      Width = 276
      Height = 62
      TabOrder = 0
      TabStop = True
      ExplicitLeft = 19
      ExplicitTop = 14
      ExplicitHeight = 62
      inherited Label2: TLabel
        Left = 8
        ExplicitLeft = 8
      end
      inherited Label3: TLabel
        Left = 8
        ExplicitLeft = 8
      end
      inherited eDateFrom: TOvcPictureField
        Epoch = 0
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      inherited eDateTo: TOvcPictureField
        Epoch = 0
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
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
      end
    end
  end
  object pnlOptions: TPanel
    Left = 8
    Top = 157
    Width = 329
    Height = 100
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 4
    object Label9: TLabel
      Left = 28
      Top = 11
      Width = 34
      Height = 13
      Caption = 'Format'
    end
    object rbDetailed: TRadioButton
      Left = 96
      Top = 12
      Width = 97
      Height = 17
      Caption = 'De&tailed'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbDetailedClick
    end
    object rbSummarised: TRadioButton
      Left = 202
      Top = 12
      Width = 113
      Height = 17
      Caption = '&Summarised'
      TabOrder = 1
      OnClick = rbSummarisedClick
    end
    object chkWrapColumnText: TCheckBox
      Left = 28
      Top = 42
      Width = 161
      Height = 17
      Caption = 'Wrap Text'
      TabOrder = 2
    end
  end
  object pnlSelectedCodes: TPanel
    Left = 344
    Top = 8
    Width = 245
    Height = 249
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Caption = 'pnlSelectedCodes'
    TabOrder = 1
    Visible = False
    object Label6: TLabel
      Left = 12
      Top = 7
      Width = 27
      Height = 13
      Caption = 'From '
    end
    object Label7: TLabel
      Left = 114
      Top = 7
      Width = 12
      Height = 13
      Caption = 'To'
    end
    object btnPayee: TSpeedButton
      Left = 175
      Top = 4
      Width = 65
      Height = 21
      Hint = 'Lookup Contractor Payees'
      Caption = 'Payee'
      Flat = True
      ParentShowHint = False
      ShowHint = True
      OnClick = btnPayeeClick
    end
    object tgRanges: TtsGrid
      Left = 8
      Top = 32
      Width = 231
      Height = 177
      Hint = 'Select contractor payee ranges to show on Report'
      AutoScale = True
      CheckBoxStyle = stCheck
      Cols = 2
      DefaultColWidth = 105
      DefaultRowHeight = 20
      ExportDelimiter = ','
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Verdana'
      Font.Style = []
      HeadingFont.Charset = DEFAULT_CHARSET
      HeadingFont.Color = clWindowText
      HeadingFont.Height = -15
      HeadingFont.Name = 'MS Sans Serif'
      HeadingFont.Style = []
      HeadingHeight = 20
      HeadingOn = False
      HeadingParentFont = False
      MaskDefs = tsMaskDefs1
      ParentFont = False
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
      OnResize = tgRangesResize
      ColProperties = <
        item
          DataCol = 1
          Col.ControlType = ctText
          Col.MaskName = 'sysLongInteger'
          Col.MaxLength = 10
          Col.Width = 105
        end
        item
          DataCol = 2
          Col.ControlType = ctText
          Col.MaskName = 'sysLongInteger'
          Col.MaxLength = 10
          Col.Width = 104
        end>
      Data = {0100000002000000010000000001000000000000000000000000}
    end
    object btnSaveTemplate: TButton
      Left = 8
      Top = 216
      Width = 110
      Height = 25
      Caption = 'Save Te&mplate'
      TabOrder = 1
      OnClick = btnSaveTemplateClick
    end
    object btnLoad: TButton
      Left = 128
      Top = 216
      Width = 110
      Height = 25
      Caption = '&Load Template'
      TabOrder = 2
      OnClick = btnLoadClick
    end
  end
  object btnSave: TBitBtn
    Left = 350
    Top = 263
    Width = 75
    Height = 25
    Caption = 'Sa&ve'
    TabOrder = 7
    OnClick = btnSaveClick
  end
  object tsMaskDefs1: TtsMaskDefs
    Masks = <
      item
        Name = 'sysLongInteger'
        Picture = '*9[#]'
      end>
    Left = 376
    Top = 64
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.prt'
    Filter = 'Payee Report Template (*.prt)|*.prt'
    Options = [ofHideReadOnly, ofPathMustExist, ofFileMustExist, ofEnableSizing]
    Title = 'Load Payee Report Template'
    Left = 184
    Top = 264
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '.prt'
    Filter = 'Payee Report Template (*.prt)|*.prt'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Title = 'Save Payee Report Template'
    Left = 216
    Top = 264
  end
end
