object dlgChooseContactDetails: TdlgChooseContactDetails
  Left = 294
  Top = 207
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Choose Contact Details'
  ClientHeight = 270
  ClientWidth = 436
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 275
    Height = 13
    Caption = 'Use the following contact details for the selected client(s)'
  end
  object lblContactName: TLabel
    Left = 48
    Top = 143
    Width = 38
    Height = 13
    Caption = 'C&ontact'
    FocusControl = eName
  end
  object lblPhone: TLabel
    Left = 48
    Top = 175
    Width = 30
    Height = 13
    Caption = 'P&hone'
    FocusControl = ePhone
  end
  object lblEmail: TLabel
    Left = 48
    Top = 207
    Width = 28
    Height = 13
    Caption = '&E-mail'
    FocusControl = eMail
  end
  object radPractice: TRadioButton
    Left = 32
    Top = 40
    Width = 205
    Height = 17
    Caption = '&Practice Details'
    TabOrder = 0
    OnClick = radPracticeClick
  end
  object radStaffMember: TRadioButton
    Left = 32
    Top = 72
    Width = 205
    Height = 17
    Caption = '&Staff Member Contact Details'
    TabOrder = 1
    OnClick = radPracticeClick
  end
  object radCustom: TRadioButton
    Left = 32
    Top = 104
    Width = 205
    Height = 17
    Caption = '&Custom Contact Details'
    TabOrder = 2
    OnClick = radCustomClick
  end
  object eName: TEdit
    Left = 112
    Top = 140
    Width = 310
    Height = 21
    BorderStyle = bsNone
    Ctl3D = True
    MaxLength = 60
    ParentCtl3D = False
    TabOrder = 3
    Text = 'eName'
  end
  object ePhone: TEdit
    Left = 112
    Top = 172
    Width = 309
    Height = 21
    BorderStyle = bsNone
    Ctl3D = True
    MaxLength = 60
    ParentCtl3D = False
    TabOrder = 4
    Text = 'ePhone'
  end
  object eMail: TEdit
    Left = 112
    Top = 204
    Width = 310
    Height = 21
    BorderStyle = bsNone
    MaxLength = 40
    TabOrder = 5
    Text = 'eMail'
  end
  object btnOK: TButton
    Left = 260
    Top = 237
    Width = 77
    Height = 25
    BiDiMode = bdLeftToRight
    Caption = '&OK'
    Default = True
    ModalResult = 1
    ParentBiDiMode = False
    TabOrder = 6
  end
  object btnCancel: TButton
    Left = 343
    Top = 237
    Width = 75
    Height = 25
    BiDiMode = bdLeftToRight
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    ParentBiDiMode = False
    TabOrder = 7
  end
end
