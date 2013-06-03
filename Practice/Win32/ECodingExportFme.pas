unit ECodingExportFme;
//------------------------------------------------------------------------------
{
   Title:        ECoding Export Options Frame

   Description:

   Author:

   Remarks:     Used by ECodingOptionsFrm.pas
                        ExportToECodingDlg.pas
}
//------------------------------------------------------------------------------

interface

uses
  clObj32, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

  
type
  TEcOptions = record
    Code           : string;
    Include        : byte;
    IncludeChart   : boolean;
    IncludePayees  : boolean;
    IncludeJobs    : boolean;
    AllowUPIs      : Boolean;
    ShowAccount    : Boolean;
    ShowQuantity   : boolean;
    ShowPayees     : Boolean;
    ShowGST        : Boolean;
    ShowTaxInvoice : Boolean;
    ShowSuperFields: Boolean;
    Password       : string;
    Attachments    : string;
    HideClientSpecific : boolean;
    WebSpace       : Integer;
    WebFormat      : Byte;
    WebNotify      : Integer;
  end;



type
  TfmeECodingExport = class(TFrame)
    Label5: TLabel;
    lblWhichClients: TLabel;
    lblPassword: TLabel;
    cmbInclude: TComboBox;
    chkIncludeChart: TCheckBox;
    chkIncludePayees: TCheckBox;
    chkShowQuantity: TCheckBox;
    chkShowGST: TCheckBox;
    chkShowTaxInv: TCheckBox;
    chkShowAccount: TCheckBox;
    edtPassword: TEdit;
    chkAddUPIs: TCheckBox;
    lblWebSpace: TLabel;
    cmbWebSpace: TComboBox;
    edtConfirm: TEdit;
    lblConfirm: TLabel;
    ChkSuperfund: TCheckBox;
    chkIncludeJobs: TCheckBox;
    ChkNotifyClient: TCheckBox;
    ChkNotifyMe: TCheckBox;
    lNotify: TLabel;
    procedure chkIncludeChartClick(Sender: TObject);
    procedure chkShowAccountClick(Sender: TObject);
  private
    FExportDestination: Byte;
    FWebExportType: Byte;
    FWebExportFormat: Byte;
    procedure SetExportDestination(const Value: Byte);
    procedure SetWebExportFormat(const Value: Byte);
    function GetAdmin(ClientCode: string): Boolean;
    function SetAdmin(ClientCode: string): Boolean;
    { Private declarations }
  public
    { Public declarations }
    procedure SetupDialog;
    procedure UpdateControlsOnForm;
    property ExportDestination: Byte read FExportDestination write SetExportDestination;
    property WebExportFormat: Byte read FWebExportFormat write SetWebExportFormat;

    procedure ShowSuperFields(Value: Boolean);
    procedure SetOptions(const Options: TEcOptions); overload;
    procedure SetOptions(const aClient: TClientObj); overload;

    procedure GetOptions(var Options: TECOptions); overload;
    procedure GetOptions(var aClient: TClientObj); overload;
  end;

//******************************************************************************
implementation

{$R *.dfm}

uses
  admin32,
  ComboUtils,
  WebXOffice,
  Globals,
  syDefs,
  BKCONST,
  glConst,
  bkBranding;

procedure TfmeECodingExport.chkIncludeChartClick(Sender: TObject);
begin
  UpdateControlsOnForm;
end;

procedure TfmeECodingExport.chkShowAccountClick(Sender: TObject);
begin
  UpdateControlsOnForm;
end;


function TfmeECodingExport.SetAdmin(ClientCode: string): Boolean;
var lClientRec: pClient_File_Rec;
begin
  Result := True;
  if (FExportDestination <> ecDestWebX)
  or (FWebExportFormat <> wfWebNotes)
  or (not Assigned(AdminSystem)) then
     Exit;

  chkNotifyMe.Visible := true;
  chkNotifyClient.Visible := true;
  lNotify.Visible := true;

  lClientRec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);
  if Assigned(lClientRec) then begin
     chkNotifyMe.Checked := (lClientRec.cfWebNotes_Email_Notifications and wnDontNotifyMe) = 0;
     chkNotifyClient.Checked := (lClientRec.cfWebNotes_Email_Notifications and wnDontNotifyClient) = 0;
  end else
     Result := False;
end;

