object frmCheckInOut: TfrmCheckInOut
  Left = 297
  Top = 164
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Caption'
  ClientHeight = 486
  ClientWidth = 884
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyUp = FormKeyUp
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFooter: TPanel
    Left = 0
    Top = 382
    Width = 884
    Height = 104
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      884
      104)
    object btnOK: TButton
      Left = 719
      Top = 72
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 1
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 800
      Top = 72
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
    object chkAvailOnly: TCheckBox
      Left = 7
      Top = 7
      Width = 377
      Height = 17
      Caption = 'Only &show client files that can be sent'
      Checked = True
      State = cbChecked
      TabOrder = 0
      OnClick = chkAvailOnlyClick
    end
    object cbFlagReadOnly: TCheckBox
      Left = 7
      Top = 30
      Width = 338
      Height = 17
      Caption = 'Flag selected client files as read-only after sending'
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
    object cbEditEmail: TCheckBox
      Left = 7
      Top = 53
      Width = 306
      Height = 17
      Caption = 'Edit message before sending'
      Checked = True
      State = cbChecked
      TabOrder = 4
    end
    object cbSendEmail: TCheckBox
      Left = 7
      Top = 76
      Width = 426
      Height = 17
      Caption = 
        'Send an email message after sending client files to BankLink Onl' +
        'ine'
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
  end
  object pnlFrameHolder: TPanel
    Left = 0
    Top = 0
    Width = 884
    Height = 347
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    inline ClientLookupFrame: TfmeClientLookup
      Left = 0
      Top = 86
      Width = 884
      Height = 261
      Align = alClient
      TabOrder = 0
      TabStop = True
      ExplicitTop = 86
      ExplicitWidth = 884
      ExplicitHeight = 261
      inherited vtClients: TVirtualStringTree
        Width = 884
        Height = 261
        Header.Font.Height = -13
        ExplicitWidth = 884
        ExplicitHeight = 261
      end
    end
    object pnlPassword: TPanel
      Left = 0
      Top = 0
      Width = 884
      Height = 86
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object Label2: TLabel
        Left = 22
        Top = 17
        Width = 52
        Height = 13
        Alignment = taRightJustify
        Caption = 'Username:'
      end
      object Label3: TLabel
        Left = 24
        Top = 54
        Width = 50
        Height = 13
        Alignment = taRightJustify
        Caption = 'Password:'
      end
      object eUsername: TEdit
        Left = 88
        Top = 14
        Width = 321
        Height = 21
        TabOrder = 0
      end
      object ePassword: TEdit
        Left = 88
        Top = 51
        Width = 321
        Height = 21
        PasswordChar = '*'
        TabOrder = 1
      end
      object btnRefresh: TBitBtn
        Left = 424
        Top = 12
        Width = 121
        Height = 25
        Caption = 'Refresh'
        TabOrder = 2
        OnClick = btnRefreshClick
        Glyph.Data = {
          36030000424D3603000000000000360000002800000010000000100000000100
          18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
          B78183B78183B78183B78183B78183B78183B78183B78183B78183B78183B781
          83B78183B78183FF00FFFF00FFFF00FFB78183FEEED4D3D8A9DFD9ABF5DBB4ED
          D6A7EED29FF1CF9AF0CF97F0CF98F0CF98F5D49AB78183FF00FFFF00FFFF00FF
          B78183FDEFD9AECE9046AD3889BE6936A72937A7287AB553D6C78AEECC97EECC
          97F3D199B78183FF00FFFF00FFFF00FFB48176FEF3E3CDD9AE20A31C029A0302
          9A03029A03029A0341A82EE6CA95EECC97F3D199B78183FF00FFFF00FFFF00FF
          B48176FFF7EBCCDCB324A51F029A032FA726BBCC8E8CBD680C9C0A90BB63EFCD
          99F3D198B78183FF00FFFF00FFFF00FFBA8E85FFFCF4CBDFBA17A116029A030C
          9D0C9AC57AF4DBBBB8C78887BF69F0D0A1F3D29BB78183FF00FFFF00FFFF00FF
          BA8E85FFFFFDE8EDDBB7D8A6AED399A9CF90AECE90F2DEC0F4DBBAB3D092F0D4
          A9F5D5A3B78183FF00FFFF00FFFF00FFCB9A82FFFFFFBAE2B7FBF3ECF7EEDFB1
          D39CAACF90ACCD8EB3CC8EEFDAB6F2D8B2F6D9ACB78183FF00FFFF00FFFF00FF
          CB9A82FFFFFF8DD28EC1E1BBFBF3EC9CCF8F0D9D0C029A0317A014F6DEC1F4DB
          B9F8DDB4B78183FF00FFFF00FFFF00FFDCA887FFFFFF99D69A0D9D0E93D18EC0
          DEB430AA2C029A0324A41FF6E2C8F7E1C2F0DAB7B78183FF00FFFF00FFFF00FF
          DCA887FFFFFFF6FBF645B546029A03029A03029A03029A0321A41EFCEFD9E6D9
          C4C6BCA9B78183FF00FFFF00FFFF00FFE3B18EFFFFFFFFFFFFE5F5E581CD813B
          B03B38AE378ECD8545AE3DAA8771B8857AB8857AB78183FF00FFFF00FFFF00FF
          E3B18EFFFFFFFFFFFFFFFFFFFFFFFFE8F6E8E7F5E5FFFEF9BEC6A8A2886CE8B2
          70ECA54AC58768FF00FFFF00FFFF00FFEDBD92FFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFE4D4D2B8857AFAC577CD9377FF00FFFF00FFFF00FFFF00FF
          EDBD92FCF7F4FCF7F3FBF6F3FBF6F3FAF5F3F9F5F3F9F5F3E1D0CEB8857ACF9B
          86FF00FFFF00FFFF00FFFF00FFFF00FFEDBD92DCA887DCA887DCA887DCA887DC
          A887DCA887DCA887DCA887B8857AFF00FFFF00FFFF00FFFF00FF}
      end
      object btnChangePassword: TButton
        Left = 424
        Top = 49
        Width = 121
        Height = 25
        Caption = 'Change Password'
        TabOrder = 3
        OnClick = btnChangePasswordClick
      end
    end
  end
  object pnlBrowseDir: TPanel
    Left = 0
    Top = 347
    Width = 884
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      884
      35)
    object lblDirLabel: TLabel
      Left = 7
      Top = 8
      Width = 54
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Files Folder'
      FocusControl = ePath
    end
    object btnFolder: TSpeedButton
      Left = 840
      Top = 6
      Width = 25
      Height = 22
      Hint = 'Click to Select a Folder'
      Anchors = [akRight, akBottom]
      ParentShowHint = False
      ShowHint = True
      OnClick = btnFolderClick
      ExplicitLeft = 940
    end
    object ePath: TEdit
      Left = 128
      Top = 6
      Width = 709
      Height = 21
      Anchors = [akLeft, akRight, akBottom]
      TabOrder = 0
      OnEnter = ePathEnter
      OnExit = ePathExit
    end
  end
end
