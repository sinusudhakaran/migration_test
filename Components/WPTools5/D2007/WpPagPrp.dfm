object WPPageProp: TWPPageProp
  Left = 21
  Top = 157
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Page Layout'
  ClientHeight = 496
  ClientWidth = 428
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Panel2: TPanel
    Left = 0
    Top = 169
    Width = 428
    Height = 327
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PaperSize: TGroupBox
      Left = 11
      Top = 12
      Width = 405
      Height = 110
      Caption = 'Papersize'
      TabOrder = 0
      object labWidth: TLabel
        Left = 10
        Top = 73
        Width = 68
        Height = 16
        AutoSize = False
        Caption = 'Width'
        FocusControl = PW
      end
      object labHeight: TLabel
        Left = 217
        Top = 73
        Width = 67
        Height = 16
        AutoSize = False
        Caption = 'Height'
        FocusControl = PH
      end
      object PW: TWPValueEdit
        Left = 89
        Top = 69
        Width = 93
        Height = 26
        AvailableUnits = [euInch, euCm, euPt]
        UnitType = euCm
        OnUnitChange = MLUnitChange
        TabOrder = 1
        OnChange = PaperSizeChange
        AllowNegative = False
        Value = 0
        IntValue = 0
        Undefined = False
      end
      object PH: TWPValueEdit
        Left = 295
        Top = 69
        Width = 94
        Height = 26
        AvailableUnits = [euInch, euCm, euPt]
        UnitType = euCm
        OnUnitChange = MLUnitChange
        TabOrder = 2
        OnChange = PaperSizeChange
        AllowNegative = False
        Value = 0
        IntValue = 0
        Undefined = False
      end
      object cbxPaperSize: TComboBox
        Left = 10
        Top = 30
        Width = 379
        Height = 24
        Style = csDropDownList
        ItemHeight = 16
        TabOrder = 0
        OnChange = cbxPaperSizeChange
        Items.Strings = (
          '')
      end
    end
    object Orientation: TRadioGroup
      Left = 11
      Top = 222
      Width = 405
      Height = 60
      Caption = 'Orientation'
      Columns = 2
      Items.Strings = (
        'P&ortrait'
        'L&andscape')
      TabOrder = 1
      OnClick = OrientationClick
    end
    object Margins: TGroupBox
      Left = 11
      Top = 126
      Width = 405
      Height = 92
      Caption = 'Margins'
      TabOrder = 2
      object labTop: TLabel
        Left = 10
        Top = 65
        Width = 68
        Height = 16
        AutoSize = False
        Caption = 'Top'
        FocusControl = MT
      end
      object labBottom: TLabel
        Left = 217
        Top = 64
        Width = 67
        Height = 16
        AutoSize = False
        Caption = 'Bottom'
        FocusControl = MB
      end
      object labLeft: TLabel
        Left = 10
        Top = 25
        Width = 68
        Height = 16
        AutoSize = False
        Caption = 'Left'
        FocusControl = ML
      end
      object labRight: TLabel
        Left = 217
        Top = 25
        Width = 67
        Height = 16
        AutoSize = False
        Caption = 'Right'
        FocusControl = MR
      end
      object HeaderMarg: TLabel
        Left = 10
        Top = 105
        Width = 46
        Height = 16
        Caption = 'Header'
      end
      object FooterMarg: TLabel
        Left = 217
        Top = 105
        Width = 39
        Height = 16
        Caption = 'Footer'
      end
      object MT: TWPValueEdit
        Left = 89
        Top = 59
        Width = 93
        Height = 26
        AvailableUnits = [euInch, euCm, euPt]
        UnitType = euCm
        OnUnitChange = MLUnitChange
        TabOrder = 1
        OnChange = MTChange
        OnExit = CheckMargins
        AllowNegative = False
        Value = 0
        IntValue = 0
        Undefined = False
      end
      object MB: TWPValueEdit
        Left = 295
        Top = 59
        Width = 94
        Height = 26
        AvailableUnits = [euInch, euCm, euPt]
        UnitType = euCm
        OnUnitChange = MLUnitChange
        TabOrder = 3
        OnChange = MBChange
        OnExit = CheckMargins
        AllowNegative = False
        Value = 0
        IntValue = 0
        Undefined = False
      end
      object ML: TWPValueEdit
        Left = 89
        Top = 20
        Width = 93
        Height = 26
        AvailableUnits = [euInch, euCm, euPt]
        UnitType = euCm
        OnUnitChange = MLUnitChange
        TabOrder = 0
        OnChange = MLChange
        OnExit = CheckMargins
        AllowNegative = False
        Value = 0
        IntValue = 0
        Undefined = False
      end
      object MR: TWPValueEdit
        Left = 295
        Top = 20
        Width = 94
        Height = 26
        AvailableUnits = [euInch, euCm, euPt]
        UnitType = euCm
        OnUnitChange = MLUnitChange
        TabOrder = 2
        OnChange = MRChange
        OnExit = CheckMargins
        AllowNegative = False
        Value = 0
        IntValue = 0
        Undefined = False
      end
      object MH: TWPValueEdit
        Left = 89
        Top = 100
        Width = 93
        Height = 26
        AvailableUnits = [euInch, euCm, euPt]
        UnitType = euCm
        OnUnitChange = MLUnitChange
        Precision = 3
        TabOrder = 4
        Visible = False
        OnChange = MHChange
        OnExit = CheckMargins
        AllowNegative = False
        Value = 0
        IntValue = 0
        Undefined = False
      end
      object MF: TWPValueEdit
        Left = 295
        Top = 100
        Width = 94
        Height = 26
        AvailableUnits = [euInch, euCm, euPt]
        UnitType = euCm
        OnUnitChange = MLUnitChange
        Precision = 3
        TabOrder = 5
        Visible = False
        OnChange = MHChange
        OnExit = CheckMargins
        AllowNegative = False
        Value = 0
        IntValue = 0
        Undefined = False
      end
    end
    object btnOK: TButton
      Left = 126
      Top = 287
      Width = 92
      Height = 31
      Caption = 'OK'
      Default = True
      TabOrder = 3
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 224
      Top = 287
      Width = 92
      Height = 31
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 4
    end
    object btnPrinter: TButton
      Left = 321
      Top = 286
      Width = 93
      Height = 31
      Cancel = True
      Caption = '&Printer...'
      TabOrder = 5
      OnClick = btnPrinterClick
    end
  end
  object PreviewPanel: TPanel
    Left = 0
    Top = 0
    Width = 428
    Height = 169
    Align = alTop
    BevelOuter = bvNone
    Caption = ' '
    TabOrder = 1
    object PagePreview: TPaintBox
      Left = 0
      Top = 0
      Width = 428
      Height = 169
      Align = alClient
      OnPaint = PagePreviewPaint
    end
  end
  object PSD: TPrinterSetupDialog
    Left = 16
    Top = 16
  end
end
