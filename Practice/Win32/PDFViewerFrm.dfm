object PDFViewFrm: TPDFViewFrm
  Left = 0
  Top = 0
  ActiveControl = PDFViewer
  Caption = 'PDF Viewer'
  ClientHeight = 769
  ClientWidth = 916
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 750
    Width = 916
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Loading Report...'
  end
  object tbarPreview: TToolBar
    Left = 0
    Top = 0
    Width = 916
    Height = 30
    AutoSize = True
    ButtonHeight = 26
    ButtonWidth = 74
    EdgeBorders = [ebTop, ebBottom]
    Images = AppImages.imPreview
    List = True
    ShowCaptions = True
    TabOrder = 1
    object tbDoSetup: TToolButton
      Left = 0
      Top = 0
      Hint = 'Setup printer options'
      Caption = '&Setup'
      ImageIndex = 1
      OnClick = tbDoSetupClick
    end
    object tbDoPrint: TToolButton
      Left = 74
      Top = 0
      Hint = 'Print this report'
      Caption = '&Print'
      ImageIndex = 0
      OnClick = tbDoPrintClick
    end
    object tbEmail: TToolButton
      Left = 148
      Top = 0
      Caption = '&Email'
      ImageIndex = 6
      OnClick = tbEmailClick
    end
    object tbSep1: TToolButton
      Left = 222
      Top = 0
      Width = 8
      Caption = 'M'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object tbPage: TToolButton
      Left = 230
      Top = 0
      Hint = 'Use the full width to view the preview'
      Caption = '&Width'
      ImageIndex = 3
      OnClick = tbPageClick
    end
    object tbWhole: TToolButton
      Left = 304
      Top = 0
      Hint = 'See the full page in the preview'
      Caption = '&Full Page'
      ImageIndex = 4
      OnClick = tbWholeClick
    end
    object tbSep2: TToolButton
      Left = 378
      Top = 0
      Width = 8
      Caption = ' '
      ImageIndex = 5
      Style = tbsSeparator
    end
    object cmbZoom: TComboBox
      Left = 386
      Top = 0
      Width = 111
      Height = 21
      Hint = 'Zoom the preview'
      Align = alClient
      ItemHeight = 13
      ItemIndex = 8
      TabOrder = 0
      Text = 'Page Width'
      OnChange = cmbZoomChange
      OnKeyDown = cmbZoomKeyDown
      OnKeyUp = cmbZoomKeyUp
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
        'Whole Page'
        '2 Pages')
    end
    object tbSep3: TToolButton
      Left = 497
      Top = 0
      Width = 8
      Caption = 'tbSep3'
      ImageIndex = 6
      Style = tbsSeparator
    end
    object tbClose: TToolButton
      Left = 505
      Top = 0
      Hint = 'Close the preview'
      Caption = 'Close '
      ImageIndex = 5
      OnClick = tbCloseClick
    end
  end
  object tbarPage: TToolBar
    Left = 0
    Top = 30
    Width = 916
    Height = 28
    AutoSize = True
    ButtonHeight = 26
    ButtonWidth = 55
    Caption = 'Where does this go'
    EdgeBorders = [ebBottom]
    Images = AppImages.imPage
    List = True
    TabOrder = 0
    Wrapable = False
    object tbFirst: TToolButton
      Left = 0
      Top = 0
      Hint = 'Go to the first page'
      AutoSize = True
      ImageIndex = 0
      OnClick = tbFirstClick
    end
    object tbPrev: TToolButton
      Left = 31
      Top = 0
      Hint = 'Go to the previous page'
      AutoSize = True
      ImageIndex = 1
      OnClick = tbPrevClick
    end
    object tbNext: TToolButton
      Left = 62
      Top = 0
      Hint = 'Go to the next page'
      AutoSize = True
      ImageIndex = 2
      OnClick = tbNextClick
    end
    object tbLast: TToolButton
      Left = 93
      Top = 0
      Hint = 'Go to the last page'
      AutoSize = True
      Caption = 'Page'
      ImageIndex = 3
      OnClick = tbLastClick
    end
  end
  object PDFViewer: TWPViewPDF
    Left = 0
    Top = 58
    Width = 916
    Height = 692
    ViewControls = [wpHorzScrollBar, wpVertScrollBar, wpNavigationPanel]
    ViewOptions = [wpSelectClickedPage]
    SecurityOptions = [wpDisableSave, wpDisableCopy, wpDisableForms, wpDisableEdit, wpDisablePDFSecurityOverride]
    OnChangeViewPage = PDFViewerChangeViewPage
    OnKeyDown = PDFViewerKeyDown
    Align = alClient
  end
end
