object WPXMLPropertyEditor: TWPXMLPropertyEditor
  Left = 37
  Top = 306
  Width = 579
  Height = 378
  Caption = 'XML Property'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 139
    Top = 0
    Width = 6
    Height = 305
    Cursor = crHSplit
    Color = clGray
    ParentColor = False
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 305
    Width = 571
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 
      ' WPTools, WPForm and wPDF - info: http://www.wptools.de - XML-Pr' +
      'operty Editor V1.05'
  end
  object TreeView1: TTreeView
    Left = 0
    Top = 0
    Width = 139
    Height = 305
    Align = alLeft
    Indent = 19
    TabOrder = 1
    OnClick = TreeView1Click
    OnEditing = TreeView1Editing
    OnKeyUp = TreeView1KeyUp
  end
  object Panel1: TPanel
    Left = 145
    Top = 0
    Width = 426
    Height = 305
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object PageControl1: TPageControl
      Left = 0
      Top = 25
      Width = 426
      Height = 280
      ActivePage = TabSheet1
      Align = alClient
      TabOrder = 0
      OnChanging = PageControl1Changing
      object TabSheet1: TTabSheet
        Caption = 'Values'
        object StringGrid1: TStringGrid
          Left = 0
          Top = 49
          Width = 418
          Height = 158
          Align = alClient
          ColCount = 2
          DefaultColWidth = 60
          FixedColor = clSilver
          RowCount = 1
          FixedRows = 0
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goEditing, goAlwaysShowEditor, goThumbTracking]
          ScrollBars = ssVertical
          TabOrder = 0
          Visible = False
          OnKeyPress = StringGrid1KeyPress
        end
        object Memo1: TMemo
          Left = 0
          Top = 207
          Width = 418
          Height = 45
          Align = alBottom
          TabOrder = 1
          Visible = False
          OnKeyPress = StringGrid1KeyPress
        end
        object CommentPanel: TPanel
          Left = 0
          Top = 0
          Width = 418
          Height = 49
          Align = alTop
          BevelOuter = bvLowered
          TabOrder = 2
          Visible = False
          object CommentLabel: TLabel
            Left = 1
            Top = 1
            Width = 416
            Height = 47
            Align = alClient
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGreen
            Font.Height = -13
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            WordWrap = True
          end
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'Text'
        TabVisible = False
        object Memo2: TMemo
          Left = 0
          Top = 0
          Width = 392
          Height = 198
          Align = alClient
          TabOrder = 0
        end
      end
    end
    object DisplayCurrent: TPanel
      Left = 0
      Top = 0
      Width = 426
      Height = 25
      Align = alTop
      BevelOuter = bvLowered
      TabOrder = 1
    end
  end
  object MainMenu1: TMainMenu
    Left = 267
    Top = 102
    object File1: TMenuItem
      Caption = 'File'
      object Load1: TMenuItem
        Caption = 'Load'
        OnClick = Load1Click
      end
      object Merge1: TMenuItem
        Caption = 'Merge'
        OnClick = Merge1Click
      end
      object Save1: TMenuItem
        Caption = 'Save'
        OnClick = Save1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object OK: TMenuItem
        Caption = 'OK'
        Visible = False
        OnClick = OKClick
      end
      object Cancel: TMenuItem
        Caption = 'CANCEL'
        Visible = False
        OnClick = CancelClick
      end
      object Close1: TMenuItem
        Caption = 'Close'
        OnClick = Close1Click
      end
    end
    object CurrentBranch: TMenuItem
      Caption = 'Branch'
      Visible = False
      object FindTextinbranch1: TMenuItem
        Caption = 'Find Text in branch'
        OnClick = FindTextinbranch1Click
      end
      object FindNext1: TMenuItem
        Caption = 'Find Next'
        Enabled = False
        ShortCut = 114
        OnClick = FindNext1Click
      end
      object ShowAsString1: TMenuItem
        Caption = 'Show contents as text ...'
        Visible = False
        OnClick = ShowAsString1Click
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object MoveBranch1: TMenuItem
        Caption = 'Move to ...'
        OnClick = MoveBranch1Click
      end
      object CopyBranch1: TMenuItem
        Caption = 'Create Copy in same level'
        OnClick = CopyBranch1Click
      end
      object CreateCopy1: TMenuItem
        Caption = 'Create Copy in different level'
        OnClick = CreateCopy1Click
      end
      object RenameBranch1: TMenuItem
        Caption = 'Rename as ...'
        OnClick = RenameBranch1Click
      end
      object DeleteBranch1: TMenuItem
        Caption = 'Delete'
        OnClick = DeleteBranch1Click
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object Create1: TMenuItem
        Caption = 'Create Item with PARAMs'
        OnClick = Create1Click
      end
      object CreateParaminallelements1: TMenuItem
        Caption = 'Add PARAM to Sub-Tags...'
        OnClick = CreateParaminallelements1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object SaveBranch1: TMenuItem
        Caption = 'Save Branch'
        OnClick = SaveBranch1Click
      end
    end
  end
  object WPXMLTree1: TWPXMLTree
    AutoCreateClosedTags = True
    DontSaveEmptyTags = True
    Encoding = 'windows-1250'
    StyleSheets = <>
    OnLoaded = WPXMLTree1Loaded
    XMLData.Data = {
      3C3F786D6C2076657273696F6E3D22312E302220656E636F64696E673D227769
      6E646F77732D31323530223F3E0D0A}
    Left = 331
    Top = 103
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'XML'
    Filter = 'XML Files|*.XML'
    Left = 264
    Top = 46
  end
  object SaveDialog1: TSaveDialog
    Filter = 'XML Files|*.XML'
    Left = 329
    Top = 46
  end
end
