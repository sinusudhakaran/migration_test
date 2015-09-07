object dlgCodingOptimisationReportRange: TdlgCodingOptimisationReportRange
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Coding Optimisation Report'
  ClientHeight = 262
  ClientWidth = 634
  Color = clWindow
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
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
  object pnlControls: TPanel
    Left = 0
    Top = 221
    Width = 634
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 2
    ExplicitLeft = 16
    ExplicitTop = 216
    ExplicitWidth = 620
    DesignSize = (
      634
      41)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 634
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 644
    end
    object btnPreview: TButton
      Left = 8
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Previe&w'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
    end
    object btnFile: TButton
      Left = 88
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
    end
    object btnPrint: TButton
      Left = 472
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Print'
      TabOrder = 2
      OnClick = btnPrintClick
      ExplicitLeft = 482
    end
    object btnCancel: TButton
      Left = 553
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 3
      OnClick = btnCancelClick
      ExplicitLeft = 563
    end
  end
end
