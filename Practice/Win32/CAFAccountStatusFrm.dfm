object frmCAFAccountStatus: TfrmCAFAccountStatus
  Left = 0
  Top = 0
  ActiveControl = cmbAccountFilter
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Account Status'
  ClientHeight = 481
  ClientWidth = 1013
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  DesignSize = (
    1013
    481)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 372
    Height = 13
    Caption = 
      'The following Bank Accounts have been submitted to BankLink for ' +
      'processing.'
  end
  object Label2: TLabel
    Left = 8
    Top = 41
    Width = 70
    Height = 13
    Caption = 'Account Filter:'
  end
  object lvAccountStatus: TVirtualStringTree
    Left = 8
    Top = 72
    Width = 997
    Height = 343
    Anchors = [akLeft, akTop, akRight, akBottom]
    ButtonStyle = bsTriangle
    Header.AutoSizeIndex = 0
    Header.Font.Charset = DEFAULT_CHARSET
    Header.Font.Color = clWindowText
    Header.Font.Height = -11
    Header.Font.Name = 'Tahoma'
    Header.Font.Style = []
    Header.Options = [hoColumnResize, hoDrag, hoHotTrack, hoShowSortGlyphs, hoVisible]
    Header.Style = hsXPStyle
    LineStyle = lsSolid
    ParentBackground = False
    TabOrder = 0
    TreeOptions.PaintOptions = [toHideFocusRect, toShowButtons, toShowHorzGridLines, toThemeAware, toUseBlendedImages]
    TreeOptions.SelectionOptions = [toExtendedFocus, toFullRowSelect]
    OnCompareNodes = lvAccountStatusCompareNodes
    OnGetText = lvAccountStatusGetText
    OnHeaderClick = lvAccountStatusHeaderClick
    Columns = <
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 0
        Width = 80
        WideText = 'Date'
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 1
        Width = 200
        WideText = 'Account Name'
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 2
        Width = 150
        WideText = 'Account Number'
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 3
        Width = 100
        WideText = 'Client Code'
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 4
        Width = 150
        WideText = 'Status'
      end
      item
        Options = [coAllowClick, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible]
        Position = 5
        Width = 300
        WideText = 'Additional Details'
      end>
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 462
    Width = 1013
    Height = 19
    Panels = <>
  end
  object Button1: TButton
    Left = 930
    Top = 428
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
  object cmbAccountFilter: TComboBox
    Left = 100
    Top = 38
    Width = 189
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
    OnSelect = cmbAccountFilterSelect
    Items.Strings = (
      'Exclude Active and Deleted'
      'Active Only'
      'Deleted Only')
  end
end
