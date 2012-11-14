object frmDeleteRequest: TfrmDeleteRequest
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Request Account Deletes'
  ClientHeight = 450
  ClientWidth = 623
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
    Width = 623
    Height = 241
    Align = alClient
    Lines.Strings = (
      'mAccounts')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 0
  end
  object Prequest: TPanel
    Left = 0
    Top = 41
    Width = 623
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 219
      Height = 13
      Caption = 'Request deletion of the following accounts on'
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
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
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
    Width = 623
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object CheckBox: TCheckBox
      Left = 8
      Top = 13
      Width = 209
      Height = 17
      Caption = 'Mark accounts as deleted'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = CheckBoxClick
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 409
    Width = 623
    Height = 41
    Align = alBottom
    TabOrder = 3
    DesignSize = (
      623
      41)
    object btnOK: TButton
      Left = 456
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 537
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object PRequestText: TPanel
    Left = 0
    Top = 368
    Width = 623
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object lProcessed: TLabel
      Left = 59
      Top = 6
      Width = 285
      Height = 13
      Caption = 'Please allow 14 days for a delete request to be processed. '
    end
    object lCharges: TLabel
      Left = 59
      Top = 25
      Width = 278
      Height = 13
      Caption = 'Normal charges apply until the bank deletes the accounts.'
    end
  end
  object PDeleteText: TPanel
    Left = 0
    Top = 323
    Width = 623
    Height = 45
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 5
    Visible = False
    object LDelete: TLabel
      Left = 59
      Top = 6
      Width = 446
      Height = 13
      Caption = 
        'You should only mark accounts as deleted if the account is no lo' +
        'nger on the BankLink service.'
    end
    object LDownload: TLabel
      Left = 59
      Top = 25
      Width = 398
      Height = 13
      Caption = 
        'Downloaded accounts will be moved to the deleted section of the ' +
        'download report.'
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
