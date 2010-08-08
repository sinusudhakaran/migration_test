object ExchangeRatesfrm: TExchangeRatesfrm
  Left = 0
  Top = 0
  Caption = 'Maintain Exchange Rates'
  ClientHeight = 450
  ClientWidth = 672
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 160
    Top = 0
    Height = 409
    ExplicitTop = -65
    ExplicitHeight = 357
  end
  object pButtons: TPanel
    Left = 0
    Top = 409
    Width = 672
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      672
      41)
    object btnCancel: TButton
      Left = 586
      Top = 8
      Width = 77
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object BtnoK: TButton
      Left = 506
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
          Caption = '-'
        end
        item
          Action = acLock
        end
        item
          Action = acUnlock
        end>
      Opened = True
      OpenedHeight = 108
      SmallImages = AppImages.ilFileActions_ClientMgr
      Caption = 'Currency Tasks'
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
    Left = 163
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
      Header.AutoSizeIndex = 1
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
      Header.ParentFont = True
      Header.SortColumn = 0
      Header.Style = hsXPStyle
      ParentBackground = False
      TabOrder = 1
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
      Columns = <
        item
          MaxWidth = 500
          MinWidth = 130
          Position = 0
          Tag = 1
          Width = 130
          WideText = 'ISO Currency Code'
        end
        item
          Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
          Position = 1
          Tag = 2
          Width = 223
          WideText = 'Currency'
        end
        item
          Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
          Position = 2
          Tag = 3
          Width = 150
          WideText = 'Type'
        end>
    end
  end
  object ActionList1: TActionList
    Images = AppImages.ilFileActions_ClientMgr
    Left = 48
    Top = 136
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
  end
  object ReloadTimer: TTimer
    Enabled = False
    OnTimer = ReloadTimerTimer
    Left = 600
    Top = 8
  end
end
