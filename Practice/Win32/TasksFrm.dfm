object frmTasks: TfrmTasks
  Left = 295
  Top = 172
  BorderIcons = [biSystemMenu, biMaximize]
  BorderWidth = 3
  Caption = 'Tasks'
  ClientHeight = 364
  ClientWidth = 616
  Color = clBtnFace
  Constraints.MinHeight = 240
  Constraints.MinWidth = 480
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 321
    Width = 616
    Height = 43
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      616
      43)
    object btnOK: TButton
      Left = 456
      Top = 12
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 536
      Top = 12
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pgToDo: TPageControl
    Left = 0
    Top = 33
    Width = 616
    Height = 288
    ActivePage = tsToDo
    Align = alClient
    TabOrder = 1
    object tsToDo: TTabSheet
      Caption = 'Tasks'
      object pnlTasks: TPanel
        Left = 0
        Top = 0
        Width = 608
        Height = 260
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 6
        Caption = 'pnlTasks'
        TabOrder = 0
        object Shape1: TShape
          Left = 6
          Top = 6
          Width = 596
          Height = 1
          Align = alTop
          Pen.Color = clSilver
          ExplicitLeft = 288
          ExplicitTop = 8
          ExplicitWidth = 65
        end
        object Shape2: TShape
          Left = 6
          Top = 7
          Width = 1
          Height = 208
          Align = alLeft
          Pen.Color = clSilver
          ExplicitTop = 6
          ExplicitHeight = 596
        end
        object Shape3: TShape
          Left = 601
          Top = 7
          Width = 1
          Height = 208
          Align = alRight
          Pen.Color = clSilver
          ExplicitLeft = 6
          ExplicitTop = 6
          ExplicitHeight = 596
        end
        object pnlTasksFooter: TPanel
          Left = 6
          Top = 215
          Width = 596
          Height = 39
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 1
          DesignSize = (
            596
            39)
          object ShapeControl: TShape
            Left = 0
            Top = 0
            Width = 596
            Height = 1
            Align = alTop
            Pen.Color = clSilver
            ExplicitLeft = 288
            ExplicitTop = 8
            ExplicitWidth = 65
          end
          object btnAdd: TButton
            Left = 4
            Top = 12
            Width = 75
            Height = 25
            Caption = '&Add'
            TabOrder = 0
            OnClick = btnAddClick
          end
          object btnDelete: TButton
            Left = 89
            Top = 12
            Width = 75
            Height = 25
            Caption = '&Delete'
            TabOrder = 1
            OnClick = btnDeleteClick
          end
          object chkShowClosed: TCheckBox
            Left = 446
            Top = 15
            Width = 147
            Height = 17
            Anchors = [akRight, akBottom]
            Caption = 'Show Closed Tasks'
            TabOrder = 3
            OnClick = chkShowClosedClick
            ExplicitTop = 6
          end
          object btnReport: TButton
            Left = 175
            Top = 12
            Width = 75
            Height = 25
            Caption = '&Report'
            TabOrder = 2
            OnClick = btnReportClick
          end
        end
        object gdToDo: TtsGrid
          Left = 7
          Top = 7
          Width = 594
          Height = 208
          Align = alClient
          BorderStyle = bsNone
          CellSelectMode = cmNone
          CheckBoxStyle = stCheck
          ColMoving = False
          Color = clWhite
          Cols = 6
          ColSelectMode = csNone
          DefaultRowHeight = 30
          DrawOverlap = doDrawRowOnTop
          ExportDelimiter = ','
          GridLines = glVertLines
          HeadingButton = hbCell
          HeadingFont.Charset = DEFAULT_CHARSET
          HeadingFont.Color = clWindowText
          HeadingFont.Height = -11
          HeadingFont.Name = 'Tahoma'
          HeadingFont.Style = []
          HeadingHeight = 18
          HeadingParentFont = False
          HeadingWordWrap = wwOff
          MaskDefs = Masks
          ParentShowHint = False
          ResizeCols = rcNone
          ResizeRows = rrNone
          RowBarAlignment = vtaCenter
          RowBarWidth = 19
          RowChangedIndicator = riOff
          RowMoving = False
          Rows = 4
          SelectionType = sltColor
          ShowHint = False
          TabOrder = 0
          Version = '2.20.26'
          VertAlignment = vtaTop
          WantTabs = False
          XMLExport.Version = '1.0'
          XMLExport.DataPacketVersion = '2.0'
          OnButtonClick = gdToDoButtonClick
          OnCellEdit = gdToDoCellEdit
          OnCellLoaded = gdToDoCellLoaded
          OnEditTextResized = gdToDoEditTextResized
          OnEndCellEdit = gdToDoEndCellEdit
          OnEnter = gdToDoEnter
          OnExit = gdToDoExit
          OnHeadingClick = gdToDoHeadingClick
          OnInvalidMaskValue = gdToDoInvalidMaskValue
          OnMouseDown = gdToDoMouseDown
          OnRowLoaded = gdToDoRowLoaded
          ExplicitLeft = 6
          ExplicitTop = 6
          ExplicitWidth = 596
          ExplicitHeight = 209
          ColProperties = <
            item
              DataCol = 1
              Col.Heading = 'Date Entered'
              Col.SortPicture = spDown
              Col.Width = 95
            end
            item
              DataCol = 2
              Col.Heading = 'Entered By'
              Col.Width = 83
            end
            item
              DataCol = 3
              Col.Heading = 'Action'
              Col.Width = 84
            end
            item
              DataCol = 4
              Col.ButtonType = btDateTimePopup
              Col.Heading = 'Reminder Date'
              Col.MaskName = 'DateMask'
              Col.MaxLength = 10
              Col.Width = 108
            end
            item
              DataCol = 5
              Col.Heading = 'Closed'
              Col.HeadingHorzAlignment = htaCenter
            end
            item
              DataCol = 6
              Col.Heading = 'Date Closed'
              Col.Width = 113
            end>
        end
      end
    end
    object tsNotes: TTabSheet
      Caption = 'Comments'
      ImageIndex = 1
      object pnlNotes: TPanel
        Left = 0
        Top = 0
        Width = 608
        Height = 260
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 6
        TabOrder = 0
        object memNotes: TRzMemo
          Left = 6
          Top = 6
          Width = 596
          Height = 248
          Align = alClient
          Lines.Strings = (
            'Client is on holiday until next Tuesday')
          ScrollBars = ssVertical
          TabOrder = 0
        end
      end
    end
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 616
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblClientName: TLabel
      Left = 8
      Top = 8
      Width = 64
      Height = 13
      Caption = 'lblClientName'
      ShowAccelChar = False
    end
  end
  object Masks: TtsMaskDefs
    Masks = <
      item
        Name = 'DateMask'
        Picture = '##/##/##[##]'
      end>
    Left = 272
    Top = 312
  end
  object popEditMenu: TPopupMenu
    Left = 312
    Top = 312
    object Cut1: TMenuItem
      Caption = 'Cut'
      ShortCut = 16472
      OnClick = Cut1Click
    end
    object Copy1: TMenuItem
      Caption = 'Copy'
      OnClick = Copy1Click
    end
    object Paste1: TMenuItem
      Caption = 'Paste'
      OnClick = Paste1Click
    end
    object Delete1: TMenuItem
      Caption = 'Delete'
      OnClick = Delete1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object SelectAll1: TMenuItem
      Caption = 'Select All'
      OnClick = SelectAll1Click
    end
  end
end
