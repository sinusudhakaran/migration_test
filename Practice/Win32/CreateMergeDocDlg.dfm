object frmCreateMergeDoc: TfrmCreateMergeDoc
  Left = 364
  Top = 260
  BorderStyle = bsDialog
  Caption = 'Create a Mail Merge Document'
  ClientHeight = 327
  ClientWidth = 417
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 401
    Height = 89
    Caption = 'Document Source'
    TabOrder = 0
    object btnFromFile: TSpeedButton
      Left = 368
      Top = 61
      Width = 23
      Height = 22
      Hint = 'Click to Select a File'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnFromFileClick
    end
    object rbNew: TRadioButton
      Left = 30
      Top = 20
      Width = 106
      Height = 16
      Hint = 'Create a new blank mail merge document'
      Caption = 'New Document'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      TabStop = True
      OnClick = rbExistingClick
    end
    object rbExisting: TRadioButton
      Left = 30
      Top = 41
      Width = 151
      Height = 15
      Hint = 'Create a mail merge document from an existing document'
      Caption = 'Existing Document'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      OnClick = rbExistingClick
    end
    object edtDocument: TEdit
      Left = 80
      Top = 61
      Width = 288
      Height = 21
      Hint = 'Enter the filename of the existing document'
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 101
    Width = 401
    Height = 56
    Caption = 'Document Destination'
    TabOrder = 1
    object Label4: TLabel
      Left = 23
      Top = 24
      Width = 37
      Height = 13
      Caption = 'Save In'
    end
    object btnToFile: TSpeedButton
      Left = 368
      Top = 20
      Width = 23
      Height = 23
      Hint = 'Click to Select a File'
      ParentShowHint = False
      ShowHint = True
      OnClick = btnToFileClick
    end
    object edtSave: TEdit
      Left = 80
      Top = 20
      Width = 288
      Height = 21
      Hint = 'Enter the filename of the merged document'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  object GroupBox3: TGroupBox
    Left = 6
    Top = 161
    Width = 403
    Height = 120
    Caption = 'Options'
    TabOrder = 2
    object InfoBmp: TImage
      Left = 8
      Top = 16
      Width = 40
      Height = 40
      AutoSize = True
      Picture.Data = {
        07544269746D6170760A0000424D760A00000000000036040000280000002800
        0000280000000100080000000000400600000000000000000000000100000001
        000000000000000080000080000000808000800000008000800080800000C0C0
        C000C0DCC000F0CAA6000020400000206000002080000020A0000020C0000020
        E00000400000004020000040400000406000004080000040A0000040C0000040
        E00000600000006020000060400000606000006080000060A0000060C0000060
        E00000800000008020000080400000806000008080000080A0000080C0000080
        E00000A0000000A0200000A0400000A0600000A0800000A0A00000A0C00000A0
        E00000C0000000C0200000C0400000C0600000C0800000C0A00000C0C00000C0
        E00000E0000000E0200000E0400000E0600000E0800000E0A00000E0C00000E0
        E00040000000400020004000400040006000400080004000A0004000C0004000
        E00040200000402020004020400040206000402080004020A0004020C0004020
        E00040400000404020004040400040406000404080004040A0004040C0004040
        E00040600000406020004060400040606000406080004060A0004060C0004060
        E00040800000408020004080400040806000408080004080A0004080C0004080
        E00040A0000040A0200040A0400040A0600040A0800040A0A00040A0C00040A0
        E00040C0000040C0200040C0400040C0600040C0800040C0A00040C0C00040C0
        E00040E0000040E0200040E0400040E0600040E0800040E0A00040E0C00040E0
        E00080000000800020008000400080006000800080008000A0008000C0008000
        E00080200000802020008020400080206000802080008020A0008020C0008020
        E00080400000804020008040400080406000804080008040A0008040C0008040
        E00080600000806020008060400080606000806080008060A0008060C0008060
        E00080800000808020008080400080806000808080008080A0008080C0008080
        E00080A0000080A0200080A0400080A0600080A0800080A0A00080A0C00080A0
        E00080C0000080C0200080C0400080C0600080C0800080C0A00080C0C00080C0
        E00080E0000080E0200080E0400080E0600080E0800080E0A00080E0C00080E0
        E000C0000000C0002000C0004000C0006000C0008000C000A000C000C000C000
        E000C0200000C0202000C0204000C0206000C0208000C020A000C020C000C020
        E000C0400000C0402000C0404000C0406000C0408000C040A000C040C000C040
        E000C0600000C0602000C0604000C0606000C0608000C060A000C060C000C060
        E000C0800000C0802000C0804000C0806000C0808000C080A000C080C000C080
        E000C0A00000C0A02000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0
        E000C0C00000C0C02000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0
        A000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00080808080808080808080808080808080808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        08080808080808080808080808080808080808080808080808A4A40808080808
        0808080808080808080808080808080808080808080808080808080808080808
        A4A4A40808080808080808080808080808080808080808080808080808080808
        080808080808080000A4A4080808080808080808080808080808080808080808
        080808080808080808080808080800FF00A4A408080808080808080808080808
        08080808080808080808080808080808080808080800FFFF00A4A40808080808
        080808080808080808080808080808080808080808080808080808A400FFFFFF
        00A4A40808080808080808080808080808080808080808080808080808080808
        A4A4A4A400FFFFFF00A4A4A4A4A4080808080808080808080808080808080808
        080808080808A4A4A400000007FFFFFF00A4A4A4A4A4A4A40808080808080808
        08080808080808080808080808A400000007FFFFFFFFFFFF07000000A4A4A4A4
        A408080808080808080808080808080808080808000007FFFFFFFFFFFFFFFFFF
        FFFFFF070000A4A4A4A408080808080808080808080808080808080007FFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFF0700A4A4A4A408080808080808080808080808
        080800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00A4A4A4A408080808
        08080808080808080800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        00A4A4A4A40808080808080808080808A4FFFFFFFFFFFFFFFFFCFCFCFCFCFCFC
        FCFCFFFFFFFFFFFFFF00A4A4A408080808080808080808A407FFFFFFFFFFFFFF
        FFFFFFFCFCFCFCFCFFFFFFFFFFFFFFFFFF0700A4A4A4080808080808080808A4
        FFFFFFFFFFFFFFFFFFFFFFFCFCFCFCFCFFFFFFFFFFFFFFFFFFFF00A4A4A40808
        080808080808A407FFFFFFFFFFFFFFFFFFFFFFFCFCFCFCFCFFFFFFFFFFFFFFFF
        FFFF0700A4A40808080808080808A4FFFFFFFFFFFFFFFFFFFFFFFFFCFCFCFCFC
        FFFFFFFFFFFFFFFFFFFFFF00A4A40808080808080808A4FFFFFFFFFFFFFFFFFF
        FFFFFFFCFCFCFCFCFFFFFFFFFFFFFFFFFFFFFF00A4A40808080808080808A4FF
        FFFFFFFFFFFFFFFFFFFFFFFCFCFCFCFCFFFFFFFFFFFFFFFFFFFFFF00A4A40808
        080808080808A4FFFFFFFFFFFFFFFFFFFFFFFFFCFCFCFCFCFFFFFFFFFFFFFFFF
        FFFFFF00A4A40808080808080808A4FFFFFFFFFFFFFFFFFFFFFCFCFCFCFCFCFC
        FFFFFFFFFFFFFFFFFFFFFF00A4080808080808080808A407FFFFFFFFFFFFFFFF
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF0700A408080808080808080808A4
        FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00A408080808
        08080808080808A407FFFFFFFFFFFFFFFFFF07FCFCFCFC07FFFFFFFFFFFFFFFF
        FF070008080808080808080808080808A4FFFFFFFFFFFFFFFFFFFCFCFCFCFCFC
        FFFFFFFFFFFFFFFFFF00080808080808080808080808080808A4FFFFFFFFFFFF
        FFFFFCFCFCFCFCFCFFFFFFFFFFFFFFFF00080808080808080808080808080808
        0808A4FFFFFFFFFFFFFF07FCFCFCFC07FFFFFFFFFFFFFF000808080808080808
        0808080808080808080808A407FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF07A408
        0808080808080808080808080808080808080808A4A407FFFFFFFFFFFFFFFFFF
        FFFFFF07A4A4080808080808080808080808080808080808080808080808A4A4
        A407FFFFFFFFFFFF07A4A4A40808080808080808080808080808080808080808
        080808080808080808A4A4A4A4A4A4A4A4080808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        0808080808080808080808080808080808080808080808080808080808080808
        0808}
      Transparent = True
    end
    object Label5: TLabel
      Left = 52
      Top = 16
      Width = 348
      Height = 65
      AutoSize = False
      Caption = 
        'The document will be linked to a BankLink Data Source containing' +
        ' the supported Mail Merge fields. After creation, you can add th' +
        'e Mail Merge fields to the document using Word.'
      WordWrap = True
    end
    object chkOpen: TCheckBox
      Left = 52
      Top = 87
      Width = 278
      Height = 16
      Hint = 'Open the mail merge document for editing after creation'
      Caption = 'Open after creation'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 0
    end
  end
  object btnOk: TButton
    Left = 252
    Top = 294
    Width = 75
    Height = 25
    Hint = 'Create the mail merge document'
    Caption = 'OK'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 333
    Top = 294
    Width = 75
    Height = 25
    Hint = 'Cancel the document creation'
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'doc'
    Filter = 'Word Documents (*.doc)|*.doc|All Files (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 432
    Top = 88
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'doc'
    Filter = 'Word Documents (*.doc)|*.doc|All Files (*.*)|*.*'
    Left = 424
    Top = 168
  end
end
