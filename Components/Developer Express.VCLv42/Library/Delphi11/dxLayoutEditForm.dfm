object LayoutEditForm: TLayoutEditForm
  Left = 233
  Top = 209
  BorderStyle = bsDialog
  Caption = 'LayoutEditForm'
  ClientHeight = 88
  ClientWidth = 282
  Color = clBtnFace
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object LayoutControl: TdxLayoutControl
    Left = 0
    Top = 0
    Width = 282
    Height = 88
    Align = alClient
    TabOrder = 0
    TabStop = False
    AutoContentSizes = [acsWidth]
    object edMain: TEdit
      Left = 12
      Top = 30
      Width = 121
      Height = 17
      BorderStyle = bsNone
      TabOrder = 0
      Text = 'edMain'
    end
    object btnOK: TButton
      Left = 116
      Top = 55
      Width = 75
      Height = 23
      Caption = 'btnOK'
      Default = True
      ModalResult = 1
      TabOrder = 1
    end
    object btnCancel: TButton
      Left = 197
      Top = 55
      Width = 75
      Height = 23
      Cancel = True
      Caption = 'btnCancel'
      ModalResult = 2
      TabOrder = 2
    end
    object TdxLayoutGroup
      ShowCaption = False
      Hidden = True
      ShowBorder = False
      object LayoutControlItemEdit: TdxLayoutItem
        Caption = 'Edit1'
        CaptionOptions.Layout = clTop
        Control = edMain
      end
      object dxLayoutControl1Group1: TdxLayoutGroup
        AutoAligns = [aaVertical]
        AlignHorz = ahRight
        ShowCaption = False
        LayoutDirection = ldHorizontal
        ShowBorder = False
        object dxLayoutControl1Item2: TdxLayoutItem
          Caption = 'Button1'
          ShowCaption = False
          Control = btnOK
          ControlOptions.ShowBorder = False
        end
        object dxLayoutControl1Item3: TdxLayoutItem
          Caption = 'Button2'
          ShowCaption = False
          Control = btnCancel
          ControlOptions.ShowBorder = False
        end
      end
    end
  end
end
