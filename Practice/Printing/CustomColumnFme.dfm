object fmeCustomColumn: TfmeCustomColumn
  Scaled = False
Left = 0
  Top = 0
  Width = 460
  Height = 350
  TabOrder = 0
  object lblSelectAccounts: TLabel
    Left = 14
    Top = 5
    Width = 207
    Height = 13
    Caption = 'Select a Column to change its configuration'
  end
  object chkColumns: TCheckListBox
    Left = 14
    Top = 29
    Width = 279
    Height = 308
    OnClickCheck = chkColumnsClickCheck
    Ctl3D = False
    DragMode = dmAutomatic
    ItemHeight = 13
    ParentCtl3D = False
    TabOrder = 0
    OnDragDrop = chkColumnsDragDrop
    OnDragOver = chkColumnsDragOver
    OnMouseDown = chkColumnsMouseDown
    OnStartDrag = chkColumnsStartDrag
  end
  object gbSelectedColumn: TGroupBox
    Left = 305
    Top = 26
    Width = 143
    Height = 95
    Caption = 'Selected Column'
    TabOrder = 1
    object btnUp: TBitBtn
      Left = 17
      Top = 24
      Width = 107
      Height = 25
      Caption = 'Move &Up     '
      TabOrder = 0
      OnClick = btnUpClick
      Glyph.Data = {
        DE000000424DDE0000000000000076000000280000000D0000000D0000000100
        0400000000006800000000000000000000001000000010000000000000000000
        BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7000777777777777700077770000077770007777066607777000777706660777
        7000777706660777700070000666000070007706666666077000777066666077
        7000777706660777700077777060777770007777770777777000777777777777
        7000}
    end
    object btnDown: TBitBtn
      Left = 17
      Top = 56
      Width = 107
      Height = 25
      Caption = 'Move Dow&n'
      TabOrder = 1
      OnClick = btnDownClick
      Glyph.Data = {
        DE000000424DDE0000000000000076000000280000000D0000000D0000000100
        0400000000006800000000000000000000001000000010000000000000000000
        BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00777777777777
        7000777777777777700077777707777770007777706077777000777706660777
        7000777066666077700077066666660770007000066600007000777706660777
        7000777706660777700077770666077770007777000007777000777777777777
        7000}
    end
  end
  object gbOrientation: TGroupBox
    Left = 305
    Top = 127
    Width = 143
    Height = 71
    Caption = 'Orientation'
    TabOrder = 2
    object rbLandscape: TRadioButton
      Left = 20
      Top = 44
      Width = 113
      Height = 17
      Caption = 'Landscape'
      TabOrder = 0
      OnClick = rbPortraitClick
    end
    object rbPortrait: TRadioButton
      Left = 20
      Top = 21
      Width = 113
      Height = 17
      Caption = 'Portrait'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = rbPortraitClick
    end
  end
  object gbTemplates: TGroupBox
    Left = 305
    Top = 205
    Width = 143
    Height = 95
    Caption = 'Templates'
    TabOrder = 3
    object btnLoadTemplate: TBitBtn
      Left = 17
      Top = 24
      Width = 107
      Height = 25
      Caption = '&Load'
      TabOrder = 0
      OnClick = btnLoadTemplateClick
    end
    object btnSaveTemplate: TBitBtn
      Left = 17
      Top = 56
      Width = 107
      Height = 25
      Caption = '&Save'
      TabOrder = 1
      OnClick = btnSaveTemplateClick
    end
  end
  object btnDefaults: TButton
    Left = 322
    Top = 312
    Width = 107
    Height = 25
    Caption = 'De&faults'
    TabOrder = 4
    OnClick = btnDefaultsClick
  end
  object dlgLoadTemplate: TOpenDialog
    Left = 379
    Top = 198
  end
  object dlgSaveTemplate: TSaveDialog
    FileName = '*.crl'
    Filter = 'Coding Report Layout (*.crl)|*.crl'
    Left = 410
    Top = 198
  end
end
