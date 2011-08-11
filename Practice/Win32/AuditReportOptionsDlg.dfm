object frmAuditReportOption: TfrmAuditReportOption
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Audit Report'
  ClientHeight = 400
  ClientWidth = 455
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlSelectClient: TPanel
    Left = 0
    Top = 0
    Width = 455
    Height = 124
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object GroupBox6: TGroupBox
      Left = 8
      Top = 6
      Width = 438
      Height = 114
      Caption = 'Select Level'
      TabOrder = 0
      object rbSystem: TRadioButton
        Left = 16
        Top = 24
        Width = 113
        Height = 14
        Caption = '&System'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbSystemClick
      end
      object rbClient: TRadioButton
        Left = 16
        Top = 83
        Width = 113
        Height = 14
        Caption = '&Client'
        TabOrder = 1
        OnClick = rbSystemClick
      end
      object cbClientFileCodes: TComboBox
        Left = 143
        Top = 79
        Width = 263
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 2
      end
      object rbExchangeRates: TRadioButton
        Left = 16
        Top = 53
        Width = 113
        Height = 17
        Caption = 'Exchange Rates'
        TabOrder = 3
        OnClick = rbSystemClick
      end
    end
  end
  object pnlSelectDate: TPanel
    Left = 0
    Top = 124
    Width = 455
    Height = 107
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object gbxReportPeriod: TGroupBox
      Left = 8
      Top = 4
      Width = 440
      Height = 100
      Caption = 'Select Date Range'
      TabOrder = 0
      inline DateSelector: TfmeDateSelector
        Left = 16
        Top = 28
        Width = 276
        Height = 70
        TabOrder = 0
        TabStop = True
        ExplicitLeft = 16
        ExplicitTop = 28
        inherited Label2: TLabel
          Top = 3
          ExplicitTop = 3
        end
        inherited btnPrev: TSpeedButton
          Top = 3
          ExplicitTop = 3
        end
        inherited btnNext: TSpeedButton
          Top = 3
          ExplicitTop = 3
        end
        inherited btnQuik: TSpeedButton
          Top = 3
          ExplicitTop = 3
        end
        inherited Label3: TLabel
          Top = 29
          ExplicitTop = 29
        end
        inherited eDateFrom: TOvcPictureField
          Top = 3
          Epoch = 0
          ExplicitTop = 3
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
        inherited eDateTo: TOvcPictureField
          Top = 29
          Epoch = 0
          ExplicitTop = 29
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
        inherited pmDates: TPopupMenu
          Top = 27
        end
        inherited OvcController1: TOvcController
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
          Top = 27
        end
      end
    end
  end
  object pnlSelectTransaction: TPanel
    Left = 0
    Top = 231
    Width = 455
    Height = 129
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object GroupBox1: TGroupBox
      Left = 8
      Top = 4
      Width = 438
      Height = 120
      Caption = 'Select Transactions'
      TabOrder = 0
      object rbSytemTransactionType: TRadioButton
        Left = 16
        Top = 32
        Width = 113
        Height = 17
        Caption = 'Transaction type'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbSytemTransactionTypeClick
      end
      object rbSytemTransactionID: TRadioButton
        Left = 16
        Top = 64
        Width = 113
        Height = 17
        Caption = 'Transaction ID'
        TabOrder = 1
        OnClick = rbSytemTransactionTypeClick
      end
      object cbTransactionType: TComboBox
        Left = 145
        Top = 30
        Width = 263
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 2
      end
      object eTransactionID: TEdit
        Left = 145
        Top = 62
        Width = 93
        Height = 21
        TabOrder = 3
        OnKeyPress = eTransactionIDKeyPress
      end
      object cbIncludeChildren: TCheckBox
        Left = 145
        Top = 89
        Width = 172
        Height = 21
        Caption = 'Include child transactions'
        TabOrder = 4
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 360
    Width = 455
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitTop = 338
    object btnCancel: TButton
      Left = 371
      Top = 5
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
      OnClick = btnCancelClick
    end
    object btnPrint: TButton
      Left = 290
      Top = 5
      Width = 75
      Height = 25
      Caption = '&Print'
      TabOrder = 1
    end
    object btnFile: TButton
      Left = 89
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Fil&e'
      TabOrder = 2
      OnClick = btnFileClick
    end
    object btnPreview: TButton
      Left = 8
      Top = 5
      Width = 75
      Height = 25
      Caption = 'Previe&w'
      Default = True
      TabOrder = 3
      OnClick = btnPreviewClick
    end
  end
end
