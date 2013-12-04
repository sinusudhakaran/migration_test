object frmPercentageCalculation: TfrmPercentageCalculation
  Left = 0
  Top = 0
  ActiveControl = edtAccountCode
  BorderIcons = []
  Caption = 'Percentage Calculation                                  %'
  ClientHeight = 152
  ClientWidth = 254
  Color = clBtnFace
  Constraints.MaxHeight = 190
  Constraints.MaxWidth = 270
  Constraints.MinHeight = 190
  Constraints.MinWidth = 270
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object lblAccountCode: TLabel
    Left = 16
    Top = 27
    Width = 67
    Height = 13
    Caption = 'Account Code'
  end
  object lblPercentage: TLabel
    Left = 16
    Top = 67
    Width = 55
    Height = 13
    Caption = 'Percentage'
  end
  object lblPercent: TLabel
    Left = 210
    Top = 67
    Width = 11
    Height = 13
    Caption = '%'
  end
  object edtAccountCode: TEdit
    Left = 114
    Top = 24
    Width = 95
    Height = 21
    TabOrder = 0
    OnChange = edtAccountCodeChange
  end
  object btnClear: TButton
    Left = 16
    Top = 107
    Width = 75
    Height = 25
    Caption = 'Clear'
    TabOrder = 3
    OnClick = btnClearClick
  end
  object btnOK: TButton
    Left = 129
    Top = 107
    Width = 50
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 185
    Top = 107
    Width = 50
    Height = 25
    Caption = 'Cancel'
    Default = True
    ModalResult = 2
    TabOrder = 5
  end
  object btnChart: TBitBtn
    Left = 215
    Top = 23
    Width = 22
    Height = 22
    TabOrder = 1
    OnClick = btnChartClick
  end
  object nPercent: TOvcNumericField
    Left = 114
    Top = 61
    Width = 95
    Height = 21
    Cursor = crIBeam
    DataType = nftDouble
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = '###.##'
    TabOrder = 2
    OnKeyPress = nPercentKeyPress
    RangeHigh = {0000000000804FC30F40}
    RangeLow = {00000000000000000000}
  end
end
