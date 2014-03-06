object RecommendedMemorisationsFrm: TRecommendedMemorisationsFrm
  Scaled = False
Left = 0
  Top = 0
  Caption = 'Recommended Memorisations for '
  ClientHeight = 481
  ClientWidth = 667
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 500
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object vstTree: TVirtualStringTree
    Left = 0
    Top = 33
    Width = 667
    Height = 407
    Align = alClient
    Header.AutoSizeIndex = -1
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.MainColumn = 1
    Header.Options = [hoColumnResize, hoDrag, hoVisible]
    ParentBackground = False
    TabOrder = 0
    TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toShowTreeLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toDisableDrawSelection]
    OnAfterCellPaint = vstTreeAfterCellPaint
    OnFocusChanging = vstTreeFocusChanging
    OnFreeNode = vstTreeFreeNode
    OnGetText = vstTreeGetText
    OnGetNodeDataSize = vstTreeGetNodeDataSize
    OnMouseDown = vstTreeMouseDown
    ExplicitWidth = 677
    ExplicitHeight = 417
    Columns = <
      item
        Position = 0
        Width = 110
        WideText = 'Entry Type'
      end
      item
        Position = 1
        Width = 230
        WideText = 'Statement Details'
      end
      item
        Position = 2
        Width = 100
        WideText = 'Code'
      end
      item
        Position = 3
        Width = 60
        WideText = '# Coded'
      end
      item
        Position = 4
        Width = 60
        WideText = 'Total #'
      end
      item
        Alignment = taCenter
        Position = 5
        Width = 40
      end>
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 440
    Width = 667
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 450
    ExplicitWidth = 677
    DesignSize = (
      667
      41)
    object lblStatus: TLabel
      Left = 6
      Top = 12
      Width = 41
      Height = 13
      Caption = 'lblStatus'
    end
    object btnClose: TButton
      Left = 582
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      ModalResult = 1
      TabOrder = 0
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 667
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 677
    object lblBankAccount: TLabel
      Left = 8
      Top = 8
      Width = 72
      Height = 13
      Caption = 'lblBankAccount'
    end
  end
end
