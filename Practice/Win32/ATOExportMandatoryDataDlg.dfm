object ATOWarningdlg: TATOWarningdlg
  Left = 0
  Top = 0
  Caption = 'Warnings'
  ClientHeight = 321
  ClientWidth = 714
  Color = clBtnFace
  Constraints.MinHeight = 180
  Constraints.MinWidth = 400
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    714
    321)
  PixelsPerInch = 96
  TextHeight = 13
  object lblHeadingLine: TLabel
    Left = 8
    Top = 8
    Width = 227
    Height = 16
    Caption = 'The following details need to be added:'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object btnOk: TButton
    Left = 633
    Top = 290
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&OK'
    Default = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ModalResult = 1
    ParentFont = False
    TabOrder = 0
  end
  object lstWarnings: TListBox
    Left = 8
    Top = 32
    Width = 699
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ItemHeight = 16
    ParentFont = False
    TabOrder = 1
  end
end
