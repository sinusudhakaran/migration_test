object frmAdvanceAccountOptions: TfrmAdvanceAccountOptions
  Scaled = False
Left = 297
  Top = 252
  BorderStyle = bsDialog
  Caption = 'Advanced Bank Account Options'
  ClientHeight = 93
  ClientWidth = 328
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    328
    93)
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 170
    Top = 64
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 0
    ExplicitLeft = 236
  end
  object Button2: TButton
    Left = 251
    Top = 64
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    ExplicitLeft = 317
  end
  object chkEnhancedTempAccounts: TCheckBox
    Left = 16
    Top = 24
    Width = 302
    Height = 17
    Caption = '&Enable Enhanced Manual Accounts'
    TabOrder = 2
  end
end
