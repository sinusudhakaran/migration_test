object ContactDetailsFrm: TContactDetailsFrm
  Left = 404
  Top = 291
  BorderStyle = bsDialog
  Caption = 'Edit Contact Details'
  ClientHeight = 366
  ClientWidth = 566
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    566
    366)
  PixelsPerInch = 96
  TextHeight = 13
  object Label2: TLabel
    Left = 16
    Top = 43
    Width = 57
    Height = 13
    Caption = 'Client &Name'
    FocusControl = eName
  end
  object Label3: TLabel
    Left = 16
    Top = 69
    Width = 39
    Height = 13
    Caption = 'A&ddress'
    FocusControl = eAddr1
  end
  object Label4: TLabel
    Left = 16
    Top = 186
    Width = 68
    Height = 13
    Caption = 'Con&tact Name'
    FocusControl = eContact
  end
  object Label5: TLabel
    Left = 16
    Top = 219
    Width = 30
    Height = 13
    Caption = '&Phone'
    FocusControl = ePhone
  end
  object Label9: TLabel
    Left = 16
    Top = 283
    Width = 24
    Height = 13
    Caption = 'E&mail'
    FocusControl = eMail
  end
  object Label13: TLabel
    Left = 16
    Top = 248
    Width = 18
    Height = 13
    Caption = 'Fa&x'
    FocusControl = eFax
  end
  object Label15: TLabel
    Left = 328
    Top = 234
    Width = 30
    Height = 13
    Caption = 'Mo&bile'
    FocusControl = eMobile
  end
  object lblUser: TLabel
    Left = 16
    Top = 313
    Width = 58
    Height = 13
    Caption = '&Assigned To'
    FocusControl = cmbUsers
    Visible = False
  end
  object lblCode: TLabel
    Left = 16
    Top = 9
    Width = 55
    Height = 13
    Caption = 'Client &Code'
    FocusControl = eCode
    Visible = False
  end
  object Label1: TLabel
    Left = 16
    Top = 158
    Width = 48
    Height = 13
    Caption = '&Salutation'
    FocusControl = eSal
  end
  object eName: TEdit
    Left = 152
    Top = 39
    Width = 401
    Height = 24
    BorderStyle = bsNone
    Ctl3D = True
    MaxLength = 60
    ParentCtl3D = False
    TabOrder = 1
  end
  object eContact: TEdit
    Left = 152
    Top = 182
    Width = 401
    Height = 24
    BorderStyle = bsNone
    Ctl3D = True
    MaxLength = 60
    ParentCtl3D = False
    TabOrder = 6
  end
  object eMail: TEdit
    Left = 152
    Top = 279
    Width = 401
    Height = 24
    BorderStyle = bsNone
    MaxLength = 80
    TabOrder = 10
  end
  object ePhone: TEdit
    Left = 152
    Top = 215
    Width = 161
    Height = 24
    BorderStyle = bsNone
    Ctl3D = True
    MaxLength = 60
    ParentCtl3D = False
    TabOrder = 7
  end
  object eFax: TEdit
    Left = 152
    Top = 244
    Width = 161
    Height = 24
    BorderStyle = bsNone
    MaxLength = 60
    TabOrder = 8
  end
  object btnOk: TButton
    Left = 405
    Top = 337
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 12
  end
  object btnCancel: TButton
    Left = 485
    Top = 337
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 13
  end
  object eAddr1: TEdit
    Left = 152
    Top = 69
    Width = 401
    Height = 24
    BorderStyle = bsNone
    MaxLength = 60
    TabOrder = 2
  end
  object eAddr2: TEdit
    Left = 152
    Top = 96
    Width = 401
    Height = 24
    BorderStyle = bsNone
    MaxLength = 60
    TabOrder = 3
  end
  object eAddr3: TEdit
    Left = 152
    Top = 123
    Width = 401
    Height = 24
    BorderStyle = bsNone
    MaxLength = 60
    TabOrder = 4
  end
  object eMobile: TEdit
    Left = 392
    Top = 230
    Width = 161
    Height = 24
    BorderStyle = bsNone
    Ctl3D = True
    MaxLength = 60
    ParentCtl3D = False
    TabOrder = 9
  end
  object eCode: TEdit
    Left = 152
    Top = 5
    Width = 161
    Height = 24
    BorderStyle = bsNone
    CharCase = ecUpperCase
    Ctl3D = True
    MaxLength = 8
    ParentCtl3D = False
    TabOrder = 0
    Visible = False
  end
  object cmbUsers: TComboBox
    Left = 152
    Top = 309
    Width = 305
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 11
    Visible = False
  end
  object eSal: TEdit
    Left = 152
    Top = 154
    Width = 161
    Height = 24
    BorderStyle = bsNone
    Ctl3D = True
    MaxLength = 60
    ParentCtl3D = False
    TabOrder = 5
  end
end
