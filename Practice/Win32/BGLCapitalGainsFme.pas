unit BGLCapitalGainsFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ovcbase, ovcef, ovcpb, ovcnf, StdCtrls;

type
  TfmeBGLCapitalGainsTax = class(TFrame)
    lblCGTDiscounted: TLabel;
    nfCGTDiscounted: TOvcNumericField;
    lpCGTDiscounted: TLabel;
    lblCGTIndexation: TLabel;
    nfCGTIndexation: TOvcNumericField;
    lpCGTIndexation: TLabel;
    lblCGTOther: TLabel;
    nfCGTOther: TOvcNumericField;
    lpCGTOther: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
