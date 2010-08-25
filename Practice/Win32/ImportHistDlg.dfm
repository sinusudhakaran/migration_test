object ImportHist: TImportHist
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'ImportHist'
  ClientHeight = 584
  ClientWidth = 990
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
  object pFileinput: TPanel
    Left = 0
    Top = 0
    Width = 990
    Height = 78
    Align = alTop
    TabOrder = 0
    DesignSize = (
      990
      78)
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
      Left = 752
      Top = 41
      Width = 41
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Delimiter'
      FocusControl = cbDelimiter
    end
    object BTNBrowse: TButton
      Left = 904
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Bro&wse'
      TabOrder = 0
      OnClick = BTNBrowseClick
    end
    object EPath: TEdit
      Left = 88
      Top = 11
      Width = 803
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Enabled = False
      TabOrder = 4
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
      Left = 816
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
    end
  end
  object pBtn: TPanel
    Left = 0
    Top = 543
    Width = 990
    Height = 41
    Align = alBottom
    TabOrder = 4
    DesignSize = (
      990
      41)
    object BtnCancel: TButton
      Left = 904
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnOK: TButton
      Left = 816
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
  object pOut: TPanel
    Left = 0
    Top = 403
    Width = 990
    Height = 140
    Align = alClient
    Caption = 'pOut'
    TabOrder = 3
    object vsOut: TVirtualStringTree
      Left = 1
      Top = 1
      Width = 988
      Height = 138
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
      ParentBackground = False
      TabOrder = 0
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      TreeOptions.SelectionOptions = [toFullRowSelect]
      OnBeforeCellPaint = vsOutBeforeCellPaint
      OnChange = vsOutChange
      OnGetText = vsOutGetText
      OnPaintText = vsOutPaintText
      OnHeaderClick = vsOutHeaderClick
      Columns = <>
      WideDefaultText = ''
    end
  end
  object PFormat: TPanel
    Left = 0
    Top = 268
    Width = 990
    Height = 135
    Align = alTop
    Caption = 'PFormat'
    TabOrder = 2
    object PCFormat: TPageControl
      Left = 1
      Top = 1
      Width = 988
      Height = 133
      ActivePage = TSDate
      Align = alClient
      TabOrder = 0
      OnChange = PCFormatChange
      object TSDate: TTabSheet
        Caption = '&Date'
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Label2: TLabel
          Left = 15
          Top = 20
          Width = 34
          Height = 13
          Caption = 'Format'
        end
        object Label4: TLabel
          Left = 15
          Top = 47
          Width = 35
          Height = 13
          Caption = 'Column'
        end
        object EDate: TEdit
          Left = 83
          Top = 18
          Width = 97
          Height = 21
          ReadOnly = True
          TabOrder = 0
          Text = 'dd/mm/yyyy'
        end
        object cbDate: TComboBox
          Left = 83
          Top = 45
          Width = 300
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 1
          OnChange = cbDateChange
        end
      end
      object TSAmount: TTabSheet
        Caption = '&Amount'
        ImageIndex = 1
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object lbAmount: TLabel
          Left = 216
          Top = 20
          Width = 37
          Height = 13
          Caption = 'Amount'
          Visible = False
        end
        object lbAmount2: TLabel
          Left = 216
          Top = 47
          Width = 29
          Height = 13
          Caption = 'Credit'
          Visible = False
        end
        object cbAmount: TComboBox
          Left = 304
          Top = 18
          Width = 300
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 3
          Visible = False
          OnChange = cbAmountChange
        end
        object cbAmount2: TComboBox
          Left = 304
          Top = 45
          Width = 300
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 4
          Visible = False
          OnChange = cbAmountChange
        end
        object cbSign: TCheckBox
          Left = 216
          Top = 74
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
          Top = 45
          Width = 153
          Height = 17
          Caption = 'De&bit and Credit'
          TabOrder = 1
          OnClick = rbDebitCreditClick
        end
        object RBSign: TRadioButton
          Left = 15
          Top = 72
          Width = 153
          Height = 17
          Caption = 'Amount and Si&gn'
          TabOrder = 0
          OnClick = RBSignClick
        end
        object rbSingle: TRadioButton
          Left = 15
          Top = 18
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
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object LColumns: TLabel
          Left = 15
          Top = 20
          Width = 35
          Height = 13
          Caption = 'Column'
        end
        object Label10: TLabel
          Left = 15
          Top = 56
          Width = 313
          Height = 13
          Caption = 
            'Reference is limited to 12 characters, typically a Cheque number' +
            '.'
        end
        object cbRef: TComboBox
          Left = 83
          Top = 18
          Width = 300
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
          OnChange = cbRefChange
        end
      end
      object tsAnalysis: TTabSheet
        Caption = 'A&nalysis'
        ImageIndex = 3
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Label3: TLabel
          Left = 15
          Top = 20
          Width = 35
          Height = 13
          Caption = 'Column'
        end
        object Label11: TLabel
          Left = 15
          Top = 56
          Width = 168
          Height = 13
          Caption = 'Analysis is limited to 12 characters.'
        end
        object cbAna: TComboBox
          Left = 83
          Top = 18
          Width = 300
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
          OnChange = cbAnaChange
        end
      end
      object TSNarration: TTabSheet
        Caption = 'Narra&tion'
        ImageIndex = 4
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Label5: TLabel
          Left = 15
          Top = 20
          Width = 41
          Height = 13
          Caption = 'Column1'
        end
        object Label6: TLabel
          Left = 15
          Top = 47
          Width = 41
          Height = 13
          Caption = 'Column2'
        end
        object Label7: TLabel
          Left = 15
          Top = 74
          Width = 41
          Height = 13
          Caption = 'Column3'
        end
        object cbNar1: TComboBox
          Left = 83
          Top = 18
          Width = 300
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 0
          OnChange = cbNar1Change
        end
        object cbNar2: TComboBox
          Left = 83
          Top = 45
          Width = 300
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 1
          OnChange = cbNar1Change
        end
        object cbNar3: TComboBox
          Left = 83
          Top = 72
          Width = 300
          Height = 21
          Style = csDropDownList
          ItemHeight = 0
          TabOrder = 2
          OnChange = cbNar1Change
        end
      end
    end
  end
  object pFile: TPanel
    Left = 0
    Top = 78
    Width = 990
    Height = 190
    Align = alTop
    Color = clWindow
    ParentBackground = False
    TabOrder = 1
    object lbFile: TLabel
      Left = 1
      Top = 1
      Width = 3
      Height = 13
      Align = alTop
      Constraints.MaxHeight = 100
      WordWrap = True
    end
    object vsFile: TVirtualStringTree
      Left = 1
      Top = 14
      Width = 988
      Height = 175
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
      Columns = <>
      WideDefaultText = ''
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