procedure TfmeECodingExport.GetOptions(var aClient: TClientObj);
begin
   aClient.clFields.clECoding_Entry_Selection    := cmbInclude.ItemIndex;
   aClient.clFields.clECoding_Dont_Send_Chart    := not chkIncludeChart.checked;
   aClient.clFields.clECoding_Dont_Send_Payees   := not chkIncludePayees.Checked;
   aClient.clExtra.ceECoding_Dont_Send_Jobs      := not chkIncludeJobs.Checked;
   aClient.clFields.clECoding_Dont_Allow_UPIs    := not chkAddUPIs.Checked;
   aClient.clFields.clECoding_Dont_Show_Account  := not chkShowAccount.Checked;
   aClient.clFields.clECoding_Dont_Show_Quantity := not chkShowQuantity.checked;
   aClient.clFields.clECoding_Dont_Show_GST      := not chkShowGST.Checked;
   aClient.clFields.clECoding_Dont_Show_TaxInvoice := not chkShowTaxInv.Checked;
   aClient.clFields.clECoding_Default_Password   := edtPassword.text;
   aClient.clFields.clECoding_Send_Superfund := ChkSuperfund.Checked;

   if (FExportDestination = ecDestWebX) then begin
      if not GetAdmin(AClient.clFields.clCode) then begin
         // Got here via NewClientWiz, do it myself..
        aClient.clFields.clTemp_FRS_From_Date  := 0;
        if (not chkNotifyMe.Checked) then
           aClient.clFields.clTemp_FRS_From_Date := wnDontNotifyMe;
        if (not chkNotifyClient.Checked) then
           aClient.clFields.clTemp_FRS_From_Date := aClient.clFields.clTemp_FRS_From_Date or wnDontNotifyClient;
      end;

      aClient.clFields.clWeb_Export_Format := FWebExportFormat{ComboUtils.GetComboCurrentIntObject(cmbWebFormats, 0)};
      if ({aClient.clFields.clWeb_Export_Format} FWebExportFormat = wfWebX) then
         aClient.clFields.clECoding_WebSpace := ComboUtils.GetComboCurrentIntObject(cmbWebspace)
   end;
end;

procedure TfmeECodingExport.GetOptions(var Options: TECOptions);
begin
   Options.Include        := cmbInclude.ItemIndex;
   Options.IncludeChart   := chkIncludeChart.Checked;
   Options.IncludePayees  := chkIncludePayees.Checked;
   Options.IncludeJobs    := chkIncludeJobs.Checked;
   Options.AllowUPIs      := chkAddUPIs.Checked;
   Options.ShowAccount    := chkShowAccount.Checked;
   Options.ShowQuantity   := chkShowQuantity.Checked;
   Options.ShowPayees     := chkIncludePayees.Checked;
   Options.ShowGST        := chkShowGST.Checked;
   Options.ShowTaxInvoice := chkShowTaxInv.Checked;
   Options.Password       := Trim(edtPassword.Text);
   Options.ShowSuperFields := ChkSuperfund.Checked;

   if (FExportDestination = ecDestWebX) then begin
      Options.WebFormat := FWebExportFormat {ComboUtils.GetComboCurrentIntObject(cmbWebFormats, 0)};
      if not GetAdmin(Options.Code) then begin
        // Got here via NewClientWiz, do it myself..
        Options.WebNotify  := 0;
        if (not chkNotifyMe.Checked) then
           Options.WebNotify := wnDontNotifyMe;
        if (not chkNotifyClient.Checked) then
           Options.WebNotify := Options.WebNotify or wnDontNotifyClient;
      end;
      if ({Options.WebFormat} FWebExportFormat = wfWebX)  then begin
         Options.WebSpace :=  ComboUtils.GetComboCurrentIntObject(cmbWebspace);
      end;
   end;
end;

function TfmeECodingExport.GetAdmin(ClientCode: string): Boolean;
var lClientRec: pClient_File_Rec;
begin
  Result := True;
  if (FExportDestination <> ecDestWebX) // Not doining webExport
  or (FWebExportFormat <> wfWebNotes)   // Not Doing WebNotes
  or (not Assigned(AdminSystem)) then   // savety net (Books)
     Exit;

  lClientRec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);
  if Assigned(lClientRec) then begin
     if (chkNotifyMe.Checked = ((lClientRec.cfWebNotes_Email_Notifications and wnDontNotifyMe) = 0))
     and (chkNotifyClient.Checked = ((lClientRec.cfWebNotes_Email_Notifications and wnDontNotifyClient) = 0)) then
        Exit; // nothing to save..
  end else begin
     // Got here via NewClientWiz, Have to save back to Client
     Result := False;
     Exit;
  end;

  // get new admin...
  if LoadAdminSystem(True,'EmailNotification') then begin
     lClientRec := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);
     if Assigned(lClientRec) then begin
        lClientRec.cfWebNotes_Email_Notifications := 0;
        if (not chkNotifyMe.Checked) then
           lClientRec.cfWebNotes_Email_Notifications := wnDontNotifyMe;
        if (not chkNotifyClient.Checked) then
           lClientRec.cfWebNotes_Email_Notifications := lClientRec.cfWebNotes_Email_Notifications or wnDontNotifyClient;
     end;
     SaveAdminSystem;
  end;

