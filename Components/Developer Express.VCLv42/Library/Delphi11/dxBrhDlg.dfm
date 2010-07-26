object dxBrushDlg: TdxBrushDlg
  Left = 363
  Top = 214
  BorderStyle = bsDialog
  Caption = 'Setup Brush properties'
  ClientHeight = 120
  ClientWidth = 229
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
  object GroupBox1: TGroupBox
    Left = 4
    Top = 1
    Width = 222
    Height = 85
    TabOrder = 0
    object lblColor: TLabel
      Left = 6
      Top = 21
      Width = 29
      Height = 13
      Caption = '&Color:'
      OnClick = lblClick
    end
    object lblStyle: TLabel
      Left = 6
      Top = 53
      Width = 28
      Height = 13
      Caption = '&Style:'
      OnClick = lblClick
    end
    object bvlColorHolder: TBevel
      Left = 38
      Top = 16
      Width = 178
      Height = 23
      Visible = False
    end
    object bvlStyleHolder: TBevel
      Left = 38
      Top = 48
      Width = 178
      Height = 22
      Visible = False
    end
  end
  object btnOK: TButton
    Left = 70
    Top = 93
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 151
    Top = 93
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
