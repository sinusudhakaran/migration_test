object dlgFinancialYearStarts: TdlgFinancialYearStarts
  Scaled = False
Left = 226
  Top = 197
  Width = 560
  Height = 216
  BorderIcons = [biSystemMenu]
  Caption = 'Change Financial Year Start Date'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    552
    182)
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 522
    Height = 16
    Caption = 
      'Please enter the Financial Year Start Date that you wish to assi' +
      'gn to the selected client(s)'
  end
  object Label2: TLabel
    Left = 16
    Top = 48
    Width = 121
    Height = 16
    Caption = 'Financial Year starts'
  end
  object Label3: TLabel
    Left = 16
    Top = 104
    Width = 479
    Height = 16
    Caption = 
      'Note: If you are using End of Year Balances then you will still ' +
      'need to do a rollover'
  end
  object Label4: TLabel
    Left = 16
    Top = 124
    Width = 95
    Height = 16
    Caption = 'for these clients.'
  end
  object cmbStartMonth: TComboBox
    Left = 148
    Top = 44
    Width = 125
    Height = 24
    Style = csDropDownList
    ItemHeight = 16
    TabOrder = 0
  end
  object spnStartYear: TRzSpinEdit
    Left = 276
    Top = 44
    Width = 73
    Height = 24
    Max = 2070
    Min = 1980
    Value = 2002
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 388
    Top = 152
    Width = 77
    Height = 25
    Anchors = [akRight, akBottom]
    BiDiMode = bdLeftToRight
    Caption = '&OK'
    Default = True
    ModalResult = 1
    ParentBiDiMode = False
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 472
    Top = 152
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    BiDiMode = bdLeftToRight
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    ParentBiDiMode = False
    TabOrder = 3
  end
end
