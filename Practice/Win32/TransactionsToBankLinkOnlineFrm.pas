unit TransactionsToBankLinkOnlineFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ovcbase, ovcef, ovcpb, ovcpf, Buttons, OSFont;

type
  TfrmTransactionsToBankLinkOnline = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    lblTransactionsExportableTo: TLabel;
    Label3: TLabel;
    btnNext: TSpeedButton;
    btnQuik: TSpeedButton;
    btnPrev: TSpeedButton;
    eDateFrom: TOvcPictureField;
    CheckBox1: TCheckBox;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmTransactionsToBankLinkOnline: TfrmTransactionsToBankLinkOnline;

implementation

{$R *.dfm}

end.
