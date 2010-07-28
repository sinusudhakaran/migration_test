unit WpPagPrp;
{ -----------------------------------------------------------------------------
  WPTools Version 5  / Version 6
  WPStyles - Copyright (C) 2004 by wpcubed GmbH      -   Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  This unit is used to edit the page size
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

interface

{$I WPINC.INC}

uses Windows, WinSpool, SysUtils, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons,
  {$IFDEF WPTools5}
          WPCtrMemo, WPCtrRich, WPRTEDefs,
  {$ELSE} WPRtfPA, WPWinctr, WPRich, WPDefs, WPPrint, {$ENDIF}
  WPUtil, {$IFNDEF DISABLEPRINTER} {$IFDEF WPXPRN} WPX_Printers, {$ELSE} Printers, {$ENDIF}  {$ENDIF}
  ExtCtrls
  ;

type
  {$IFDEF T2H}
  TWPPagePropOptions = set of (ppoNoPagePreview);
  {$ELSE}
  TWPPagePropOption = (
    ppoNoPagePreview, // Do not show the page format on the form
    ppoGetPrinterPaperList, // Load the list of the available paper sizes from the printer
    ppoHeaderFooterMargins, // Allow the user to adjust the header and footer margins
    ppoNoMimimumMargins // Do not set the minimum margin to the physical margin defined by printer
   );
  TWPPagePropOptions = set of TWPPagePropOption;
  TWPPagePropDlg = class;

  TWPPageProp = class(TWPShadedForm)
    PSD: TPrinterSetupDialog;
    Panel2: TPanel;
    PaperSize: TGroupBox;
    labWidth: TLabel;
    labHeight: TLabel;
    PW: TWPValueEdit;
    PH: TWPValueEdit;
    cbxPaperSize: TComboBox;
    Orientation: TRadioGroup;
    Margins: TGroupBox;
    labTop: TLabel;
    labBottom: TLabel;
    labLeft: TLabel;
    labRight: TLabel;
    MT: TWPValueEdit;
    MB: TWPValueEdit;
    ML: TWPValueEdit;
    MR: TWPValueEdit;
    btnOK: TButton;
    btnCancel: TButton;
    btnPrinter: TButton;
    HeaderMarg: TLabel;
    MH: TWPValueEdit;
    FooterMarg: TLabel;
    MF: TWPValueEdit;
    PreviewPanel: TPanel;
    PagePreview: TPaintBox;
    PaintBox1: TPaintBox;
    procedure FormActivate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure MLUnitChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure btnPrinterClick(Sender: TObject);
    procedure MLChange(Sender: TObject);
    procedure MTChange(Sender: TObject);
    procedure MRChange(Sender: TObject);
    procedure MBChange(Sender: TObject);
    procedure PaperSizeChange(Sender: TObject);
    procedure CheckMargins(Sender: TObject);
    procedure cbxPaperSizeChange(Sender: TObject);
    procedure PagePreviewPaint(Sender: TObject);
    procedure OrientationClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MHChange(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
  private
    MinML, MinMT, MinMR, MinMB: Integer;
    OldML, OldMT, OldMR, OldMB: Integer;
    FLocked: Boolean;
    FindPagerSize: Boolean;
    FNoMimimumMargins: Boolean;
    FDialogCtr : TWPPagePropDlg;
    {$IFDEF WP6}
    FSectionMode : Boolean;
    {$ENDIF}
    procedure GetPrinterProperties(var w, h: Integer);
    procedure CheckPaperSize;
    procedure SetPWandPH;
    procedure UpdatePaperList(w, h: Integer);
  public
    {$IFDEF WPTools5}
      EditBox: TWPCustomRtfEdit;
    {$ELSE}
      RtfText: TWPRtfTextPaint;
      EditBox: TWPCustomRichText;
    {$ENDIF}
  end;
  {$ENDIF}

  TWPPagePropDlg = class(TWPCustomAttrDlg)
  private
    dia: TWPPageProp;
    FUpdatePrinter: boolean;
    FOptions: TWPPagePropOptions;
    FSecProp : TWPRTFSectionProps;
  public
    constructor Create(aOwner : TComponent);  override;
    {$IFDEF WP6}
    function ExecuteEx(Sec : TWPRTFSectionProps = nil): Boolean;
    {$ENDIF}
    function Execute: Boolean; override;
  published
    property EditBox;
    property UpdatePrinter: boolean read FUpdatePrinter write FUpdatePrinter;
    property Options: TWPPagePropOptions read FOptions write FOptions;
  end;


implementation

uses Math;

{$R *.DFM}

constructor TWPPagePropDlg.Create(aOwner : TComponent);
begin
   inherited Create(aOwner);
   FOptions := [ppoHeaderFooterMargins,ppoGetPrinterPaperList];
end;




{$IFDEF WP6}
function TWPPagePropDlg.ExecuteEx(Sec : TWPRTFSectionProps = nil): Boolean;
begin
   FSecProp := Sec;
   Result := Execute;
   FSecProp := nil;
end;
{$ENDIF}

function TWPPagePropDlg.Execute: Boolean; 
var
  d: Integer;
begin
  Result := FALSE;
  if AssignedActiveRTFEdit(FEditBox) then
  begin
    try
      dia := TWPPageProp.Create(Self);
      dia.FDialogCtr := Self;
      dia.EditBox := FEditBox;
      {$IFDEF WP6}
      if (FSecProp=nil) and (FEditBox._CurrentSection<>nil) then
         FSecProp := FEditBox._CurrentSection;
      if FSecProp<>nil then
      begin
        dia.FSectionMode := TRUE;
      end else
      {$ENDIF}
      FSecProp := FEditBox.Header;

      if (ppoNoPagePreview in FOptions)
         {$IFDEF WP6}
         or dia.FSectionMode
         {$ENDIF}
       then
      begin
        dia.ClientHeight := dia.Panel2.Height;
        dia.PreviewPanel.Visible := FALSE;
      end
      else
        dia.PreviewPanel.Visible := TRUE;
      if (ppoHeaderFooterMargins in FOptions) and
         {$IFDEF WP6}
         not dia.FSectionMode and
         {$ENDIF}
      {$IFDEF WPTOOLS5}
        (ActiveRTFEdit(FEditBox).Memo.RTFData.PrintParameter.PrintHeaderFooter <> wprNever)
      {$ELSE}
        (ActiveRTFEdit(FEditBox).PrintParameter.PrintHeaderFooter <> wprNever)
      {$ENDIF}
        then
      begin
        d := dia.MF.Top + dia.MF.Height + 6 - dia.Margins.Height;
        dia.MH.Visible := TRUE;
        dia.MF.Visible := TRUE;
        dia.Margins.Height := dia.Margins.Height + d;
        dia.Orientation.Top := dia.Orientation.Top + d;
        dia.btnOK.Top := dia.btnOK.Top + d;
        dia.btnCancel.Top := dia.btnCancel.Top + d;
        dia.btnPrinter.Top := dia.btnPrinter.Top + d;
        dia.Height := dia.Height + d;
      end;
      dia.FNoMimimumMargins :=
        ppoNoMimimumMargins in FOptions;
      dia.FLocked := TRUE;
     {$IFNDEF WPTOOLS5}
      dia.RtfText := (ActiveRTFEdit(FEditBox).RtfText as TWPRtfTextPaint);
     {$ENDIF}
      dia.EditBox := ActiveRTFEdit(FEditBox);
      if (dia.EditBox <> nil) {and (dia.EditBox.PaperDefs.Count=0)} then
        dia.EditBox.PaperDefs.Init(ppoGetPrinterPaperList in FOptions);
      dia.pw.Value := FSecProp._Layout.paperw;
      dia.ph.Value := FSecProp._Layout.paperh;
      dia.MH.Value := FSecProp.MarginHeader;
      dia.MF.Value := FSecProp.MarginFooter;
      dia.FindPagerSize := TRUE;
      dia.UpdatePaperList(FSecProp._Layout.paperw, FSecProp._Layout.paperh);
      dia.FindPagerSize := FALSE;
      dia.FLocked := FALSE;
      if not FCreateAndFreeDialog and MayOpenDialog(dia) and (dia.ShowModal = mrOK) then
      begin
        Result := TRUE;
        if FUpdatePrinter
           {$IFDEF WP6}
           and not dia.FSectionMode
         {$ENDIF}
        then
           dia.btnPrinterClick(nil); // Update printer
      end;
    finally
      dia.Free;
      FSecProp := nil;
    end;
   {$IFDEF WP6}
   if FEditBox._CurrentSection<>nil then
         FSecProp := nil;
   {$ENDIF}
  end;
end;

procedure TWPPageProp.FormActivate(Sender: TObject);
begin
  // PreviewPanel.NoShading := WPShadedFormStandard;
  btnPrinter.Enabled := not WPNoPrinterInstalled;  

  PH.UnitType := GlobalValueUnit;
  PW.UnitType := GlobalValueUnit;
  ML.UnitType := GlobalValueUnit;
  MR.UnitType := GlobalValueUnit;
  MT.UnitType := GlobalValueUnit;
  MB.UnitType := GlobalValueUnit;
  MH.UnitType := GlobalValueUnit;
  MF.UnitType := GlobalValueUnit;

  // PW.Value := EditBox.Header.PageWidth;
  // PH.Value := EditBox.Header.PageHeight;
  MT.Value := FDialogCtr.FSecProp.TopMargin;
  MB.Value := FDialogCtr.FSecProp.BottomMargin;
  ML.Value := FDialogCtr.FSecProp.LeftMargin;
  MR.Value := FDialogCtr.FSecProp.RightMargin;
  MH.Value := FDialogCtr.FSecProp.MarginHeader;
  MF.Value := FDialogCtr.FSecProp.MarginFooter;

  //NOT HERE ! GetPrinterProperties(w, h);

  OldMT := MT.Value;
  OldML := ML.Value;
  OldMB := MB.Value;
  OldMR := MR.Value;

  if FDialogCtr.FSecProp.Landscape then
    Orientation.ItemIndex := 1
  else
    Orientation.ItemIndex := 0;

  PaperSizeChange(nil);
end;

procedure TWPPageProp.GetPrinterProperties(var w, h: Integer);
{$IFDEF DISABLEPRINTER}
begin
  w := 0;
  h := 0;
end;
{$ELSE}
var
  DevMode: PDeviceMode;
  ADevice, ADriver, APort: array[0..256] of Char;
  ADeviceMode: THandle;
  i, MinT, MinL, id : Integer;
  aPrinterName : string;
  aPrinterHandleDC : HDC;
begin
  Printer.GetPrinter(ADevice, ADriver, APort, ADeviceMode);
  DevMode := GlobalLock(ADeviceMode);
  if DevMode <> nil then
  try
      FLocked := TRUE;

      if (DevMode^.dmFields and DM_DEFAULTSOURCE) <> 0 then
      begin
        // ignored

      end;

      if (DevMode^.dmFields and DM_DUPLEX) <> 0 then
      begin
         // Devmode^.dmDuplex := dmdup_simplex;
         // Devmode^.dmDuplex := dmdup_vertical;
         // ignored
      end;

      if DevMode^.dmPaperSize=DMPAPER_USER then
      begin
         w := WPCentimeterToTwips(DevMode^.dmPaperWidth*100);
         h := WPCentimeterToTwips(DevMode^.dmPaperLength*100);
         cbxPaperSize.ItemIndex := 0; // custom
      end else
      begin
         i := EditBox.PaperDefs.FindDef(DevMode^.dmPaperSize);
         if i>=0 then
         begin
            w := EditBox.PaperDefs[i].Width;
            h := EditBox.PaperDefs[i].Height;
            id := EditBox.PaperDefs[i].ID;
            PW.Value := w;
            PH.Value := h;
            for i:=1 to cbxPaperSize.Items.Count-1 do
              if Integer(cbxPaperSize.Items.Objects[i])=id then
                   begin
                     cbxPaperSize.ItemIndex := i;
                     break;
                   end;
         end;
      end;



      if Printer.Orientation = poPortrait then
            Orientation.ItemIndex := 0
      else  Orientation.ItemIndex := 1;

      // Calculate minimum Margins
      if not FNoMimimumMargins then
      begin
         aPrinterName := Printer.Printers[Printer.PrinterIndex];
         aPrinterHandleDC := CreateDC(nil, PChar(aPrinterName), nil, nil);
         if aPrinterHandleDC <> 0 then
         try
            MinT := Round(GetDeviceCaps(aPrinterHandleDC, PhysicalOffsetY) * 1440
                 / GetDeviceCaps(aPrinterHandleDC, LogPixelsY));
            MinL := Round(GetDeviceCaps(aPrinterHandleDC, PhysicalOffsetX) * 1440
                / GetDeviceCaps(aPrinterHandleDC, LogPixelsX));
            if (MT.Value < MinT) then MT.Value := MinT;
            if (ML.Value < MinL) then ML.Value := MinL;
            if (MB.Value < MinT) then MB.Value := MinT;
            if (MR.Value < MinL) then MR.Value := MinL;
         finally
           DeleteDC(aPrinterHandleDC);
         end;
      end; // if not FNoMimimumMargins then

  finally
    GlobalUnlock(ADeviceMode);
    FLocked := FALSE;
  end; // if DevMode
end;
{$ENDIF}

procedure TWPPageProp.btnOKClick(Sender: TObject);
begin
  if (FDialogCtr.EditBox<>nil) then
        FDialogCtr.EditBox.Changing;
  try
  FDialogCtr.FSecProp.BeginUpdate;
  FDialogCtr.FSecProp.Landscape := (Orientation.ItemIndex = 1);
  FDialogCtr.FSecProp._Layout.paperw := PW.Value;
  FDialogCtr.FSecProp._Layout.paperh := PH.Value;
  FDialogCtr.FSecProp.TopMargin := MT.Value;
  FDialogCtr.FSecProp.BottomMargin := MB.Value;
  FDialogCtr.FSecProp.LeftMargin := ML.Value;
  FDialogCtr.FSecProp.RightMargin := MR.Value;
  FDialogCtr.FSecProp.MarginHeader := MH.Value;
  FDialogCtr.FSecProp.MarginFooter := MF.Value;
  FDialogCtr.FSecProp.EndUpdate;
  finally
  if (FDialogCtr.EditBox<>nil) then
        FDialogCtr.EditBox.ChangeApplied;
  end;
  ModalResult := mrOK;
end;

procedure TWPPageProp.MLUnitChange(Sender: TObject);
begin
  GlobalValueUnit := TWPValueEdit(Sender).UnitType;
  PH.UnitType := GlobalValueUnit;
  PW.UnitType := GlobalValueUnit;
  ML.UnitType := GlobalValueUnit;
  MR.UnitType := GlobalValueUnit;
  MT.UnitType := GlobalValueUnit;
  MB.UnitType := GlobalValueUnit;
  MH.UnitType := GlobalValueUnit;
  MF.UnitType := GlobalValueUnit;
end;

procedure TWPPageProp.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
  begin
    ModalResult := mrCancel;
    Key := #0;
  end;
end;

procedure TWPPageProp.btnPrinterClick(Sender: TObject);
var
  w, h, i: Integer;
begin
  if Sender=nil then exit;
  {$IFNDEF DISABLEPRINTER}
  i := Printer.PrinterIndex;
  If EditBox<>nil then
  begin
     if Orientation.ItemIndex=0 then
          EditBox.UpdatePrinterProperties(Printer,0, PW.Value, PH.Value)
     else EditBox.UpdatePrinterProperties(Printer,0, PH.Value, PW.Value);
  end;
  if PSD.Execute then
  begin
    // If we do not have that list get it now!
    if ((i<>Printer.PrinterIndex) or not
       (ppoGetPrinterPaperList in FDialogCtr.FOptions)) and
       (FDialogCtr<>nil) then
        EditBox.PaperDefs.Init(true);
    w := MulDiv(GetDeviceCaps(Printer.Handle, PHYSICALWIDTH), 1440,
        GetDeviceCaps(Printer.Handle, LOGPIXELSX)); ;
    h := MulDiv(GetDeviceCaps(Printer.Handle, PHYSICALHEIGHT), 1440,
        GetDeviceCaps(Printer.Handle, LOGPIXELSY));

    UpdatePaperList(w, h);
    GetPrinterProperties(w, h);
    FindPagerSize := TRUE;
    FindPagerSize := FALSE;
    PW.Value := w;
    PH.Value := h;
  end;
  {$ENDIF}
end;

procedure TWPPageProp.UpdatePaperList(w, h: Integer);
var
  i: Integer;
begin
  cbxPaperSize.Items.Clear;
  //if ppoGetPrinterPaperList in FDialogCtr.Options then
  cbxPaperSize.Items.Add(WPLoadStr(mePaperCustom));

  for i := 0 to EditBox.PaperDefs.Count - 1 do
    cbxPaperSize.Items.AddObject(
      EditBox.PaperDefs[i].DisplayName,
      TObject(EditBox.PaperDefs[i].ID));
  if (w>0) and (h>0) then
  begin
   i := EditBox.PaperDefs.FindWH(W, H);
   if i < 0 then
    cbxPaperSize.ItemIndex := 0
   else
    cbxPaperSize.ItemIndex := i + 1;
  end else
  begin
     cbxPaperSize.ItemIndex := 0; // Custom!
  end;
end;

procedure TWPPageProp.PaperSizeChange(Sender: TObject);
begin
  PagePreview.Invalidate;
  CheckPaperSize;
end;

procedure TWPPageProp.MLChange(Sender: TObject);
begin
  if not (OldML = ML.Value) then
  begin
    OldML := ML.Value;
    PagePreview.Invalidate;
  end;
end;

procedure TWPPageProp.MTChange(Sender: TObject);
begin
  if not (OldMT = MT.Value) then
  begin
    OldMT := MT.Value;
    PagePreview.Invalidate;
  end;
end;

procedure TWPPageProp.MRChange(Sender: TObject);
begin
  if not (OldMR = MR.Value) then
  begin
    OldMR := MR.Value;
    PagePreview.Invalidate;
  end;
end;

procedure TWPPageProp.MBChange(Sender: TObject);
begin
  if not (OldMB = MB.Value) then
  begin
    OldMB := MB.Value;
    PagePreview.Invalidate;
  end;
end;

procedure TWPPageProp.MHChange(Sender: TObject);
begin
  if PagePreview<>nil then PagePreview.Invalidate;
end;


procedure TWPPageProp.CheckMargins(Sender: TObject);
begin
  if (ML.Value < MinML) then ML.Value := MinML;
  if (ML.Value > (PW.Value - MR.Value)) then ML.Value := PW.Value - MR.Value;
  if (MT.Value < MinMT) then MT.Value := MinMT;
  if (MT.Value > (PH.Value - MB.Value)) then MT.Value := PH.Value - MB.Value;
  if (MR.Value < MinMR) then MR.Value := MinMR;
  if (MR.Value > (PW.Value - ML.Value)) then MR.Value := PW.Value - ML.Value;
  if (MB.Value < MinMB) then MB.Value := MinMB;
  if (MB.Value > (PH.Value - MT.Value)) then MB.Value := PH.Value - MT.Value;
end;

procedure TWPPageProp.cbxPaperSizeChange(Sender: TObject);
var
  def: TWPPaperDefinition;
begin
  if (cbxPaperSize.ItemIndex > 0) and not FLocked then
  try
    FLocked := TRUE;
    def := TWPPaperDefinition(EditBox.PaperDefs.FindItemID(
      Integer(cbxPaperSize.Items.Objects[cbxPaperSize.ItemIndex])));
    if def <> nil then
    begin
      pw.Value := def.Width;
      ph.Value := def.Height;
    end;
  finally
    FLocked := FALSE;
  end;
  SetPWandPH;
  PagePreview.Invalidate;
end;

procedure TWPPageProp.CheckPaperSize;
var
  i, id: Integer;
begin
  if not FLocked and (EditBox <> nil) then
  begin
    i := EditBox.PaperDefs.FindWH(pw.Value, ph.Value);
    if i >{=} 0 then     //V4.11e
    begin
      id := EditBox.PaperDefs[i].ID;
      for i := 0 to cbxPaperSize.Items.Count - 1 do
        if Integer(cbxPaperSize.Items.Objects[i]) = id then
        begin
          cbxPaperSize.ItemIndex := i;
          break;
        end;
    end;
    SetPWandPH;
  end;
end;

procedure TWPPageProp.SetPWandPH;
begin
  if cbxPaperSize.ItemIndex = 0 then
  begin
    PW.Enabled := true;
    PH.Enabled := true;
    PW.Color := clWindow;
    PH.Color := clWindow;
  end
  else
  begin
    PW.Enabled := false;
    PH.Enabled := false;
    PW.Color := clBtnFace;
    PH.Color := clBtnFace;
  end;
end;

procedure TWPPageProp.PagePreviewPaint(Sender: TObject);
var
  pagrect, txtrect: TRect;
  clh: Single;
  w, h, r, l, t, b, r_w, r_h: Integer;
  HeaderFooterRect: TRect;
begin
  if Orientation.ItemIndex <= 0 then
  begin
    w := PW.Value;
    h := PH.Value;
  end
  else
  begin
    h := PW.Value;
    w := PH.Value;
  end;

  r := MR.Value;
  l := ML.Value;
  t := MT.Value;
  b := MB.Value;

  if w > h then
    r_w := w
  else
    r_w := h;
  if r_w=0 then r_w := 1;

  clh := (PagePreview.Height - 20) / r_w;

  r_w := Round(w * clh);
  r_h := Round(h * clh);

  if r_h=0 then r_h := 1;

  pagrect.Left := (PagePreview.Width - r_w) div 2;
  pagrect.Top := (PagePreview.Height - r_h) div 2;
  pagrect.Right := pagrect.Left + r_w;
  pagrect.Bottom := pagrect.Top + r_h;

  if WPAllDialogsBitmap<>nil then
    WPDrawShade(PagePreview.Canvas, PagePreview.ClientRect, 192 - 128, WPShadedFormHorizontal, WPShadedFormBothWays,
      WPAllDialogsBitmap, true, Color);


  with PagePreview.Canvas do
  begin
    Pen.Style := psSolid;
    Pen.Width := 1;
    Pen.Color := clBlack;
    Brush.Style := bsClear;
    Rectangle(pagrect.Left + 1, pagrect.Top + 1, pagrect.Right + 1, pagrect.Bottom + 1);
    Brush.Style := bsSolid;
    Brush.Color := clWhite;
    Rectangle(pagrect.Left, pagrect.Top, pagrect.Right, pagrect.Bottom);

    InflateRect(pagrect, -1, -1);
    txtrect.Left := pagrect.Left + Round(l * clh);
    txtrect.Right := pagrect.Right - Round(r * clh);
    Brush.Style := bsClear;
    if MH.Visible then
    begin
      HeaderFooterRect := txtrect;
      HeaderFooterRect.Top := pagrect.Top + Round(MH.Value * clh);
      HeaderFooterRect.Bottom := pagrect.Top + Round(t * clh) - 1;
      if HeaderFooterRect.Bottom > HeaderFooterRect.Top then
      begin
        Pen.Style := psDot;
        Pen.Color := clGreen;
        Rectangle(HeaderFooterRect.Left, HeaderFooterRect.Top, HeaderFooterRect.Right, HeaderFooterRect.Bottom);
      end;
      HeaderFooterRect.Top := pagrect.Bottom - Round(b * clh) + 1;
      HeaderFooterRect.Bottom := pagrect.Bottom - Round(MF.Value * clh) - 1;
      if HeaderFooterRect.Bottom > HeaderFooterRect.Top then
      begin
        Pen.Style := psDot;
        Pen.Color := clGreen;
        Rectangle(HeaderFooterRect.Left, HeaderFooterRect.Top, HeaderFooterRect.Right, HeaderFooterRect.Bottom);
      end;
    end;

    Pen.Style := psSolid;
    Pen.Color := clBlack;
    txtrect.Top := pagrect.Top + Round(t * clh);
    txtrect.Bottom := pagrect.Bottom - Round(b * clh);

    w := txtrect.Top + 1;
    h := Round(288 * clh); { 5 lines / inch }
    r := 1;
    if h <= 0 then h := 1;

    if txtrect.Right > txtrect.Left then
    begin
      t := (txtrect.Right - txtrect.Left) div 4;
      while w < txtrect.Bottom do
      begin
        MoveTo(txtrect.Left + 1, w);
        if r = 4 then
          LineTo(txtrect.Right - t, w)
        else if (r < 5) then
          LineTo(txtrect.Right - 1, w)
        else
          r := 0;
        inc(w, h);
        inc(r);
      end;
    end;

    if not MH.Visible then
    begin
      Pen.Style := psDot;
      Pen.Color := clGray;
      Brush.Style := bsClear;
      Rectangle(txtrect.Left, txtrect.Top, txtrect.Right, txtrect.Bottom);
    end;
  end;
end;

procedure TWPPageProp.OrientationClick(Sender: TObject);
begin
  PagePreview.Invalidate;
end;

procedure TWPPageProp.FormShow(Sender: TObject);
begin
 // PreviewPanel.UseGlobal;
end;


procedure TWPPageProp.PaintBox1Paint(Sender: TObject);
begin
  if WPAllDialogsBitmap<>nil then
    WPDrawShade(PaintBox1.Canvas, PaintBox1.ClientRect, 192 - 128, WPShadedFormHorizontal, WPShadedFormBothWays,
      WPAllDialogsBitmap, true, Color);
end;

end.

