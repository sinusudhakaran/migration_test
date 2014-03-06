inherited dlgListEntriesAdvanced: TdlgListEntriesAdvanced
  Scaled = False
Left = 392
  Top = 283
  Caption = 'dlgListEntriesAdvanced'
  ClientHeight = 440
  ClientWidth = 505
  ExplicitWidth = 511
  ExplicitHeight = 466
  PixelsPerInch = 96
  TextHeight = 13
  inherited PageControl1: TPageControl
    Width = 505
    Height = 402
    ExplicitWidth = 505
    ExplicitHeight = 402
    inherited tbsOptions: TTabSheet
      ExplicitWidth = 497
      ExplicitHeight = 374
      object Label6: TLabel [0]
        Left = 16
        Top = 229
        Width = 24
        Height = 13
        Caption = 'Style'
      end
      object Label7: TLabel [1]
        Left = 16
        Top = 193
        Width = 35
        Height = 13
        Caption = 'Include'
        FocusControl = cmbInclude
      end
      object Label5: TLabel [2]
        Left = 17
        Top = 266
        Width = 73
        Height = 13
        Caption = 'Details to show'
      end
      object Bevel1: TBevel [3]
        Left = 7
        Top = 141
        Width = 474
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
      end
      object Label4: TLabel [4]
        Left = 16
        Top = 160
        Width = 71
        Height = 13
        Caption = 'Sort entries by'
        FocusControl = cmbSortBy
      end
      inherited Panel1: TPanel
        Height = 129
        ExplicitHeight = 129
        inherited eDateSelector: TfmeDateSelector
          Width = 318
          ExplicitWidth = 318
          inherited Label2: TLabel
            Top = 5
            ExplicitTop = 5
          end
          inherited btnPrev: TSpeedButton
            Left = 228
            Top = 3
            ExplicitLeft = 228
            ExplicitTop = 3
          end
          inherited btnNext: TSpeedButton
            Left = 252
            Top = 3
            ExplicitLeft = 252
            ExplicitTop = 3
          end
          inherited btnQuik: TSpeedButton
            Left = 281
            Top = 3
            ExplicitLeft = 281
            ExplicitTop = 3
          end
          inherited Label3: TLabel
            Top = 31
            ExplicitTop = 31
          end
          inherited eDateFrom: TOvcPictureField
            Left = 108
            Top = 3
            Epoch = 0
            ExplicitLeft = 108
            ExplicitTop = 3
            RangeHigh = {25600D00000000000000}
            RangeLow = {00000000000000000000}
          end
          inherited eDateTo: TOvcPictureField
            Left = 108
            Top = 29
            Epoch = 0
            ExplicitLeft = 108
            ExplicitTop = 29
            RangeHigh = {25600D00000000000000}
            RangeLow = {00000000000000000000}
          end
          inherited pmDates: TPopupMenu
            Left = 228
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
            Left = 260
            Top = 27
          end
        end
      end
      object radButton1: TRadioButton
        Left = 304
        Top = 184
        Width = 137
        Height = 17
        Caption = 'radButton1'
        TabOrder = 4
        Visible = False
      end
      object radButton2: TRadioButton
        Left = 304
        Top = 160
        Width = 137
        Height = 17
        Caption = 'radButton2'
        TabOrder = 3
        Visible = False
      end
      object cmbSortBy: TComboBox
        Left = 126
        Top = 157
        Width = 169
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 1
      end
      object chkShowNotes: TCheckBox
        Left = 126
        Top = 291
        Width = 124
        Height = 17
        Hint = 'Show notes'
        Caption = 'No&tes'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 8
      end
      object rbSingleCol: TRadioButton
        Left = 124
        Top = 229
        Width = 113
        Height = 17
        Hint = 'Show debits and credits in the same column'
        Caption = 'Sin&gle Column'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
      end
      object rbTwoCol: TRadioButton
        Left = 267
        Top = 229
        Width = 113
        Height = 17
        Hint = 'Show debits and credits in seperate columns'
        Caption = 'Two &Column'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 6
      end
      object cmbInclude: TComboBox
        Left = 126
        Top = 189
        Width = 169
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 2
        OnChange = cmbIncludeChange
      end
      object chkShowBalance: TCheckBox
        Left = 126
        Top = 267
        Width = 124
        Height = 17
        Hint = 'Show balance'
        Caption = '&Balance'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 7
      end
      object pnlNZOnly: TPanel
        Left = 18
        Top = 340
        Width = 417
        Height = 30
        BevelOuter = bvNone
        TabOrder = 9
        object rbShowNarration: TRadioButton
          Left = 108
          Top = 2
          Width = 112
          Height = 17
          Caption = '&Narration'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbShowOtherParty: TRadioButton
          Left = 251
          Top = 2
          Width = 163
          Height = 17
          Caption = 'Ot&her Party / Particulars'
          TabOrder = 1
        end
      end
      object chkWrap: TCheckBox
        Left = 126
        Top = 315
        Width = 203
        Height = 17
        Hint = 'Wrap narration text'
        Caption = 'W&rap Narrations and Notes'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 10
      end
    end
    inherited tbsAdvanced: TTabSheet
      ExplicitWidth = 497
      ExplicitHeight = 374
    end
  end
  inherited pnlButtons: TPanel
    Top = 402
    Width = 505
    ExplicitTop = 402
    ExplicitWidth = 505
    inherited btnPreview: TButton
      ParentShowHint = False
      ShowHint = True
    end
    inherited btnFile: TButton
      ParentShowHint = False
      ShowHint = True
    end
    inherited btnOK: TButton
      Left = 345
      ExplicitLeft = 345
    end
    inherited btClose: TButton
      Left = 425
      ExplicitLeft = 425
    end
  end
end
