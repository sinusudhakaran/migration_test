object frmcxStyleSheetEditor: TfrmcxStyleSheetEditor
  Left = 377
  Top = 147
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'StyleSheet Editor'
  ClientHeight = 338
  ClientWidth = 319
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 303
    Width = 319
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel: TBevel
      Left = 0
      Top = 0
      Width = 319
      Height = 2
      Align = alTop
    end
    object pnlButtons: TPanel
      Left = 150
      Top = 2
      Width = 169
      Height = 33
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 0
      object btnOK: TButton
        Left = 7
        Top = 4
        Width = 75
        Height = 25
        Caption = 'OK'
        Default = True
        ModalResult = 1
        TabOrder = 0
      end
      object bntCancel: TButton
        Left = 88
        Top = 4
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 1
      end
    end
  end
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 319
    Height = 303
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 1
    object pnlStyles: TPanel
      Left = 4
      Top = 4
      Width = 163
      Height = 295
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object pnlStylesCaption: TPanel
        Left = 0
        Top = 0
        Width = 163
        Height = 21
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = 'Styles'
        TabOrder = 0
      end
      object pnlStylesClient: TPanel
        Left = 0
        Top = 21
        Width = 163
        Height = 274
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object lbStyles: TListBox
          Left = 0
          Top = 0
          Width = 163
          Height = 186
          Style = lbOwnerDrawVariable
          Align = alClient
          ItemHeight = 16
          MultiSelect = True
          TabOrder = 0
          OnClick = lbStylesClick
          OnDrawItem = lbStylesDrawItem
          OnMeasureItem = lbStylesMeasureItem
        end
        object pnlStylesButtons: TPanel
          Left = 0
          Top = 186
          Width = 163
          Height = 88
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 1
          object cbColor: TCheckBox
            Left = 35
            Top = 33
            Width = 119
            Height = 25
            Caption = '&Color'
            TabOrder = 0
            OnClick = cbClick
          end
          object btnBitmap: TButton
            Left = 2
            Top = 4
            Width = 25
            Height = 25
            Caption = '...'
            TabOrder = 1
            OnClick = btnBitmapClick
          end
          object btnColor1: TButton
            Left = 2
            Top = 33
            Width = 25
            Height = 25
            Caption = '...'
            TabOrder = 2
            OnClick = btnColor1Click
          end
          object btnFont1: TButton
            Left = 2
            Top = 62
            Width = 25
            Height = 25
            Caption = '...'
            TabOrder = 3
            OnClick = btnFont1Click
          end
          object cbFont: TCheckBox
            Left = 35
            Top = 62
            Width = 119
            Height = 25
            Caption = '&Font'
            TabOrder = 4
            OnClick = cbClick
          end
          object cbBitmap: TCheckBox
            Left = 35
            Top = 4
            Width = 117
            Height = 25
            Caption = '&Bitmap'
            TabOrder = 5
            OnClick = cbClick
          end
        end
      end
    end
    object pnlPreview: TPanel
      Left = 171
      Top = 4
      Width = 144
      Height = 295
      Align = alRight
      Anchors = [akLeft, akTop, akRight, akBottom]
      BevelOuter = bvNone
      TabOrder = 1
      object pnlPreviewCaption: TPanel
        Left = 0
        Top = 0
        Width = 144
        Height = 21
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        Caption = 'Preview'
        TabOrder = 0
      end
      object pnlPreviewClient: TPanel
        Left = 0
        Top = 21
        Width = 144
        Height = 274
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
      end
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 76
    Top = 28
  end
  object ColorDialog: TColorDialog
    Left = 44
    Top = 28
  end
end
