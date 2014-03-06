object dlgEnterPIN: TdlgEnterPIN
  Scaled = False
Left = 312
  Top = 238
  Caption = 'Enter P.I.N'
  ClientHeight = 163
  ClientWidth = 331
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    331
    163)
  PixelsPerInch = 96
  TextHeight = 13
  object lblMessage: TLabel
    Left = 8
    Top = 8
    Width = 305
    Height = 73
    AutoSize = False
    Caption = 'You must enter your PIN number...'
    WordWrap = True
  end
  object Label2: TLabel
    Left = 8
    Top = 87
    Width = 17
    Height = 13
    Caption = '&PIN'
    FocusControl = ePIN
  end
  object ePIN: TEdit
    Left = 48
    Top = 87
    Width = 81
    Height = 21
    MaxLength = 4
    TabOrder = 0
    Text = 'ePIN'
  end
  object btnOK: TButton
    Left = 163
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
    ExplicitLeft = 231
  end
  object btnCancel: TButton
    Left = 243
    Top = 132
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
    ExplicitLeft = 311
  end
end
