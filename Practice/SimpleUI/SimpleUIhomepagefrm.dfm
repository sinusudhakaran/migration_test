object frmSimpleUIHomePage: TfrmSimpleUIHomePage
  Left = 0
  Top = 0
  Caption = 'Home'
  ClientHeight = 427
  ClientWidth = 741
  Color = clGray
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  FormStyle = fsMDIChild
  OldCreateOrder = False
  Position = poDefault
  Scaled = False
  Visible = True
  WindowState = wsMaximized
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFrameHolder: TPanel
    Left = 0
    Top = 65
    Width = 741
    Height = 362
    Align = alClient
    BevelOuter = bvNone
    Color = 4802889
    ParentBackground = False
    TabOrder = 0
  end
  object pnlNavigator: TPanel
    Left = 0
    Top = 45
    Width = 741
    Height = 20
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    object lblHome: TLabel
      Left = 5
      Top = 1
      Width = 33
      Height = 16
      Cursor = crHandPoint
      Caption = 'Home'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = lblHomeClick
    end
    object lblNavLevel1: TLabel
      Left = 50
      Top = 1
      Width = 36
      Height = 16
      Cursor = crHandPoint
      Caption = 'Level1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = lblNavLevel1Click
    end
    object lblNavLevel2: TLabel
      Left = 134
      Top = 1
      Width = 36
      Height = 16
      Cursor = crHandPoint
      Caption = 'Level2'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = lblNavLevel1Click
    end
    object lblNavLevel3: TLabel
      Left = 207
      Top = 1
      Width = 36
      Height = 16
      Cursor = crHandPoint
      Caption = 'Level3'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = lblNavLevel1Click
    end
  end
  object pnlExtraTitleBar: TRzPanel
    Left = 0
    Top = 0
    Width = 741
    Height = 45
    Align = alTop
    BorderSides = []
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    GradientColorStyle = gcsCustom
    GradientColorStop = clGray
    ParentFont = False
    TabOrder = 2
    VisualStyle = vsGradient
    object lblClientName: TLabel
      Left = 132
      Top = 3
      Width = 58
      Height = 21
      Caption = 'A Client'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4802889
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      ShowAccelChar = False
      Transparent = True
    end
    object lblCurrentPeriod: TLabel
      Left = 132
      Top = 25
      Width = 237
      Height = 16
      AutoSize = False
      Caption = 'Coding Range 1/1/90 - 12/12/99'
      Color = clActiveCaption
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
    end
    object imgRight: TImage
      Left = 508
      Top = 0
      Width = 233
      Height = 45
      Align = alRight
      Anchors = [akTop, akRight]
      AutoSize = True
      Center = True
      Transparent = True
      ExplicitLeft = 0
      ExplicitHeight = 43
    end
    object imgLeft: TImage
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 123
      Height = 39
      Align = alLeft
      AutoSize = True
      Center = True
      Transparent = True
      ExplicitTop = 0
      ExplicitHeight = 41
    end
  end
end
