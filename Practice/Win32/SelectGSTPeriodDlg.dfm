object dlgSelectGSTPeriod: TdlgSelectGSTPeriod
  Left = 245
  Top = 108
  BorderStyle = bsDialog
  Caption = 'Select GST Period'
  ClientHeight = 301
  ClientWidth = 572
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    572
    301)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 259
    Width = 572
    Height = 42
    Align = alBottom
    Shape = bsSpacer
  end
  object OKBtn: TButton
    Left = 408
    Top = 267
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Vie&w'
    Default = True
    TabOrder = 2
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 489
    Top = 267
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 3
  end
  object lvGSTPeriod: TListView
    Left = 0
    Top = 0
    Width = 572
    Height = 259
    Align = alClient
    BiDiMode = bdLeftToRight
    Columns = <
      item
        Caption = 'Period'
        Width = 250
      end
      item
        Caption = 'Entries Available'
        MinWidth = 150
        Width = 150
      end
      item
        Caption = 'Number Uncoded'
        MinWidth = 150
        Width = 150
      end>
    ColumnClick = False
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ParentBiDiMode = False
    SmallImages = AppImages.Misc
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = lvGSTPeriodChange
    OnDblClick = lvGSTPeriodDblClick
  end
  object btnSave: TBitBtn
    Left = 327
    Top = 267
    Width = 75
    Height = 25
    Caption = 'Sa&ve'
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object btnAdd: TButton
    Left = 8
    Top = 267
    Width = 75
    Height = 25
    Caption = '&Add'
    TabOrder = 4
    OnClick = btnAddClick
  end
  object BtnClear: TButton
    Left = 89
    Top = 267
    Width = 75
    Height = 25
    Caption = '&Clear'
    TabOrder = 5
    OnClick = BtnClearClick
  end
end
