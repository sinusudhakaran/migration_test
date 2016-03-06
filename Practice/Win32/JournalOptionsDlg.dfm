inherited DlgJournalOptions: TDlgJournalOptions
  Caption = 'Journal Report Options'
  ClientHeight = 304
  ExplicitHeight = 332
  PixelsPerInch = 96
  TextHeight = 13
  inherited PCOptions: TPageControl
    Height = 259
    ExplicitHeight = 259
    inherited tsOptions: TTabSheet
      ExplicitHeight = 231
      object lblFormat: TLabel [2]
        Left = 28
        Top = 150
        Width = 45
        Height = 23
        AutoSize = False
        Caption = 'Format'
        FocusControl = DateSelector.eDateTo
      end
      object lblSortOrder: TLabel [3]
        Left = 28
        Top = 179
        Width = 72
        Height = 23
        AutoSize = False
        Caption = 'Sort Order'
        FocusControl = DateSelector.eDateTo
      end
      inherited DateSelector: TfmeDateSelector
        Height = 56
        ExplicitHeight = 56
        inherited eDateFrom: TOvcPictureField
          Left = 74
          Epoch = 0
          ExplicitLeft = 74
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
        end
        inherited eDateTo: TOvcPictureField
          Left = 74
          Epoch = 0
          ExplicitLeft = 74
          RangeHigh = {25600D00000000000000}
          RangeLow = {00000000000000000000}
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
        end
      end
      inherited radButton1: TRadioButton
        Top = 205
        TabOrder = 7
        ExplicitTop = 205
      end
      inherited radButton2: TRadioButton
        Top = 210
        TabOrder = 8
        ExplicitTop = 210
      end
      inherited chkWrapNarration: TCheckBox
        Top = 207
        TabOrder = 4
        ExplicitTop = 207
      end
      inherited chkNonBaseCurrency: TCheckBox
        Top = 207
        TabOrder = 5
        ExplicitTop = 207
      end
      object chkGroupBy: TCheckBox
        Left = 28
        Top = 233
        Width = 245
        Height = 17
        Caption = 'Group by Journal Type'
        TabOrder = 6
        Visible = False
      end
      object rbSummary: TRadioButton
        Left = 102
        Top = 150
        Width = 137
        Height = 17
        Caption = 'Summary'
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = rbSummaryClick
      end
      object rbDetailed: TRadioButton
        Left = 268
        Top = 150
        Width = 137
        Height = 17
        Caption = 'Detailed'
        TabOrder = 2
        OnClick = rbDetailedClick
      end
      object cmbSortOrder: TComboBox
        Left = 102
        Top = 176
        Width = 164
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
        Items.Strings = (
          'Date + Reference'
          'Date'
          'Reference')
      end
    end
    inherited tsAdvanced: TTabSheet
      ExplicitHeight = 225
      inherited fmeAccountSelector1: TfmeAccountSelector
        inherited lblSelectAccounts: TLabel
          Width = 295
          Caption = 'Select the journals that you wish to be included in this report:'
          ExplicitWidth = 295
        end
      end
    end
  end
  inherited pnlControls: TPanel
    Top = 259
    ExplicitTop = 259
  end
end
