object FundSelectionFrm: TFundSelectionFrm
  Left = 0
  Top = 0
  ActiveControl = edtSearch
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Select a Fund'
  ClientHeight = 604
  ClientWidth = 910
  Color = clWindow
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
  object pnlBottom: TPanel
    Left = 0
    Top = 563
    Width = 910
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 2
    DesignSize = (
      910
      41)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 910
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 788
    end
    object btnYes: TButton
      Left = 738
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
      Left = 827
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = '&Cancel'
      TabOrder = 1
      OnClick = btnNoClick
    end
  end
  object pnlSearch: TPanel
    Left = 0
    Top = 0
    Width = 910
    Height = 37
    Align = alTop
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 910
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
      Width = 910
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
  object pnlGridContainer: TPanel
    Left = 0
    Top = 37
    Width = 910
    Height = 526
    Margins.Left = 10
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object sgFunds: TStringGrid
      Left = 0
      Top = 0
      Width = 910
      Height = 526
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      ColCount = 3
      Ctl3D = False
      DefaultColWidth = 10
      DefaultRowHeight = 22
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowSelect, goThumbTracking]
      ParentCtl3D = False
      TabOrder = 0
      OnDblClick = sgFundsDblClick
      OnDrawCell = sgFundsDrawCell
      OnMouseUp = sgFundsMouseUp
      ColWidths = (
        164
        514
        204)
    end
  end
end
