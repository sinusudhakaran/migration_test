object dlgCodingOptimisationReportRange: TdlgCodingOptimisationReportRange
  Scaled = False
Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Coding Optimisation Report'
  ClientHeight = 259
  ClientWidth = 644
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  DesignSize = (
    644
    259)
  PixelsPerInch = 96
  TextHeight = 13
  object btnPreview: TButton
    Left = 12
    Top = 226
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Previe&w'
    Default = True
    TabOrder = 2
    OnClick = btnPreviewClick
  end
  object btnFile: TButton
    Left = 92
    Top = 226
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Fil&e'
    TabOrder = 3
    OnClick = btnFileClick
  end
  object btnPrint: TButton
    Left = 477
    Top = 229
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Print'
    TabOrder = 4
    OnClick = btnPrintClick
  end
  object btnCancel: TButton
    Left = 561
    Top = 229
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 5
    OnClick = btnCancelClick
  end
  inline DateSelector: TfmeDateSelector
    Left = 19
    Top = 8
    Width = 276
    Height = 70
    TabOrder = 0
    TabStop = True
    ExplicitLeft = 19
    ExplicitTop = 8
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
  inline ClientSelect: TFmeClientSelect
    Left = 4
    Top = 71
    Width = 629
    Height = 142
    TabOrder = 1
    ExplicitLeft = 4
    ExplicitTop = 71
    inherited grpSettings: TGroupBox
      inherited btnFromLookup: TSpeedButton
        OnClick = ClientSelectbtnFromLookupClick
      end
    end
  end
end
