unit BGLInterestIncomeFme;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, ovcbase, ovcef, ovcpb, ovcnf, StdCtrls;

type
  TfmeBGLInterestIncome = class(TFrame)
    lblInterest: TLabel;
    nfInterest: TOvcNumericField;
    lpInterest: TLabel;
    nfOtherIncome: TOvcNumericField;
    lpOtherIncome: TLabel;
    lblOtherIncome: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

end.
