object AddFavouriteDlg: TAddFavouriteDlg
  Left = 0
  Top = 0
  ActiveControl = EName
  BorderStyle = bsDialog
  Caption = 'Add To Favourite Reports'
  ClientHeight = 180
  ClientWidth = 388
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    388
    180)
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 305
    Top = 147
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    TabOrder = 2
    OnClick = btnCancelClick
  end
  object btnSave: TButton
    Left = 213
    Top = 147
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnSaveClick
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 388
    Height = 137
    Align = alTop
    TabOrder = 0
    object lblTitle: TLabel
      Left = 16
      Top = 9
      Width = 363
      Height = 48
      AutoSize = False
      Caption = 
        #39'A Coding report will be added to this client'#39's Favourite Report' +
        's list with the selected settings.'
      WordWrap = True
    end
    object Label2: TLabel
      Left = 16
      Top = 89
      Width = 27
      Height = 13
      Caption = 'Name'
    end
    object Label1: TLabel
      Left = 16
      Top = 63
      Width = 241
      Height = 13
      Caption = 'Please enter a unique name for the new Favourite'
    end
    object EName: TEdit
      Left = 59
      Top = 89
      Width = 320
      Height = 21
      TabOrder = 0
      Text = 'EName'
    end
  end
end
