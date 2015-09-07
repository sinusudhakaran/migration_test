object dlgTrialBalanceOptions: TdlgTrialBalanceOptions
  Left = 379
  Top = 239
  BorderStyle = bsDialog
  Caption = 'Trial Balance Report'
  ClientHeight = 223
  ClientWidth = 504
  Color = clWhite
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 36
    Width = 104
    Height = 13
    Caption = 'Reporting Year Starts'
  end
  object Label4: TLabel
    Left = 14
    Top = 85
    Width = 87
    Height = 13
    Caption = 'Trial Balance as at'
  end
  object lblLast: TLabel
    Left = 164
    Top = 108
    Width = 209
    Height = 13
    Alignment = taRightJustify
    Caption = 'This last period of  CODED data is Dec 1998'
  end
  object cmbStartMonth: TComboBox
    Left = 156
    Top = 32
    Width = 124
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cmbStartMonthChange
  end
  object spnStartYear: TRzSpinEdit
    Left = 292
    Top = 32
    Width = 81
    Height = 21
    Max = 2070.000000000000000000
    Min = 1980.000000000000000000
    Value = 2002.000000000000000000
    TabOrder = 1
    OnChange = spnStartYearChange
  end
  object cmbPeriod: TComboBox
    Left = 156
    Top = 80
    Width = 217
    Height = 22
    Style = csOwnerDrawFixed
    DropDownCount = 12
    ItemHeight = 16
    TabOrder = 2
    OnDrawItem = cmbPeriodDrawItem
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7'
      '8'
      '9'
      '10'
      '11'
      '12')
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 180
    Width = 504
    Height = 43
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 5
    DesignSize = (
      504
      43)
    object BevelBorder: TBevel
      Left = -6
      Top = 1
      Width = 510
      Height = 5
      Anchors = [akLeft, akBottom]
      Shape = bsTopLine
      ExplicitTop = 3
    end
    object btnPrint: TButton
      Left = 335
      Top = 10
      Width = 75
      Height = 25
      Caption = '&Print'
      ModalResult = 1
      TabOrder = 4
      OnClick = btnPrintClick
    end
    object btnCancel: TButton
      Left = 416
      Top = 10
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 5
      OnClick = btnCancelClick
    end
    object btnPreview: TButton
      Left = 12
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Pre&view'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 92
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnSave: TBitBtn
      Left = 254
      Top = 10
      Width = 75
      Height = 25
      Caption = 'Sa&ve'
      TabOrder = 3
      OnClick = btnSaveClick
    end
    object btnEmail: TButton
      Left = 173
      Top = 10
      Width = 75
      Height = 25
      Caption = 'E&mail'
      TabOrder = 2
      OnClick = btnEmailClick
    end
  end
  object chkIncludeCodes: TCheckBox
    Left = 16
    Top = 151
    Width = 153
    Height = 17
    Alignment = taLeftJustify
    Caption = 'Include Chart Codes'
    TabOrder = 3
  end
  object chkGSTInclusive: TCheckBox
    Left = 212
    Top = 151
    Width = 161
    Height = 17
    Alignment = taLeftJustify
    Caption = 'GST Inclusive'
    TabOrder = 4
  end
end
