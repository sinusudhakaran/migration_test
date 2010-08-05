object frmEditSuper: TfrmEditSuper
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Edit Superfund Details'
  ClientHeight = 283
  ClientWidth = 612
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 612
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      612
      41)
    object Label1: TLabel
      Left = 24
      Top = 4
      Width = 34
      Height = 16
      Caption = 'Date'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label7: TLabel
      Left = 80
      Top = 4
      Width = 65
      Height = 16
      Caption = 'Narration'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label8: TLabel
      Left = 496
      Top = 4
      Width = 46
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Payee'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblDate: TLabel
      Left = 24
      Top = 21
      Width = 49
      Height = 16
      AutoSize = False
      Caption = '29/1/99'
      Transparent = True
    end
    object lblNarrationField: TLabel
      Left = 80
      Top = 21
      Width = 223
      Height = 16
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'NARRATION'
      EllipsisPosition = epEndEllipsis
      Transparent = True
    end
    object lblPayeeName: TLabel
      Left = 496
      Top = 19
      Width = 185
      Height = 16
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '0'
      Transparent = True
    end
    object Label2: TLabel
      Left = 309
      Top = 4
      Width = 73
      Height = 16
      Anchors = [akTop, akRight]
      Caption = 'Reference'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object Label6: TLabel
      Left = 436
      Top = 4
      Width = 41
      Height = 16
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'Value'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object lblAmount: TLabel
      Left = 373
      Top = 19
      Width = 104
      Height = 16
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '$240.00'
      Transparent = True
    end
    object lblRef: TLabel
      Left = 309
      Top = 19
      Width = 105
      Height = 16
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'REF'
      EllipsisPosition = epEndEllipsis
      Transparent = True
    end
    object imgCoded: TImage
      Left = 6
      Top = 23
      Width = 12
      Height = 12
      Hint = 'Coded By Accountant'
      AutoSize = True
      ParentShowHint = False
      Picture.Data = {
        07544269746D6170D6000000424DD60000000000000076000000280000000C00
        00000C000000010004000000000060000000C40E0000C40E0000100000000000
        0000000000000000BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0
        C000808080000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFF
        FF00300000000033000030FFFFFFF033000030F44444F033000030FFFFFFF033
        000030F44444F033000030FFFFFFF033000030F44444F033000030FFFFFFF033
        000030F44444F033000030FFFFFFF03300003000000000330000333333333333
        0000}
      ShowHint = True
      Transparent = True
      Visible = False
    end
  end
  object pnlRight: TPanel
    Left = 604
    Top = 49
    Width = 8
    Height = 226
    Align = alRight
    BevelOuter = bvNone
    Color = 10050048
    ParentBackground = False
    TabOrder = 1
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 275
    Width = 612
    Height = 8
    Align = alBottom
    BevelOuter = bvNone
    Color = 10050048
    ParentBackground = False
    TabOrder = 2
  end
  object pnlTop: TPanel
    Left = 0
    Top = 41
    Width = 612
    Height = 8
    Align = alTop
    BevelOuter = bvNone
    Color = 10050048
    ParentBackground = False
    TabOrder = 3
  end
  object pnlLeft: TPanel
    Left = 0
    Top = 49
    Width = 8
    Height = 226
    Align = alLeft
    BevelOuter = bvNone
    Color = 10050048
    ParentBackground = False
    TabOrder = 4
  end
  object PnlSuper: TPanel
    Left = 8
    Top = 49
    Width = 596
    Height = 226
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 5
    object pnlBtn: TPanel
      Left = 0
      Top = 185
      Width = 596
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Ctl3D = False
      ParentCtl3D = False
      TabOrder = 0
      DesignSize = (
        594
        39)
      object btnClear: TButton
        Left = 8
        Top = 4
        Width = 81
        Height = 29
        Caption = '&Clear'
        TabOrder = 0
        OnClick = btnClearClick
      end
      object btnOK: TButton
        Left = 415
        Top = 4
        Width = 81
        Height = 29
        Anchors = [akTop, akRight]
        Caption = '&OK'
        Default = True
        TabOrder = 1
        OnClick = btnOKClick
        ExplicitLeft = 417
      end
      object btnCancel: TButton
        Left = 500
        Top = 4
        Width = 81
        Height = 28
        Anchors = [akTop, akRight]
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 2
        ExplicitLeft = 502
      end
    end
    object PnlEdit: TPanel
      Left = 0
      Top = 0
      Width = 596
      Height = 185
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object Label3: TLabel
        Left = 8
        Top = 16
        Width = 98
        Height = 16
        Caption = 'Franked Amount'
      end
      object Label4: TLabel
        Left = 8
        Top = 46
        Width = 110
        Height = 16
        Caption = 'Unfranked Amount'
      end
      object Label5: TLabel
        Left = 8
        Top = 76
        Width = 97
        Height = 16
        Caption = 'Franking Credits'
      end
      object EFranked: TRzNumericEdit
        Left = 174
        Top = 13
        Width = 105
        Height = 24
        Ctl3D = True
        FrameController = frmMain.RzFrameController1
        MaxLength = 14
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 0
        OnChange = EFrankedChange
        IntegersOnly = False
        DisplayFormat = '#,##0.00'
      end
      object EUnfranked: TRzNumericEdit
        Left = 174
        Top = 43
        Width = 105
        Height = 24
        Ctl3D = True
        FrameController = frmMain.RzFrameController1
        MaxLength = 14
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 1
        OnChange = EUnfrankedChange
        IntegersOnly = False
        DisplayFormat = '#,##0.00'
      end
      object ECredits: TRzNumericEdit
        Left = 174
        Top = 73
        Width = 105
        Height = 24
        Ctl3D = True
        FrameController = frmMain.RzFrameController1
        MaxLength = 14
        ParentCtl3D = False
        TabOnEnter = True
        TabOrder = 2
        OnChange = ECreditsChange
        IntegersOnly = False
        DisplayFormat = '#,##0.00'
      end
      object btnCalc: TBitBtn
        Left = 285
        Top = 73
        Width = 92
        Height = 25
        Caption = 'Calculate'
        TabOrder = 3
        OnClick = btnCalcClick
        Glyph.Data = {
          36040000424D3604000000000000360000002800000010000000100000000100
          2000000000000004000000000000000000000000000000000000FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
          0000000000000000000000000000000000000000000000000000000000000000
          0000000000000000000000000000000000000000000000000000FFFFFF000000
          000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
          FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000FFFFFF000000
          0000FFFFFF00848484000000000000FFFF008484840000000000FFFFFF008484
          84000000000000FFFF008484840000000000FFFFFF0000000000FFFFFF000000
          000000FFFF00FFFFFF000000000000FFFF00FFFFFF000000000000FFFF00FFFF
          FF000000000000FFFF00FFFFFF000000000000FFFF0000000000FFFFFF000000
          0000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
          FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000FFFFFF000000
          000000FFFF00848484000000000000FFFF00848484000000000000FFFF008484
          84000000000000FFFF00848484000000000000FFFF0000000000FFFFFF000000
          000000FFFF00FFFFFF000000000000FFFF00FFFFFF000000000000FFFF00FFFF
          FF000000000000FFFF00FFFFFF000000000000FFFF0000000000FFFFFF000000
          0000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
          FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000FFFFFF000000
          000000FFFF000000000000000000000000000000000000000000000000000000
          0000000000000000000000FFFF00FFFFFF0000FFFF0000000000FFFFFF000000
          000000FFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF000000000000FFFF0000FFFF0000FFFF0000000000FFFFFF000000
          000000FFFF000000000000000000000000000000000000000000000000000000
          00000000000000000000FFFFFF0000FFFF00FFFFFF0000000000FFFFFF000000
          000000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
          FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000FFFFFF00FFFF
          FF00000000000000000000000000000000000000000000000000000000000000
          00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
          FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00}
      end
    end
  end
end
