object frmcxStyleSheetsLoad: TfrmcxStyleSheetsLoad
  Left = 303
  Top = 129
  AutoScroll = False
  BorderIcons = [biSystemMenu]
  Caption = 'Predefined StyleSheets'
  ClientHeight = 329
  ClientWidth = 659
  Color = clBtnFace
  Constraints.MinHeight = 296
  Constraints.MinWidth = 315
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 294
    Width = 659
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel: TBevel
      Left = 0
      Top = 0
      Width = 659
      Height = 2
      Align = alTop
    end
    object btnLoad: TButton
      Left = 497
      Top = 8
      Width = 75
      Height = 23
      Anchors = [akRight, akBottom]
      Caption = 'Load'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnClose: TButton
      Left = 580
      Top = 8
      Width = 75
      Height = 23
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Close'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 659
    Height = 294
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 5
    TabOrder = 1
    object pnlStyles: TPanel
      Left = 5
      Top = 5
      Width = 297
      Height = 284
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object pnlStyleSheetClasses: TPanel
        Left = 0
        Top = 0
        Width = 297
        Height = 25
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object lbStyleSheetClass: TLabel
          Left = 3
          Top = 1
          Width = 94
          Height = 18
          AutoSize = False
          Caption = 'Style Sheet Class:'
          Layout = tlCenter
        end
        object cbStyleSheetClasses: TComboBox
          Left = 96
          Top = 0
          Width = 201
          Height = 21
          Style = csDropDownList
          Anchors = [akTop, akRight]
          DropDownCount = 10
          ItemHeight = 13
          TabOrder = 0
        end
      end
      object lbStyleSheets: TListBox
        Left = 0
        Top = 25
        Width = 297
        Height = 259
        Align = alClient
        ItemHeight = 13
        MultiSelect = True
        TabOrder = 1
      end
    end
    object pnlPreview: TPanel
      Left = 302
      Top = 5
      Width = 352
      Height = 284
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 5
        Height = 284
        Align = alLeft
        BevelOuter = bvNone
        TabOrder = 0
      end
      object Panel1: TPanel
        Left = 5
        Top = 0
        Width = 347
        Height = 284
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object Panel3: TPanel
          Left = 0
          Top = 0
          Width = 347
          Height = 25
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          TabOrder = 0
          object lbPreview: TLabel
            Left = 0
            Top = 0
            Width = 61
            Height = 21
            AutoSize = False
            Caption = 'Preview'
            Layout = tlCenter
          end
        end
        object pnlPreviewClient: TPanel
          Left = 0
          Top = 25
          Width = 347
          Height = 259
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
        end
      end
    end
  end
end
