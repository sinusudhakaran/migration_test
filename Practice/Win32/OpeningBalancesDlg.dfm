object dlgOpeningBalances: TdlgOpeningBalances
  Left = 375
  Top = 114
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Opening Balances'
  ClientHeight = 495
  ClientWidth = 622
  Color = clBtnFace
  Constraints.MinWidth = 630
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFooter: TPanel
    Left = 0
    Top = 416
    Width = 622
    Height = 79
    Align = alBottom
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 2
    DesignSize = (
      622
      79)
    object lblAmountRemText: TLabel
      Left = 8
      Top = 8
      Width = 166
      Height = 13
      Caption = 'Amount remaining to be assigned: '
    end
    object lblAmountRemaining: TLabel
      Left = 248
      Top = 8
      Width = 62
      Height = 13
      Caption = '$123,456.78'
    end
    object lblInvalidAccountsUsed: TLabel
      Left = 8
      Top = 32
      Width = 412
      Height = 16
      Caption = 'WARNING: You have amounts posted to non-balance sheet accounts'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object btnOK: TButton
      Left = 456
      Top = 45
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 536
      Top = 45
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
    object chkHideNonBS: TCheckBox
      Left = 387
      Top = 9
      Width = 230
      Height = 17
      Anchors = [akTop, akRight]
      Caption = '&Hide Non-Balance Sheet Accounts'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = chkHideNonBSClick
    end
  end
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 622
    Height = 78
    Align = alTop
    TabOrder = 0
    object lSubTitle: TLabel
      Left = 8
      Top = 16
      Width = 251
      Height = 13
      Caption = 'Enter the Opening Balances for your accounts as at '
    end
    object lblFinYear: TLabel
      Left = 326
      Top = 17
      Width = 63
      Height = 13
      Caption = '01 April 2002'
    end
    object Label3: TLabel
      Left = 8
      Top = 56
      Width = 321
      Height = 13
      Caption = 
        'Note: All balances should normally be entered as positive amount' +
        's.'
    end
  end
  object tgBalances: TtsGrid
    Left = 0
    Top = 78
    Width = 622
    Height = 338
    Hint = 'Test hint'
    Align = alClient
    AlwaysShowScrollBar = ssVertical
    CellSelectMode = cmNone
    CheckBoxStyle = stCheck
    ColMoving = False
    Cols = 5
    ColSelectMode = csNone
    Ctl3D = False
    DefaultRowHeight = 20
    ExportDelimiter = ','
    GridLines = glVertLines
    HeadingFont.Charset = DEFAULT_CHARSET
    HeadingFont.Color = clWindowText
    HeadingFont.Height = -11
    HeadingFont.Name = 'Tahoma'
    HeadingFont.Style = []
    HeadingHeight = 20
    HeadingParentFont = False
    HeadingVertAlignment = vtaCenter
    MaskDefs = tsMaskDefs1
    ParentCtl3D = False
    ParentShowHint = False
    RowBarOn = False
    RowMoving = False
    Rows = 4
    RowSelectMode = rsSingle
    ShowHint = False
    TabOrder = 1
    Version = '2.20.26'
    WantTabs = False
    XMLExport.Version = '1.0'
    XMLExport.DataPacketVersion = '2.0'
    OnCellLoaded = tgBalancesCellLoaded
    OnContextPopup = tgBalancesContextPopup
    OnEndCellEdit = tgBalancesEndCellEdit
    OnEndRowEdit = tgBalancesEndRowEdit
    OnInvalidMaskValue = tgBalancesInvalidMaskValue
    OnKeyPress = tgBalancesKeyPress
    OnMouseMove = tgBalancesMouseMove
    OnPaintCell = tgBalancesPaintCell
    OnStartCellEdit = tgBalancesStartCellEdit
    ColProperties = <
      item
        DataCol = 1
        Col.Heading = 'Account'
        Col.ReadOnly = True
        Col.Width = 100
      end
      item
        DataCol = 2
        Col.Heading = 'Description'
        Col.ReadOnly = True
        Col.Width = 175
      end
      item
        DataCol = 3
        Col.Heading = 'Opening Balance'
        Col.MaskName = 'sysLongDecimal'
        Col.HorzAlignment = htaRight
        Col.Width = 145
      end
      item
        DataCol = 4
        Col.ReadOnly = True
        Col.Width = 25
      end
      item
        DataCol = 5
        Col.Heading = 'Report Group'
        Col.ReadOnly = True
        Col.Width = 162
      end>
  end
  object tsMaskDefs1: TtsMaskDefs
    Masks = <
      item
        Name = 'sysLongDecimal'
        Picture = '[-]*10[#][.##]'
      end>
    Left = 560
    Top = 16
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 320
    Top = 136
    object Enterforeigncurrencybalance1: TMenuItem
      Action = acForeignCurrency
    end
  end
  object ActionList1: TActionList
    Left = 360
    Top = 136
    object acForeignCurrency: TAction
      Caption = 'Enter foreign currency balance'
      OnExecute = acForeignCurrencyExecute
    end
  end
end
