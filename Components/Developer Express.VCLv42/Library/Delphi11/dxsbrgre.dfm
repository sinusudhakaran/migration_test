object frmSideBarGroupRename: TfrmSideBarGroupRename
  Left = 149
  Top = 197
  BorderIcons = []
  BorderStyle = bsDialog
  ClientHeight = 84
  ClientWidth = 237
  Color = clBtnFace
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 4
    Top = 5
    Width = 227
    Height = 39
    Shape = bsFrame
  end
  object LGroupName: TLabel
    Left = 11
    Top = 18
    Width = 63
    Height = 13
    Caption = 'Group Name:'
  end
  object EGroupName: TEdit
    Left = 80
    Top = 13
    Width = 144
    Height = 21
    TabOrder = 0
    OnKeyUp = EGroupNameKeyUp
  end
  object BOk: TButton
    Left = 6
    Top = 53
    Width = 72
    Height = 22
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object BCancel: TButton
    Left = 83
    Top = 53
    Width = 72
    Height = 22
    Cancel = True
    Caption = 'Can&cel'
    ModalResult = 2
    TabOrder = 2
  end
  object BHelp: TButton
    Left = 160
    Top = 53
    Width = 72
    Height = 22
    Caption = '&Help'
    TabOrder = 3
  end
end
