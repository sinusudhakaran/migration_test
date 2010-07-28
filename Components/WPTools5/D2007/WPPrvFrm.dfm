object WPPreviewForm: TWPPreviewForm
  Left = 502
  Top = 149
  Width = 729
  Height = 470
  ActiveControl = Panel1
  Caption = 'Print-Preview'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poDefault
  Scaled = False
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Panel1: TPanel
    Left = 0
    Top = 416
    Width = 721
    Height = 20
    Align = alBottom
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object ZoomValue: TLabel
      Left = 5
      Top = 2
      Width = 52
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Caption = '100%'
      Transparent = True
    end
    object Bevel1: TBevel
      Left = 65
      Top = 2
      Width = 6
      Height = 18
      Shape = bsLeftLine
    end
    object grpPageButtons: TToolBar
      Left = 535
      Top = 0
      Width = 186
      Height = 20
      Align = alRight
      ButtonHeight = 18
      ButtonWidth = 21
      Images = ImageList1
      TabOrder = 0
      Wrapable = False
      object btnFirstPage: TToolButton
        Left = 0
        Top = 2
        Caption = 'ToolButton1'
        ImageIndex = 0
        OnClick = btnFirstPageClick
      end
      object btnPrevPage: TToolButton
        Left = 21
        Top = 2
        Caption = 'ToolButton3'
        ImageIndex = 1
        OnClick = btnPrevPageClick
      end
      object PageNoParent: TPanel
        Left = 42
        Top = 2
        Width = 33
        Height = 18
        BevelOuter = bvNone
        TabOrder = 0
      end
      object NumPages: TLabel
        Left = 75
        Top = 2
        Width = 36
        Height = 18
        Caption = ' / 000 '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object btnNextPage: TToolButton
        Left = 111
        Top = 2
        Caption = 'ToolButton2'
        ImageIndex = 2
        OnClick = btnNextPageClick
      end
      object btnLastPage: TToolButton
        Left = 132
        Top = 2
        Caption = 'btnLastPage'
        ImageIndex = 3
        OnClick = btnLastPageClick
      end
      object ToolButton2: TToolButton
        Left = 153
        Top = 2
        Caption = 'ToolButton2'
        Enabled = False
        ImageIndex = 4
      end
    end
  end
  object WPPreview1: TWPPreview
    Left = 15
    Top = 48
    Width = 651
    Height = 337
    SinglePageMode = False
    PageNumber = 0
    Zooming = 1
    XOffset = 144
    YOffset = 144
    XBetween = 144
    YBetween = 144
    LayoutMode = wplayFullLayout
    ScrollBars = ssBoth
    ViewOptions = [wpHideSelection, wpDisableMisspellMarkers, wpDontGrayHeaderFooterInLayout]
    OneClickHyperlink = False
    OnUpdateExternScrollbar = WPPreview1UpdateExternScrollbar
    TabOrder = 1
  end
  object ToolPanel: TPanel
    Left = 0
    Top = 0
    Width = 721
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    object Bevel2: TBevel
      Left = 0
      Top = 37
      Width = 721
      Height = 4
      Align = alBottom
      Shape = bsBottomLine
    end
    object cbxZoomModes: TComboBox
      Left = 248
      Top = 5
      Width = 153
      Height = 24
      ItemHeight = 16
      TabOrder = 0
      Text = 'cbxZoomModes'
      OnChange = cbxZoomModesChange
      Items.Strings = (
        '500%'
        '200%'
        '150%'
        '100%'
        '75%'
        '50%'
        '25%'
        '10%'
        'Page Width'
        'Full Page'
        'Two Pages')
    end
    object grpStatusButtons: TToolBar
      Left = 0
      Top = 1
      Width = 245
      Height = 37
      Align = alNone
      AutoSize = True
      ButtonHeight = 33
      ButtonWidth = 35
      Images = ImageList2
      TabOrder = 1
      Wrapable = False
      object btnClose: TToolButton
        Left = 0
        Top = 2
        Hint = 'Close'
        AllowAllUp = True
        Caption = 'btnClose'
        ImageIndex = 1
        OnClick = btnCloseClick
      end
      object btnPrint: TToolButton
        Left = 35
        Top = 2
        Hint = 'Print'
        AllowAllUp = True
        Caption = 'btnPrint'
        ImageIndex = 6
        OnClick = btnPrintClick
      end
      object btnPrintSetup: TToolButton
        Left = 70
        Top = 2
        AllowAllUp = True
        Caption = 'btnPrintSetup'
        ImageIndex = 5
        OnClick = btnPrintSetupClick
      end
      object btnSaveExport: TToolButton
        Left = 105
        Top = 2
        AllowAllUp = True
        Caption = 'btnSaveExport'
        ImageIndex = 2
        OnClick = btnSaveExportClick
      end
      object btnSavePDF: TToolButton
        Left = 140
        Top = 2
        AllowAllUp = True
        Caption = 'btnSavePDF'
        Enabled = False
        ImageIndex = 4
      end
      object btnMail: TToolButton
        Left = 175
        Top = 2
        AllowAllUp = True
        Caption = 'btnMail'
        ImageIndex = 3
      end
      object btnEditMode: TToolButton
        Left = 210
        Top = 2
        AllowAllUp = True
        Caption = 'btnEditMode'
        ImageIndex = 0
        Wrap = True
        OnClick = btnEditModeClick
      end
    end
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = cbxZoomModesChange
    Left = 242
    Top = 93
  end
  object ImageList1: TImageList
    Height = 12
    Width = 12
    Left = 88
    Top = 104
  end
  object ImageList2: TImageList
    Height = 24
    Width = 24
    Left = 128
    Top = 104
  end
end
