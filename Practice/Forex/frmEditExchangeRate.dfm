object EditExchangeRateForm: TEditExchangeRateForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit Exchange Rates'
  ClientHeight = 287
  ClientWidth = 250
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pButtons: TPanel
    Left = 0
    Top = 246
    Width = 250
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitTop = 273
    ExplicitWidth = 278
    DesignSize = (
      250
      41)
    object btnCancel: TButton
      Left = 164
      Top = 8
      Width = 77
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
      ExplicitLeft = 192
    end
    object BtnoK: TButton
      Left = 84
      Top = 8
      Width = 77
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 1
      ExplicitLeft = 112
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 250
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 278
    object btnQuik: TSpeedButton
      Left = 116
      Top = 9
      Width = 23
      Height = 27
      OnClick = btnQuikClick
    end
    object eDate: TOvcPictureField
      Left = 5
      Top = 12
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
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
  end
  object vtRates: TVirtualStringTree
    Left = 0
    Top = 41
    Width = 250
    Height = 205
    Align = alClient
    Header.AutoSizeIndex = 1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoAutoResize, hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
    ParentBackground = False
    TabOrder = 2
    TreeOptions.MiscOptions = [toAcceptOLEDrop, toEditable, toFullRepaintOnResize, toInitOnSave, toWheelPanning]
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect, toRightClickSelect]
    OnClick = vtRatesClick
    OnCreateEditor = vtRatesCreateEditor
    OnEditing = vtRatesEditing
    OnNewText = vtRatesNewText
    ExplicitHeight = 96
    Columns = <
      item
        Options = [coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Width = 125
        WideText = 'Currency'
      end
      item
        Position = 1
        Tag = 1
        Width = 121
        WideText = 'Rate'
      end>
  end
end
