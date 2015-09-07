object dlgStatusReportRange: TdlgStatusReportRange
  Left = 397
  Top = 335
  BorderStyle = bsDialog
  Caption = 'Range for Status Report'
  ClientHeight = 332
  ClientWidth = 431
  Color = clWindow
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  PixelsPerInch = 96
  TextHeight = 13
  object lblFrom: TLabel
    Left = 16
    Top = 171
    Width = 82
    Height = 13
    Caption = 'From Client Code'
    FocusControl = edtFromCode
  end
  object lblTo: TLabel
    Left = 16
    Top = 203
    Width = 70
    Height = 13
    Caption = 'To Client Code'
    FocusControl = edtToCode
  end
  object Label1: TLabel
    Left = 16
    Top = 111
    Width = 48
    Height = 13
    Caption = 'Select by:'
  end
  object Label2: TLabel
    Left = 16
    Top = 8
    Width = 340
    Height = 13
    Caption = 
      'Select the date range for the Client Status Report (maximum 12 m' +
      'ths).'
  end
  object edtToCode: TEdit
    Left = 144
    Top = 200
    Width = 89
    Height = 24
    BorderStyle = bsNone
    CharCase = ecUpperCase
    TabOrder = 3
  end
  object edtFromCode: TEdit
    Left = 144
    Top = 170
    Width = 89
    Height = 24
    BorderStyle = bsNone
    CharCase = ecUpperCase
    TabOrder = 2
  end
  object rbClient: TRadioButton
    Left = 144
    Top = 111
    Width = 113
    Height = 17
    Caption = '&Client'
    Checked = True
    TabOrder = 0
    TabStop = True
    OnClick = rbClientClick
  end
  object rbStaffMember: TRadioButton
    Left = 144
    Top = 134
    Width = 137
    Height = 17
    Caption = 'Staff &Member'
    TabOrder = 1
    OnClick = rbClientClick
  end
  inline DateSelector: TfmeDateSelector
    Left = 16
    Top = 35
    Width = 361
    Height = 70
    TabOrder = 4
    TabStop = True
    ExplicitLeft = 16
    ExplicitTop = 35
    ExplicitWidth = 361
    inherited btnPrev: TSpeedButton
      Left = 248
      ExplicitLeft = 248
    end
    inherited btnNext: TSpeedButton
      Left = 272
      ExplicitLeft = 272
    end
    inherited btnQuik: TSpeedButton
      Left = 301
      ExplicitLeft = 301
    end
    inherited eDateFrom: TOvcPictureField
      Left = 128
      Epoch = 0
      ExplicitLeft = 128
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    inherited eDateTo: TOvcPictureField
      Left = 128
      Epoch = 0
      ExplicitLeft = 128
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    inherited pmDates: TPopupMenu
      Left = 248
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
      Left = 280
    end
  end
  object pnlControls: TPanel
    Left = 0
    Top = 282
    Width = 431
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 5
    DesignSize = (
      431
      50)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 431
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnPreview: TButton
      Left = 3
      Top = 15
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Previe&w'
      Default = True
      TabOrder = 0
      OnClick = btnPreviewClick
      ExplicitTop = 22
    end
    object btnFile: TButton
      Left = 83
      Top = 15
      Width = 75
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Fil&e'
      TabOrder = 1
      OnClick = btnFileClick
      ExplicitTop = 22
    end
    object btnPrint: TButton
      Left = 268
      Top = 15
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Print'
      TabOrder = 2
      OnClick = btnPrintClick
      ExplicitTop = 22
    end
    object btnCancel: TButton
      Left = 351
      Top = 15
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 3
      OnClick = btnCancelClick
      ExplicitTop = 22
    end
  end
end
