object CurrenciesFrm: TCurrenciesFrm
  Left = 0
  Top = 0
  Caption = 'Maintain Currencies'
  ClientHeight = 398
  ClientWidth = 721
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 160
    Top = 0
    Height = 357
    ExplicitTop = -29
    ExplicitHeight = 393
  end
  object pButtons: TPanel
    Left = 0
    Top = 357
    Width = 721
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      721
      41)
    object btnCancel: TButton
      Left = 635
      Top = 8
      Width = 77
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object BtnoK: TButton
      Left = 555
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
    Height = 357
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
          Action = acAdd
          ImageIndex = 12
        end
        item
          Action = acDelete
        end
        item
          Caption = '-'
        end
        item
          Action = acISOCurrencyCodes
        end>
      Opened = True
      OpenedHeight = 124
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
  object Panel1: TPanel
    Left = 163
    Top = 0
    Width = 558
    Height = 357
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 2
    object vtCurrencies: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 556
      Height = 355
      Align = alClient
      Header.AutoSizeIndex = 1
      Header.Font.Charset = DEFAULT_CHARSET
      Header.Font.Color = clWindowText
      Header.Font.Height = -11
      Header.Font.Name = 'Tahoma'
      Header.Font.Style = []
      Header.Options = [hoAutoResize, hoShowSortGlyphs, hoVisible]
      Header.ParentFont = True
      Header.SortColumn = 0
      Header.Style = hsXPStyle
      ParentBackground = False
      TabOrder = 0
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
      OnCreateEditor = vtCurrenciesCreateEditor
      OnEditing = vtCurrenciesEditing
      OnHeaderClick = vtCurrenciesHeaderClick
      OnKeyDown = vtCurrenciesKeyDown
      OnNewText = vtCurrenciesNewText
      Columns = <
        item
          MaxWidth = 500
          MinWidth = 130
          Position = 0
          Tag = 1
          Width = 145
          WideText = 'ISO Currency Code'
        end
        item
          Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
          Position = 1
          Tag = 2
          Width = 276
          WideText = 'Currency'
        end
        item
          Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
          Position = 2
          Tag = 3
          Width = 135
          WideText = 'Type'
        end>
    end
  end
  object ActionList1: TActionList
    Images = AppImages.ilFileActions_ClientMgr
    Left = 48
    Top = 136
    object acDelete: TAction
      Caption = 'Remove'
      ImageIndex = 35
      OnExecute = acDeleteExecute
    end
    object acAdd: TAction
      Caption = 'Add'
      OnExecute = acAddExecute
    end
    object acISOCurrencyCodes: TAction
      Caption = 'ISO Currency Code List'
      ImageIndex = 38
      OnExecute = acISOCurrencyCodesExecute
    end
  end
end
