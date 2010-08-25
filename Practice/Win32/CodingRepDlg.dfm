object dlgCodingRep: TdlgCodingRep
  Left = 360
  Top = 189
  BorderStyle = bsDialog
  Caption = 'Coding Report'
  ClientHeight = 426
  ClientWidth = 504
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  ShowHint = True
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 504
    Height = 391
    ActivePage = tbsColumns
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    object tbsOptions: TTabSheet
      Caption = '&Options'
      object Panel2: TPanel
        Left = 1
        Top = 0
        Width = 492
        Height = 89
        ParentColor = True
        TabOrder = 0
        object lblData: TLabel
          Left = 15
          Top = 8
          Width = 425
          Height = 16
          AutoSize = False
          Caption = 'lblData'
        end
        inline eDateSelector: TfmeDateSelector
          Left = 15
          Top = 24
          Width = 466
          Height = 61
          TabOrder = 0
          TabStop = True
          ExplicitLeft = 15
          ExplicitTop = 24
          ExplicitWidth = 466
          ExplicitHeight = 61
          inherited btnPrev: TSpeedButton
            Left = 271
            Top = 6
            ExplicitLeft = 271
            ExplicitTop = 6
          end
          inherited btnNext: TSpeedButton
            Left = 295
            Top = 6
            ExplicitLeft = 295
            ExplicitTop = 6
          end
          inherited btnQuik: TSpeedButton
            Left = 326
            Top = 6
            ExplicitLeft = 326
            ExplicitTop = 6
          end
          inherited eDateFrom: TOvcPictureField
            Left = 160
            Epoch = 0
            ExplicitLeft = 160
            RangeHigh = {25600D00000000000000}
            RangeLow = {00000000000000000000}
          end
          inherited eDateTo: TOvcPictureField
            Left = 160
            Epoch = 0
            ExplicitLeft = 160
            RangeHigh = {25600D00000000000000}
            RangeLow = {00000000000000000000}
          end
          inherited pmDates: TPopupMenu
            Left = 326
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
            Left = 288
          end
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 95
        Width = 493
        Height = 261
        TabOrder = 1
        object Label1: TLabel
          Left = 16
          Top = 8
          Width = 24
          Height = 13
          Caption = 'Style'
          FocusControl = cmbStyle
        end
        object Label2: TLabel
          Left = 16
          Top = 40
          Width = 51
          Height = 13
          Caption = 'Sort Order'
          FocusControl = cmbSort
        end
        object Label5: TLabel
          Left = 16
          Top = 72
          Width = 35
          Height = 13
          Caption = 'Include'
          FocusControl = cmbInclude
        end
        object Label6: TLabel
          Left = 16
          Top = 106
          Width = 56
          Height = 13
          Caption = 'Leave Lines'
          FocusControl = cmbLeave
        end
        object pnlNZOnly: TPanel
          Left = 3
          Top = 222
          Width = 445
          Height = 33
          BevelOuter = bvNone
          TabOrder = 8
          object lblDetailsToShow: TLabel
            Left = 15
            Top = 10
            Width = 73
            Height = 13
            Caption = 'Details to show'
          end
          object rbShowNarration: TRadioButton
            Left = 179
            Top = 8
            Width = 113
            Height = 17
            Caption = 'N&arration'
            Checked = True
            TabOrder = 0
            TabStop = True
          end
          object rbShowOtherParty: TRadioButton
            Left = 275
            Top = 8
            Width = 169
            Height = 17
            Caption = 'Ot&her Party / Particulars'
            TabOrder = 1
          end
        end
        object chkRuleLine: TCheckBox
          Left = 16
          Top = 135
          Width = 329
          Height = 17
          Alignment = taLeftJustify
          Caption = 'R&ule a line between entries'
          TabOrder = 4
        end
        object cmbStyle: TComboBox
          Left = 176
          Top = 8
          Width = 169
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = cmbStyleChange
        end
        object cmbSort: TComboBox
          Left = 176
          Top = 40
          Width = 169
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
        end
        object cmbInclude: TComboBox
          Left = 176
          Top = 72
          Width = 169
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 2
        end
        object cmbLeave: TComboBox
          Left = 288
          Top = 106
          Width = 57
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 3
          Items.Strings = (
            '0'
            '1'
            '2')
        end
        object chkTaxInvoice: TCheckBox
          Left = 16
          Top = 207
          Width = 329
          Height = 17
          Alignment = taLeftJustify
          Caption = 'chkTaxInvoice'
          TabOrder = 5
        end
        object chkWrap: TCheckBox
          Left = 16
          Top = 183
          Width = 329
          Height = 17
          Alignment = taLeftJustify
          Caption = 'W&rap Narration and Notes'
          TabOrder = 6
        end
        object chkRuleVerticalLine: TCheckBox
          Left = 16
          Top = 159
          Width = 329
          Height = 17
          Alignment = taLeftJustify
          Caption = 'Rule a line between columns'
          TabOrder = 7
        end
      end
    end
    object tbsAdvanced: TTabSheet
      Caption = 'A&dvanced'
      ImageIndex = 1
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 493
        Height = 357
        TabOrder = 0
        inline fmeAccountSelector1: TfmeAccountSelector
          Left = 16
          Top = 4
          Width = 460
          Height = 188
          TabOrder = 0
          TabStop = True
          ExplicitLeft = 16
          ExplicitTop = 4
        end
      end
    end
    object tbsColumns: TTabSheet
      Caption = 'Colu&mns'
      ImageIndex = 3
      inline fmeCustomColumn1: TfmeCustomColumn
        Left = 6
        Top = 3
        Width = 460
        Height = 350
        TabOrder = 0
        ExplicitLeft = 6
        ExplicitTop = 3
      end
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 391
    Width = 504
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      504
      35)
    object btnPreview: TButton
      Left = 4
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Previe&w'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 88
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnPrint: TButton
      Left = 336
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Print'
      TabOrder = 3
      OnClick = btnPrintClick
    end
    object btnCancel: TButton
      Left = 420
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 4
      OnClick = btnCancelClick
    end
    object BtnSave: TBitBtn
      Left = 253
      Top = 4
      Width = 75
      Height = 25
      Caption = 'Sa&ve'
      TabOrder = 2
      OnClick = BtnSaveClick
    end
  end
  object dlgLoadCRL: TOpenDialog
    FileName = '*.crl'
    Filter = 'Coding Report Layout (*.crl)|*.crl'
    Left = 178
    Top = 392
  end
  object dlgSaveCRL: TSaveDialog
    FileName = '*.crl'
    Filter = 'Coding Report Layout (*.crl)|*.crl'
    Left = 209
    Top = 392
  end
end
