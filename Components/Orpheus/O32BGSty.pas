{*********************************************************}
{*                  O32BGSTY.PAS 4.05                    *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit O32BGSty;
  {Orpheus Background classes and methods}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TBGImageStyle = (bgNone, bgNormal, bgCenter, bgStretch, bgTile);

  TO32BackgroundStyle = class(TPersistent)
  protected {private}
    FAlphaBlend: Byte; {Range 0 to 255}
    FColor: TColor;
    FEnabled: Boolean;
    FImage: TBitmap;
    FImageStyle: TBGImageStyle;
    procedure SetAlphaBlend(Value: Byte);
    procedure SetColor(NewColor: TColor);
    procedure SetEnabled(Value: Boolean);
    procedure SetImage(Image: TBitmap);
    procedure SetImageStyle(Style: TBGImageStyle);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure PaintBG(Sender: TObject; Canvas: TCanvas; const Rct: TRect);
  published
    property AlphaBlend: Byte read FAlphaBlend write SetAlphaBlend;
    property Color: TColor read FColor write SetColor;
    property Enabled: Boolean read FEnabled write SetEnabled;
    property Image: TBitmap read FImage write SetImage;
    property ImageStyle: TBGImageStyle read FImageStyle write SetImageStyle;
  end;

implementation

end.
