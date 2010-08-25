object dxfmPageSetupDialog: TdxfmPageSetupDialog
  Left = 448
  Top = 228
  BorderStyle = bsDialog
  Caption = 'Page Setup'
  ClientHeight = 435
  ClientWidth = 526
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pnlStyleName: TPanel
    Left = 0
    Top = 0
    Width = 526
    Height = 31
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblStyleName: TLabel
      Left = 4
      Top = 9
      Width = 61
      Height = 13
      Caption = 'Style &Name: '
      FocusControl = edStyleName
    end
    object edStyleName: TEdit
      Left = 66
      Top = 6
      Width = 259
      Height = 21
      MaxLength = 31
      TabOrder = 0
      OnChange = edStyleNameChange
      OnExit = edStyleNameExit
    end
    object btnOptions: TButton
      Left = 331
      Top = 5
      Width = 88
      Height = 24
      Caption = '&Options ...'
      TabOrder = 1
    end
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 399
    Width = 526
    Height = 36
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object btnPrintPreview: TButton
      Left = 117
      Top = 7
      Width = 106
      Height = 23
      Caption = 'Print Preview...'
      TabOrder = 1
      OnClick = btnPrintPreviewClick
    end
    object btnPrint: TButton
      Left = 5
      Top = 7
      Width = 106
      Height = 23
      Caption = 'Print...'
      TabOrder = 0
      OnClick = btnPrintClick
    end
    object btnOK: TButton
      Left = 273
      Top = 7
      Width = 79
      Height = 23
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 2
    end
    object btnCancel: TButton
      Left = 358
      Top = 7
      Width = 79
      Height = 23
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 3
    end
    object btnHelp: TButton
      Left = 443
      Top = 7
      Width = 79
      Height = 23
      Caption = '&Help'
      TabOrder = 4
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 31
    Width = 526
    Height = 368
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object pgctrlMain: TPageControl
      Left = 5
      Top = 3
      Width = 517
      Height = 365
      ActivePage = tshMargins
      MultiLine = True
      TabOrder = 0
      OnChange = pgctrlMainChange
      OnChanging = pgctrlMainChanging
      object tshPage: TTabSheet
        Caption = '&Page'
        object Panel5: TPanel
          Left = 0
          Top = 0
          Width = 509
          Height = 337
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object gbxPaper: TGroupBox
            Left = 5
            Top = 5
            Width = 231
            Height = 326
            Caption = ' Paper '
            TabOrder = 0
            object lblPaperWidth: TLabel
              Left = 18
              Top = 208
              Width = 32
              Height = 13
              Caption = '&Width:'
              OnClick = lblMarginTopClick
            end
            object lblPaperHeight: TLabel
              Left = 18
              Top = 234
              Width = 35
              Height = 13
              Caption = 'H&eight:'
              OnClick = lblMarginTopClick
            end
            object bvlPaperDimensions: TBevel
              Left = 64
              Top = 191
              Width = 157
              Height = 4
              Shape = bsBottomLine
            end
            object bvlPaperSource: TBevel
              Left = 79
              Top = 278
              Width = 142
              Height = 4
              Shape = bsBottomLine
            end
            object bvlPaperType: TBevel
              Left = 36
              Top = 20
              Width = 185
              Height = 4
              Shape = bsBottomLine
            end
            object bvlPaperWidthHolder: TBevel
              Left = 81
              Top = 204
              Width = 100
              Height = 22
              Visible = False
            end
            object bvlPaperHeightHolder: TBevel
              Left = 81
              Top = 230
              Width = 100
              Height = 22
              Visible = False
            end
            object lblPaperSource: TLabel
              Left = 6
              Top = 272
              Width = 63
              Height = 13
              Caption = 'Paper so&urce'
              FocusControl = cbxPaperSource
              OnClick = lblPaperSourceClick
            end
            object lblPaperType: TLabel
              Left = 6
              Top = 15
              Width = 24
              Height = 13
              Caption = 'T&ype'
              FocusControl = lbxPaperType
            end
            object lblPaperDimensions: TLabel
              Left = 6
              Top = 186
              Width = 53
              Height = 13
              Caption = 'Dimensions'
            end
            object lbxPaperType: TListBox
              Left = 12
              Top = 31
              Width = 208
              Height = 148
              Style = lbOwnerDrawFixed
              IntegralHeight = True
              ItemHeight = 18
              TabOrder = 0
              OnClick = lbxPaperTypeClick
              OnDrawItem = lbxPaperTypeDrawItem
            end
            object cbxPaperSource: TComboBox
              Left = 12
              Top = 289
              Width = 208
              Height = 24
              Style = csOwnerDrawFixed
              ItemHeight = 18
              TabOrder = 1
              OnChange = cbxPaperSourceChange
              OnDrawItem = cbxPaperSourceDrawItem
            end
          end
          object Panel1: TPanel
            Left = 239
            Top = 0
            Width = 270
            Height = 337
            Align = alRight
            BevelOuter = bvNone
            ParentColor = True
            TabOrder = 1
            object Label1: TLabel
              Left = 265
              Top = 5
              Width = 5
              Height = 326
              Align = alRight
              AutoSize = False
              Transparent = True
            end
            object Label2: TLabel
              Left = 0
              Top = 5
              Width = 5
              Height = 326
              Align = alLeft
              AutoSize = False
              Transparent = True
            end
            object Label3: TLabel
              Left = 0
              Top = 0
              Width = 270
              Height = 5
              Align = alTop
              AutoSize = False
              Transparent = True
            end
            object Label4: TLabel
              Left = 0
              Top = 331
              Width = 270
              Height = 6
              Align = alBottom
              AutoSize = False
              Transparent = True
            end
            object Panel6: TPanel
              Left = 5
              Top = 5
              Width = 260
              Height = 326
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 0
              object gbxOrientation: TGroupBox
                Left = 0
                Top = 0
                Width = 260
                Height = 187
                Align = alTop
                Caption = ' Orientation '
                TabOrder = 0
                object bvlOrientationHolder: TBevel
                  Left = 8
                  Top = 20
                  Width = 145
                  Height = 159
                  Visible = False
                end
                object rBtnLandscape: TRadioButton
                  Tag = 1
                  Left = 162
                  Top = 109
                  Width = 93
                  Height = 17
                  Caption = '&Landscape'
                  TabOrder = 1
                  OnClick = OrientationClick
                  OnDblClick = OrientationDblClick
                end
                object rBtnPortrait: TRadioButton
                  Left = 162
                  Top = 62
                  Width = 93
                  Height = 17
                  Caption = 'P&ortrait'
                  Checked = True
                  TabOrder = 0
                  TabStop = True
                  OnClick = OrientationClick
                  OnDblClick = OrientationDblClick
                end
              end
              object gbxPrintOrder: TGroupBox
                Left = 0
                Top = 187
                Width = 260
                Height = 80
                Align = alTop
                Caption = ' Print Order '
                TabOrder = 1
                object pbxPageOrder: TPaintBox
                  Left = 10
                  Top = 20
                  Width = 74
                  Height = 49
                  OnDblClick = pbxPageOrderDblClick
                  OnPaint = pbxPageOrderPaint
                end
                object rbtnOverThenDown: TRadioButton
                  Left = 105
                  Top = 47
                  Width = 150
                  Height = 17
                  Caption = 'O&ver, then down'
                  TabOrder = 0
                  OnClick = PageOrderClick
                end
                object rbtnDownThenOver: TRadioButton
                  Tag = 1
                  Left = 105
                  Top = 24
                  Width = 150
                  Height = 17
                  Caption = '&Down, then over'
                  Checked = True
                  TabOrder = 1
                  TabStop = True
                  OnClick = PageOrderClick
                end
              end
              object gbxShading: TGroupBox
                Left = 0
                Top = 267
                Width = 260
                Height = 59
                Align = alClient
                Caption = ' Shading '
                TabOrder = 2
                object chbxShading: TCheckBox
                  Left = 11
                  Top = 25
                  Width = 206
                  Height = 17
                  Caption = 'Print using &gray shading'
                  TabOrder = 0
                  OnClick = chbxShadingClick
                end
              end
            end
          end
        end
      end
      object tshMargins: TTabSheet
        Caption = '&Margins'
        object pnlInMargins: TPanel
          Left = 0
          Top = 0
          Width = 509
          Height = 337
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object Bevel12: TBevel
            Left = 297
            Top = 7
            Width = 201
            Height = 5
            Shape = bsBottomLine
          end
          object bvlPreviewHolder: TBevel
            Left = 252
            Top = 18
            Width = 246
            Height = 310
            Visible = False
          end
          object lblPreview: TLabel
            Left = 252
            Top = 3
            Width = 38
            Height = 13
            Caption = 'Preview'
          end
          object Panel14: TPanel
            Left = 0
            Top = 0
            Width = 237
            Height = 337
            Align = alLeft
            BevelOuter = bvNone
            ParentColor = True
            TabOrder = 0
            object Label5: TLabel
              Left = 0
              Top = 0
              Width = 237
              Height = 5
              Align = alTop
              AutoSize = False
              Transparent = True
            end
            object Label6: TLabel
              Left = 0
              Top = 332
              Width = 237
              Height = 5
              Align = alBottom
              AutoSize = False
              Transparent = True
            end
            object Label7: TLabel
              Left = 0
              Top = 5
              Width = 5
              Height = 327
              Align = alLeft
              AutoSize = False
              Transparent = True
            end
            object Label8: TLabel
              Left = 232
              Top = 5
              Width = 5
              Height = 327
              Align = alRight
              AutoSize = False
              Transparent = True
            end
            object Panel8: TPanel
              Left = 5
              Top = 5
              Width = 227
              Height = 327
              Align = alClient
              BevelOuter = bvNone
              TabOrder = 0
              object bvlMarginsWarningHolder: TBevel
                Left = 4
                Top = 281
                Width = 222
                Height = 33
                Visible = False
              end
              object gbxMargins: TGroupBox
                Left = 0
                Top = 0
                Width = 227
                Height = 223
                Align = alTop
                TabOrder = 0
                object pnlMargins: TPanel
                  Left = 2
                  Top = 15
                  Width = 223
                  Height = 106
                  Align = alTop
                  BevelOuter = bvNone
                  TabOrder = 0
                  object lblMarginTop: TLabel
                    Left = 13
                    Top = 8
                    Width = 22
                    Height = 13
                    Caption = '&Top:'
                    OnClick = lblMarginTopClick
                  end
                  object lblMarginBottom: TLabel
                    Left = 13
                    Top = 34
                    Width = 41
                    Height = 13
                    Caption = '&Bottom: '
                    OnClick = lblMarginTopClick
                  end
                  object lblMarginLeft: TLabel
                    Left = 13
                    Top = 60
                    Width = 26
                    Height = 13
                    Caption = 'Le&ft: '
                    OnClick = lblMarginTopClick
                  end
                  object lblMarginRight: TLabel
                    Left = 13
                    Top = 86
                    Width = 32
                    Height = 13
                    Caption = 'Ri&ght: '
                    OnClick = lblMarginTopClick
                  end
                  object bvlMarginTopHolder: TBevel
                    Left = 97
                    Top = 3
                    Width = 117
                    Height = 22
                    Visible = False
                  end
                  object bvlMarginBottomHolder: TBevel
                    Left = 97
                    Top = 29
                    Width = 117
                    Height = 22
                    Visible = False
                  end
                  object bvlMarginLeftHolder: TBevel
                    Left = 97
                    Top = 55
                    Width = 117
                    Height = 22
                    Visible = False
                  end
                  object bvlMarginRightHolder: TBevel
                    Left = 97
                    Top = 81
                    Width = 117
                    Height = 22
                    Visible = False
                  end
                end
                object pnlHFMargins: TPanel
                  Left = 2
                  Top = 121
                  Width = 223
                  Height = 58
                  Align = alTop
                  BevelOuter = bvNone
                  TabOrder = 1
                  object lblMarginHeader: TLabel
                    Left = 13
                    Top = 11
                    Width = 42
                    Height = 13
                    Caption = 'H&eader: '
                    OnClick = lblMarginTopClick
                  end
                  object lblMarginFooter: TLabel
                    Left = 13
                    Top = 38
                    Width = 36
                    Height = 13
                    Caption = 'Foote&r:'
                    OnClick = lblMarginTopClick
                  end
                  object bvlMarginHeaderHolder: TBevel
                    Left = 97
                    Top = 6
                    Width = 117
                    Height = 22
                    Visible = False
                  end
                  object bvlMarginFooterHolder: TBevel
                    Left = 97
                    Top = 33
                    Width = 117
                    Height = 22
                    Visible = False
                  end
                end
                object Panel3: TPanel
                  Left = 2
                  Top = 179
                  Width = 223
                  Height = 39
                  Align = alTop
                  BevelOuter = bvNone
                  TabOrder = 2
                  object btnFix: TButton
                    Left = 6
                    Top = 13
                    Width = 79
                    Height = 23
                    Caption = 'Fi&x'
                    TabOrder = 0
                    OnClick = btnFixClick
                  end
                  object btnRestoreOriginalMargins: TButton
                    Left = 88
                    Top = 13
                    Width = 127
                    Height = 23
                    Caption = 'Restore &Original'
                    TabOrder = 1
                    OnClick = btnRestoreOriginalMarginsClick
                  end
                end
              end
              object pnlCenterOnPage: TPanel
                Left = 0
                Top = 223
                Width = 227
                Height = 54
                Align = alTop
                BevelOuter = bvNone
                TabOrder = 1
                object bvlCenterOnPage: TBevel
                  Left = 99
                  Top = 16
                  Width = 128
                  Height = 4
                  Shape = bsBottomLine
                end
                object lblCenterOnPage: TLabel
                  Left = 1
                  Top = 13
                  Width = 78
                  Height = 13
                  Caption = 'Center on page '
                end
                object chbxCenterHorz: TCheckBox
                  Left = 9
                  Top = 33
                  Width = 112
                  Height = 17
                  Caption = 'Hori&zontaly'
                  Color = clBtnFace
                  ParentColor = False
                  TabOrder = 0
                  OnClick = CenterOnPageClick
                end
                object chbxCenterVert: TCheckBox
                  Tag = 1
                  Left = 131
                  Top = 33
                  Width = 92
                  Height = 17
                  Caption = '&Verticaly'
                  TabOrder = 1
                  OnClick = CenterOnPageClick
                end
              end
            end
          end
        end
      end
      object tshHeaderFooter: TTabSheet
        Caption = '&Header\Footer'
        object Panel7: TPanel
          Left = 0
          Top = 0
          Width = 509
          Height = 337
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object pnlBottom: TPanel
            Left = 0
            Top = 236
            Width = 509
            Height = 67
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object pnlHFOpt: TPanel
              Left = 0
              Top = 0
              Width = 509
              Height = 67
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 0
              object Label18: TLabel
                Left = 0
                Top = 65
                Width = 509
                Height = 2
                Align = alBottom
                AutoSize = False
                Transparent = True
              end
              object Label17: TLabel
                Left = 0
                Top = 2
                Width = 4
                Height = 63
                Align = alLeft
                AutoSize = False
                Transparent = True
              end
              object Label19: TLabel
                Left = 505
                Top = 2
                Width = 4
                Height = 63
                Align = alRight
                AutoSize = False
                Transparent = True
              end
              object Label20: TLabel
                Left = 0
                Top = 0
                Width = 509
                Height = 2
                Align = alTop
                AutoSize = False
                Transparent = True
              end
              object Panel9: TPanel
                Left = 4
                Top = 2
                Width = 501
                Height = 63
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 0
                object pnlVertAlignment: TPanel
                  Left = 0
                  Top = 0
                  Width = 125
                  Height = 63
                  Align = alLeft
                  BevelOuter = bvNone
                  TabOrder = 0
                  object gbxVertAlignment: TGroupBox
                    Left = 0
                    Top = 0
                    Width = 120
                    Height = 63
                    Caption = ' Vertical Alignment '
                    TabOrder = 0
                    object tbTAVert: TToolBar
                      Left = 22
                      Top = 23
                      Width = 79
                      Height = 30
                      Align = alNone
                      ButtonHeight = 24
                      ButtonWidth = 25
                      EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
                      EdgeInner = esLowered
                      Images = ilPaperTypes
                      TabOrder = 0
                      Wrapable = False
                      object ToolButton12: TToolButton
                        Left = 0
                        Top = 2
                        Caption = 'ToolButton9'
                        Down = True
                        Grouped = True
                        ImageIndex = 0
                        Style = tbsCheck
                        OnClick = VertTextAlignClick
                      end
                      object ToolButton13: TToolButton
                        Tag = 1
                        Left = 25
                        Top = 2
                        Caption = 'ToolButton10'
                        Grouped = True
                        ImageIndex = 1
                        Style = tbsCheck
                        OnClick = VertTextAlignClick
                      end
                      object ToolButton14: TToolButton
                        Tag = 2
                        Left = 50
                        Top = 2
                        Caption = 'ToolButton11'
                        Grouped = True
                        ImageIndex = 2
                        Style = tbsCheck
                        OnClick = VertTextAlignClick
                      end
                    end
                  end
                end
                object gbxFunctions: TGroupBox
                  Left = 125
                  Top = 0
                  Width = 376
                  Height = 63
                  Align = alClient
                  Caption = ' Predefined Functions  '
                  TabOrder = 1
                  object pnlToolBar: TPanel
                    Left = 2
                    Top = 15
                    Width = 372
                    Height = 46
                    Align = alClient
                    BevelOuter = bvNone
                    Caption = 'Panel1'
                    TabOrder = 0
                    object tbPredefined: TToolBar
                      Left = 19
                      Top = 8
                      Width = 335
                      Height = 30
                      Align = alNone
                      ButtonHeight = 24
                      ButtonWidth = 25
                      EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
                      EdgeInner = esLowered
                      ParentShowHint = False
                      ShowHint = True
                      TabOrder = 0
                      Wrapable = False
                    end
                  end
                end
              end
            end
          end
          object pnlHeader: TPanel
            Left = 0
            Top = 0
            Width = 509
            Height = 118
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 1
            object pnlHeaderMemos: TPanel
              Left = 0
              Top = 46
              Width = 509
              Height = 72
              Align = alClient
              BevelOuter = bvNone
              ParentColor = True
              TabOrder = 2
              object Label9: TLabel
                Left = 0
                Top = 4
                Width = 4
                Height = 64
                Align = alLeft
                AutoSize = False
                Transparent = True
              end
              object Label10: TLabel
                Left = 505
                Top = 4
                Width = 4
                Height = 64
                Align = alRight
                AutoSize = False
                Transparent = True
              end
              object Label11: TLabel
                Left = 0
                Top = 0
                Width = 509
                Height = 4
                Align = alTop
                AutoSize = False
                Transparent = True
              end
              object Label12: TLabel
                Left = 0
                Top = 68
                Width = 509
                Height = 4
                Align = alBottom
                AutoSize = False
                Transparent = True
              end
              object pnlHeaderMemosHost: TPanel
                Left = 4
                Top = 4
                Width = 501
                Height = 64
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 0
                object memHeaderLeft: TMemo
                  Left = 0
                  Top = 0
                  Width = 167
                  Height = 64
                  Align = alClient
                  ScrollBars = ssVertical
                  TabOrder = 0
                  OnChange = MemoChange
                  OnEnter = MemoEnter
                  OnExit = MemoExit
                end
                object memHeaderCenter: TMemo
                  Tag = 1
                  Left = 167
                  Top = 0
                  Width = 167
                  Height = 64
                  Align = alRight
                  Alignment = taCenter
                  ScrollBars = ssVertical
                  TabOrder = 1
                  OnChange = MemoChange
                  OnEnter = MemoEnter
                  OnExit = MemoExit
                end
                object memHeaderRight: TMemo
                  Tag = 2
                  Left = 334
                  Top = 0
                  Width = 167
                  Height = 64
                  Align = alRight
                  Alignment = taRightJustify
                  ScrollBars = ssVertical
                  TabOrder = 2
                  OnChange = MemoChange
                  OnEnter = MemoEnter
                  OnExit = MemoExit
                end
              end
            end
            object pnlHeaderFont: TPanel
              Left = 0
              Top = 16
              Width = 509
              Height = 30
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 1
              object btnHeaderFont: TButton
                Left = 4
                Top = 3
                Width = 75
                Height = 26
                Caption = '&Font...'
                TabOrder = 0
                OnClick = btnHFFontClick
              end
              object edHeaderFontInfo: TEdit
                Left = 84
                Top = 6
                Width = 244
                Height = 21
                TabStop = False
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 1
              end
              object btnHeaderBackground: TBitBtn
                Left = 333
                Top = 3
                Width = 172
                Height = 26
                Caption = '&Background'
                TabOrder = 2
                OnClick = BackgroundClick
                Layout = blGlyphRight
              end
            end
            object pnlHeaderTitle: TPanel
              Left = 0
              Top = 0
              Width = 509
              Height = 16
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 0
              object bvlHeader: TBevel
                Left = 47
                Top = 6
                Width = 454
                Height = 5
                Shape = bsBottomLine
              end
              object lblHeader: TLabel
                Left = 6
                Top = 2
                Width = 35
                Height = 13
                Caption = 'Header'
              end
            end
          end
          object pnlFooter: TPanel
            Left = 0
            Top = 118
            Width = 509
            Height = 118
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 2
            object pnlFooterTitle: TPanel
              Left = 0
              Top = 0
              Width = 509
              Height = 16
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 0
              object bvlFooter: TBevel
                Left = 48
                Top = 8
                Width = 456
                Height = 4
                Shape = bsBottomLine
              end
              object lblFooter: TLabel
                Left = 6
                Top = 3
                Width = 32
                Height = 13
                Caption = 'Footer'
              end
            end
            object pnlFooterFont: TPanel
              Left = 0
              Top = 16
              Width = 509
              Height = 30
              Align = alTop
              BevelOuter = bvNone
              TabOrder = 1
              object btnFooterFont: TButton
                Tag = 1
                Left = 4
                Top = 3
                Width = 75
                Height = 26
                Caption = 'Fo&nt...'
                TabOrder = 0
                OnClick = btnHFFontClick
              end
              object edFooterFontInfo: TEdit
                Left = 83
                Top = 6
                Width = 244
                Height = 21
                TabStop = False
                Color = clBtnFace
                ReadOnly = True
                TabOrder = 1
              end
              object btnFooterBackGround: TBitBtn
                Tag = 1
                Left = 332
                Top = 3
                Width = 172
                Height = 26
                Caption = 'Back&ground'
                TabOrder = 2
                OnClick = BackgroundClick
                Layout = blGlyphRight
              end
            end
            object pnlFooterMemos: TPanel
              Left = 0
              Top = 46
              Width = 509
              Height = 72
              Align = alClient
              BevelOuter = bvNone
              ParentColor = True
              TabOrder = 2
              object Label14: TLabel
                Left = 0
                Top = 0
                Width = 509
                Height = 4
                Align = alTop
                AutoSize = False
                Transparent = True
              end
              object Label15: TLabel
                Left = 0
                Top = 68
                Width = 509
                Height = 4
                Align = alBottom
                AutoSize = False
                Transparent = True
              end
              object Label13: TLabel
                Left = 0
                Top = 4
                Width = 4
                Height = 64
                Align = alLeft
                AutoSize = False
                Transparent = True
              end
              object Label16: TLabel
                Left = 505
                Top = 4
                Width = 4
                Height = 64
                Align = alRight
                AutoSize = False
                Transparent = True
              end
              object pnlFooterMemosHost: TPanel
                Left = 4
                Top = 4
                Width = 501
                Height = 64
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 0
                object memFooterLeft: TMemo
                  Tag = 3
                  Left = 0
                  Top = 0
                  Width = 167
                  Height = 64
                  Align = alClient
                  ScrollBars = ssVertical
                  TabOrder = 0
                  OnChange = MemoChange
                  OnEnter = MemoEnter
                  OnExit = MemoExit
                end
                object memFooterCenter: TMemo
                  Tag = 4
                  Left = 167
                  Top = 0
                  Width = 167
                  Height = 64
                  Align = alRight
                  Alignment = taCenter
                  ScrollBars = ssVertical
                  TabOrder = 1
                  OnChange = MemoChange
                  OnEnter = MemoEnter
                  OnExit = MemoExit
                end
                object memFooterRight: TMemo
                  Tag = 5
                  Left = 334
                  Top = 0
                  Width = 167
                  Height = 64
                  Align = alRight
                  Alignment = taRightJustify
                  ScrollBars = ssVertical
                  TabOrder = 2
                  OnChange = MemoChange
                  OnEnter = MemoEnter
                  OnExit = MemoExit
                end
              end
            end
          end
          object pnlReverse: TPanel
            Left = 0
            Top = 303
            Width = 509
            Height = 28
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 3
            object chbxReverseOnEvenPages: TCheckBox
              Left = 7
              Top = 8
              Width = 264
              Height = 17
              Caption = '&Reverse on even pages'
              TabOrder = 0
              OnClick = chbxReverseOnEvenPagesClick
            end
          end
        end
      end
      object tshScaling: TTabSheet
        Caption = '&Scaling'
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 509
          Height = 337
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object bvlAdjustToHolder: TBevel
            Left = 35
            Top = 32
            Width = 75
            Height = 22
            Visible = False
          end
          object bvlFitToPageHolder: TBevel
            Left = 35
            Top = 84
            Width = 75
            Height = 22
            Visible = False
          end
          object lblPagesWideBy: TLabel
            Left = 119
            Top = 91
            Width = 77
            Height = 13
            Caption = 'page(s) &wide by'
          end
          object lblPercentOfNormalSize: TLabel
            Left = 118
            Top = 39
            Width = 67
            Height = 13
            Caption = '% normal size'
          end
          object bvlFitToPageTallHolder: TBevel
            Left = 261
            Top = 84
            Width = 75
            Height = 22
            Visible = False
          end
          object lblTall: TLabel
            Left = 343
            Top = 91
            Width = 14
            Height = 13
            Caption = '&tall'
          end
          object rbtnAdjustTo: TRadioButton
            Left = 12
            Top = 9
            Width = 150
            Height = 17
            Caption = '&Adjust To:'
            Checked = True
            TabOrder = 0
            TabStop = True
            OnClick = ScalingClick
          end
          object rbtnFitTo: TRadioButton
            Tag = 1
            Left = 12
            Top = 62
            Width = 150
            Height = 17
            Caption = '&Fit To:'
            TabOrder = 1
            OnClick = ScalingClick
          end
        end
      end
    end
  end
  object ilPrintOrders: TImageList
    BkColor = clWhite
    AllocBy = 2
    Height = 49
    Masked = False
    Width = 74
    Left = 210
    Top = 65534
    Bitmap = {
      494C01010200040004004A003100FFFFFF00FE00FFFFFFFFFFFFFFFF424D3600
      000000000000360000002800000028010000310000000100200000000000A0E2
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080000000000000000000000000000000
      0000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000000000000000000080800000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000000000000000000000000000000000008080
      00008080000080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF0000000000000000008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF000000
      00000000000080800000808000000000000000000000FFFFFF0080808000FFFF
      FF0000000000000000000000000000000000FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0000000000000000000000000000000000808000008080
      00008080000080800000FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080800000808000008080000000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000000000808000008080000080800000FFFFFF00FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000080800000808000008080
      0000808000008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000080800000808000008080000080800000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000008080000080800000808000008080
      000080800000808000008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      000080800000808000008080000080800000808000008080000080800000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF000000
      000000000000808000008080000080800000808000008080000080808000FFFF
      FF0000000000000000000000000000000000FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000808000008080000080800000808000008080
      000080800000808000008080000080800000808000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF008080800080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000000000808000008080000080800000808000008080000080800000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000008080000080800000808000008080000080800000808000008080
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      000080800000808000008080000080800000808000008080000080800000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF000000
      0000000000008080000080800000808000008080000080800000808000008080
      000080800000000000000000000000000000FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00000000000000000080800000808000008080
      0000808000008080000000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF000000
      0000000000000000000000000000FFFFFF0080808000FFFFFF00000000000000
      0000000000000000000080800000808000008080000080800000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00808000008080
      0000808000008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF00808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00808080008080
      0000808000008080000080800000FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      000080800000808000008080000080800000FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000008080000080800000808000008080000080808000808080008080
      8000808000008080000080800000808000008080800080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080000000000000000000808000008080
      0000808000008080000080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808000008080000080800000808000008080000080808000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080800000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008080000080800000808000008080000080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008080000080800000808000008080000080800000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00000000000000000080800000808000008080000080800000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080800000808000008080000080800000808000008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000080800000808000008080000080800000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000808000008080000080800000808000008080
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080000080800000808000008080
      0000FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080000080800000808000008080
      000080800000FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000008080000080800000808000008080000080808000808080008080
      8000808080008080800080808000808080008080800080800000808000008080
      000080800000FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080000000000000000000808000008080
      0000808000008080000080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080800000808000008080
      00008080000080800000FFFFFF00FFFFFF008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808000008080
      0000808000008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      0000808000008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      000080800000808000008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080800000808000008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF008080000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008080000080800000808000008080000080800000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000008080000080800000808000008080000080808000808080008080
      8000808080008080800080808000808080008080800080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080800000808000008080000080800000808080008080
      8000808080008080800080808000808080000000000000000000808000008080
      0000808000008080000080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF0080800000808000008080000080800000808000008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF008080800080800000808000008080000080800000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00808000008080000080800000808000008080
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF0000000000000000000000000000000000FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF008080000080800000808000008080
      000000000000FFFFFF0080808000FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF008080000080800000808000008080
      0000808000000000000000000000FFFFFF0080808000FFFFFF00000000000000
      00000000000000000000FFFFFF0080808000FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0080800000808000008080
      000080800000FFFFFF0080808000FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080800000808000008080
      00008080000080800000FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00808000008080
      0000808000008080000080808000FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00808000008080
      0000808000008080000080800000FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF0000000000000000000000000000000000FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000008080
      0000808000008080000080800000FFFFFF000000000000000000808000008080
      00008080000080800000FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF008080
      00008080000080800000808000008080000080808000FFFFFF00000000000000
      00000000000000000000FFFFFF0080808000FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00808000008080000080800000808000000000000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF008080000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008080000080800000808000008080000000000000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008080000080800000808000008080000080800000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF0000000000000000000000000000000000FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080800000808000008080000080800000808000008080
      00008080000080800000FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF0000000000000000000000000000000000FFFF
      FF0080808000FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF000000
      0000000000000000000080800000808000008080000080800000808000000000
      00000000000000000000FFFFFF0080808000FFFFFF0000000000000000000000
      000000000000FFFFFF0080808000FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000808000008080000080800000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000808000008080000080800000808000008080
      0000FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF0080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF008080000080800000808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080000080800000808000008080
      000080800000FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080000000
      0000000000008080000080800000808000008080000080808000808080008080
      8000808080008080800080808000808080008080800080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080800000808000008080
      0000808000008080000080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000000000000000000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00808000008080
      00008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF000000
      00000000000080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000008080
      00008080000080800000FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000FFFFFF00FFFFFF0080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      000080800000808000008080000080800000FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF0000000000000000000000000000000000FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      00008080000080800000FFFFFF0000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF0000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000FFFFFF00FFFFFF0080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000080800000808000008080
      0000808000008080000080800000808000008080000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080800000808000008080000080800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF0080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      80008080800080808000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000}
  end
  object ilPaperTypes: TImageList
    AllocBy = 8
    Left = 126
    Top = 65534
    Bitmap = {
      494C010103000800080010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFF7FFFFF0000FFFFFF7FFFFF0000
      FFFFFF7FE0030000FFFFFC1FFFFF0000FFFFFE3FFFBF0000FF7FFF7FFF1F0000
      FF7FFFFFFE0F0000FF7FE003FFBF0000FF7FFFFFFFBF0000FC1FFF7FFFBF0000
      FE3FFE3FFFBF0000FF7FFC1FFFFF0000FFFFFF7FFFFF0000E003FF7FFFFF0000
      FFFFFF7FFFFF0000FFFFFFFFFFFF000000000000000000000000000000000000
      000000000000}
  end
  object ilBins: TImageList
    Left = 154
    Top = 65534
    Bitmap = {
      494C010102000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000000000FF
      FF00000000000000000000000000FFFFFF008080800080808000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00000000000000
      0000FFFFFF008080800000000000808080000000000000000000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      800080808000808080008080800000000000000000000000000080808000FFFF
      FF00808080008080800000000000FFFFFF008080800080808000000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF00000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00808080000000000080808000FFFFFF00808080008080
      8000FFFFFF008080800000000000FFFFFF008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF00FFFF
      FF0000FFFF00808080008080800080808000808080000000000000000000FFFF
      FF0000FFFF00FFFFFF008080800000000000808080008080800080808000FFFF
      FF00808080008080800000000000FFFFFF008080800080808000808080008080
      8000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF0000FF
      FF00FFFFFF0080808000FFFFFF00FFFFFF008080800080808000808080000000
      0000FFFFFF0000FFFF00808080000000000080808000FFFFFF00808080008080
      800080808000FFFFFF00FFFFFF00FFFFFF008080800080808000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF00FFFF
      FF0000FFFF00808080008080800000FF00000000FF0000000000808080000000
      000000FFFF00FFFFFF008080800000000000808080008080800080808000FFFF
      FF00FFFFFF008080800080808000FFFFFF00FFFFFF00FFFFFF00808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000808080008080800000FF
      FF00FFFFFF0000FFFF00FFFFFF008080800080808000808080000000000000FF
      FF00FFFFFF0000FFFF0080808000000000000000000080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000FF000000FF00FFFFFF00FFFFFF00FFFF
      FF00808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0080808000FFFFFF00FFFFFF000000
      000000FFFF00FFFFFF008080800000000000000000000000000080808000FFFF
      FF00FFFFFF0000FF000000FF0000FFFFFF00FFFFFF00FFFFFF00808080008080
      800000000000FFFFFF0080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00808080008080800000FF
      FF00FFFFFF0000FFFF0080808000000000000000000000000000808080008080
      8000FFFFFF00FFFFFF00FFFFFF00FFFFFF008080800080808000FFFFFF00FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0080808000000000000000000000000000000000000000
      00008080800080808000FFFFFF0080808000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008080800000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0080808000808080008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000080808000808080008080800080808000808080008080
      8000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000008080800000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000808080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000080808000FFFFFF00FFFF
      FF00FFFFFF008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFE3F00000000E000E00F00000000
      C000800300000000800000010000000080000001000000008000000100000000
      8000000000000000800000000000000080008000000000008000800000000000
      8000C001000000008000F003000000008001FC0100000000C07FFF0000000000
      E0FFFF8100000000FFFFFFC70000000000000000000000000000000000000000
      000000000000}
  end
  object ilPapers: TImageList
    Left = 182
    Top = 65534
    Bitmap = {
      494C010102000400040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00808080008080800080808000808080008080800080808000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000080800000808000FFFFFF00FFFF
      FF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFF
      FF00FFFFFF0000FFFF0000808000008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000808000FFFFFF000080800000FF
      FF00FFFFFF00FFFFFF00FFFFFF000080800000808000FFFFFF00FFFFFF0000FF
      FF00FFFFFF0000808000FFFFFF00008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF0080808000808080008080800080808000808080008080800080808000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000080800000FFFF00FFFFFF000080
      8000FFFFFF0000FFFF0000808000FFFFFF00FFFFFF0000808000FFFFFF00FFFF
      FF000080800000FFFF00FFFFFF00008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000808000FFFFFF00FFFFFF0000FF
      FF000000000000808000FFFFFF0000FFFF00FFFFFF00FFFFFF00008080000000
      0000FFFFFF00FFFFFF00FFFFFF00008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF0080808000808080008080800080808000808080008080800080808000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000080800000FFFF00FFFFFF00FFFF
      FF000080800000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF000080
      8000FFFFFF0000FFFF00FFFFFF00008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000808000FFFFFF00FFFFFF000080
      8000FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FF
      FF0000808000FFFFFF00FFFFFF00008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF0080808000808080008080800080808000808080008080800080808000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000080800000FFFF0000808000FFFF
      FF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFF
      FF00FFFFFF0000808000FFFFFF00008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000080800000808000FFFFFF0000FF
      FF00FFFFFF00FFFFFF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF0000FF
      FF00FFFFFF00FFFFFF0000808000008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000080800000808000008080000080
      8000008080000080800000808000008080000080800000808000008080000080
      8000008080000080800000808000008080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00C001FFFF00000000C001FFFF00000000
      C001FFFF00000000C001000000000000C001000000000000C001000000000000
      C001000000000000C001081000000000C001000000000000C001000000000000
      C001000000000000C001000000000000C001000000000000C003FFFF00000000
      C007FFFF00000000C00FFFFF0000000000000000000000000000000000000000
      000000000000}
  end
end
