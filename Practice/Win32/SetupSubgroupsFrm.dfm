object frmSetupSubGroups: TfrmSetupSubGroups
  Scaled = False
Left = 368
  Top = 148
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Set Up Sub-groups'
  ClientHeight = 451
  ClientWidth = 492
  Color = clBtnFace
  Constraints.MinHeight = 400
  Constraints.MinWidth = 500
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    492
    451)
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 412
    Width = 492
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      492
      39)
    object btnCopy: TButton
      Left = 12
      Top = 8
      Width = 89
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Copy From...'
      TabOrder = 2
      OnClick = btnCopyClick
    end
    object btnOK: TButton
      Left = 320
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Caption = '&OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
    end
    object btnCancel: TButton
      Left = 404
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object gdSubGroups: TtsGrid
    Left = 13
    Top = 9
    Width = 464
    Height = 400
    Anchors = [akLeft, akTop, akRight, akBottom]
    CheckBoxStyle = stCheck
    ColMoving = False
    Cols = 2
    ColSelectMode = csNone
    Ctl3D = False
    DefaultColWidth = 100
    DefaultRowHeight = 20
    ExportDelimiter = ','
    HeadingFont.Charset = DEFAULT_CHARSET
    HeadingFont.Color = clWindowText
    HeadingFont.Height = -11
    HeadingFont.Name = 'Tahoma'
    HeadingFont.Style = []
    HeadingHeight = 20
    HeadingParentFont = False
    ParentCtl3D = False
    ParentShowHint = False
    ResizeRows = rrNone
    RowBarOn = False
    RowMoving = False
    Rows = 100
    RowSelectMode = rsNone
    ShowHint = False
    TabOrder = 1
    Version = '2.20.26'
    XMLExport.Version = '1.0'
    XMLExport.DataPacketVersion = '2.0'
    OnCellEdit = gdSubGroupsCellEdit
    OnCellLoaded = gdSubGroupsCellLoaded
    OnMouseWheel = gdSubGroupsMouseWheel
    ColProperties = <
      item
        DataCol = 1
        Col.Heading = 'Sub-group'
        Col.ReadOnly = True
        Col.Width = 117
      end
      item
        DataCol = 2
        Col.Heading = 'Description'
        Col.MaxLength = 60
        Col.Width = 318
      end>
  end
end
