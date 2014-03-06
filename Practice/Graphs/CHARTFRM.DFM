object frmChart: TfrmChart
  Left = 255
  Top = 164
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Graph Output'
  ClientHeight = 566
  ClientWidth = 792
  Color = clBtnFace
  Constraints.MinWidth = 450
  ParentFont = True
  OldCreateOrder = False
  Scaled = False
  WindowState = wsMaximized
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lblTitle: TLabel
    Left = 0
    Top = 0
    Width = 792
    Height = 24
    Align = alTop
    Alignment = taCenter
    Caption = 'BANKLINK GRAPH'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 162
  end
  object lblGST: TLabel
    Left = 0
    Top = 24
    Width = 792
    Height = 13
    Align = alTop
    Alignment = taCenter
    Caption = 'INCLUDING GST'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 84
  end
  object lblBudget: TLabel
    Left = 0
    Top = 37
    Width = 792
    Height = 13
    Align = alTop
    Alignment = taCenter
    Caption = 'Using Budget:'
    ExplicitWidth = 67
  end
  object Panel1: TPanel
    Left = 0
    Top = 492
    Width = 792
    Height = 74
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      792
      74)
    object BInclude: TBevel
      Left = 8
      Top = 4
      Width = 540
      Height = 29
    end
    object lInclude: TLabel
      Left = 16
      Top = 10
      Width = 42
      Height = 13
      Caption = 'Include :'
    end
    object btnPreview: TButton
      Left = 8
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Pre&view'
      Default = True
      TabOrder = 2
      OnClick = btnPreviewClick
    end
    object btnPrint: TButton
      Left = 617
      Top = 40
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Print'
      TabOrder = 4
      OnClick = btnPrintClick
    end
    object btnCancel: TButton
      Left = 698
      Top = 40
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 5
      OnClick = btnCancelClick
    end
    object chLastYear: TCheckBox
      Left = 70
      Top = 9
      Width = 74
      Height = 17
      Caption = 'Last Year'
      Checked = True
      Color = clBtnFace
      ParentColor = False
      State = cbChecked
      TabOrder = 0
      OnClick = chLastYearClick
    end
    object chBudget: TCheckBox
      Left = 150
      Top = 9
      Width = 74
      Height = 17
      Caption = 'Budget'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = chLastYearClick
    end
    object btnFile: TButton
      Left = 89
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Fil&e'
      TabOrder = 3
      OnClick = btnFileClick
    end
    object ChSales: TCheckBox
      Left = 230
      Top = 9
      Width = 64
      Height = 17
      Caption = 'Sales'
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = chLastYearClick
    end
    object ChNett: TCheckBox
      Left = 300
      Top = 9
      Width = 117
      Height = 17
      Caption = 'Operating Profit'
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = chLastYearClick
    end
    object ChGross: TCheckBox
      Left = 436
      Top = 9
      Width = 101
      Height = 17
      Caption = 'Gross Profit'
      Checked = True
      State = cbChecked
      TabOrder = 8
      OnClick = chLastYearClick
    end
  end
  object Chart1: TChart
    Left = 0
    Top = 50
    Width = 792
    Height = 442
    BackWall.Brush.Color = clWhite
    Border.Visible = True
    Gradient.EndColor = clNavy
    LeftWall.Brush.Color = clWhite
    LeftWall.Brush.Style = bsClear
    Legend.Alignment = laBottom
    Legend.LegendStyle = lsSeries
    Title.Font.Color = clBlack
    Title.Text.Strings = (
      '')
    BottomAxis.DateTimeFormat = 'd/MM/yy'
    BottomAxis.Increment = 60.000000000000000000
    BottomAxis.LabelsAngle = 90
    Chart3DPercent = 20
    CustomAxes = <
      item
        Horizontal = False
        OtherSide = False
      end>
    LeftAxis.Increment = 100.000000000000000000
    LeftAxis.LabelStyle = talValue
    LeftAxis.Title.Caption = 'Dollars ($)'
    View3D = False
    View3DOptions.Elevation = 360
    View3DOptions.Orthogonal = False
    View3DOptions.Rotation = 360
    View3DOptions.VertOffset = -20
    View3DOptions.Zoom = 97
    Align = alClient
    BevelOuter = bvNone
    Color = clWindow
    TabOrder = 1
    PrintMargins = (
      15
      22
      15
      22)
    object Series4: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Length = 20
      Marks.Visible = False
      DataSource = Series3
      SeriesColor = clBlack
      ShowInLegend = False
      Title = 'Lables'
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      object TeeFunction1: TSubtractTeeFunction
      end
    end
    object Series11: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Visible = False
      DataSource = Series3
      SeriesColor = clBlack
      ShowInLegend = False
      Title = 'Label2'
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRectangle
      Pointer.Visible = False
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      object TeeFunction2: TSubtractTeeFunction
      end
    end
    object Series3: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Visible = False
      SeriesColor = clBlue
      Title = 'A'
      LinePen.Color = clBlue
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psTriangle
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        00190000000000000000507E400000000000487C400000000000B87F40000000
        0000087B400000000000E080400000000000E080400000000000CC8040000000
        0000B87F4000000000005C8240000000000014844000000000002C8540000000
        00006C81400000000000507E4000000000003878400000000000D87840000000
        0000C07C400000000000B0784000000000008076400000000000387340000000
        00009075400000000000487C400000000000D878400000000000107340000000
        00004872400000000000007940}
    end
    object Series2: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Length = 0
      Marks.Visible = False
      SeriesColor = clGreen
      Title = 'B'
      LinePen.Color = clGreen
      LinePen.Width = 2
      Pointer.HorizSize = 3
      Pointer.InflateMargins = True
      Pointer.Pen.Style = psDash
      Pointer.Style = psRectangle
      Pointer.VertSize = 3
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        00190000009999999999A1724066666666E60174406666666666B67740000000
        0080A4744066666666E63D78400000000080EF79403333333333717640999999
        9999CE754066666666666B7240CCCCCCCCCC6D6D40CCCCCCCCCCD76240666666
        66664D604000000000001D64403333333333AD6A40CDCCCCCCCCD76240CDCCCC
        CCCC0456403433333333CB4C400000000000F0604033333333338F6840666666
        66664D6040FFFFFFFFFFA35D4064666666667A4340A399999999192B409C9999
        9999A142400100000000A45D40}
    end
    object Series1: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Style = smsLabelPercent
      Marks.Visible = False
      Title = 'C'
      LinePen.Color = clRed
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psCircle
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        0019000000CDCCCCCC4C047F403333333333F87F409A999999190B8140CDCCCC
        CC4C4181409A99999959E58240CDCCCCCC8C398540CDCCCCCC8C1B8340333333
        33B39E8040CDCCCCCC0C8581400000000040D9834033333333F3698140999999
        99D96C8340CCCCCCCCCCD782403233333373F1814065666666A6458440FFFFFF
        FFBF7E8640FFFFFFFF3F15884032333333B30788409899999919928A40323333
        3373878C403233333373878C4065666666661F8F409899999999558F40FEFFFF
        FF7F2B8E40CCCCCCCC4C329040}
    end
    object Series5: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Visible = False
      SeriesColor = clBlue
      Title = 'D'
      Brush.Style = bsFDiagonal
      LineBrush = bsFDiagonal
      LinePen.Color = clBlue
      LinePen.Style = psDot
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psDownTriangle
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        0019000000263108ACFC2178400F5839B4C8357B40BB749318447A7D40F1D24D
        62B0AE80406791ED7CBFBE7F40EA51B81E65B97A4003560E2DE2EC80401D85EB
        5188A68440656666669638824090ED7C3FB5C982405FE5D022DB2382400B022B
        875668844090ED7C3FB5C9824009D7A3709D0181405A8FC2F548957F40C54B37
        89013D7A40966E1283E0FD7C40C0CAA145D60880408A6CE7FB69D47C405739B4
        C8D6C7784059643BDF8F2E7C407E6ABC74F3AA7C407E6ABC74F3AA7C40EB51B8
        1EF59980406791ED7CBFBE7F40}
    end
    object Series6: TLineSeries
      Depth = 0
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Length = 0
      Marks.Visible = False
      SeriesColor = clGreen
      Title = 'E'
      LinePen.Color = clGreen
      LinePen.Style = psDot
      LinePen.Width = 2
      Pointer.HorizSize = 3
      Pointer.InflateMargins = True
      Pointer.Style = psCross
      Pointer.VertSize = 3
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        0019000000BB749318447A6D4090ED7C3FB5C972403E355EBAE974784053E3A5
        9B64FA71408A6CE7FB69D46C40D478E92631CD6D408616D9CEF7067640716891
        ED7C817C40DE4F8D977E7080400B022B87566884403008AC1CBAE484408A6CE7
        FBF9B482408616D9CEF7068640BB749318D45A83404C621058A9E581403E60E5
        D0A2DB7B40A0703D0A57277D40CD22DBF9BEFF7640E77C3F351E206E40F0FDD4
        78691574401FDBF97E8A547140991A2FDDE45966408EED7C3FB5C97240210681
        9543BB744030894160E5186F40}
    end
    object Series7: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Style = smsLabelPercent
      Marks.Visible = False
      SeriesColor = clRed
      Title = 'F'
      LinePen.Color = clRed
      LinePen.Style = psDot
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psDiagCross
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        00190000006791ED7C4F9F8540E2A59BC4F03D87403689416075F98440989999
        9929458640540E2DB21D6185402DDD2406017E8140D9F97E6A7CC28340E3D022
        DB39858040E3D022DB39858040706891ED0C6282407C6ABC74838B8240A1703D
        0AE70783404B621058A9E5814055643BDF8F2E7C40D824068135297740258716
        D96EEF7E40FBD478E926D88040926E1283E0FD7C40568FC2F548957F409AEFA7
        C62BF3824007D7A3709D018140CACCCCCC4C3280405F3BDF4F4DF178400B5839
        B4C8357B40450C022BA7377540}
    end
    object Series8: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Visible = False
      SeriesColor = clBlue
      Title = 'G'
      LinePen.Color = clBlue
      LinePen.Style = psDashDotDot
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psDiamond
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        00190000001183C0CA819C7E40D478E92631CD7D40AB1C5A645B837640E5D022
        DB39857040C2F5285C8F6F73401E85EB51F8C56E40058195430B736E4022DBF9
        7E8A5471407C3F355E3A447940CCCCCCCC4C3280404160E5D032BC81401E85EB
        51F8C57E40A145B6F39DC07940C64B3789911D8040355EBA49BC928140666666
        6606587C400C022B87566874407D3F355E3A4469408B6CE7FB69D46C40F853E3
        A5DBE26A4079E92631C8767240DBF97E6A7CC273403D0AD7A3300E7540F753E3
        A5DBE27A40550E2DB21D617540}
    end
    object Series10: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Callout.Length = 0
      Marks.Visible = False
      SeriesColor = clGreen
      Title = 'H'
      LinePen.Color = clGreen
      LinePen.Style = psDashDotDot
      LinePen.Width = 2
      Pointer.HorizSize = 3
      Pointer.InflateMargins = True
      Pointer.Style = psLeftTriangle
      Pointer.VertSize = 3
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        001900000061105839948A75409E1A2FDDE4597640192FDD2486F87740C320B0
        7248D67640D14D621078667A40E4D022DB39858040D8CEF753C35B8040BA7493
        18447A7D40418B6CE75B427F406466666606587C40FEFFFFFFDF3E7440493789
        41609E68406491ED7CBFBE5F40CE22DBF9BEFF66405EE5D022DB2362403B0AD7
        A3300E654049378941609E6840AA47E17A14EA5940E3D022DB398560400D5839
        B4C8356B40D7CEF753C35B704044E17A14EED06140095839B4C8355B40D02631
        08AC523740DC263108AC524740}
    end
    object Series9: TLineSeries
      Marks.Callout.Brush.Color = clBlack
      Marks.Style = smsLabelPercent
      Marks.Visible = False
      SeriesColor = clRed
      Title = 'I'
      LinePen.Color = clRed
      LinePen.Style = psDashDot
      LinePen.Width = 2
      Pointer.InflateMargins = True
      Pointer.Style = psRightTriangle
      Pointer.Visible = True
      XValues.Name = 'X'
      XValues.Order = loAscending
      YValues.Name = 'Y'
      YValues.Order = loNone
      Data = {
        0019000000012B871699A577406CE7FBA9514D72406E1283C00AB46540388941
        60E5184F40BFF5285C8F6F4340B247E17A14EA39405AE5D022DB233240A247E1
        7A14EA29402206819543BB5440DC4F8D97EE8F5A400A022B8756686440318941
        60E5184F4033894160E5185F408FED7C3FB5C9624031333333734B68400E5839
        B4C8356B40AB47E17A14EA5940D078E92631CD4D400C5839B4C8354B40E52631
        08AC524740DC4F8D97EE8F5A40F1FDD47869155440ED05819543BB0440348941
        60E5185F4046E17A14EED06140}
    end
  end
end
