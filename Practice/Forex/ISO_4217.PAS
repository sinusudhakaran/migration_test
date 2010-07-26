Unit ISO_4217;

interface

uses
   Classes;

Type
  pISO_4217_Record = ^ISO_4217_Record;
  ISO_4217_Record = Record
    Code          : String[3];
    Numeric_Code  : String[3];
    Decimals      : Integer;
    Name          : String[128];
  end;

Function Get_ISO_4217_Record( Const ACode : String ): pISO_4217_Record;
Function ISO_4217_Code_Exists( Const ACode : String ): Boolean;

implementation

uses
   sysUtils;


Const
  ISO_4217_min = 0; ISO_4217_max = 177;
  ISO_4217_Records : Array[ ISO_4217_min..ISO_4217_max ] of ISO_4217_Record =
  (
    (  Code : 'AED';  Numeric_Code : '784';  Decimals : 2;  Name : 'United Arab Emirates dirham' ),
    (  Code : 'AFN';  Numeric_Code : '971';  Decimals : 2;  Name : 'Afghani' ),
    (  Code : 'ALL';  Numeric_Code : '008';  Decimals : 2;  Name : 'Lek' ),
    (  Code : 'AMD';  Numeric_Code : '051';  Decimals : 2;  Name : 'Armenian dram' ),
    (  Code : 'ANG';  Numeric_Code : '532';  Decimals : 2;  Name : 'Netherlands Antillean guilder/florin' ),
    (  Code : 'AOA';  Numeric_Code : '973';  Decimals : 2;  Name : 'Kwanza' ),
    (  Code : 'ARS';  Numeric_Code : '032';  Decimals : 2;  Name : 'Argentine peso' ),
    (  Code : 'AUD';  Numeric_Code : '036';  Decimals : 2;  Name : 'Australian dollar' ),
    (  Code : 'AWG';  Numeric_Code : '533';  Decimals : 2;  Name : 'Aruban guilder' ),
    (  Code : 'AZN';  Numeric_Code : '944';  Decimals : 2;  Name : 'Azerbaijanian manat' ),
    (  Code : 'BAM';  Numeric_Code : '977';  Decimals : 2;  Name : 'Convertible marks' ),
    (  Code : 'BBD';  Numeric_Code : '052';  Decimals : 2;  Name : 'Barbados dollar' ),
    (  Code : 'BDT';  Numeric_Code : '050';  Decimals : 2;  Name : 'Bangladeshi taka' ),
    (  Code : 'BGN';  Numeric_Code : '975';  Decimals : 2;  Name : 'Bulgarian lev' ),
    (  Code : 'BHD';  Numeric_Code : '048';  Decimals : 3;  Name : 'Bahraini dinar' ),
    (  Code : 'BIF';  Numeric_Code : '108';  Decimals : 0;  Name : 'Burundian franc' ),
    (  Code : 'BMD';  Numeric_Code : '060';  Decimals : 2;  Name : 'Bermudian dollar (customarily known as Bermuda dollar)' ),
    (  Code : 'BND';  Numeric_Code : '096';  Decimals : 2;  Name : 'Brunei dollar' ),
    (  Code : 'BOB';  Numeric_Code : '068';  Decimals : 2;  Name : 'Boliviano' ),
    (  Code : 'BOV';  Numeric_Code : '984';  Decimals : 2;  Name : 'Bolivian Mvdol (funds code)' ),
    (  Code : 'BRL';  Numeric_Code : '986';  Decimals : 2;  Name : 'Brazilian real' ),
    (  Code : 'BSD';  Numeric_Code : '044';  Decimals : 2;  Name : 'Bahamian dollar' ), 
    (  Code : 'BTN';  Numeric_Code : '064';  Decimals : 2;  Name : 'Ngultrum' ), 
    (  Code : 'BWP';  Numeric_Code : '072';  Decimals : 2;  Name : 'Pula' ), 
    (  Code : 'BYR';  Numeric_Code : '974';  Decimals : 0;  Name : 'Belarussian ruble' ), 
    (  Code : 'BZD';  Numeric_Code : '084';  Decimals : 2;  Name : 'Belize dollar' ), 
    (  Code : 'CAD';  Numeric_Code : '124';  Decimals : 2;  Name : 'Canadian dollar' ), 
    (  Code : 'CDF';  Numeric_Code : '976';  Decimals : 2;  Name : 'Franc Congolais' ), 
    (  Code : 'CHE';  Numeric_Code : '947';  Decimals : 2;  Name : 'WIR euro (complementary currency)' ), 
    (  Code : 'CHF';  Numeric_Code : '756';  Decimals : 2;  Name : 'Swiss franc' ), 
    (  Code : 'CHW';  Numeric_Code : '948';  Decimals : 2;  Name : 'WIR franc (complementary currency)' ), 
    (  Code : 'CLF';  Numeric_Code : '990';  Decimals : 0;  Name : 'Unidad de Fomento (funds code)' ), 
    (  Code : 'CLP';  Numeric_Code : '152';  Decimals : 0;  Name : 'Chilean peso' ), 
    (  Code : 'CNY';  Numeric_Code : '156';  Decimals : 2;  Name : 'Renminbi' ), 
    (  Code : 'COP';  Numeric_Code : '170';  Decimals : 2;  Name : 'Colombian peso' ), 
    (  Code : 'COU';  Numeric_Code : '970';  Decimals : 2;  Name : 'Unidad de Valor Real' ), 
    (  Code : 'CRC';  Numeric_Code : '188';  Decimals : 2;  Name : 'Costa Rican colon' ), 
    (  Code : 'CUP';  Numeric_Code : '192';  Decimals : 2;  Name : 'Cuban peso' ), 
    (  Code : 'CVE';  Numeric_Code : '132';  Decimals : 2;  Name : 'Cape Verde escudo' ),
    (  Code : 'CZK';  Numeric_Code : '203';  Decimals : 2;  Name : 'Czech koruna' ), 
    (  Code : 'DJF';  Numeric_Code : '262';  Decimals : 0;  Name : 'Djibouti franc' ), 
    (  Code : 'DKK';  Numeric_Code : '208';  Decimals : 2;  Name : 'Danish krone' ), 
    (  Code : 'DOP';  Numeric_Code : '214';  Decimals : 2;  Name : 'Dominican peso' ), 
    (  Code : 'DZD';  Numeric_Code : '012';  Decimals : 2;  Name : 'Algerian dinar' ),
    (  Code : 'EEK';  Numeric_Code : '233';  Decimals : 2;  Name : 'Kroon' ),
    (  Code : 'EGP';  Numeric_Code : '818';  Decimals : 2;  Name : 'Egyptian pound' ),
    (  Code : 'ERN';  Numeric_Code : '232';  Decimals : 2;  Name : 'Nakfa' ),
    (  Code : 'ETB';  Numeric_Code : '230';  Decimals : 2;  Name : 'Ethiopian birr' ), 
    (  Code : 'EUR';  Numeric_Code : '978';  Decimals : 2;  Name : 'Euro' ), 
    (  Code : 'FJD';  Numeric_Code : '242';  Decimals : 2;  Name : 'Fiji dollar' ), 
    (  Code : 'FKP';  Numeric_Code : '238';  Decimals : 2;  Name : 'Falkland Islands pound' ), 
    (  Code : 'GBP';  Numeric_Code : '826';  Decimals : 2;  Name : 'Pound sterling' ), 
    (  Code : 'GEL';  Numeric_Code : '981';  Decimals : 2;  Name : 'Lari' ), 
    (  Code : 'GHS';  Numeric_Code : '936';  Decimals : 2;  Name : 'Cedi' ), 
    (  Code : 'GIP';  Numeric_Code : '292';  Decimals : 2;  Name : 'Gibraltar pound' ),
    (  Code : 'GMD';  Numeric_Code : '270';  Decimals : 2;  Name : 'Dalasi' ),
    (  Code : 'GNF';  Numeric_Code : '324';  Decimals : 0;  Name : 'Guinea franc' ), 
    (  Code : 'GTQ';  Numeric_Code : '320';  Decimals : 2;  Name : 'Quetzal' ), 
    (  Code : 'GYD';  Numeric_Code : '328';  Decimals : 2;  Name : 'Guyana dollar' ), 
    (  Code : 'HKD';  Numeric_Code : '344';  Decimals : 2;  Name : 'Hong Kong dollar' ),
    (  Code : 'HNL';  Numeric_Code : '340';  Decimals : 2;  Name : 'Lempira' ),
    (  Code : 'HRK';  Numeric_Code : '191';  Decimals : 2;  Name : 'Croatian kuna' ), 
    (  Code : 'HTG';  Numeric_Code : '332';  Decimals : 2;  Name : 'Haiti gourde' ), 
    (  Code : 'HUF';  Numeric_Code : '348';  Decimals : 2;  Name : 'Forint' ), 
    (  Code : 'IDR';  Numeric_Code : '360';  Decimals : 2;  Name : 'Rupiah' ), 
    (  Code : 'ILS';  Numeric_Code : '376';  Decimals : 2;  Name : 'Israeli new sheqel' ), 
    (  Code : 'INR';  Numeric_Code : '356';  Decimals : 2;  Name : 'Indian rupee' ), 
    (  Code : 'IQD';  Numeric_Code : '368';  Decimals : 3;  Name : 'Iraqi dinar' ), 
    (  Code : 'IRR';  Numeric_Code : '364';  Decimals : 2;  Name : 'Iranian rial' ), 
    (  Code : 'ISK';  Numeric_Code : '352';  Decimals : 2;  Name : 'Iceland krona' ), 
    (  Code : 'JMD';  Numeric_Code : '388';  Decimals : 2;  Name : 'Jamaican dollar' ), 
    (  Code : 'JOD';  Numeric_Code : '400';  Decimals : 3;  Name : 'Jordanian dinar' ), 
    (  Code : 'JPY';  Numeric_Code : '392';  Decimals : 0;  Name : 'Japanese yen' ), 
    (  Code : 'KES';  Numeric_Code : '404';  Decimals : 2;  Name : 'Kenyan shilling' ), 
    (  Code : 'KGS';  Numeric_Code : '417';  Decimals : 2;  Name : 'Som' ), 
    (  Code : 'KHR';  Numeric_Code : '116';  Decimals : 2;  Name : 'Riel' ), 
    (  Code : 'KMF';  Numeric_Code : '174';  Decimals : 0;  Name : 'Comoro franc' ), 
    (  Code : 'KPW';  Numeric_Code : '408';  Decimals : 2;  Name : 'North Korean won' ), 
    (  Code : 'KRW';  Numeric_Code : '410';  Decimals : 0;  Name : 'South Korean won' ), 
    (  Code : 'KWD';  Numeric_Code : '414';  Decimals : 3;  Name : 'Kuwaiti dinar' ), 
    (  Code : 'KYD';  Numeric_Code : '136';  Decimals : 2;  Name : 'Cayman Islands dollar' ), 
    (  Code : 'KZT';  Numeric_Code : '398';  Decimals : 2;  Name : 'Tenge' ), 
    (  Code : 'LAK';  Numeric_Code : '418';  Decimals : 2;  Name : 'Kip' ), 
    (  Code : 'LBP';  Numeric_Code : '422';  Decimals : 2;  Name : 'Lebanese pound' ), 
    (  Code : 'LKR';  Numeric_Code : '144';  Decimals : 2;  Name : 'Sri Lanka rupee' ), 
    (  Code : 'LRD';  Numeric_Code : '430';  Decimals : 2;  Name : 'Liberian dollar' ),
    (  Code : 'LSL';  Numeric_Code : '426';  Decimals : 2;  Name : 'Loti' ), 
    (  Code : 'LTL';  Numeric_Code : '440';  Decimals : 2;  Name : 'Lithuanian litas' ), 
    (  Code : 'LVL';  Numeric_Code : '428';  Decimals : 2;  Name : 'Latvian lats' ), 
    (  Code : 'LYD';  Numeric_Code : '434';  Decimals : 3;  Name : 'Libyan dinar' ), 
    (  Code : 'MAD';  Numeric_Code : '504';  Decimals : 2;  Name : 'Moroccan dirham' ),
    (  Code : 'MDL';  Numeric_Code : '498';  Decimals : 2;  Name : 'Moldovan leu' ),
    (  Code : 'MGA';  Numeric_Code : '969';  Decimals : 7;  Name : 'Malagasy ariary' ),
    (  Code : 'MKD';  Numeric_Code : '807';  Decimals : 2;  Name : 'Denar' ),
    (  Code : 'MMK';  Numeric_Code : '104';  Decimals : 2;  Name : 'Kyat' ), 
    (  Code : 'MNT';  Numeric_Code : '496';  Decimals : 2;  Name : 'Tugrik' ), 
    (  Code : 'MOP';  Numeric_Code : '446';  Decimals : 2;  Name : 'Pataca' ), 
    (  Code : 'MRO';  Numeric_Code : '478';  Decimals : 7;  Name : 'Ouguiya' ), 
    (  Code : 'MUR';  Numeric_Code : '480';  Decimals : 2;  Name : 'Mauritius rupee' ), 
    (  Code : 'MVR';  Numeric_Code : '462';  Decimals : 2;  Name : 'Rufiyaa' ), 
    (  Code : 'MWK';  Numeric_Code : '454';  Decimals : 2;  Name : 'Kwacha' ), 
    (  Code : 'MXN';  Numeric_Code : '484';  Decimals : 2;  Name : 'Mexican peso' ),
    (  Code : 'MXV';  Numeric_Code : '979';  Decimals : 2;  Name : 'Mexican Unidad de Inversion (UDI) (funds code)' ),
    (  Code : 'MYR';  Numeric_Code : '458';  Decimals : 2;  Name : 'Malaysian ringgit' ), 
    (  Code : 'MZN';  Numeric_Code : '943';  Decimals : 2;  Name : 'Metical' ), 
    (  Code : 'NAD';  Numeric_Code : '516';  Decimals : 2;  Name : 'Namibian dollar' ), 
    (  Code : 'NGN';  Numeric_Code : '566';  Decimals : 2;  Name : 'Naira' ), 
    (  Code : 'NIO';  Numeric_Code : '558';  Decimals : 2;  Name : 'Cordoba oro' ),
    (  Code : 'NOK';  Numeric_Code : '578';  Decimals : 2;  Name : 'Norwegian krone' ), 
    (  Code : 'NPR';  Numeric_Code : '524';  Decimals : 2;  Name : 'Nepalese rupee' ), 
    (  Code : 'NZD';  Numeric_Code : '554';  Decimals : 2;  Name : 'New Zealand dollar' ), 
    (  Code : 'OMR';  Numeric_Code : '512';  Decimals : 3;  Name : 'Rial Omani' ), 
    (  Code : 'PAB';  Numeric_Code : '590';  Decimals : 2;  Name : 'Balboa' ), 
    (  Code : 'PEN';  Numeric_Code : '604';  Decimals : 2;  Name : 'Nuevo sol' ), 
    (  Code : 'PGK';  Numeric_Code : '598';  Decimals : 2;  Name : 'Kina' ), 
    (  Code : 'PHP';  Numeric_Code : '608';  Decimals : 2;  Name : 'Philippine peso' ), 
    (  Code : 'PKR';  Numeric_Code : '586';  Decimals : 2;  Name : 'Pakistan rupee' ), 
    (  Code : 'PLN';  Numeric_Code : '985';  Decimals : 2;  Name : 'Zloty' ), 
    (  Code : 'PYG';  Numeric_Code : '600';  Decimals : 0;  Name : 'Guarani' ), 
    (  Code : 'QAR';  Numeric_Code : '634';  Decimals : 2;  Name : 'Qatari rial' ),
    (  Code : 'RON';  Numeric_Code : '946';  Decimals : 2;  Name : 'Romanian new leu' ), 
    (  Code : 'RSD';  Numeric_Code : '941';  Decimals : 2;  Name : 'Serbian dinar' ), 
    (  Code : 'RUB';  Numeric_Code : '643';  Decimals : 2;  Name : 'Russian ruble' ), 
    (  Code : 'RWF';  Numeric_Code : '646';  Decimals : 0;  Name : 'Rwanda franc' ), 
    (  Code : 'SAR';  Numeric_Code : '682';  Decimals : 2;  Name : 'Saudi riyal' ), 
    (  Code : 'SBD';  Numeric_Code : '090';  Decimals : 2;  Name : 'Solomon Islands dollar' ), 
    (  Code : 'SCR';  Numeric_Code : '690';  Decimals : 2;  Name : 'Seychelles rupee' ), 
    (  Code : 'SDG';  Numeric_Code : '938';  Decimals : 2;  Name : 'Sudanese pound' ), 
    (  Code : 'SEK';  Numeric_Code : '752';  Decimals : 2;  Name : 'Swedish krona' ), 
    (  Code : 'SGD';  Numeric_Code : '702';  Decimals : 2;  Name : 'Singapore dollar' ), 
    (  Code : 'SHP';  Numeric_Code : '654';  Decimals : 2;  Name : 'Saint Helena pound' ), 
    (  Code : 'SKK';  Numeric_Code : '703';  Decimals : 2;  Name : 'Slovak koruna' ), 
    (  Code : 'SLL';  Numeric_Code : '694';  Decimals : 2;  Name : 'Leone' ),
    (  Code : 'SOS';  Numeric_Code : '706';  Decimals : 2;  Name : 'Somali shilling' ), 
    (  Code : 'SRD';  Numeric_Code : '968';  Decimals : 2;  Name : 'Surinam dollar' ), 
    (  Code : 'STD';  Numeric_Code : '678';  Decimals : 2;  Name : 'Dobra' ), 
    (  Code : 'SYP';  Numeric_Code : '760';  Decimals : 2;  Name : 'Syrian pound' ), 
    (  Code : 'SZL';  Numeric_Code : '748';  Decimals : 2;  Name : 'Lilangeni' ),
    (  Code : 'THB';  Numeric_Code : '764';  Decimals : 2;  Name : 'Baht' ),
    (  Code : 'TJS';  Numeric_Code : '972';  Decimals : 2;  Name : 'Somoni' ),
    (  Code : 'TMM';  Numeric_Code : '795';  Decimals : 2;  Name : 'Manat' ),
    (  Code : 'TND';  Numeric_Code : '788';  Decimals : 3;  Name : 'Tunisian dinar' ), 
    (  Code : 'TOP';  Numeric_Code : '776';  Decimals : 2;  Name : 'Pa''anga' ),
    (  Code : 'TRY';  Numeric_Code : '949';  Decimals : 2;  Name : 'New Turkish lira' ), 
    (  Code : 'TTD';  Numeric_Code : '780';  Decimals : 2;  Name : 'Trinidad and Tobago dollar' ), 
    (  Code : 'TWD';  Numeric_Code : '901';  Decimals : 2;  Name : 'New Taiwan dollar' ), 
    (  Code : 'TZS';  Numeric_Code : '834';  Decimals : 2;  Name : 'Tanzanian shilling' ), 
    (  Code : 'UAH';  Numeric_Code : '980';  Decimals : 2;  Name : 'Hryvnia' ), 
    (  Code : 'UGX';  Numeric_Code : '800';  Decimals : 2;  Name : 'Uganda shilling' ),
    (  Code : 'USD';  Numeric_Code : '840';  Decimals : 2;  Name : 'US dollar' ),
    (  Code : 'USN';  Numeric_Code : '997';  Decimals : 2;  Name : 'United States dollar (next day) (funds code)' ), 
    (  Code : 'USS';  Numeric_Code : '998';  Decimals : 2;  Name : 'United States dollar (same day) (funds code) (one source claims it is no longer used, but it is still on the ISO 4217-MA list)' ), 
    (  Code : 'UYU';  Numeric_Code : '858';  Decimals : 2;  Name : 'Peso' ), 
    (  Code : 'UZS';  Numeric_Code : '860';  Decimals : 2;  Name : 'Uzbekistan som' ), 
    (  Code : 'VEF';  Numeric_Code : '937';  Decimals : 2;  Name : 'Venezuelan bolívar fuerte' ),
    (  Code : 'VND';  Numeric_Code : '704';  Decimals : 2;  Name : 'Vietnamese dong' ), 
    (  Code : 'VUV';  Numeric_Code : '548';  Decimals : 0;  Name : 'Vatu' ), 
    (  Code : 'WST';  Numeric_Code : '882';  Decimals : 2;  Name : 'Samoan tala' ), 
    (  Code : 'XAF';  Numeric_Code : '950';  Decimals : 0;  Name : 'CFA franc BEAC' ), 
    (  Code : 'XAG';  Numeric_Code : '961';  Decimals : -1;  Name : 'Silver (one troy ounce)' ), 
    (  Code : 'XAU';  Numeric_Code : '959';  Decimals : -1;  Name : 'Gold (one troy ounce)' ), 
    (  Code : 'XBA';  Numeric_Code : '955';  Decimals : -1;  Name : 'European Composite Unit (EURCO) (bond market unit)' ), 
    (  Code : 'XBB';  Numeric_Code : '956';  Decimals : -1;  Name : 'European Monetary Unit (E.M.U.-6) (bond market unit)' ), 
    (  Code : 'XBC';  Numeric_Code : '957';  Decimals : -1;  Name : 'European Unit of Account 9 (E.U.A.-9) (bond market unit)' ), 
    (  Code : 'XBD';  Numeric_Code : '958';  Decimals : -1;  Name : 'European Unit of Account 17 (E.U.A.-17) (bond market unit)' ), 
    (  Code : 'XCD';  Numeric_Code : '951';  Decimals : 2;  Name : 'East Caribbean dollar' ), 
    (  Code : 'XDR';  Numeric_Code : '960';  Decimals : -1;  Name : 'Special Drawing Rights' ), 
    (  Code : 'XFU';  Numeric_Code : 'Nil';  Decimals : -1;  Name : 'UIC franc (special settlement currency)' ), 
    (  Code : 'XOF';  Numeric_Code : '952';  Decimals : 0;  Name : 'CFA Franc BCEAO' ), 
    (  Code : 'XPD';  Numeric_Code : '964';  Decimals : -1;  Name : 'Palladium (one troy ounce)' ), 
    (  Code : 'XPF';  Numeric_Code : '953';  Decimals : 0;  Name : 'CFP franc' ),
    (  Code : 'XPT';  Numeric_Code : '962';  Decimals : -1;  Name : 'Platinum (one troy ounce)' ), 
    (  Code : 'XTS';  Numeric_Code : '963';  Decimals : -1;  Name : 'Code reserved for testing purposes' ), 
    (  Code : 'XXX';  Numeric_Code : '999';  Decimals : -1;  Name : 'No currency' ), 
    (  Code : 'YER';  Numeric_Code : '886';  Decimals : 2;  Name : 'Yemeni rial' ), 
    (  Code : 'ZAR';  Numeric_Code : '710';  Decimals : 2;  Name : 'South African rand' ), 
    (  Code : 'ZMK';  Numeric_Code : '894';  Decimals : 2;  Name : 'Kwacha' ), 
    (  Code : 'ZWD';  Numeric_Code : '716';  Decimals : 2;  Name : 'Zimbabwe dollar' )
  );

// ----------------------------------------------------------------------------

Function Get_ISO_4217_Record( Const ACode : String ): pISO_4217_Record;
var
  L, H, I, C: Integer;
  ISO : pISO_4217_Record;
begin
  Result := nil;
  If ACode = '' then exit;

  L := ISO_4217_min;
  H := ISO_4217_max;

  if L > H then Exit;

  repeat
    I := ( L + H ) shr 1;
    ISO := @ISO_4217_Records[ i ];
    C := CompareStr( ACode, ISO.Code );
    if C > 0 then L := I + 1 else H := I - 1;
  until ( c = 0 ) or ( L > H );
  if c = 0 then Result := ISO;
end;

// ----------------------------------------------------------------------------

Function ISO_4217_Code_Exists( Const ACode : String ): Boolean;
Begin
  Result := Assigned( Get_ISO_4217_Record( ACode ) );
end;

end.
