object dlgSelectList: TdlgSelectList
  Scaled = False
Left = 402
  Top = 232
  Anchors = [akRight, akBottom]
  BorderIcons = [biSystemMenu]
  Caption = 'Select'
  ClientHeight = 344
  ClientWidth = 434
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object lvList: TListView
    Left = 0
    Top = 0
    Width = 434
    Height = 303
    Align = alClient
    Columns = <
      item
        AutoSize = True
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvListDblClick
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 303
    Width = 434
    Height = 41
    Align = alBottom
    Anchors = [akRight, akBottom]
    TabOrder = 1
    DesignSize = (
      434
      41)
    object btnOK: TButton
      Left = 267
      Top = 10
      Width = 77
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 351
      Top = 10
      Width = 77
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
