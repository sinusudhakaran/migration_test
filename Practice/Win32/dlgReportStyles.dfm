object ReportStylesDlg: TReportStylesDlg
  Scaled = False
Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Manage Report Styles'
  ClientHeight = 434
  ClientWidth = 566
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 160
    Top = 0
    Height = 393
    ExplicitLeft = 232
    ExplicitTop = 224
    ExplicitHeight = 100
  end
  object RSGroupBar: TRzGroupBar
    Left = 0
    Top = 0
    Height = 393
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
    TabOrder = 0
    object grpStyles: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
          Action = acAddStyle
        end
        item
          Action = acEditStyle
        end
        item
          Action = acRenamestyle
        end
        item
          Action = acDeleteStyle
        end>
      Opened = True
      OpenedHeight = 108
      SmallImages = AppImages.ilFileActions_ClientMgr
      Caption = 'Style Tasks'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
  end
  object pnlLists: TPanel
    Left = 163
    Top = 0
    Width = 403
    Height = 393
    Align = alClient
    Caption = 'pnlLists'
    TabOrder = 1
    ExplicitLeft = 304
    ExplicitWidth = 262
    object vtStyles: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 401
      Height = 391
      Align = alClient
      Header.AutoSizeIndex = 0
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
      TabOrder = 0
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect, toRightClickSelect]
      OnHeaderClick = vtStylesHeaderClick
      OnNewText = vtStylesNewText
      ExplicitWidth = 404
      Columns = <
        item
          Position = 0
          Tag = 1
          Width = 397
          WideText = 'Style Name'
        end>
    end
  end
  object pButtons: TPanel
    Left = 0
    Top = 393
    Width = 566
    Height = 41
    Align = alBottom
    TabOrder = 2
    object btnCancel: TButton
      Left = 481
      Top = 8
      Width = 77
      Height = 25
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object BtnoK: TButton
      Left = 401
      Top = 8
      Width = 77
      Height = 25
      Caption = 'OK'
      TabOrder = 1
      OnClick = BtnoKClick
    end
  end
  object ActionList1: TActionList
    Images = AppImages.ilFileActions_ClientMgr
    Left = 264
    object acAddStyle: TAction
      Caption = '&Add Style'
      ImageIndex = 12
      OnExecute = acAddStyleExecute
    end
    object acEditStyle: TAction
      Caption = '&Edit'
      OnExecute = acEditStyleExecute
    end
    object acRenamestyle: TAction
      Caption = '&Rename'
      OnExecute = acRenamestyleExecute
    end
    object acDeleteStyle: TAction
      Caption = '&Delete'
      ImageIndex = 35
      OnExecute = acDeleteStyleExecute
    end
    object acSimple: TAction
      Caption = 'Set as Si&mple'
    end
  end
end
