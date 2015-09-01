object dlgGraphNames: TdlgGraphNames
  Left = 273
  Top = 171
  BorderIcons = [biSystemMenu]
  Caption = 'Set Up Graph Headings'
  ClientHeight = 282
  ClientWidth = 602
  Color = clBtnFace
  Constraints.MaxWidth = 618
  Constraints.MinHeight = 180
  Constraints.MinWidth = 435
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 602
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Select the Titles and Headings to use on the Graphs.'
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 0
    Top = 221
    Width = 602
    Height = 61
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = 224
    DesignSize = (
      602
      61)
    object Label1: TLabel
      Left = 8
      Top = 4
      Width = 419
      Height = 13
      Caption = 
        '(Note: The default titles and headings will be used if the user ' +
        'defined text is left blank.)'
    end
    object btnOk: TButton
      Left = 436
      Top = 29
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 2
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 520
      Top = 29
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object btnRestore: TButton
      Left = 8
      Top = 29
      Width = 121
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Restore Defaults'
      TabOrder = 0
      OnClick = btnRestoreClick
    end
    object btnCopy: TButton
      Left = 135
      Top = 29
      Width = 121
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = '&Copy From...'
      TabOrder = 1
      OnClick = btnCopyClick
    end
  end
  object tbNames: TOvcTable
    Left = 0
    Top = 25
    Width = 602
    Height = 196
    RowLimit = 9
    Align = alClient
    Color = clWindow
    ColorUnused = clBtnFace
    Colors.ActiveUnfocused = clWindow
    Colors.ActiveUnfocusedText = clWindowText
    Colors.Locked = clWindow
    Colors.Editing = clWindow
    Controller = OvcController1
    Ctl3D = False
    GridPenSet.NormalGrid.NormalColor = clBtnShadow
    GridPenSet.NormalGrid.Style = psInsideFrame
    GridPenSet.NormalGrid.Effect = geHorizontal
    GridPenSet.LockedGrid.NormalColor = clBtnShadow
    GridPenSet.LockedGrid.Style = psSolid
    GridPenSet.LockedGrid.Effect = ge3D
    GridPenSet.CellWhenFocused.NormalColor = clBlack
    GridPenSet.CellWhenFocused.Style = psSolid
    GridPenSet.CellWhenFocused.Effect = geBoth
    GridPenSet.CellWhenUnfocused.NormalColor = clBlack
    GridPenSet.CellWhenUnfocused.Style = psClear
    GridPenSet.CellWhenUnfocused.Effect = geNone
    LockedRowsCell = OvcTCColHead1
    Options = [otoNoRowResizing, otoEnterToArrow, otoNoSelection]
    ParentCtl3D = False
    TabOrder = 1
    OnBeginEdit = tbNamesBeginEdit
    OnDoneEdit = tbNamesDoneEdit
    OnEnter = tbNamesEnter
    OnEnteringRow = tbNamesEnteringRow
    OnExit = tbNamesExit
    OnGetCellData = tbNamesGetCellData
    OnLeavingRow = tbNamesLeavingRow
    OnUserCommand = tbNamesUserCommand
    ExplicitHeight = 199
    CellData = (
      'dlgGraphNames.OvcTCColHead1'
      'dlgGraphNames.tcUser'
      'dlgGraphNames.tcDefault')
    RowData = (
      22
      1
      False
      21
      5
      False
      21)
    ColData = (
      225
      False
      True
      'dlgGraphNames.tcDefault'
      439
      False
      True
      'dlgGraphNames.tcUser')
  end
  object OvcController1: TOvcController
    EntryCommands.TableList = (
      'Default'
      True
      (
        117
        69)
      'WordStar'
      False
      ()
      'Grid'
      False
      ())
    Epoch = 1900
    Left = 256
    Top = 96
  end
  object OvcTCColHead1: TOvcTCColHead
    Headings.Strings = (
      'Default'
      'User Defined')
    ShowLetters = False
    Table = tbNames
    Left = 320
    Top = 80
  end
  object tcDefault: TOvcTCString
    MaxLength = 40
    Table = tbNames
    Left = 360
    Top = 82
  end
  object tcUser: TOvcTCString
    MaxLength = 40
    Table = tbNames
    Left = 400
    Top = 82
  end
end
