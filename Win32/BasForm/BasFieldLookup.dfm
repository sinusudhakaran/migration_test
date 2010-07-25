inherited dlgBasFieldLookup: TdlgBasFieldLookup
  Left = 299
  Top = 214
  Caption = 'Add New Bas Field'
  ClientHeight = 205
  ClientWidth = 438
  OldCreateOrder = True
  ExplicitWidth = 444
  ExplicitHeight = 237
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel [0]
    Left = 16
    Top = 10
    Width = 83
    Height = 16
    Caption = 'Add Total into'
  end
  object lblGSTClass: TLabel [1]
    Left = 16
    Top = 181
    Width = 65
    Height = 16
    Caption = 'GST Class'
    Visible = False
  end
  object Label3: TLabel [2]
    Left = 16
    Top = 92
    Width = 66
    Height = 16
    Caption = 'Total Type'
  end
  object lblBoxDesc: TLabel [3]
    Left = 120
    Top = 10
    Width = 89
    Height = 16
    Caption = 'G1 Total Sales'
    ShowAccelChar = False
  end
  object lblAccountCode: TLabel [4]
    Left = 16
    Top = 56
    Width = 84
    Height = 16
    Caption = 'Account Code'
    Visible = False
  end
  object sbtnChart: TSpeedButton [5]
    Left = 274
    Top = 54
    Width = 65
    Height = 22
    Caption = 'Chart'
    Flat = True
    Visible = False
    OnClick = sbtnChartClick
  end
  object Label2: TLabel [6]
    Left = 16
    Top = 128
    Width = 70
    Height = 16
    Caption = 'Percentage'
  end
  object Label4: TLabel [7]
    Left = 208
    Top = 128
    Width = 12
    Height = 16
    Caption = '%'
  end
  object cmbGST: TComboBox [8]
    Left = 120
    Top = 174
    Width = 225
    Height = 24
    Style = csDropDownList
    ItemHeight = 16
    TabOrder = 1
    Visible = False
    OnDropDown = cmbGSTDropDown
  end
  inherited btnOK: TButton
    Left = 279
    Top = 174
    TabOrder = 4
    ExplicitLeft = 279
    ExplicitTop = 174
  end
  inherited btnCancel: TButton
    Left = 359
    Top = 174
    TabOrder = 5
    ExplicitLeft = 359
    ExplicitTop = 174
  end
  object cmbTotalType: TComboBox
    Left = 120
    Top = 88
    Width = 193
    Height = 24
    Hint = #39'xx'#39
    Style = csDropDownList
    ItemHeight = 16
    TabOrder = 2
  end
  object txtCode: TEdit
    Left = 120
    Top = 54
    Width = 145
    Height = 22
    BorderStyle = bsNone
    MaxLength = 6
    TabOrder = 0
    Visible = False
    OnChange = txtCodeChange
    OnKeyDown = txtCodeKeyDown
    OnKeyUp = txtCodeKeyUp
  end
  object nfPercent: TOvcNumericField
    Left = 120
    Top = 128
    Width = 81
    Height = 22
    Cursor = crIBeam
    DataType = nftDouble
    BorderStyle = bsNone
    CaretOvr.Shape = csBlock
    Controller = OvcController1
    Ctl3D = False
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    ParentCtl3D = False
    PictureMask = '####.####'
    TabOrder = 3
    RangeHigh = {73B2DBB9838916F2FE43}
    RangeLow = {73B2DBB9838916F2FEC3}
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
  end
end
