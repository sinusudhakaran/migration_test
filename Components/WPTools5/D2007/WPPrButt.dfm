object WPButtonPropDlg: TWPButtonPropDlg
  Left = 35
  Top = 171
  Width = 492
  Height = 242
  Caption = 'WPToolButton Style - WPTools Version 5'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'System'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 20
  object WPToolBar1: TWPToolBar
    Left = 0
    Top = 0
    Width = 484
    Height = 166
    ParentColor = False
    UseDockManager = False
    KeepGroupsTogether = False
    Align = alClient
    ParentShowHint = False
    ShowHint = True
    BevelLines = []
    AutoEnabling = False
    WidthBetweenGroups = 0
    FontChoice = fsPrinterFonts
    ShowFont = True
    sel_ListBoxes = []
    sel_StatusIcons = [SelNormal, SelBold, SelItalic, SelUnder, SelHyperLink, SelStrikeOut, SelSuper, SelSub, SelHidden, SelProtected, SelRTFCode, SelLeft, SelRight, SelBlock, SelCenter]
    sel_ActionIcons = [SelExit, SelNew, SelOpen, SelSave, SelClose, SelPrint, SelPrintSetup, SelFitWidth, SelFitHeight, SelZoomIn, SelZoomOut, SelNextPage, SelPriorPage]
    sel_DatabaseIcons = [SelToStart, SelNext, SelPrev, SelToEnd, SelEdit, SelAdd, SelDel, SelCancel, SelPost]
    sel_EditIcons = [SelUndo, SelCopy, SelCut, SelPaste, SelSelAll, SelHideSel, SelFind, SelReplace, SelSpellCheck]
    sel_TableIcons = [SelCreateTable, SelSelRow, SelInsRow, SelDelRow, SelInsCol, SelDelCol, SelSelCol, SelSplitCell, SelCombineCell, SelBAllOff, SelBAllOn, SelBInner, SelBOuter, SelBLeft, SelBRight, SelBTop, SelBBottom]
    sel_OutlineIcons = [SelBullets, SelNumbers, SelNextLevel, SelPriorLevel, SelParProtect, SelParKeep]
    FontSizeFrom = 8
    OnIconSelection = WPToolBar1IconSelection
    FlatButtons = True
    ButtonHeight = 0
    TrueTypeOnly = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 166
    Width = 484
    Height = 42
    Align = alBottom
    Caption = ' '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Arial'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    object Bevel1: TBevel
      Left = 8
      Top = 5
      Width = 210
      Height = 31
    end
    object Definition: TLabel
      Left = 10
      Top = 9
      Width = 204
      Height = 22
      AutoSize = False
      Caption = 'Definition'
    end
    object BitBtn2: TBitBtn
      Left = 356
      Top = 5
      Width = 63
      Height = 31
      Caption = ' '
      TabOrder = 0
      Kind = bkCancel
    end
    object BitBtn1: TBitBtn
      Left = 423
      Top = 5
      Width = 62
      Height = 31
      Caption = ' '
      TabOrder = 1
      Kind = bkOK
    end
  end
end
