object frmStatistics: TfrmStatistics
  Left = 354
  Top = 319
  Caption = 'frmStatistics'
  ClientHeight = 354
  ClientWidth = 534
  Color = clWhite
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFooter: TPanel
    Left = 0
    Top = 320
    Width = 534
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      534
      34)
    object btnClose: TButton
      Left = 448
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 534
    Height = 320
    ActivePage = tbsCalculated
    Align = alClient
    TabOrder = 1
    object tbsCalculated: TTabSheet
      Caption = 'Statistics'
      ImageIndex = 1
      object Label1: TLabel
        Left = 8
        Top = 56
        Width = 30
        Height = 13
        Caption = 'Logins'
      end
      object Label2: TLabel
        Left = 8
        Top = 96
        Width = 45
        Height = 13
        Caption = 'Reliability'
      end
      object lblLogins: TLabel
        Left = 128
        Top = 56
        Width = 6
        Height = 13
        Caption = '0'
      end
      object lblReliability: TLabel
        Left = 128
        Top = 96
        Width = 27
        Height = 13
        Caption = '0.0%'
      end
      object Label3: TLabel
        Left = 8
        Top = 16
        Width = 53
        Height = 13
        Caption = 'Start Date '
      end
      object lblStartDate: TLabel
        Left = 128
        Top = 16
        Width = 48
        Height = 13
        Caption = 'dd/mm/yy'
      end
      object Label4: TLabel
        Left = 8
        Top = 136
        Width = 53
        Height = 13
        Caption = 'Lock Errors'
      end
      object lblLockErrors: TLabel
        Left = 128
        Top = 136
        Width = 6
        Height = 13
        Caption = '0'
      end
      object Label5: TLabel
        Left = 8
        Top = 176
        Width = 83
        Height = 13
        Caption = 'Unhandled Errors'
      end
      object lblUnhandled: TLabel
        Left = 128
        Top = 176
        Width = 6
        Height = 13
        Caption = '0'
      end
    end
    object tbsRaw: TTabSheet
      Caption = 'Raw File'
      object memFile: TMemo
        Left = 0
        Top = 0
        Width = 526
        Height = 292
        Align = alClient
        Lines.Strings = (
          'memFile')
        ReadOnly = True
        TabOrder = 0
      end
    end
  end
end
