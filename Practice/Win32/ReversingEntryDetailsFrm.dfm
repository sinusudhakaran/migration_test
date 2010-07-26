object frmReversingEntryDetails: TfrmReversingEntryDetails
  Left = 279
  Top = 267
  BorderStyle = bsDialog
  Caption = 'Cancel an Unpresented Item'
  ClientHeight = 177
  ClientWidth = 482
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
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    482
    177)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 287
    Height = 13
    Caption = 'A reversing entry will be created with the following details.  '
  end
  object Label2: TLabel
    Left = 16
    Top = 32
    Width = 246
    Height = 13
    Caption = 'Please select the effective date for this transaction'
  end
  object lblRef: TLabel
    Left = 130
    Top = 97
    Width = 27
    Height = 13
    Caption = 'lblRef'
  end
  object lblAmount: TLabel
    Left = 342
    Top = 97
    Width = 47
    Height = 13
    Alignment = taRightJustify
    Caption = 'lblAmount'
  end
  object Label5: TLabel
    Left = 16
    Top = 72
    Width = 23
    Height = 13
    Caption = '&Date'
    FocusControl = eDate
  end
  object Label6: TLabel
    Left = 112
    Top = 72
    Width = 50
    Height = 13
    Caption = 'Reference'
  end
  object Label7: TLabel
    Left = 352
    Top = 75
    Width = 37
    Height = 13
    Alignment = taRightJustify
    Caption = 'Amount'
  end
  object lblReversingPrefix: TLabel
    Left = 112
    Top = 96
    Width = 12
    Height = 13
    Caption = '[!]'
  end
  object eDate: TOvcPictureField
    Left = 16
    Top = 96
    Width = 89
    Height = 24
    Cursor = crIBeam
    DataType = pftDate
    AutoSize = False
    BorderStyle = bsNone
    CaretOvr.Shape = csBlock
    Controller = OvcController1
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
    OnError = eDateError
    RangeHigh = {25600D00000000000000}
    RangeLow = {00000000000000000000}
  end
  object btnOK: TButton
    Left = 318
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 399
    Top = 144
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
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
    Epoch = 2000
    Left = 448
    Top = 8
  end
end
