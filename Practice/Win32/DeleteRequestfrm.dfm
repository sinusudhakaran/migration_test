object frmDeleteRequest: TfrmDeleteRequest
  Scaled = False
Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Request Account Deletes'
  ClientHeight = 450
  ClientWidth = 637
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object EAccounts: TMemo
    Left = 0
    Top = 82
    Width = 637
    Height = 241
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    Lines.Strings = (
      'mAccounts')
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Prequest: TPanel
    Left = 0
    Top = 41
    Width = 637
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 623
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 259
      Height = 16
      Caption = 'Request deletion of the following accounts on'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object EDate: TOvcPictureField
      Left = 326
      Top = 6
      Width = 86
      Height = 22
      Cursor = crIBeam
      DataType = pftDate
      AutoSize = False
      BorderStyle = bsNone
      CaretOvr.Shape = csBlock
      ControlCharColor = clRed
      DecimalPlaces = 0
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Epoch = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
      ParentFont = False
      PictureMask = 'DD/mm/yy'
      TabOrder = 0
      OnChange = EDateChange
      OnDblClick = EDateDblClick
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
  end
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 637
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitWidth = 623
    object CheckBox: TCheckBox
      Left = 8
      Top = 13
      Width = 209
      Height = 17
      Caption = 'Mark accounts as deleted'
      Checked = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      State = cbChecked
      TabOrder = 0
      OnClick = CheckBoxClick
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 409
    Width = 637
    Height = 41
    Align = alBottom
    TabOrder = 3
    ExplicitWidth = 623
    DesignSize = (
      637
      41)
    object btnOK: TButton
      Left = 470
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = btnOKClick
      ExplicitLeft = 456
    end
    object btnCancel: TButton
      Left = 551
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 1
      ExplicitLeft = 537
    end
  end
  object PRequestText: TPanel
    Left = 0
    Top = 368
    Width = 637
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    ExplicitWidth = 623
    object lProcessed: TLabel
      Left = 59
      Top = 6
      Width = 339
      Height = 16
      Caption = 'Please allow 14 days for a delete request to be processed. '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lCharges: TLabel
      Left = 59
      Top = 25
      Width = 330
      Height = 16
      Caption = 'Normal charges apply until the bank deletes the accounts.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
  end
  object PDeleteText: TPanel
    Left = 0
    Top = 323
    Width = 637
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 5
    Visible = False
    ExplicitWidth = 623
    object LDelete: TLabel
      Left = 59
      Top = 6
      Width = 476
      Height = 16
      Caption = 
        'You should only mark accounts as deleted if the account is no lo' +
        'nger with BankLink.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object LDownload: TLabel
      Left = 59
      Top = 25
      Width = 473
      Height = 16
      Caption = 
        'Downloaded accounts will be moved to the deleted section of the ' +
        'download report.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Image1: TImage
      Left = 4
      Top = 2
      Width = 40
      Height = 40
      Transparent = True
    end
  end
end
