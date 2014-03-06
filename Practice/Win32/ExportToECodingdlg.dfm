object dlgExportToECoding: TdlgExportToECoding
  Scaled = False
Left = 344
  Top = 154
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Export Entries to eCoding File'
  ClientHeight = 546
  ClientWidth = 546
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShortCut = FormShortCut
  OnShow = FormShow
  DesignSize = (
    546
    546)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOk: TButton
    Left = 382
    Top = 516
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    Default = True
    TabOrder = 0
    OnClick = btnOkClick
  end
  object btnCancel: TButton
    Left = 462
    Top = 516
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
    OnClick = btnCancelClick
  end
  object pcMain: TPageControl
    Left = 0
    Top = 0
    Width = 537
    Height = 510
    ActivePage = tsOptions
    TabOrder = 2
    object tsOptions: TTabSheet
      Caption = 'Options'
      ImageIndex = 1
      object GroupBox1: TGroupBox
        Left = 8
        Top = 89
        Width = 512
        Height = 334
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        TabOrder = 1
        inline ecExportOptions: TfmeECodingExport
          Left = 2
          Top = 5
          Width = 508
          Height = 329
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          TabOrder = 0
          TabStop = True
          ExplicitLeft = 2
          ExplicitTop = 5
          ExplicitWidth = 508
          ExplicitHeight = 329
          inherited edtPassword: TEdit
            Height = 21
            ExplicitHeight = 21
          end
          inherited edtConfirm: TEdit
            Height = 21
            ExplicitHeight = 21
          end
        end
      end
      object GroupBox2: TGroupBox
        Left = 8
        Top = 1
        Width = 512
        Height = 86
        TabOrder = 0
        object lblData: TLabel
          Left = 12
          Top = 9
          Width = 477
          Height = 16
          AutoSize = False
          Caption = 'lblData'
        end
        inline ecDateSelector: TfmeDateSelector
          Left = 12
          Top = 21
          Width = 477
          Height = 61
          TabOrder = 0
          TabStop = True
          ExplicitLeft = 12
          ExplicitTop = 21
          ExplicitWidth = 477
          ExplicitHeight = 61
          inherited btnPrev: TSpeedButton
            Left = 181
            Top = 7
            ExplicitLeft = 181
            ExplicitTop = 7
          end
          inherited btnNext: TSpeedButton
            Left = 205
            Top = 7
            ExplicitLeft = 205
            ExplicitTop = 7
          end
          inherited btnQuik: TSpeedButton
            Left = 232
            Top = 7
            ExplicitLeft = 232
            ExplicitTop = 7
          end
          inherited eDateFrom: TOvcPictureField
            Left = 70
            Epoch = 0
            ExplicitLeft = 70
            RangeHigh = {25600D00000000000000}
            RangeLow = {00000000000000000000}
          end
          inherited eDateTo: TOvcPictureField
            Left = 70
            Epoch = 0
            ExplicitLeft = 70
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
      object GbFilename: TGroupBox
        Left = 8
        Top = 426
        Width = 512
        Height = 50
        TabOrder = 2
        object Label6: TLabel
          Left = 12
          Top = 20
          Width = 42
          Height = 13
          Caption = 'File&name'
          FocusControl = eTo
        end
        object btnToFolder: TSpeedButton
          Left = 474
          Top = 16
          Width = 25
          Height = 24
          Hint = 'Click to Select a Folder'
          OnClick = btnToFolderClick
        end
        object eTo: TEdit
          Left = 81
          Top = 17
          Width = 387
          Height = 19
          Ctl3D = False
          ParentCtl3D = False
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = eToChange
        end
      end
    end
    object tsAdvanced: TTabSheet
      Caption = 'Advanced'
      inline fmeAccountSelector1: TfmeAccountSelector
        Left = 0
        Top = 16
        Width = 529
        Height = 177
        TabOrder = 0
        TabStop = True
        ExplicitTop = 16
        ExplicitWidth = 529
        ExplicitHeight = 177
        inherited lblSelectAccounts: TLabel
          Left = 8
          Width = 310
          Caption = 
            'Select the bank accounts that you wish to be included in this fi' +
            'le:'
          ExplicitLeft = 8
          ExplicitWidth = 310
        end
        inherited chkAccounts: TCheckListBox
          Left = 8
          Width = 423
          Height = 145
          Hint = 'Enable bank accounts to include in the Report'
          ParentShowHint = False
          ShowHint = True
          ExplicitLeft = 8
          ExplicitWidth = 423
          ExplicitHeight = 145
        end
        inherited btnSelectAllAccounts: TButton
          Left = 441
          Hint = 'Enable all bank accounts'
          ParentShowHint = False
          ShowHint = True
          ExplicitLeft = 441
        end
        inherited btnClearAllAccounts: TButton
          Left = 441
          Top = 68
          Hint = 'Disable all bank accounts'
          ExplicitLeft = 441
          ExplicitTop = 68
        end
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Filter = 'All Files (*.*)|*.*'
    Title = 'Save Entries To'
    Left = 368
    Top = 392
  end
end
