object frmChkProgress: TfrmChkProgress
  Scaled = False
Left = 482
  Top = 393
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Checkout Progress'
  ClientHeight = 411
  ClientWidth = 574
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnResize = FormResize
  DesignSize = (
    574
    411)
  PixelsPerInch = 96
  TextHeight = 13
  object lblStatus: TLabel
    Left = 8
    Top = 352
    Width = 31
    Height = 13
    Caption = 'Status'
  end
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
    Left = 475
    Top = 378
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&OK'
    TabOrder = 0
    OnClick = btnOKClick
    ExplicitTop = 358
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 329
    Width = 558
    Height = 17
    TabOrder = 2
  end
end
