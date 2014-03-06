object frmClientLookup: TfrmClientLookup
  Scaled = False
Left = 365
  Top = 292
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Client Lookup Frame'
  ClientHeight = 230
  ClientWidth = 541
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFrameHolder: TPanel
    Left = 0
    Top = 0
    Width = 541
    Height = 230
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object pnlButtons: TPanel
      Left = 0
      Top = 189
      Width = 541
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        541
        41)
      object btnOK: TButton
        Left = 376
        Top = 8
        Width = 75
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = '&Open'
        Default = True
        ModalResult = 1
        TabOrder = 2
      end
      object btnCancel: TButton
        Left = 456
        Top = 8
        Width = 75
        Height = 25
        Anchors = [akRight, akBottom]
        Cancel = True
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 3
      end
      object rbAllFiles: TRadioButton
        Left = 16
        Top = 16
        Width = 121
        Height = 17
        Caption = 'View &everyone'#39's files'
        TabOrder = 0
        Visible = False
        OnClick = rbAllFilesClick
      end
      object rbMyFiles: TRadioButton
        Left = 160
        Top = 16
        Width = 113
        Height = 17
        Caption = 'View &my files'
        TabOrder = 1
        Visible = False
        OnClick = rbMyFilesClick
      end
    end
    inline ClientLookupFrame: TfmeClientLookup
      Left = 0
      Top = 0
      Width = 541
      Height = 189
      Align = alClient
      TabOrder = 1
      TabStop = True
      ExplicitWidth = 541
      ExplicitHeight = 189
      inherited vtClients: TVirtualStringTree
        Width = 541
        Height = 189
        Header.Font.Height = -13
        Header.Font.Name = 'MS Sans Serif'
        ExplicitWidth = 541
        ExplicitHeight = 189
      end
    end
  end
end
