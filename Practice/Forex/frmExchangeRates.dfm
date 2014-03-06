object ExchangeRatesfrm: TExchangeRatesfrm
  Scaled = False
Left = 0
  Top = 0
  Caption = 'Maintain Exchange Rates'
  ClientHeight = 450
  ClientWidth = 705
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 193
    Top = 0
    Height = 409
    ExplicitLeft = 160
    ExplicitTop = -65
    ExplicitHeight = 357
  end
  object pButtons: TPanel
    Left = 0
    Top = 409
    Width = 705
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      705
      41)
    object btnCancel: TButton
      Left = 619
      Top = 8
      Width = 77
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object BtnoK: TButton
      Left = 539
      Top = 8
      Width = 77
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 1
      OnClick = BtnoKClick
    end
  end
  object RSGroupBar: TRzGroupBar
    Left = 0
    Top = 0
    Width = 193
    Height = 409
    GradientColorStyle = gcsCustom
    GradientColorStart = 16776934
    GradientColorStop = 11446784
    GroupBorderSize = 8
    Color = clBtnShadow
    Constraints.MinWidth = 100
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Verdana'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 1
    object grpStyles: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
          Action = acImport
        end
        item
          Action = acAddExchangeRate
        end
        item
          Action = acEditExchangeRate
        end
        item
          Caption = '-'
        end
        item
          Action = acLock
        end
        item
          Action = acUnlock
        end>
      Opened = True
      OpenedHeight = 148
      SmallImages = AppImages.ilFileActions_ClientMgr
      Caption = 'Exchange Rate Tasks'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object grpDetails: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
          Caption = 'Item1'
        end>
      Opened = True
      OpenedHeight = 45
      Caption = 'Details'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
  end
  object pTree: TPanel
    Left = 196
    Top = 0
    Width = 509
    Height = 409
    Align = alClient
    TabOrder = 2
    object pTop: TPanel
      Left = 1
      Top = 1
      Width = 507
      Height = 41
      Align = alTop
      TabOrder = 0
      object Label1: TLabel
        Left = 16
        Top = 8
        Width = 53
        Height = 13
        Caption = 'Rates from'
      end
      object Label2: TLabel
        Left = 208
        Top = 8
        Width = 21
        Height = 13
        Caption = 'Until'
      end
      object eDateFrom: TOvcPictureField
        Left = 83
        Top = 7
        Width = 105
        Height = 20
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        ControlCharColor = clRed
        DecimalPlaces = 0
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Epoch = 0
        InitDateTime = False
        MaxLength = 8
        Options = [efoCaretToEnd]
        PictureMask = 'DD/mm/yy'
        TabOrder = 0
        OnChange = eDateFromChange
        OnDblClick = eDateToDblClick
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      object eDateTo: TOvcPictureField
        Left = 256
        Top = 7
        Width = 105
        Height = 20
        Cursor = crIBeam
        DataType = pftDate
        AutoSize = False
        BorderStyle = bsNone
        CaretOvr.Shape = csBlock
        ControlCharColor = clRed
        DecimalPlaces = 0
        EFColors.Disabled.BackColor = clWindow
        EFColors.Disabled.TextColor = clGrayText
        EFColors.Error.BackColor = clRed
        EFColors.Error.TextColor = clBlack
        EFColors.Highlight.BackColor = clHighlight
        EFColors.Highlight.TextColor = clHighlightText
        Epoch = 0
        InitDateTime = False
        MaxLength = 8
        Options = [efoCaretToEnd]
        PictureMask = 'DD/mm/yy'
        TabOrder = 1
        OnChange = eDateFromChange
        OnDblClick = eDateToDblClick
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
    end
    object vtRates: TVirtualStringTree
      Left = 1
      Top = 42
      Width = 507
      Height = 366
      Align = alClient
      Header.AutoSizeIndex = -1
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.MainColumn = 1
      Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
      Header.ParentFont = True
      Header.Style = hsXPStyle
      ParentBackground = False
      PopupMenu = PopupMenu1
      TabOrder = 1
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
      OnColumnDblClick = vtRatesColumnDblClick
      OnContextPopup = vtRatesContextPopup
      OnFocusChanged = vtRatesFocusChanged
      OnHeaderDragging = vtRatesHeaderDragging
      Columns = <
        item
          Position = 0
          WideText = 'State'
        end
        item
          Position = 1
          Width = 100
          WideText = 'ISO Code'
        end
        item
          Position = 2
          Width = 353
          WideText = 'Rate'
        end>
    end
  end
  object ActionList1: TActionList
    Images = AppImages.ilFileActions_ClientMgr
    Left = 64
    Top = 232
    object acImport: TAction
      Caption = 'Import'
      ImageIndex = 19
      OnExecute = acImportExecute
    end
    object acLock: TAction
      Caption = 'Lock'
      ImageIndex = 2
      OnExecute = acLockExecute
    end
    object acUnlock: TAction
      Caption = 'Unlock'
      ImageIndex = 5
      OnExecute = acUnlockExecute
    end
    object acAddExchangeRate: TAction
      Caption = '&Add'
      ImageIndex = 12
      OnExecute = acAddExchangeRateExecute
    end
    object acEditExchangeRate: TAction
      Caption = '&Edit'
      ImageIndex = 17
      OnExecute = acEditExchangeRateExecute
    end
  end
  object ReloadTimer: TTimer
    Enabled = False
    OnTimer = ReloadTimerTimer
    Left = 64
    Top = 296
  end
  object PopupMenu1: TPopupMenu
    Left = 64
    Top = 264
    object miSetForWholeMonth: TMenuItem
      Caption = 'Set for whole month'
      OnClick = miSetForWholeMonthClick
    end
  end
end
