object frmMaintainPracBank: TfrmMaintainPracBank
  Left = 262
  Top = 162
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Maintain Bank Accounts in Admin System'
  ClientHeight = 581
  ClientWidth = 954
  Color = clBtnFace
  Constraints.MinHeight = 160
  Constraints.MinWidth = 400
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShortCut = FormShortCut
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 200
    Top = 0
    Width = 5
    Height = 546
    ExplicitTop = 22
    ExplicitHeight = 503
  end
  object Panel1: TPanel
    Left = 0
    Top = 546
    Width = 954
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      954
      35)
    object btnOK: TButton
      Left = 871
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Close'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
  inline SysAccounts: TfmeSysAccounts
    Left = 205
    Top = 0
    Width = 749
    Height = 546
    Align = alClient
    TabOrder = 1
    ExplicitLeft = 205
    ExplicitWidth = 749
    ExplicitHeight = 546
    inherited pTop: TPanel
      Width = 749
      ExplicitWidth = 749
    end
    inherited AccountTree: TVirtualStringTree
      Width = 749
      Height = 521
      PopupMenu = pmGrid
      OnDblClick = SysAccountsAccountTreeDblClick
      ExplicitWidth = 749
      ExplicitHeight = 521
    end
    inherited pmHeader: TPopupMenu
      Left = 26
    end
  end
  object gbMain: TRzGroupBar
    Left = 0
    Top = 0
    Width = 200
    Height = 546
    BorderSides = []
    BorderColor = 15510150
    BorderShadow = 15510150
    GradientColorStyle = gcsCustom
    GradientColorStart = clBtnFace
    GradientColorStop = 7829248
    GroupBorderSize = 8
    SmallImages = AppImages.ilFileActions_ClientMgr
    Color = clBtnShadow
    ParentColor = False
    TabOrder = 2
    object gbAccounts: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
          Action = actNew
        end
        item
          Action = actEdit
        end
        item
          Action = actDelete
        end
        item
          Action = actRemove
        end
        item
          Caption = '-'
        end
        item
          Action = actCharge
        end
        item
          Action = actSendFrequencyRequest
        end
        item
          Action = actSendDelete
        end
        item
          Caption = '-'
        end
        item
          Action = acAddProvTrans
          Caption = 'Add Provisional Transactions'
        end
        item
          Action = acSendProvReq
          Caption = 'Send Provisional Account Request'
        end
        item
          Caption = '-'
        end
        item
          Action = acCurrencies
        end
        item
          Action = acExchangeRates
        end
        item
          Caption = '-'
        end
        item
          Action = actPrint
        end>
      Opened = True
      OpenedHeight = 396
      Caption = 'Accounts'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object gbDetails: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
        end>
      Opened = True
      OpenedHeight = 33
      Caption = 'Details'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object rzgOptions: TRzGroup
      CaptionColorStart = 16773337
      CaptionColorStop = 10115840
      GroupController = AppImages.AppGroupController
      Items = <
        item
        end
        item
        end>
      Opened = True
      OpenedHeight = 53
      Caption = 'Options'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Visible = False
    end
  end
  object actList: TActionList
    Images = AppImages.ilFileActions_ClientMgr
    Left = 144
    Top = 8
    object actEdit: TAction
      Category = 'Accounts'
      Caption = 'Edit'
      ImageIndex = 17
      OnExecute = actEditExecute
    end
    object actDelete: TAction
      Category = 'Accounts'
      Caption = 'Delete'
      ImageIndex = 35
      OnExecute = actDeleteExecute
    end
    object actRemove: TAction
      Category = 'Accounts'
      Caption = 'Remove'
      ImageIndex = 35
      OnExecute = actRemoveExecute
    end
    object actNew: TAction
      Category = 'Accounts'
      Caption = 'Setup New Accounts'
      ImageIndex = 12
      OnExecute = actNewExecute
    end
    object actCharge: TAction
      Category = 'Accounts'
      Caption = 'Charge'
      ImageIndex = 21
      OnExecute = actChargeExecute
    end
    object actSendFrequencyRequest: TAction
      Category = 'Accounts'
      Caption = 'Send Frequency Change Request'
      ImageIndex = 8
      OnExecute = actSendFrequencyRequestExecute
    end
    object actSendDelete: TAction
      Category = 'Accounts'
      Caption = 'Send Delete Request'
      ImageIndex = 8
      OnExecute = actSendDeleteExecute
    end
    object actPrint: TAction
      Category = 'Reports'
      Caption = 'Print'
      ImageIndex = 14
      OnExecute = actPrintExecute
    end
    object actListBankAccounts: TAction
      Category = 'Reports'
      Caption = 'List Bank Accounts'
      ImageIndex = 14
      OnExecute = actListBankAccountsExecute
    end
    object actListInactiveAccounts: TAction
      Category = 'Reports'
      Caption = 'List Inactive Accounts'
      ImageIndex = 14
      OnExecute = actListInactiveAccountsExecute
    end
    object acCurrencies: TAction
      Category = 'Currency'
      Caption = 'Maintain Currencies'
      ImageIndex = 36
      OnExecute = acCurrenciesExecute
    end
    object acExchangeRates: TAction
      Category = 'Currency'
      Caption = 'Maintain Exchange Rates'
      ImageIndex = 37
      OnExecute = acExchangeRatesExecute
    end
    object acSendProvReq: TAction
      Category = 'Provisional'
      Caption = 'acSendProvReq'
      ImageIndex = 8
      OnExecute = actSendProvReqExecute
    end
    object acAddProvTrans: TAction
      Category = 'Provisional'
      Caption = 'acAddProvTrans'
      ImageIndex = 12
      OnExecute = acAddProvTransExecute
    end
  end
  object pmGrid: TPopupMenu
    Images = AppImages.ilFileActions_ClientMgr
    OnPopup = pmGridPopup
    Left = 96
    Top = 96
  end
end
