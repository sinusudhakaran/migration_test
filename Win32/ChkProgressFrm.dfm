object frmChkProgress: TfrmChkProgress
  Left = 482
  Top = 393
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Checkout Progress'
  ClientHeight = 357
  ClientWidth = 574
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    574
    357)
  PixelsPerInch = 96
  TextHeight = 13
  object mProgress: TMemo
    Left = 4
    Top = 5
    Width = 567
    Height = 318
    TabStop = False
    BorderStyle = bsNone
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    WantTabs = True
    WordWrap = False
  end
  object btnOK: TButton
    Left = 491
    Top = 329
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&OK'
    TabOrder = 0
    OnClick = btnOKClick
  end
end
