object ChangePasswordForm: TChangePasswordForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Change Password'
  ClientHeight = 297
  ClientWidth = 482
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlNote: TPanel
    Left = 0
    Top = 193
    Width = 482
    Height = 62
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    DesignSize = (
      482
      62)
    object gbxNote: TGroupBox
      Left = 16
      Top = 8
      Width = 448
      Height = 54
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      DesignSize = (
        448
        54)
      object lblNote: TLabel
        Left = 16
        Top = 16
        Width = 332
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Note: Note to user about entering their BankLink Online Login de' +
          'tails.'
        WordWrap = True
      end
    end
  end
  object pnlCurrent: TPanel
    Left = 0
    Top = 82
    Width = 482
    Height = 37
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblCurrent: TLabel
      Left = 16
      Top = 11
      Width = 86
      Height = 13
      Caption = '&Current Password'
    end
    object eCurrent: TEdit
      Left = 144
      Top = 8
      Width = 160
      Height = 21
      MaxLength = 12
      PasswordChar = '*'
      TabOrder = 0
    end
  end
  object pnlDomainAndUser: TPanel
    Left = 0
    Top = 0
    Width = 482
    Height = 82
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblSubdomain: TLabel
      Left = 16
      Top = 19
      Width = 56
      Height = 13
      Caption = 'Subdomain:'
    end
    object lblUsername: TLabel
      Left = 16
      Top = 56
      Width = 52
      Height = 13
      Caption = 'Username:'
    end
    object eUsername: TEdit
      Left = 144
      Top = 53
      Width = 320
      Height = 21
      TabOrder = 1
    end
    object eSubDomain: TEdit
      Left = 144
      Top = 16
      Width = 321
      Height = 21
      TabOrder = 0
    end
  end
  object pnlNewAndConfirm: TPanel
    Left = 0
    Top = 119
    Width = 482
    Height = 74
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object lblNew: TLabel
      Left = 16
      Top = 11
      Width = 70
      Height = 13
      Caption = '&New Password'
    end
    object lblConfirm: TLabel
      Left = 16
      Top = 48
      Width = 86
      Height = 13
      Caption = 'Con&firm Password'
    end
    object eNewConfirm: TEdit
      Left = 144
      Top = 45
      Width = 160
      Height = 21
      MaxLength = 12
      PasswordChar = '*'
      TabOrder = 1
      OnKeyDown = eNewConfirmKeyDown
    end
    object eNew: TEdit
      Left = 144
      Top = 8
      Width = 160
      Height = 21
      MaxLength = 12
      PasswordChar = '*'
      TabOrder = 0
      OnKeyDown = eNewKeyDown
    end
  end
  object pnlOkCancel: TPanel
    Left = 0
    Top = 255
    Width = 482
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    DesignSize = (
      482
      42)
    object btnOk: TButton
      Left = 310
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 399
      Top = 9
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
end
