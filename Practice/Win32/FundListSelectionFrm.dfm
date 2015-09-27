object FundSelectionFrm: TFundSelectionFrm
  Left = 0
  Top = 0
  ActiveControl = btnYes
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Select a Fund'
  ClientHeight = 487
  ClientWidth = 788
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
    Top = 446
    Width = 788
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    ExplicitTop = 436
    ExplicitWidth = 789
    DesignSize = (
      788
      41)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 788
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnYes: TButton
      Left = 616
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      TabOrder = 0
      OnClick = btnYesClick
      ExplicitLeft = 617
    end
    object btnNo: TButton
      Left = 705
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = '&Cancel'
      Default = True
      TabOrder = 1
      OnClick = btnNoClick
      ExplicitLeft = 706
    end
  end
  object sgFunds: TStringGrid
    Left = 0
    Top = 0
    Width = 788
    Height = 446
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    ColCount = 3
    DefaultColWidth = 10
    FixedCols = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goRowSelect]
    ScrollBars = ssNone
    TabOrder = 1
    ExplicitWidth = 789
    ExplicitHeight = 436
    ColWidths = (
      220
      172
      367)
  end
end
