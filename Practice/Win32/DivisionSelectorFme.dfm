object fmeDivisionSelector: TfmeDivisionSelector
  Scaled = False
Left = 0
  Top = 0
  Width = 460
  Height = 269
  TabOrder = 0
  object lblSelectDivisions: TLabel
    Left = 4
    Top = 4
    Width = 297
    Height = 13
    Caption = 
      'Select the divisions that you wish be to included in this report' +
      ':'
  end
  object chkDivisions: TCheckListBox
    Left = 4
    Top = 28
    Width = 369
    Height = 186
    OnClickCheck = chkDivisionsClickCheck
    Ctl3D = True
    IntegralHeight = True
    ItemHeight = 13
    Items.Strings = (
      'Division 1'
      'Division 2'
      'Division 3')
    ParentCtl3D = False
    TabOrder = 0
  end
  object btnSelectAllDivisions: TButton
    Left = 380
    Top = 28
    Width = 75
    Height = 25
    Caption = 'Select &All'
    TabOrder = 1
    OnClick = btnSelectAllDivisionsClick
  end
  object btnClearAllDivisions: TButton
    Left = 380
    Top = 60
    Width = 75
    Height = 25
    Caption = '&Clear All'
    TabOrder = 2
    OnClick = btnClearAllDivisionsClick
  end
  object chkSplitByDivision: TCheckBox
    Left = 4
    Top = 224
    Width = 179
    Height = 17
    Caption = 'Split Report by Di&vision'
    TabOrder = 3
  end
end
