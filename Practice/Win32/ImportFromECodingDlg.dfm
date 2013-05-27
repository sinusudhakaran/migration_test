object dlgImportBNotes: TdlgImportBNotes
  Left = 411
  Top = 361
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Import from ECoding file'
  ClientHeight = 442
  ClientWidth = 677
  Color = clBtnFace
  TransparentColorValue = clMaroon
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    677
    442)
  PixelsPerInch = 96
  TextHeight = 13
  object pnlSave: TPanel
    Left = 8
    Top = 336
    Width = 661
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentColor = True
    TabOrder = 1
    DesignSize = (
      661
      57)
    object Label6: TLabel
      Left = 16
      Top = 20
      Width = 42
      Height = 13
      Caption = 'File&name'
      FocusControl = edtFrom
    end
    object btnToFolder: TSpeedButton
      Left = 625
      Top = 17
      Width = 25
      Height = 24
      Hint = 'Click to Select a Folder'
      Anchors = [akTop]
      Glyph.Data = {
        36050000424D3605000000000000360400002800000010000000100000000100
        08000000000000010000C40E0000C40E00000001000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
        A6000020400000206000002080000020A0000020C0000020E000004000000040
        20000040400000406000004080000040A0000040C0000040E000006000000060
        20000060400000606000006080000060A0000060C0000060E000008000000080
        20000080400000806000008080000080A0000080C0000080E00000A0000000A0
        200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
        200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
        200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
        20004000400040006000400080004000A0004000C0004000E000402000004020
        20004020400040206000402080004020A0004020C0004020E000404000004040
        20004040400040406000404080004040A0004040C0004040E000406000004060
        20004060400040606000406080004060A0004060C0004060E000408000004080
        20004080400040806000408080004080A0004080C0004080E00040A0000040A0
        200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
        200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
        200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
        20008000400080006000800080008000A0008000C0008000E000802000008020
        20008020400080206000802080008020A0008020C0008020E000804000008040
        20008040400080406000804080008040A0008040C0008040E000806000008060
        20008060400080606000806080008060A0008060C0008060E000808000008080
        20008080400080806000808080008080A0008080C0008080E00080A0000080A0
        200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
        200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
        200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
        2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
        2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
        2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
        2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
        2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
        2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
        2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00060606060606
        06060606060600000606060606060606060606060604FEFC0006060000000000
        0000000004FEFCFC00062DB6B6B6B6B6B6B62D04FEFCFC2D00062DF6B7BFB7BF
        B7B704FEFCFCB7B600062DF6BFB7A40000A407FCFCB7B7B600062DF6B7A407FE
        0700A403B7BFB7B600062DF6A42DFE07FE0700B7BFB7BFB600062DF6A4FEB7FE
        07FE00B7B7BFB7B600062DF6A4BFFEB7FE0700B7BFB7BFB600062DF6B7A4BFFE
        B700A4BFBFBFB7B600062DF6F6B7A4A400A4F6F6F6F6BFB600062DB6B6B6B6B6
        B6B62D2D2D2D2D2D0606062DF6F6F6BFBF2D000606060606060606062D2D2D2D
        2D00060606060606060606060606060606060606060606060606}
      OnClick = btnToFolderClick
      ExplicitLeft = 540
    end
    object edtFrom: TEdit
      Left = 72
      Top = 17
      Width = 550
      Height = 19
      Anchors = [akLeft, akTop, akRight]
      Ctl3D = False
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnChange = edtFromChange
      ExplicitWidth = 462
    end
  end
  object btnOk: TButton
    Left = 513
    Top = 410
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
    ExplicitLeft = 427
    ExplicitTop = 400
  end
  object btnCancel: TButton
    Left = 593
    Top = 410
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    ExplicitLeft = 507
    ExplicitTop = 400
  end
  object Panel2: TPanel
    Left = 8
    Top = 16
    Width = 661
    Height = 316
    Anchors = [akLeft, akTop, akRight]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      661
      316)
    object Bevel2: TBevel
      Left = 1
      Top = 199
      Width = 662
      Height = 9
      Anchors = [akLeft, akTop, akRight]
      Shape = bsTopLine
      ExplicitWidth = 576
    end
    object chkShowExample: TCheckBox
      Left = 16
      Top = 205
      Width = 153
      Height = 18
      Caption = 'Show examples'
      TabOrder = 5
      OnClick = chkShowExampleClick
    end
    object chkFillNarration: TCheckBox
      Left = 16
      Top = 9
      Width = 521
      Height = 17
      Caption = 
        'Automatically transfer the following information into the Narrat' +
        'ion field for each entry'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = rbClick
    end
    object rbPayee: TRadioButton
      Left = 72
      Top = 57
      Width = 113
      Height = 17
      Caption = 'Payee name'
      TabOrder = 2
      OnClick = rbClick
    end
    object rbNotes: TRadioButton
      Left = 72
      Top = 33
      Width = 113
      Height = 17
      Caption = 'Notes'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = rbClick
    end
    object rbBoth: TRadioButton
      Left = 72
      Top = 81
      Width = 174
      Height = 17
      Caption = 'Payee name and Notes'
      TabOrder = 3
      OnClick = rbClick
    end
    object Panel1: TPanel
      Left = 8
      Top = 104
      Width = 472
      Height = 92
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 4
      object lblIfNarration: TLabel
        Left = 9
        Top = 0
        Width = 234
        Height = 13
        Caption = 'If the Narration field already contains some text '
      end
      object rbReplace: TRadioButton
        Left = 64
        Top = 25
        Width = 113
        Height = 18
        Caption = 'Replace it'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rbClick
      end
      object rbNothing: TRadioButton
        Left = 64
        Top = 74
        Width = 113
        Height = 18
        Caption = 'Do nothing'
        TabOrder = 1
        OnClick = rbClick
      end
      object rbAppend: TRadioButton
        Left = 64
        Top = 49
        Width = 129
        Height = 18
        Caption = 'Append it'
        TabOrder = 2
        OnClick = rbClick
      end
    end
    object pnlExample: TPanel
      Left = 8
      Top = 227
      Width = 647
      Height = 82
      Anchors = [akLeft, akTop, akRight]
      BevelInner = bvLowered
      Color = clWindow
      TabOrder = 6
      Visible = False
      DesignSize = (
        647
        82)
      object Shape2: TShape
        Left = 388
        Top = 54
        Width = 255
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Brush.Color = clBtnFace
        ExplicitWidth = 169
      end
      object Shape1: TShape
        Left = 388
        Top = 27
        Width = 255
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Brush.Color = clBtnFace
        ExplicitWidth = 169
      end
      object Label1: TLabel
        Left = 9
        Top = 8
        Width = 85
        Height = 13
        Caption = 'Existing Narration'
      end
      object Label2: TLabel
        Left = 126
        Top = 8
        Width = 72
        Height = 13
        Caption = 'ECoding Payee'
      end
      object Label5: TLabel
        Left = 265
        Top = 8
        Width = 70
        Height = 13
        Caption = 'ECoding Notes'
      end
      object Label7: TLabel
        Left = 390
        Top = 6
        Width = 69
        Height = 13
        Caption = 'New Narration'
      end
      object lblNewNarration1: TLabel
        Left = 390
        Top = 30
        Width = 82
        Height = 13
        Caption = 'lblNewNarration1'
        Transparent = True
      end
      object lblEcodingNotes2: TLabel
        Left = 265
        Top = 56
        Width = 74
        Height = 13
        Caption = 'Office contents'
      end
      object lblEcodingNotes1: TLabel
        Left = 265
        Top = 30
        Width = 60
        Height = 13
        Caption = 'Renovations'
      end
      object lblEcodingPayee2: TLabel
        Left = 126
        Top = 56
        Width = 56
        Height = 13
        Caption = 'ABC Limited'
      end
      object lblNewNarration2: TLabel
        Left = 390
        Top = 56
        Width = 82
        Height = 13
        Caption = 'lblNewNarration2'
        Transparent = True
      end
      object Bevel1: TBevel
        Left = 8
        Top = 25
        Width = 639
        Height = 7
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
        ExplicitWidth = 553
      end
      object lblExisting2: TLabel
        Left = 9
        Top = 56
        Width = 58
        Height = 13
        Caption = 'INSURANCE'
      end
      object Bevel3: TBevel
        Left = 8
        Top = 50
        Width = 631
        Height = 7
        Anchors = [akLeft, akTop, akRight]
        Shape = bsTopLine
        ExplicitWidth = 545
      end
    end
  end
  object OpenDialog: TOpenDialog
    Left = 512
    Top = 72
  end
end
