object FundSelectionFrm: TFundSelectionFrm
  Left = 0
  Top = 0
  ClientHeight = 477
  ClientWidth = 789
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
    Top = 436
    Width = 789
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    ExplicitWidth = 788
    DesignSize = (
      789
      41)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 789
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 788
    end
    object btnYes: TButton
      Left = 617
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Ok'
      TabOrder = 0
      OnClick = btnYesClick
      ExplicitLeft = 616
    end
    object btnNo: TButton
      Left = 706
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = '&Cancel'
      Default = True
      TabOrder = 1
      OnClick = btnNoClick
      ExplicitLeft = 705
    end
  end
  object sgFunds: TStringGrid
    Left = 0
    Top = 0
    Width = 789
    Height = 436
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    ColCount = 3
    DefaultColWidth = 10
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
    ScrollBars = ssNone
    TabOrder = 1
    ExplicitTop = 1
    ColWidths = (
      220
      172
      367)
  end
end
