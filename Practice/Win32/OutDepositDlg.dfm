object dlgDeposit: TdlgDeposit
  Scaled = False
Left = 347
  Top = 236
  ActiveControl = eReference
  BorderStyle = bsDialog
  Caption = 'Add Unpresented Deposits'
  ClientHeight = 191
  ClientWidth = 398
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    398
    191)
  PixelsPerInch = 96
  TextHeight = 13
  object lblDate: TLabel
    Left = 8
    Top = 88
    Width = 23
    Height = 13
    Caption = '&Date'
    FocusControl = eDate
  end
  object Label2: TLabel
    Left = 296
    Top = 88
    Width = 37
    Height = 13
    Caption = '&Amount'
    FocusControl = eAmount
  end
  object lblType: TLabel
    Left = 8
    Top = 8
    Width = 255
    Height = 13
    Caption = 'Enter the deposit details.  The deposit must be dated'
  end
  object Label4: TLabel
    Left = 104
    Top = 88
    Width = 50
    Height = 13
    Caption = '&Reference'
    FocusControl = eReference
  end
  object lblPeriod: TLabel
    Left = 8
    Top = 32
    Width = 98
    Height = 13
    Caption = '01/01/00 - 31/12/00'
  end
  object lblUPDPrefix: TLabel
    Left = 106
    Top = 112
    Width = 20
    Height = 13
    Caption = 'UPD'
  end
  object eAmount: TOvcNumericField
    Left = 280
    Top = 112
    Width = 113
    Height = 21
    Cursor = crIBeam
    DataType = nftDouble
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
    PictureMask = '########.##'
    TabOrder = 2
    OnKeyPress = eAmountKeyPress
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
  end
  object eDate: TOvcPictureField
    Left = 8
    Top = 112
    Width = 89
    Height = 24
    Cursor = crIBeam
    DataType = pftDate
    AutoSize = False
    BorderStyle = bsNone
    CaretOvr.Shape = csBlock
    Controller = OvcController1
    ControlCharColor = clRed
    DecimalPlaces = 0
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Epoch = 0
    InitDateTime = False
    MaxLength = 8
    Options = [efoCaretToEnd]
    PictureMask = 'DD/mm/yy'
    TabOrder = 0
    OnError = eDateError
    RangeHigh = {25600D00000000000000}
    RangeLow = {00000000000000000000}
  end
  object btnOK: TButton
    Left = 240
    Top = 160
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 320
    Top = 160
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object eReference: TEdit
    Left = 140
    Top = 112
    Width = 132
    Height = 24
    BorderStyle = bsNone
    Ctl3D = False
    MaxLength = 8
    ParentCtl3D = False
    TabOrder = 1
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
    Epoch = 1900
    Left = 512
    Top = 136
  end
end
