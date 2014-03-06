object frmBudgetUnitPriceEntry: TfrmBudgetUnitPriceEntry
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Calculate Budgeted Amount'
  ClientHeight = 149
  ClientWidth = 281
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    281
    149)
  PixelsPerInch = 96
  TextHeight = 13
  object lblUnitPrice: TLabel
    Left = 8
    Top = 10
    Width = 97
    Height = 13
    Caption = 'Unit Price (excl GST)'
  end
  object lblQuantity: TLabel
    Left = 8
    Top = 37
    Width = 42
    Height = 13
    Caption = 'Quantity'
  end
  object lblTotal: TLabel
    Left = 8
    Top = 78
    Width = 92
    Height = 13
    Caption = 'Total (Rounded)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object btnCancel: TButton
    Left = 198
    Top = 116
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 4
    ExplicitLeft = 186
  end
  object btnOk: TButton
    Left = 117
    Top = 116
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnOkClick
    ExplicitLeft = 105
  end
  object nUnitPrice: TOvcNumericField
    Left = 143
    Top = 8
    Width = 130
    Height = 21
    Cursor = crIBeam
    DataType = nftExtended
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = '##########.##'
    TabOrder = 0
    OnChange = nUnitPriceChange
    RangeHigh = {E175587FED2AB1ECFE7F}
    RangeLow = {E175587FED2AB1ECFEFF}
  end
  object nQuantity: TOvcNumericField
    Left = 143
    Top = 35
    Width = 130
    Height = 21
    Cursor = crIBeam
    DataType = nftExtended
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = '#######.##'
    TabOrder = 1
    OnChange = nQuantityChange
    RangeHigh = {E175587FED2AB1ECFE7F}
    RangeLow = {E175587FED2AB1ECFEFF}
  end
  object nTotal: TOvcNumericField
    Left = 143
    Top = 72
    Width = 130
    Height = 21
    Cursor = crIBeam
    DataType = nftLongInt
    CaretOvr.Shape = csBlock
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Enabled = False
    Options = []
    PictureMask = '############'
    TabOrder = 2
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000000000000000000}
  end
end
