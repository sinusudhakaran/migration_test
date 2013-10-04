object dlgExtract: TdlgExtract
  Left = 279
  Top = 200
  BorderStyle = bsDialog
  Caption = 'Extract Data'
  ClientHeight = 329
  ClientWidth = 538
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  OnShow = FormShow
  DesignSize = (
    538
    329)
  PixelsPerInch = 96
  TextHeight = 13
  object lblMessage: TLabel
    Left = 26
    Top = 16
    Width = 500
    Height = 32
    AutoSize = False
    Caption = '%s will now save the selected entries into an extract file.'
    ShowAccelChar = False
    WordWrap = True
  end
  object lblFormat: TLabel
    Left = 26
    Top = 54
    Width = 506
    Height = 27
    AutoSize = False
    Caption = 'The file will be saved in Solution 6 format.'
    ShowAccelChar = False
    WordWrap = True
  end
  object lblData: TLabel
    Left = 26
    Top = 106
    Width = 504
    Height = 16
    AutoSize = False
    Caption = 'lblData'
    WordWrap = True
  end
  object btnOk: TButton
    Left = 377
    Top = 298
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 457
    Top = 298
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object chkNewFormat: TCheckBox
    Left = 26
    Top = 302
    Width = 273
    Height = 17
    Caption = 'Extract Data in New &Format'
    TabOrder = 1
  end
  inline DateSelector: TfmeDateSelector
    Left = 26
    Top = 128
    Width = 498
    Height = 70
    TabOrder = 0
    TabStop = True
    ExplicitLeft = 26
    ExplicitTop = 128
    ExplicitWidth = 498
    inherited btnPrev: TSpeedButton
      Left = 241
      Top = 5
      OnClick = DateSelectorbtnPrevClick
      ExplicitLeft = 241
      ExplicitTop = 5
    end
    inherited btnNext: TSpeedButton
      Left = 266
      Top = 5
      ExplicitLeft = 266
      ExplicitTop = 5
    end
    inherited btnQuik: TSpeedButton
      Left = 297
      Top = 5
      ExplicitLeft = 297
      ExplicitTop = 5
    end
    inherited eDateFrom: TOvcPictureField
      Left = 130
      Epoch = 0
      ExplicitLeft = 130
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    inherited eDateTo: TOvcPictureField
      Left = 130
      Epoch = 0
      ExplicitLeft = 130
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    inherited pmDates: TPopupMenu
      Left = 272
    end
    inherited OvcController1: TOvcController
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
      Left = 264
    end
  end
  object pnlSaveTo: TPanel
    Left = 16
    Top = 208
    Width = 508
    Height = 65
    BevelOuter = bvNone
    TabOrder = 2
    object Label6: TLabel
      Left = 10
      Top = 41
      Width = 75
      Height = 13
      Caption = '&Save Entries To'
      FocusControl = eTo
    end
    object btnToFolder: TSpeedButton
      Left = 454
      Top = 37
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      OnClick = btnToFolderClick
    end
    object eTo: TEdit
      Left = 140
      Top = 37
      Width = 313
      Height = 24
      BorderStyle = bsNone
      TabOrder = 0
      Text = 'eTo'
    end
    object pnlMASLedgerCode: TPanel
      Left = 4
      Top = -7
      Width = 497
      Height = 41
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      object Label3: TLabel
        Left = 6
        Top = 14
        Width = 80
        Height = 13
        Caption = 'MAS ledger code'
      end
      object lblLedgerCodeToUse: TLabel
        Left = 136
        Top = 14
        Width = 98
        Height = 13
        Caption = 'lblLedgerCodeToUse'
        ShowAccelChar = False
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Filter = 'All Files (*.*)|*.*'
    Title = 'Save Entries To'
    Left = 392
    Top = 136
  end
end
