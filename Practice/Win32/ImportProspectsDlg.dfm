object frmImportProspects: TfrmImportProspects
  Left = 439
  Top = 249
  BorderStyle = bsDialog
  Caption = 'Import Prospects'
  ClientHeight = 446
  ClientWidth = 403
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlOutlook: TPanel
    Left = 0
    Top = 91
    Width = 403
    Height = 317
    Align = alClient
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 2
    object clbContacts: TCheckListBox
      Left = 0
      Top = 25
      Width = 403
      Height = 251
      Hint = 'Select the Outlook Contacts to import as propsects'
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      ItemHeight = 13
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = clbContactsClick
    end
    object pnlTitle2: TPanel
      Left = 0
      Top = 0
      Width = 403
      Height = 25
      Align = alTop
      Caption = 'Enable the check box for Outlook contacts to import'
      TabOrder = 1
    end
    object Panel1: TPanel
      Left = 0
      Top = 276
      Width = 403
      Height = 41
      Align = alBottom
      TabOrder = 2
      object btnCheck: TButton
        Left = 32
        Top = 8
        Width = 75
        Height = 25
        Hint = 'Tick all the Contacts'
        Caption = 'Enable All'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = btnCheckClick
      end
      object btnClear: TButton
        Left = 136
        Top = 8
        Width = 75
        Height = 25
        Hint = 'Untick all the Contacts'
        Caption = 'Clear All'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnClearClick
      end
      object chkSelect: TCheckBox
        Left = 240
        Top = 12
        Width = 161
        Height = 17
        Hint = 'Tick the selected Contacts'
        Caption = 'Enable/Clear Selection'
        Checked = True
        ParentShowHint = False
        ShowHint = True
        State = cbChecked
        TabOrder = 2
        OnClick = chkSelectClick
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 408
    Width = 403
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOk: TButton
      Left = 232
      Top = 7
      Width = 75
      Height = 25
      Hint = 'Import now'
      Caption = '&OK'
      Default = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 320
      Top = 7
      Width = 75
      Height = 25
      Hint = 'Cancel the import'
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object pnlOptions: TPanel
    Left = 0
    Top = 0
    Width = 403
    Height = 91
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblImport: TLabel
      Left = 12
      Top = 12
      Width = 59
      Height = 13
      Caption = 'Import From'
    end
    object lblFilename: TLabel
      Left = 12
      Top = 51
      Width = 45
      Height = 13
      Caption = 'File name'
    end
    object btnFromFile: TSpeedButton
      Left = 353
      Top = 47
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      ParentShowHint = False
      ShowHint = True
      OnClick = btnFromFileClick
    end
    object cmbImport: TComboBox
      Left = 94
      Top = 9
      Width = 253
      Height = 21
      Hint = 'Choose where to import from'
      Style = csDropDownList
      ItemHeight = 0
      ItemIndex = 0
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Text = 'CSV File'
      OnChange = cmbImportChange
      Items.Strings = (
        'CSV File'
        'Outlook Contacts')
    end
    object edtCSV: TEdit
      Left = 94
      Top = 47
      Width = 253
      Height = 21
      Hint = 'Enter the filename to import from'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object chkHeaders: TCheckBox
      Left = 12
      Top = 74
      Width = 239
      Height = 17
      Hint = 'Tick if the first row contains column headers'
      Caption = 'First row contains column headers'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Visible = False
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'csv'
    Filter = 'CSV Files (*.csv)|*.csv|All Files (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 344
    Top = 80
  end
end
