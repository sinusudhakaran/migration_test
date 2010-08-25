object dxfmOptions: TdxfmOptions
  Left = 310
  Top = 187
  ActiveControl = chbxShowMargins
  BorderStyle = bsDialog
  Caption = 'Preferences'
  ClientHeight = 247
  ClientWidth = 536
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 5
    Top = 4
    Width = 526
    Height = 207
    ActivePage = tshGeneral
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    TabStop = False
    object tshGeneral: TTabSheet
      Caption = 'General'
      object gbxShow: TGroupBox
        Left = 6
        Top = 4
        Width = 250
        Height = 104
        Caption = ' &Show '
        TabOrder = 0
        object chbxShowMargins: TCheckBox
          Left = 10
          Top = 22
          Width = 230
          Height = 17
          Caption = '&Margins'
          TabOrder = 0
          OnClick = FormChanged
        end
        object chbxShowMarginsHints: TCheckBox
          Left = 10
          Top = 49
          Width = 230
          Height = 17
          Caption = 'Margins &hints'
          TabOrder = 1
          OnClick = FormChanged
        end
        object chbxShowMarginsHintsWhileDragging: TCheckBox
          Left = 10
          Top = 75
          Width = 230
          Height = 17
          Caption = 'Margins hints while &dragging'
          TabOrder = 2
          OnClick = FormChanged
        end
      end
      object gbxMeasurementUnits: TGroupBox
        Left = 6
        Top = 109
        Width = 250
        Height = 61
        TabOrder = 2
        object lblMeasurementUnits: TLabel
          Left = 8
          Top = 12
          Width = 95
          Height = 13
          Caption = '&Measurement units:'
          FocusControl = cbxMeasurementUnits
          OnClick = lblMeasurementUnitsClick
        end
        object cbxMeasurementUnits: TComboBox
          Left = 8
          Top = 28
          Width = 232
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          OnChange = FormChanged
          Items.Strings = (
            'Default'
            'Inches'
            'Millimeters')
        end
      end
      object gbxMarginsColor: TGroupBox
        Left = 261
        Top = 109
        Width = 250
        Height = 61
        TabOrder = 3
        object lblMarginsColor: TLabel
          Left = 8
          Top = 12
          Width = 67
          Height = 13
          Caption = '&Margins color:'
          OnClick = lblMarginsColorClick
        end
        object bvlMarginColorHolder: TBevel
          Left = 8
          Top = 28
          Width = 231
          Height = 21
          Visible = False
        end
      end
      object gbxZoomOpt: TGroupBox
        Left = 261
        Top = 4
        Width = 250
        Height = 104
        TabOrder = 1
        object lblZoomStep: TLabel
          Left = 10
          Top = 54
          Width = 58
          Height = 13
          Caption = 'Zoom &Step :'
          OnClick = lblZoomStepClick
        end
        object bvlZoomStepHolder: TBevel
          Left = 103
          Top = 50
          Width = 67
          Height = 21
          Visible = False
        end
        object chbxZoomOnRoll: TCheckBox
          Left = 10
          Top = 22
          Width = 230
          Height = 17
          Caption = '&Zoom on roll with IntelliMouse'
          TabOrder = 0
          OnClick = FormChanged
        end
      end
    end
  end
  object btnOk: TButton
    Left = 294
    Top = 218
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 375
    Top = 218
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 456
    Top = 218
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
  end
end
