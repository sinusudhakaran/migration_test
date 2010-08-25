object RecipientsDialog: TRecipientsDialog
  Left = 298
  Top = 150
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'NNWFax Recipients Editor'
  ClientHeight = 351
  ClientWidth = 492
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ListBoxRecipients: TListBox
    Left = 0
    Top = 0
    Width = 169
    Height = 308
    Align = alLeft
    ItemHeight = 13
    TabOrder = 0
    OnClick = ListBoxRecipientsClick
  end
  object PanelRecipientProperties: TPanel
    Left = 169
    Top = 0
    Width = 323
    Height = 308
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object LabelCompany: TLabel
      Left = 11
      Top = 33
      Width = 44
      Height = 13
      Alignment = taRightJustify
      Caption = 'Company'
      FocusControl = EditCompany
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object LabelName: TLabel
      Left = 11
      Top = 7
      Width = 28
      Height = 13
      Caption = 'Name'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
    end
    object EditCompany: TEdit
      Left = 64
      Top = 29
      Width = 246
      Height = 21
      TabOrder = 1
      OnExit = EditCompanyExit
    end
    object RadioGroupPriority: TRadioGroup
      Left = 8
      Top = 136
      Width = 209
      Height = 43
      Caption = 'Priority'
      Columns = 3
      Items.Strings = (
        'High'
        'Normal'
        'Low')
      TabOrder = 3
      OnExit = RadioGroupPriorityExit
    end
    object EditName: TEdit
      Left = 64
      Top = 3
      Width = 246
      Height = 21
      TabOrder = 0
      OnExit = EditNameExit
    end
    object GroupBoxDialingInfo: TGroupBox
      Left = 8
      Top = 53
      Width = 305
      Height = 76
      Caption = 'Dialing Information'
      TabOrder = 2
      object LabelCountryCode: TLabel
        Left = 11
        Top = 21
        Width = 64
        Height = 13
        Alignment = taRightJustify
        Caption = 'Country Code'
        FocusControl = EditCountryCode
      end
      object LabelAreaCode: TLabel
        Left = 157
        Top = 21
        Width = 50
        Height = 13
        Alignment = taRightJustify
        Caption = 'Area Code'
        FocusControl = EditAreaCode
      end
      object LabelLocalNumber: TLabel
        Left = 11
        Top = 53
        Width = 66
        Height = 13
        Alignment = taRightJustify
        Caption = 'Local Number'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object EditCountryCode: TEdit
        Left = 81
        Top = 17
        Width = 64
        Height = 21
        TabOrder = 0
        OnExit = EditCountryCodeExit
        OnKeyPress = EditNumberKeyPress
      end
      object EditAreaCode: TEdit
        Left = 213
        Top = 17
        Width = 64
        Height = 21
        TabOrder = 1
        OnExit = EditAreaCodeExit
        OnKeyPress = EditNumberKeyPress
      end
      object EditLocalNumber: TEdit
        Left = 88
        Top = 48
        Width = 121
        Height = 21
        TabOrder = 2
        OnExit = EditLocalNumberExit
        OnKeyPress = EditNumberKeyPress
      end
    end
    object RadioGroupDelivery: TRadioGroup
      Left = 8
      Top = 184
      Width = 209
      Height = 121
      Caption = 'Delivery'
      Items.Strings = (
        'Send Now'
        'Hold in Outbox'
        'Send Off-Peak'
        'Scheduled')
      TabOrder = 4
      OnExit = RadioGroupDeliveryExit
    end
    object MaskEditDate: TMaskEdit
      Left = 96
      Top = 275
      Width = 57
      Height = 21
      EditMask = '!99/99/00;1; '
      MaxLength = 8
      TabOrder = 5
      Text = '  /  /  '
      OnExit = MaskEditDateExit
    end
    object MaskEditTime: TMaskEdit
      Left = 163
      Top = 275
      Width = 38
      Height = 21
      EditMask = '!90:00;1; '
      MaxLength = 5
      TabOrder = 6
      Text = '  :  '
      OnExit = MaskEditTimeExit
    end
  end
  object PanelButtons: TPanel
    Left = 0
    Top = 308
    Width = 492
    Height = 43
    Align = alBottom
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 2
    object ButtonCancel: TButton
      Left = 408
      Top = 10
      Width = 75
      Height = 25
      Cancel = True
      Caption = '&Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object ButtonOk: TButton
      Left = 322
      Top = 10
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      TabOrder = 2
      OnClick = ButtonOkClick
    end
    object ButtonAdd: TButton
      Left = 10
      Top = 9
      Width = 75
      Height = 25
      Caption = '&Add'
      TabOrder = 0
      OnClick = ButtonAddClick
    end
    object ButtonDelete: TButton
      Left = 98
      Top = 9
      Width = 75
      Height = 25
      Caption = '&Delete'
      TabOrder = 1
      OnClick = ButtonDeleteClick
    end
  end
end
