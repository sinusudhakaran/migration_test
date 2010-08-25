object fmGoToDateForm: TfmGoToDateForm
  Left = 160
  Top = 234
  BorderStyle = bsDialog
  Caption = 'fmGoToDateForm'
  ClientHeight = 90
  ClientWidth = 336
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object cxGroupBox1: TcxGroupBox
    Left = 8
    Top = 4
    Alignment = alCenterCenter
    TabOrder = 0
    Height = 77
    Width = 213
    object lbDate: TLabel
      Left = 10
      Top = 20
      Width = 31
      Height = 13
      Caption = 'lbDate'
      FocusControl = deDate
      Transparent = True
    end
    object lbShowIn: TLabel
      Left = 10
      Top = 48
      Width = 44
      Height = 13
      Caption = 'lbShowIn'
      FocusControl = cbShowIn
      Transparent = True
    end
    object deDate: TcxDateEdit
      Left = 80
      Top = 16
      Properties.DateButtons = [btnToday]
      TabOrder = 0
      Width = 121
    end
    object cbShowIn: TcxComboBox
      Left = 80
      Top = 44
      Properties.DropDownListStyle = lsFixedList
      TabOrder = 1
      Width = 121
    end
  end
  object btnOk: TcxButton
    Left = 232
    Top = 8
    Width = 95
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TcxButton
    Left = 232
    Top = 42
    Width = 95
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
