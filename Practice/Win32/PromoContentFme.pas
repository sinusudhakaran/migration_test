unit PromoContentFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, WPRTEDefs, WPCTRMemo, WPCTRRich, StdCtrls, RzLabel, ComCtrls,
  OleCtrls, SHDocVw, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxTextEdit, cxMemo, cxRichEdit,
  RzEdit, ExtCtrls;

type
  TPromoContentFrame = class(TFrame)
    lblTitle: TRzLabel;
    lblURL: TRzLabel;
    imgContainer: TImage;
    reDescription: TRichEdit;
    lblDescResize: TRzLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
