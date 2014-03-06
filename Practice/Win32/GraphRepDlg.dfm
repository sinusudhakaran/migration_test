object dlgGraphRep: TdlgGraphRep
  Scaled = False
Left = 307
  Top = 200
  BorderStyle = bsDialog
  Caption = 'Graph Options'
  ClientHeight = 369
  ClientWidth = 446
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    446
    369)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 286
    Top = 339
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Vie&w'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 366
    Top = 339
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnSave: TBitBtn
    Left = 205
    Top = 339
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Sa&ve'
    TabOrder = 0
    OnClick = btnSaveClick
  end
  object pcGraph: TPageControl
    Left = 0
    Top = 1
    Width = 441
    Height = 325
    ActivePage = tsOptions
    TabOrder = 3
    object tsOptions: TTabSheet
      Caption = '&Options'
      object Panel1: TPanel
        Left = 4
        Top = 4
        Width = 426
        Height = 97
        TabOrder = 0
        object Label3: TLabel
          Left = 8
          Top = 12
          Width = 104
          Height = 13
          Caption = 'Reporting Year &Starts'
        end
        object lblLast: TLabel
          Left = 8
          Top = 68
          Width = 209
          Height = 13
          Caption = 'This last period of  CODED data is Dec 1998'
        end
        object lblReportingYearStartDate: TLabel
          Left = 144
          Top = 12
          Width = 126
          Height = 13
          Caption = 'lblReportingYearStartDate'
        end
        object Label1: TLabel
          Left = 8
          Top = 40
          Width = 68
          Height = 13
          Caption = 'Report &Ending'
          FocusControl = cmbPeriod
        end
        object cmbPeriod: TComboBox
          Left = 144
          Top = 36
          Width = 241
          Height = 26
          Style = csOwnerDrawFixed
          DropDownCount = 12
          ItemHeight = 20
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
        object cmbStartMonth: TComboBox
          Left = 144
          Top = 8
          Width = 93
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = cmbStartMonthChange
        end
        object spnStartYear: TRzSpinEdit
          Left = 244
          Top = 8
          Width = 73
          Height = 21
          Max = 2070.000000000000000000
          Min = 1980.000000000000000000
          Value = 2002.000000000000000000
          TabOrder = 1
          OnChange = spnStartYearChange
        end
      end
      object Panel2: TPanel
        Left = 4
        Top = 108
        Width = 426
        Height = 101
        TabOrder = 1
        object lblBudget: TLabel
          Left = 8
          Top = 36
          Width = 72
          Height = 13
          Caption = 'Include &Budget'
          FocusControl = cmbBudget
        end
        object lblDivision: TLabel
          Left = 9
          Top = 67
          Width = 36
          Height = 13
          Caption = '&Division'
          FocusControl = cmbDivision
        end
        object chkGST: TCheckBox
          Left = 8
          Top = 8
          Width = 149
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Print &GST Inclusive'
          TabOrder = 0
        end
        object cmbBudget: TComboBox
          Left = 144
          Top = 33
          Width = 241
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnChange = cmbBudgetChange
          Items.Strings = (
            '<none>')
        end
        object cmbDivision: TComboBox
          Left = 144
          Top = 64
          Width = 241
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
        end
      end
      object plInclude: TPanel
        Left = 4
        Top = 215
        Width = 426
        Height = 34
        TabOrder = 2
        object Label2: TLabel
          Left = 9
          Top = 8
          Width = 39
          Height = 13
          Caption = 'Include:'
        end
        object cbLastYear: TCheckBox
          Left = 144
          Top = 8
          Width = 87
          Height = 17
          Caption = 'Last Year'
          TabOrder = 0
        end
        object cbBudget: TCheckBox
          Left = 308
          Top = 8
          Width = 69
          Height = 17
          Caption = 'Budget'
          TabOrder = 1
        end
      end
      object plTrading: TPanel
        Left = 4
        Top = 255
        Width = 426
        Height = 34
        TabOrder = 3
        object Label4: TLabel
          Left = 9
          Top = 8
          Width = 40
          Height = 13
          Caption = 'Trading:'
        end
        object ckSales: TCheckBox
          Left = 84
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Sales'
          TabOrder = 0
        end
        object ckGrossProfit: TCheckBox
          Left = 196
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Gross Profit'
          TabOrder = 1
        end
        object ckNettProfit: TCheckBox
          Left = 308
          Top = 8
          Width = 109
          Height = 17
          Caption = 'Operating Profit'
          TabOrder = 2
        end
      end
    end
    object tsAdvanced: TTabSheet
      Caption = 'A&dvanced'
      ImageIndex = 1
      inline fmeAccountSelector1: TfmeAccountSelector
        Left = -4
        Top = 16
        Width = 434
        Height = 257
        TabOrder = 0
        TabStop = True
        ExplicitLeft = -4
        ExplicitTop = 16
        ExplicitWidth = 434
        ExplicitHeight = 257
        inherited lblSelectAccounts: TLabel
          Left = 12
          Top = 3
          Width = 298
          Caption = 'Select the accounts that you wish to be included in this graph:'
          ExplicitLeft = 12
          ExplicitTop = 3
          ExplicitWidth = 298
        end
        inherited chkAccounts: TCheckListBox
          Left = 12
          Width = 325
          Height = 223
          Hint = 'Enable bank accounts to include in the Report'
          ParentShowHint = False
          ShowHint = True
          ExplicitLeft = 12
          ExplicitWidth = 325
          ExplicitHeight = 223
        end
        inherited btnSelectAllAccounts: TButton
          Left = 358
          Top = 36
          Hint = 'Enable all bank accounts'
          ParentShowHint = False
          ShowHint = True
          ExplicitLeft = 358
          ExplicitTop = 36
        end
        inherited btnClearAllAccounts: TButton
          Left = 358
          Top = 68
          Hint = 'Disable all bank accounts'
          ExplicitLeft = 358
          ExplicitTop = 68
        end
      end
    end
  end
  object OvcController1: TOvcController
    EntryCommands.TableList = (
      'Default'
      True
      ()
      'WordStar'
      False
      ()
      'Grid'
      False
      ())
    Epoch = 1900
    Left = 12
    Top = 336
  end
end
