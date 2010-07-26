object cxGridViewLayoutEditor: TcxGridViewLayoutEditor
  Left = 350
  Top = 204
  BorderIcons = [biSystemMenu]
  Caption = 'Layout and Data Editor'
  ClientHeight = 466
  ClientWidth = 692
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TPanel
    Left = 0
    Top = 432
    Width = 692
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object pnlButtons: TPanel
      Left = 523
      Top = 0
      Width = 169
      Height = 34
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 2
      object btnOK: TcxButton
        Left = 4
        Top = 5
        Width = 75
        Height = 24
        Caption = 'OK'
        ModalResult = 1
        TabOrder = 0
      end
      object btnCancel: TcxButton
        Left = 89
        Top = 5
        Width = 75
        Height = 24
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 1
      end
    end
    object pnlLayoutCustomization: TPanel
      Left = 0
      Top = 0
      Width = 153
      Height = 34
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object btnLayoutCustomization: TcxButton
        Left = 8
        Top = 5
        Width = 134
        Height = 24
        TabOrder = 0
        OnClick = btnLayoutCustomizationClick
      end
    end
    object pnlSaveOptions: TPanel
      Left = 153
      Top = 0
      Width = 192
      Height = 34
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object chbSaveLayout: TcxCheckBox
        Left = 11
        Top = 7
        Caption = 'Save layout'
        State = cbsChecked
        TabOrder = 0
        Width = 81
      end
      object chbSaveData: TcxCheckBox
        Left = 107
        Top = 7
        Caption = 'Save data'
        State = cbsChecked
        TabOrder = 1
        Width = 81
      end
    end
  end
  object pnlClient: TPanel
    Left = 0
    Top = 0
    Width = 692
    Height = 432
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 3
    Constraints.MinHeight = 200
    Constraints.MinWidth = 300
    TabOrder = 1
  end
  object pmGrid: TcxGridPopupMenu
    PopupMenus = <>
    Left = 400
    Top = 319
  end
end
