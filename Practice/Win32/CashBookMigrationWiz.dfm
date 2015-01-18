object frmCashBookMigrationWiz: TfrmCashBookMigrationWiz
  Left = 480
  Top = 386
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Cashbook Migration'
  ClientHeight = 491
  ClientWidth = 744
  Color = clBtnFace
  Constraints.MinHeight = 526
  Constraints.MinWidth = 760
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 449
    Width = 744
    Height = 42
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      744
      42)
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 744
      Height = 2
      Align = alTop
      Shape = bsTopLine
      ExplicitWidth = 622
    end
    object btnBack: TButton
      Left = 490
      Top = 12
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '< &Back'
      Enabled = False
      TabOrder = 0
      OnClick = btnBackClick
    end
    object btnNext: TButton
      Left = 570
      Top = 12
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&Next >'
      Default = True
      TabOrder = 1
      OnClick = btnNextClick
    end
    object btnCancel: TButton
      Left = 658
      Top = 12
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 2
    end
  end
  object pnlWizard: TPanel
    Left = 0
    Top = 0
    Width = 744
    Height = 449
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlWizard'
    TabOrder = 0
    object Bevel2: TBevel
      Left = 0
      Top = 69
      Width = 744
      Height = 3
      Align = alTop
      Shape = bsTopLine
      ExplicitWidth = 593
    end
    object pnlTabTitle: TPanel
      Left = 0
      Top = 0
      Width = 744
      Height = 69
      Align = alTop
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 0
      DesignSize = (
        744
        69)
      object lblTitle: TLabel
        Left = 8
        Top = 8
        Width = 107
        Height = 16
        Caption = 'Title for Page 1'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        ShowAccelChar = False
      end
      object lblDescription: TLabel
        Left = 8
        Top = 29
        Width = 644
        Height = 34
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 'Description for Page 1'
        ShowAccelChar = False
        WordWrap = True
        ExplicitWidth = 493
      end
      object Image1: TImage
        Left = 685
        Top = 8
        Width = 46
        Height = 44
        Anchors = [akTop, akRight]
        AutoSize = True
        Picture.Data = {
          07544269746D617046180000424D461800000000000036000000280000002E00
          00002C0000000100180000000000101800000000000000000000000000000000
          0000D6D2BFDAD6C3DAD6C3DEDAC7DEDAC7E3DFCCE3DFCCE7E3D0E7E3D0ECE8D5
          ECE8D5F0ECD9F1ECDAF0F0DAF2F1DCF6F5E0F6F5E0F9F8E3FAF9E4FEFDE8FFFE
          E9FDFCEEFDFCEFFFFEF0FFFFF1FFFFF0FFFFF0FFFFF0FFFFF0FFFDEFFFFEF0FF
          FEF0FFFEF0FFFEF0FFFEF0FFFEF0FFFDEFFFFFF1FFFFF1FFFFF1FFFFF1FFFFF1
          FFFFF1FFFFF1FFFFF1FFFFF10000D5D1BEDAD6C3DAD6C3DEDAC7DEDAC7E3DFCC
          E3DFCCE7E3D0E7E3D0ECE8D5ECE8D5F0ECD9F1ECD9F0EFDAF2F1DCF6F5E0F6F5
          E0F8F7E2FAF9E4FEFDE8FEFEE9FCFEEDFCFEEDFFFDF0FFFFF0FFFEF3FFFFF9FF
          FFFBFFFFFEFFFFF1FFFDEFFFFDEFFFFEEFFFFDEFFFFDEFFFFDEFFFFDEFFFFFF1
          FFFFF1FFFFF1FFFFF1FFFFF1FFFFF1FFFFF1FFFFF1FFFFF10000D6D2BFDAD6C3
          DBD7C4DFDBC8E2DECBE4E0CDE6E2CFE8E4D1E8E4D1EDE9D6EFEBD8F1EDDAF1ED
          DAF4F3DEF6F5E0F8F7E2F9F8E3FBFAE5FDFCE7FEFDE7FEFEEAFBFBEBFCFDEFFD
          FCEEFFFCF2FFFFFFC9C3BAD0C6BEA9A09AFFFFF8FFFFF5FFFFF2FDFDF3FFFFF2
          FFFFF2FFFFF2FFFFF2FFFFF1FFFFF1FFFFF1FFFFF1FFFFF1FFFFF1FFFFF1FFFF
          F1FFFFEF0000D6D2BFDAD6C3DBD7C4DFDBC8E2DECBE4E0CDE6E2CFE8E4D1E8E4
          D1EDE9D6EFEBD8F1EDDAF1EDDAF4F3DEF6F5E0F8F7E2F8F7E2FBFAE5FDFCE7FE
          FCE7FEFEE9FDFFEEFAFBEBFEFDF0FFFFFADFDAD27A6E6970625F3F302E8F8A7D
          FFFFFDFFFFF3FCF9EBFFFFF1FFFFF1FFFFF1FFFFF1FFFDEFFFFEF0FFFEF0FFFE
          F0FFFEF0FFFEF0FFFEF0FFFDF0FFFFEF0000D6D2BFDAD6C3DBD7C4DFDAC8E2DE
          CBE4E0CDE6E2CFE8E4D1E8E4D1EDE9D6EFEAD8F1EDDAF1EDDAF4F3DEF6F5E0F8
          F7E2F8F7E2FBF9E5FDFCE7FEFCE8FDFFE8FFFFF0FEFEF0FCFCEEFFFFFF7F766E
          2C1D1B5643444E3C3D443F33FFFFFFFDFCEEFEFEF0FFFEF0FFFDF0FFFDF0FFFE
          F0FDFCEFFDFDEFFDFDEFFDFDEFFDFDEFFDFDEFFDFCEFFDFDEFFDFEEC0000D6D3
          C0DAD6C2DBD8C5DFDBC8E2DECBE4E0CDE6E2CFE8E4D1E8E5D2EDE9D6EFEBD8F1
          EDDAF1EDDAF4F3DDF6F5E0F8F7E2F9F8E3FBFAE5FDFCE6FEFDE8FEFFE9FBFCEC
          F8FBE8FFFFF5E6DFD61E140D3D2E2C331F224531332A2417EEEDE2FFFFF6FFFC
          EDFFFDEFFFFDEFFFFDEFFFFEEFFDFBEDFDFBEEFDFBEEFDFBEEFDFBEEFDFBEEFD
          FBEEFDFCEDFDFDEB0000D7D2BBDAD6BFDCD8C1DEDAC3E0DCC5E1DCC7E3DEC9E7
          E2CDE9E5CDEBE7D0EDE9D0F1EDD4F3EFD6F2F5D6F1F1DAF6F3E4F3F3DFF8F9DF
          F9FCDEFCFBE6FDFBEBFCFFEAFAFAE7FFFFFF786864342021422E304230314635
          36372A2ACDC6BDFFFFEEFFFEEBFEFDEAFEFDEAFEFFE6FFFFE0FFFFE8FFFFE8FF
          FFE8FFFFE8FFFEE7FFFEE7FFFEE7FFFEE7FFFDE60000D4D0B8D8D4BCDAD6BEDC
          D8C0DDD9C1DFDBC5E1DDC5E5E1C9E7E3CBE9E5CDEBE7CEEFEBD2F1EDD4F3F2D8
          FCF7E5F8F3E7F5F0E2F9F5DFFAF9DEFDF8E6FEF7EDFEFEE7FFFFEDFFFFF81C0B
          084430333E2B313C2D324034393D2E32B5AAA2FFFFF0FFFFE8FCFBE6FCFBE8FC
          FFE2FFFFDBFFFDE5FFFDE5FFFDE5FFFDE5FFFCE4FFFCE4FFFCE4FFFCE4FDFBE3
          0000D1CCB3D5D0B7D7D2B9D9D4BBDBD6BDDDD8BFE0DBC2E3DEC5E5E0C7E8E3CA
          EAE5CCEDE8CFF0EBD1F3EDD7A49C8DFCF4EDF6EFE5F9F2DDFAF4DEFDF5E4FEF3
          EAFFFCE4FFFFF89F938937242449394040323E3C32405C566160555CB1A9A2FF
          FFEDFEFFE4FBF9E1FBF9E3FBFBDFFBFDD9FEFADFFEF9E0FEF9E0FEF9E0FEF9E0
          FEF9E0FEF9E0FEF9E0FCFCE10000CFCAB1D2CDB4D4CFB6D6D1B8D8D3BADBD7BB
          DDDABDE1DDC1E3E0C3E5E0C8E7E3C9EBE5CEEDE7D0FFFEE661554585776EFFFF
          F4FAF0D8FCF4D7FEF4DDFFF3E4FEFAE0FFFFFA4737303F2E334737453E344660
          5D717473887E7581A09C98FFFFF4FEFDDFFBF7DEFCF7DFF9F9DDF9FBD7FBF7DC
          FBF6DDFBF6DDFBF6DDFCF7DEFCF7DEFCF7DEFCF7DEFDF9E00000CEC7ACD2CBB0
          D4CDB2D8D1B6DAD2B7D9D4B5DCD6B8E0DABDE1DBBEE7E0C5E5DEC5EAE2CBECE4
          CDFFFCE29A92808275678B7F6BFFFFE6FBF6D3F9F3D4FBF2DDFFF9E7FBF0E331
          221F46343E3D2F424F465F73728A666984514C5C938F8DFFFFEEFEFADCFCF6DA
          FCF5DCF9F8DAF7F9D7FCF6DBFCF5DBFCF5DBFCF5DAFEF7DCFEF7DCFEF7DCFDF8
          DCFCF8DC0000CEC8ABD1CBAED3CDB0D6D0B4D8D3B6D9D4B1DBD7B5DEDAB9E1DC
          BEE2DBC0ECE5CCECE4CDFFFDEAEBE4D1C2BCAFC8BDB5B2A89ACEC9AEFFFFE2FA
          F7DAF9F3E0FFFFFA786C67392B30483847493A525B546F7E7E9B5D637E5C5A6E
          373537FFFFF9FFFBDAFFF6D9FEF6DAFAF8DAF7F9D7FCF6DAFDF7DAFCF7DAFCF6
          D9FDF8DBFDF8DBFDF8DBFEF7DBFCF8DB0000CFC7AAD1C9ACD3CBAED6CEB1D9D1
          B4DAD5AFDCD7B1E0DAB7E2DABCE3DABFE3D9C1FFF6DF7267542B211D22141920
          12193025268A8377C1BCAAFFFBECFFFFFF7C7673261E1F42343F4D3F53574A64
          514A65777592484C664B4D647D7E82FFFFF0FFFAD9FFF7D6FFF6D9FCF8D9F6F9
          D6FDF5D9FEF6D9FEF6D9FDF6D9FFF7DAFFF7DAFFF7DAFEF7DAFDF7DA0000CEC6
          A9CFC7ABD1C9ACD5CDB1D7CFB2DAD4AEDBD6B0DFDAB6E1D9BBE7DEC2ECE3CBDA
          CFBA3125135447545A4C63594961332739766D71787270736B6E867C83484449
          453E47453B4A4E405860526F7E7792807E98585873585D73C6C7CAFFFFEBFEF6
          D4FFF7D6FFF6D9FCF8D9F7F9D6FCF4D8FDF4D7FCF4D7FCF4D7FEF6D9FEF6D9FE
          F6D9FEF6D8FBF5D90000D0C7A9D0C6A8D2C8ABD5CCAED8CEB0D9D1B5DBD4B5DE
          D9B5E1DAB8E8E0C3FBEFDF53413E705E64D7DFF4AEBAD898A5C4C7D4F0B1BED9
          B2BFE1828DB07781A7848DA97F87A3747A9B5B5D8356547D655E88594C775B4D
          736F685CF5F5E2FEF9E1FEF8DBFDF5D8FCF7D8FCF7D8FAF8D6FEF5D9FDF5D8FD
          F5D8FDF5D8FEF6D9FEF6D9FEF6D8FEF6D9FBF4DD0000D0C6A8D0C6A8D2C8AAD6
          CCADD9CEB0D9D0B6DBD3B7DFD9B6E1DBB7E8DFC4E9DBCD38262646333B66767D
          E6F9FFB3C8D5ECFFFFD6F0FED3ECFFADC5DF68809C5F6D926B7CA07281A6838F
          B2818AAC63648256506C867A90FFFDECFFFDE8FDF8E1F5EED7FCF5DBFBF5D9FC
          F5DAFBF5D9FEF5D8FDF5D8FDF5D8FDF5D8FDF5D8FDF5D8FDF5D8FDF5D9FBF4DC
          0000CEC4A6D0C6A8D2C8AAD6CCAED9CFB0D9D1B5DBD3B6DFD8B6E2DBBADED5BA
          F5E8D931211B4F3D40E6EFEDA6B1B0ECF9FAF3FFFFBED4E1EAFFFFE0FDFFC5E3
          FA9EB2D27286AB5063876073927180997D8796848A91FEFFFFFFFAE7FEF7E2F8
          F0DCFDF6DFFBF4DBFCF4DBFCF5DAFBF5DAFCF4D7FCF4D7FCF4D7FCF4D7FCF4D7
          FCF4D7FCF4D7FCF4D7FBF7D70000CEC4A6D1C7A9D2C8AAD6CCAED9CFB0D9D2B5
          DBD3B6DFD8B6E1D9BBEBE2C8F2E6D546362D2C1C1A857F87FDF7FE9996A7C6C8
          DE7C86A17284A691ABCDA5C4E9D7F2FFB4CDEE96B0D2597292667994717F908C
          979EF0F7F7FFF9E2FEFAE0FDF9DDFEF8DBFBF5D8FCF6D8FCF7D7FCF7D8FBF3D5
          FBF3D5FCF4D6FBF3D6FCF3D6FCF3D6FCF3D6FCF3D6FCF9D40000CEC4A6D1C7A9
          D3C9ABD6CCAED9CEB0D9D1B3DBD3B5DFD7B8E0D8BBE5DCC2F8ECD87163563424
          1C28191D33232E9F92A1F5F0FFD6D8F6D1DEFFB8D0F7A7C7F0C6E7FAB2D2EABC
          D9FA92ABD16D7FA67F8CAC929AB4A6ABBBFFFFEBFFFCDBFCFBDAF9F5D4FBF9D5
          FBF8D1F9F6D0FAF7D1FDF7D6FDF8D7F8F1D0FDF7D7FAF3D3FBF4D3FBF3D3FBF4
          D3FAF8D10000CDC3A5D0C6A8D1C7A9D5CBADD8CDB0D7D1AFD9D1B4DDD5B7DFD7
          BAE6DCC3E5DAC5F3E7D66D6150382D17A79A88F2E5DAEDE4E2BEBEC6BBC8D7DB
          F6FFB5D8ECC1E5F1C3E4F9C2DEFEB6CEF88F9FCF8089B46E7597585B75A9A387
          FFFFF8FFFFE3FCF7D7FEFAD7FFFCD8FCF9D5FAF7D3FBF7D5FAF4D3F7EFCFFBF5
          D4FAF3D2FAF3D3FAF3D3FBF4D3F9F7D00000CBC1A3CDC3A5CFC5A7D3C9ABD6CB
          AED5CFADD7CFB2DCD4B7DED4B9DDD3BBEBE0CAF3E8D3E4DAC5E3DAB7FDF1D1FF
          FEE88B7F73322D2B0F18207A919FD3F3FFD6F8FFD7F8FFC8E4FFC4DAFDA1B2DC
          AAB8DAAAB4CABBC1CD1C1203493F2FAEA493E9E3D2FDF8E3F4EAD7FFFBE5FFFE
          E7F9F6D8FBF4D1FDFAD9FBF6D4FAF4D1FBF4D2FBF4D2FBF5D2F8F3D30000C9BF
          A2CCC2A5CEC4A6D2C8AAD4C9ACD4CEACD6CEB1DAD2B5DCD3B8D9D0B8E5DBC3E4
          DAC2E9DFC7EFE4CAFAEBD8F9E5DC3C252A46384627253F4F5B7ABED4F8DAF9FF
          CDECFEA2BEE0C4DAFC94A8C7B4C5D6F5FFFFF1FAF2EBDDDDBFB2B26E5E5D5141
          3F574745E7D9D373655F685B52BBB491FFFDDCFDF8D4FAF4D1FAF5D2FAF5D1FA
          F5D1FBF5D3F7F2D40000C8BE9ECCC1A1CEC3A4D2C7A7D3C9A9D5CDABD7CEADDB
          D1B2DCD3B4E0D7B9DFD5B7E7DEC0E9E0C2EFE3C6FDEEDBA49593322433615A75
          353756545D7EB2C2E6ABCCF5C4E0FF99ABC6747B86EDF1E9F9FBE8F8F8E2FAF8
          E3FFFFF2FFFFFAFFFEF1E2D7CA978D81F5EEE6100400CDC3B9FFFFDFFDF5D3FD
          F5D3FBF2D1FBF3D2FBF3D2FBF3D2FCF3D2FAF3D10000C7BC9CCBC09FCDC2A2D0
          C5A5D3C8A8D4CBAAD6CDACDAD1B0DCD3B1DFD6B4E1D8B6E5DCBAE8DFBDEDE3C3
          FBF0DB473C3962596946425E55597828314E98A6C4C0DAFFACBFE8727B90F0F0
          EAFFFDE3FFFCDAFFFADDFEF7E1FEFCE0F7F1D6FEF9E0FFFFEDFFFEEAD9D1BFE1
          DDCEFFFBEAFFF7D7FEF5D4FCF3D2FAF1D0FBF2D1FBF2D1FBF2D1FBF1D1FBF3CE
          0000C6BB9BC9BE9ECBC0A0CFC4A4D0C5A5D3CAA9D4CBAAD8CFAED9D0AFDDD4B3
          DED5B4E3DAB9E7DDBDF1E5CAB5A8992C201F7C73825E59728284A38992AE5F6B
          88606F987C86A29CA1AAFFFEF1FDF8DCFFF9D7FEF9DBFBF7DCFEF8DBFEF9DCFC
          F6DAFDF6DCFFFEE6FFF9E2FFFBE7F6F0DAFCF4D3FCF3D2FBF2D1F9F0CFF8EFCE
          F9F0CFF9F0CFF9EFCFF9F1CC0000C6BB9BC8BD9DCABF9FCDC2A2CFC4A4D1C8A7
          D3CAA9D6CDACD8CFAEDBD2B1DED5B4E2D9B8E4DABAFDEFDC65574E3B2E31685D
          6C5A556C8989A66C728F6A718F5859793B3B4BF3F1EBFFFCE5FDF7D6FEF7D6FC
          F7D6F9F8D6F9F3D5FEF9DBFAF5D6FFFBDDF5EED1FEFADEF8F1D6FBF8DDFCF1D1
          FBF2D1F9F0CFF8EFCEF7EECDF7EECDF7EECDF7EECDF7EFCB0000C5BA9AC7BC9C
          C9BE9ECCC1A1CEC2A3D0C7A6D2C9A8D5CCABD7CEADDCD3B2DAD1B0DED5B3E7DE
          BDF1E0D6342422382A2F4B404E3E374D625F79414460474A665B4F68867E82FF
          FFEEFCF9D7FCF4D3FCF4D7FAF6D6FAF7D3FCF6D6FEF8DAFDF6D7FCF5D7FBF4D6
          FCF6D5FEF9D9FAF3D3FAF0CFFAF1D0F8EFCEF7EECDF6EDCCF6EDCCF6EDCCF6ED
          CCF5EDC90000C4B999C5BA9AC8BD9DCBC0A0CDC2A2CFC6A5D1C8A7D4CBAAD6CD
          ACD8CFAEDFD6B5E5DDBBEAE0C1C4B2B128181C4031393F3341433B4E6E6A814F
          4F6A4B4B67594B5DC6BDB6FFFFDCF6F4CAF9F3D4FBF0DAFBF4D7FCF7D3FFF4D8
          FEF4D9FEF4D7FEF4D7FEF5D7FFF6D5FDF5D3FCF4D3F9F0CFFAF1D0F7EECDF6ED
          CCF5ECCBF5ECCBF5ECCBF6ECCCF4ECC80000C1B696C4B999C5BA9BC9BE9ECCC1
          A1CCC4A3CEC5A4D2C9A8D5CCABD7CEADDCD3B2E3DAB9F5EBCC7E6A6F37252F3C
          2C374A3D4C4940526B667B56536C585470594A5BFBF3E6F2F6CAF5F7C9F6F2D4
          FAEDDDFDF0DBFDF5D2FDF2D9FDF1DAFDF2D8FDF2D7FDF3D6FDF3D5FCF3D1FCF3
          D1F9F0CFFAF1D0F7EECDF7EECDF5ECCBF6EDCCF6EDCCF6EDCCF4EDC80000BEB3
          94C2B797C4B999C8BD9DCABF9FCBC2A1CDC4A4D0C7A7D2C9A9D8CFAEDAD1B0EA
          E1BFD4CAAB36212B4632404434414E414D4F44566C667B5E5A74625E78584C5C
          FFFFF2EEF7C5F1F7C5F4F1D5F9EBE0FDEEDBFFF3D4FBEFDAFCEEDBFCEFDAFCF1
          D7FCF1D6FBF1D4FAF1D2FAF0D1FAF1CFFAF1D0F7EFCDF7EECDF5EDCBF6EDCCF6
          EDCCF6EDCCF4EDC80000BFB28FC4B593C6B896C9BB99CCBD9BCBBE9CCDC39ED1
          C8A1D5CBA5D7CDACDACFB6E4D5C6412E273A222F43313F4A404E534F5E616073
          6B687F5C5270796E8A82796EFFFFE6F2F2CEEEEEC8F3EFD3F5EDD7F9EFD7FBF2
          D5FBEFD5FBEFD5FBF0D5FBF0D5FAEFD2F9EFD1F8EED0F8EED0F9EECEF9EFCEF7
          EDCDF7ECCCF5EBCBF6EBCBF6EBCBF6EBCBF5ECC90000C1B18DC5B591C8B793CB
          BA96CDBD98CCBE99D0C39CD3CA9ED6CBA3D9CFADE9DBC85642403F282F432C3A
          3E2F3E4640515D5F7263657A514F6451455B59485BFFFFE8EEE7C9F4ECCFF6EE
          D2F3EBCEF5EED0F6EFD1F7F0D3FAF0D2FAF0D2FAF0D2FAF0D2F8EED0F8EED1F7
          EDD0F6ECCEF9EDCDF8EDCDF7ECCDF6EBCBF5EACAF5EACBF5EACBF5EACBF5ECC9
          0000C0B08CC4B490C6B692C9B995CCBC98CBBD9ACFC29BD1C89FD5CAA3E7DCBF
          8A7B6B291612463036412F3B382A3A594F67625F75514E64514A58291F22E1D4
          CDF4EBD0F5EED0EDE5C8F5EDD0F1E9CCF2EBCEF5EDD0F5EDD0F9F0D0F9F0CFF9
          F0D0F9F0D0F8EFCFF7EECEF6EDCDF6EDCCF8EDCCF8ECCBF8ECCBF7EBCAF6EAC9
          F6EAC9F6EAC9F6EAC9F6EBC60000BFAF8BC4B490C5B591C9B995CBBB97CABC98
          CEC19AD0C6A0D7CAA8DACDB43C2C1F3D29283C262B3A2C343F33425E52695B51
          6A443A4C322928BDB3A2FCF0D2EEE5C7F0E6C9F1E7CAEBE1C4F0E7C9F2E9CBF3
          EACCF4EACDF9EFCEF9EECEF9EECEF9EECEF7EDCDF7EDCDF6ECCBF5EBCBF9EDCA
          F9EDCBF7EBCAF7EBC9F5E9C7F5EAC8F6EAC8F6EAC8F5EAC50000BEAE8AC3B38F
          C5B591C8B894CAB995CFC19DCDC09BD1C5A3DDCEB28E7F6C26150C3F2B2B3A24
          29352A2D433741574A5B5E5162473A42BDB0A5FFF8D7EDE6B9EEE4C4EEE5C5F1
          E8C8F1E8C7EFE6C6F0E7C7F2E9C9F3EAC9F6EBCAF7ECCAF8ECCBF8ECCBF8ECCB
          F8ECCBF7EBCAF7ECCAF9EBC9F8EBC8F8EBC8F8EBC8F6E9C6F6E8C5F5E7C4F5E7
          C4F6EAC40000BDAD89C2B28EC3B38FC7B793C9B995CABC98CDBD9CD1C4A6DCCC
          B529190B3A27213722253A2429352728443638534549786868EEE1D9F4E8D3E9
          DFBAE6DFB3ECE2C1ECE2C1ECE2C2EDE2C2EDE3C3F0E5C5F0E6C6F2E7C7F5E9C7
          F5E9C7F6EAC8F7EBC9F7EBC9F7EBC9F7EBC9F7EBC9F8EBC5F8EBC5F8EBC5F8EB
          C6F5E8C2F5E8C3F4E7C2F4E6C0F6E9C30000BBAB87C0B08CC2B28EC5B591C7B7
          93C7B994CFC09FDACCB36F5E4B2F1D123C28263A25283D272C43312D39272089
          786BF6E7D3E4D7BEE5DBBDE7DFBDE4DBB7E9DFBEE8DEBCE9DFBEEAE0BFECE1C0
          EDE2C1EFE5C3EFE5C4F3E6C3F4E7C4F4E7C4F5E8C4F6E9C6F6E9C6F6E9C6F6E9
          C5F7E8C2F7E8C3F7E8C3F7E8C3F6E7C2F6E7C1F5E6C0F4E5C0F5E7C00000BAAA
          86BEAE8AC0B08CC4B490C6B692C3B691D0C0A2CEBFA69E8C7D5A484136222441
          2C31372028331D15AC9789FBE8CDE0D3B0E6DCB5DFD7B4DAD3B8DDD4BFE6DBBA
          E6DBB9E7DCBAE8DDBBEADFBDECE1BFEDE2C0EEE3C1F2E4C0F2E4C0F3E5C1F2E4
          C0F6E8C4F6E8C4F5E7C3F5E8C4F6E6C1F6E6C1F6E6C1F6E6C1F6E6C1F5E5C0F4
          E4BFF4E3BFF4E6BD0000B9A783BDAC88BFAE89C2B18CC4B48FC3B290D1C0A1C1
          AF935541326A5647412B2448322D402824D5C3ADF0E0C4DED0ADE0D4ADE0D5AD
          DED3B0E1D7B9DED4B8E4D8B3E8D8B4E8D9B5E9DBB6EBDCB8ECDDB9EEDFBBF0E0
          BCEFE1BBF1E2BCF2E3BDF3E5BFF4E5C0F4E6C0F5E7C1F4E6C1F7E5C0F7E5C1F7
          E5C1F7E5C1F7E6C1F7E6C1F7E5C0F6E5C0F3E4BC0000B6A581B9A984BBAB86BF
          AF8AC1B18BC4B595C1B291E3D3B679674D6955406753425F4A3AEBD5C8DFD5B2
          D9D0ACDBD1AFDCD3B0DAD0AEDCD1AFDDD2B0DFD4B2E2D5B0E4D5B2E6D8B4E7D8
          B5E7D9B5E9DAB7EADBB8EBDEBAECDEB8EDDFB9EFE2BBF0E3BCF0E3BDF1E3BDF1
          E4BEF4E5C0F3E5BFF4E5BFF4E5BFF4E5BFF4E5BFF4E5BFF4E5BFF5E5C0F1E1BC
          0000AFA47DB3A982B5AA84B8AE87BBB18AB6AB8BBDB291C5B99BD4C8AC6D5E48
          877863E5D4C3D9C8B8D3CAACD5CBACD5CCADD5CCADD6CDAED8CEAFD9D0B1DAD2
          B1DCD1B1DED3B2DFD4B4E0D5B5E1D6B5E2D7B7E4D9B8E5DABAE5DBB9E7DCBAE8
          DEBBE9DFBCEADFBDEAE0BDEBE1BFEBE2BEEEE3BCEEE3BCEEE3BCEEE3BCEEE3BC
          EEE3BCEEE3BCEEE3BCEDE2BB0000B0A278B4A67CB6A87DB9AC81BCAE84BCB089
          BDB18BC5B995C7B997CEC0A1DBCDAFCFC0A4D4C5AAD1C6A5D2C7A7D3C8A8D3C7
          A8D6CBABD6CBACD9CDADD9CEAFDDCFADDED1AEDED2AFDFD3B0E1D4B1E1D5B2E4
          D7B4E5D9B5E6D9B5E7DAB5E8DBB6E9DCB7EADEB9E9DDB8EBDEBAECE0BBEFE1B7
          EFE1B6EFE1B6EFE1B6EFE1B6EFE1B6EFE1B6EFE1B6EFE1B70000B8A474B5A272
          B8A574BDAA79C0AD7DC0B082C1B183C3B287CAB98FCAB88FD0BD96D9C69FD5C2
          9CD6C49FD6C49FD7C6A1D8C6A1DAC8A3DCCAA5DDCBA6DDCDA7E3D1A9E3D2AAE5
          D2ABE5D3ABE6D4ADE7D5ADE8D6AFE8D6AFEADAAFEBDAAFECDBB1EDDCB2EDDCB2
          EEDEB3EFDDB4EFDEB4F4E1B1F5E1B1F5E1B1F4E1B1F5E2B1F5E1B1F5E1B1F5E1
          B1F6E3B20000B29E70B29F71B5A173BAA678BEAB7CB8A67CBCAB7FC1AF85C4B3
          88C5B48AC9B78CCDBB91D0BE96CFBD99D0BE9AD3C19DD3C19DD6C4A0D7C6A1D9
          C6A3DAC7A3DFCCA7E0CDA7E1CDA8E1CEA9E5D1ACE5D2ACE6D3AEE6D3ADE8D5AE
          E8D6AEE9D6AFEAD7AFEAD7AFE9D7B0EBD8B1ECD9B1EFDCAEEFDBADEFDBADEFDB
          ADF0DDAEF0DDAEF0DDAEF0DDAEF0DCAE0000}
        Transparent = True
      end
    end
    object PageControl1: TPageControl
      Left = 0
      Top = 72
      Width = 744
      Height = 377
      ActivePage = tabMYOBCredentials
      Align = alClient
      Style = tsButtons
      TabHeight = 5
      TabOrder = 1
      TabStop = False
      TabWidth = 5
      object tabOverview: TTabSheet
        Caption = 'tabOverview'
        DesignSize = (
          736
          362)
        object BKOverviewWebBrowser: TBKWebBrowser
          Left = 10
          Top = 3
          Width = 716
          Height = 351
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          ExplicitHeight = 348
          ControlData = {
            4C000000004A0000472400000000000000000000000000000000000000000000
            000000004C000000000000000000000001000000E0D057007335CF11AE690800
            2B2E126208000000000000004C0000000114020000000000C000000000000046
            8000000000000000000000000000000000000000000000000000000000000000
            00000000000000000100000000000000000000000000000000000000}
        end
      end
      object tabMYOBCredentials: TTabSheet
        Tag = 1
        Caption = 'tabMYOBCredentials'
        ImageIndex = 1
        DesignSize = (
          736
          362)
        object pnlLogin: TPanel
          Left = 10
          Top = 0
          Width = 716
          Height = 169
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          object Label4: TLabel
            Left = 69
            Top = 27
            Width = 26
            Height = 16
            Caption = 'User'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object Label5: TLabel
            Left = 40
            Top = 69
            Width = 55
            Height = 16
            Caption = 'Password'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object edtUser: TEdit
            Left = 107
            Top = 24
            Width = 217
            Height = 24
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
          end
          object edtPassword: TEdit
            Left = 107
            Top = 66
            Width = 217
            Height = 24
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            PasswordChar = '#'
            TabOrder = 1
          end
          object btnResetPassword: TButton
            Left = 21
            Top = 123
            Width = 110
            Height = 25
            Caption = 'Reset Password'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 2
          end
          object btnSignup: TButton
            Left = 146
            Top = 123
            Width = 110
            Height = 25
            Caption = 'Sign up'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 3
          end
          object btnLogin: TButton
            Left = 281
            Top = 123
            Width = 110
            Height = 25
            Caption = 'Login'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            TabOrder = 4
            OnClick = btnLoginClick
          end
        end
        object pnlFirm: TPanel
          Left = 10
          Top = 184
          Width = 716
          Height = 164
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 1
          object Label6: TLabel
            Left = 30
            Top = 27
            Width = 65
            Height = 16
            Caption = 'Select Firm'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
          end
          object cmbSelectFirm: TComboBox
            Left = 107
            Top = 24
            Width = 217
            Height = 24
            Style = csDropDownList
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ItemHeight = 16
            ParentFont = False
            TabOrder = 0
            OnChange = cmbSelectFirmChange
          end
        end
      end
      object tabSelectData: TTabSheet
        Tag = 2
        Caption = 'tabSelectData'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ImageIndex = 2
        ParentFont = False
        DesignSize = (
          736
          362)
        object pnlSelectData: TPanel
          Left = 10
          Top = 0
          Width = 716
          Height = 351
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          object chkCreateCashBook: TCheckBox
            Left = 37
            Top = 32
            Width = 180
            Height = 17
            Caption = 'Create CashBook'
            Checked = True
            Enabled = False
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 0
          end
          object chkBankFeed: TCheckBox
            Left = 37
            Top = 56
            Width = 180
            Height = 17
            Caption = 'Bank Feed'
            Checked = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 1
          end
          object chkChartofAccount: TCheckBox
            Left = 37
            Top = 78
            Width = 180
            Height = 17
            Caption = 'Chart of Account'
            Checked = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 2
            OnClick = chkChartofAccountClick
          end
          object chkBalances: TCheckBox
            Left = 48
            Top = 101
            Width = 180
            Height = 17
            Caption = 'Balances'
            Checked = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 3
          end
          object chkTransactions: TCheckBox
            Left = 37
            Top = 124
            Width = 180
            Height = 17
            Caption = 'Transactions'
            Checked = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            State = cbChecked
            TabOrder = 4
          end
        end
      end
      object tabTermsAndConditions: TTabSheet
        Tag = 3
        Caption = 'tabTermsAndConditions'
        ImageIndex = 3
        DesignSize = (
          736
          362)
        object lRead: TLabel
          AlignWithMargins = True
          Left = 16
          Top = 6
          Width = 704
          Height = 42
          Margins.Left = 16
          Margins.Top = 6
          Margins.Right = 16
          Align = alTop
          AutoSize = False
          Caption = 
            'Please read the following Licence Agreement. Use the scroll bar ' +
            'or press the Page Down key to view the rest of the agreement.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          WordWrap = True
          ExplicitLeft = 11
          ExplicitWidth = 531
        end
        object chkAcceptAgreement: TCheckBox
          Left = 318
          Top = 326
          Width = 401
          Height = 17
          Anchors = [akRight, akBottom]
          Caption = 'Do you accept all the terms of the preceding Licence Agreement?'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = chkAcceptAgreementClick
        end
        object pnlWebBrowser: TPanel
          Left = 16
          Top = 54
          Width = 703
          Height = 251
          Anchors = [akLeft, akTop, akRight, akBottom]
          BevelOuter = bvNone
          TabOrder = 1
          object BKTermsWebBrowser: TBKWebBrowser
            Left = 0
            Top = 0
            Width = 703
            Height = 251
            Align = alClient
            TabOrder = 0
            ExplicitWidth = 716
            ExplicitHeight = 297
            ControlData = {
              4C000000A8480000F11900000000000000000000000000000000000000000000
              000000004C000000000000000000000001000000E0D057007335CF11AE690800
              2B2E126208000000000000004C0000000114020000000000C000000000000046
              8000000000000000000000000000000000000000000000000000000000000000
              00000000000000000100000000000000000000000000000000000000}
          end
        end
      end
      object tabProgress: TTabSheet
        Tag = 4
        Caption = 'tabProgress'
        ImageIndex = 4
        DesignSize = (
          736
          362)
        object pnlProgress: TPanel
          Left = 10
          Top = 0
          Width = 716
          Height = 351
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          object lblProgressTitle: TLabel
            Left = 150
            Top = 128
            Width = 401
            Height = 25
            Alignment = taCenter
            AutoSize = False
            Caption = 'Migrating Data to Cashbook'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -16
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            ShowAccelChar = False
            Transparent = True
          end
          object lblFirstProgress: TLabel
            Left = 150
            Top = 160
            Width = 401
            Height = 18
            Alignment = taCenter
            AutoSize = False
            Caption = '1 of 10 files'
          end
          object prgFirstProgress: TRzProgressBar
            Left = 150
            Top = 179
            Width = 401
            Height = 15
            BarStyle = bsLED
            BorderOuter = fsBump
            BorderWidth = 0
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clHighlight
            Font.Height = -15
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            InteriorOffset = 1
            NumSegments = 50
            ParentFont = False
            PartsComplete = 0
            Percent = 0
            ShowPercent = False
            TotalParts = 0
          end
        end
      end
      object tabComplete: TTabSheet
        Tag = 5
        Caption = 'tabComplete'
        ImageIndex = 5
        ExplicitLeft = 0
        ExplicitTop = 0
        ExplicitWidth = 0
        ExplicitHeight = 0
        object Label1: TLabel
          Left = 288
          Top = 130
          Width = 137
          Height = 20
          Caption = 'Migration Complete'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -16
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object Label2: TLabel
          Left = 248
          Top = 171
          Width = 215
          Height = 16
          Caption = 'Take me to MYOB accounts Cashbook'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
      end
    end
    object pnlTabButtonHider: TPanel
      Left = 57
      Top = 69
      Width = 185
      Height = 11
      BevelOuter = bvLowered
      TabOrder = 2
    end
  end
end
