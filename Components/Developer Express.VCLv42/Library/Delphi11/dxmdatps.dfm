object frmdxMemDataPersistent: TfrmdxMemDataPersistent
  Left = 403
  Top = 251
  AutoScroll = False
  Caption = 'ExpressMemData Persistent Editor...'
  ClientHeight = 336
  ClientWidth = 471
  Color = clBtnFace
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 16
  object pnlBottom: TPanel
    Left = 0
    Top = 294
    Width = 471
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnClear: TButton
      Left = 30
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Clear'
      TabOrder = 0
      OnClick = btnClearClick
    end
    object btnLoad: TButton
      Left = 118
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Load...'
      TabOrder = 1
      OnClick = btnLoadClick
    end
    object btnSave: TButton
      Left = 206
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Save...'
      TabOrder = 2
      OnClick = btnSaveClick
    end
    object btnOK: TButton
      Left = 294
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&OK'
      ModalResult = 1
      TabOrder = 3
    end
    object btnCancel: TButton
      Left = 382
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 4
    end
  end
  object DBGrid: TDBGrid
    Left = 0
    Top = 0
    Width = 471
    Height = 294
    Align = alClient
    DataSource = DataSource
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgMultiSelect]
    TabOrder = 1
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -13
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
  end
  object DataSource: TDataSource
    DataSet = InternalMemData
    Left = 88
    Top = 72
  end
  object InternalMemData: TdxMemData
    Indexes = <>
    SortOptions = []
    Left = 48
    Top = 48
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '*.dat'
    Filter = 'MemData Files|*.dat|All Files|*.*'
    Left = 224
    Top = 176
  end
  object SaveDialog: TSaveDialog
    DefaultExt = '*.dat'
    Filter = 'MemData Files|*.dat|All Files|*.*'
    Left = 248
    Top = 168
  end
end
