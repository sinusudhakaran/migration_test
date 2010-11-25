object ImportHist: TImportHist
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'ImportHist'
  ClientHeight = 584
  ClientWidth = 1027
  Color = clBtnFace
  Constraints.MinHeight = 600
  Constraints.MinWidth = 600
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pBtn: TPanel
    Left = 0
    Top = 543
    Width = 1027
    Height = 41
    Align = alBottom
    TabOrder = 0
    ExplicitWidth = 990
    DesignSize = (
      1027
      41)
    object BtnCancel: TButton
      Left = 941
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 904
    end
    object btnOK: TButton
      Left = 853
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&OK'
      TabOrder = 0
      OnClick = btnOKClick
      ExplicitLeft = 816
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 300
    Width = 1027
    Height = 243
    Align = alClient
    BevelInner = bvLowered
    TabOrder = 1
    ExplicitLeft = 264
    ExplicitTop = 296
    ExplicitWidth = 513
    ExplicitHeight = 225
    object PbTitle: TPanel
      Left = 2
      Top = 2
      Width = 1023
      Height = 20
      Margins.Left = 20
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      Alignment = taLeftJustify
      BevelOuter = bvNone
      TabOrder = 0
      object lMappingTitle: TLabel
        Left = 20
        Top = 1
        Width = 117
        Height = 13
        Caption = 'Output column mapping:'
      end
    end
    object PFormat: TPanel
      Left = 2
      Top = 22
      Width = 1023
      Height = 141
      Align = alTop
      AutoSize = True
      BevelOuter = bvNone
      Caption = 'PFormat'
      TabOrder = 1
      ExplicitTop = 27
      object PCFormat: TPageControl
        Left = 0
        Top = 0
        Width = 1023
        Height = 121
        ActivePage = TSNarration
        Align = alTop
        TabOrder = 0
        OnChange = PCFormatChange
        ExplicitLeft = 1
        ExplicitTop = 1
        ExplicitWidth = 1025
        ExplicitHeight = 133
        object TSDate: TTabSheet
          Caption = '&Date'
          ExplicitWidth = 980
          ExplicitHeight = 105
          object Label2: TLabel
            Left = 15
            Top = 10
            Width = 34
            Height = 13
            Caption = 'Format'
          end
          object Label4: TLabel
            Left = 15
            Top = 37
            Width = 35
            Height = 13
            Caption = 'Column'
          end
          object EDate: TEdit
            Left = 83
            Top = 8
            Width = 97
            Height = 21
            ReadOnly = True
            TabOrder = 0
            Text = 'dd/mm/yyyy'
          end
          object cbDate: TComboBox
            Left = 83
            Top = 35
            Width = 300
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 1
            OnChange = cbDateChange
          end
        end
        object TSAmount: TTabSheet
          Caption = '&Amount'
          ImageIndex = 1
          ExplicitWidth = 980
          ExplicitHeight = 105
          object lbAmount: TLabel
            Left = 216
            Top = 10
            Width = 37
            Height = 13
            Caption = 'Amount'
            Visible = False
          end
          object lbAmount2: TLabel
            Left = 216
            Top = 37
            Width = 29
            Height = 13
            Caption = 'Credit'
            Visible = False
          end
          object cbAmount: TComboBox
            Left = 304
            Top = 8
            Width = 300
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 3
            Visible = False
            OnChange = cbAmountChange
          end
          object cbAmount2: TComboBox
            Left = 304
            Top = 35
            Width = 300
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 4
            Visible = False
            OnChange = cbAmountChange
          end
          object cbSign: TCheckBox
            Left = 216
            Top = 64
            Width = 401
            Height = 17
            Caption = 'Re&verse Sign, BankLink expects Deposits to be Negative'
            Checked = True
            State = cbChecked
            TabOrder = 5
            OnClick = cbAmountChange
          end
          object rbDebitCredit: TRadioButton
            Left = 15
            Top = 35
            Width = 153
            Height = 17
            Caption = 'De&bit and Credit'
            TabOrder = 1
            OnClick = rbDebitCreditClick
          end
          object RBSign: TRadioButton
            Left = 15
            Top = 62
            Width = 153
            Height = 17
            Caption = 'Amount and Si&gn'
            TabOrder = 0
            OnClick = RBSignClick
          end
          object rbSingle: TRadioButton
            Left = 15
            Top = 8
            Width = 153
            Height = 18
            Caption = '&Single Amount (Signed)'
            TabOrder = 2
            OnClick = rbSingleClick
          end
        end
        object TSReference: TTabSheet
          Caption = '&Reference'
          ImageIndex = 2
          ExplicitWidth = 980
          ExplicitHeight = 105
          object LColumns: TLabel
            Left = 15
            Top = 10
            Width = 35
            Height = 13
            Caption = 'Column'
          end
          object Label10: TLabel
            Left = 15
            Top = 46
            Width = 313
            Height = 13
            Caption = 
              'Reference is limited to 12 characters, typically a Cheque number' +
              '.'
          end
          object cbRef: TComboBox
            Left = 83
            Top = 8
            Width = 300
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 0
            OnChange = cbRefChange
          end
        end
        object tsAnalysis: TTabSheet
          Caption = 'A&nalysis'
          ImageIndex = 3
          ExplicitWidth = 980
          ExplicitHeight = 105
          object Label3: TLabel
            Left = 15
            Top = 10
            Width = 35
            Height = 13
            Caption = 'Column'
          end
          object Label11: TLabel
            Left = 15
            Top = 46
            Width = 168
            Height = 13
            Caption = 'Analysis is limited to 12 characters.'
          end
          object cbAna: TComboBox
            Left = 83
            Top = 8
            Width = 300
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 0
            OnChange = cbAnaChange
          end
        end
        object TSNarration: TTabSheet
          Caption = 'Narra&tion'
          ImageIndex = 4
          ExplicitWidth = 980
          ExplicitHeight = 105
          object Label5: TLabel
            Left = 15
            Top = 10
            Width = 41
            Height = 13
            Caption = 'Column1'
          end
          object Label6: TLabel
            Left = 15
            Top = 37
            Width = 41
            Height = 13
            Caption = 'Column2'
          end
          object Label7: TLabel
            Left = 15
            Top = 64
            Width = 41
            Height = 13
            Caption = 'Column3'
          end
          object cbNar1: TComboBox
            Left = 83
            Top = 8
            Width = 300
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 0
            OnChange = cbNar1Change
          end
          object cbNar2: TComboBox
            Left = 83
            Top = 35
            Width = 300
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 1
            OnChange = cbNar1Change
          end
          object cbNar3: TComboBox
            Left = 83
            Top = 62
            Width = 300
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 2
            OnChange = cbNar1Change
          end
        end
      end
      object POutfileTitle: TPanel
        Left = 0
        Top = 121
        Width = 1023
        Height = 20
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object lOutputTitle: TLabel
          Left = 20
          Top = 1
          Width = 100
          Height = 13
          Caption = 'Output transactions:'
        end
      end
    end
    object pOut: TPanel
      Left = 2
      Top = 163
      Width = 1023
      Height = 78
      Align = alClient
      BevelOuter = bvNone
      Caption = 'pOut'
      TabOrder = 2
      ExplicitLeft = -477
      ExplicitTop = 85
      ExplicitWidth = 990
      ExplicitHeight = 140
      object vsOut: TVirtualStringTree
        Left = 0
        Top = 0
        Width = 1023
        Height = 78
        Align = alClient
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.Height = 20
        Header.MainColumn = -1
        Header.Options = [hoColumnResize, hoDrag, hoVisible]
        Header.ParentFont = True
        HintMode = hmHint
        ParentBackground = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
        TreeOptions.SelectionOptions = [toFullRowSelect]
        OnBeforeCellPaint = vsOutBeforeCellPaint
        OnChange = vsOutChange
        OnGetText = vsOutGetText
        OnPaintText = vsOutPaintText
        OnGetHint = vsOutGetHint
        OnHeaderClick = vsOutHeaderClick
        ExplicitLeft = 1
        ExplicitTop = 32
        ExplicitWidth = 1025
        ExplicitHeight = 50
        Columns = <>
        WideDefaultText = ''
      end
    end
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 1027
    Height = 300
    Align = alTop
    BevelOuter = bvNone
    Caption = 'pTop'
    TabOrder = 2
    object pFileinput: TPanel
      Left = 0
      Top = 0
      Width = 1027
      Height = 86
      Align = alTop
      TabOrder = 0
      DesignSize = (
        1027
        86)
      object Label1: TLabel
        Left = 15
        Top = 14
        Width = 51
        Height = 13
        Caption = 'Import File'
      end
      object Label9: TLabel
        Left = 15
        Top = 41
        Width = 43
        Height = 13
        Caption = 'Skip lines'
        FocusControl = SkipLine
      end
      object Label12: TLabel
        Left = 789
        Top = 41
        Width = 41
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Delimiter'
        FocusControl = cbDelimiter
        ExplicitLeft = 752
      end
      object lInFileTitle: TLabel
        Left = 15
        Top = 67
        Width = 83
        Height = 13
        Caption = 'Input file content'
      end
      object BTNBrowse: TButton
        Left = 941
        Top = 9
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Bro&wse'
        TabOrder = 0
        OnClick = BTNBrowseClick
        ExplicitLeft = 904
      end
      object EPath: TEdit
        Left = 88
        Top = 11
        Width = 840
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Enabled = False
        TabOrder = 4
        ExplicitWidth = 803
      end
      object chFirstline: TCheckBox
        Left = 184
        Top = 40
        Width = 161
        Height = 17
        Caption = 'Next line is &header line'
        TabOrder = 2
        OnClick = chFirstlineClick
      end
      object SkipLine: TRzSpinEdit
        Left = 88
        Top = 38
        Width = 65
        Height = 21
        AllowKeyEdit = True
        CheckRange = True
        Max = 99.000000000000000000
        TabOrder = 1
        OnChange = SkipLineChange
      end
      object cbDelimiter: TComboBox
        Left = 853
        Top = 38
        Width = 75
        Height = 21
        Style = csDropDownList
        Anchors = [akTop, akRight]
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 3
        Text = ','
        OnChange = cbDelimiterChange
        Items.Strings = (
          ','
          ';'
          '<tab>')
        ExplicitLeft = 816
      end
    end
    object pFile: TPanel
      Left = 0
      Top = 86
      Width = 1027
      Height = 214
      Align = alClient
      Color = clWindow
      ParentBackground = False
      TabOrder = 1
      ExplicitLeft = -764
      ExplicitTop = -63
      ExplicitWidth = 990
      ExplicitHeight = 190
      object lbFile: TLabel
        Left = 1
        Top = 1
        Width = 1025
        Height = 13
        Align = alTop
        Constraints.MaxHeight = 100
        WordWrap = True
        ExplicitWidth = 3
      end
      object vsFile: TVirtualStringTree
        Left = 1
        Top = 14
        Width = 1025
        Height = 199
        Align = alClient
        Header.AutoSizeIndex = 0
        Header.Font.Charset = DEFAULT_CHARSET
        Header.Font.Color = clWindowText
        Header.Font.Height = -11
        Header.Font.Name = 'Tahoma'
        Header.Font.Style = []
        Header.Height = 20
        Header.MainColumn = -1
        Header.Options = [hoAutoResize, hoColumnResize, hoDblClickResize, hoVisible]
        Header.ParentFont = True
        ParentBackground = False
        TabOrder = 0
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
        TreeOptions.SelectionOptions = [toFullRowSelect]
        TreeOptions.StringOptions = []
        OnBeforeCellPaint = vsFileBeforeCellPaint
        OnChange = vsFileChange
        OnGetText = vsFileGetText
        OnPaintText = vsFilePaintText
        OnHeaderClick = vsFileHeaderClick
        ExplicitWidth = 988
        ExplicitHeight = 175
        Columns = <>
        WideDefaultText = ''
      end
    end
  end
  object OpenDlg: TOpenDialog
    Filter = 'CSVFile|*.csv'
    Left = 512
    Top = 8
  end
  object ReloadTimer: TTimer
    Enabled = False
    OnTimer = ReloadTimerTimer
    Left = 160
    Top = 32
  end
end
