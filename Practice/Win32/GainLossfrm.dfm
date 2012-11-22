object frmGainLoss: TfrmGainLoss
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Exchange Gains/Losses'
  ClientHeight = 409
  ClientWidth = 575
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnDestroy = FormDestroy
  OnShow = FormShow
  DesignSize = (
    575
    409)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 12
    Width = 267
    Height = 13
    Caption = 'Foreign Exchange Gains or Losses for the month ending'
  end
  object lblMonthEndDate: TLabel
    Left = 278
    Top = 12
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
  object tbPrevious: TRzToolButton
    Left = 386
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
    ExplicitLeft = 387
  end
  object tbNext: TRzToolButton
    Left = 486
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
    ExplicitLeft = 487
  end
  object Label2: TLabel
    Left = 8
    Top = 352
    Width = 154
    Height = 13
    Caption = 'The above entries were created'
  end
  object lblEntriesCreatedDate: TLabel
    Left = 165
    Top = 352
    Width = 34
    Height = 13
    Caption = '[DATE]'
  end
  object tgGainLoss: TtsGrid
    Left = 0
    Top = 37
    Width = 576
    Height = 310
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
    GridMode = gmBrowse
    HeadingFont.Charset = DEFAULT_CHARSET
    HeadingFont.Color = clWindowText
    HeadingFont.Height = -11
    HeadingFont.Name = 'MS Sans Serif'
    HeadingFont.Style = []
    HeadingHeight = 16
    HeadingParentFont = False
    ParentCtl3D = False
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
        Col.Heading = 'Account Number'
        Col.HeadingFont.Charset = DEFAULT_CHARSET
        Col.HeadingFont.Color = clWindowText
        Col.HeadingFont.Height = -11
        Col.HeadingFont.Name = 'MS Sans Serif'
        Col.HeadingFont.Style = [fsBold]
        Col.HeadingHorzAlignment = htaLeft
        Col.HeadingParentFont = False
        Col.ReadOnly = True
        Col.HorzAlignment = htaLeft
        Col.Width = 120
      end
      item
        DataCol = 2
        Col.Heading = 'Account Name'
        Col.HeadingFont.Charset = DEFAULT_CHARSET
        Col.HeadingFont.Color = clWindowText
        Col.HeadingFont.Height = -11
        Col.HeadingFont.Name = 'MS Sans Serif'
        Col.HeadingFont.Style = [fsBold]
        Col.HeadingHorzAlignment = htaLeft
        Col.HeadingParentFont = False
        Col.ReadOnly = True
        Col.Width = 200
      end
      item
        DataCol = 3
        Col.Heading = 'Account'
        Col.HeadingFont.Charset = DEFAULT_CHARSET
        Col.HeadingFont.Color = clWindowText
        Col.HeadingFont.Height = -11
        Col.HeadingFont.Name = 'MS Sans Serif'
        Col.HeadingFont.Style = [fsBold]
        Col.HeadingHorzAlignment = htaLeft
        Col.HeadingParentFont = False
        Col.ReadOnly = True
        Col.HorzAlignment = htaLeft
        Col.Width = 80
      end
      item
        DataCol = 4
        Col.Heading = 'Exchange Gain/Loss'
        Col.HeadingFont.Charset = DEFAULT_CHARSET
        Col.HeadingFont.Color = clWindowText
        Col.HeadingFont.Height = -11
        Col.HeadingFont.Name = 'MS Sans Serif'
        Col.HeadingFont.Style = [fsBold]
        Col.HeadingHorzAlignment = htaLeft
        Col.HeadingParentFont = False
        Col.ReadOnly = True
        Col.HorzAlignment = htaRight
        Col.Width = 130
      end
      item
        DataCol = 5
        Col.HeadingHorzAlignment = htaRight
        Col.ReadOnly = True
        Col.HorzAlignment = htaCenter
        Col.Width = 25
      end>
  end
  object btnClose: TButton
    Left = 487
    Top = 352
    Width = 75
    Height = 25
    Caption = 'Close'
    ModalResult = 1
    TabOrder = 1
  end
end
