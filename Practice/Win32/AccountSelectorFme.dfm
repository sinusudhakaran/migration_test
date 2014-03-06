object fmeAccountSelector: TfmeAccountSelector
  Left = 0
  Top = 0
  Width = 460
  Height = 188
  TabOrder = 0
  TabStop = True
  object lblSelectAccounts: TLabel
    Left = 4
    Top = 4
    Width = 300
    Height = 13
    Caption = 'Select the accounts that you wish to be included in this report:'
  end
  object chkAccounts: TCheckListBox
    Left = 4
    Top = 28
    Width = 369
    Height = 158
    Ctl3D = False
    IntegralHeight = True
    ItemHeight = 13
    Items.Strings = (
      'Select accounts'
      '981234533234  Chalet de Niege'
      '012329342343  My Other Accounts'
      'Cash Journals')
    ParentCtl3D = False
    TabOrder = 0
  end
  object btnSelectAllAccounts: TButton
    Left = 380
    Top = 28
    Width = 75
    Height = 25
    Caption = 'Select &All'
    TabOrder = 1
    OnClick = btnSelectAllAccountsClick
  end
  object btnClearAllAccounts: TButton
    Left = 380
    Top = 60
    Width = 75
    Height = 25
    Caption = '&Clear All'
    TabOrder = 2
    OnClick = btnClearAllAccountsClick
  end
end
