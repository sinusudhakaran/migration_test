object MainForm: TMainForm
  Left = 364
  Top = 261
  BorderStyle = bsDialog
  Caption = 'BankLink Transaction Archive Log'
  ClientHeight = 448
  ClientWidth = 794
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 27
    Top = 8
    Width = 388
    Height = 13
    Caption = 
      '* WARNING: Please shut down BankLink before running this utility' +
      ' *'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Label2: TLabel
    Left = 440
    Top = 8
    Width = 48
    Height = 13
    Caption = 'Using Zip:'
  end
  object btnCheck: TButton
    Left = 27
    Top = 28
    Width = 388
    Height = 25
    Caption = 'Check Transaction Archive'
    TabOrder = 0
    OnClick = btnCheckClick
  end
  object sbStatus: TStatusBar
    Left = 0
    Top = 429
    Width = 794
    Height = 19
    Panels = <>
    SimplePanel = True
    SimpleText = 'Click the "Check Transaction Archive" button to start'
  end
  object moResults: TMemo
    Left = 27
    Top = 80
    Width = 742
    Height = 343
    Lines.Strings = (
      '')
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object Edit1: TEdit
    Left = 494
    Top = 5
    Width = 275
    Height = 21
    TabOrder = 1
    Text = 'Edit1'
  end
  object chkFix: TCheckBox
    Left = 440
    Top = 32
    Width = 137
    Height = 17
    Caption = 'Auto Fix Client Files'
    Checked = True
    State = cbChecked
    TabOrder = 5
    Visible = False
  end
  object btnPrint: TButton
    Left = 494
    Top = 28
    Width = 275
    Height = 25
    Caption = 'Print Results'
    Enabled = False
    TabOrder = 2
    OnClick = btnPrintClick
  end
  object moFixed: TMemo
    Left = 96
    Top = 334
    Width = 185
    Height = 89
    TabOrder = 6
    Visible = False
  end
  object moManual: TMemo
    Left = 303
    Top = 334
    Width = 185
    Height = 89
    TabOrder = 7
    Visible = False
  end
  object moTemp: TMemo
    Left = 512
    Top = 334
    Width = 185
    Height = 89
    TabOrder = 8
    Visible = False
  end
  object pBar: TProgressBar
    Left = 27
    Top = 57
    Width = 742
    Height = 17
    Step = 1
    TabOrder = 9
  end
end
