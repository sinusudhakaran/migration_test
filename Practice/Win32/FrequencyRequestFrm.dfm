object frmFrequencyRequest: TfrmFrequencyRequest
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Send Frequency Change Request'
  ClientHeight = 484
  ClientWidth = 594
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pBottom: TPanel
    Left = 0
    Top = 443
    Width = 594
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      594
      41)
    object lblInstitutionListLink: TLabel
      Left = 16
      Top = 2
      Width = 309
      Height = 33
      AutoSize = False
      Caption = 
        'Please check the available frequency options per institution bef' +
        'ore sending through the request.'
      WordWrap = True
      OnClick = lblInstitutionListLinkClick
      OnMouseEnter = lblInstitutionListLinkMouseEnter
      OnMouseLeave = lblInstitutionListLinkMouseLeave
    end
    object btnOK: TButton
      Left = 427
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 508
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnlMonthly: TPanel
    Left = 0
    Top = 36
    Width = 594
    Height = 104
    BevelOuter = bvNone
    TabOrder = 1
    Visible = False
    DesignSize = (
      594
      104)
    object gbMonthly: TGroupBox
      Left = 8
      Top = 4
      Width = 578
      Height = 93
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      DesignSize = (
        578
        93)
      object Label2: TLabel
        Left = 8
        Top = 17
        Width = 38
        Height = 13
        Caption = 'Monthly'
      end
      object Label4: TLabel
        Left = 68
        Top = 17
        Width = 10
        Height = 13
        Caption = 'to'
      end
      object rbMonthToWeek: TRadioButton
        Left = 100
        Top = 17
        Width = 89
        Height = 17
        Caption = 'Weekly'
        TabOrder = 0
        OnClick = rbDailyClick
      end
      object rbMonthToDay: TRadioButton
        Left = 200
        Top = 17
        Width = 71
        Height = 17
        Caption = 'Daily'
        TabOrder = 1
        OnClick = rbDailyClick
      end
      object memoMonthly: TMemo
        Left = 8
        Top = 40
        Width = 560
        Height = 44
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          'memoMonthly')
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
  end
  object pnlDaily: TPanel
    Left = 0
    Top = 302
    Width = 594
    Height = 104
    BevelOuter = bvNone
    TabOrder = 3
    Visible = False
    DesignSize = (
      594
      104)
    object gbDaily: TGroupBox
      Left = 8
      Top = 4
      Width = 578
      Height = 93
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      DesignSize = (
        578
        93)
      object Label1: TLabel
        Left = 8
        Top = 19
        Width = 23
        Height = 13
        Caption = 'Daily'
      end
      object Label6: TLabel
        Left = 68
        Top = 19
        Width = 10
        Height = 13
        Caption = 'to'
      end
      object rbDayToMonth: TRadioButton
        Left = 100
        Top = 19
        Width = 89
        Height = 17
        Caption = 'Monthly'
        TabOrder = 0
        OnClick = rbDailyClick
      end
      object rbDayToWeek: TRadioButton
        Left = 200
        Top = 19
        Width = 71
        Height = 17
        Caption = 'Weekly'
        TabOrder = 1
        OnClick = rbDailyClick
      end
      object memoDaily: TMemo
        Left = 8
        Top = 40
        Width = 560
        Height = 44
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          'memoDaily')
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
  end
  object pnlWeekly: TPanel
    Left = 0
    Top = 171
    Width = 594
    Height = 104
    BevelOuter = bvNone
    TabOrder = 2
    Visible = False
    DesignSize = (
      594
      104)
    object gbWeekly: TGroupBox
      Left = 8
      Top = 4
      Width = 578
      Height = 93
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      DesignSize = (
        578
        93)
      object Label3: TLabel
        Left = 8
        Top = 17
        Width = 35
        Height = 13
        Caption = 'Weekly'
      end
      object Label5: TLabel
        Left = 68
        Top = 17
        Width = 10
        Height = 13
        Caption = 'to'
      end
      object rbWeekToMonth: TRadioButton
        Left = 100
        Top = 17
        Width = 89
        Height = 17
        Caption = 'Monthly'
        TabOrder = 0
        OnClick = rbDailyClick
      end
      object rbWeekToDay: TRadioButton
        Left = 200
        Top = 17
        Width = 71
        Height = 17
        Caption = 'Daily'
        TabOrder = 1
        OnClick = rbDailyClick
      end
      object memoWeekly: TMemo
        Left = 8
        Top = 40
        Width = 560
        Height = 44
        Anchors = [akLeft, akTop, akRight, akBottom]
        Lines.Strings = (
          'memoWeekly')
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
  end
  object pnlNotify: TPanel
    Left = 0
    Top = 0
    Width = 594
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 4
    Visible = False
    object cbNotifyEmail: TCheckBox
      Left = 16
      Top = 8
      Width = 330
      Height = 17
      Caption = 'Notify practice by email when Daily Data is available'
      Enabled = False
      TabOrder = 0
    end
  end
end
