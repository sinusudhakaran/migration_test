object frmNewCAF: TfrmNewCAF
  Left = 0
  Top = 0
  Caption = 'Customer Authority Form Details'
  ClientHeight = 587
  ClientWidth = 832
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    832
    587)
  PixelsPerInch = 96
  TextHeight = 13
  object btnFile: TButton
    Left = 8
    Top = 555
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&File'
    TabOrder = 0
    OnClick = btnFileClick
  end
  object btnEmail: TButton
    Left = 97
    Top = 555
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&E-mail'
    TabOrder = 1
    OnClick = btnEmailClick
  end
  object btnPrint: TButton
    Left = 186
    Top = 555
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = '&Print'
    TabOrder = 2
    OnClick = btnPrintClick
  end
  object btnResetForm: TButton
    Left = 669
    Top = 555
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Reset Form'
    TabOrder = 3
    OnClick = btnResetFormClick
  end
  object btnCancel: TButton
    Left = 750
    Top = 555
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 4
  end
  object PrintDialog: TPrintDialog
    Options = [poPageNums, poSelection]
    Left = 624
    Top = 552
  end
end
