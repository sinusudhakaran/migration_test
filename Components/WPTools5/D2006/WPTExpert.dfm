object WPQuickConfig: TWPQuickConfig
  Left = 53
  Top = 142
  BorderStyle = bsDialog
  Caption = 'WPTools 5 Setup'
  ClientHeight = 436
  ClientWidth = 642
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  PixelsPerInch = 120
  TextHeight = 16
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 642
    Height = 395
    ActivePage = TabSheet1
    Align = alClient
    TabOrder = 0
    object TabSheet1: TTabSheet
      Caption = 'Quickconfig'
      ParentShowHint = False
      ShowHint = True
      object Bevel1: TBevel
        Left = 424
        Top = 40
        Width = 201
        Height = 161
      end
      object Label1: TLabel
        Left = 16
        Top = 208
        Width = 310
        Height = 16
        Caption = 'With '#39'Apply'#39' several properties are modified at once!'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -13
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
      end
      object Memo1: TMemo
        Left = 0
        Top = 240
        Width = 634
        Height = 124
        Align = alBottom
        Lines.Strings = (
          'applied property changes:')
        ScrollBars = ssVertical
        TabOrder = 0
      end
      object PreviewButton: TButton
        Left = 496
        Top = 208
        Width = 129
        Height = 25
        Caption = 'Preview Changes'
        TabOrder = 1
        OnClick = PreviewButtonClick
      end
      object ApplyButton: TButton
        Left = 360
        Top = 208
        Width = 129
        Height = 25
        Caption = 'Apply'
        TabOrder = 2
        OnClick = PreviewButtonClick
      end
      object ClassSelect: TRadioGroup
        Left = 16
        Top = 8
        Width = 401
        Height = 193
        Caption = ' Editor Class '
        Items.Strings = (
          'Standard Editor (plain text)'
          'Word-Processing Editor (Page Layout, WYSIWYG)'
          'Forms (EditFields)'
          'Full Page Preview (Readonly)'
          'Multi Page Preview (Readonly)')
        TabOrder = 3
      end
      object Scroll: TCheckBox
        Left = 432
        Top = 48
        Width = 153
        Height = 17
        Caption = 'Scrolling (V+H)'
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object HideMailMerge: TCheckBox
        Left = 432
        Top = 72
        Width = 169
        Height = 17
        Caption = 'Hide mailmerge fields'
        Checked = True
        State = cbChecked
        TabOrder = 5
      end
      object SupUndo: TCheckBox
        Left = 433
        Top = 96
        Width = 169
        Height = 17
        Caption = 'Support Undo/Redo'
        Checked = True
        State = cbChecked
        TabOrder = 6
      end
      object ImageDragDrop: TCheckBox
        Left = 433
        Top = 120
        Width = 184
        Height = 17
        Caption = 'Support Image Drag&&Drop'
        Checked = True
        State = cbChecked
        TabOrder = 7
      end
      object MovableImages: TCheckBox
        Left = 472
        Top = 144
        Width = 145
        Height = 17
        Caption = 'movable images'
        Checked = True
        State = cbChecked
        TabOrder = 8
      end
      object Extras: TCheckBox
        Left = 424
        Top = 16
        Width = 97
        Height = 17
        Caption = 'Extras:'
        TabOrder = 9
      end
      object DontAddExternalFontLeading: TCheckBox
        Left = 432
        Top = 168
        Width = 185
        Height = 17
        Hint = 
          'This FormatOptionEx makes the fonts shorter, the text will look ' +
          'more like in WPTools 4'
        Caption = 'wpDontAddExternalFontLeading'
        TabOrder = 10
      end
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 395
    Width = 642
    Height = 41
    Align = alBottom
    TabOrder = 1
    object Button3: TButton
      Left = 496
      Top = 8
      Width = 129
      Height = 25
      Cancel = True
      Caption = 'Close'
      TabOrder = 0
      OnClick = Button3Click
    end
  end
end
