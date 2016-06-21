object FrmTestRESTClient: TFrmTestRESTClient
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 676
  ClientWidth = 825
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 825
    Height = 635
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 567
    DesignSize = (
      825
      635)
    object Label1: TLabel
      Left = 24
      Top = 53
      Width = 186
      Height = 16
      Caption = '1. Contentful without thread'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label2: TLabel
      Left = 24
      Top = 102
      Width = 164
      Height = 16
      Caption = '2. Contentful with thread'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label3: TLabel
      Left = 24
      Top = 153
      Width = 209
      Height = 16
      Caption = '3. cashbook/MYOB Ledger Login'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label4: TLabel
      Left = 24
      Top = 204
      Width = 209
      Height = 16
      Caption = '4. Cashbook/MYOB Ledger Firms'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label5: TLabel
      Left = 24
      Top = 253
      Width = 305
      Height = 16
      Caption = '5. Cashbook/MYOB Ledger Export Transactions'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label6: TLabel
      Left = 24
      Top = 306
      Width = 270
      Height = 16
      Caption = '6. Lean Engage URL Check without thread'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label7: TLabel
      Left = 24
      Top = 409
      Width = 260
      Height = 16
      Caption = '8. Lean Engage Identity without thread '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label8: TLabel
      Left = 24
      Top = 358
      Width = 248
      Height = 16
      Caption = '7. Lean Engage URL Check with thread'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label9: TLabel
      Left = 24
      Top = 462
      Width = 238
      Height = 16
      Caption = '9. Lean Engage Identity with thread '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label10: TLabel
      Left = 24
      Top = 511
      Width = 240
      Height = 16
      Caption = '10. Lean Engage Survey with thread '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label11: TLabel
      Left = 24
      Top = 562
      Width = 270
      Height = 16
      Caption = '11. Lean Engage Identity with 1 sec timer'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object rgOptions: TRadioGroup
      Left = 354
      Top = 16
      Width = 449
      Height = 588
      Anchors = [akTop, akRight, akBottom]
      ItemIndex = 0
      Items.Strings = (
        'https://cdn.contentful.com/spaces'
        'https://cdn.contentful.com/spaces'
        'https://test.secure.myob.com/oauth2/v1/Authorize'
        'https://burwood.cashbook.dev.myob.com/api/firms'
        
          'https://burwood.cashbook.dev.myob.com/api/businesses/%s/bank_tra' +
          'nsactions'
        'https://www.leanengage.com'
        'https://www.leanengage.com'
        'https://www.leanengage.com/api/v1/identify'
        'https://www.leanengage.com/api/v1/identify'
        'https://www.leanengage.com/api/v1/feedback/check'
        'https://www.leanengage.com/api/v1/identify')
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 635
    Width = 825
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 567
    DesignSize = (
      825
      41)
    object btnCallAPI: TBitBtn
      Left = 317
      Top = 0
      Width = 231
      Height = 25
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Call REST API'
      TabOrder = 0
      OnClick = btnCallAPIClick
    end
  end
end
