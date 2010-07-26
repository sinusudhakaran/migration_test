{*********************************************************}
{*                  OVCTCBOX.PAS 4.05                    *}
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

unit ovctcbox;
  {-Orpheus Table Cell - Check box type}

interface

uses
  Windows, SysUtils, Graphics, Classes, Controls, StdCtrls,
  OvcTCmmn, OvcTCell, OvcTGRes, OvcTCGly;

type
  TOvcTCCustomCheckBox = class(TOvcTCCustomGlyph)
    protected {private}
      {.Z+}
      FAllowGrayed : boolean;

      FatherValue : Integer;
      {.Z-}

    protected
      {.Z+}
      procedure SetAllowGrayed(AG : boolean);

      procedure GlyphsHaveChanged(Sender : TObject);
      procedure tcPaint(TableCanvas : TCanvas;
                  const CellRect    : TRect;
                        RowNum      : TRowNum;
                        ColNum      : TColNum;
                  const CellAttr    : TOvcCellAttributes;
                        Data        : pointer); override;
      {.Z-}

    public
      constructor Create(AOwner : TComponent); override;

      function  CanAssignGlyphs(CBG : TOvcCellGlyphs) : boolean; override;

      procedure SaveEditedData(Data : pointer); override;
      procedure StartEditing(RowNum : TRowNum; ColNum : TColNum;
                             CellRect : TRect;
                       const CellAttr : TOvcCellAttributes;
                             CellStyle: TOvcTblEditorStyle;
                             Data : pointer); override;
      procedure StopEditing(SaveValue : boolean;
                            Data : pointer); override;

      property AllowGrayed : boolean
         read FAllowGrayed write SetAllowGrayed;

  end;

  TOvcTCCheckBox = class(TOvcTCCustomCheckBox)
    published
      {properties inherited from custom ancestor}
      property AcceptActivationClick default True;                    {!!.05}
      property Access default otxDefault;                             {!!.05}
      property Adjust default otaDefault;                             {!!.05}
      property AllowGrayed default False;                             {!!.05}
      property CellGlyphs;
      property Color;
      property Hint;
      property Margin default 4;                                      {!!.05}
      property ShowHint default False;                                {!!.05}
      property Table;
      property TableColor default True;                               {!!.05}

      {events inherited from custom ancestor}
      property OnClick;
      property OnDragDrop;
      property OnDragOver;
      property OnEndDrag;
      property OnEnter;
      property OnExit;
      property OnKeyDown;
      property OnKeyPress;
      property OnKeyUp;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
      property OnOwnerDraw;
  end;

implementation


{===TOvcTCCustomCheckBox creation/destruction========================}
constructor TOvcTCCustomCheckBox.Create(AOwner : TComponent);
  begin
    inherited Create(AOwner);
    CellGlyphs.OnCfgChanged := nil;
    if (CellGlyphs.ActiveGlyphCount = 3) then
      CellGlyphs.ActiveGlyphCount := 2;
    CellGlyphs.OnCfgChanged := GlyphsHaveChanged;
    FAcceptActivationClick := true;
  end;
{--------}
procedure TOvcTCCustomCheckBox.SetAllowGrayed(AG : boolean);
  begin
    if AG <> FAllowGrayed then
      begin
        FAllowGrayed := AG;
        if AG then
          CellGlyphs.ActiveGlyphCount := 3
        else
          CellGlyphs.ActiveGlyphCount := 2;
        tcDoCfgChanged;
      end;
  end;
{--------}
function TOvcTCCustomCheckBox.CanAssignGlyphs(CBG : TOvcCellGlyphs) : boolean;
  begin
    Result := CBG.GlyphCount = 3;
  end;
{--------}
procedure TOvcTCCustomCheckBox.GlyphsHaveChanged(Sender : TObject);
  begin
    CellGlyphs.OnCfgChanged := nil;
    if FAllowGrayed then
      CellGlyphs.ActiveGlyphCount := 3
    else
      CellGlyphs.ActiveGlyphCount := 2;
    CellGlyphs.OnCfgChanged := GlyphsHaveChanged;
    tcDoCfgChanged;
  end;
{====================================================================}


{===TOvcTCCustomCheckBox painting====================================}
procedure TOvcTCCustomCheckBox.tcPaint(TableCanvas : TCanvas;
                                 const CellRect    : TRect;
                                       RowNum      : TRowNum;
                                       ColNum      : TColNum;
                                 const CellAttr    : TOvcCellAttributes;
                                       Data        : pointer);
  var
    B : ^TCheckBoxState absolute Data;
    Value : integer;
  begin
    if (Data = nil) then
      inherited tcPaint(TableCanvas, CellRect, RowNum, ColNum, CellAttr, nil)
    else
      begin
        Value := ord(B^);
        inherited tcPaint(TableCanvas, CellRect, RowNum, ColNum, CellAttr, @Value);
      end;
  end;
{====================================================================}


{===TOvcTCCheckBox editing===========================================}
procedure TOvcTCCustomCheckBox.SaveEditedData(Data : pointer);
  begin
    if Assigned(Data) then
      begin
        inherited SaveEditedData(@FatherValue);
        TCheckBoxState(Data^) := TCheckBoxState(FatherValue);
      end;
  end;
{--------}
procedure TOvcTCCustomCheckBox.StartEditing(RowNum : TRowNum; ColNum : TColNum;
                                            CellRect : TRect;
                                      const CellAttr : TOvcCellAttributes;
                                            CellStyle: TOvcTblEditorStyle;
                                            Data : pointer);
  begin
    if (Data = nil) then
      inherited StartEditing(RowNum, ColNum,
                             CellRect, CellAttr, CellStyle, nil)
    else
      begin
        FatherValue := Integer(TCheckBoxState(Data^));
        inherited StartEditing(RowNum, ColNum,
                               CellRect, CellAttr, CellStyle, @FatherValue);
      end;
  end;
{--------}
procedure TOvcTCCustomCheckBox.StopEditing(SaveValue : boolean;
                                           Data : pointer);
  begin
    inherited StopEditing(SaveValue, @FatherValue);
    if SaveValue and Assigned(Data) then
      TCheckBoxState(Data^) := TCheckBoxState(FatherValue);
  end;
{====================================================================}


end.
