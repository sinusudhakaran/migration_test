object dlgHistCheques: TdlgHistCheques
  Scaled = False
Left = 376
  Top = 270
  BorderIcons = [biSystemMenu]
  Caption = 'Add Cheques'
  ClientHeight = 235
  ClientWidth = 449
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    449
    235)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 88
    Width = 61
    Height = 13
    Caption = 'Default Date'
  end
  object Label2: TLabel
    Left = 16
    Top = 128
    Width = 111
    Height = 13
    Caption = 'Cheque Number Range'
  end
  object Label3: TLabel
    Left = 290
    Top = 128
    Width = 4
    Height = 13
    Caption = '-'
  end
  object Label4: TLabel
    Left = 16
    Top = 16
    Width = 421
    Height = 57
    AutoSize = False
    Caption = 
      'Enter the range of Cheque Numbers you wish to add.   All Cheques' +
      ' will be created with their date set to the default date.  You c' +
      'an override this when entering the transaction details.'
    WordWrap = True
  end
  object Label5: TLabel
    Left = 16
    Top = 155
    Width = 421
    Height = 43
    AutoSize = False
    Caption = 
      'Note:  A Cheque number will not be added if it is detected in th' +
      'e existing transactions for this Bank Account.'
    WordWrap = True
  end
  object btnOK: TButton
    Left = 280
    Top = 204
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 364
    Top = 204
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object eDateFrom: TOvcPictureField
    Left = 168
    Top = 88
    Width = 111
    Height = 22
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
    OnError = eDateFromError
    RangeHigh = {25600D00000000000000}
    RangeLow = {00000000000000000000}
  end
  object nfCheqFrom: TOvcNumericField
    Left = 168
    Top = 127
    Width = 113
    Height = 22
    Cursor = crIBeam
    DataType = nftLongInt
    AutoSize = False
    BorderStyle = bsNone
    CaretOvr.Shape = csBlock
    Controller = OvcController1
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = '999999'
    TabOrder = 1
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
  end
  object nfCheqTo: TOvcNumericField
    Left = 304
    Top = 127
    Width = 113
    Height = 22
    Cursor = crIBeam
    DataType = nftLongInt
    AutoSize = False
    BorderStyle = bsNone
    CaretOvr.Shape = csBlock
    Controller = OvcController1
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Options = []
    PictureMask = '999999'
    TabOrder = 2
    RangeHigh = {FFFFFF7F000000000000}
    RangeLow = {00000080000000000000}
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
  end
end
