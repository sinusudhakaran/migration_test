object fmeExistingCheques: TfmeExistingCheques
  Left = 0
  Top = 0
  Width = 592
  Height = 177
  TabOrder = 0
  object label1: TLabel
    Left = 10
    Top = 4
    Width = 86
    Height = 13
    Caption = 'Existing Cheques:'
  end
  object lblDates: TLabel
    Left = 122
    Top = 4
    Width = 98
    Height = 13
    Caption = '01/01/00 - 31/12/01'
  end
  object pgCheques: TPageControl
    Left = 8
    Top = 32
    Width = 577
    Height = 145
    ActivePage = tbsUnpresented
    TabOrder = 0
    object tbsAll: TTabSheet
      Caption = 'All Cheques'
      object lbAllCheques: TListBox
        Left = 4
        Top = 8
        Width = 561
        Height = 101
        Columns = 3
        Ctl3D = False
        ItemHeight = 13
        Items.Strings = (
          '100104 - 100106'
          '108'
          '100110 - 100150')
        ParentCtl3D = False
        TabOrder = 0
      end
    end
    object tblPresented: TTabSheet
      Caption = 'Presented Cheques'
      ImageIndex = 1
      object lbPresented: TListBox
        Left = 4
        Top = 8
        Width = 561
        Height = 101
        Columns = 3
        Ctl3D = False
        ItemHeight = 13
        Items.Strings = (
          '100104 - 100106'
          '108'
          '100110 - 100150')
        ParentCtl3D = False
        TabOrder = 0
      end
    end
    object tbsUnpresented: TTabSheet
      Caption = 'Unpresented Cheques'
      ImageIndex = 2
      object lbUnpresented: TListBox
        Left = 4
        Top = 8
        Width = 561
        Height = 101
        Columns = 3
        Ctl3D = False
        ItemHeight = 13
        Items.Strings = (
          '100104 - 100106'
          '108'
          '100110 - 100150')
        ParentCtl3D = False
        TabOrder = 0
      end
    end
  end
end