end;

procedure TfmeECodingExport.SetExportDestination(const Value: Byte);

begin
  FExportDestination := Value;
  // The Destination gets set first,
  // Later the actual format gets set..

  case FExportDestination of
     ecDestWebX : begin
        // No Passwords
        edtPassword.Visible := False;
        edtConfirm.Visible := False;
        lblPassword.Visible := False;
        LblConfirm.Visible := False;
     end;

     else begin
        Caption := bkBranding.NotesProductName + ' Options';
        edtPassword.Visible := True;
        edtConfirm.Visible := True;
        LblPassword.Visible := True;
        LblConfirm.Visible := True;

        cmbWebSpace.Visible := False;
        lblWebSpace.Visible := False;
        ChkNotifyClient.Visible := False;
        ChkNotifyMe.Visible := False;
        lNotify.Visible := False;
     end;
  end;//Case
end;

procedure TfmeECodingExport.SetOptions(const aClient: TClientObj);
begin

  if (aClient.clFields.clECoding_Entry_Selection in [ esAllEntries, esUncodedOnly]) then
     cmbInclude.ItemIndex := aClient.clFields.clECoding_Entry_Selection
  else
     cmbInclude.ItemIndex := 0;

  ChkSuperfund.Checked     := aClient.clFields.clECoding_Send_Superfund;
  chkIncludeChart.Checked  := not aClient.clFields.clECoding_Dont_Send_Chart;
  chkIncludePayees.Checked := not aClient.clFields.clECoding_Dont_Send_Payees;
  chkIncludeJobs.Checked   := not aClient.clExtra.ceECoding_Dont_Send_Jobs;
  chkAddUPIs.Checked       := not aClient.clFields.clECoding_Dont_Allow_UPIs;
  chkShowAccount.Checked   := not aClient.clFields.clECoding_Dont_Show_Account;
  chkShowQuantity.checked  := not aClient.clFields.clECoding_Dont_Show_Quantity;
  chkShowGST.Checked       := not aClient.clFields.clECoding_Dont_Show_GST;
  chkShowTaxInv.Checked    := not aClient.clFields.clECoding_Dont_Show_TaxInvoice;
  edtPassword.Text         := aClient.clFields.clECoding_Default_Password;
  edtConfirm.Text          := aClient.clFields.clECoding_Default_Password;
  WebExportFormat          := aClient.clFields.clWeb_Export_Format;

  if cmbWebSpace.Visible then
    ComboUtils.SetComboIndexByIntObject(aClient.clFields.clECoding_WebSpace, cmbWebspace);

  if not SetAdmin(AClient.clFields.clCode) then begin
     // Via NewClientWiz, Not in admin yet, so do it myself...
     chkNotifyMe.Checked := (aClient.clFields.clTemp_FRS_From_Date and wnDontNotifyMe) = 0;
     chkNotifyClient.Checked := (aClient.clFields.clTemp_FRS_From_Date and wnDontNotifyClient) = 0;
  end;

end;

procedure TfmeECodingExport.SetOptions(const Options: TEcOptions);

   procedure SetShowDetails(Value: Boolean);
   begin
      cmbWebSpace.Visible := Value and (FExportDestination = ecDestWebX);
      lblWebSpace.Visible := Value and (FExportDestination = ecDestWebX);

      edtPassword.Visible := Value and (FExportDestination <> ecDestWebX);
      lblPassword.Visible := Value and (FExportDestination <> ecDestWebX);
      edtConfirm.Visible := Value and (FExportDestination <> ecDestWebX);
      lblConfirm.Visible  := Value and (FExportDestination <> ecDestWebX);
   end;

