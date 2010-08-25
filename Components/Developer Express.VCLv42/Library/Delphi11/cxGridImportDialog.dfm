object ImportDialog: TImportDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Import'
  ClientHeight = 368
  ClientWidth = 694
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 237
    Top = 0
    Width = 80
    Height = 368
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object btnImport: TcxButton
      Left = 0
      Top = 8
      Width = 80
      Height = 24
      Caption = 'Import ->'
      Enabled = False
      TabOrder = 0
      OnClick = btnImportClick
    end
    object btnClose: TcxButton
      Left = 0
      Top = 40
      Width = 80
      Height = 24
      Cancel = True
      Caption = 'Close'
      TabOrder = 1
      OnClick = btnCloseClick
    end
  end
  object Panel2: TPanel
    Left = 317
    Top = 0
    Width = 377
    Height = 368
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 2
    object Panel6: TPanel
      Left = 8
      Top = 8
      Width = 361
      Height = 352
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 1
      Color = clBtnShadow
      TabOrder = 0
      object PageControl1: TcxPageControl
        Left = 1
        Top = 1
        Width = 359
        Height = 350
        ActivePage = TabSheet1
        Align = alClient
        Color = clBtnFace
        ParentColor = False
        TabOrder = 0
        ClientRectBottom = 350
        ClientRectRight = 359
        ClientRectTop = 24
        object TabSheet1: TcxTabSheet
          BorderWidth = 8
          Caption = '  Levels  '
          Color = clBtnFace
          ParentColor = False
          object cbDeleteAllSublevels: TcxCheckBox
            Left = 0
            Top = 289
            Align = alBottom
            Caption = 'Delete All Sublevels'
            State = cbsChecked
            TabOrder = 3
            Width = 343
          end
          object Panel7: TPanel
            Left = 0
            Top = 0
            Width = 343
            Height = 13
            Align = alTop
            AutoSize = True
            BevelOuter = bvNone
            TabOrder = 0
            object lblLevelName: TLabel
              Left = 89
              Top = 0
              Width = 254
              Height = 13
              Align = alClient
            end
            object Label1: TLabel
              Left = 0
              Top = 0
              Width = 89
              Height = 13
              Align = alLeft
              Caption = 'Destination Level: '
            end
          end
          object pnlStructureControlSite: TPanel
            Left = 0
            Top = 21
            Width = 343
            Height = 260
            Align = alClient
            BevelOuter = bvNone
            BorderWidth = 1
            Color = clBtnShadow
            TabOrder = 1
          end
          object Panel3: TPanel
            Left = 0
            Top = 13
            Width = 343
            Height = 8
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 2
          end
          object Panel8: TPanel
            Left = 0
            Top = 281
            Width = 343
            Height = 8
            Align = alBottom
            BevelOuter = bvNone
            TabOrder = 4
          end
        end
        object TabSheet2: TcxTabSheet
          BorderWidth = 8
          Caption = '  Styles  '
          Color = clBtnFace
          ImageIndex = 1
          ParentColor = False
          object cbImportStyles: TcxCheckBox
            Left = 0
            Top = 0
            Align = alTop
            Caption = 'Import Styles'
            State = cbsChecked
            TabOrder = 0
            OnClick = cbImportStylesClick
            Width = 343
          end
          object rbCreateNewStyleRepository: TcxRadioButton
            Left = 12
            Top = 29
            Width = 169
            Height = 17
            Caption = 'Create New StyleRepository'
            Checked = True
            TabOrder = 1
            TabStop = True
            OnClick = rbStyleRepositoryClick
          end
          object rbUseExistingStyleRepository: TcxRadioButton
            Left = 12
            Top = 87
            Width = 173
            Height = 17
            Caption = 'Use Existing StyleRepository'
            TabOrder = 3
            TabStop = True
            OnClick = rbStyleRepositoryClick
          end
          object edNewStyleRepository: TcxTextEdit
            Left = 36
            Top = 52
            TabOrder = 2
            Width = 290
          end
          object cbStyleRepositories: TcxComboBox
            Left = 36
            Top = 110
            Properties.DropDownListStyle = lsFixedList
            TabOrder = 4
            Width = 290
          end
        end
      end
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 0
    Width = 237
    Height = 368
    Align = alLeft
    BevelOuter = bvNone
    BorderWidth = 8
    TabOrder = 0
    object Panel5: TPanel
      Left = 8
      Top = 8
      Width = 221
      Height = 352
      Align = alClient
      BevelOuter = bvNone
      BorderWidth = 1
      Color = clBtnShadow
      TabOrder = 0
      object lbComponentsForImport: TListBox
        Left = 1
        Top = 1
        Width = 219
        Height = 350
        Style = lbOwnerDrawVariable
        Align = alClient
        BorderStyle = bsNone
        ItemHeight = 13
        TabOrder = 0
        OnClick = lbComponentsForImportClick
        OnDblClick = lbComponentsForImportDblClick
        OnMeasureItem = lbComponentsForImportMeasureItem
      end
    end
  end
end
