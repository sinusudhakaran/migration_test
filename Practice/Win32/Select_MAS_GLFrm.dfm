object frmSelectMas_GL: TfrmSelectMas_GL
  Left = 456
  Top = 261
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Select Ledger'
  ClientHeight = 342
  ClientWidth = 714
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object lvLedgers: TListView
    Left = 0
    Top = 41
    Width = 714
    Height = 282
    HelpType = htKeyword
    Align = alClient
    Columns = <
      item
        Caption = 'Client'
        Width = 100
      end
      item
        Caption = 'Name'
        Width = 300
      end
      item
        AutoSize = True
        Caption = 'Location'
      end>
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = lvLedgersDblClick
    OnKeyPress = lvLedgersKeyPress
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 714
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      714
      41)
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 163
      Height = 16
      Caption = 'Solution 6 System Directory'
    end
    object btnSol6Dir: TSpeedButton
      Left = 542
      Top = 8
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      Anchors = [akLeft, akBottom]
      OnClick = btnSol6DirClick
    end
    object edtSol64Dir: TEdit
      Left = 184
      Top = 8
      Width = 353
      Height = 24
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      Text = 'C:\SOL64'
      OnKeyPress = edtSol64DirKeyPress
    end
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 323
    Width = 714
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
