object AddReportFrm: TAddReportFrm
  Scaled = False
Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Add Favourite Report'
  ClientHeight = 345
  ClientWidth = 556
  Color = clBtnFace
  Constraints.MinHeight = 213
  Constraints.MinWidth = 213
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyPress = FormKeyPress
  DesignSize = (
    556
    345)
  PixelsPerInch = 96
  TextHeight = 13
  object tvMenu: TTreeView
    Left = 8
    Top = 8
    Width = 540
    Height = 289
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideSelection = False
    Indent = 19
    ReadOnly = True
    RightClickSelect = True
    RowSelect = True
    TabOrder = 0
    OnChange = tvMenuChange
    OnCollapsing = tvMenuCollapsing
    OnDblClick = tvMenuDblClick
    OnExpanding = tvMenuCollapsing
    OnKeyPress = tvMenuKeyPress
    Items.NodeData = {
      0105000000330000000000000000000000FFFFFFFFFFFFFFFF00000000000000
      000D43006F00640069006E00670020005200650070006F007200740033000000
      0000000000000000FFFFFFFFFFFFFFFF00000000000000000D4C006500640067
      006500720020005200650070006F0072007400390000000000000000000000FF
      FFFFFFFFFFFFFF000000000300000010430061007300680046006C006F007700
      20005200650070006F00720074007300290000000000000000000000FFFFFFFF
      FFFFFFFF00000000000000000831002000410063007400750061006C003F0000
      000000000000000000FFFFFFFFFFFFFFFF000000000000000013320020004100
      63007400750061006C00200061006E0064002000420075006400670065007400
      530000000000000000000000FFFFFFFFFFFFFFFF00000000000000001D330020
      00410063007400750061006C002C002000420075006400670065007400200061
      006E006400200076006100720069006E00610063006500190000000000000000
      000000FFFFFFFFFFFFFFFF000000000000000000190000000000000000000000
      FFFFFFFFFFFFFFFF000000000000000000}
  end
  object btnCancel: TButton
    Left = 474
    Top = 312
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object btnOk: TButton
    Left = 391
    Top = 312
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Add Report'
    TabOrder = 2
    OnClick = btnOkClick
  end
end
