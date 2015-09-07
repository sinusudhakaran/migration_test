object dlgEditGroup: TdlgEditGroup
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Group Details'
  ClientHeight = 147
  ClientWidth = 508
  Color = clWhite
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lblField: TLabel
    Left = 14
    Top = 41
    Width = 59
    Height = 13
    Caption = 'Group &Name'
    FocusControl = eFullName
  end
  object Lcode: TLabel
    Left = 14
    Top = 11
    Width = 25
    Height = 13
    Caption = 'Co&de'
    Visible = False
  end
  object eFullName: TEdit
    Left = 120
    Top = 38
    Width = 377
    Height = 24
    Hint = 'Enter a description of the Group'
    BorderStyle = bsNone
    MaxLength = 60
    TabOrder = 1
    Text = 'eFullName'
  end
  object eCode: TEdit
    Left = 120
    Top = 8
    Width = 148
    Height = 25
    BorderStyle = bsNone
    MaxLength = 8
    TabOrder = 0
    Text = 'eCode'
    Visible = False
  end
  object cbCompleted: TCheckBox
    Left = 120
    Top = 72
    Width = 99
    Height = 18
    Caption = 'Co&mpleted'
    TabOrder = 2
    Visible = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 106
    Width = 508
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 3
    ExplicitTop = 128
    DesignSize = (
      508
      41)
    object Shape1: TShape
      Left = 0
      Top = 0
      Width = 508
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnOK: TButton
      Left = 341
      Top = 8
      Width = 77
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
      ExplicitLeft = 325
    end
    object btnCancel: TButton
      Left = 424
      Top = 8
      Width = 76
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 408
    end
  end
end
