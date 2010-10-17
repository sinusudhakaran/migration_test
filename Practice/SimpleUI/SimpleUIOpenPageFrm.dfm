object frmSimpleUIOpen: TfrmSimpleUIOpen
  Left = 0
  Top = 0
  Caption = 'Open'
  ClientHeight = 495
  ClientWidth = 774
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
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object gpnlButtonHolder: TGridPanel
    Left = 0
    Top = 45
    Width = 774
    Height = 450
    Align = alClient
    Color = 5395026
    ColumnCollection = <
      item
        Value = 33.334999561204380000
      end
      item
        Value = 33.332056440897180000
      end
      item
        Value = 33.332943997898440000
      end>
    ControlCollection = <
      item
        Column = 0
        Control = gbtnOpenLast
        Row = 0
      end
      item
        Column = 1
        Control = gbtnOpenDiff
        Row = 0
      end
      item
        Column = 2
        Control = gbtnCheckIn
        Row = 0
      end
      item
        Column = 0
        Control = gbtnRestore
        Row = 1
      end>
    UseDockManager = False
    ParentBackground = False
    RowCollection = <
      item
        Value = 50.000285745973880000
      end
      item
        Value = 49.999714254026120000
      end>
    TabOrder = 0
    DesignSize = (
      774
      450)
    object gbtnOpenLast: tbkExGlassButton
      Left = 54
      Top = 38
      Width = 150
      Height = 150
      ButtonCaption = 'Open the file that I last used'
      ButtonColor = clLime
      ButtonFontColor = clWhite
      ButtonVertMargin = 0
      ButtonHorizMargin = 0
      LabelFontSize = 12
      LabelHeight = 0
      ParentColor = True
      TabOrder = 0
      Anchors = []
      OnClick = gbtnOpenLastClick
      DesignSize = (
        150
        150)
    end
    object gbtnOpenDiff: tbkExGlassButton
      Left = 311
      Top = 38
      Width = 150
      Height = 150
      ButtonCaption = 'Open a different file'
      ButtonColor = clAqua
      ButtonFontColor = clWhite
      ButtonVertMargin = 0
      ButtonHorizMargin = 0
      LabelFontSize = 8
      LabelHeight = 0
      ParentColor = True
      TabOrder = 1
      Anchors = []
      OnClick = gbtnOpenDiffClick
      DesignSize = (
        150
        150)
    end
    object gbtnCheckIn: tbkExGlassButton
      Left = 569
      Top = 38
      Width = 150
      Height = 150
      ButtonCaption = 'Open a file from my accountant'
      ButtonColor = clTeal
      ButtonFontColor = clWhite
      ButtonVertMargin = 0
      ButtonHorizMargin = 0
      LabelFontSize = 8
      LabelHeight = 0
      ParentColor = True
      TabOrder = 2
      Anchors = []
      OnClick = gbtnCheckInClick
      DesignSize = (
        150
        150)
    end
    object gbtnRestore: tbkExGlassButton
      Left = 1
      Top = 225
      Width = 257
      Height = 224
      ButtonCaption = 'Restore'
      ButtonColor = clMaroon
      ButtonFontColor = clWhite
      ButtonVertMargin = 0
      ButtonHorizMargin = 0
      LabelFontSize = 8
      LabelHeight = 15
      ParentColor = True
      TabOrder = 3
      Align = alClient
      OnClick = gbtnRestoreClick
      DesignSize = (
        257
        224)
    end
  end
  object pnlExtraTitleBar: TRzPanel
    Left = 0
    Top = 0
    Width = 774
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
    TabOrder = 1
    VisualStyle = vsGradient
    object imgRight: TImage
      Left = 541
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
