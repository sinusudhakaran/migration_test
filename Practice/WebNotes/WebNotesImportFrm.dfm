object WebNotesImportForm: TWebNotesImportForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'WebNotesImportForm'
  ClientHeight = 234
  ClientWidth = 393
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pBtn: TPanel
    Left = 0
    Top = 193
    Width = 393
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      393
      41)
    object btnCancel: TButton
      Left = 304
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object btnOK: TButton
      Left = 215
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = 'Import'
      Enabled = False
      TabOrder = 1
      OnClick = btnOKClick
    end
  end
  object pList: TPanel
    Left = 0
    Top = 0
    Width = 393
    Height = 193
    Align = alClient
    TabOrder = 1
    object lAvailable: TLabel
      Left = 32
      Top = 16
      Width = 145
      Height = 13
      Caption = 'Checking for available data ...'
    end
    object lblClientSave: TLabel
      Left = 96
      Top = 140
      Width = 249
      Height = 37
      AutoSize = False
      Caption = 'Note: The client file will be saved during the import.'
      WordWrap = True
    end
    inline DateSelector: TfmeDateSelector
      Left = 32
      Top = 64
      Width = 276
      Height = 70
      TabOrder = 0
      TabStop = True
      ExplicitLeft = 32
      ExplicitTop = 64
      inherited eDateFrom: TOvcPictureField
        Epoch = 0
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
      end
      inherited eDateTo: TOvcPictureField
        Epoch = 0
        RangeHigh = {25600D00000000000000}
        RangeLow = {00000000000000000000}
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
      end
    end
  end
end
