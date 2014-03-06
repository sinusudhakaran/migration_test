object frmClientNotes: TfrmClientNotes
  Scaled = False
Left = 313
  Top = 337
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Client File Notes'
  ClientHeight = 212
  ClientWidth = 425
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object meNotes: TMemo
    Left = 0
    Top = 0
    Width = 425
    Height = 170
    Align = alClient
    Ctl3D = False
    Lines.Strings = (
      'meNotes')
    MaxLength = 20000
    ParentCtl3D = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 170
    Width = 425
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      425
      42)
    object chkShowOnOpen: TCheckBox
      Left = 6
      Top = 11
      Width = 259
      Height = 17
      Caption = 'Show notes when openin&g this client'
      TabOrder = 0
    end
    object btnOK: TButton
      Left = 344
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Cancel = True
      Caption = '&OK'
      Default = True
      TabOrder = 1
      OnClick = btnOKClick
    end
  end
end
