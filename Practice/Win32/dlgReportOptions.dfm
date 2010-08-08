object ReportOptionDlg: TReportOptionDlg
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Report And Graph Options'
  ClientHeight = 526
  ClientWidth = 784
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 700
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object pBtn: TPanel
    Left = 0
    Top = 485
    Width = 784
    Height = 41
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      784
      41)
    object btnCancel: TButton
      Left = 699
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
    object btnOk: TButton
      Left = 619
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      Default = True
      TabOrder = 1
      OnClick = btnOkClick
    end
    object btnPreview: TButton
      Left = 10
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Pre&view'
      TabOrder = 0
      OnClick = btnPreviewClick
    end
  end
  object pFooter: TPanel
    Left = 0
    Top = 442
    Width = 784
    Height = 43
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      784
      43)
    object lh2: TLabel
      Left = 7
      Top = 2
      Width = 74
      Height = 13
      Caption = 'Common Footer'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object Bevel1: TBevel
      Left = 101
      Top = 6
      Width = 679
      Height = 8
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
      ExplicitWidth = 687
    end
    object cbRptClientCode: TCheckBox
      Left = 41
      Top = 20
      Width = 97
      Height = 17
      Caption = 'Cli&ent Code'
      TabOrder = 0
    end
    object cbRptPageNo: TCheckBox
      Left = 284
      Top = 17
      Width = 105
      Height = 17
      Caption = 'Page &numbers'
      TabOrder = 1
    end
    object cbRptPrinted: TCheckBox
      Left = 509
      Top = 17
      Width = 94
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Printed &date'
      TabOrder = 2
    end
    object cbRptTime: TCheckBox
      Left = 609
      Top = 17
      Width = 55
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Ti&me'
      TabOrder = 3
    end
    object cbRptUser: TCheckBox
      Left = 692
      Top = 17
      Width = 52
      Height = 17
      Anchors = [akTop, akRight]
      Caption = '&User'
      TabOrder = 4
    end
  end
  object PReport: TPanel
    Left = 0
    Top = 29
    Width = 784
    Height = 100
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lStyle: TLabel
      Left = 41
      Top = 65
      Width = 28
      Height = 13
      Caption = 'St&yle:'
      FocusControl = cbStyles
    end
    object tcReportType: TTabControl
      Left = 0
      Top = 0
      Width = 784
      Height = 25
      Align = alTop
      TabOrder = 0
      Tabs.Strings = (
        'Financial'
        'Coding'
        'Ledger'
        'GST'
        'Listings'
        'Other'
        'Graphs')
      TabIndex = 0
      TabWidth = 65
      OnChange = tcReportTypeChange
    end
    object CBRounded: TCheckBox
      Left = 41
      Top = 31
      Width = 173
      Height = 25
      Caption = '&Show rounded values '
      TabOrder = 1
    end
    object cbAccountPage: TCheckBox
      Left = 40
      Top = 31
      Width = 508
      Height = 25
      Caption = '&Start a new page for each bank account '
      TabOrder = 2
      WordWrap = True
    end
    object cbStyles: TComboBox
      Left = 80
      Top = 62
      Width = 207
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      Sorted = True
      TabOrder = 3
    end
    object btnStyle: TButton
      Left = 293
      Top = 61
      Width = 22
      Height = 25
      Caption = '...'
      TabOrder = 4
      OnClick = btnStyleClick
    end
  end
  object TopToolbar: TRzToolbar
    Left = 0
    Top = 0
    Width = 784
    Height = 29
    ButtonWidth = 60
    ShowButtonCaptions = True
    TextOptions = ttoSelectiveTextOnRight
    BorderInner = fsNone
    BorderOuter = fsGroove
    BorderSides = [sdTop]
    BorderWidth = 0
    GradientColorStyle = gcsMSOffice
    TabOrder = 0
    VisualStyle = vsGradient
    ToolbarControls = (
      BtnCopy
      BtnPaste)
    object BtnCopy: TRzToolButton
      Left = 4
      Top = 2
      ImageIndex = 3
      Images = Editor.ActImages
      Caption = 'Copy'
      OnClick = BtnCopyClick
    end
    object BtnPaste: TRzToolButton
      Left = 64
      Top = 2
      ImageIndex = 4
      Images = Editor.ActImages
      Caption = 'Paste'
      Enabled = False
      OnClick = BtnPasteClick
    end
  end
  object PHeaderFooter: TPanel
    Left = 0
    Top = 129
    Width = 784
    Height = 313
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 4
    object TcSection: TTabControl
      Left = 0
      Top = 49
      Width = 784
      Height = 25
      Align = alTop
      TabOrder = 0
      Tabs.Strings = (
        'Header '
        'Footer'
        'Different header first page'
        'Different footer last page')
      TabIndex = 0
      OnChange = TcSectionChange
    end
    inline Editor: TfmeEditRTF
      Left = 0
      Top = 74
      Width = 784
      Height = 239
      Align = alClient
      TabOrder = 1
      ExplicitTop = 74
      ExplicitWidth = 784
      ExplicitHeight = 239
      inherited Panel1: TPanel
        Width = 784
        Height = 239
        ExplicitWidth = 784
        ExplicitHeight = 239
        inherited WPToolPanel1: TWPToolPanel
          Width = 782
          ExplicitWidth = 782
          inherited TopToolbar: TRzToolbar
            Width = 780
            ExplicitWidth = 780
            ToolbarControls = (
              cbFont
              cbSize
              cbColor
              cbBackGround
              btnBold
              btnItalic
              btnUnderline
              RzSpacer1
              BtnLeftJustify
              BtnCenterJustify
              btnJustified
              BtnRightJustify
              RzSpacer2
              BtnUndo
              RzSpacer4
              BtnCut
              BtnCopy
              Btnpaste
              btnDelete
              RzSpacer3
              BtnFind
              BtnReplace)
          end
        end
        inherited ERTF: TWPRichText
          Width = 756
          Height = 177
          RTFText.Data = {
            3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
            617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
            43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
            733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
            6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
            50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
            65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
            64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
            54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
            6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
            707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
            543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
            5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
            756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
            74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
            756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
            3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
            3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
            3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
            6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
            3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
            33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
            74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
            36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
            0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
            3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
            652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
            6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
            2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
            4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
            3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
            303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
            6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
            3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
            6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
            7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
            3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
            696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
            44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
            7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
            6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
            724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
            3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
            54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
            6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
            494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
            67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
            64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
            626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
            31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
            724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
            4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
            643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
            6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
            393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
            652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
            5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
            262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
            74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
            793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
            393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
            3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
            69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
            756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
            33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
            6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
            332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
            4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
            756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
            454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
            75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
            313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
            54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
            36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
            6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
            62657254455854413A262333393B29262333393B3B4E756D6265725445585442
            3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
            2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
            3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
            686172466F6E743A262333393B417269616C262333393B3B43686172466F6E74
            53697A653A313130303B5D5D2F3E3C6469762063733D313E3C63206E723D312F
            3E3435363334353C2F6469763E0D0A}
          Header.DefaultPageWidth = 11350
          Header.PageWidth = 11350
          TabOrder = 3
          ExplicitWidth = 756
          ExplicitHeight = 177
        end
        inherited LeftRuler: TWPVertRuler
          Height = 177
          ExplicitHeight = 177
        end
        inherited TopRuler: TWPRuler
          Width = 782
          ExplicitWidth = 782
        end
      end
    end
    object pHFTop: TPanel
      Left = 0
      Top = 0
      Width = 784
      Height = 49
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      DesignSize = (
        784
        49)
      object Bevel2: TBevel
        Left = 101
        Top = 6
        Width = 683
        Height = 8
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
        ExplicitWidth = 746
      end
      object lh1: TLabel
        Left = 5
        Top = 1
        Width = 76
        Height = 13
        Caption = 'Header / Footer'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object ChkHFEnabled: TCheckBox
        Left = 41
        Top = 20
        Width = 122
        Height = 17
        Caption = 'Use by default'
        TabOrder = 0
      end
    end
  end
  object OpenPictureDlg: TOpenPictureDialog
    Filter = 'Bitmaps (*.bmp)|*.bmp'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 348
  end
end
