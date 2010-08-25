object Form1: TForm1
  Left = 333
  Top = 322
  BorderStyle = bsToolWindow
  Caption = 'BankLink Network Help fix (for MSKB 896054)'
  ClientHeight = 256
  ClientWidth = 618
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Verdana'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 593
    Height = 65
    AutoSize = False
    Caption = 
      'This utility will update settings in your Windows Registry File.' +
      '   Please ensure that you have administrator access on your PC a' +
      'nd that you have consulted with your Network Manager before proc' +
      'eeding.'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 8
    Top = 136
    Width = 290
    Height = 14
    Caption = 'Please select the location of your BK5 help file'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Verdana'
    Font.Style = []
    ParentFont = False
  end
  object Label3: TLabel
    Left = 10
    Top = 88
    Width = 204
    Height = 14
    Caption = 'For more information please see'
  end
  object urlMicrosoftKB: TRzURLLabel
    Left = 232
    Top = 88
    Width = 228
    Height = 16
    Caption = 'http://support.microsoft.com/kb/896054'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clHighlight
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsUnderline]
    ParentFont = False
  end
  object edtFilename: TEdit
    Left = 8
    Top = 160
    Width = 513
    Height = 24
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object btnBrowse: TButton
    Left = 528
    Top = 159
    Width = 75
    Height = 25
    Caption = 'Browse'
    TabOrder = 1
    OnClick = btnBrowseClick
  end
  object btnModify: TButton
    Left = 184
    Top = 224
    Width = 115
    Height = 25
    Caption = 'Update Registry'
    TabOrder = 2
    OnClick = btnModifyClick
  end
  object btnClose: TButton
    Left = 312
    Top = 224
    Width = 115
    Height = 25
    Cancel = True
    Caption = 'Close'
    TabOrder = 3
    OnClick = btnCloseClick
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '.chm'
    Filter = 'Help files (*.chm)|*.chm'
    Options = [ofHideReadOnly, ofExtensionDifferent, ofEnableSizing]
    Left = 536
    Top = 120
  end
end
