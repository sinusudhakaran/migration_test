object frmImageColumnEditor: TfrmImageColumnEditor
  Left = 570
  Top = 11
  BorderStyle = bsDialog
  Caption = 'ExpressMasterView ImageColumn Items Editor'
  ClientHeight = 287
  ClientWidth = 418
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOk: TButton
    Left = 340
    Top = 230
    Width = 72
    Height = 22
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object ButtonCancel: TButton
    Left = 340
    Top = 258
    Width = 72
    Height = 22
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object ButtonAdd: TButton
    Left = 340
    Top = 6
    Width = 72
    Height = 22
    Caption = '&Add'
    TabOrder = 1
    OnClick = ButtonAddClick
  end
  object ButtonDelete: TButton
    Left = 340
    Top = 62
    Width = 72
    Height = 22
    Caption = '&Delete'
    TabOrder = 3
    OnClick = ButtonDeleteClick
  end
  object Grid: TStringGrid
    Left = 6
    Top = 6
    Width = 327
    Height = 275
    ColCount = 4
    DefaultRowHeight = 20
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goDrawFocusSelected, goEditing, goThumbTracking]
    TabOrder = 0
    OnDrawCell = GridDrawCell
    OnGetEditText = GridGetEditText
    OnKeyDown = GridKeyDown
    OnSelectCell = GridSelectCell
    OnSetEditText = GridSetEditText
    ColWidths = (
      37
      63
      67
      127)
  end
  object ButtonInsert: TButton
    Left = 340
    Top = 34
    Width = 72
    Height = 22
    Caption = '&Insert'
    TabOrder = 2
    OnClick = ButtonInsertClick
  end
end