begin

    if Options.Include in [ esAllEntries, esUncodedOnly] then
       cmbInclude.itemIndex := Options.Include
    else
       cmbInclude.ItemIndex := 0;

    chkIncludeChart.checked    := Options.IncludeChart;
    chkIncludePayees.Checked   := Options.IncludePayees;
    chkIncludeJobs.Checked     := Options.IncludeJobs;
    chkAddUPIs.Checked         := Options.AllowUPIs;
    chkShowAccount.Checked     := Options.ShowAccount;
    chkShowQuantity.Checked    := Options.ShowQuantity;
    chkShowGST.Checked         := Options.ShowGST;
    chkShowTaxInv.Checked      := Options.ShowTaxInvoice;

    edtPassword.Text           := Options.Password;
    edtConfirm.Text            := Options.Password;
    ChkSuperfund.Checked       := Options.ShowSuperFields;

    SetShowDetails(not Options.HideClientSpecific);

    if FExportDestination = ecDestWebX then begin
       WebExportFormat := Options.WebFormat;

       if cmbWebSpace.Visible then
         ComboUtils.SetComboIndexByIntObject(Options.WebSpace, cmbWebspace);

       if not SetAdmin(Options.Code) then begin
           // Via NewClientWiz, Not in admin yet, so do it myself...
           chkNotifyMe.Checked := (Options.WebNotify and wnDontNotifyMe) = 0;
           chkNotifyClient.Checked := (Options.WebNotify and wnDontNotifyClient) = 0;
       end;
    end;

end;

procedure TfmeECodingExport.SetupDialog;
var i: Integer;
begin
     //set up frame
   cmbInclude.Clear;
   for i := esAllEntries to esUncodedOnly do
     cmbInclude.Items.Add( esNames[ i]);
end;


procedure TfmeECodingExport.SetWebExportFormat(const Value: Byte);

   procedure SetWebXOptions(Value: Boolean);
   begin
      chkIncludeJobs.Enabled := Value;
      chkSuperfund.Enabled := Value;
      chkAddUPIs.Enabled := Value;
   end;

var S : TSTrings;
begin
   FWebExportFormat := Value;
   // This is called after SetExport Destination
   if FExportDestination <> ecDestWebX then
      Exit; // i.e, not now...

   case FWebExportFormat of
   wfNone     :;
   wfWebX     : begin
           SetWebXOptions(False);
           S := TSTringList.Create;
           try
              WebXOffice.ReadSecureAreas(S);
              cmbWebSpace.Clear;
              cmbWebSpace.Items := S;
              cmbWebSpace.ItemIndex := 0;
              cmbWebSpace.Sorted := True;
           finally
              S.Free;
           end;
           cmbWebSpace.Visible := True;
           lblWebSpace.Visible := True;
           ChkNotifyClient.Visible := False;
           ChkNotifyMe.Visible := False;
           lNotify.Visible := False;
      end;
   wfWebNotes : begin
          SetWebXOptions(True);
          cmbWebSpace.Visible := False;
          lblWebSpace.Visible := False;
          if not Assigned(AdminSystem) then begin
             ChkNotifyClient.Visible := False;
             ChkNotifyMe.Visible := False;
             lNotify.Visible := False;
          end;
      end;

   end;

end;

procedure TfmeECodingExport.ShowSuperFields(Value: Boolean);
const sm = 20;
      bg = 26;
begin

   ChkSuperfund.Visible := Value;
   if Value then begin
      chkIncludeChart.Top := 44;
      chkIncludePayees.Top := chkIncludeChart.Top + sm;
      chkIncludeJobs.Top := chkIncludePayees.Top + sm;
      if chkIncludeJobs.Visible then
        ChkSuperfund.Top := chkIncludeJobs.Top + sm
      else
        ChkSuperfund.Top := chkIncludePayees.Top + sm;
      chkAddUPIs.Top := ChkSuperfund.Top + sm;
   end else begin
      chkIncludeChart.Top := 46;
      chkIncludePayees.Top := chkIncludeChart.Top + bg;
      chkIncludeJobs.Top   := chkIncludePayees.Top + bg;
      if chkIncludeJobs.Visible then
        chkAddUPIs.Top := chkIncludeJobs.Top + bg
      else
        chkAddUPIs.Top := chkIncludePayees.Top + bg;
   end;
  
end;

procedure TfmeECodingExport.UpdateControlsOnForm;
begin
  //the show account box must be ticked if the chart is included
  chkShowAccount.Enabled := not chkIncludeChart.Checked;

  if chkIncludeChart.Checked then
    chkShowAccount.Checked := True;
end;





// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
