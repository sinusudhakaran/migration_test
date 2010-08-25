object fmGalleryFilterGroups: TfmGalleryFilterGroups
  Left = 0
  Top = 0
  AutoScroll = False
  BorderStyle = bsSizeToolWin
  Caption = 'fmGalleryFilterGroups'
  ClientHeight = 265
  ClientWidth = 423
  Color = clBtnFace
  Constraints.MinHeight = 250
  Constraints.MinWidth = 350
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 306
    Height = 250
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = ' Groups '
    TabOrder = 0
    object clbGroups: TCheckListBox
      Left = 8
      Top = 16
      Width = 289
      Height = 225
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 0
    end
  end
  object btnOk: TButton
    Left = 320
    Top = 23
    Width = 95
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 320
    Top = 54
    Width = 95
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
