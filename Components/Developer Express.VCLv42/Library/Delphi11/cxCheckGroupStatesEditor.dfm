object cxCheckGroupStatesEditorDlg: TcxCheckGroupStatesEditorDlg
  Left = 260
  Top = 283
  BorderStyle = bsDialog
  Caption = 'cxCheckGroup - CheckStates editor'
  ClientHeight = 238
  ClientWidth = 436
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  Position = poScreenCenter
  TextHeight = 13
  object clbStates: TcxCheckListBox
    Left = 0
    Top = 0
    Width = 346
    Height = 238
    Align = alClient
    Columns = 0
    EditValue = 0
    EditValueFormat = cvfCaptions
    Items = <>
    ParentColor = False
    ScrollWidth = 0
    Style.LookAndFeel.Kind = lfUltraFlat
    Style.LookAndFeel.NativeStyle = True
    TabOrder = 0
    TabWidth = 0
  end
  object Panel1: TPanel
    Left = 346
    Top = 0
    Width = 90
    Height = 238
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 1
    object btnOK: TcxButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
      LookAndFeel.Kind = lfUltraFlat
      LookAndFeel.NativeStyle = True
      UseSystemPaint = False
    end
    object btnCancel: TcxButton
      Left = 8
      Top = 40
      Width = 75
      Height = 25
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      LookAndFeel.Kind = lfUltraFlat
      LookAndFeel.NativeStyle = True
      UseSystemPaint = False
    end
  end
end
