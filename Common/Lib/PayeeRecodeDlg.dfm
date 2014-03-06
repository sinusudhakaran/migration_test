object dlgPayeeRecode: TdlgPayeeRecode
  Scaled = False
Left = 333
  Top = 245
  BorderStyle = bsDialog
  Caption = 'Code by Payee'
  ClientHeight = 218
  ClientWidth = 383
  Color = clWindow
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 326
    Height = 13
    Caption = 
      'This transaction has already been coded.  What do you want to do' +
      '?'
    Transparent = True
    WordWrap = True
  end
  object Bevel1: TBevel
    Left = -8
    Top = 168
    Width = 401
    Height = 10
    Shape = bsBottomLine
  end
  object rbtnClear: TRzBmpButton
    Left = 16
    Top = 49
    Width = 353
    Height = 44
    Bitmaps.TransparentColor = clOlive
    Color = clBtnFace
    ShowDownPattern = False
    ButtonSize = bszNeither
    Caption = 'Clear'
    TabOrder = 0
    OnClick = rbtnClearClick
  end
  object btnCancel: TButton
    Left = 294
    Top = 184
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = btnCancelClick
  end
  object rbtnPreserve: TRzBmpButton
    Left = 16
    Top = 105
    Width = 353
    Height = 44
    Bitmaps.TransparentColor = clOlive
    Color = clBtnFace
    ShowDownPattern = False
    Caption = 'Preserve'
    TabOrder = 2
    OnClick = rbtnPreserveClick
  end
  object pnlClear: TPanel
    Left = 24
    Top = 53
    Width = 337
    Height = 37
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = clWindow
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
    object ruClear: TRzURLLabel
      Left = 8
      Top = 7
      Width = 321
      Height = 37
      AutoSize = False
      Caption = 'Recode this entry using the defaults for the payee.'
      FocusControl = rbtnClear
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlight
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      WordWrap = True
      OnClick = ruClearClick
      FlyByColor = clBlue
      FlyByEnabled = True
    end
  end
  object pnlPreserve: TPanel
    Left = 24
    Top = 109
    Width = 337
    Height = 37
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = clWindow
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
    object ruPreserve: TRzURLLabel
      Left = 7
      Top = 7
      Width = 324
      Height = 34
      AutoSize = False
      Caption = 'Preserve the existing coding but change the payee'
      FocusControl = rbtnPreserve
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clHighlight
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      WordWrap = True
      OnClick = ruPreserveClick
      FlyByColor = clBlue
      FlyByEnabled = True
    end
  end
end
