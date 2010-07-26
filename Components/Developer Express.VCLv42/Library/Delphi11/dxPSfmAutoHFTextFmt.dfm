object dxfmAutoText: TdxfmAutoText
  Left = 467
  Top = 306
  BorderStyle = bsDialog
  Caption = 'AutoText'
  ClientHeight = 358
  ClientWidth = 394
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object gbxEnterAutoTextEntriesHere: TGroupBox
    Left = 4
    Top = 4
    Width = 387
    Height = 317
    Caption = ' Enter A&utoText Entries Here: '
    TabOrder = 0
    object lblPreview: TLabel
      Left = 9
      Top = 215
      Width = 38
      Height = 13
      Caption = 'Preview'
    end
    object ToolBar: TToolBar
      Left = 9
      Top = 176
      Width = 275
      Height = 30
      Align = alNone
      ButtonHeight = 24
      ButtonWidth = 25
      EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
      EdgeInner = esLowered
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
    object btnAdd: TButton
      Left = 289
      Top = 20
      Width = 90
      Height = 23
      Caption = '&Add'
      Default = True
      TabOrder = 1
      OnClick = btnAddClick
    end
    object btnDelete: TButton
      Left = 289
      Top = 47
      Width = 90
      Height = 23
      Caption = '&Delete'
      TabOrder = 2
      OnClick = btnDeleteClick
    end
    object cbxAutoEntries: TComboBox
      Left = 9
      Top = 20
      Width = 274
      Height = 154
      Style = csSimple
      ItemHeight = 13
      Sorted = True
      TabOrder = 0
      OnChange = NewAutoTextChange
      OnClick = AutoEntriesClick
      OnEnter = cbxAutoEntriesEnter
      OnExit = cbxAutoEntriesExit
      OnKeyDown = NewAutoTextKeyDown
    end
    object Panel1: TPanel
      Left = 9
      Top = 231
      Width = 370
      Height = 76
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 4
      object pbxPreview: TPaintBox
        Left = 0
        Top = 0
        Width = 370
        Height = 76
        Align = alClient
        Color = clBtnFace
        ParentColor = False
        OnPaint = pbxPreviewPaint
      end
    end
  end
  object btnOK: TButton
    Left = 146
    Top = 329
    Width = 79
    Height = 23
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 229
    Top = 329
    Width = 79
    Height = 23
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 312
    Top = 329
    Width = 79
    Height = 23
    Caption = '&Help'
    TabOrder = 3
  end
end
