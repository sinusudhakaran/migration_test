object dxfmPSReportProperties: TdxfmPSReportProperties
  Left = 357
  Top = 319
  ActiveControl = edName
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  BorderStyle = bsDialog
  Caption = 'Properties'
  ClientHeight = 477
  ClientWidth = 359
  Color = clBtnFace
  Constraints.MinHeight = 502
  Constraints.MinWidth = 367
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001001010100000000000280100001600000028000000100000002000
    00000100040000000000C0000000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    00000000000000000000000000000FFFFFFFFFF000000F00F00000F000000FFF
    FFFFFFF000000F00F00000F000000FFFFFFFFFF000000FFFFFFF0FF000000F00
    FFF080F000000F080F08080000440FF080808088804400000808088888440000
    008088888844000000088888804400000000000000440000000000000000FFFF
    0000000F0000000F0000000F0000000F0000000F0000000F0000000F0000000F
    0000000400000000000000000000F8000000FC000000FE040000FFFF0000}
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  object pcSummary: TPageControl
    Left = 5
    Top = 6
    Width = 349
    Height = 434
    ActivePage = tshSummary
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object tshSummary: TTabSheet
      Caption = 'Summary'
      object Image1: TImage
        Left = 10
        Top = 8
        Width = 32
        Height = 32
        Picture.Data = {
          07544269746D617076020000424D760200000000000076000000280000002000
          0000200000000100040000000000000200000000000000000000100000001000
          0000000000000000800000800000008080008000000080008000808000008080
          8000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
          FF00DDD777777777777777777777777777DDDD00000000000000000000000000
          07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF
          07DDDD0F88888888888888888888888F07DDDD0F8FFF8FFF8FFF8FFFF8FFFF8F
          07DDDD0F8FFF8FFF8FFF8FFFF8FFFF8F07DDDD0F88888888888888888888888F
          07DDDD0F8FFF8FFF8FFF8FFFF8FFFF8F07DDDD0F8FFF8FFF8FFF8FFFF8FFFF8F
          07DDDD0F88888888888888888888888F07DDDD0F8FFF8FFF8FFF8FFFF8FFFF8F
          07DDDD0F8FFF8FFF8FFF8FFFF8FFFF8F07DDDD0F88888888888888888888888F
          07DDDD0F8FFF8FFF8FFF8FFFF8FFFF8F07DDDD0F8FFF8FFF8FFF8FFFF8FFFF8F
          07DDDD0F88888888888888888888888F07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF
          07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF07DDDD0F0000FF7777777777FFFFFFFF
          07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF07DDDD0F0000FF7777777777FFFFFFFF
          07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF07DDDD0F0000FF7777777777FFFFFFFF
          07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF
          07DDDD0F77777777777777777777777F07DDDD0F7777777FFFFFFFFFFFFFFFFF
          07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF07DDDD0FFFFFFFFFFFFFFFFFFFFFFFFF
          07DDDD000000000000000000000000000DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD
          DDDD}
        Transparent = True
      end
      object Bevel1: TBevel
        Left = 8
        Top = 46
        Width = 320
        Height = 6
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object lblCreator: TLabel
        Left = 10
        Top = 80
        Width = 41
        Height = 13
        Caption = 'Creator:'
        FocusControl = edCreator
      end
      object lblCreationDate: TLabel
        Left = 10
        Top = 105
        Width = 71
        Height = 13
        Caption = 'Creation Date:'
        FocusControl = edCreationDate
      end
      object Bevel2: TBevel
        Left = 8
        Top = 142
        Width = 320
        Height = 6
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object edName: TEdit
        Left = 66
        Top = 16
        Width = 262
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        Text = 'edName'
      end
      object edCreator: TEdit
        Left = 112
        Top = 80
        Width = 215
        Height = 14
        TabStop = False
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        BorderStyle = bsNone
        Ctl3D = False
        ParentCtl3D = False
        ReadOnly = True
        TabOrder = 1
        Text = 'edCreator'
      end
      object edCreationDate: TEdit
        Left = 112
        Top = 105
        Width = 215
        Height = 14
        TabStop = False
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        BorderStyle = bsNone
        Ctl3D = False
        ParentCtl3D = False
        ReadOnly = True
        TabOrder = 2
        Text = 'edCreationDate'
      end
      object pcDescription: TPageControl
        Left = 10
        Top = 158
        Width = 319
        Height = 237
        ActivePage = tshPreview
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 3
        object tshDescription: TTabSheet
          Caption = '&Description'
          object memDescription: TMemo
            Left = 0
            Top = 0
            Width = 311
            Height = 209
            Align = alClient
            ScrollBars = ssBoth
            TabOrder = 0
          end
        end
        object tshPreview: TTabSheet
          Caption = '&Preview'
          ImageIndex = 1
          object bvlPreviewHost: TBevel
            Left = 0
            Top = 0
            Width = 311
            Height = 172
            Align = alTop
            Anchors = [akLeft, akTop, akRight, akBottom]
          end
          object btnPreview: TButton
            Left = 206
            Top = 180
            Width = 100
            Height = 23
            Anchors = [akRight, akBottom]
            Caption = 'Pre&view...'
            TabOrder = 0
            OnClick = PreviewClick
          end
        end
      end
    end
  end
  object btnOK: TButton
    Left = 116
    Top = 447
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 197
    Top = 447
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 279
    Top = 447
    Width = 75
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 3
  end
end
