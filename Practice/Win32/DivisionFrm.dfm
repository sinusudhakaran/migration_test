object DivisionDlg: TDivisionDlg
  Scaled = False
Left = 261
  Top = 187
  BorderStyle = bsSingle
  Caption = 'Set Up Divisions'
  ClientHeight = 372
  ClientWidth = 475
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  ParentFont = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  DesignSize = (
    475
    372)
  PixelsPerInch = 96
  TextHeight = 13
  object pnlButtons: TPanel
    Left = 0
    Top = 333
    Width = 475
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      475
      39)
    object btnCopy: TButton
      Left = 8
      Top = 8
      Width = 89
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = 'Copy From...'
      TabOrder = 2
      OnClick = btnCopyClick
    end
    object btnOK: TButton
      Left = 308
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
      Left = 392
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
  object gdDivisions: TtsGrid
    Left = 10
    Top = 8
    Width = 455
    Height = 321
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
    HeadingFont.Height = -13
    HeadingFont.Name = 'MS Sans Serif'
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
    OnCellEdit = gdDivisionsCellEdit
    OnCellLoaded = gdDivisionsCellLoaded
    OnMouseWheel = gdDivisionsMouseWheel
    ColProperties = <
      item
        DataCol = 1
        Col.Heading = 'Division'
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
