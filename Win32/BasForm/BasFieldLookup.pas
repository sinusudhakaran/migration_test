unit BasFieldLookup;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:

   Written:
   Authors:

   Purpose:

   Notes:
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  bkOKCancelDlg, StdCtrls, Buttons, OvcBase, OvcEF, OvcPB, OvcNF, MoneyDef;

const
   bflAccount = 0;
   bflClass   = 1;

type
  TdlgBasFieldLookup = class(TbkOKCancelDlgForm)
    Label1: TLabel;
    lblGSTClass: TLabel;
    Label3: TLabel;
    lblBoxDesc: TLabel;
    cmbGST: TComboBox;
    cmbTotalType: TComboBox;
    lblAccountCode: TLabel;
    txtCode: TEdit;
    sbtnChart: TSpeedButton;
    Label2: TLabel;
    nfPercent: TOvcNumericField;
    OvcController1: TOvcController;
    Label4: TLabel;
    procedure txtCodeChange(Sender: TObject);
    procedure txtCodeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure txtCodeKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure sbtnChartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbGSTDropDown(Sender: TObject);
  private
    { Private declarations }
    removingMask : boolean;
    procedure DoList;
    procedure SetupHelp;
  public
    { Public declarations }
  end;

  function PickAccountForBAS ( BoxDesc : string; var Account : string; var TotalType : byte; var Percent : Money; HideTotal: Boolean = False) : boolean;
  function PickGSTClassForBAS( BoxDesc : string; GSTClasses : TStringList; var GSTClass : integer; var TotalType : byte; var Percent : Money) : boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
  GenUtils,
  AccountLookupFrm,
  bkConst,
  bkMaskUtils,
  bkXPThemes,
  Globals,
  imagesFrm,
  StdHints;

//------------------------------------------------------------------------------

procedure TdlgBasFieldLookup.DoList;
var s : string;
begin
   s := txtCode.text;
   if PickAccount(s) then txtCode.text := s;
   txtCode.Refresh;
end;
//------------------------------------------------------------------------------

procedure TdlgBasFieldLookup.txtCodeChange(Sender: TObject);
begin
   bkMaskUtils.CheckForMaskChar(txtCode,RemovingMask);
end;
//------------------------------------------------------------------------------

procedure TdlgBasFieldLookup.txtCodeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key = vk_back then bkMaskUtils.CheckRemoveMaskChar(txtCode,RemovingMask);
end;
//------------------------------------------------------------------------------

procedure TdlgBasFieldLookup.txtCodeKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (key = 113) or ((key=40) and (Shift = [ssAlt])) then
     DoList;
end;
//------------------------------------------------------------------------------

procedure TdlgBasFieldLookup.sbtnChartClick(Sender: TObject);
begin
  DoList;
  txtCode.setFocus;
end;
//------------------------------------------------------------------------------

procedure TdlgBasFieldLookup.FormCreate(Sender: TObject);
var
  i : integer;
begin
  inherited;
  bkXPThemes.ThemeForm( Self);

  removingMask      := false;
  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,sbtnChart.Glyph);
  SetUpHelp;
  txtCode.MaxLength := MaxBK5CodeLen;
  //load total type combo
  cmbtotalType.Clear;
  for i := blMin to blMax do begin
     cmbTotalType.Items.Add( blNames[i]);
  end;
  cmbTotalType.ItemIndex := blGross;
  //clear gst items
  cmbGST.Items.Clear;
  //set default percentage
  nfPercent.AsFloat := 100.0;
end;
//------------------------------------------------------------------------------

procedure TdlgBasFieldLookup.SetupHelp;
begin

end;
//------------------------------------------------------------------------------

procedure TdlgBasFieldLookup.cmbGSTDropDown(Sender: TObject);
begin
  inherited;
   //try to set default drop down width
   SendMessage(cmbGST.Handle, CB_SETDROPPEDWIDTH, 345, 0);
end;
//------------------------------------------------------------------------------

function PickAccountForBAS ( BoxDesc : string; var Account : string; var TotalType : byte;
  var Percent : Money; HideTotal: Boolean = False) : boolean;
begin
   result := false;
   with TDlgBasFieldLookup.Create(Application) do begin
       try
          Caption                := 'Add new Account Code to a BAS Field';

          lblBoxDesc.Caption     := BoxDesc;
          lblAccountCode.Visible := true;
          txtCode.Visible        := true;
          sbtnChart.Visible      := true;

          cmbTotalType.Visible := HideTotal;
          Label3.Visible := HideTotal;

          ShowModal;

          if ( ModalResult = mrOK) then begin
             TotalType := cmbTotalType.ItemIndex;
             Account   := Trim( txtCode.Text);
             Percent   := Double2Percent( nfPercent.AsFloat);
             result := ( Account <> '');
          end;
       finally
          Free;
       end;
   end;
end;
//------------------------------------------------------------------------------

function PickGSTClassForBAS( BoxDesc : string; GSTClasses : TStringList; var GSTClass : integer; var TotalType : byte; var Percent : Money) : boolean;
var
   i : integer;
begin
   result := false;
   with TDlgBasFieldLookup.Create(Application) do begin
       try
          Caption              := 'Add new GST Class to a BAS Field';

          lblBoxDesc.Caption   := BoxDesc;
          lblGSTClass.Top      := lblAccountCode.Top;
          lblGSTClass.Visible  := true;
          cmbGST.Top           := txtCode.Top;
          cmbGST.Visible       := true;
          //Load GST Types combo,  only load items that have a id and a description
          //Store the actual gst type in the object value of the item.
          //load 'not assigned' as the first item so it can be selected
          cmbGST.Items.Clear;
          cmbGST.Items.add('Unallocated');

          with GSTClasses do
             for i := 0 to Pred( Count) do begin
                cmbGST.Items.AddObject( GSTClasses[i], Objects[i]);
             end;

          ShowModal;

          if ( ModalResult = mrOK) and ( cmbGST.ItemIndex <> -1) then begin
             TotalType := cmbTotalType.ItemIndex;
             Percent   := Double2Percent( nfPercent.AsFloat);
             if cmbGST.ItemIndex > 0 then begin
                GSTClass := Integer( cmbGST.Items.Objects[ cmbGST.ItemIndex]);
             end
             else
                GSTClass := 0;  //not assigned
             result := true;
          end;
       finally
          Free;
       end;
   end;
end;
//------------------------------------------------------------------------------
end.
