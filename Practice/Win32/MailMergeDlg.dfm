object frmMailMerge: TfrmMailMerge
  Left = 432
  Top = 350
  BorderStyle = bsDialog
  Caption = 'Mail Merge and Print'
  ClientHeight = 406
  ClientWidth = 514
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object gbPrint: TGroupBox
    Left = 0
    Top = 400
    Width = 240
    Height = 121
    Caption = 'Action After Merge'
    TabOrder = 5
    Visible = False
    object rbNoPrint: TRadioButton
      Left = 24
      Top = 25
      Width = 113
      Height = 17
      Hint = 'Perform no action after the merge completes'
      Caption = 'No action'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object rbPreview: TRadioButton
      Left = 24
      Top = 67
      Width = 129
      Height = 17
      Hint = 'Preview the document after the merge completes'
      Caption = 'Print Preview'
      Checked = True
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      TabStop = True
    end
    object rbPrint: TRadioButton
      Left = 24
      Top = 89
      Width = 161
      Height = 17
      Hint = 
        'Print the document to the default printer after the merge comple' +
        'tes'
      Caption = 'Print'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
    end
    object rbView: TRadioButton
      Left = 24
      Top = 46
      Width = 161
      Height = 17
      Hint = 'View the merged document after the merge completes'
      Caption = 'View Document'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
  end
  object btnOk: TButton
    Left = 349
    Top = 371
    Width = 75
    Height = 25
    Hint = 'Perform the mail merge'
    Caption = 'OK'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 430
    Top = 371
    Width = 75
    Height = 25
    Hint = 'Cancel the mail merge'
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    ParentShowHint = False
    ShowHint = True
    TabOrder = 4
  end
  object gbSummary: TGroupBox
    Left = 8
    Top = 264
    Width = 497
    Height = 97
    Caption = 'Report Summary To'
    TabOrder = 2
    object rbRepNone: TRadioButton
      Tag = 1
      Left = 24
      Top = 25
      Width = 113
      Height = 17
      Hint = 'Do not generate a summary report'
      Caption = '&None'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
    object rbRepScreen: TRadioButton
      Left = 24
      Top = 46
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
      Left = 24
      Top = 67
      Width = 129
      Height = 17
      Hint = 'Generate a summary report to the default printer'
      Caption = '&Printer'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
    end
    object rbRepFile: TRadioButton
      Left = 224
      Top = 41
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
  object gbTask: TGroupBox
    Left = 8
    Top = 136
    Width = 497
    Height = 121
    Caption = 'Task'
    TabOrder = 1
    object Label1: TLabel
      Left = 24
      Top = 52
      Width = 68
      Height = 16
      Caption = '&Description'
      FocusControl = edtDescription
    end
    object Label3: TLabel
      Left = 24
      Top = 88
      Width = 91
      Height = 16
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
      UseToolbarButtonSize = False
      ParentShowHint = False
      ShowHint = True
      OnClick = btnQuikClick
    end
    object edtDescription: TEdit
      Left = 144
      Top = 48
      Width = 217
      Height = 24
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
      Epoch = 2000
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
  object gbDocs: TGroupBox
    Left = 8
    Top = 8
    Width = 497
    Height = 121
    Caption = 'Documents'
    TabOrder = 0
    object Label2: TLabel
      Left = 24
      Top = 38
      Width = 103
      Height = 16
      Caption = '&Merge Document'
      FocusControl = edtDocument
    end
    object Label4: TLabel
      Left = 24
      Top = 78
      Width = 45
      Height = 16
      Caption = '&Save In'
      FocusControl = edtSave
    end
    object btnFromFile: TSpeedButton
      Left = 448
      Top = 34
      Width = 25
      Height = 24
      Hint = 'Click to Select a File'
      ParentShowHint = False
      ShowHint = True
      OnClick = btnFromFileClick
    end
    object btnToFile: TSpeedButton
      Left = 448
      Top = 74
      Width = 25
      Height = 24
      Hint = 'Click to Select a File'
      ParentShowHint = False
      ShowHint = True
      OnClick = btnToFileClick
    end
    object edtSave: TEdit
      Left = 144
      Top = 74
      Width = 305
      Height = 24
      Hint = 'Enter the filename of the merged document'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
    end
    object edtDocument: TEdit
      Left = 144
      Top = 34
      Width = 305
      Height = 24
      Hint = 'Enter the filename of the mail merge document'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
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
    Top = 384
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'doc'
    Filter = 'Word Documents (*.doc)|*.doc|All Files (*.*)|*.*'
    Left = 480
    Top = 80
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'doc'
    Filter = 'Word Documents (*.doc)|*.doc|All Files (*.*)|*.*'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 480
    Top = 40
  end
  object popFollowup: TPopupMenu
    Left = 304
    Top = 216
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
