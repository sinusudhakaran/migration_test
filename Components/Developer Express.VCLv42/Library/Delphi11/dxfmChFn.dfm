object fmdxChangeFileName: TfmdxChangeFileName
  Left = 368
  Top = 184
  ActiveControl = edFileName
  BorderStyle = bsDialog
  Caption = 'Choose New File Name'
  ClientHeight = 104
  ClientWidth = 350
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 109
    Top = 75
    Width = 75
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 190
    Top = 75
    Width = 75
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 271
    Top = 75
    Width = 75
    Height = 23
    Caption = '&Help'
    TabOrder = 3
  end
  object GroupBox1: TGroupBox
    Left = 4
    Top = 2
    Width = 342
    Height = 65
    TabOrder = 0
    object lblEnterNewFileName: TLabel
      Left = 9
      Top = 17
      Width = 103
      Height = 13
      Caption = '&Enter New File Name:'
      FocusControl = edFileName
    end
    object edFileName: TEdit
      Left = 9
      Top = 33
      Width = 324
      Height = 21
      MaxLength = 260
      TabOrder = 0
      OnChange = edFileNameChange
    end
  end
end
