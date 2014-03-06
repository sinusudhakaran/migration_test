object AdoptOrSyncFrm: TAdoptOrSyncFrm
  Scaled = False
Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Adopt or Synchronise?'
  ClientHeight = 224
  ClientWidth = 497
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  DesignSize = (
    497
    224)
  PixelsPerInch = 96
  TextHeight = 16
  object Label1: TLabel
    Left = 24
    Top = 24
    Width = 462
    Height = 145
    AutoSize = False
    Caption = 
      'This client has been downloading transactions themselves but the' +
      ' client file currently belongs to another Practice.'#13#13'Click '#39'Adop' +
      't'#39' to allow them to keep downloading their own transactions and ' +
      'associate them with your practice, or'#13#13'Click '#39'Synchronise'#39' to re' +
      'trieve the transactions on their behalf and associate them with ' +
      'your practice.'
    WordWrap = True
  end
  object btnAdopt: TButton
    Left = 140
    Top = 191
    Width = 121
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Adopt'
    ModalResult = 1
    TabOrder = 0
    OnClick = btnAdoptClick
  end
  object btnSync: TButton
    Left = 276
    Top = 191
    Width = 121
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Synchronise'
    TabOrder = 1
    OnClick = btnSyncClick
  end
  object btnCancel: TButton
    Left = 414
    Top = 191
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
