object WPCreatePDF: TWPCreatePDF
  Left = 87
  Top = 242
  Width = 342
  Height = 333
  Caption = 'Create PDF'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 334
    Height = 255
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Options'
      object Image1: TImage
        Left = 9
        Top = 10
        Width = 16
        Height = 15
        Picture.Data = {
          07544269746D6170D6040000424DD604000000000000E6030000280000001000
          00000F0000000100080000000000F00000007412000074120000EC0000000000
          000000000000330000006600000099000000CC000000FF000000003300003333
          00006633000099330000CC330000FF3300000066000033660000666600009966
          0000CC660000FF66000000990000339900006699000099990000CC990000FF99
          000000CC000033CC000066CC000099CC0000CCCC0000FFCC000000FF000033FF
          000066FF000099FF0000CCFF0000FFFF00000000330033003300660033009900
          3300CC003300FF00330000333300333333006633330099333300CC333300FF33
          330000663300336633006666330099663300CC663300FF663300009933003399
          33006699330099993300CC993300FF99330000CC330033CC330066CC330099CC
          3300CCCC3300FFCC330000FF330033FF330066FF330099FF3300CCFF3300FFFF
          330000006600330066006600660099006600CC006600FF006600003366003333
          66006633660099336600CC336600FF3366000066660033666600666666009966
          6600CC666600FF66660000996600339966006699660099996600CC996600FF99
          660000CC660033CC660066CC660099CC6600CCCC6600FFCC660000FF660033FF
          660066FF660099FF6600CCFF6600FFFF66000000990033009900660099009900
          9900CC009900FF00990000339900333399006633990099339900CC339900FF33
          990000669900336699006666990099669900CC669900FF669900009999003399
          99006699990099999900CC999900FF99990000CC990033CC990066CC990099CC
          9900CCCC9900FFCC990000FF990033FF990066FF990099FF9900CCFF9900FFFF
          99000000CC003300CC006600CC009900CC00CC00CC00FF00CC000033CC003333
          CC006633CC009933CC00CC33CC00FF33CC000066CC003366CC006666CC009966
          CC00CC66CC00FF66CC000099CC003399CC006699CC009999CC00CC99CC00FF99
          CC0000CCCC0033CCCC0066CCCC0099CCCC00CCCCCC00FFCCCC0000FFCC0033FF
          CC0066FFCC0099FFCC00CCFFCC00FFFFCC000000FF003300FF006600FF009900
          FF00CC00FF00FF00FF000033FF003333FF006633FF009933FF00CC33FF00FF33
          FF000066FF003366FF006666FF009966FF00CC66FF00FF66FF000099FF003399
          FF006699FF009999FF00CC99FF00FF99FF0000CCFF0033CCFF0066CCFF0099CC
          FF00CCCCFF00FFCCFF0000FFFF0033FFFF0066FFFF0099FFFF00CCFFFF00FFFF
          FF00000000000D0D0D001A1A1A00282828003535350043434300505050005D5D
          5D006B6B6B00787878008686860093939300A1A1A100AEAEAE00BBBBBB00C9C9
          C900D6D6D600E4E4E400F1F1F100FFFFFF00D7D7D7D7D7D7D7D7D7D7D7D7D7D7
          D7D7D7D7D700D9D9D9D9D9D9D9D9D9D9D7D7D7D7D700C2E8E8E8E8E8E8E8E8D9
          D7D7D7D7D7009EBCACE8E8E8E8E8ACD9D7D7D7D7D700E8E8A5BB9EACA5A5BBD9
          D7D7D7D7D700E8E8ACC2ACBBBBBBACD9D7D7D7D7D700E8E8E8A5A59EE8E8E8D9
          D7D7D7D7D700E8E8E8E89EE8E8E8E8D9D7D7D7D7D700E8E8E8E8A5E8E8E8E8D9
          D7D7D7000000000000000000E8E8E8D9D7D7D700B4B4B4B4B4B4B400E8E8E8D9
          D7D7D700B4B4B4B4B4B4B400E80000D9D7D7D7D7D700E8E8E8E8E8E8E8D9D9D7
          D7D7D7D7D70000000000000000D9D7D7D7D7D7D7D7D7D7D7D7D7D7D7D7D7D7D7
          D7D7}
      end
      object BackgroundImage: TImage
        Left = 245
        Top = 128
        Width = 62
        Height = 52
        Visible = False
      end
      object FileName: TEdit
        Left = 31
        Top = 7
        Width = 249
        Height = 24
        TabOrder = 0
        Text = 'c:\test.pdf'
      end
      object Button3: TButton
        Left = 284
        Top = 6
        Width = 29
        Height = 25
        Caption = '...'
        TabOrder = 1
        OnClick = Button3Click
      end
      object GroupBox3: TGroupBox
        Left = 5
        Top = 37
        Width = 312
        Height = 72
        Caption = ' compression '
        TabOrder = 2
        object Label5: TLabel
          Left = 10
          Top = 42
          Width = 45
          Height = 16
          Caption = 'Images'
        end
        object EnableCompression: TCheckBox
          Left = 6
          Top = 19
          Width = 160
          Height = 17
          Alignment = taLeftJustify
          Caption = 'compress text'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object ImageCompression: TComboBox
          Left = 149
          Top = 39
          Width = 145
          Height = 24
          Style = csDropDownList
          ItemHeight = 16
          TabOrder = 1
          Items.Strings = (
            'ZIP'
            'JPEG 10'
            'JPEG 25'
            'JPEG 50'
            'JPEG 75')
        end
      end
      object AutoLaunch: TCheckBox
        Left = 17
        Top = 120
        Width = 301
        Height = 17
        Caption = 'Display PDF file after creation'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object EmbedFonts: TCheckBox
        Left = 17
        Top = 142
        Width = 135
        Height = 17
        Caption = 'Embed all fonts'
        TabOrder = 4
      end
      object EncodeASCI85: TCheckBox
        Left = 17
        Top = 161
        Width = 214
        Height = 17
        Caption = 'Encode PDF file to use 7bit only'
        TabOrder = 5
      end
      object SubsetsOnly: TCheckBox
        Left = 144
        Top = 142
        Width = 92
        Height = 17
        Alignment = taLeftJustify
        Caption = 'as subsets'
        TabOrder = 6
      end
      object Messages: TComboBox
        Left = 2
        Top = 193
        Width = 311
        Height = 24
        ItemHeight = 16
        TabOrder = 7
        Text = 'Messages'
        Visible = False
      end
      object asCID: TCheckBox
        Left = 259
        Top = 142
        Width = 53
        Height = 17
        Alignment = taLeftJustify
        Caption = 'CID'
        TabOrder = 8
        Visible = False
      end
      object PDFAMode: TCheckBox
        Left = 246
        Top = 161
        Width = 66
        Height = 17
        Alignment = taLeftJustify
        Caption = 'PDF/A'
        TabOrder = 9
        Visible = False
        OnClick = PDFAModeClick
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Security'
      ImageIndex = 1
      object radSecurity: TRadioGroup
        Left = 5
        Top = 8
        Width = 316
        Height = 44
        Caption = ' Security '
        Columns = 3
        Items.Strings = (
          'off'
          '40 bit'
          '128 bit')
        TabOrder = 0
      end
      object grpPasswords: TGroupBox
        Left = 5
        Top = 55
        Width = 316
        Height = 78
        Caption = ' Passwords '
        TabOrder = 1
        object Label3: TLabel
          Left = 12
          Top = 24
          Width = 38
          Height = 16
          Caption = 'Owner'
        end
        object Label4: TLabel
          Left = 14
          Top = 51
          Width = 29
          Height = 16
          Caption = 'User'
        end
        object OwnerPassword: TEdit
          Left = 62
          Top = 20
          Width = 231
          Height = 24
          TabOrder = 0
        end
        object UserPassword: TEdit
          Left = 62
          Top = 48
          Width = 231
          Height = 24
          TabOrder = 1
        end
      end
      object grpEnable: TGroupBox
        Left = 4
        Top = 144
        Width = 316
        Height = 73
        Caption = ' enable '
        TabOrder = 2
        object chkPrint: TCheckBox
          Left = 5
          Top = 20
          Width = 97
          Height = 17
          Caption = 'Printing'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
        object chkLowRes: TCheckBox
          Left = 155
          Top = 17
          Width = 146
          Height = 17
          Caption = 'Low Quality print only'
          TabOrder = 1
        end
        object chkCopy: TCheckBox
          Left = 5
          Top = 40
          Width = 97
          Height = 17
          Caption = 'Copy'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object chkEdit: TCheckBox
          Left = 155
          Top = 39
          Width = 97
          Height = 17
          Caption = 'Edit'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Watermark'
      ImageIndex = 2
      TabVisible = False
      object Bevel1: TBevel
        Left = 200
        Top = 2
        Width = 117
        Height = 119
        Shape = bsFrame
      end
      object Image2: TImage
        Left = 205
        Top = 7
        Width = 105
        Height = 105
        Stretch = True
      end
      object Button4: TButton
        Left = 5
        Top = 96
        Width = 130
        Height = 25
        Caption = 'Load image file'
        TabOrder = 0
      end
      object RadioGroup2: TRadioGroup
        Left = 5
        Top = 3
        Width = 188
        Height = 88
        Caption = ' draw mode '
        Columns = 2
        Items.Strings = (
          'top left'
          'top right'
          'centered'
          'tiled')
        TabOrder = 1
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 255
    Width = 334
    Height = 44
    Align = alBottom
    TabOrder = 1
    object Label1: TLabel
      Left = 2
      Top = 7
      Width = 100
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'powered by wPDF  '
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -10
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      Transparent = True
      WordWrap = True
      OnClick = Label2Click
    end
    object Label2: TLabel
      Left = 2
      Top = 21
      Width = 100
      Height = 17
      Alignment = taCenter
      AutoSize = False
      Caption = 'WPCubed GmbH  '
      Font.Charset = ANSI_CHARSET
      Font.Color = clNavy
      Font.Height = -10
      Font.Name = 'Arial'
      Font.Style = []
      ParentFont = False
      Transparent = True
      WordWrap = True
      OnClick = Label2Click
    end
    object Button1: TButton
      Left = 224
      Top = 9
      Width = 90
      Height = 25
      Caption = 'Create PDF'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 126
      Top = 9
      Width = 90
      Height = 25
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = Button2Click
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'PDF'
    Filter = 'PDF FIles|*.PDF'
    Left = 294
    Top = 231
  end
end
