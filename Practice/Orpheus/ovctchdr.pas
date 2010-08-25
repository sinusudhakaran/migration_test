{*********************************************************}
{*                  OVCTCHDR.PAS 4.01                    *}
{*     Copyright (c) 1995-2001 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{$W-} {Windows Stack Frame}
{$X+} {Extended Syntax}

unit ovctchdr;
  {Orpheus Table Cell - Headers for columns and rows}

interface

uses
  Windows, SysUtils, Graphics, Classes, OvcTCmmn, OvcTCell, OvcTCStr,
  {BankLink Modification} ovcBase;

type
  TOvcTCColHead = class(TOvcTCBaseString)
    protected {private}
      {.Z+}
      FHeadings      : TStringList;
      FShowActiveCol : boolean;
      FShowLetters   : boolean;
      {BankLink modifications}
      FShowSortArrow : boolean;
      FSArrowColor   : integer;
      FSArrowFillColor : integer;
      {End of BankLink modifications}

      {.Z-}

    protected
      {.Z+}
      procedure SetHeadings(H : TStringList);
      procedure SetShowActiveCol(SAC : boolean);
      procedure SetShowLetters(SL : boolean);
      procedure SetShowSortArrow (SSA : boolean); {BankLink modification}

      procedure tcPaint(TableCanvas : TCanvas;
                  const CellRect    : TRect;
                        RowNum      : TRowNum;
                        ColNum      : TColNum;
                  const CellAttr    : TOvcCellAttributes;
                        Data        : pointer); override;
      {.Z-}

     public {protected}
      {.Z+}
      procedure chColumnsChanged(ColNum1, ColNum2 : TColNum; Action : TOvcTblActions);
      {.Z-}

    public
      constructor Create(AOwner : TComponent); override;
      destructor Destroy; override;

    published
      property Headings : TStringList
         read FHeadings write SetHeadings;

      property ShowActiveCol : boolean
         read FShowActiveCol write SetShowActiveCol;

      property ShowLetters : boolean
         read FShowLetters write SetShowLetters;

      {BankLink modifications}
      property ShowSortArrow : boolean
         read FShowSortArrow write SetShowSortArrow
         default false;

      property SortArrowColor : integer read FSArrowColor write FSArrowColor;
      property SortArrowFillColor : integer read FSArrowFillColor write FSArrowFillColor;
      {End of BankLink modifications}

      {properties inherited from custom ancestor}
      property About;
      property Adjust;
      property Color;
      property Font;
      property Margin;
      property Table;
      property TableColor;
      property TableFont;
      property TextHiColor;
      property TextStyle;
      property UseASCIIZStrings;                                            
      property UseWordWrap;

      {events inherited from custom ancestor}
      property OnClick;
      property OnDblClick;
      property OnDragDrop;
      property OnDragOver;
      property OnEndDrag;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
      property OnOwnerDraw;
  end;

  TOvcTCRowHead = class(TOvcTCBaseString)
    protected {private}
      {.Z+}
      FShowActiveRow : boolean;
      FShowNumbers   : boolean;
      {.Z-}

    protected
      {.Z+}
      procedure SetShowActiveRow(SAR : boolean);
      procedure SetShowNumbers(SN : boolean);
      procedure tcPaint(TableCanvas : TCanvas;
                  const CellRect    : TRect;
                        RowNum      : TRowNum;
                        ColNum      : TColNum;
                  const CellAttr    : TOvcCellAttributes;
                        Data        : pointer); override;
      {.Z-}

    public
      constructor Create(AOwner : TComponent); override;

    published
      property ShowActiveRow : boolean
         read FShowActiveRow write SetShowActiveRow;

      property ShowNumbers : boolean
         read FShowNumbers write SetShowNumbers;

      {properties inherited from custom ancestor}
      property About;
      property Adjust;
      property Color;
      property Font;
      property Margin;
      property Table;
      property TableColor;
      property TableFont;
      property TextHiColor;
      property TextStyle;

      {events inherited from custom ancestor}
      property OnClick;
      property OnDblClick;
      property OnDragDrop;
      property OnDragOver;
      property OnEndDrag;
      property OnMouseDown;
      property OnMouseMove;
      property OnMouseUp;
      property OnOwnerDraw;
  end;

implementation



{===TOvcTCColHead====================================================}
constructor TOvcTCColHead.Create(AOwner : TComponent);
  begin
    inherited Create(AOwner);
    FHeadings := TStringList.Create;
    Access := otxReadOnly;
    UseASCIIZStrings := false;
    {UseWordWrap := false;}
    ShowLetters := true;
    SortArrowColor     := clBtnFace;   {BankLink modification}
    SortArrowFillColor := clBtnFace;   {BankLink modification}
  end;
{--------}
destructor TOvcTCColHead.Destroy;
  begin
    FHeadings.Free;
    inherited Destroy;
  end;
{--------}
procedure TOvcTCColHead.chColumnsChanged(ColNum1, ColNum2 : TColNum;
                                         Action : TOvcTblActions);
  var
    MaxColNum : TColNum;
    ColNum    : TColNum;
    Temp : string;
  begin
    case Action of
      taInsert :
        if (0 <= ColNum1) and (ColNum1 < FHeadings.Count) then
          FHeadings.Insert(ColNum1, '')
        else if (ColNum1 = FHeadings.Count) then
          FHeadings.Add('');
      taDelete :
        if (0 <= ColNum1) and (ColNum1 < FHeadings.Count) then
          FHeadings.Delete(ColNum1);
      taExchange :
        begin
          MaxColNum := MaxL(ColNum1, ColNum2);
          if (MaxColNum >= FHeadings.Count) and (FHeadings.Count > 0) then
            for ColNum := FHeadings.Count to MaxColNum do
              FHeadings.Add('');
          if (0 <= ColNum1) and (0 <= ColNum2) and
             (FHeadings.Count > 0) then
            begin
              Temp := FHeadings[ColNum1];
              FHeadings[ColNum1] := FHeadings[ColNum2];
              FHeadings[ColNum2] := Temp;
            end;
        end;
    end;
  end;

{--------}
procedure TOvcTCColHead.tcPaint(TableCanvas : TCanvas;
                          const CellRect    : TRect;
                                RowNum      : TRowNum;
                                ColNum      : TColNum;
                          const CellAttr    : TOvcCellAttributes;
                                Data        : pointer);

{!!!! Major BankLink modifications to this unit to display 3d arrow that indicates
 sort order !!!!}

(*
   BankLink 21/9/99
   MJCH altered library 22 Sep 97
   Add 3d effect to arrow and ability to have up and down arrows

   Text will always be drawn with arrow.  Arrow should be positioned to
   right of text if left justified and vv.

   If column is too small then arrow will disappear.
*)

  {------}
  {BankLink modification, removed PaintAnArrow routine}
  (*  procedure PaintAnArrow;
    var
      ArrowDim : Integer;
      X, Y     : Integer;
      LeftPoint, RightPoint, BottomPoint : TPoint;
      CellWidth  : integer;
      CellHeight : integer;
    begin
      CellWidth := CellRect.Right - CellRect.Left;
      CellHeight := CellRect.Bottom - CellRect.Top;
      with TableCanvas do
        begin
          Pen.Color := CellAttr.caFont.Color;
          Brush.Color := Pen.Color;
          ArrowDim := MinI(CellWidth, CellHeight) div 3;
          case CellAttr.caAdjust of
            otaTopLeft, otaCenterLeft, otaBottomLeft    : X := Margin;
            otaTopRight, otaCenterRight, otaBottomRight : X := CellWidth-Margin-ArrowDim;
          else
            X := (CellWidth - ArrowDim) div 2;
          end;{case}
          inc(X, CellRect.Left);
          case CellAttr.caAdjust of
            otaTopLeft, otaTopCenter, otaTopRight          : Y := Margin;
            otaBottomLeft, otaBottomCenter, otaBottomRight : Y := CellHeight-Margin-ArrowDim;
          else
            Y := (CellHeight - ArrowDim) div 2;
          end;{case}
          inc(Y, CellRect.Top);
          LeftPoint := Point(X, Y);
          RightPoint := Point(X+ArrowDim, Y);
          BottomPoint := Point(X+(ArrowDim div 2), Y+ArrowDim);
          Polygon([LeftPoint, RightPoint, BottomPoint]);
        end;
    end;*)


  procedure mjchPaintAnArrow( bDownArrow : boolean; DataWidth : longint);
  const
    MAX_ARROW_SIZE = 7;

    procedure _Line ( pt1 : TPoint; pt2 : TPoint; col : TColor);
      // added by mjch to get around problem of drawing on cell header
      // the pen did not work if cell didn't have focus for some unknown
      // reason.

      // this is not the faster algoritm to use but given the amount of use
      // it will get it is acceptable in this case
     var
        dx,dy,m  : single;
        y,x1     : single;
        x,y1     :integer;
     begin
        dx := pt2.x - pt1.x;
        dy := pt2.y - pt1.y;
        m := dy/dx;
        if abs(Round(m))<= 1 then
          begin  //interate along x-axis
            y := pt1.y;
            for x:= pt1.x to pt2.x do
              begin
                TableCanvas.Pixels[x,Round(y)] := col;
                y := y + m;
             end;
        end
        else
          begin  // interate along y-axis
            x1 := pt1.x;
            m := 1/m;
            for y1:= pt1.y to pt2.y do
              begin
                TableCanvas.Pixels[Round(x1),y1] := col;
                x1 := x1 + m;
              end;
          end;
     end;
     {------}
    var
      ArrowDim : Integer;
      X, Y     : Integer;
      LeftPoint, RightPoint, BottomPoint, TopPoint : TPoint;
      CellWidth  : integer;
      CellHeight : integer;
    begin
      CellWidth := CellRect.Right - CellRect.Left;
      CellHeight := CellRect.Bottom - CellRect.Top;

      with TableCanvas do
        begin
          ArrowDim := MinI(CellWidth, CellHeight) div 2;
          if ArrowDim > MAX_ARROW_SIZE then ArrowDim := MAX_ARROW_SIZE;

          case CellAttr.caAdjust of
               otaTopLeft, otaCenterLeft, otaBottomLeft    :
                           begin
                              X := CellRect.Left + Margin + DataWidth + ArrowDim;
                              if X > (CellRect.Right - ArrowDim - Margin) then Exit;       //Dont Draw if outside rect
                           end;
               otaTopRight, otaCenterRight, otaBottomRight :
                           begin
                             X := CellRect.Right - Margin - DataWidth - ArrowDim * 2;
                             if X < (CellRect.Left + ArrowDim + Margin) then Exit;        //Dont Draw if outside rect
                           end;
          else  //text centered so draw arrow to right
               X := CellRect.Right - Margin - ArrowDim;
          end;{case}

          case CellAttr.caAdjust of
            otaTopLeft, otaTopCenter, otaTopRight: Y := CellHeight-Margin-ArrowDim;
            otaBottomLeft, otaBottomCenter, otaBottomRight : Y := Margin;
          else
            Y := (CellHeight - ArrowDim) div 2;
          end;{case}
          inc(Y, CellRect.Top);

          TableCanvas.Brush.Color := FSArrowFillColor;
          if bDownArrow then
          begin         // Draw Down Arrow
             LeftPoint := Point(X, Y);
             RightPoint := Point(X+ArrowDim, Y);
             BottomPoint := Point(X+(ArrowDim div 2), Y+ArrowDim);

             TableCanvas.Polygon([LeftPoint,RightPoint,BottomPoint]);

             _Line(LeftPoint,RightPoint,   FSArrowColor);
             _Line(LeftPoint,BottomPoint,  FSArrowColor);
             _Line(RightPoint,BottomPoint, clBtnHighlight);
          end
          else
          begin          // Draw Up Arrow
             LeftPoint := Point(X, Y+ArrowDim);
             RightPoint := Point(X+ArrowDim, Y+ArrowDim);
             TopPoint := Point(X+(ArrowDim div 2), Y);

             TableCanvas.Polygon([LeftPoint,RightPoint,BottomPoint]);

             _Line(LeftPoint,RightPoint, FSArrowColor);
             _Line(TopPoint,RightPoint,  FSArrowColor);
             _Line(TopPoint,LeftPoint,   clBtnHighlight);
          end;
        end;
    end;
  {------}
  var
    DataSt    : POvcShortString absolute Data;
    LockedCols: TColNum;
//    ActiveCol : TColNum;
    WorkCol   : TColNum;
    C         : string[1];
    HeadSt    : ShortString;

    SortedCol : TColNum;         //BankLink 21/9/99
    HeadWidth : longInt;         //BankLink 21/9/99
    SortMethod: TColSortStatus;  //BankLink 21/9/99
  begin
    if Assigned(FTable) then
      begin
        LockedCols := tcRetrieveTableLockedCols;
//        ActiveCol := tcRetrieveTableActiveCol;

        SortedCol := tcRetrieveTableSortedCol; //BankLink 21/9/99
        SortMethod := soAscend;                //BankLink 21/9/99
      end
    else
      begin
        LockedCols := 0;
//        ActiveCol := -1;

        SortedCol := -1;        //BankLink 21/9/99
        SortMethod := soNone;   //BankLink 21/9/99
      end;
    HeadSt := '';
(*
    {if required show a down arrow for the active column}
    if ShowActiveCol and (ColNum = ActiveCol) then
      begin
        {this call to inherited tcPaint blanks out the cell}
        inherited tcPaint(TableCanvas, CellRect, RowNum, ColNum, CellAttr, @HeadSt);
        PaintAnArrow;
      end
    else
*)
    if ShowLetters then
      begin
        {convert the column number to the spreadsheet-style letters}
        WorkCol := ColNum - LockedCols + 1;
        HeadSt := '.';
        while (WorkCol > 0) do
          begin
            C := AnsiChar(pred(WorkCol) mod 26 + ord('A'));
            System.Insert(C, HeadSt, 1);
            WorkCol := pred(WorkCol) div 26;
          end;
        Delete(HeadSt, length(HeadSt), 1);
        inherited tcPaint(TableCanvas, CellRect, RowNum, ColNum, CellAttr, @HeadSt);
      end
    else {Data points to a column heading}
      begin
        HeadWidth := 0;
        if Assigned(Data) then begin
          HeadSt := DataSt^;
          //BankLink 07/10/99
          HeadWidth := tableCanvas.TextWidth(DataSt^);
        end
        else if (0 <= ColNum) and (ColNum < Headings.Count) then begin
          HeadSt := Headings[ColNum];
          //BankLink 07/10/99
          Headwidth := tableCanvas.textWidth(Headings[ColNum]);
        end;
        inherited tcPaint(TableCanvas, CellRect, RowNum, ColNum, CellAttr, @HeadSt);

        //BankLink 21/9/99  - Draw Text then arrow
        if ShowSortArrow and (ColNum = SortedCol) then begin
           case sortMethod of
           soAscend:
              mjchPaintAnArrow(true, HeadWidth);
           soDecend:
              mjchPaintAnArrow(false, HeadWidth);
           soNone:
              ;
           end;
        end;      end;
  end;
{--------}
procedure TOvcTCColHead.SetHeadings(H : TStringList);
  begin
    FHeadings.Assign(H);
    tcDoCfgChanged;
  end;
{--------}
procedure TOvcTCColHead.SetShowActiveCol(SAC : boolean);
  begin
    if (SAC <> ShowActiveCol) then
      begin
        FShowActiveCol := SAC;
        tcDoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTCColHead.SetShowLetters(SL : boolean);
  begin
    if (SL <> ShowLetters) then
      begin
        FShowLetters := SL;
        tcDoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTCColHead.SetShowSortArrow (SSA : boolean); //BankLink 21/9/99
  begin
    if (SSA <> ShowSortArrow) then
      begin
        FShowSortArrow := SSA;
        tcDoCfgChanged;
      end;
    end;
{====================================================================}

{===TOvcTCRowHead====================================================}
constructor TOvcTCRowHead.Create(AOwner : TComponent);
  begin
    inherited Create(AOwner);
    Access := otxReadOnly;
    UseASCIIZStrings := false;
    UseWordWrap := false;
    ShowNumbers := true;
  end;
{--------}
procedure TOvcTCRowHead.tcPaint(TableCanvas : TCanvas;
                          const CellRect    : TRect;
                                RowNum      : TRowNum;
                                ColNum      : TColNum;
                          const CellAttr    : TOvcCellAttributes;
                                Data        : pointer);
  {------}
  procedure PaintAnArrow;
    var
      ArrowDim : Integer;
      X, Y     : Integer;
      TopPoint, BottomPoint, RightPoint : TPoint;
      CellWidth  : integer;
      CellHeight : integer;
    begin
      CellWidth := CellRect.Right - CellRect.Left;
      CellHeight := CellRect.Bottom - CellRect.Top;
      with TableCanvas do
        begin
          Pen.Color := CellAttr.caFont.Color;
          Brush.Color := Pen.Color;
          ArrowDim := MinI(CellWidth-8, CellHeight div 3);
          case CellAttr.caAdjust of
            otaTopLeft, otaCenterLeft, otaBottomLeft    : X := Margin;
            otaTopRight, otaCenterRight, otaBottomRight : X := CellWidth-Margin-ArrowDim;
          else
            X := (CellWidth - ArrowDim) div 2;
          end;{case}
          inc(X, CellRect.Left);
          case CellAttr.caAdjust of
            otaTopLeft, otaTopCenter, otaTopRight          : Y := Margin;
            otaBottomLeft, otaBottomCenter, otaBottomRight : Y := CellHeight-Margin-ArrowDim;
          else
            Y := (CellHeight - ArrowDim) div 2;
          end;{case}
          inc(Y, CellRect.Top);
          TopPoint := Point(X, Y);
          BottomPoint := Point(X, Y+ArrowDim);
          RightPoint := Point(X+ArrowDim, Y+(ArrowDim div 2));
          Polygon([RightPoint, TopPoint, BottomPoint]);
        end;
    end;
  {------}
  var
    HeadSt : ShortString;
    ActiveRow  : TRowNum;
    LockedRows : TRowNum;
    WorkRow    : TRowNum;
  begin
    if Assigned(FTable) then
      begin
        LockedRows := tcRetrieveTableLockedRows;
        ActiveRow := tcRetrieveTableActiveRow;
      end
    else
      begin
        LockedRows := 0;
        ActiveRow := -1;
      end;
    {display the row number, etc}
    HeadSt := '';
    if (ShowActiveRow and (RowNum = ActiveRow)) then
      begin
        inherited tcPaint(TableCanvas, CellRect, RowNum, ColNum, CellAttr, @HeadSt);
        PaintAnArrow;
      end
    else
      begin
        if ShowNumbers then
          begin
            WorkRow := (RowNum + 1) - LockedRows;
            HeadSt := Format('%d', [WorkRow]);
          end;
        inherited tcPaint(TableCanvas, CellRect, RowNum, ColNum, CellAttr, @HeadSt);
      end;
  end;
{--------}
procedure TOvcTCRowHead.SetShowActiveRow(SAR : boolean);
  begin
    if (SAR <> ShowActiveRow) then
      begin
        FShowActiveRow := SAR;
        tcDoCfgChanged;
      end;
  end;
{--------}
procedure TOvcTCRowHead.SetShowNumbers(SN : boolean);
  begin
    if (SN <> ShowNumbers) then
      begin
        FShowNumbers := SN;
        tcDoCfgChanged;
      end;
  end;
{====================================================================}


end.
