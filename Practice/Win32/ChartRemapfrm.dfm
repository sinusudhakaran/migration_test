object frmRemapChart: TfrmRemapChart
  Left = 0
  Top = 0
  ActiveControl = EGstFile
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'frmRemapChart'
  ClientHeight = 467
  ClientWidth = 791
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 400
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pBtn: TPanel
    Left = 0
    Top = 426
    Width = 791
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      791
      41)
    object btnCancel: TButton
      Left = 710
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnOK: TButton
      Left = 628
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
  object pcChart: TPageControl
    Left = 0
    Top = 0
    Width = 791
    Height = 426
    ActivePage = tsGST
    Align = alClient
    TabOrder = 1
    object tsChart: TTabSheet
      Caption = 'Chart'
      OnShow = tsChartShow
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object ChartGrid: TVirtualStringTree
        Left = 0
        Top = 65
        Width = 783
        Height = 333
        Align = alClient
        EditDelay = 300
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.Options = [hoColumnResize, hoDblClickResize, hoShowSortGlyphs, hoVisible]
        Header.ParentFont = True
        Header.SortColumn = 0
        ParentBackground = False
        TabOrder = 1
        TreeOptions.AutoOptions = [toAutoDropExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes]
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toWheelPanning]
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
        TreeOptions.SelectionOptions = [toExtendedFocus, toRightClickSelect]
        OnCompareNodes = ChartGridCompareNodes
        OnCreateEditor = ChartGridCreateEditor
        OnDblClick = ChartGridDblClick
        OnEditing = ChartGridEditing
        OnGetText = ChartGridGetText
        OnPaintText = ChartGridPaintText
        OnHeaderClick = ChartGridHeaderClick
        OnKeyDown = ChartGridKeyDown
        OnKeyPress = ChartGridKeyPress
        OnNewText = ChartGridNewText
        Columns = <
          item
            MaxWidth = 150
            Position = 0
            Width = 100
            WideText = 'Old Code'
          end
          item
            Position = 1
            Width = 200
            WideText = 'Old Description'
          end
          item
            Position = 2
            Width = 100
            WideText = 'New Code'
          end
          item
            Position = 3
            Width = 200
            WideText = 'New Description'
          end>
      end
      object pChartTop: TPanel
        Left = 0
        Top = 0
        Width = 783
        Height = 65
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          783
          65)
        object lChartFile: TLabel
          Left = 4
          Top = 8
          Width = 77
          Height = 13
          Caption = 'Chart remap file'
        end
        object eChartFile: TEdit
          Left = 112
          Top = 5
          Width = 588
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ReadOnly = True
          TabOrder = 0
        end
        object btnChartBrowse: TButton
          Left = 706
          Top = 3
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Bro&wse'
          TabOrder = 1
          OnClick = btnChartBrowseClick
        end
        object btnChart: TBitBtn
          Left = 706
          Top = 34
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Chart'
          TabOrder = 3
          OnClick = btnChartClick
        end
        object pSave: TPanel
          Left = 112
          Top = 32
          Width = 169
          Height = 25
          BevelEdges = [beBottom]
          BevelOuter = bvNone
          TabOrder = 2
          object btnChartsave: TButton
            AlignWithMargins = True
            Left = 0
            Top = 0
            Width = 75
            Height = 25
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 7
            Margins.Bottom = 0
            Align = alLeft
            Caption = '&Save'
            TabOrder = 0
            OnClick = btnChartsaveClick
          end
          object btnChartSaveAs: TButton
            AlignWithMargins = True
            Left = 82
            Top = 0
            Width = 75
            Height = 25
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 7
            Margins.Bottom = 0
            Align = alLeft
            Caption = 'Save &as'
            TabOrder = 1
            OnClick = btnChartSaveAsClick
          end
        end
      end
    end
    object tsGST: TTabSheet
      Caption = 'GST'
      ImageIndex = 1
      OnShow = tsGSTShow
      object pGSTTop: TPanel
        Left = 0
        Top = 0
        Width = 783
        Height = 65
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          783
          65)
        object lGstFile: TLabel
          Left = 4
          Top = 8
          Width = 72
          Height = 13
          Caption = 'Gst renmap file'
        end
        object btnGSTChart: TBitBtn
          Left = 664
          Top = 34
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'GST'
          TabOrder = 3
          OnClick = btnGSTChartClick
        end
        object btnGSTBrowse: TButton
          Left = 664
          Top = 3
          Width = 75
          Height = 25
          Anchors = [akTop, akRight]
          Caption = 'Bro&wse'
          TabOrder = 1
          OnClick = btnGSTBrowseClick
        end
        object EGstFile: TEdit
          Left = 112
          Top = 5
          Width = 546
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          ReadOnly = True
          TabOrder = 0
        end
        object pGSTSave: TPanel
          Left = 112
          Top = 32
          Width = 169
          Height = 25
          BevelEdges = [beBottom]
          BevelOuter = bvNone
          TabOrder = 2
          object btnGSTSave: TButton
            AlignWithMargins = True
            Left = 0
            Top = 0
            Width = 75
            Height = 25
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 7
            Margins.Bottom = 0
            Align = alLeft
            Caption = '&Save'
            TabOrder = 0
            OnClick = btnGSTSaveClick
          end
          object btnGSTSaveAs: TButton
            AlignWithMargins = True
            Left = 82
            Top = 0
            Width = 75
            Height = 25
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 7
            Margins.Bottom = 0
            Align = alLeft
            Caption = 'Save &as'
            TabOrder = 1
            OnClick = btnGSTSaveAsClick
          end
        end
      end
      object GSTGrid: TVirtualStringTree
        Left = 0
        Top = 65
        Width = 783
        Height = 333
        Align = alClient
        EditDelay = 300
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.Options = [hoColumnResize, hoDblClickResize, hoShowSortGlyphs, hoVisible]
        Header.SortColumn = 0
        ParentBackground = False
        TabOrder = 1
        TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toGridExtensions, toInitOnSave, toWheelPanning]
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowVertGridLines, toThemeAware, toUseBlendedImages]
        TreeOptions.SelectionOptions = [toExtendedFocus, toRightClickSelect]
        OnCompareNodes = GSTGridCompareNodes
        OnCreateEditor = GSTGridCreateEditor
        OnEditing = GSTGridEditing
        OnGetText = GSTGridGetText
        OnPaintText = GSTGridPaintText
        OnHeaderClick = GSTGridHeaderClick
        OnKeyDown = GSTGridKeyDown
        OnKeyPress = GSTGridKeyPress
        OnNewText = GSTGridNewText
        Columns = <
          item
            Position = 0
            Width = 100
            WideText = 'Old ID'
          end
          item
            Position = 1
            Width = 200
            WideText = 'Old Class Description'
          end
          item
            Position = 2
            Width = 100
            WideText = 'New ID'
          end
          item
            Position = 3
            Width = 200
            WideText = 'New Class Description'
          end>
      end
    end
  end
  object OpenDlg: TOpenDialog
    Filter = 'Remap File|*.cht|CSV File|*.csv'
    Left = 496
  end
  object SaveDlg: TSaveDialog
    DefaultExt = '*.csv'
    Filter = 'CSV file *.csv|*.csv'
    FilterIndex = 0
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 528
  end
end
