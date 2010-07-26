object frmClientManagerOptions: TfrmClientManagerOptions
  Left = 353
  Top = 193
  BorderStyle = bsDialog
  Caption = 'Task Settings'
  ClientHeight = 499
  ClientWidth = 495
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  DesignSize = (
    495
    499)
  PixelsPerInch = 96
  TextHeight = 13
  object lblWillAdd: TLabel
    Left = 8
    Top = 8
    Width = 228
    Height = 13
    Caption = 'BankLink will add a task to the client when you: '
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 458
    Width = 495
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      495
      41)
    object btnOK: TButton
      Left = 334
      Top = 10
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 414
      Top = 10
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnlAutoTasks: TPanel
    Left = 24
    Top = 27
    Width = 463
    Height = 410
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelInner = bvRaised
    BevelOuter = bvLowered
    Color = clInfoBk
    TabOrder = 0
    object lblCoding1: TLabel
      Left = 31
      Top = 34
      Width = 106
      Height = 13
      Caption = 'Set Reminder Date to '
    end
    object lblCoding2: TLabel
      Left = 226
      Top = 34
      Width = 158
      Height = 13
      Caption = 'day(s) after task is added  (OFF)'
    end
    object lblBNotes1: TLabel
      Left = 31
      Top = 88
      Width = 106
      Height = 13
      Caption = 'Set Reminder Date to '
    end
    object lblBNotes2: TLabel
      Left = 226
      Top = 88
      Width = 158
      Height = 13
      Caption = 'day(s) after task is added  (OFF)'
    end
    object lblWeb1: TLabel
      Left = 31
      Top = 166
      Width = 106
      Height = 13
      Caption = 'Set Reminder Date to '
    end
    object lblWeb2: TLabel
      Left = 226
      Top = 166
      Width = 158
      Height = 13
      Caption = 'day(s) after task is added  (OFF)'
    end
    object lblCheckOut1: TLabel
      Left = 31
      Top = 244
      Width = 106
      Height = 13
      Caption = 'Set Reminder Date to '
    end
    object lblCheckOut2: TLabel
      Left = 226
      Top = 244
      Width = 158
      Height = 13
      Caption = 'day(s) after task is added  (OFF)'
    end
    object lblCheckIn1: TLabel
      Left = 31
      Top = 322
      Width = 106
      Height = 13
      Caption = 'Set Reminder Date to '
    end
    object lblCheckIn2: TLabel
      Left = 226
      Top = 322
      Width = 158
      Height = 13
      Caption = 'day(s) after task is added  (OFF)'
    end
    object lblQueryEmail1: TLabel
      Left = 31
      Top = 376
      Width = 106
      Height = 13
      Caption = 'Set Reminder Date to '
    end
    object lblQueryEmail2: TLabel
      Left = 226
      Top = 376
      Width = 158
      Height = 13
      Caption = 'day(s) after task is added  (OFF)'
    end
    object chkCoding: TCheckBox
      Left = 8
      Top = 11
      Width = 233
      Height = 17
      Caption = 'Generate a Coding Report'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 0
      OnClick = chkTaskClick
    end
    object rzsCoding: TRzSpinEdit
      Left = 162
      Top = 31
      Width = 60
      Height = 21
      AllowBlank = True
      AllowKeyEdit = True
      CheckRange = True
      Max = 366.000000000000000000
      TabOrder = 1
      OnChange = spinEditChange
    end
    object chkBNotes: TCheckBox
      Left = 8
      Top = 65
      Width = 233
      Height = 17
      Caption = 'Export a BankLink Notes File'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 2
      OnClick = chkTaskClick
    end
    object rzsBNotes: TRzSpinEdit
      Left = 162
      Top = 85
      Width = 60
      Height = 21
      AllowBlank = True
      AllowKeyEdit = True
      CheckRange = True
      Max = 366.000000000000000000
      TabOrder = 3
      OnChange = spinEditChange
    end
    object chkBNotesClose: TCheckBox
      Left = 31
      Top = 112
      Width = 181
      Height = 17
      Caption = 'Close Task on Import'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 4
      OnClick = chkTaskClick
    end
    object chkWeb: TCheckBox
      Left = 8
      Top = 143
      Width = 233
      Height = 17
      Caption = 'Export a Web File'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 5
      OnClick = chkTaskClick
    end
    object rzsWeb: TRzSpinEdit
      Left = 162
      Top = 163
      Width = 60
      Height = 21
      AllowBlank = True
      AllowKeyEdit = True
      CheckRange = True
      Max = 366.000000000000000000
      TabOrder = 6
      OnChange = spinEditChange
    end
    object chkWebClose: TCheckBox
      Left = 31
      Top = 190
      Width = 181
      Height = 17
      Caption = 'Close Task on Import'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 7
      OnClick = chkTaskClick
    end
    object chkCheckOut: TCheckBox
      Left = 8
      Top = 221
      Width = 233
      Height = 17
      Caption = 'Check Out a Client File'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 8
      OnClick = chkTaskClick
    end
    object rzsCheckOut: TRzSpinEdit
      Left = 162
      Top = 241
      Width = 60
      Height = 21
      AllowBlank = True
      AllowKeyEdit = True
      CheckRange = True
      Max = 366.000000000000000000
      TabOrder = 9
      OnChange = spinEditChange
    end
    object chkCheckOutClose: TCheckBox
      Left = 31
      Top = 268
      Width = 181
      Height = 17
      Caption = 'Close Task on Check In'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 10
      OnClick = chkTaskClick
    end
    object chkCheckIn: TCheckBox
      Left = 8
      Top = 299
      Width = 233
      Height = 17
      Caption = 'Check In a Client File'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 11
      OnClick = chkTaskClick
    end
    object rzsCheckIn: TRzSpinEdit
      Left = 160
      Top = 319
      Width = 60
      Height = 21
      AllowBlank = True
      AllowKeyEdit = True
      CheckRange = True
      Max = 366.000000000000000000
      TabOrder = 12
      OnChange = spinEditChange
    end
    object chkQueryEmail: TCheckBox
      Left = 8
      Top = 353
      Width = 233
      Height = 17
      Caption = 'Send a Query Email'
      Color = clBtnFace
      ParentColor = False
      TabOrder = 13
      OnClick = chkTaskClick
    end
    object rzsQueryEmail: TRzSpinEdit
      Left = 160
      Top = 373
      Width = 60
      Height = 21
      AllowBlank = True
      AllowKeyEdit = True
      CheckRange = True
      Max = 366.000000000000000000
      TabOrder = 14
      OnChange = spinEditChange
    end
  end
  object chkShowOverdue: TCheckBox
    Left = 32
    Top = 443
    Width = 449
    Height = 19
    Anchors = [akLeft, akBottom]
    Caption = 'Show overdue tasks when closing a client file'
    TabOrder = 1
  end
end
