object SelectBusinessForm: TSelectBusinessForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Select a Business'
  ClientHeight = 514
  ClientWidth = 830
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlGridContainer: TPanel
    Left = 0
    Top = 37
    Width = 830
    Height = 436
    Margins.Left = 10
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 832
    ExplicitHeight = 437
    object sgClients: TStringGrid
      Left = 0
      Top = 0
      Width = 830
      Height = 436
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 10
      DefaultRowHeight = 22
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowSelect, goThumbTracking]
      ParentCtl3D = False
      ScrollBars = ssVertical
      TabOrder = 0
      OnDblClick = sgClientsDblClick
      OnDrawCell = sgClientsDrawCell
      OnMouseUp = sgClientsMouseUp
      ExplicitTop = -3
      ExplicitWidth = 925
      ExplicitHeight = 437
      ColWidths = (
        336
        186
        144
        145)
    end
  end
  object pnlSearch: TPanel
    Left = 0
    Top = 0
    Width = 830
    Height = 37
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 1
    ExplicitWidth = 832
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 830
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 788
    end
    object lblFind: TLabel
      Left = 11
      Top = 9
      Width = 20
      Height = 13
      Caption = 'Find'
    end
    object ShapeBorderTop: TShape
      Left = 0
      Top = 36
      Width = 830
      Height = 1
      Align = alBottom
      Pen.Color = clSilver
      ExplicitTop = -24
      ExplicitWidth = 808
    end
    object edtSearch: TEdit
      Left = 48
      Top = 8
      Width = 241
      Height = 21
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      TabOrder = 0
      Text = ' '
      OnChange = edtSearchChange
    end
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 473
    Width = 830
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 2
    ExplicitTop = 474
    ExplicitWidth = 832
    DesignSize = (
      830
      41)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 830
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 788
    end
    object btnYes: TButton
      Left = 666
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      TabOrder = 0
      OnClick = btnYesClick
    end
    object btnNo: TButton
      Left = 747
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = '&Cancel'
      TabOrder = 1
      OnClick = btnNoClick
      ExplicitLeft = 749
    end
  end
end
