object dlgEditBudgetBalance: TdlgEditBudgetBalance
  Scaled = False
Left = 329
  Top = 309
  BorderStyle = bsDialog
  Caption = 'Estimated Opening Bank Balance'
  ClientHeight = 176
  ClientWidth = 431
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    431
    176)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 24
    Width = 276
    Height = 13
    Caption = 'Enter the estimated opening bank balance for this budget'
  end
  object lblDate: TLabel
    Left = 35
    Top = 61
    Width = 127
    Height = 26
    Caption = 'Estimated Balance as at 01/07/01'
    WordWrap = True
  end
  object nBalance: TOvcNumericField
    Left = 168
    Top = 68
    Width = 129
    Height = 18
    Cursor = crIBeam
    DataType = nftDouble
    AutoSize = False
    BorderStyle = bsNone
    CaretOvr.Shape = csBlock
    Controller = OvcController1
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = '###,###,###.##'
    TabOrder = 0
    OnKeyDown = nBalanceKeyDown
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {00000000000000000000}
  end
  object btnOK: TButton
    Left = 268
    Top = 143
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    ExplicitLeft = 285
  end
  object btnCancel: TButton
    Left = 348
    Top = 143
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    ExplicitLeft = 365
  end
  object cmbBalance: TComboBox
    Left = 312
    Top = 68
    Width = 105
    Height = 21
    Style = csDropDownList
    Ctl3D = True
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 1
    Items.Strings = (
      'In Funds'
      'Overdrawn')
  end
  object OvcController1: TOvcController
    EntryCommands.TableList = (
      'Default'
      True
      ()
      'WordStar'
      False
      ()
      'Grid'
      False
      ())
    Epoch = 2000
    Left = 16
    Top = 136
  end
end
