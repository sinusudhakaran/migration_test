inherited cxCardViewEditor: TcxCardViewEditor
  Caption = 'cxCardViewEditor'
  PixelsPerInch = 96
  TextHeight = 13
  inherited PViewEditor: TPanel
    inherited PageControl1: TcxPageControl
      inherited TSItems: TcxTabSheet
        Caption = '   Rows   '
      end
      inherited TSSummary: TcxTabSheet
        TabVisible = False
      end
    end
  end
end
