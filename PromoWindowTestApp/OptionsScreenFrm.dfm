object FrmOptionsScreen: TFrmOptionsScreen
  Left = 0
  Top = 0
  ActiveControl = btnPromos
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  ClientHeight = 492
  ClientWidth = 475
  Color = clWindow
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 17
  object Label2: TLabel
    Left = 21
    Top = 290
    Width = 88
    Height = 17
    Caption = 'Upgrade From'
  end
  object Label3: TLabel
    Left = 21
    Top = 343
    Width = 72
    Height = 17
    Caption = 'Upgrade To'
  end
  object Label1: TLabel
    Left = 21
    Top = 391
    Width = 79
    Height = 17
    Caption = 'Choose Date'
  end
  object pnlControls: TPanel
    Left = 0
    Top = 442
    Width = 475
    Height = 50
    Align = alBottom
    BevelOuter = bvNone
    Caption = ' '
    ParentBackground = False
    TabOrder = 6
    ExplicitWidth = 545
    object ShapeBorder: TShape
      Left = 0
      Top = 0
      Width = 475
      Height = 1
      Align = alTop
      Pen.Color = clSilver
      ExplicitWidth = 545
    end
    object btnPromos: TBitBtn
      Left = 160
      Top = 7
      Width = 199
      Height = 33
      Caption = 'MYOB Communications'
      TabOrder = 0
      OnClick = btnPromosClick
    end
    object btnClose: TBitBtn
      Left = 367
      Top = 7
      Width = 98
      Height = 33
      Caption = 'Close'
      TabOrder = 1
      OnClick = btnCloseClick
    end
  end
  object gbContentTypes: TGroupBox
    Left = 10
    Top = 10
    Width = 455
    Height = 75
    Caption = 'Login Type'
    TabOrder = 0
    object rbFirstLogin: TRadioButton
      Left = 31
      Top = 31
      Width = 148
      Height = 23
      Caption = 'First Login'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbSecondLogin: TRadioButton
      Left = 220
      Top = 31
      Width = 147
      Height = 23
      Caption = 'Second Login'
      TabOrder = 1
    end
  end
  object gbUserTypes: TGroupBox
    Left = 10
    Top = 110
    Width = 454
    Height = 74
    Caption = 'User Types'
    TabOrder = 1
    object rbAdmin: TRadioButton
      Left = 31
      Top = 31
      Width = 81
      Height = 23
      Caption = 'Admin'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbRestricted: TRadioButton
      Left = 263
      Top = 31
      Width = 102
      Height = 23
      Caption = 'Restricted'
      TabOrder = 2
    end
    object rbNormal: TRadioButton
      Left = 137
      Top = 31
      Width = 80
      Height = 23
      Caption = 'Normal'
      TabOrder = 1
    end
    object rbBooks: TRadioButton
      Left = 377
      Top = 31
      Width = 147
      Height = 23
      Caption = 'Books'
      TabOrder = 3
    end
  end
  object edtVersionFrom: TEdit
    Left = 184
    Top = 286
    Width = 190
    Height = 25
    TabOrder = 3
  end
  object gbCountry: TGroupBox
    Left = 21
    Top = 204
    Width = 242
    Height = 75
    Caption = 'Geography'
    TabOrder = 2
    object rbNZ: TRadioButton
      Left = 31
      Top = 31
      Width = 89
      Height = 23
      Caption = 'nz'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbAU: TRadioButton
      Left = 157
      Top = 31
      Width = 93
      Height = 23
      Caption = 'au'
      TabOrder = 1
    end
  end
  object edtVersionTo: TEdit
    Left = 184
    Top = 339
    Width = 190
    Height = 25
    TabOrder = 4
    Text = '5.29.4'
  end
  object dtDate: TDateTimePicker
    Left = 184
    Top = 387
    Width = 135
    Height = 25
    Date = 42269.670096284720000000
    Time = 42269.670096284720000000
    TabOrder = 5
  end
end
