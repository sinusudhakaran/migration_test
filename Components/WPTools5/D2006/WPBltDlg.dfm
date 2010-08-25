object WPBulletDialog: TWPBulletDialog
  Left = 39
  Top = 211
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsDialog
  Caption = 'Bullets'
  ClientHeight = 322
  ClientWidth = 457
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Outline: TLabel
    Left = 119
    Top = 297
    Width = 41
    Height = 16
    Caption = 'Outline'
    Visible = False
  end
  object Numbers: TLabel
    Left = 49
    Top = 286
    Width = 55
    Height = 16
    Caption = 'Numbers'
    Visible = False
  end
  object Bullets: TLabel
    Left = 173
    Top = 297
    Width = 40
    Height = 16
    Caption = 'Bullets'
    Visible = False
  end
  object PageControl1: TPageControl
    Left = 10
    Top = 9
    Width = 434
    Height = 267
    ActivePage = TabSheet1
    TabOrder = 2
    object TabSheet1: TTabSheet
      Caption = 'Bullets'
      object ScrollBox1: TScrollBox
        Left = 0
        Top = 0
        Width = 426
        Height = 236
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Numbers'
      object ScrollBox2: TScrollBox
        Left = 0
        Top = 0
        Width = 426
        Height = 236
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Outline'
      object ScrollBox3: TScrollBox
        Left = 0
        Top = 0
        Width = 426
        Height = 236
        Align = alClient
        BorderStyle = bsNone
        TabOrder = 0
      end
    end
  end
  object btnOk: TButton
    Left = 246
    Top = 286
    Width = 92
    Height = 30
    Caption = '&Ok'
    Default = True
    TabOrder = 0
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 345
    Top = 286
    Width = 92
    Height = 30
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnAdd: TButton
    Left = 20
    Top = 286
    Width = 92
    Height = 30
    Caption = 'Add'
    TabOrder = 3
    OnClick = btnAddClick
  end
  object AddPopup: TPopupMenu
    Left = 18
    Top = 131
    object menAddBullet: TMenuItem
      Caption = 'New Bullet'
      OnClick = menAddBulletClick
    end
    object menAddNumber: TMenuItem
      Caption = 'New Number'
      OnClick = menAddNumberClick
    end
    object menAddOutline: TMenuItem
      Caption = 'New Outline'
      Visible = False
      OnClick = menAddOutlineClick
    end
  end
  object EditPopup: TPopupMenu
    Left = 54
    Top = 131
    object menEdit: TMenuItem
      Caption = 'Edit'
      OnClick = menEditClick
    end
  end
end
