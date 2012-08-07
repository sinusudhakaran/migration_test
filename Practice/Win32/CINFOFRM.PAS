// Client Info
unit Cinfofrm; 
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,
  OSFont, StrUtils;

type
  TfrmCinfo = class(TForm)
    btnClose: TButton;
    PageControl1: TPageControl;
    Bevel1: TBevel;
    tabGeneral: TTabSheet;
    TabStats: TTabSheet;
    lvAccounts: TListView;
    lblChartUpdated: TLabel;
    Label1: TLabel;
    chShow: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lblCodes: TLabel;
    lblPayees: TLabel;
    lblBanks: TLabel;
    lblTrans: TLabel;
    lblMem: TLabel;
    lblLoad: TLabel;
    Image1: TImage;
    Label10: TLabel;
    lblName: TLabel;
    lblCode: TLabel;
    Label2: TLabel;
    lblBudget: TLabel;
    Image2: TImage;
    lblForeign: TLabel;
    Label11: TLabel;
    lblSaveCount: TLabel;
    lblBelongs: TLabel;
    lblPractice: TLabel;
    pnlAdminInfo: TPanel;
    Label12: TLabel;
    lblCLRN: TLabel;
    Label13: TLabel;
    lblFileSize: TLabel;
    Label14: TLabel;
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private declarations }
    procedure SetUpHelp;
  public
    { Public declarations }
  end;

procedure ShowClientProperties;

//******************************************************************************
implementation
{$R *.DFM}
uses
   globals,
   bkdefs,
   bkDateUtils,
   bkHelp,
   bkXPThemes,
   admin32,
   Imagesfrm,
   syDefs,
   bkConst, SysObj32, cfList32;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCinfo.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  lblForeign.Font.Style := [fsBold];
  image1.Picture := AppImages.imgBankLinkB.Picture;
  image2.Picture := AppImages.imgBankLinkB.Picture;
  SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCinfo.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   chShow.Hint :=
               'Check this to show this form when a Client File is opened|' +
               'Check this to show this form automatically when you open a Client File';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCinfo.FormShow(Sender: TObject);
var
   t, i : integer;
   ListItem : TListItem;
   TransCount : integer;
   pCF        : pClient_File_Rec;
   d          : double;
begin
   PageControl1.ActivePage := tabGeneral;
   BKHelpSetUp( Self, bkHelp.BKH_Client_file_information);

   lvAccounts.Items.Clear;
   chShow.checked := INI_ShowClientProperties;

   with MyClient, MyClient.clFields do
   begin
     lblName.Caption := clName;
     lblCode.Caption := clCode;

     d := clRawStreamSize;
     lblFileSize.Caption := FormatFloat('#,##0;', d);
     
     if clChart_Last_Updated <> 0 then
       lblChartUpdated.Caption := 'Chart last updated on '+ bkDate2Str(clChart_Last_Updated)
     else
       lblChartUpdated.caption := 'Chart has never been updated.';


     lblCodes.Caption := inttostr( clChart.ItemCount );
     lblPayees.Caption:= inttostr( clPayee_List.ItemCount );
     lblBanks.Caption := inttostr( clBank_Account_List.ItemCount );
     lblSaveCount.Caption := inttostr( clFile_Save_Count );

     //Show which pratice owns this client
     if ( Trim( clPractice_Name ) <> '' ) then begin
        lblPractice.caption := clPractice_Name;
     end
     else begin
        lblPractice.visible := false;
        lblBelongs.visible := false;
     end;

     t := 0;
     for i := 0 to clBank_Account_List.ItemCount -1 do with clBank_Account_List.Bank_Account_At(i) do
     begin
        t := t + baTransaction_List.ItemCount;

        {add bank accounts}
        with lvAccounts do
        begin
           ListItem := Items.Add;
           ListItem.Caption := baFields.baBank_Account_Number;
           ListItem.SubItems.Add(AccountName);
           TransCount := baTransaction_List.itemCount;
           ListItem.SubItems.Add(inttostr(TransCount));
           if TransCount > 0 then
           begin
             ListItem.SubItems.Add(bkDate2Str(baTransaction_List.transaction_at(0)^.txDate_Effective));
             ListItem.SubItems.Add(bkDate2Str(baTransaction_List.Transaction_At(baTransaction_List.ItemCount-1)^.txDate_Effective));
           end;
        end;
     end;
     lblTrans.Caption := inttostr(t);

     t := 0;
     for i := 0 to clBank_Account_List.ItemCount -1 do
        t := t + clBank_Account_List.Bank_Account_At(i).baMemorisations_List.ItemCount;
     lblmem.Caption := inttostr(t);

     lblBudget.Caption := inttostr(clBudget_List.itemCount);

     lblLoad.caption := inttoStr(clFile_Load_Time)+' ms.';

     lblForeign.Visible := false;
     pnlAdminInfo.Visible := false;
     RefreshAdmin;

     if Assigned( AdminSystem) then
     begin
       lblForeign.Visible := (clMagic_Number <> AdminSystem.fdFields.fdMagic_Number);
       pnlAdminInfo.Visible := true;

       case clDownload_From of
         dlAdminSystem : lblForeign.caption := 'New Data cannot be downloaded into this Client File.  It belongs to another Admin System.';
       else
         lblForeign.caption := 'New Data cannot be downloaded into this Client File.  It is an Off-site Client File.';
       end;

       pCF := AdminSystem.fdSystem_Client_File_List.FindCode( MyClient.clFields.clCode);
       if Assigned( pCF) then
       begin
         lblCLRN.Caption := inttostr( pCF^.cfLRN);
       end
       else
       begin
         lblCLRN.Caption := 'Unknown';
       end;
     end;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCinfo.btnCloseClick(Sender: TObject);
begin
   INI_ShowClientProperties := chShow.Checked;
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ShowClientProperties;
var
   MyDlg : TfrmCinfo;
begin
   if not Assigned(myClient) then exit;

   MyDlg := TFrmCInfo.Create(Application.MainForm);
   try
     MyDlg.ShowModal;
   finally
     MyDlg.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCinfo.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePage = tabGeneral then
    BKHelpSetUp( Self, BKHelp.BKH_Client_file_information)
  else
    BKHelpSetUp( Self, 0);
end;

end.
