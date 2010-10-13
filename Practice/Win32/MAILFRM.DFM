object frmMail: TfrmMail
  Left = 294
  Top = 189
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Send a Client File'
  ClientHeight = 539
  ClientWidth = 750
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 350
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
  object sbMail: TStatusBar
    Left = 0
    Top = 518
    Width = 750
    Height = 21
    Panels = <>
    SimplePanel = True
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 484
    Width = 750
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      750
      34)
    object chkCheckout: TCheckBox
      Left = 7
      Top = 10
      Width = 314
      Height = 17
      Caption = 'Check &Out attached client files after sending'
      TabOrder = 0
    end
    object btnSend: TButton
      Left = 585
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Send'
      TabOrder = 1
      OnClick = btnSendClick
    end
    object btnCancel: TButton
      Left = 666
      Top = 5
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      TabOrder = 2
      OnClick = btnCancelClick
    end
  end
  object pnlMessage: TPanel
    Left = 0
    Top = 193
    Width = 750
    Height = 291
    Align = alClient
    Caption = 'pnlmessage'
    TabOrder = 2
    inline Editor: TfmeEditRTF
      Left = 1
      Top = 1
      Width = 748
      Height = 289
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitWidth = 748
      ExplicitHeight = 289
      inherited Panel1: TPanel
        Width = 748
        Height = 289
        ExplicitWidth = 748
        ExplicitHeight = 289
        inherited WPToolPanel1: TWPToolPanel
          Width = 746
          ExplicitWidth = 746
          inherited TopToolbar: TRzToolbar
            Width = 744
            ExplicitWidth = 744
            ToolbarControls = (
              cbFont
              cbSize
              cbColor
              cbBackGround
              btnBold
              btnItalic
              btnUnderline
              RzSpacer1
              BtnLeftJustify
              BtnCenterJustify
              btnJustified
              BtnRightJustify
              RzSpacer2
              BtnUndo
              RzSpacer4
              BtnCut
              BtnCopy
              Btnpaste
              btnDelete
              RzSpacer3
              BtnFind
              BtnReplace)
          end
        end
        inherited ERTF: TWPRichText
          Width = 720
          Height = 227
          RTFText.Data = {
            3C215750546F6F6C735F466F726D617420563D3531382F3E0D0A3C5374616E64
            617264466F6E742077706373733D2243686172466F6E743A27417269616C273B
            43686172466F6E7453697A653A313130303B222F3E0D0A3C7661726961626C65
            733E0D0A3C7661726961626C65206E616D653D22446174616261736573222064
            6174613D22616E73692220746578743D22444154412C4C4F4F5031302C4C4F4F
            50313030222F3E3C2F7661726961626C65733E0D0A3C6E756D6265727374796C
            65733E3C6E7374796C652069643D312077707374793D5B5B4E756D6265724D6F
            64653A32343B4E756D626572494E44454E543A3336303B4E756D626572544558
            54423A262333393B6C262333393B3B43686172466F6E743A262333393B57696E
            6764696E6773262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D322077
            707374793D5B5B4E756D6265724D6F64653A31393B4E756D626572494E44454E
            543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D332077707374793D5B
            5B4E756D6265724D6F64653A313B4E756D626572494E44454E543A3336303B4E
            756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C6E73
            74796C652069643D342077707374793D5B5B4E756D6265724D6F64653A323B4E
            756D626572494E44454E543A3336303B4E756D62657254455854413A26233339
            3B2E262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D35207770737479
            3D5B5B4E756D6265724D6F64653A333B4E756D626572494E44454E543A333630
            3B4E756D62657254455854413A262333393B2E262333393B3B5D5D2F3E0D0A3C
            6E7374796C652069643D362077707374793D5B5B4E756D6265724D6F64653A34
            3B4E756D626572494E44454E543A3336303B4E756D62657254455854413A2623
            33393B29262333393B3B5D5D2F3E0D0A3C6E7374796C652069643D3720777073
            74793D5B5B4E756D6265724D6F64653A353B4E756D626572494E44454E543A33
            36303B4E756D62657254455854413A262333393B29262333393B3B5D5D2F3E0D
            0A3C6E7374796C652069643D382077707374793D5B5B4E756D6265724D6F6465
            3A363B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
            652069643D392077707374793D5B5B4E756D6265724D6F64653A373B4E756D62
            6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3130
            2077707374793D5B5B4E756D6265724D6F64653A383B4E756D626572494E4445
            4E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3131207770737479
            3D5B5B4E756D6265724D6F64653A31353B4E756D626572494E44454E543A3336
            303B5D5D2F3E0D0A3C6E7374796C652069643D31322077707374793D5B5B4E75
            6D6265724D6F64653A31363B4E756D626572494E44454E543A3336303B5D5D2F
            3E0D0A3C6E7374796C652069643D31332077707374793D5B5B4E756D6265724D
            6F64653A32333B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E
            7374796C652069643D3131342077707374793D5B5B4E756D6265725445585442
            3A262333393B70262333393B3B43686172466F6E743A262333393B57696E6764
            696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572494E
            44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D313135207770
            7374793D5B5B4E756D62657254455854423A262333393B6E262333393B3B4368
            6172466F6E743A262333393B57696E6764696E6773262333393B3B4E756D6265
            724D6F64653A32343B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A
            3C6E7374796C652069643D3131362077707374793D5B5B4E756D626572544558
            54423A262333393B76262333393B3B43686172466F6E743A262333393B57696E
            6764696E6773262333393B3B4E756D6265724D6F64653A32343B4E756D626572
            494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31313720
            67726F75703D31206C6576656C3D312077707374793D5B5B4E756D6265724D6F
            64653A323B4E756D62657254455854413A262333393B2E262333393B3B4E756D
            626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D31
            31382067726F75703D31206C6576656C3D322077707374793D5B5B4E756D6265
            724D6F64653A343B4E756D62657254455854413A262333393B2E262333393B3B
            4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069
            643D3131392067726F75703D31206C6576656C3D332077707374793D5B5B4E75
            6D6265724D6F64653A313B4E756D62657254455854413A262333393B2E262333
            393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C
            652069643D3132302067726F75703D31206C6576656C3D342077707374793D5B
            5B4E756D6265724D6F64653A353B4E756D62657254455854413A262333393B29
            262333393B3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E73
            74796C652069643D3132312067726F75703D31206C6576656C3D352077707374
            793D5B5B4E756D6265724D6F64653A333B4E756D62657254455854413A262333
            393B29262333393B3B4E756D62657254455854423A262333393B28262333393B
            3B4E756D626572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C6520
            69643D3132322067726F75703D31206C6576656C3D362077707374793D5B5B4E
            756D6265724D6F64653A353B4E756D62657254455854413A262333393B292623
            33393B3B4E756D62657254455854423A262333393B28262333393B3B4E756D62
            6572494E44454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132
            332067726F75703D31206C6576656C3D372077707374793D5B5B4E756D626572
            4D6F64653A313B4E756D62657254455854413A262333393B29262333393B3B4E
            756D62657254455854423A262333393B28262333393B3B4E756D626572494E44
            454E543A3336303B5D5D2F3E0D0A3C6E7374796C652069643D3132342067726F
            75703D31206C6576656C3D382077707374793D5B5B4E756D6265724D6F64653A
            313B4E756D62657254455854413A262333393B29262333393B3B4E756D626572
            54455854423A262333393B28262333393B3B4E756D626572494E44454E543A33
            36303B5D5D2F3E0D0A3C6E7374796C652069643D3132352067726F75703D3120
            6C6576656C3D392077707374793D5B5B4E756D6265724D6F64653A313B4E756D
            62657254455854413A262333393B29262333393B3B4E756D6265725445585442
            3A262333393B28262333393B3B4E756D626572494E44454E543A3336303B5D5D
            2F3E0D0A3C2F6E756D6265727374796C65733E0D0A3C7374796C657368656574
            3E3C2F7374796C6573686565743E3C6373206E723D312077707374793D5B5B43
            686172466F6E743A262333393B417269616C262333393B3B43686172466F6E74
            53697A653A313130303B5D5D2F3E3C6469762063733D313E3C63206E723D312F
            3E3435363334353C2F6469763E0D0A}
          OnMailMergeGetText = ERichTextMailMergeGetText
          ExplicitWidth = 720
          ExplicitHeight = 227
        end
        inherited LeftRuler: TWPVertRuler
          Height = 227
          ExplicitHeight = 227
        end
        inherited TopRuler: TWPRuler
          Width = 746
          ExplicitWidth = 746
        end
      end
    end
  end
  object pcTop: TPageControl
    Left = 0
    Top = 0
    Width = 750
    Height = 193
    ActivePage = TSEMail
    Align = alTop
    TabOrder = 3
    object TSEMail: TTabSheet
      Caption = 'TSEMail'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object pnlHeader: TPanel
        Left = 0
        Top = 0
        Width = 742
        Height = 165
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          742
          165)
        object lblMailTo: TLabel
          Left = 8
          Top = 12
          Width = 12
          Height = 13
          Caption = '&To'
          FocusControl = txtRecipient
        end
        object lblReturn: TLabel
          Left = 8
          Top = 67
          Width = 40
          Height = 13
          Caption = '&Reply to'
          FocusControl = eReturnAddr
        end
        object Label2: TLabel
          Left = 8
          Top = 76
          Width = 36
          Height = 13
          Anchors = [akLeft, akBottom]
          Caption = 'Su&bject'
          FocusControl = txtSubject
          ExplicitTop = 93
        end
        object lblCC: TLabel
          Left = 8
          Top = 40
          Width = 12
          Height = 13
          Caption = '&Cc'
          FocusControl = txtCC
        end
        object Image1: TImage
          Left = 620
          Top = 14
          Width = 16
          Height = 16
          Picture.Data = {
            07544269746D617036050000424D360500000000000036040000280000001000
            0000100000000100080000000000000100000000000000000000000100000000
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
            FF00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF90909090909090909090909006
            06FFFF9090909090909090909090060606FFFF909090FFFFFFFFFFF6F5E80606
            06FFFF909090FFFF090909FFFF09060606FFFF909090FFFFA2909009FFFF0606
            06FFFF909090FFFFA2909009FFF6060606FFFF909090FFFF090909FFFFF30606
            06FFFF909090FFFFFFFFFFFFF306060606FFFF909090FFFFA206F2FFFFF20606
            06FFFF909090FFFFF20606F6FFF5060606FFFF909090FFFF0809F6FFFFF20606
            06FFFF909090FFFFFFFFFF08F306060606FFFF90909006060606060606060606
            06FFFF9006060606060606060606060606FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
            FFFF}
          Stretch = True
          Visible = False
        end
        object Label1: TLabel
          Left = 8
          Top = 104
          Width = 61
          Height = 13
          Anchors = [akLeft, akBottom]
          Caption = 'Attachments'
          ExplicitTop = 121
        end
        object txtRecipient: TEdit
          Left = 88
          Top = 9
          Width = 651
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 2
          Text = 'a@b.c'
          OnExit = txtRecipientExit
        end
        object eReturnAddr: TEdit
          Left = 88
          Top = 63
          Width = 651
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          MaxLength = 80
          TabOrder = 4
          Text = 'eReturnAddr'
        end
        object txtSubject: TEdit
          Left = 88
          Top = 73
          Width = 651
          Height = 21
          Anchors = [akLeft, akRight, akBottom]
          TabOrder = 5
          Text = 'txtSubject'
        end
        object txtCC: TEdit
          Left = 88
          Top = 36
          Width = 651
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 3
          Text = 'a@b.c'
        end
        object btnAttach: TButton
          Left = 658
          Top = 136
          Width = 75
          Height = 25
          Action = actAttach
          Anchors = [akRight, akBottom]
          Caption = 'Other'
          TabOrder = 7
        end
        object btnAttachClient: TButton
          Left = 658
          Top = 100
          Width = 75
          Height = 25
          Action = actClientFile
          Anchors = [akRight, akBottom]
          Caption = 'Client &File'
          TabOrder = 6
        end
        object btnMailTo: TRzMenuButton
          Left = 5
          Top = 8
          Width = 57
          Alignment = taLeftJustify
          Caption = '&To'
          TabOrder = 0
          DropDownMenu = pmTo
        end
        object btnCC: TRzMenuButton
          Left = 5
          Top = 36
          Width = 57
          Alignment = taLeftJustify
          Caption = '&Cc'
          TabOrder = 1
          Visible = False
          DropDownMenu = pmCC
        end
        object lvAttach: TListView
          Left = 88
          Top = 100
          Width = 564
          Height = 62
          Anchors = [akLeft, akRight, akBottom]
          Columns = <>
          Constraints.MinHeight = 30
          IconOptions.AutoArrange = True
          LargeImages = ImageList1
          MultiSelect = True
          ReadOnly = True
          PopupMenu = popAttachments
          SmallImages = ImageList1
          TabOrder = 8
          ViewStyle = vsSmallIcon
          OnDblClick = lvAttachDblClick
          OnEnter = lvAttachEnter
          OnKeyUp = lvAttachKeyUp
        end
      end
    end
    object TSEdit: TTabSheet
      Caption = 'TSEdit'
      ImageIndex = 1
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
    end
  end
  object ImageList1: TImageList
    Left = 576
    Top = 4
  end
  object OpenDialog1: TOpenDialog
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 544
    Top = 4
  end
  object popAttachments: TPopupMenu
    OnPopup = popAttachmentsPopup
    Left = 512
    Top = 3
    object AttachClientFile1: TMenuItem
      Action = actClientFile
    end
    object AttachOtherFile1: TMenuItem
      Action = actAttach
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object pmiDelete: TMenuItem
      Caption = 'Delete Attachment'
      OnClick = pmiDeleteClick
    end
  end
  object ActionList1: TActionList
    Left = 608
    object actClientFile: TAction
      Caption = 'Attach Client &File...'
      OnExecute = actClientFileExecute
    end
    object actAttach: TAction
      Caption = 'Attac&h Other...'
      OnExecute = actAttachExecute
    end
  end
  object pmTo: TPopupMenu
    AutoHotkeys = maManual
    Left = 424
  end
  object pmCC: TPopupMenu
    Left = 392
  end
end
