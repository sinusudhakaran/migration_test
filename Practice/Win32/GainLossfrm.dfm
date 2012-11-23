object frmGainLoss: TfrmGainLoss
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Exchange Gains/Losses'
  ClientHeight = 390
  ClientWidth = 596
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    596
    390)
  PixelsPerInch = 96
  TextHeight = 13
  object lblMonthEndDate1: TLabel
    Left = 8
    Top = 8
    Width = 267
    Height = 13
    Caption = 'Foreign Exchange Gains or Losses for the month ending'
  end
  object tbPrevious: TRzToolButton
    Left = 423
    Top = 6
    Width = 81
    ImageIndex = 1
    Images = AppImages.Misc
    ShowCaption = True
    Transparent = False
    UseToolbarButtonLayout = False
    UseToolbarButtonSize = False
    UseToolbarShowCaption = False
    Anchors = [akTop, akRight]
    Caption = '&Back'
    OnClick = tbPreviousClick
    ExplicitLeft = 402
  end
  object tbNext: TRzToolButton
    Left = 511
    Top = 6
    Width = 81
    ImageIndex = 2
    Images = AppImages.Misc
    Layout = blGlyphRight
    ShowCaption = True
    Transparent = False
    UseToolbarButtonLayout = False
    UseToolbarButtonSize = False
    UseToolbarShowCaption = False
    Anchors = [akTop, akRight]
    Caption = '&Forward'
    OnClick = tbNextClick
    ExplicitLeft = 490
  end
  object lblMonthEndDate2: TLabel
    Left = 281
    Top = 8
    Width = 39
    Height = 13
    Caption = '[DATE]'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object tgGainLoss: TtsGrid
    Left = 0
    Top = 36
    Width = 597
    Height = 303
    AlwaysShowScrollBar = ssVertical
    Anchors = [akLeft, akTop, akRight, akBottom]
    CellSelectMode = cmNone
    CheckBoxStyle = stCheck
    ColMoving = False
    Cols = 5
    ColSelectMode = csNone
    Ctl3D = True
    DefaultRowHeight = 21
    ExportDelimiter = ','
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    GridLines = glVertLines
    GridMode = gmBrowse
    HeadingFont.Charset = ANSI_CHARSET
    HeadingFont.Color = clWindowText
    HeadingFont.Height = -13
    HeadingFont.Name = 'Tahoma'
    HeadingFont.Style = [fsBold]
    HeadingHeight = 20
    HeadingParentFont = False
    ParentCtl3D = False
    ParentFont = False
    ParentShowHint = False
    ResizeCols = rcNone
    ResizeRows = rrNone
    RowBarOn = False
    RowMoving = False
    Rows = 5
    RowSelectMode = rsNone
    ShowHint = False
    TabOrder = 0
    Version = '2.20.26'
    WantTabs = False
    XMLExport.Version = '1.0'
    XMLExport.DataPacketVersion = '2.0'
    OnCellLoaded = tgGainLossCellLoaded
    ColProperties = <
      item
        DataCol = 1
        Col.Heading = ' Account Number'
        Col.HeadingFont.Charset = DEFAULT_CHARSET
        Col.HeadingFont.Color = clWindowText
        Col.HeadingFont.Height = -12
        Col.HeadingFont.Name = 'Tahoma'
        Col.HeadingFont.Style = [fsBold]
        Col.HeadingHorzAlignment = htaLeft
        Col.HeadingParentFont = False
        Col.HeadingVertAlignment = vtaCenter
        Col.ReadOnly = True
        Col.HorzAlignment = htaLeft
        Col.Width = 120
      end
      item
        DataCol = 2
        Col.Heading = ' Account Name'
        Col.HeadingFont.Charset = DEFAULT_CHARSET
        Col.HeadingFont.Color = clWindowText
        Col.HeadingFont.Height = -12
        Col.HeadingFont.Name = 'Tahoma'
        Col.HeadingFont.Style = [fsBold]
        Col.HeadingHorzAlignment = htaLeft
        Col.HeadingParentFont = False
        Col.HeadingVertAlignment = vtaCenter
        Col.ReadOnly = True
        Col.Width = 200
      end
      item
        DataCol = 3
        Col.Heading = ' Account'
        Col.HeadingFont.Charset = DEFAULT_CHARSET
        Col.HeadingFont.Color = clWindowText
        Col.HeadingFont.Height = -12
        Col.HeadingFont.Name = 'Tahoma'
        Col.HeadingFont.Style = [fsBold]
        Col.HeadingHorzAlignment = htaLeft
        Col.HeadingParentFont = False
        Col.HeadingVertAlignment = vtaCenter
        Col.ReadOnly = True
        Col.HorzAlignment = htaLeft
        Col.Width = 80
      end
      item
        DataCol = 4
        Col.Heading = ' Exchange Gain/Loss'
        Col.HeadingFont.Charset = DEFAULT_CHARSET
        Col.HeadingFont.Color = clWindowText
        Col.HeadingFont.Height = -12
        Col.HeadingFont.Name = 'Tahoma'
        Col.HeadingFont.Style = [fsBold]
        Col.HeadingHorzAlignment = htaLeft
        Col.HeadingParentFont = False
        Col.HeadingVertAlignment = vtaCenter
        Col.ReadOnly = True
        Col.HorzAlignment = htaRight
        Col.Width = 150
      end
      item
        DataCol = 5
        Col.HeadingHorzAlignment = htaRight
        Col.ReadOnly = True
        Col.HorzAlignment = htaCenter
        Col.Width = 25
      end>
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 349
    Width = 596
    Height = 41
    Align = alBottom
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 1
    VerticalAlignment = taAlignBottom
    ExplicitLeft = 8
    ExplicitTop = 345
    ExplicitWidth = 580
    object lblEntriesCreatedDate: TLabel
      Left = 5
      Top = 10
      Width = 191
      Height = 13
      Caption = 'The above entries were created [DATE]'
    end
    object btnClose: TButton
      Left = 492
      Top = 7
      Width = 75
      Height = 25
      Caption = 'Close'
      ModalResult = 1
      TabOrder = 0
    end
  end
end
