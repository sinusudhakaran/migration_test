object ResynchronizeFrm: TResynchronizeFrm
  Left = 0
  Top = 0
  ActiveControl = lClients
  Caption = 'Repatriate '
  ClientHeight = 393
  ClientWidth = 506
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 250
    Top = 41
    Height = 333
    ExplicitLeft = 184
    ExplicitTop = 144
    ExplicitHeight = 100
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 506
    Height = 41
    Align = alTop
    TabOrder = 0
    object btn: TButton
      Left = 8
      Top = 10
      Width = 113
      Height = 25
      Caption = 'Repatriate  Clients'
      Enabled = False
      TabOrder = 0
      OnClick = btnClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 374
    Width = 506
    Height = 19
    Panels = <>
  end
  object Panel2: TPanel
    Left = 253
    Top = 41
    Width = 253
    Height = 333
    Align = alClient
    TabOrder = 2
    object GroupBox1: TGroupBox
      Left = 1
      Top = 1
      Width = 251
      Height = 96
      Align = alTop
      Caption = 'For file version:'
      TabOrder = 0
      object Label1: TLabel
        Left = 16
        Top = 24
        Width = 50
        Height = 13
        Caption = 'System db'
      end
      object Label2: TLabel
        Left = 45
        Top = 48
        Width = 21
        Height = 13
        Caption = 'BK5 '
      end
      object eSysdb: TEdit
        Left = 72
        Top = 21
        Width = 121
        Height = 21
        ReadOnly = True
        TabOrder = 0
      end
      object Eexe: TEdit
        Left = 72
        Top = 48
        Width = 121
        Height = 21
        ReadOnly = True
        TabOrder = 1
      end
    end
  end
  object lClients: TListView
    Left = 0
    Top = 41
    Width = 250
    Height = 333
    Align = alLeft
    Columns = <
      item
        AutoSize = True
        Caption = 'Foreign Clients'
      end>
    MultiSelect = True
    TabOrder = 3
    ViewStyle = vsReport
    OnChange = lClientsChange
    OnDeletion = lClientsDeletion
  end
end
