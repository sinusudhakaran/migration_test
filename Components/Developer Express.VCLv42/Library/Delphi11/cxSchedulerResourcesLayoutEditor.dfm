object fmResourcesLayoutEditor: TfmResourcesLayoutEditor
  Left = 249
  Top = 230
  ActiveControl = clbResources
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Resource editor'
  ClientHeight = 227
  ClientWidth = 301
  Color = clBtnFace
  Constraints.MinHeight = 160
  Constraints.MinWidth = 220
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TcxButton
    Left = 210
    Top = 196
    Width = 85
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 0
  end
  object btnUp: TcxButton
    Left = 210
    Top = 8
    Width = 85
    Height = 23
    Anchors = [akTop, akRight]
    Caption = 'Up'
    TabOrder = 1
    OnClick = BtnClick
  end
  object btnDown: TcxButton
    Tag = 1
    Left = 210
    Top = 40
    Width = 85
    Height = 23
    Anchors = [akTop, akRight]
    Caption = 'Down'
    TabOrder = 2
    OnClick = BtnClick
  end
  object clbResources: TcxCheckListBox
    Left = 8
    Top = 8
    Width = 195
    Height = 212
    Anchors = [akLeft, akTop, akRight, akBottom]
    EditValueFormat = cvfIndices
    Items = <>
    TabOrder = 3
    OnClick = clbResourcesClick
    OnDragOver = clbResourcesDragOver
    OnEditValueChanged = clbResourcesEditValueChanged
    OnKeyDown = clbResourcesKeyDown
    OnMouseDown = clbResourcesMouseDown
  end
end
