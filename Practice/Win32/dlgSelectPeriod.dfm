object frmSelectPeriod: TfrmSelectPeriod
  Left = 0
  Top = 0
  ActiveControl = fmeDateSelector1.eDateFrom
  Caption = 'Select GST period'
  ClientHeight = 155
  ClientWidth = 426
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pButton: TPanel
    Left = 0
    Top = 114
    Width = 426
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object btnCancel: TButton
      Left = 336
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object BtnOK: TButton
      Left = 255
      Top = 8
      Width = 75
      Height = 25
      Caption = '&OK'
      Default = True
      TabOrder = 0
      OnClick = BtnOKClick
    end
  end
  inline fmeDateSelector1: TfmeDateSelector
    Left = 70
    Top = 24
    Width = 276
    Height = 70
    TabOrder = 0
    TabStop = True
    ExplicitLeft = 70
    ExplicitTop = 24
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
