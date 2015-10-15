unit BGLFrankingFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ovcbase, ovcef, ovcpb, ovcnf, StdCtrls;

type
  TfmeBGLFranking = class(TFrame)
    lblFranked: TLabel;
    nfFranked: TOvcNumericField;
    lpFranked: TLabel;
    lblUnfranked: TLabel;
    nfUnfranked: TOvcNumericField;
    lpUnfranked: TLabel;
    lblFrankingCredits: TLabel;
    nfFrankingCredits: TOvcNumericField;
    btnFrankingCredits: TSpeedButton;
  private
    { Private declarations }
    fMemorisationsOnly : boolean;
    fFrankPercentage: boolean;
    function GetMemorisationsOnly : boolean;
    procedure SetMemorisationsOnly( const Value : boolean );
    function GetFrankPercentage : boolean;
    procedure SetFrankPercentage( const Value : boolean );
  public
    { Public declarations }
    property MemorisationsOnly : boolean read fMemorisationsOnly write SetMemorisationsOnly;
    property FrankPercentage: boolean read fFrankPercentage write SetFrankPercentage;

  end;

implementation
uses
  SuperFieldsUtils;

(*
const
  cFrankPerc   = 'Percentage Franked';
  cUnFrankPerc = 'Percentage Unfranked';
  cFrankAmnt   = 'Franked Amount';
  cUnFrankAmnt = 'Unfranked Amount';
*)

{$R *.dfm}

{ TfmeFranking }

function TfmeBGLFranking.GetMemorisationsOnly: boolean;
begin
  result := fMemorisationsOnly;
end;

procedure TfmeBGLFranking.SetMemorisationsOnly( const Value: boolean );
begin
  fMemorisationsOnly := Value;
  nfFrankingCredits.Enabled := not MemorisationsOnly;
end;

function TfmeBGLFranking.GetFrankPercentage: boolean;
begin
  result := FrankPercentage;
end;

procedure TfmeBGLFranking.SetFrankPercentage(const Value: Boolean);
begin
   FFrankPercentage := Value;
   SetPercentLabel(lpFranked, FrankPercentage);
   SetPercentLabel(lpUnfranked, FrankPercentage);

   btnFrankingCredits.Visible := not FrankPercentage;

(*   if FrankPercentage then begin
      lblFranked.Caption := cFrankPerc;
      lblUnFranked.Caption := cUnFrankPerc;

   end else begin
      lblFranked.Caption := cFrankAmnt;
      lblUnFranked.Caption := cUnFrankAmnt;
   end; *)
end;

end.
