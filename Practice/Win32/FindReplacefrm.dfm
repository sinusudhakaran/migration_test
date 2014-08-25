object FindReplaceDlg: TFindReplaceDlg
  Left = 0
  Top = 0
  Caption = 'Find and Replace'
  ClientHeight = 314
  ClientWidth = 490
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  Scaled = False
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pBtn: TPanel
    Left = 0
    Top = 273
    Width = 490
    Height = 41
    Align = alBottom
    TabOrder = 1
    DesignSize = (
      490
      41)
    object btnCancel: TButton
      Left = 405
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
    object BtnOK: TButton
      Left = 324
      Top = 8
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'OK'
      TabOrder = 0
      OnClick = BtnOKClick
    end
  end
  object PCMain: TPageControl
    Left = 0
    Top = 0
    Width = 490
    Height = 273
    ActivePage = tsOptions
    Align = alClient
    TabOrder = 0
    object tsOptions: TTabSheet
      Caption = '&Options'
      DesignSize = (
        482
        245)
      object Label1: TLabel
        Left = 3
        Top = 32
        Width = 47
        Height = 13
        Caption = 'Find what'
      end
      object Label2: TLabel
        Left = 3
        Top = 62
        Width = 61
        Height = 13
        Caption = 'Replace with'
      end
      object EFind: TEdit
        Left = 80
        Top = 32
        Width = 315
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 20
        TabOrder = 0
      end
      object EReplace: TEdit
        Left = 80
        Top = 59
        Width = 315
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        MaxLength = 20
        TabOrder = 2
      end
      object btnFindChart: TBitBtn
        Left = 401
        Top = 27
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Chart'
        TabOrder = 1
        OnClick = btnFindChartClick
      end
      object btnReplaceChart: TBitBtn
        Left = 401
        Top = 58
        Width = 75
        Height = 25
        Anchors = [akTop, akRight]
        Caption = 'Chart'
        TabOrder = 3
        OnClick = btnReplaceChartClick
      end
      object GroupBox1: TGroupBox
        Left = 3
        Top = 104
        Width = 476
        Height = 129
        Caption = 'Dates'
        TabOrder = 4
        object rbSel: TRadioButton
          Left = 16
          Top = 25
          Width = 81
          Height = 17
          Caption = 'Sele&cted'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object rbAll: TRadioButton
          Left = 200
          Top = 25
          Width = 113
          Height = 17
          Caption = '&All'
          TabOrder = 1
        end
        inline DateSelector: TfmeDateSelector
          Left = 16
          Top = 48
          Width = 276
          Height = 70
          TabOrder = 2
          TabStop = True
          ExplicitLeft = 16
          ExplicitTop = 48
          inherited eDateFrom: TOvcPictureField
            Epoch = 0
            RangeHigh = {25600D00000000000000}
            RangeLow = {00000000000000000000}
          end
          inherited eDateTo: TOvcPictureField
            Epoch = 0
            RangeHigh = {25600D00000000000000}
            RangeLow = {00000000000000000000}
          end
          inherited OvcController1: TOvcController
            EntryCommands.TableList = (
              'Default'
              True
              ()
              'WordStar'
              False
              ()
              'Grid'
              False
              ())
          end
        end
      end
    end
    object tsAdvanced: TTabSheet
      Caption = 'A&dvanced'
      ImageIndex = 1
      inline AccountSelector: TfmeAccountSelector
        Left = 17
        Top = 16
        Width = 460
        Height = 188
        TabOrder = 0
        TabStop = True
        ExplicitLeft = 17
        ExplicitTop = 16
        inherited lblSelectAccounts: TLabel
          Width = 236
          Caption = 'Select the accounts that you wish to be included:'
          ExplicitWidth = 236
        end
      end
    end
  end
end
