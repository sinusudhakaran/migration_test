object DateRangeFrm: TDateRangeFrm
  Left = 0
  Top = 0
  Caption = 'DateRangeFrm'
  ClientHeight = 214
  ClientWidth = 407
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ltext: TLabel
    Left = 20
    Top = 22
    Width = 365
    Height = 35
    AutoSize = False
    Caption = 
      'Enter the starting and finsishilg date for the period you want t' +
      'o lock'
    WordWrap = True
  end
  object pButtons: TPanel
    Left = 0
    Top = 173
    Width = 407
    Height = 41
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      407
      41)
    object btnCancel: TButton
      Left = 321
      Top = 8
      Width = 77
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
    end
    object BtnoK: TButton
      Left = 241
      Top = 8
      Width = 77
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 1
      OnClick = BtnoKClick
    end
  end
  inline DateSelector: TfmeDateSelector
    Left = 20
    Top = 73
    Width = 276
    Height = 65
    TabOrder = 1
    TabStop = True
    ExplicitLeft = 20
    ExplicitTop = 73
    ExplicitHeight = 65
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
