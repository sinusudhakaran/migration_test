object dlgGraphRep: TdlgGraphRep
  Left = 307
  Top = 200
  BorderStyle = bsDialog
  Caption = 'Graph Options'
  ClientHeight = 340
  ClientWidth = 446
  Color = clWhite
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pcGraph: TPageControl
    Left = 0
    Top = 0
    Width = 446
    Height = 304
    ActivePage = tsOptions
    Align = alClient
    Style = tsFlatButtons
    TabOrder = 0
    ExplicitTop = 1
    ExplicitWidth = 441
    ExplicitHeight = 325
    object tsOptions: TTabSheet
      Caption = '&Options'
      ExplicitWidth = 433
      ExplicitHeight = 294
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 438
        Height = 97
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        ExplicitWidth = 433
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
        object Shape1: TShape
          Left = 0
          Top = 96
          Width = 438
          Height = 1
          Align = alBottom
          Pen.Color = clSilver
          ExplicitLeft = 1
          ExplicitTop = 87
          ExplicitWidth = 431
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
        Left = 0
        Top = 97
        Width = 438
        Height = 101
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        ExplicitWidth = 433
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
        object Shape2: TShape
          Left = 0
          Top = 100
          Width = 438
          Height = 1
          Align = alBottom
          Pen.Color = clSilver
          ExplicitLeft = 1
          ExplicitTop = 91
          ExplicitWidth = 431
        end
        object chkGST: TCheckBox
          Left = 8
          Top = 8
          Width = 149
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Print &GST Inclusive'
          Color = clWhite
          ParentColor = False
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
        Left = 0
        Top = 198
        Width = 438
        Height = 40
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 2
        object Label2: TLabel
          Left = 9
          Top = 8
          Width = 39
          Height = 13
          Caption = 'Include:'
        end
        object Shape3: TShape
          Left = 0
          Top = 39
          Width = 438
          Height = 1
          Align = alBottom
          Pen.Color = clSilver
          ExplicitLeft = 1
          ExplicitTop = 24
          ExplicitWidth = 431
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
        Left = 0
        Top = 238
        Width = 438
        Height = 34
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 3
        ExplicitTop = 237
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
          Color = clWhite
          ParentColor = False
          TabOrder = 0
        end
        object ckGrossProfit: TCheckBox
          Left = 196
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Gross Profit'
          Color = clWhite
          ParentColor = False
          TabOrder = 1
        end
        object ckNettProfit: TCheckBox
          Left = 308
          Top = 8
          Width = 109
          Height = 17
          Caption = 'Operating Profit'
          Color = clWhite
          ParentColor = False
          TabOrder = 2
        end
      end
    end
    object tsAdvanced: TTabSheet
      Caption = 'A&dvanced'
      ImageIndex = 1
      ExplicitWidth = 433
      ExplicitHeight = 294
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
  object Panel3: TPanel
    Left = 0
    Top = 304
    Width = 446
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 1
    ExplicitTop = 305
    DesignSize = (
      446
      36)
    object Shape4: TShape
      Left = 0
      Top = 0
      Width = 446
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitLeft = 1
      ExplicitTop = 24
      ExplicitWidth = 431
    end
    object btnSave: TBitBtn
      Left = 205
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Sa&ve'
      TabOrder = 0
      OnClick = btnSaveClick
    end
    object btnOK: TButton
      Left = 286
      Top = 6
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
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
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
    Left = 236
    Top = 216
  end
end
