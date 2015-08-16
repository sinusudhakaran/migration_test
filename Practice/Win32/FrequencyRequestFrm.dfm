object frmFrequencyRequest: TfrmFrequencyRequest
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Send Frequency Change Request'
  ClientHeight = 634
  ClientWidth = 777
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object Label7: TLabel
    Left = 80
    Top = 189
    Width = 441
    Height = 17
    Caption = 
      'Components are not deleted just hidden by memos ticket num is 89' +
      '280'
    Visible = False
  end
  object pBottom: TPanel
    Left = 0
    Top = 581
    Width = 777
    Height = 53
    Align = alBottom
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    DesignSize = (
      777
      53)
    object lblInstitutionListLink: TLabel
      Left = 21
      Top = 0
      Width = 404
      Height = 46
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
      Left = 558
      Top = 10
      Width = 98
      Height = 33
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 664
      Top = 10
      Width = 98
      Height = 33
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnlMonthly: TPanel
    Left = 0
    Top = 47
    Width = 777
    Height = 136
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Visible = False
    DesignSize = (
      777
      136)
    object gbMonthly: TGroupBox
      Left = 10
      Top = 3
      Width = 756
      Height = 122
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      DesignSize = (
        756
        122)
      object Label2: TLabel
        Left = 10
        Top = 10
        Width = 120
        Height = 21
        Caption = 'Monthly to Daily'
      end
      object Label4: TLabel
        Left = 89
        Top = 22
        Width = 15
        Height = 21
        Caption = 'to'
        Visible = False
      end
      object rbMonthToWeek: TRadioButton
        Left = 262
        Top = 21
        Width = 116
        Height = 22
        Caption = 'Weekly'
        TabOrder = 0
        Visible = False
        OnClick = rbDailyClick
      end
      object rbMonthToDay: TRadioButton
        Left = 131
        Top = 21
        Width = 92
        Height = 22
        Caption = 'Daily'
        TabOrder = 1
        Visible = False
        OnClick = rbDailyClick
      end
      object memoMonthly: TMemo
        Left = 11
        Top = 40
        Width = 732
        Height = 67
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          'memoMonthly')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
  end
  object pnlDaily: TPanel
    Left = 0
    Top = 395
    Width = 777
    Height = 136
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    Visible = False
    DesignSize = (
      777
      136)
    object gbDaily: TGroupBox
      Left = 10
      Top = 5
      Width = 756
      Height = 122
      Anchors = [akLeft, akTop, akRight, akBottom]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      DesignSize = (
        756
        122)
      object Label1: TLabel
        Left = 10
        Top = 10
        Width = 120
        Height = 21
        Caption = 'Daily to Monthly'
      end
      object Label6: TLabel
        Left = 89
        Top = 25
        Width = 15
        Height = 21
        Caption = 'to'
        Visible = False
      end
      object rbDayToMonth: TRadioButton
        Left = 131
        Top = 25
        Width = 116
        Height = 22
        Caption = 'Monthly'
        TabOrder = 0
        Visible = False
        OnClick = rbDailyClick
      end
      object rbDayToWeek: TRadioButton
        Left = 262
        Top = 24
        Width = 92
        Height = 22
        Caption = 'Weekly'
        TabOrder = 1
        Visible = False
        OnClick = rbDailyClick
      end
      object memoDaily: TMemo
        Left = 10
        Top = 40
        Width = 732
        Height = 61
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -17
        Font.Name = 'Tahoma'
        Font.Style = []
        Lines.Strings = (
          'memoDaily')
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 2
      end
    end
  end
  object pnlWeekly: TPanel
    Left = 0
    Top = 223
    Width = 777
    Height = 136
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    Visible = False
    DesignSize = (
      777
      136)
    object gbWeekly: TGroupBox
      Left = 10
      Top = 5
      Width = 756
      Height = 122
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
      DesignSize = (
        756
        122)
      object Label3: TLabel
        Left = 10
        Top = 10
        Width = 53
        Height = 21
        Caption = 'Weekly'
      end
      object Label5: TLabel
        Left = 89
        Top = 10
        Width = 15
        Height = 21
        Caption = 'to'
      end
      object rbWeekToMonth: TRadioButton
        Left = 131
        Top = 10
        Width = 116
        Height = 22
        Caption = 'Monthly'
        TabOrder = 0
        OnClick = rbDailyClick
      end
      object rbWeekToDay: TRadioButton
        Left = 262
        Top = 10
        Width = 92
        Height = 22
        Caption = 'Daily'
        TabOrder = 1
        OnClick = rbDailyClick
      end
      object memoWeekly: TMemo
        Left = 10
        Top = 40
        Width = 732
        Height = 61
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
    Width = 777
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -17
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
    Visible = False
    object cbNotifyEmail: TCheckBox
      Left = 21
      Top = 11
      Width = 431
      Height = 23
      Caption = 'Notify practice by email when Daily Data is available'
      Enabled = False
      TabOrder = 0
    end
  end
end
