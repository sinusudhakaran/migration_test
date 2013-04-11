object frmExportCharges: TfrmExportCharges
  Left = 330
  Top = 274
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Export Charges'
  ClientHeight = 446
  ClientWidth = 653
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 425
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlOptions: TPanel
    Left = 0
    Top = 76
    Width = 653
    Height = 330
    Align = alClient
    TabOrder = 0
    object lblSaveTo: TLabel
      Left = 26
      Top = 103
      Width = 75
      Height = 13
      Caption = '&Save Entries To'
      FocusControl = eTo
    end
    object lblMonth: TLabel
      Left = 26
      Top = 43
      Width = 78
      Height = 13
      Caption = '&Month to Export'
      FocusControl = cmbMonths
    end
    object btnToFolder: TSpeedButton
      Left = 562
      Top = 99
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      OnClick = btnToFolderClick
    end
    object lblDate: TLabel
      Left = 26
      Top = 172
      Width = 58
      Height = 13
      Caption = 'Import &Date'
      FocusControl = eDate
    end
    object lblRemarks: TLabel
      Left = 26
      Top = 236
      Width = 41
      Height = 13
      Caption = '&Remarks'
      FocusControl = eRemarks
    end
    object eTo: TEdit
      Left = 146
      Top = 99
      Width = 415
      Height = 24
      BorderStyle = bsNone
      TabOrder = 1
      Text = 'eTo'
    end
    object cmbMonths: TComboBox
      Left = 146
      Top = 39
      Width = 151
      Height = 21
      Hint = 'Choose the charges month to export'
      Style = csDropDownList
      ItemHeight = 0
      TabOrder = 0
      OnChange = cmbMonthsChange
    end
    object eDate: TRzDateTimePicker
      Left = 146
      Top = 168
      Width = 103
      Height = 21
      Date = 38965.379046875000000000
      Time = 38965.379046875000000000
      TabOrder = 2
      OnChange = eDateChange
    end
    object eRemarks: TEdit
      Left = 146
      Top = 232
      Width = 415
      Height = 24
      BorderStyle = bsNone
      MaxLength = 200
      TabOrder = 3
    end
  end
  object pnlAdjust: TPanel
    Left = 0
    Top = 76
    Width = 653
    Height = 330
    Align = alClient
    TabOrder = 4
    object lblView: TLabel
      Left = 130
      Top = 258
      Width = 265
      Height = 13
      Cursor = crHandPoint
      Caption = 'View Statements and Download Documents for <date>'
      Color = 4868168
      ParentColor = False
      ShowAccelChar = False
      Transparent = True
      OnClick = lblViewClick
    end
    object gbFixed: TGroupBox
      Left = 63
      Top = 35
      Width = 506
      Height = 116
      TabOrder = 1
      object rbDistribute: TRadioButton
        Left = 30
        Top = 58
        Width = 323
        Height = 17
        Caption = 'Distribute a fixed amount across all charges'
        Enabled = False
        TabOrder = 2
        OnClick = rbDistributeClick
      end
      object rbAddFixed: TRadioButton
        Left = 30
        Top = 27
        Width = 323
        Height = 17
        Caption = 'Add a fixed amount to each charge             '
        Enabled = False
        TabOrder = 0
        OnClick = rbAddFixedClick
      end
      object eAddFixed: TOvcNumericField
        Left = 355
        Top = 27
        Width = 62
        Height = 22
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
        Enabled = False
        Options = []
        PictureMask = '##,###.##'
        TabOrder = 1
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
      object eDistribute: TOvcNumericField
        Left = 355
        Top = 58
        Width = 62
        Height = 22
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
        Enabled = False
        Options = []
        PictureMask = '##,###.##'
        TabOrder = 3
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
      object rbSetFixed: TRadioButton
        Left = 30
        Top = 89
        Width = 275
        Height = 17
        Caption = 'Set a fixed amount for each charge'
        Enabled = False
        TabOrder = 4
        OnClick = rbSetFixedClick
      end
      object eSetFixed: TOvcNumericField
        Left = 355
        Top = 89
        Width = 62
        Height = 22
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
        Enabled = False
        Options = []
        PictureMask = '##,###.##'
        TabOrder = 5
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
    end
    object gbPercent: TGroupBox
      Left = 63
      Top = 160
      Width = 506
      Height = 70
      TabOrder = 3
      object lblPercent: TLabel
        Left = 30
        Top = 30
        Width = 344
        Height = 13
        Caption = 
          'Increase each charge by a specified percentage                  ' +
          '                %'
        Enabled = False
      end
      object ePercent: TOvcNumericField
        Left = 355
        Top = 27
        Width = 62
        Height = 22
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
        Enabled = False
        Options = []
        PictureMask = '##,###.##'
        TabOrder = 0
        RangeHigh = {73B2DBB9838916F2FE43}
        RangeLow = {73B2DBB9838916F2FEC3}
      end
    end
    object chkFixed: TCheckBox
      Left = 72
      Top = 35
      Width = 50
      Height = 17
      Caption = 'Fixed'
      TabOrder = 0
      OnClick = chkFixedClick
    end
    object chkPercent: TCheckBox
      Left = 72
      Top = 157
      Width = 85
      Height = 17
      Caption = 'Percentage'
      TabOrder = 2
      OnClick = chkPercentClick
    end
  end
  object pnlGrid: TPanel
    Left = 0
    Top = 76
    Width = 653
    Height = 330
    Align = alClient
    TabOrder = 2
    object pnlProgress: TPanel
      Left = 1
      Top = 1
      Width = 651
      Height = 298
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      DesignSize = (
        651
        298)
      object pnlCentre: TPanel
        Left = 220
        Top = 125
        Width = 209
        Height = 50
        Anchors = []
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          209
          50)
        object Label1: TLabel
          Left = 6
          Top = 4
          Width = 76
          Height = 13
          Anchors = []
          Caption = 'Updating grid...'
        end
        object pbGrid: TProgressBar
          Left = 6
          Top = 25
          Width = 200
          Height = 20
          Anchors = []
          TabOrder = 0
        end
      end
    end
    object tgCharges: TtsGrid
      Left = 1
      Top = 1
      Width = 651
      Height = 298
      Align = alClient
      BorderStyle = bsNone
      CheckBoxStyle = stCheck
      ColMoving = False
      Cols = 11
      ColSelectMode = csNone
      DefaultRowHeight = 24
      ExportDelimiter = ','
      HeadingButton = hbCell
      HeadingFont.Charset = DEFAULT_CHARSET
      HeadingFont.Color = clWindowText
      HeadingFont.Height = -11
      HeadingFont.Name = 'Tahoma'
      HeadingFont.Style = []
      HeadingHeight = 35
      HeadingParentFont = False
      HeadingVertAlignment = vtaCenter
      MaskDefs = tsMaskDefs1
      ParentShowHint = False
      PopupMenu = pmGrid
      RowBarOn = False
      RowMoving = False
      Rows = 4
      RowSelectMode = rsNone
      ShowHint = False
      StoreData = True
      TabOrder = 0
      Version = '2.20.26'
      WantTabs = False
      XMLExport.Version = '1.0'
      XMLExport.DataPacketVersion = '2.0'
      OnCellChanged = tgChargesCellChanged
      OnCellEdit = tgChargesCellEdit
      OnColChanged = tgChargesColChanged
      OnColResized = tgChargesColResized
      OnComboCellLoaded = tgChargesComboCellLoaded
      OnComboDropDown = tgChargesComboDropDown
      OnComboGetValue = tgChargesComboGetValue
      OnEndCellEdit = tgChargesEndCellEdit
      OnKeyDown = tgChargesKeyDown
      OnMouseUp = tgChargesMouseUp
      OnRowChanged = tgChargesRowChanged
      ColProperties = <
        item
          DataCol = 1
          Col.Heading = 'Secure Code'
          Col.ReadOnly = True
          Col.SortPicture = spDown
          Col.Width = 75
          Col.WordWrap = wwOff
        end
        item
          DataCol = 2
          Col.Heading = 'Account No'
          Col.MaxLength = 20
          Col.ReadOnly = True
          Col.Width = 110
          Col.WordWrap = wwOff
        end
        item
          DataCol = 3
          Col.Heading = 'Account Name'
          Col.MaxLength = 60
          Col.ReadOnly = True
          Col.Width = 95
          Col.WordWrap = wwOff
        end
        item
          DataCol = 4
          Col.Color = clInfoBk
          Col.Heading = 'File Code'
          Col.MaxLength = 10
          Col.WordWrap = wwOff
        end
        item
          DataCol = 5
          Col.Color = clInfoBk
          Col.Heading = 'Cost Code'
          Col.MaxLength = 10
          Col.Width = 71
          Col.WordWrap = wwOff
        end
        item
          DataCol = 6
          Col.ButtonType = btCombo
          Col.Color = clInfoBk
          Col.Heading = 'Client'
          Col.MaxLength = 15
          Col.ParentCombo = False
          Col.WordWrap = wwOff
          Col.Combo = {
            545046300C547473436F6D626F4772696400044C656674020003546F70020005
            57696474680340010648656967687402780754616253746F70080A4175746F53
            656172636807056173546F700C44726F70446F776E526F7773020A0C44726F70
            446F776E436F6C7302020D436865636B426F785374796C650707737443686563
            6B04436F6C7302020543746C3344080F44656661756C74436F6C576964746802
            4A1348656164696E67466F6E742E43686172736574070F44454641554C545F43
            4841525345541148656164696E67466F6E742E436F6C6F72070C636C57696E64
            6F77546578741248656164696E67466F6E742E48656967687402F41048656164
            696E67466F6E742E4E616D65060D4D532053616E732053657269661148656164
            696E67466F6E742E5374796C650B001148656164696E67506172656E74466F6E
            74080B506172656E7443746C3344080E506172656E7453686F7748696E74080A
            526573697A65436F6C73070672634E6F6E650A526573697A65526F7773070672
            724E6F6E6508526F774261724F6E0804526F777302000A5363726F6C6C426172
            73070A7373566572746963616C0853686F7748696E74080953746F7265446174
            61090D5468756D62547261636B696E67090756657273696F6E0607322E32302E
            32360D436F6C50726F706572746965730E010744617461436F6C02010B436F6C
            2E48656164696E67060B436C69656E74204E616D6509436F6C2E576964746803
            960000010744617461436F6C02020B436F6C2E48656164696E670609436C6965
            6E7420494409436F6C2E57696474680232000004446174610A08000000000000
            00000000000000}
        end
        item
          DataCol = 7
          Col.ButtonType = btCombo
          Col.Color = clInfoBk
          Col.DropDownStyle = ddDropDownList
          Col.Heading = 'Matter'
          Col.MaxLength = 100
          Col.ParentCombo = False
          Col.WordWrap = wwOff
          Col.Combo = {
            545046300C547473436F6D626F4772696400044C656674020003546F70020005
            57696474680340010648656967687402780754616253746F70080A4175746F53
            656172636807056173546F700C44726F70446F776E526F7773020A0C44726F70
            446F776E436F6C7302020D44726F70446F776E5374796C65070E646444726F70
            446F776E4C6973740D436865636B426F785374796C6507077374436865636B04
            436F6C7302020543746C3344080F44656661756C74436F6C5769647468024A13
            48656164696E67466F6E742E43686172736574070F44454641554C545F434841
            525345541148656164696E67466F6E742E436F6C6F72070C636C57696E646F77
            546578741248656164696E67466F6E742E48656967687402F41048656164696E
            67466F6E742E4E616D65060D4D532053616E732053657269661148656164696E
            67466F6E742E5374796C650B001148656164696E67506172656E74466F6E7408
            0B506172656E7443746C3344080E506172656E7453686F7748696E74080A5265
            73697A65436F6C73070672634E6F6E650A526573697A65526F7773070672724E
            6F6E6508526F774261724F6E0804526F777302000A5363726F6C6C4261727307
            0A7373566572746963616C0853686F7748696E74080953746F72654461746109
            0D5468756D62547261636B696E67090756657273696F6E0607322E32302E3236
            0D436F6C50726F706572746965730E010744617461436F6C02010B436F6C2E48
            656164696E67060B4D6174746572204E616D6509436F6C2E5769647468039600
            00010744617461436F6C02020B436F6C2E48656164696E6706094D6174746572
            20494409436F6C2E57696474680232000004446174610A080000000000000000
            0000000000}
        end
        item
          DataCol = 8
          Col.Color = clInfoBk
          Col.Heading = 'Assignment Code'
          Col.MaskName = 'sysConvertUpper'
          Col.MaxLength = 20
          Col.Width = 100
          Col.WordWrap = wwOff
        end
        item
          DataCol = 9
          Col.Color = clInfoBk
          Col.Heading = 'Disbursement Code Type'
          Col.MaxLength = 10
          Col.Width = 100
          Col.WordWrap = wwOff
        end
        item
          DataCol = 10
          Col.Heading = 'BankLink Charges'
          Col.MaskName = 'money'
          Col.MaxLength = 20
          Col.ReadOnly = True
          Col.WordWrap = wwOff
        end
        item
          DataCol = 11
          Col.Color = clInfoBk
          Col.Heading = 'Amended Charges'
          Col.MaskName = 'money'
        end>
      Data = {
        010000000B000000010000000001000000000100000000010000000001000000
        0001000000000100000000010000000001000000000100000000010000000000
        00000000000000}
    end
    object pnlHide: TPanel
      Left = 1
      Top = 299
      Width = 651
      Height = 30
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      DesignSize = (
        651
        30)
      object chkHide: TCheckBox
        Left = 7
        Top = 6
        Width = 258
        Height = 17
        Caption = '&Hide accounts with no charge this month'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = chkHideClick
      end
      object pnlSearch: TPanel
        Left = 271
        Top = 0
        Width = 380
        Height = 30
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvNone
        TabOrder = 1
        object Label2: TLabel
          Left = 23
          Top = 8
          Width = 24
          Height = 13
          Caption = 'Find:'
        end
        object edtFind: TEdit
          Left = 56
          Top = 4
          Width = 130
          Height = 21
          Hint = 'Enter text to search for'
          MaxLength = 100
          TabOrder = 0
          OnChange = edtFindChange
          OnKeyDown = edtFindKeyDown
        end
        object btnNext: TBitBtn
          Left = 189
          Top = 3
          Width = 85
          Height = 25
          Hint = 'Find the next entry containing the search text'
          Caption = '&Next'
          TabOrder = 1
          OnClick = btnFindNextClick
          Glyph.Data = {
            5E040000424D5E04000000000000360000002800000012000000130000000100
            18000000000028040000C40E0000C40E00000000000000000000D8E9ECD8E9EC
            D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9
            ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC0000D8E9ECD8E9ECD8E9ECD8E9ECD8E9
            ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8
            E9ECD8E9ECD8E9EC0000D8E9ECD8E9ECD8E9EC000000000000000000000000D8
            E9ECD8E9ECD8E9EC000000000000000000000000D8E9ECD8E9ECD8E9ECD8E9EC
            0000D8E9ECD8E9ECD8E9EC000000FFFFFF000000000000D8E9ECD8E9ECD8E9EC
            000000FFFFFF000000000000D8E9ECD8E9ECD8E9ECD8E9EC0000D8E9ECD8E9EC
            D8E9EC000000FFFFFF000000000000D8E9ECD8E9ECD8E9EC000000FFFFFF0000
            00000000D8E9ECD8E9ECD8E9ECD8E9EC0000D8E9ECD8E9ECD8E9EC0000000000
            00000000000000000000000000000000000000000000000000000000D8E9ECD8
            E9ECD8E9ECD8E9EC0000D8E9ECD8E9ECD8E9EC000000FFFFFF00000000000000
            000099A8AC000000FFFFFF000000000000000000D8E9ECD8E9ECD8E9ECD8E9EC
            0000D8E9ECD8E9ECD8E9EC000000FFFFFF000000000000000000000000000000
            FFFFFF000000000000000000D8E9ECD8E9ECD8E9ECD8E9EC0000D8E9ECD8E9EC
            D8E9ECD8E9EC00000000000000000099A8ACD8E9EC99A8AC0000000000000000
            00D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC0000D8E9ECD8E9ECD8E9ECD8E9ECD8E9
            EC000000000000D8E9ECD8E9ECD8E9EC000000000000D8E9ECD8E9ECD8E9ECD8
            E9ECD8E9ECD8E9EC0000D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000000000D8
            E9ECD8E9ECD8E9EC000000000000D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
            0000D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC99A8AC800000D8E9EC
            D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC0000D8E9ECD8E9EC
            D8E9ECD8E9ECD8E9ECD8E9EC99A8AC800000D8E9ECD8E9ECD8E9ECD8E9EC8000
            00800000800000800000D8E9ECD8E9EC0000D8E9ECD8E9ECD8E9ECD8E9ECD8E9
            ECD8E9EC800000D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC80000080000080
            0000D8E9ECD8E9EC0000D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC800000D8
            E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC800000800000800000D8E9ECD8E9EC
            0000D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC99A8AC800000D8E9ECD8E9EC
            D8E9EC99A8AC800000D8E9ECD8E9EC800000D8E9ECD8E9EC0000D8E9ECD8E9EC
            D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC99A8AC800000800000800000800000D8E9
            ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC0000D8E9ECD8E9ECD8E9ECD8E9ECD8E9
            ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8
            E9ECD8E9ECD8E9EC0000E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2
            EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1
            0000}
          Layout = blGlyphRight
        end
        object btnLast: TBitBtn
          Left = 276
          Top = 3
          Width = 85
          Height = 25
          Hint = 'Find the previous entry containing the search text'
          Caption = '&Previous'
          TabOrder = 2
          OnClick = btnFindLastClick
          Glyph.Data = {
            AA040000424DAA04000000000000360000002800000013000000130000000100
            18000000000074040000C40E0000C40E00000000000000000000D8E9ECD8E9EC
            D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9
            ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000D8E9ECD8E9ECD8E9ECD8
            E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
            D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000D8E9ECD8E9ECD8E9ECD8E9ECD8E9
            EC000000000000000000000000D8E9ECD8E9ECD8E9EC00000000000000000000
            0000D8E9ECD8E9ECD8E9EC000000D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000
            FFFFFF000000000000D8E9ECD8E9ECD8E9EC000000FFFFFF000000000000D8E9
            ECD8E9ECD8E9EC000000D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000FFFFFF00
            0000000000D8E9ECD8E9ECD8E9EC000000FFFFFF000000000000D8E9ECD8E9EC
            D8E9EC000000D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC0000000000000000000000
            00000000000000000000000000000000000000000000D8E9ECD8E9ECD8E9EC00
            0000D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000FFFFFF000000000000000000
            99A8AC000000FFFFFF000000000000000000D8E9ECD8E9ECD8E9EC000000D8E9
            ECD8E9ECD8E9ECD8E9ECD8E9EC000000FFFFFF00000000000000000000000000
            0000FFFFFF000000000000000000D8E9ECD8E9ECD8E9EC000000D8E9ECD8E9EC
            D8E9ECD8E9ECD8E9ECD8E9EC00000000000000000099A8ACD8E9EC99A8AC0000
            00000000000000D8E9ECD8E9ECD8E9ECD8E9EC000000D8E9ECD8E9ECD8E9ECD8
            E9ECD8E9ECD8E9ECD8E9EC000000000000D8E9ECD8E9ECD8E9EC000000000000
            D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000D8E9ECD8E9ECD8E9ECD8E9ECD8E9
            ECD8E9ECD8E9EC000000000000D8E9ECD8E9ECD8E9EC000000000000D8E9ECD8
            E9ECD8E9ECD8E9ECD8E9EC000000D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
            D8E9ECD8E9ECD8E9ECD8E9EC80000099A8ACD8E9ECD8E9ECD8E9ECD8E9ECD8E9
            ECD8E9ECD8E9EC000000D8E9ECD8E9ECD8E9EC800000800000800000800000D8
            E9ECD8E9ECD8E9ECD8E9EC80000099A8ACD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
            D8E9EC000000D8E9ECD8E9ECD8E9EC800000800000800000D8E9ECD8E9ECD8E9
            ECD8E9ECD8E9ECD8E9EC800000D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC00
            0000D8E9ECD8E9ECD8E9EC800000800000800000D8E9ECD8E9ECD8E9ECD8E9EC
            D8E9ECD8E9EC800000D8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000D8E9
            ECD8E9ECD8E9EC800000D8E9ECD8E9EC80000099A8ACD8E9ECD8E9ECD8E9EC80
            000099A8ACD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000D8E9ECD8E9EC
            D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC80000080000080000080000099A8ACD8E9
            ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000D8E9ECD8E9ECD8E9ECD8
            E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9ECD8E9EC
            D8E9ECD8E9ECD8E9ECD8E9ECD8E9EC000000E2EFF1E2EFF1E2EFF1E2EFF1E2EF
            F1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2EFF1E2
            EFF1E2EFF1E2EFF1E2EFF1000000}
          Layout = blGlyphRight
        end
      end
    end
  end
  object pnlInstructions: TPanel
    Left = 0
    Top = 0
    Width = 653
    Height = 76
    Align = alTop
    TabOrder = 1
    object lblTitle: TLabel
      Left = 7
      Top = 36
      Width = 618
      Height = 34
      AutoSize = False
      Caption = 'Description'
      WordWrap = True
    end
    object lblHeading: TLabel
      Left = 7
      Top = 8
      Width = 32
      Height = 16
      Caption = 'Title'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 406
    Width = 653
    Height = 40
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      653
      40)
    object btnBack: TButton
      Left = 413
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '<< &Back'
      TabOrder = 2
      OnClick = btnBackClick
    end
    object btnReport: TButton
      Left = 7
      Top = 7
      Width = 75
      Height = 25
      Hint = 'List the charges in a report'
      Caption = '&Report'
      TabOrder = 0
      OnClick = btnReportClick
    end
    object btnOK: TButton
      Left = 492
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Finish'
      Default = True
      TabOrder = 3
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 571
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 4
      OnClick = btnCancelClick
    end
    object btnStore: TButton
      Left = 335
      Top = 7
      Width = 75
      Height = 25
      Hint = 'Save the current data in the grid'
      Anchors = [akRight, akBottom]
      Caption = '&Save Data'
      TabOrder = 1
      OnClick = btnStoreClick
    end
  end
  object tsMaskDefs1: TtsMaskDefs
    Masks = <
      item
        Evaluate = [mcOnEdit]
        Name = 'money'
        Picture = '[-]#*9[#][.##]'
      end
      item
        Name = 'sysInteger'
        Picture = '###############'
      end
      item
        Name = 'sysConvertUpper'
        Picture = '>>*[!]'
      end
      item
        Name = 'sysShortInteger'
        Picture = '*3[#]'
      end
      item
        Name = 'sysLongDecimal'
        Picture = '#*7[#][.##]'
      end>
    Left = 544
    Top = 220
  end
  object SaveDialog1: TSaveDialog
    Title = 'Save Charges To'
    Left = 464
    Top = 215
  end
  object tmrAPS: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmrAPSTimer
    Left = 504
    Top = 215
  end
  object pmGrid: TPopupMenu
    OnPopup = pmGridPopup
    Left = 328
    Top = 160
    object FlagAccountasNoCharge1: TMenuItem
      Caption = 'Flag Account as No Charge'
      OnClick = FlagAccountasNoCharge1Click
    end
    object RemoveNoChargeFlag1: TMenuItem
      Caption = 'Remove No Charge Flag'
      OnClick = RemoveNoChargeFlag1Click
    end
  end
end
