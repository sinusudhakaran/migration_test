inherited cxStyleRepositoryEditor: TcxStyleRepositoryEditor
  Left = 333
  Top = 185
  Width = 317
  Height = 412
  Caption = 'StyleRepository editor'
  Constraints.MinHeight = 350
  Constraints.MinWidth = 300
  Position = poDefaultPosOnly
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 309
    Height = 378
    ActivePage = tsStyles
    Align = alClient
    TabOrder = 0
    object tsStyles: TTabSheet
      Caption = 'Styles'
      object lbStyles: TListBox
        Left = 0
        Top = 0
        Width = 210
        Height = 350
        Align = alClient
        ItemHeight = 13
        MultiSelect = True
        PopupMenu = pmStyles
        TabOrder = 0
        OnClick = lbStylesClick
      end
      object pnlStyles: TPanel
        Left = 210
        Top = 0
        Width = 91
        Height = 350
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object btStyleAdd: TButton
          Left = 9
          Top = 8
          Width = 75
          Height = 25
          Caption = '&Add'
          TabOrder = 0
          OnClick = btStyleAddClick
        end
        object btStyleDelete: TButton
          Left = 9
          Top = 40
          Width = 75
          Height = 25
          Caption = '&Delete'
          TabOrder = 1
          OnClick = btStyleDeleteClick
        end
        object btClose: TButton
          Left = 9
          Top = 316
          Width = 75
          Height = 26
          Anchors = [akLeft, akBottom]
          Caption = '&Close'
          TabOrder = 2
          OnClick = btCloseClick
        end
      end
    end
    object tsStyleSheets: TTabSheet
      Caption = 'Style Sheets'
      ImageIndex = 1
      object lbStyleSheets: TListBox
        Left = 0
        Top = 0
        Width = 201
        Height = 350
        Align = alClient
        ItemHeight = 13
        MultiSelect = True
        PopupMenu = pmStyleSheets
        TabOrder = 0
        OnClick = lbStyleSheetsClick
      end
      object pnlStyleSheets: TPanel
        Left = 201
        Top = 0
        Width = 100
        Height = 350
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object btStyleSheetAdd: TButton
          Left = 9
          Top = 8
          Width = 85
          Height = 25
          Caption = '&Add...'
          TabOrder = 0
          OnClick = btStyleSheetAddClick
        end
        object btStyleSheetDelete: TButton
          Left = 9
          Top = 38
          Width = 85
          Height = 25
          Caption = '&Delete'
          TabOrder = 1
          OnClick = btStyleSheetDeleteClick
        end
        object Button3: TButton
          Left = 9
          Top = 316
          Width = 85
          Height = 26
          Anchors = [akLeft, akBottom]
          Caption = '&Close'
          TabOrder = 2
          OnClick = btCloseClick
        end
        object btnStyleSheetEdit: TButton
          Left = 9
          Top = 68
          Width = 85
          Height = 25
          Caption = '&Edit...'
          TabOrder = 3
          OnClick = btnStyleSheetEditClick
        end
        object btnStyleSheetsSave: TButton
          Left = 9
          Top = 104
          Width = 85
          Height = 25
          Caption = '&Save to ini...'
          TabOrder = 4
          OnClick = btnStyleSheetsSaveClick
        end
        object btnStyleSheetsLoad: TButton
          Left = 9
          Top = 133
          Width = 85
          Height = 25
          Caption = '&Load from ini...'
          TabOrder = 5
          OnClick = btnStyleSheetsLoadClick
        end
        object btnStyleSheetsPredefine: TButton
          Left = 9
          Top = 163
          Width = 85
          Height = 25
          Caption = '&Predefined...'
          TabOrder = 6
          OnClick = btnStyleSheetsPredefineClick
        end
      end
    end
  end
  object pmStyles: TPopupMenu
    Left = 40
    Top = 88
    object miStyleAdd: TMenuItem
      Caption = 'Add'
      ShortCut = 45
      OnClick = btStyleAddClick
    end
    object miStyleDelete: TMenuItem
      Caption = 'Delete'
      Enabled = False
      ShortCut = 46
      OnClick = btStyleDeleteClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object miStyleSelectAll: TMenuItem
      Caption = 'Select all'
      Enabled = False
      ShortCut = 16449
      OnClick = miStyleSelectAllClick
    end
  end
  object pmStyleSheets: TPopupMenu
    Left = 72
    Top = 168
    object miStyleSheetAdd: TMenuItem
      Caption = 'Add...'
      ShortCut = 45
      OnClick = btStyleSheetAddClick
    end
    object miStyleSheetDelete: TMenuItem
      Caption = 'Delete'
      Enabled = False
      ShortCut = 46
      OnClick = btStyleSheetDeleteClick
    end
    object imStyleSheetEdit: TMenuItem
      Caption = 'Edit...'
      OnClick = btnStyleSheetEditClick
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object miStyleSheetSelectAll: TMenuItem
      Caption = 'Select all'
      Enabled = False
      ShortCut = 16449
      OnClick = miStyleSheetSelectAllClick
    end
  end
  object pmAddStyleSheet: TPopupMenu
    Left = 128
    Top = 48
  end
  object SaveDialog: TSaveDialog
    DefaultExt = 'ini'
    FileName = 'cxstyles.ini'
    Filter = 'Ini files|*.ini'
    Left = 160
    Top = 120
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'ini'
    FileName = 'cxstyles.ini'
    Filter = 'Ini files|*.ini'
    Left = 160
    Top = 176
  end
end
