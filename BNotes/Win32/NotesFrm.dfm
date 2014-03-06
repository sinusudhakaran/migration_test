inherited frmNotes: TfrmNotes
  Left = 393
  Top = 206
  BorderIcons = [biSystemMenu]
  Caption = 'Notes'
  ClientHeight = 266
  ClientWidth = 392
  Constraints.MinHeight = 180
  Constraints.MinWidth = 360
  FormStyle = fsStayOnTop
  OldCreateOrder = True
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 16
  object memNotes: TMemo
    Left = 4
    Top = 4
    Width = 385
    Height = 229
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object pnlFooter: TPanel
    Left = 0
    Top = 236
    Width = 392
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      392
      30)
    object chkShowNotesOnOpen: TCheckBox
      Left = 4
      Top = 8
      Width = 257
      Height = 17
      Caption = 'Show comments when opening this file'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
    object btnClose: TButton
      Left = 316
      Top = 4
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&Close'
      ModalResult = 2
      TabOrder = 1
      OnClick = btnCloseClick
    end
  end
end
