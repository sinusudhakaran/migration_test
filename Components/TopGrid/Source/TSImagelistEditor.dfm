object tsImageListDlg: TtsImageListDlg
  Left = 308
  Top = 89
  ActiveControl = cmbGlobalSetName
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  ClientHeight = 412
  ClientWidth = 543
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object bvlProperties: TBevel
    Left = 8
    Top = 255
    Width = 526
    Height = 111
    Shape = bsFrame
  end
  object Bevel2: TBevel
    Left = -8
    Top = 106
    Width = 800
    Height = 2
  end
  object butDelete: TSpeedButton
    Left = 87
    Top = 59
    Width = 72
    Height = 43
    Caption = '&Delete picture'
    Flat = True
    Glyph.Data = {
      EE000000424DEE000000000000007600000028000000100000000F0000000100
      0400000000007800000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00887777777777
      7777800000000000000780FBFBFBFB00FB0770BFBFBFBF080F0710FBFBFBFB0B
      800711BFBF71BF000007717BF717FBFBFB078117B11FBFBFBF07871111FBFBFB
      FB0787111FBFBFBFBF0771111700000000081178117888888888888881178888
      888888888811788888888888888888888888}
    Layout = blGlyphTop
    OnClick = butDeleteClick
  end
  object butAdd: TSpeedButton
    Left = 9
    Top = 59
    Width = 72
    Height = 43
    Caption = '&Add picture'
    Flat = True
    Glyph.Data = {
      EE000000424DEE000000000000007600000028000000100000000F0000000100
      0400000000007800000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00887777777777
      7777800000000000000780FBFBFBFB00FB0780BFBFBFBF080F0780FBFBFBFB0B
      800780BFBFBFBF000007F0F7BFBFBBFBFB077BB7FB7BFFBFBF0787F7B7BFBBFB
      FB07777F7FBFBFBFBF07FB7BF7777000000887B7B7B8888888887B87F87B8888
      8888B887B887888888888887F88888888888}
    Layout = blGlyphTop
    OnClick = butAddClick
  end
  object bvlSeperator2: TBevel
    Left = 262
    Top = 59
    Width = 2
    Height = 43
  end
  object butLeft: TSpeedButton
    Left = 271
    Top = 59
    Width = 58
    Height = 43
    Caption = 'Move le&ft'
    Flat = True
    Glyph.Data = {
      EE000000424DEE000000000000007600000028000000100000000F0000000100
      0400000000007800000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
      8888888888808888888888888800788888888888806077777778888806600000
      0078888066666666607888066666666660788066666666666078880666666666
      6078888066666666607888880660000000888888806078888888888888007888
      888888888880888888888888888888888888}
    Layout = blGlyphTop
    ParentShowHint = False
    ShowHint = False
    OnClick = butLeftClick
  end
  object butRight: TSpeedButton
    Left = 335
    Top = 59
    Width = 58
    Height = 43
    Caption = 'Move &right'
    Flat = True
    Glyph.Data = {
      EE000000424DEE0000000000000076000000280000000F0000000F0000000100
      0400000000007800000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
      8880888888807888888088888880078888808877777060788880800000006607
      8880806666666660788080666666666607808066666666666080806666666666
      0880806666666660888080000000660888808888888060888880888888800888
      888088888880888888808888888888888880}
    Layout = blGlyphTop
    OnClick = butRightClick
  end
  object butLoad: TSpeedButton
    Left = 176
    Top = 59
    Width = 78
    Height = 43
    Caption = '&Change picture'
    Flat = True
    Glyph.Data = {
      2A010000424D2A010000000000007600000028000000120000000F0000000100
      040000000000B400000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00887777777777
      88888800000080000000000078888800000080033333333307888800000080B0
      3333333330788800000080FB0333333333078800000080BFB033333333307800
      000080FBFB00000000000800000080BFBFBFBFB078888800000080FBFBFBFBF0
      78888800000080BFB00000008888880000008800088888888000880000008888
      8888888888008800000088888888808880808800000088888888880008888800
      0000888888888888888888000000}
    Layout = blGlyphTop
    OnClick = butLoadClick
  end
  object bvlSeperator1: TBevel
    Left = 167
    Top = 59
    Width = 2
    Height = 43
  end
  object lblSetName: TLabel
    Left = 11
    Top = 19
    Width = 50
    Height = 13
    Caption = 'Show set :'
  end
  object lblName: TLabel
    Left = 23
    Top = 282
    Width = 34
    Height = 13
    Caption = 'Name :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object shpFixedColor: TShape
    Left = 395
    Top = 330
    Width = 33
    Height = 17
  end
  object lblSize: TLabel
    Left = 23
    Top = 311
    Width = 26
    Height = 13
    Caption = 'Size :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblPictureSize: TLabel
    Left = 79
    Top = 311
    Width = 47
    Height = 13
    Caption = '999 x 999'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
  end
  object lblProperties: TLabel
    Left = 19
    Top = 253
    Width = 66
    Height = 13
    Caption = ' Properties '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = -8
    Top = 53
    Width = 800
    Height = 2
  end
  object butAddSet: TSpeedButton
    Left = 220
    Top = 5
    Width = 57
    Height = 43
    Caption = 'A&dd set'
    Flat = True
    Glyph.Data = {
      5A010000424D5A01000000000000760000002800000014000000130000000100
      040000000000E400000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888777777
      7777777700008888800000000000000700008888808B888B8B8B8B0700008880
      0000000000000807000088808B8B8B8B8B8B0B07000080000000000000080807
      000080FBFBFBFB00FB0B0B07000080BFBFBFBF080F080807000080FBFBFBFB0B
      800B0B07000080BFBFBFBF00000808070000F0F7BFBFBBFBFB0B000800007BB7
      FB7BFFBFBF080888000087F7B7BFBBFBFB0008880000777F7FBFBFBFBF088888
      0000FB7BF777700000088888000087B7B7B888888888888800007B87F87B8888
      888888880000B887B88788888888888800008887F8888888888888880000}
    Layout = blGlyphTop
    OnClick = butAddSetClick
  end
  object butDeleteSet: TSpeedButton
    Left = 284
    Top = 5
    Width = 57
    Height = 43
    Caption = 'D&elete set'
    Flat = True
    Glyph.Data = {
      5A010000424D5A01000000000000760000002800000014000000130000000100
      040000000000E400000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888777777
      7777777700008888800000000000000700008888808B8B8B8B8B8B0700008880
      0000000000000807000088808B8B8B8B8B8B0B07000080000000000000080807
      000080FBFBFBFB00FB0B0B07000070BFBFBFBF080F080807000010FBFBFBFB0B
      800B0B07000011BFBF71BF00000808070000717BF717FBFBFB0B000800008117
      B11FBFBFBF0808880000871111FBFBFBFB000888000087111FBFBFBFBF088888
      0000711117000000000888880000117811788888888888880000888881178888
      888888880000888888117888888888880000888888888888888888880000}
    Layout = blGlyphTop
    OnClick = butDeleteSetClick
  end
  object bvlSeperator3: TBevel
    Left = 400
    Top = 60
    Width = 2
    Height = 43
  end
  object butMoveToSet: TSpeedButton
    Left = 409
    Top = 59
    Width = 75
    Height = 43
    Caption = 'Mo&ve to set ...'
    Flat = True
    Glyph.Data = {
      DE010000424DDE0100000000000076000000280000002D0000000F0000000100
      0400000000006801000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
      8888888888888888888777777777777770008888888888888888888888888888
      8800000000000000700087777777777777788888888888888808B8B8B8B8B8B0
      70000000000000000078888888888888000000000000008070000FBFBFBFB00F
      B07888880888888808B8B8B8B8B8B0B070000BFBFBFBF080F078888800888800
      000000000000808070000FBFBFBFB0B8007880000008880FBFBFBFB00FB0B0B0
      70000BFBFBFBF000007880000000880BFBFBFBF080F0808070000FBFBFBFBFBF
      B07880000008880FBFBFBFB0B800B0B070000BFBFBFBFBFBF07888880088880B
      FBFBFBF00000808070000FBFBFBFBFBFB07888880888880FBFBFBFBFBFB0B000
      80000BFBFBFBFBFBF07888888888880BFBFBFBFBFBF080888000000000000000
      008888888888880FBFBFBFBFBFB000888000888888888888888888888888880B
      FBFBFBFBFBF08888800088888888888888888888888888000000000000008888
      8000}
    Layout = blGlyphTop
    OnClick = butMoveToSetClick
  end
  object butEditSet: TSpeedButton
    Left = 348
    Top = 5
    Width = 67
    Height = 43
    Caption = 'Edit set&name'
    Flat = True
    Glyph.Data = {
      5A010000424D5A01000000000000760000002800000013000000130000000100
      040000000000E400000000000000000000001000000010000000000000000000
      8000008000000080800080000000800080008080000080808000C0C0C0000000
      FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888887777777
      777777700000888800000000000000700000888808B888B8B8B8B07000008800
      000000000000807000008808B8B8B8B8B8B0B070000000000000000000808070
      00000FBFBFBFB00FB0B0B07000000BFBFBFBF080F080807000000F0F0F0FB0B8
      00B0B07000000BFBFB00F0000080807000000FBFBF000FBFB0B0008000000BFB
      FB03B0FBF080888000000FBFBF0B30BFB000888000000BFBFBF0B30BF0888880
      0000000000003B300088888000008888888803B0888888800000888888880B00
      888888800000888888888099088888800000888888888000888888800000}
    Layout = blGlyphTop
    OnClick = butEditSetClick
  end
  object grdImages: TtsGrid
    Left = 8
    Top = 117
    Width = 526
    Height = 128
    CellSelectMode = cmNone
    CheckBoxStyle = stCheck
    ColMoving = False
    Cols = 1
    Ctl3D = True
    DefaultColWidth = 100
    DefaultRowHeight = 90
    ExportDelimiter = ','
    FocusBorder = fbNone
    GridLines = glNone
    HeadingFont.Charset = DEFAULT_CHARSET
    HeadingFont.Color = clWindowText
    HeadingFont.Height = -11
    HeadingFont.Name = 'MS Sans Serif'
    HeadingFont.Style = []
    ParentCtl3D = False
    ProvideGridMenu = True
    ResizeCols = rcNone
    ResizeRows = rrNone
    RowBarOn = False
    RowMoving = False
    Rows = 1
    RowSelectMode = rsNone
    ScrollBars = ssHorizontal
    TabOrder = 4
    ThumbTracking = True
    Version = '2.20.25'
    WantTabs = False
    XMLExport.Version = '1.0'
    XMLExport.DataPacketVersion = '2.0'
    OnColChanged = grdImagesColChanged
    OnDblClickCell = grdImagesDblClickCell
    OnEnter = grdImagesEnter
    OnPaintCell = grdImagesPaintCell
    OnSelectChanged = grdImagesSelectChanged
  end
  object cmbGlobalSetName: TComboBox
    Left = 67
    Top = 16
    Width = 137
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnClick = cmbGlobalSetNameClick
    OnEnter = cmbGlobalSetNameEnter
  end
  object butOK: TButton
    Left = 358
    Top = 377
    Width = 75
    Height = 25
    Caption = '&OK'
    TabOrder = 7
    OnClick = butOKClick
  end
  object butCancel: TButton
    Left = 458
    Top = 377
    Width = 75
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 8
    OnClick = butCancelClick
  end
  object txtName: TEdit
    Left = 79
    Top = 279
    Width = 145
    Height = 21
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    Text = 'txtName'
    OnKeyPress = txtNameKeyPress
  end
  object optLowerLeftPixel: TRadioButton
    Left = 288
    Top = 306
    Width = 243
    Height = 17
    Caption = '&Lower left pixel specifies transparantcolor'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
    TabStop = True
    OnClick = optLowerLeftPixelClick
    OnEnter = optLowerLeftPixelEnter
  end
  object optFixedColor: TRadioButton
    Left = 288
    Top = 330
    Width = 107
    Height = 17
    Caption = '&Use fixed color :'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    TabStop = True
    OnClick = optFixedColorClick
    OnEnter = optFixedColorEnter
  end
  object butSelectColor: TButton
    Left = 441
    Top = 326
    Width = 72
    Height = 25
    Caption = '&Select color'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 6
    OnClick = butSelectColorClick
    OnEnter = butSelectColorEnter
  end
  object chkTransparent: TCheckBox
    Left = 272
    Top = 282
    Width = 111
    Height = 17
    Caption = '&Transparent :'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    OnClick = chkTransparentClick
    OnEnter = chkTransparentEnter
  end
  object dlgLoadPicture: TOpenDialog
    Left = 480
    Top = 5
  end
  object dlgColor: TColorDialog
    Ctl3D = True
    Left = 448
    Top = 5
  end
end
