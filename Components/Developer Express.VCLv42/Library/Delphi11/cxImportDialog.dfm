object cxImportDialogForm: TcxImportDialogForm
  Left = 288
  Top = 203
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Import'
  ClientHeight = 367
  ClientWidth = 546
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 141
    Top = 0
    Width = 113
    Height = 367
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object Button1: TButton
      Left = 12
      Top = 8
      Width = 89
      Height = 25
      Caption = 'Import'
      Enabled = False
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 12
      Top = 40
      Width = 89
      Height = 25
      Cancel = True
      Caption = 'Close'
      ModalResult = 2
      TabOrder = 1
    end
    object Button3: TButton
      Left = 12
      Top = 332
      Width = 89
      Height = 25
      Caption = 'Options >>'
      TabOrder = 2
      OnClick = Button3Click
    end
  end
  object ListBox1: TListBox
    Left = 0
    Top = 0
    Width = 141
    Height = 367
    Align = alLeft
    ItemHeight = 13
    TabOrder = 1
    OnClick = ListBox1Click
    OnDblClick = ListBox1DblClick
  end
  object StylesPane: TPanel
    Left = 254
    Top = 0
    Width = 292
    Height = 367
    Align = alClient
    TabOrder = 2
    object PageControl1: TPageControl
      Left = 1
      Top = 1
      Width = 290
      Height = 365
      ActivePage = TabSheet2
      Align = alClient
      TabOrder = 0
      TabStop = False
      object TabSheet2: TTabSheet
        Caption = 'Styles'
        ImageIndex = 1
        OnShow = TabSheet2Show
        object GroupBox2: TGroupBox
          Left = 0
          Top = 36
          Width = 282
          Height = 301
          Align = alBottom
          Caption = ' StyleRepository Options '
          TabOrder = 1
          object RadioButton1: TRadioButton
            Left = 16
            Top = 28
            Width = 169
            Height = 17
            Caption = 'Create New StyleRepository'
            Checked = True
            TabOrder = 0
            TabStop = True
            OnClick = RadioButton1Click
          end
          object RadioButton2: TRadioButton
            Left = 16
            Top = 100
            Width = 173
            Height = 17
            Caption = 'Use Existing StyleRepository'
            TabOrder = 2
            OnClick = RadioButton2Click
          end
          object Edit1: TEdit
            Left = 36
            Top = 52
            Width = 229
            Height = 21
            TabOrder = 1
          end
          object ComboBox1: TComboBox
            Left = 36
            Top = 124
            Width = 229
            Height = 21
            Style = csDropDownList
            Color = clBtnFace
            Enabled = False
            ItemHeight = 13
            TabOrder = 3
          end
        end
        object cbImportStyles: TCheckBox
          Left = 4
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Import Styles'
          Checked = True
          State = cbChecked
          TabOrder = 0
          OnClick = cbImportStylesClick
        end
      end
    end
  end
end
