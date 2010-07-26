object dxOCReportLinkDesignWindow: TdxOCReportLinkDesignWindow
  Left = 518
  Top = 415
  ActiveControl = chbxFullExpand
  BorderStyle = bsDialog
  Caption = 'Report Designer'
  ClientHeight = 293
  ClientWidth = 552
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl1: TPageControl
    Left = 4
    Top = 4
    Width = 544
    Height = 254
    ActivePage = tshOptions
    MultiLine = True
    TabOrder = 0
    OnChange = PageControl1Change
    object tshOptions: TTabSheet
      Caption = '&Options'
      object pnlOptions: TPanel
        Left = 0
        Top = 0
        Width = 536
        Height = 226
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object lblPreview: TLabel
          Left = 241
          Top = 2
          Width = 38
          Height = 13
          Caption = 'Preview'
        end
        object chbxFullExpand: TCheckBox
          Left = 17
          Top = 10
          Width = 216
          Height = 17
          Caption = 'Full &Expand'
          TabOrder = 0
          OnClick = chbxFullExpandClick
        end
        object gbxTransparent: TGroupBox
          Left = 5
          Top = 43
          Width = 231
          Height = 56
          Caption = '  '
          TabOrder = 2
          object lblColor: TLabel
            Left = 7
            Top = 26
            Width = 35
            Height = 13
            Caption = 'Co&lor : '
            OnClick = lblColorClick
          end
          object bvlColorHolder: TBevel
            Left = 86
            Top = 22
            Width = 138
            Height = 21
            Visible = False
          end
        end
        object chbxTransparent: TCheckBox
          Left = 17
          Top = 41
          Width = 15
          Height = 17
          TabOrder = 1
          OnClick = chbxTransparentClick
        end
        object gbxBorder: TGroupBox
          Left = 5
          Top = 109
          Width = 231
          Height = 56
          Caption = '      '
          TabOrder = 4
          object lblGridLinesColor: TLabel
            Left = 7
            Top = 26
            Width = 67
            Height = 13
            Caption = '&Border Color: '
            OnClick = lblColorClick
          end
          object bvlLineColorHolder: TBevel
            Left = 86
            Top = 22
            Width = 138
            Height = 21
            Visible = False
          end
        end
        object chbxDrawBorder: TCheckBox
          Left = 17
          Top = 107
          Width = 15
          Height = 17
          TabOrder = 3
          OnClick = chbxDrawBorderClick
        end
        object stTransparent: TStaticText
          Left = 32
          Top = 42
          Width = 76
          Height = 17
          Caption = ' &Transparent '
          FocusControl = chbxTransparent
          TabOrder = 5
          OnClick = stTransparentClick
        end
        object stDrawBorder: TStaticText
          Left = 32
          Top = 108
          Width = 70
          Height = 17
          Caption = ' Draw Border '
          FocusControl = chbxDrawBorder
          TabOrder = 6
          OnClick = stDrawBorderClick
        end
      end
    end
  end
  object pnlPreview: TPanel
    Left = 250
    Top = 46
    Width = 290
    Height = 201
    BevelInner = bvLowered
    BevelOuter = bvNone
    Color = clWindow
    TabOrder = 1
    object ocPreview: TdxOrgChart
      Left = 6
      Top = 5
      Width = 279
      Height = 192
      DefaultImageAlign = iaLT
      BorderStyle = bsNone
      Options = [ocDblClick, ocEdit, ocCanDrag, ocShowDrag, ocRect3D]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Visible = False
      Items = {
        000001005A000000FFFFFF1F01000200011600436F72706F7261746520486561
        647175617274657273020050000000FFFFFF1F0100010001130053616C657320
        616E64204D61726B6574696E67010050000000FFFFFF1F010003000117004669
        656C64204F66666963653A2043616E6164610D0A09000050000000FFFFFF1F01
        000000010B00456E67696E656572696E670000}
    end
  end
end
