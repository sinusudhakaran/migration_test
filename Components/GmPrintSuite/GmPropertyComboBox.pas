{******************************************************************************}
{                                                                              }
{                            GmPropertyComboBox.pas                            }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmPropertyComboBox;

interface

uses Windows, Classes, Graphics, Messages, GmClasses, GmPreview, GmConst, sysutils,
  StdCtrls;

type
  TGmOnAddPropertyItem = procedure(Sender: TObject; Item: string; var AddItem: Boolean) of object;

  TGmComboPropertyType = (gmPaperList, gmPrinterList);

  TGmPropertyComboBox = class(TGmComboBox)
  private
    FBitmapEnvelope: TBitmap;
    FBitmapPaper: TBitmap;
    FBitmapPrinter: TBitmap;
    FPreview: TGmPreview;
    FPreviewProperty: TGmComboPropertyType;
    // events...
    FOnAddItem: TGmOnAddPropertyItem;
    function GetAddItem(Item: string): Boolean;
    function GetImage(index: integer): TBitmap;
    //procedure Changed(Sender: TObject);
    procedure SetPreview(Value: TGmPreview);
    procedure SetPreviewProperty(Value: TGmComboPropertyType);
    procedure UpdateList;
    procedure UpdatePaperList;
    procedure UpdatePrinterList;
  protected
    procedure Change; override;
    procedure DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure PaperSizeChanged(var Message: TMessage); message GM_PAPERSIZE_CHANGED;
    procedure PrinterChanged(var Message: TMessage); message GM_PRINTER_CHANGED;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ItemHeight default 18;
    property Preview: TGmPreview read FPreview write SetPreview;
    property PreviewProperty: TGmComboPropertyType read FPreviewProperty write SetPreviewProperty default gmPrinterList;
    // events...
    property OnAddItem: TGmOnAddPropertyItem read FOnAddItem write FOnAddItem;
  end;

implementation

uses GmTypes, GmFuncs, GmPrinter, Controls;

//------------------------------------------------------------------------------

{$R PropertyComboRes.RES}

// *** TGmPropertyComboBox ***

constructor TGmPropertyComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBitmapEnvelope := TBitmap.Create;
  FBitmapPaper := TBitmap.Create;
  FBitmapPrinter := TBitmap.Create;
  FBitmapEnvelope.LoadFromResourceName(HInstance, 'Envelope');
  FBitmapPaper.LoadFromResourceName(HInstance, 'Paper');
  FBitmapPrinter.LoadFromResourceName(HInstance, 'Printer');
  FBitmapEnvelope.Transparent := True;
  FBitmapPaper.Transparent := True;
  FBitmapPrinter.Transparent := True;
  FPreviewProperty := gmPrinterList;
  Style := csOwnerDrawFixed;
  ItemHeight := 20;
end;

destructor TGmPropertyComboBox.Destroy;
begin
  if Assigned(FPreview) then FPreview.RemoveAssociatedComponent(Self);
  FBitmapEnvelope.Free;
  FBitmapPaper.Free;
  FBitmapPrinter.Free;
  inherited Destroy;
end;

function TGmPropertyComboBox.GetAddItem(Item: string): Boolean;
begin
  Result := True;
  if Assigned(FOnAddItem) then FOnAddItem(Self, Item, Result);
end;

function TGmPropertyComboBox.GetImage(index: integer): TBitmap;
var
  APaperSize: TGmPaperSize;
begin
  Result := nil;
  case FPreviewProperty of
    gmPrinterList: Result := FBitmapPrinter;
    gmPaperList:
    begin
      APaperSize := StrToPaperSize(Items[index]);
      if IsEnvelope(APaperSize) then
        Result := FBitmapEnvelope
      else
        Result := FBitmapPaper;
    end;
  end;
end;

procedure TGmPropertyComboBox.SetPreview(Value: TGmPreview);
begin
  if Assigned(FPreview) then FPreview.RemoveAssociatedComponent(Self);
  FPreview := Value;
  if Assigned(FPreview) then FPreview.AddAssociatedComponent(Self);
  UpdateList;
end;

procedure TGmPropertyComboBox.SetPreviewProperty(Value: TGmComboPropertyType);
begin
  if FPreviewProperty = Value then Exit;
  FPreviewProperty := Value;
  UpdateList;
end;

procedure TGmPropertyComboBox.UpdateList;
begin
  if not Assigned(FPreview) then Exit;
  Items.Clear;
  case FPreviewProperty of
    gmPaperList  : UpdatePaperList;
    gmPrinterList: UpdatePrinterList;
  end;
end;

procedure TGmPropertyComboBox.UpdatePaperList;
var
  PaperList: TStrings;
  ICount: integer;
begin
  PaperList := TStringList.Create;
  try
    FPreview.PaperSizes(PaperList);
    for ICount := 0 to PaperList.Count-1 do
      if GetAddItem(PaperList[ICount]) then Items.Add(PaperList[ICount]);
  finally
    PaperList.Free;
  end;
  ItemIndex := Items.IndexOf(PaperSizeToStr(FPreview.PaperSize));
end;

procedure TGmPropertyComboBox.UpdatePrinterList;
var
  Printers: TStrings;
  ICount: integer;
begin
  Printers := TStringList.Create;
  try
    Printers.Assign(FPreview.GmPrinter.Printers);
    for ICount := 0 to Printers.Count-1 do
      if GetAddItem(Printers[ICount]) then Items.Add(Printers[ICount]);
  finally
    Printers.Free;
  end;
  with FPreview.GmPrinter do
    ItemIndex := Items.IndexOf(Printers[PrinterIndex]);
end;

procedure TGmPropertyComboBox.Change;
begin
  case FPreviewProperty of
    gmPaperList : FPreview.PaperSize := StrToPaperSize(Items[ItemIndex]);
    gmPrinterList: FPreview.GmPrinter.PrinterIndex := FPreview.GmPrinter.Printers.IndexOf(Items[ItemIndex]);
  end;
  inherited Change;
end;

procedure TGmPropertyComboBox.DrawItem(Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  AText: string;
  ARect: TRect;
begin
  with Canvas do
  begin
    FillRect(Rect);

    AText := Items[Index];
    ARect := Rect;
    ARect.Left := ARect.Left + 24;
    Draw(6, Rect.Top + ((ItemHeight-16) div 2), GetImage(Index));
    DrawText(Canvas.Handle, PChar(AText), Length(AText), ARect, DT_VCENTER or DT_SINGLELINE);
  end;
end;

procedure TGmPropertyComboBox.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPreview) then
  begin
    FPreview := nil;
    UpdateList;
  end;
end;

procedure TGmPropertyComboBox.PaperSizeChanged(var Message: TMessage);
begin
  UpdateList;
end;

procedure TGmPropertyComboBox.PrinterChanged(var Message: TMessage);
begin
  UpdateList;
end;

end.
