object FrmChartExportMapGSTClass: TFrmChartExportMapGSTClass
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Map GST Class'
  ClientHeight = 528
  ClientWidth = 788
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    788
    528)
  PixelsPerInch = 96
  TextHeight = 13
  object grpMain: TGroupBox
    Left = 0
    Top = -5
    Width = 786
    Height = 494
    Anchors = [akLeft, akTop, akRight, akBottom]
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBackground = False
    ParentColor = False
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      786
      494)
    object lblGstRemapFile: TLabel
      Left = 12
      Top = 12
      Width = 118
      Height = 16
      Caption = 'GST class remap file'
      FocusControl = edtGstReMapFile
    end
    object edtGstReMapFile: TEdit
      Left = 136
      Top = 10
      Width = 574
      Height = 22
      Anchors = [akLeft, akTop, akRight]
      Ctl3D = False
      Enabled = False
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object btnSave: TButton
      Left = 627
      Top = 40
      Width = 69
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Save'
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      OnClick = btnSaveClick
    end
    object btnSaveAs: TButton
      Left = 702
      Top = 40
      Width = 81
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Save As'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 3
      OnClick = btnSaveAsClick
    end
    object btnBrowse: TButton
      Left = 716
      Top = 9
      Width = 67
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Browse'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
      OnClick = btnBrowseClick
    end
    object virGstReMap: TVirtualStringTree
      Left = 3
      Top = 71
      Width = 780
      Height = 420
      Anchors = [akLeft, akTop, akRight, akBottom]
      Colors.HotColor = clMenuText
      Colors.UnfocusedSelectionColor = clHighlight
      Colors.UnfocusedSelectionBorderColor = clHighlight
      Header.AutoSizeIndex = 0
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoColumnResize, hoDrag, hoVisible]
      ParentBackground = False
      TabOrder = 4
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toHideFocusRect, toShowButtons, toShowHorzGridLines, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect]
      OnCompareNodes = virGstReMapCompareNodes
      OnCreateEditor = virGstReMapCreateEditor
      OnFocusChanged = virGstReMapFocusChanged
      OnGetText = virGstReMapGetText
      OnPaintText = virGstReMapPaintText
      OnHeaderClick = virGstReMapHeaderClick
      OnNewText = virGstReMapNewText
      ExplicitHeight = 415
      Columns = <
        item
          Position = 0
          WideText = 'ID'
        end
        item
          Position = 1
          Width = 350
          WideText = 'Class Description'
        end
        item
          Position = 2
          Width = 350
          WideText = 'MYOB Essentials Cashbook GST class'
        end>
    end
  end
  object btnOk: TButton
    Left = 624
    Top = 495
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 1
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 705
    Top = 495
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 2
    ParentFont = False
    TabOrder = 2
  end
  object SaveDlg: TSaveDialog
    DefaultExt = '*.csv'
    Filter = 'CSV file *.csv|*.csv'
    FilterIndex = 0
    Options = [ofHideReadOnly, ofNoChangeDir, ofEnableSizing]
    Left = 584
    Top = 496
  end
  object OpenDlg: TOpenDialog
    Filter = 'Remap File|*.cht|CSV File|*.csv'
    Left = 552
    Top = 496
  end
end
