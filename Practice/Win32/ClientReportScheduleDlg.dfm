inherited dlgClientReportSchedule: TdlgClientReportSchedule
  Left = 324
  Top = 237
  Caption = 'Report Schedule'
  ClientHeight = 494
  ClientWidth = 632
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  ExplicitWidth = 638
  ExplicitHeight = 522
  PixelsPerInch = 96
  TextHeight = 13
  inherited btnOK: TButton
    Left = 472
    Top = 464
    Caption = 'OK'
    TabOrder = 1
    ExplicitLeft = 472
    ExplicitTop = 464
  end
  inherited btnCancel: TButton
    Left = 552
    Top = 464
    TabOrder = 2
    ExplicitLeft = 552
    ExplicitTop = 464
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 632
    Height = 449
    ActivePage = tbsOptions
    Align = alTop
    TabOrder = 0
    OnChange = PageControl1Change
    object tbsOptions: TTabSheet
      Caption = '&Options'
      object Label1: TLabel
        Left = 5
        Top = 2
        Width = 80
        Height = 13
        Caption = 'Prod&uce Reports'
        FocusControl = cmbPeriod
      end
      object Label2: TLabel
        Left = 315
        Top = 2
        Width = 57
        Height = 13
        Caption = 'Start &Month'
        FocusControl = cmbStarts
      end
      object lblMessage: TLabel
        Left = 5
        Top = 119
        Width = 53
        Height = 13
        Caption = 'lblMessage'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object cmbPeriod: TComboBox
        Left = 5
        Top = 21
        Width = 305
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 0
        OnChange = cmbPeriodChange
      end
      object cmbStarts: TComboBox
        Left = 315
        Top = 21
        Width = 305
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
        OnChange = cmbPeriodChange
      end
      object grpSelect: TGroupBox
        Left = 325
        Top = 252
        Width = 295
        Height = 109
        Caption = ' Selected Reports'
        TabOrder = 5
        object chkCodingReport: TCheckBox
          Left = 11
          Top = 24
          Width = 73
          Height = 17
          Caption = 'Codi&ng'
          TabOrder = 0
          OnClick = chkCodingReportClick
        end
        object chkChartReport: TCheckBox
          Left = 11
          Top = 52
          Width = 137
          Height = 17
          Caption = 'C&hart of Accounts'
          TabOrder = 2
        end
        object chkPayeeReport: TCheckBox
          Left = 11
          Top = 80
          Width = 105
          Height = 17
          Caption = 'Pa&yee List'
          TabOrder = 3
        end
        object btnReportSettings: TButton
          Left = 142
          Top = 20
          Width = 143
          Height = 25
          Caption = 'Current &Report Setup'
          TabOrder = 1
          OnClick = btnReportSettingsClick
        end
        object chkJobReport: TCheckBox
          Left = 171
          Top = 80
          Width = 105
          Height = 17
          Caption = '&Job List'
          TabOrder = 4
        end
      end
      object lvReports: TListView
        Left = 5
        Top = 50
        Width = 615
        Height = 68
        Color = clBtnHighlight
        Columns = <>
        Ctl3D = False
        ReadOnly = True
        SmallImages = AppImages.Misc
        TabOrder = 2
        ViewStyle = vsList
      end
      object gbDestination: TGroupBox
        Left = 5
        Top = 134
        Width = 315
        Height = 283
        Caption = 'Destination'
        TabOrder = 3
        object rbToPrinter: TRadioButton
          Left = 6
          Top = 24
          Width = 129
          Height = 17
          Caption = '&Print'
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rbToPrinterClick
        end
        object rbToFax: TRadioButton
          Left = 6
          Top = 52
          Width = 145
          Height = 17
          Caption = '&Fax'
          TabOrder = 1
          OnClick = rbToPrinterClick
        end
        object rbToEMail: TRadioButton
          Left = 6
          Top = 80
          Width = 97
          Height = 17
          Caption = '&E-Mail'
          TabOrder = 2
          OnClick = rbToPrinterClick
        end
        object rbToECoding: TRadioButton
          Left = 6
          Top = 108
          Width = 161
          Height = 17
          Caption = '&Notes File'
          TabOrder = 4
          OnClick = rbToPrinterClick
        end
        object cmbEmailFormat: TComboBox
          Left = 137
          Top = 78
          Width = 175
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 3
          Items.Strings = (
            'Text File '
            'CSV File')
        end
        object btnECodingSetup: TButton
          Left = 137
          Top = 104
          Width = 175
          Height = 25
          Caption = 'ECoding Options'
          TabOrder = 5
          OnClick = btnECodingSetupClick
        end
        object rbToWebX: TRadioButton
          Left = 6
          Top = 136
          Width = 161
          Height = 17
          Caption = '&Web File'
          TabOrder = 6
          OnClick = rbToPrinterClick
        end
        object btnWebXSetup: TButton
          Left = 137
          Top = 131
          Width = 175
          Height = 25
          Caption = 'Web Options'
          TabOrder = 7
          OnClick = btnWebXSetupClick
        end
        object rbCheckOut: TRadioButton
          Left = 6
          Top = 164
          Width = 169
          Height = 17
          Caption = 'BankLink Boo&ks File'
          TabOrder = 8
          OnClick = rbToPrinterClick
        end
        object rbBusinessProducts: TRadioButton
          Left = 6
          Top = 220
          Width = 160
          Height = 17
          Caption = 'Bu&siness Products'
          TabOrder = 9
          Visible = False
          OnClick = rbToPrinterClick
        end
        object cmbBusinessProducts: TComboBox
          Left = 137
          Top = 218
          Width = 175
          Height = 21
          Style = csDropDownList
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ItemHeight = 13
          ParentFont = False
          TabOrder = 10
          Visible = False
          Items.Strings = (
            'Text File '
            'CSV File')
        end
        object rbCheckoutOnline: TRadioButton
          Left = 6
          Top = 192
          Width = 259
          Height = 17
          Caption = 'BankLink Books File via BankLink Online'
          TabOrder = 11
          OnClick = rbToPrinterClick
        end
      end
      object gbDetails: TGroupBox
        Left = 325
        Top = 134
        Width = 295
        Height = 115
        Caption = 'Destination Details'
        TabOrder = 4
        object Label6: TLabel
          Left = 11
          Top = 24
          Width = 18
          Height = 13
          Caption = 'Fa&x'
          FocusControl = eFaxNo
        end
        object lblAddress: TLabel
          Left = 11
          Top = 52
          Width = 28
          Height = 13
          Caption = 'E-Mai&l'
          FocusControl = eMail
        end
        object Label3: TLabel
          Left = 11
          Top = 80
          Width = 14
          Height = 13
          Caption = '&CC'
          FocusControl = eCCeMail
        end
        object eFaxNo: TEdit
          Left = 67
          Top = 24
          Width = 215
          Height = 20
          BorderStyle = bsNone
          MaxLength = 40
          TabOrder = 0
          Text = 'eFax'
        end
        object eMail: TEdit
          Left = 67
          Top = 52
          Width = 215
          Height = 20
          BorderStyle = bsNone
          MaxLength = 80
          TabOrder = 1
          Text = 'eMail'
        end
        object eCCeMail: TEdit
          Left = 67
          Top = 80
          Width = 215
          Height = 20
          BorderStyle = bsNone
          MaxLength = 255
          TabOrder = 2
          Text = 'eCCeMail'
        end
      end
      object GroupBox1: TGroupBox
        Left = 325
        Top = 363
        Width = 295
        Height = 54
        Caption = 'Custom Document'
        TabOrder = 6
        object chkUseCustomDoc: TCheckBox
          Left = 11
          Top = 24
          Width = 128
          Height = 17
          Caption = 'Include '
          TabOrder = 0
          OnClick = chkUseCustomDocClick
        end
        object cmbCustomDocList: TComboBox
          Left = 142
          Top = 22
          Width = 143
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnDropDown = cmbCustomDocListDropDown
        end
      end
    end
    object tbsMessage: TTabSheet
      Caption = 'Messa&ge'
      ImageIndex = 1
      DesignSize = (
        624
        421)
      object memMessage: TMemo
        Left = 4
        Top = 4
        Width = 599
        Height = 409
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
    object tbsAttachments: TTabSheet
      Caption = 'A&ttachments'
      ImageIndex = 3
      DesignSize = (
        624
        421)
      object lblAttach: TLabel
        Left = 8
        Top = 3
        Width = 205
        Height = 13
        Caption = 'Other files to attach when emailing reports'
      end
      object Image1: TImage
        Left = 111
        Top = 347
        Width = 32
        Height = 32
        Transparent = True
        Visible = False
      end
      object lvAttach: TListView
        Left = 3
        Top = 22
        Width = 600
        Height = 365
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <>
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -15
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        IconOptions.AutoArrange = True
        MultiSelect = True
        ReadOnly = True
        ParentFont = False
        SmallImages = ImageList1
        TabOrder = 0
        ViewStyle = vsList
        OnKeyUp = lvAttachKeyUp
      end
      object btnAttach: TButton
        Left = 3
        Top = 393
        Width = 85
        Height = 25
        Hint = 'Attach Client file(s) to this E-mail'
        Anchors = [akLeft, akBottom]
        Caption = 'Attac&h File'
        TabOrder = 1
        OnClick = btnAttachClick
      end
    end
    object tbsAdvanced: TTabSheet
      Caption = 'A&dvanced'
      ImageIndex = 2
      inline fmeAccountSelector1: TfmeAccountSelector
        Left = 4
        Top = 8
        Width = 460
        Height = 201
        TabOrder = 0
        TabStop = True
        ExplicitLeft = 4
        ExplicitTop = 8
        ExplicitHeight = 201
        inherited lblSelectAccounts: TLabel
          Width = 359
          Caption = 
            'Select the accounts that you wish to be included in the Schedule' +
            'd Reports:'
          ExplicitWidth = 359
        end
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = 'All Files|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Title = 'Choose File'
    Left = 156
    Top = 372
  end
  object ImageList1: TImageList
    Left = 196
    Top = 372
  end
end
