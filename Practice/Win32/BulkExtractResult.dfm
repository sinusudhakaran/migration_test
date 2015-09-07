object frmBulkResult: TfrmBulkResult
  Left = 0
  Top = 0
  Caption = 'frmBulkResult'
  ClientHeight = 442
  ClientWidth = 652
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object pButtons: TPanel
    Left = 0
    Top = 401
    Width = 652
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      652
      41)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 652
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnOK: TButton
      Left = 489
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Continue'
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 570
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnLog: TButton
      Left = 8
      Top = 6
      Width = 75
      Height = 25
      Caption = 'View Log'
      TabOrder = 2
      OnClick = btnLogClick
    end
  end
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 652
    Height = 401
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = bsNone
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    TabOrder = 1
  end
end
