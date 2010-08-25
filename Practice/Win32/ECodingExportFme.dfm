object fmeECodingExport: TfmeECodingExport
  Left = 0
  Top = 0
  Width = 480
  Height = 318
  Margins.Left = 0
  Margins.Top = 0
  Margins.Right = 0
  Margins.Bottom = 0
  TabOrder = 0
  TabStop = True
  object Label5: TLabel
    Left = 8
    Top = 12
    Width = 35
    Height = 13
    Caption = '&Include'
    FocusControl = cmbInclude
  end
  object lblWhichClients: TLabel
    Left = 8
    Top = 188
    Width = 319
    Height = 13
    Caption = 
      'Some columns are optional. Which columns do your clients require' +
      '?'
  end
  object lblPassword: TLabel
    Left = 8
    Top = 260
    Width = 219
    Height = 13
    Caption = 'File Access &Password (Maximum 8 characters)'
  end
  object lblWebSpace: TLabel
    Left = 8
    Top = 260
    Width = 107
    Height = 13
    Caption = 'Choose a Secure Area'
    Visible = False
  end
  object lblConfirm: TLabel
    Left = 8
    Top = 290
    Width = 86
    Height = 13
    Caption = 'Confir&m Password'
    FocusControl = edtConfirm
  end
  object lNotify: TLabel
    Left = 8
    Top = 235
    Width = 86
    Height = 13
    Caption = 'Email Notifications'
    Visible = False
  end
  object cmbInclude: TComboBox
    Left = 80
    Top = 9
    Width = 229
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    Items.Strings = (
      'All Entries'
      'Uncoded Only')
  end
  object chkIncludeChart: TCheckBox
    Left = 80
    Top = 40
    Width = 317
    Height = 17
    Caption = 'Include a &Chart of Accounts'
    Checked = True
    State = cbChecked
    TabOrder = 1
    OnClick = chkIncludeChartClick
  end
  object chkIncludePayees: TCheckBox
    Left = 80
    Top = 67
    Width = 317
    Height = 17
    Caption = 'Include a Pa&yee List'
    Checked = True
    State = cbChecked
    TabOrder = 2
  end
  object chkShowQuantity: TCheckBox
    Left = 380
    Top = 212
    Width = 73
    Height = 17
    Caption = '&Quantity'
    Checked = True
    State = cbChecked
    TabOrder = 9
  end
  object chkShowGST: TCheckBox
    Left = 190
    Top = 212
    Width = 53
    Height = 17
    Caption = '&GST'
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
  object chkShowTaxInv: TCheckBox
    Left = 280
    Top = 212
    Width = 93
    Height = 17
    Caption = 'Ta&x Invoice'
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object chkShowAccount: TCheckBox
    Left = 80
    Top = 212
    Width = 81
    Height = 17
    Caption = '&Account'
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = chkShowAccountClick
  end
  object edtPassword: TEdit
    Left = 280
    Top = 256
    Width = 119
    Height = 21
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Wingdings'
    Font.Style = []
    MaxLength = 8
    ParentCtl3D = False
    ParentFont = False
    PasswordChar = #376
    TabOrder = 10
  end
  object chkAddUPIs: TCheckBox
    Left = 80
    Top = 148
    Width = 317
    Height = 17
    Caption = 'Allow your client to add &UPCs/UPDs?'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object cmbWebSpace: TComboBox
    Left = 190
    Top = 256
    Width = 278
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 11
    Visible = False
  end
  object edtConfirm: TEdit
    Left = 280
    Top = 286
    Width = 119
    Height = 21
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Wingdings'
    Font.Style = []
    MaxLength = 8
    ParentCtl3D = False
    ParentFont = False
    PasswordChar = #376
    TabOrder = 12
  end
  object ChkSuperfund: TCheckBox
    Left = 80
    Top = 121
    Width = 317
    Height = 17
    Caption = 'Include Franking Credits'
    TabOrder = 4
  end
  object chkIncludeJobs: TCheckBox
    Left = 80
    Top = 94
    Width = 317
    Height = 17
    Caption = 'Include a &Job List'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object ChkNotifyClient: TCheckBox
    Left = 80
    Top = 260
    Width = 317
    Height = 17
    Caption = 'Send to the client, on export'
    TabOrder = 13
    Visible = False
  end
  object ChkNotifyMe: TCheckBox
    Left = 80
    Top = 288
    Width = 388
    Height = 17
    Caption = 'Send to the practice, when transactions are available '
    TabOrder = 14
    Visible = False
  end
end
