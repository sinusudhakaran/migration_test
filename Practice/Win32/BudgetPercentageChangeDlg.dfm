object dlgBudgetPercentageChange: TdlgBudgetPercentageChange
  Left = 414
  Top = 279
  ActiveControl = nPercent
  BorderStyle = bsDialog
  Caption = 'Percentage Increase or Decrease'
  ClientHeight = 292
  ClientWidth = 417
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    417
    292)
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 336
    Top = 258
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnOK: TButton
    Left = 250
    Top = 258
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object gbFigures: TGroupBox
    Left = 8
    Top = 128
    Width = 401
    Height = 121
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 24
      Width = 201
      Height = 13
      Caption = 'What do you want to do to these figures?'
    end
    object Label2: TLabel
      Left = 261
      Top = 69
      Width = 11
      Height = 13
      Caption = '%'
    end
    object rbIncreaseFigures: TRadioButton
      Left = 72
      Top = 56
      Width = 113
      Height = 17
      Caption = '&Increase by'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbDecreaseFigures: TRadioButton
      Left = 72
      Top = 88
      Width = 113
      Height = 17
      Caption = '&Decrease by'
      TabOrder = 1
    end
    object nPercent: TOvcNumericField
      Left = 197
      Top = 66
      Width = 58
      Height = 22
      Cursor = crIBeam
      DataType = nftDouble
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Options = []
      PictureMask = '#,###.##'
      TabOrder = 2
      OnKeyPress = nPercentKeyPress
      RangeHigh = {000000000000409C0C40}
      RangeLow = {00000000000000000000}
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 401
    Height = 121
    TabOrder = 3
    object Label3: TLabel
      Left = 16
      Top = 15
      Width = 184
      Height = 13
      Caption = 'Which figures do you want to change?'
    end
    object rbAll: TRadioButton
      Left = 204
      Top = 80
      Width = 113
      Height = 17
      Caption = '&All '
      TabOrder = 0
      OnClick = rbAllClick
    end
    object rbCell: TRadioButton
      Left = 72
      Top = 48
      Width = 113
      Height = 17
      Caption = '&Cell'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = rbCellClick
    end
    object rbColumn: TRadioButton
      Left = 72
      Top = 80
      Width = 113
      Height = 17
      Caption = 'Colu&mn'
      TabOrder = 2
      OnClick = rbColumnClick
    end
    object rbRow: TRadioButton
      Left = 204
      Top = 48
      Width = 113
      Height = 17
      Caption = '&Row'
      TabOrder = 3
      OnClick = rbRowClick
    end
  end
end
