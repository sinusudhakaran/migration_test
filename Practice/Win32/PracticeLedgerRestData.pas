unit PracticeLedgerRestData;

interface
uses
  Classes,
  CashBookMigrationRestData,
  uLkJSON,
  bkConst;

type
  //----------------------------------------------------------------------------
  TPracticeLedgerChartOfAccountData = class(  TChartOfAccountData  )
  private
    fCountryID : integer;
  public
    procedure Read(const aJson: TlkJSONobject ); override;
  end;

  //----------------------------------------------------------------------------
  TPracticeLedgerChartOfAccountsData = class( TChartOfAccountsData )
  private
    fCountryID : integer;
  protected
    function CreateAndAddAccountToChart: TChartOfAccountData; override;
  public
    constructor Create( ItemClass: TCollectionItemClass; aCountryID : integer = whNewZealand ); reintroduce;
  end;

implementation
uses
  LogUtil;

const
  UnitName = 'PracticeLedgerRestData';

var
  DebugMe : boolean = false;


{ TPracticeLedgerChartOfAccountData }

procedure TPracticeLedgerChartOfAccountData.Read(const aJson: TlkJSONobject );

  procedure CheckValidPLGSTCode( aCountryID: integer );
  const
    cValidNZPLCodes: Array [1..5] of String[4] =
                     ( 'GST', (*'GSTI', 'GSTO', *)'E', 'NTR', 'Z', 'I' );
    cValidAUPLCodes: Array [1..9] of String[4] =
                     ('CAP', 'EXP', 'FRE', 'GNR', 'GST', 'INP', 'ITS', 'NTR',
                      'NA');
  var
    GSTValid : boolean;
    liLoop,
    liNumberOfValidCodes : integer;
  begin
    GSTValid := False;

    case aCountryID of
      whNewZealand : liNumberOfValidCodes := high( cValidNZPLCodes );
      whAustralia  : liNumberOfValidCodes := high( cValidAUPLCodes );                                    
    end;

    for liLoop := 1 to liNumberOfValidCodes do
    begin
      case aCountryID of
        whNewZealand : GSTValid := GstType = cValidNZPLCodes[ liLoop ];
        whAustralia  : GSTValid := GstType = cValidAUPLCodes[ liLoop ];
      end;
      if GSTValid then
        Break;
    end;
    if not GSTValid then
      GstType := 'NONE';
  end;


begin
  inherited Read( aJson );

  CheckValidPLGSTCode( fCountryID );
end;

{ TPracticeLedgerChartOfAccountsData }

constructor TPracticeLedgerChartOfAccountsData.Create(
  ItemClass: TCollectionItemClass; aCountryID: integer);
begin
  inherited Create( ItemClass );

  fCountryID := aCountryID;
end;

function TPracticeLedgerChartOfAccountsData.CreateAndAddAccountToChart: TChartOfAccountData;
begin
  result := inherited CreateAndAddAccountToChart;
  TPracticeLedgerChartOfAccountData( result ).fCountryID := fCountryID;
end;

initialization
begin
  DebugMe := DebugUnit(UnitName);
end;

end.
