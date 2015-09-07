object frmBulkExtract: TfrmBulkExtract
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Extract Bulk Data'
  ClientHeight = 316
  ClientWidth = 640
  Color = clWhite
  ParentFont = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pBtn: TPanel
    Left = 0
    Top = 275
    Width = 640
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      640
      41)
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 640
      Height = 1
      Align = alTop
      Pen.Color = clSilver
    end
    object btnCancel: TButton
      Left = 554
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object btnOK: TButton
      Left = 473
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 0
      OnClick = btnOKClick
    end
  end
  object pnlClientSelect: TPanel
    Left = 0
    Top = 132
    Width = 640
    Height = 143
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    inline ClientSelect: TFmeClientSelect
      Left = 5
      Top = 0
      Width = 629
      Height = 142
      TabOrder = 0
      ExplicitLeft = 5
      inherited grpSettings: TGroupBox
        inherited rbSelectAll: TRadioButton
          Color = clWhite
          ParentColor = False
        end
        inherited rbRange: TRadioButton
          Color = clWhite
          ParentColor = False
        end
        inherited rbSelection: TRadioButton
          Color = clWhite
          ParentColor = False
        end
        inherited Panel1: TPanel
          inherited rbClient: TRadioButton
            Color = clWhite
            ParentColor = False
          end
          inherited rbStaffMember: TRadioButton
            Color = clWhite
            ParentColor = False
          end
          inherited rbGroup: TRadioButton
            Color = clWhite
            ParentColor = False
          end
          inherited rbClientType: TRadioButton
            Color = clWhite
            ParentColor = False
          end
        end
      end
    end
  end
  object pnlBulkExtract: TPanel
    Left = 0
    Top = 0
    Width = 640
    Height = 132
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Label1: TLabel
      Left = 24
      Top = 24
      Width = 34
      Height = 13
      Caption = 'Format'
    end
    object cbExtractor: TComboBox
      Left = 88
      Top = 24
      Width = 196
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
    end
    object btnSetup: TButton
      Left = 290
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Setup'
      TabOrder = 1
      OnClick = btnSetupClick
    end
    inline DateSelector: TfmeDateSelector
      Left = 24
      Top = 64
      Width = 276
      Height = 70
      TabOrder = 2
      TabStop = True
      ExplicitLeft = 24
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
