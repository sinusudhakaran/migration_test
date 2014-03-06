object FmeClientSelect: TFmeClientSelect
  Left = 0
  Top = 0
  Width = 629
  Height = 142
  TabOrder = 0
  object grpSettings: TGroupBox
    Left = 4
    Top = 4
    Width = 621
    Height = 134
    Caption = ' Select Clients'
    TabOrder = 0
    object lblFrom: TLabel
      Left = 139
      Top = 76
      Width = 82
      Height = 13
      Caption = '&From Client Code'
      FocusControl = edtFromCode
    end
    object lblTo: TLabel
      Left = 400
      Top = 77
      Width = 70
      Height = 13
      Caption = 'T&o Client Code'
      FocusControl = edtToCode
    end
    object Label5: TLabel
      Left = 16
      Top = 24
      Width = 76
      Height = 13
      Caption = 'Sort Reports by'
    end
    object btnFromLookup: TSpeedButton
      Left = 363
      Top = 72
      Width = 23
      Height = 25
      Hint = 'Lookup '#39'from'#39' range'
      OnClick = btnFromLookupClick
    end
    object btnToLookup: TSpeedButton
      Left = 591
      Top = 72
      Width = 23
      Height = 25
      Hint = 'Lookup '#39'to'#39' range'
      OnClick = btnToLookupClick
    end
    object lblSelection: TLabel
      Left = 139
      Top = 105
      Width = 114
      Height = 13
      Caption = 'Selected Staff Members'
      FocusControl = edtSelection
    end
    object btnSelect: TSpeedButton
      Left = 591
      Top = 103
      Width = 23
      Height = 25
      Hint = 'Select codes'
      OnClick = btnSelectClick
    end
    object edtFromCode: TEdit
      Left = 273
      Top = 73
      Width = 89
      Height = 24
      BorderStyle = bsNone
      CharCase = ecUpperCase
      MaxLength = 8
      TabOrder = 3
    end
    object edtToCode: TEdit
      Left = 501
      Top = 72
      Width = 89
      Height = 24
      BorderStyle = bsNone
      CharCase = ecUpperCase
      MaxLength = 8
      TabOrder = 4
    end
    object edtSelection: TEdit
      Left = 273
      Top = 103
      Width = 317
      Height = 24
      BorderStyle = bsNone
      CharCase = ecUpperCase
      TabOrder = 6
    end
    object rbSelectAll: TRadioButton
      Left = 15
      Top = 47
      Width = 125
      Height = 16
      Caption = 'All Staff Members'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = rbRangeClick
    end
    object rbRange: TRadioButton
      Left = 15
      Top = 76
      Width = 113
      Height = 16
      Caption = 'Use Range'
      TabOrder = 2
      OnClick = rbRangeClick
    end
    object rbSelection: TRadioButton
      Left = 15
      Top = 105
      Width = 113
      Height = 16
      Caption = 'Use Selection'
      TabOrder = 5
      OnClick = rbRangeClick
    end
    object Panel1: TPanel
      Left = 134
      Top = 15
      Width = 480
      Height = 32
      BevelOuter = bvNone
      TabOrder = 0
      object rbClient: TRadioButton
        Left = 5
        Top = 9
        Width = 62
        Height = 17
        Caption = 'Cl&ient'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbClientClick
      end
      object rbStaffMember: TRadioButton
        Left = 88
        Top = 9
        Width = 101
        Height = 17
        Caption = 'S&taff Member'
        TabOrder = 1
        OnClick = rbClientClick
      end
      object rbGroup: TRadioButton
        Left = 209
        Top = 9
        Width = 69
        Height = 17
        Caption = '&Group'
        TabOrder = 2
        OnClick = rbClientClick
      end
      object rbClientType: TRadioButton
        Left = 291
        Top = 9
        Width = 98
        Height = 17
        Caption = 'Client T&ype'
        TabOrder = 3
        OnClick = rbClientClick
      end
    end
  end
end
