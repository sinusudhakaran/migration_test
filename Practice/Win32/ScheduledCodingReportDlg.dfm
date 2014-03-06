object dlgSchedCodingReportSettings: TdlgSchedCodingReportSettings
  Left = 415
  Top = 356
  BorderStyle = bsDialog
  Caption = 'Setup Coding Report'
  ClientHeight = 424
  ClientWidth = 504
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    504
    424)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 340
    Top = 391
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 420
    Top = 391
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 504
    Height = 385
    ActivePage = tbsOptions
    Align = alTop
    TabOrder = 2
    object tbsOptions: TTabSheet
      Caption = '&Options'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Label1: TLabel
        Left = 24
        Top = 16
        Width = 24
        Height = 13
        Caption = 'St&yle'
        FocusControl = cmbStyle
      end
      object Label2: TLabel
        Left = 24
        Top = 48
        Width = 51
        Height = 13
        Caption = '&Sort Order'
        FocusControl = cmbSort
      end
      object Label5: TLabel
        Left = 24
        Top = 80
        Width = 35
        Height = 13
        Caption = '&Include'
        FocusControl = cmbInclude
      end
      object Label6: TLabel
        Left = 24
        Top = 120
        Width = 56
        Height = 13
        Caption = '&Leave Lines'
        FocusControl = cmbLeave
      end
      object chkRuleLine: TCheckBox
        Left = 24
        Top = 158
        Width = 321
        Height = 17
        Alignment = taLeftJustify
        Caption = 'R&ule a line between entries'
        TabOrder = 4
      end
      object cmbStyle: TComboBox
        Left = 176
        Top = 16
        Width = 169
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 0
        OnChange = cmbStyleChange
      end
      object cmbSort: TComboBox
        Left = 176
        Top = 48
        Width = 169
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 1
      end
      object cmbInclude: TComboBox
        Left = 176
        Top = 80
        Width = 169
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 2
      end
      object cmbLeave: TComboBox
        Left = 288
        Top = 120
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
        Left = 24
        Top = 230
        Width = 321
        Height = 17
        Alignment = taLeftJustify
        Caption = 'chkTaxInvoice'
        TabOrder = 7
      end
      object pnlNZOnly: TPanel
        Left = 19
        Top = 247
        Width = 454
        Height = 33
        BevelOuter = bvNone
        TabOrder = 8
        object lblDetailsToShow: TLabel
          Left = 5
          Top = 8
          Width = 73
          Height = 13
          Caption = 'Details to show'
        end
        object rbShowNarration: TRadioButton
          Left = 168
          Top = 8
          Width = 113
          Height = 17
          Caption = 'Na&rration'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbShowOtherParty: TRadioButton
          Left = 280
          Top = 8
          Width = 169
          Height = 17
          Caption = 'Ot&her Party / Particulars'
          TabOrder = 1
        end
      end
      object chkWrap: TCheckBox
        Left = 24
        Top = 206
        Width = 321
        Height = 17
        Alignment = taLeftJustify
        Caption = '&Wrap Narration and Notes'
        TabOrder = 6
      end
      object chkRuleVerticalLine: TCheckBox
        Left = 24
        Top = 182
        Width = 321
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Rule a line between columns'
        TabOrder = 5
      end
    end
    object tbsColumns: TTabSheet
      Caption = '&Columns'
      ImageIndex = 1
      inline fmeCustomColumn1: TfmeCustomColumn
        Left = 36
        Top = 7
        Width = 460
        Height = 350
        TabOrder = 0
        ExplicitLeft = 36
        ExplicitTop = 7
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
    Left = 408
    Top = 24
  end
  object popDates: TPopupMenu
    Left = 407
    Top = 58
    object LastMonth1: TMenuItem
      Tag = 1
      Caption = 'Last Calendar &Month'
    end
    object ThisYear1: TMenuItem
      Tag = 2
      Caption = '&This Financial Year'
    end
    object LastYear1: TMenuItem
      Tag = 3
      Caption = '&Last Financial Year'
    end
    object AllData1: TMenuItem
      Tag = 4
      Caption = '&All Data'
    end
  end
end
