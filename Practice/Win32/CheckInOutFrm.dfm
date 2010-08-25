object frmCheckInOut: TfrmCheckInOut
  Left = 297
  Top = 164
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Caption'
  ClientHeight = 416
  ClientWidth = 600
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
  object pnlFooter: TPanel
    Left = 0
    Top = 343
    Width = 600
    Height = 73
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      600
      73)
    object lblDirLabel: TLabel
      Left = 7
      Top = 10
      Width = 86
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = '&Check out files to '
      FocusControl = ePath
    end
    object btnFolder: TSpeedButton
      Left = 556
      Top = 8
      Width = 25
      Height = 22
      Hint = 'Click to Select a Folder'
      Anchors = [akRight, akBottom]
      ParentShowHint = False
      ShowHint = True
      OnClick = btnFolderClick
    end
    object btnOK: TButton
      Left = 436
      Top = 40
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 2
    end
    object btnCancel: TButton
      Left = 516
      Top = 40
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object chkAvailOnly: TCheckBox
      Left = 16
      Top = 48
      Width = 377
      Height = 17
      Caption = 'Only &show files that can be checked out'
      Checked = True
      State = cbChecked
      TabOrder = 1
      OnClick = chkAvailOnlyClick
    end
    object ePath: TEdit
      Left = 128
      Top = 8
      Width = 425
      Height = 21
      Anchors = [akLeft, akRight, akBottom]
      TabOrder = 0
      OnEnter = ePathEnter
      OnExit = ePathExit
    end
  end
  object pnlFrameHolder: TPanel
    Left = 0
    Top = 0
    Width = 600
    Height = 343
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    inline ClientLookupFrame: TfmeClientLookup
      Left = 0
      Top = 0
      Width = 600
      Height = 343
      Align = alClient
      TabOrder = 0
      TabStop = True
      ExplicitWidth = 600
      ExplicitHeight = 343
      inherited vtClients: TVirtualStringTree
        Width = 600
        Height = 343
        Header.Font.Height = -13
        ExplicitWidth = 600
        ExplicitHeight = 343
      end
    end
  end
end
