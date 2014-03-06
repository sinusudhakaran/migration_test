object dlgSelectJournal: TdlgSelectJournal
  Scaled = False
Left = 246
  Top = 234
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsDialog
  Caption = 'dlgSelectJournal'
  ClientHeight = 218
  ClientWidth = 506
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
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 174
    Align = alClient
    TabOrder = 0
    object Label1: TLabel
      Left = 48
      Top = 16
      Width = 401
      Height = 25
      AutoSize = False
      Caption = 'Enter the EFFECTIVE Date for this Journal.'
    end
    object Label3: TLabel
      Left = 48
      Top = 56
      Width = 61
      Height = 13
      Caption = '&Journal Date'
    end
    object Label2: TLabel
      Left = 48
      Top = 87
      Width = 50
      Height = 13
      Caption = 'Reference'
    end
    object Label4: TLabel
      Left = 48
      Top = 114
      Width = 45
      Height = 13
      Caption = 'Narration'
    end
    object eDate: TOvcPictureField
      Left = 128
      Top = 56
      Width = 79
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
      OnDblClick = eDateDblClick
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object ERef: TEdit
      Left = 128
      Top = 84
      Width = 121
      Height = 21
      MaxLength = 12
      TabOrder = 1
    end
    object ENarration: TEdit
      Left = 128
      Top = 111
      Width = 225
      Height = 21
      MaxLength = 200
      TabOrder = 2
    end
    object rgAction: TRadioGroup
      Left = 368
      Top = 38
      Width = 128
      Height = 94
      Caption = 'Action'
      ItemIndex = 0
      Items.Strings = (
        '&Normal'
        '&Reversing'
        '&Standing')
      TabOrder = 3
    end
    object BtnCal: TButton
      Left = 213
      Top = 58
      Width = 21
      Height = 20
      Caption = '...'
      TabOrder = 4
      OnClick = BtnCalClick
    end
  end
  object PBottom: TPanel
    Left = 0
    Top = 174
    Width = 506
    Height = 44
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      506
      44)
    object btnOK: TButton
      Left = 341
      Top = 11
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 421
      Top = 11
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      BiDiMode = bdLeftToRight
      Cancel = True
      Caption = 'Cancel'
      ParentBiDiMode = False
      TabOrder = 1
      OnClick = btnCancelClick
    end
    object btnView: TButton
      Left = 255
      Top = 11
      Width = 80
      Height = 25
      Caption = 'View &Month'
      TabOrder = 2
      OnClick = btnViewClick
    end
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
    Left = 8
    Top = 88
  end
end
