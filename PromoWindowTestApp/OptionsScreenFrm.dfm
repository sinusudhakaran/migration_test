object FrmOptionsScreen: TFrmOptionsScreen
  Left = 0
  Top = 0
  ActiveControl = btnPromos
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 376
  ClientWidth = 388
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 222
    Width = 68
    Height = 13
    Caption = 'Upgrade From'
  end
  object Label3: TLabel
    Left = 16
    Top = 262
    Width = 56
    Height = 13
    Caption = 'Upgrade To'
  end
  object Label1: TLabel
    Left = 16
    Top = 299
    Width = 62
    Height = 13
    Caption = 'Choose Date'
  end
  object pnlControls: TPanel
    Left = 0
    Top = 338
    Width = 388
    Height = 38
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 6
    ExplicitWidth = 411
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 388
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 535
    end
    object btnPromos: TBitBtn
      Left = 147
      Top = 7
      Width = 152
      Height = 25
      Caption = 'MYOB Communications'
      TabOrder = 0
      OnClick = btnPromosClick
    end
    object btnClose: TBitBtn
      Left = 305
      Top = 7
      Width = 75
      Height = 25
      Caption = 'Close'
      TabOrder = 1
      OnClick = btnCloseClick
    end
  end
  object gbContentTypes: TGroupBox
    Left = 8
    Top = 8
    Width = 337
    Height = 57
    Caption = 'Login Type'
    TabOrder = 0
    object rbFirstLogin: TRadioButton
      Left = 24
      Top = 24
      Width = 113
      Height = 17
      Caption = 'First Login'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbSecondLogin: TRadioButton
      Left = 168
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Second Login'
      TabOrder = 1
    end
  end
  object gbUserTypes: TGroupBox
    Left = 8
    Top = 84
    Width = 369
    Height = 57
    Caption = 'User Types'
    TabOrder = 1
    object rbAdmin: TRadioButton
      Left = 24
      Top = 24
      Width = 62
      Height = 17
      Caption = 'Admin'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbRestricted: TRadioButton
      Left = 201
      Top = 24
      Width = 78
      Height = 17
      Caption = 'Restricted'
      TabOrder = 2
    end
    object rbNormal: TRadioButton
      Left = 105
      Top = 24
      Width = 61
      Height = 17
      Caption = 'Normal'
      TabOrder = 1
    end
    object rbBooks: TRadioButton
      Left = 288
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Books'
      TabOrder = 3
    end
  end
  object edtVersionFrom: TEdit
    Left = 141
    Top = 219
    Width = 145
    Height = 21
    TabOrder = 3
  end
  object gbCountry: TGroupBox
    Left = 16
    Top = 156
    Width = 233
    Height = 57
    Caption = 'Geography'
    TabOrder = 2
    object rbNZ: TRadioButton
      Left = 24
      Top = 24
      Width = 68
      Height = 17
      Caption = 'nz'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbAU: TRadioButton
      Left = 120
      Top = 24
      Width = 71
      Height = 17
      Caption = 'au'
      TabOrder = 1
    end
  end
  object edtVersionTo: TEdit
    Left = 141
    Top = 259
    Width = 145
    Height = 21
    TabOrder = 4
    Text = '5.29.1'
  end
  object dtDate: TDateTimePicker
    Left = 141
    Top = 296
    Width = 103
    Height = 21
    Date = 42269.670096284720000000
    Time = 42269.670096284720000000
    TabOrder = 5
  end
end
