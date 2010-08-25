object fmeDateSelector: TfmeDateSelector
  Left = 0
  Top = 0
  Width = 276
  Height = 70
  TabOrder = 0
  TabStop = True
  object Label2: TLabel
    Left = 0
    Top = 8
    Width = 47
    Height = 17
    AutoSize = False
    Caption = 'From'
    FocusControl = eDateFrom
  end
  object btnPrev: TSpeedButton
    Left = 184
    Top = 8
    Width = 23
    Height = 23
    OnClick = btnPrevClick
  end
  object btnNext: TSpeedButton
    Left = 208
    Top = 8
    Width = 23
    Height = 23
    OnClick = btnNextClick
  end
  object btnQuik: TSpeedButton
    Left = 237
    Top = 8
    Width = 23
    Height = 23
    OnClick = btnQuikClick
  end
  object Label3: TLabel
    Left = 0
    Top = 34
    Width = 45
    Height = 23
    AutoSize = False
    Caption = 'To'
    FocusControl = eDateTo
  end
  object eDateFrom: TOvcPictureField
    Left = 64
    Top = 8
    Width = 105
    Height = 20
    Cursor = crIBeam
    DataType = pftDate
    AutoSize = False
    BorderStyle = bsNone
    CaretOvr.Shape = csBlock
    Controller = OvcController1
    ControlCharColor = clRed
    DecimalPlaces = 0
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Epoch = 0
    InitDateTime = False
    MaxLength = 8
    Options = [efoCaretToEnd]
    PictureMask = 'DD/mm/yy'
    TabOrder = 0
    OnChange = eDateFromChange
    OnError = eDateFromError
    OnKeyDown = eDateFromKeyDown
    RangeHigh = {25600D00000000000000}
    RangeLow = {00000000000000000000}
  end
  object eDateTo: TOvcPictureField
    Left = 64
    Top = 34
    Width = 105
    Height = 20
    Cursor = crIBeam
    DataType = pftDate
    AutoSize = False
    BorderStyle = bsNone
    CaretOvr.Shape = csBlock
    Controller = OvcController1
    ControlCharColor = clRed
    DecimalPlaces = 0
    EFColors.Disabled.BackColor = clWindow
    EFColors.Disabled.TextColor = clGrayText
    EFColors.Error.BackColor = clRed
    EFColors.Error.TextColor = clBlack
    EFColors.Highlight.BackColor = clHighlight
    EFColors.Highlight.TextColor = clHighlightText
    Epoch = 0
    InitDateTime = False
    MaxLength = 8
    Options = [efoCaretToEnd]
    PictureMask = 'DD/mm/yy'
    TabOrder = 1
    OnChange = eDateFromChange
    OnError = eDateFromError
    OnKeyDown = eDateFromKeyDown
    RangeHigh = {25600D00000000000000}
    RangeLow = {00000000000000000000}
  end
  object pmDates: TPopupMenu
    Left = 184
    Top = 32
    object LastMonth1: TMenuItem
      Caption = 'Last &Month'
      Hint = 'Select Last Calendar Month'
      OnClick = LastMonth1Click
    end
    object Last2Months1: TMenuItem
      Caption = 'Last &2 Month Period'
      OnClick = Last2Months1Click
    end
    object LastQuarter1: TMenuItem
      Caption = 'Last &Quarter'
      Hint = 'Select This Quarter'
      OnClick = LastQuarter1Click
    end
    object Last6months1: TMenuItem
      Caption = 'Last &6 Month Period'
      OnClick = Last6months1Click
    end
    object ThisYear1: TMenuItem
      Caption = '&This Year'
      Hint = 'Select This Financial Year'
      OnClick = ThisYear1Click
    end
    object LastYear1: TMenuItem
      Caption = '&Last Year'
      Hint = 'Select Last Financial Year'
      OnClick = LastYear1Click
    end
    object AllData1: TMenuItem
      Caption = '&All Data'
      Hint = 'Select ALL transactions for client'
      OnClick = AllData1Click
    end
  end
  object OvcController1: TOvcController
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
    Epoch = 1900
    Left = 216
    Top = 32
  end
end
