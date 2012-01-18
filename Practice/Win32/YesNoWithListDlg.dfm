object dlgYesNoWithList: TdlgYesNoWithList
  Left = 351
  Top = 191
  BorderStyle = bsDialog
  Caption = 'Clear GST Class?'
  ClientHeight = 316
  ClientWidth = 497
  Color = clWindow
  DefaultMonitor = dmMainForm
  ParentFont = True
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    497
    316)
  PixelsPerInch = 96
  TextHeight = 13
  object lblHeaderMsg: TLabel
    Left = 16
    Top = 16
    Width = 432
    Height = 26
    Caption = 
      #39'The following chart codes no longer have a GST rate associated ' +
      'with them in Professional Accounting, however the still have a G' +
      'ST class in BankLink:'
    WordWrap = True
  end
  object lblFooterMsg: TLabel
    Left = 16
    Top = 257
    Width = 333
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 
      'Do you want to clear the GST class in BankLink for these chart c' +
      'odes?'
  end
  object btnYes: TButton
    Left = 252
    Top = 283
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Yes'
    Default = True
    ModalResult = 6
    TabOrder = 0
  end
  object btnNo: TButton
    Left = 333
    Top = 283
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&No'
    ModalResult = 7
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 414
    Top = 283
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object memItems: TMemo
    Left = 16
    Top = 72
    Width = 465
    Height = 170
    TabStop = False
    Anchors = [akLeft, akTop, akBottom]
    Ctl3D = False
    Lines.Strings = (
      '230 Sales'#9#9'(GST I)'
      '400 Expenses'#9'(GST X)')
    ParentCtl3D = False
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
end
