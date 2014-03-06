object frmEMailMerge: TfrmEMailMerge
  Scaled = False
Left = 403
  Top = 255
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsDialog
  Caption = 'Mail Merge and E-mail'
  ClientHeight = 446
  ClientWidth = 514
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object gbDocs: TGroupBox
    Left = 8
    Top = 8
    Width = 497
    Height = 63
    Caption = 'Document'
    TabOrder = 0
    object Label2: TLabel
      Left = 24
      Top = 29
      Width = 81
      Height = 13
      Caption = '&Merge Document'
      FocusControl = edtDocument
    end
    object btnFromFile: TSpeedButton
      Left = 448
      Top = 25
      Width = 25
      Height = 24
      Hint = 'Click to Select a File'
      ParentShowHint = False
      ShowHint = True
      OnClick = btnFromFileClick
    end
    object edtDocument: TEdit
      Left = 144
      Top = 25
      Width = 305
      Height = 21
      Hint = 'Enter the filename of the mail merge document'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 73
    Width = 497
    Height = 104
    Caption = 'Mail Options'
    TabOrder = 1
    object Label4: TLabel
      Left = 16
      Top = 25
      Width = 57
      Height = 13
      Caption = 'Mail &Subject'
      FocusControl = edtSubject
    end
    object rbAttach: TRadioButton
      Left = 176
      Top = 64
      Width = 305
      Height = 17
      Hint = 'Send the e-mail with the merged data as a Word attachment'
      Caption = 'Mail as Attachment (Word document)'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Visible = False
    end
    object rbMessageHTML: TRadioButton
      Left = 24
      Top = 55
      Width = 241
      Height = 17
      Hint = 'Send the e-mail with the merged data as an HTML message'
      Caption = 'Mail as message (&HTML format)'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      TabStop = True
    end
    object edtSubject: TEdit
      Left = 144
      Top = 25
      Width = 305
      Height = 21
      Hint = 'Enter the subject for the e-mail message'
      MaxLength = 50
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnExit = edtSubjectExit
    end
    object rbMessageText: TRadioButton
      Left = 24
      Top = 77
      Width = 233
      Height = 17
      Hint = 'Send the e-mail with the merged data as a text message'
      Caption = 'Mail as message (plain &text format)'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
  end
  object gbTask: TGroupBox
    Left = 8
    Top = 177
    Width = 497
    Height = 121
    Caption = 'Task'
    TabOrder = 2
    object Label1: TLabel
      Left = 24
      Top = 52
      Width = 53
      Height = 13
      Caption = '&Description'
      FocusControl = edtDescription
    end
    object Label3: TLabel
      Left = 24
      Top = 88
      Width = 71
      Height = 13
      Caption = '&Reminder Date'
      FocusControl = ovcFollowup
    end
    object btnQuik: TRzToolButton
      Left = 240
      Top = 84
      Width = 27
      Height = 24
      Hint = 'Choose a reminder date'
      Flat = False
      ImageIndex = 3
      Images = AppImages.Misc
      UseToolbarButtonLayout = False
      UseToolbarButtonSize = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnQuikClick
    end
    object edtDescription: TEdit
      Left = 144
      Top = 48
      Width = 217
      Height = 21
      Hint = 'Enter the task description'
      MaxLength = 50
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object ovcFollowup: TOvcPictureField
      Left = 144
      Top = 84
      Width = 89
      Height = 24
      Cursor = crIBeam
      Hint = 'Enter the follow up date'
      DataType = pftDate
      AutoSize = False
      CaretOvr.Shape = csBlock
      ControlCharColor = clRed
      DecimalPlaces = 0
      EFColors.Disabled.BackColor = clWindow
      EFColors.Disabled.TextColor = clGrayText
      EFColors.Error.BackColor = clRed
      EFColors.Error.TextColor = clBlack
      EFColors.Highlight.BackColor = clHighlight
      EFColors.Highlight.TextColor = clHighlightText
      Epoch = 1970
      InitDateTime = False
      MaxLength = 8
      Options = [efoCaretToEnd]
      ParentShowHint = False
      PictureMask = 'dd/mm/yy'
      ShowHint = True
      TabOrder = 2
      RangeHigh = {25600D00000000000000}
      RangeLow = {00000000000000000000}
    end
    object chkTask: TCheckBox
      Left = 24
      Top = 24
      Width = 337
      Height = 17
      Hint = 'Add a task to the client for follow up'
      Caption = '&Create a task'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      OnClick = chkTaskClick
    end
  end
  object gbPrint: TGroupBox
    Left = 8
    Top = 299
    Width = 241
    Height = 110
    Caption = 'Action After Merge'
    TabOrder = 3
    object Label5: TLabel
      Left = 63
      Top = 19
      Width = 161
      Height = 52
      Caption = 
        'After the Mail Merge, the merged document will be displayed in W' +
        'ord. Please click the "Merge to E-mail" button to send the email' +
        's.'
      WordWrap = True
    end
    object InfoBmp: TImage
      Left = 8
      Top = 40
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
    object rbPreview: TRadioButton
      Left = 24
      Top = 11
      Width = 193
      Height = 17
      Hint = 'Preview the merged e-mail after the merge completes'
      Caption = 'Preview'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      TabStop = True
      Visible = False
    end
    object rbSend: TRadioButton
      Left = 32
      Top = 13
      Width = 161
      Height = 17
      Hint = 'Send the merged e-mails after the merge completes'
      Caption = 'Send'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Visible = False
    end
    object rbManual: TRadioButton
      Left = 16
      Top = 15
      Width = 169
      Height = 17
      Hint = 
        'Open the merged document to manually generate the e-mails (avoid' +
        's the Outlook security question)'
      Caption = 'Manual Generate'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Visible = False
    end
  end
  object gbSummary: TGroupBox
    Left = 256
    Top = 299
    Width = 249
    Height = 110
    Caption = 'Report Summary To'
    TabOrder = 4
    object rbRepNone: TRadioButton
      Tag = 1
      Left = 16
      Top = 27
      Width = 113
      Height = 17
      Hint = 'Do not generate a summary report'
      Caption = '&None'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object rbRepScreen: TRadioButton
      Left = 16
      Top = 51
      Width = 161
      Height = 17
      Hint = 'Generate a summary report to the screen'
      Caption = 'Pre&view'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      TabStop = True
    end
    object rbRepPrint: TRadioButton
      Tag = 2
      Left = 16
      Top = 76
      Width = 129
      Height = 17
      Hint = 'Generate a summary report to the default printer'
      Caption = '&Printer'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object rbRepFile: TRadioButton
      Left = 256
      Top = 17
      Width = 161
      Height = 17
      Hint = 'Generate a summary report to a file'
      Caption = 'File'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Visible = False
    end
  end
  object btnOk: TButton
    Left = 344
    Top = 414
    Width = 75
    Height = 25
    Hint = 'Perform the mail merge'
    Caption = 'OK'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 429
    Top = 414
    Width = 75
    Height = 25
    Hint = 'Cancel the mail merge'
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'doc'
    Filter = 'Word Documents (*.doc)|*.doc|All Files (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 480
    Top = 32
  end
  object opemMerge: TOpEventModel
    Version = '1.64'
    RowCount = 0
    SupportedModes = []
    VariableLengthRows = False
    OnGetColCount = opemMergeGetColCount
    OnGetColHeaders = opemMergeGetColHeaders
    OnGetData = opemMergeGetData
    Left = 8
    Top = 408
  end
  object popFollowup: TPopupMenu
    Left = 296
    Top = 264
    object N1Week: TMenuItem
      Caption = '1 Week'
      OnClick = N1WeekClick
    end
    object N2Weeks: TMenuItem
      Caption = '2 Weeks'
      OnClick = N2WeeksClick
    end
    object N4Weeks: TMenuItem
      Caption = '1 Month'
      OnClick = N4WeeksClick
    end
    object N6Weeks: TMenuItem
      Caption = '6 Weeks'
      OnClick = N6WeeksClick
    end
    object N2Months: TMenuItem
      Caption = '2 Months'
      OnClick = N2MonthsClick
    end
    object N4Months: TMenuItem
      Caption = '4 Months'
      OnClick = N4MonthsClick
    end
  end
end
