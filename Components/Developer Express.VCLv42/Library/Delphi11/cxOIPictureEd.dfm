object cxfmPictureEditor: TcxfmPictureEditor
  Left = 295
  Top = 158
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Picture Editor'
  ClientHeight = 326
  ClientWidth = 368
  Color = clBtnFace
  Constraints.MinHeight = 220
  Constraints.MinWidth = 200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 287
    Width = 352
    Height = 4
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsTopLine
  end
  object Image: TcxImage
    Left = 8
    Top = 8
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 8
    Height = 273
    Width = 268
  end
  object btnCancel: TcxButton
    Left = 264
    Top = 297
    Width = 81
    Height = 22
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object btnOk: TcxButton
    Left = 178
    Top = 296
    Width = 80
    Height = 22
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnClear: TcxButton
    Left = 282
    Top = 120
    Width = 79
    Height = 23
    Anchors = [akTop, akRight]
    Caption = 'C&lear'
    TabOrder = 2
    OnClick = btnClearClick
  end
  object btnCopy: TcxButton
    Left = 282
    Top = 64
    Width = 79
    Height = 23
    Anchors = [akTop, akRight]
    Caption = '&Copy'
    TabOrder = 3
    OnClick = btnCopyClick
  end
  object btnLoad: TcxButton
    Left = 282
    Top = 8
    Width = 79
    Height = 23
    Anchors = [akTop, akRight]
    Caption = '&Load...'
    TabOrder = 4
    OnClick = btnLoadClick
  end
  object btnPaste: TcxButton
    Left = 282
    Top = 92
    Width = 79
    Height = 23
    Anchors = [akTop, akRight]
    Caption = '&Paste'
    TabOrder = 5
    OnClick = btnPasteClick
  end
  object btnSave: TcxButton
    Left = 282
    Top = 36
    Width = 79
    Height = 23
    Anchors = [akTop, akRight]
    Caption = '&Save...'
    TabOrder = 6
    OnClick = btnSaveClick
  end
  object Panel1: TPanel
    Left = 24
    Top = 24
    Width = 236
    Height = 241
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Color = clWindow
    TabOrder = 7
  end
end
