object cxfmStringsEditor: TcxfmStringsEditor
  Left = 370
  Top = 256
  ActiveControl = Memo1
  AutoScroll = False
  Caption = 'String List Editor'
  ClientHeight = 317
  ClientWidth = 412
  Color = clBtnFace
  Constraints.MinHeight = 200
  Constraints.MinWidth = 200
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnPaint = FormPaint
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 412
    Height = 281
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object GroupBox: TGroupBox
      Left = 4
      Top = 4
      Width = 404
      Height = 273
      Align = alClient
      TabOrder = 0
      object pnlClientTop: TPanel
        Left = 2
        Top = 15
        Width = 400
        Height = 19
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label1: TLabel
          Left = 9
          Top = 1
          Width = 32
          Height = 13
          Caption = 'Label1'
        end
      end
      object pnlClientClient: TPanel
        Left = 2
        Top = 34
        Width = 400
        Height = 237
        Align = alClient
        BevelOuter = bvNone
        BorderWidth = 5
        TabOrder = 1
        object Memo1: TcxMemo
          Left = 5
          Top = 5
          Align = alClient
          Lines.Strings = (
            'Memo1')
          Properties.OnChange = Memo1PropertiesChange
          TabOrder = 0
          Height = 227
          Width = 390
        end
      end
    end
  end
  object btnOK: TcxButton
    Left = 224
    Top = 286
    Width = 81
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TcxButton
    Left = 311
    Top = 286
    Width = 80
    Height = 23
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
