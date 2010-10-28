Unit ISO_4217;

interface

uses
   Classes;

Type
  pISO_4217_Record = ^ISO_4217_Record;
  ISO_4217_Record = Record
    Code          : String[3];
    Numeric_Code  : String[3];
    Symbol        : String[5];
    Decimals      : Integer;
    Name          : String[128];
  end;

Function Get_ISO_4217_Record( Const ACode : String ): pISO_4217_Record;
Function ISO_4217_Code_Exists( Const ACode : String ): Boolean;
Function Get_ISO_4217_Symbol( Const ACode : String ): string;

implementation

uses
   sysUtils;


Const
  ISO_4217_min = 0; ISO_4217_max = 177;
  ISO_4217_Records : Array[ ISO_4217_min..ISO_4217_max ] of ISO_4217_Record =
  (
    (  Code : 'AED';  Numeric_Code : '784';  Symbol : '';   Decimals : 2;  Name : 'United Arab Emirates dirham' ),
    (  Code : 'AFN';  Numeric_Code : '971';  Symbol : '';     Decimals : 2;  Name : 'Afghani' ),
    (  Code : 'ALL';  Numeric_Code : '008';  Symbol : 'L';     Decimals : 2;  Name : 'Lek' ),
    (  Code : 'AMD';  Numeric_Code : '051';  Symbol : '';   Decimals : 2;  Name : 'Armenian dram' ),
    (  Code : 'ANG';  Numeric_Code : '532';  Symbol : 'ƒ';     Decimals : 2;  Name : 'Netherlands Antillean guilder/florin' ),
    (  Code : 'AOA';  Numeric_Code : '973';  Symbol : 'Kz';    Decimals : 2;  Name : 'Kwanza' ),
    (  Code : 'ARS';  Numeric_Code : '032';  Symbol : '$';     Decimals : 2;  Name : 'Argentine peso' ),
    (  Code : 'AUD';  Numeric_Code : '036';  Symbol : '$';     Decimals : 2;  Name : 'Australian dollar' ),
    (  Code : 'AWG';  Numeric_Code : '533';  Symbol : 'ƒ';     Decimals : 2;  Name : 'Aruban guilder' ),
    (  Code : 'AZN';  Numeric_Code : '944';  Symbol : 'm';     Decimals : 2;  Name : 'Azerbaijanian manat' ),
    (  Code : 'BAM';  Numeric_Code : '977';  Symbol : 'KM';    Decimals : 2;  Name : 'Convertible marks' ),
    (  Code : 'BBD';  Numeric_Code : '052';  Symbol : '$';     Decimals : 2;  Name : 'Barbados dollar' ),
    (  Code : 'BDT';  Numeric_Code : '050';  Symbol : '';     Decimals : 2;  Name : 'Bangladeshi taka' ),
    (  Code : 'BGN';  Numeric_Code : '975';  Symbol : '';    Decimals : 2;  Name : 'Bulgarian lev' ),
    (  Code : 'BHD';  Numeric_Code : '048';  Symbol : '';  Decimals : 3;  Name : 'Bahraini dinar' ),
    (  Code : 'BIF';  Numeric_Code : '108';  Symbol : 'Fr';    Decimals : 0;  Name : 'Burundian franc' ),
    (  Code : 'BMD';  Numeric_Code : '060';  Symbol : '$';     Decimals : 2;  Name : 'Bermudian dollar (customarily known as Bermuda dollar)' ),
    (  Code : 'BND';  Numeric_Code : '096';  Symbol : '$';     Decimals : 2;  Name : 'Brunei dollar' ),
    (  Code : 'BOB';  Numeric_Code : '068';  Symbol : 'Bs.';   Decimals : 2;  Name : 'Boliviano' ),
    (  Code : 'BOV';  Numeric_Code : '984';  Symbol : '';      Decimals : 2;  Name : 'Bolivian Mvdol (funds code)' ),
    (  Code : 'BRL';  Numeric_Code : '986';  Symbol : 'R$';    Decimals : 2;  Name : 'Brazilian real' ),
    (  Code : 'BSD';  Numeric_Code : '044';  Symbol : '$';     Decimals : 2;  Name : 'Bahamian dollar' ),
    (  Code : 'BTN';  Numeric_Code : '064';  Symbol : 'Nu.';   Decimals : 2;  Name : 'Ngultrum' ),
    (  Code : 'BWP';  Numeric_Code : '072';  Symbol : 'P';     Decimals : 2;  Name : 'Pula' ),
    (  Code : 'BYR';  Numeric_Code : '974';  Symbol : 'Br';    Decimals : 0;  Name : 'Belarussian ruble' ),
    (  Code : 'BZD';  Numeric_Code : '084';  Symbol : '$';     Decimals : 2;  Name : 'Belize dollar' ),
    (  Code : 'CAD';  Numeric_Code : '124';  Symbol : '$';     Decimals : 2;  Name : 'Canadian dollar' ),
    (  Code : 'CDF';  Numeric_Code : '976';  Symbol : 'Fr';    Decimals : 2;  Name : 'Franc Congolais' ),
    (  Code : 'CHE';  Numeric_Code : '947';  Symbol : '';      Decimals : 2;  Name : 'WIR euro (complementary currency)' ),
    (  Code : 'CHF';  Numeric_Code : '756';  Symbol : 'Fr';    Decimals : 2;  Name : 'Swiss franc' ),
    (  Code : 'CHW';  Numeric_Code : '948';  Symbol : '';      Decimals : 2;  Name : 'WIR franc (complementary currency)' ),
    (  Code : 'CLF';  Numeric_Code : '990';  Symbol : '';      Decimals : 0;  Name : 'Unidad de Fomento (funds code)' ),
    (  Code : 'CLP';  Numeric_Code : '152';  Symbol : '$';     Decimals : 0;  Name : 'Chilean peso' ),
    (  Code : 'CNY';  Numeric_Code : '156';  Symbol : '¥';     Decimals : 2;  Name : 'Renminbi' ),
    (  Code : 'COP';  Numeric_Code : '170';  Symbol : '$';     Decimals : 2;  Name : 'Colombian peso' ),
    (  Code : 'COU';  Numeric_Code : '970';  Symbol : '';      Decimals : 2;  Name : 'Unidad de Valor Real' ),
    (  Code : 'CRC';  Numeric_Code : '188';  Symbol : '';     Decimals : 2;  Name : 'Costa Rican colon' ),
    (  Code : 'CUP';  Numeric_Code : '192';  Symbol : '$';     Decimals : 2;  Name : 'Cuban peso' ),
    (  Code : 'CVE';  Numeric_Code : '132';  Symbol : '$';     Decimals : 2;  Name : 'Cape Verde escudo' ),
    (  Code : 'CZK';  Numeric_Code : '203';  Symbol : '';    Decimals : 2;  Name : 'Czech koruna' ),
    (  Code : 'DJF';  Numeric_Code : '262';  Symbol : 'Fr';    Decimals : 0;  Name : 'Djibouti franc' ),
    (  Code : 'DKK';  Numeric_Code : '208';  Symbol : 'kr';    Decimals : 2;  Name : 'Danish krone' ),
    (  Code : 'DOP';  Numeric_Code : '214';  Symbol : '$';     Decimals : 2;  Name : 'Dominican peso' ),
    (  Code : 'DZD';  Numeric_Code : '012';  Symbol : '';   Decimals : 2;  Name : 'Algerian dinar' ),
    (  Code : 'EEK';  Numeric_Code : '233';  Symbol : 'KR';    Decimals : 2;  Name : 'Kroon' ),
    (  Code : 'EGP';  Numeric_Code : '818';  Symbol : '£';     Decimals : 2;  Name : 'Egyptian pound' ),
    (  Code : 'ERN';  Numeric_Code : '232';  Symbol : 'Nfk';   Decimals : 2;  Name : 'Nakfa' ),
    (  Code : 'ETB';  Numeric_Code : '230';  Symbol : 'Br';    Decimals : 2;  Name : 'Ethiopian birr' ),
    (  Code : 'EUR';  Numeric_Code : '978';  Symbol : '€';     Decimals : 2;  Name : 'Euro' ),
    (  Code : 'FJD';  Numeric_Code : '242';  Symbol : '$';     Decimals : 2;  Name : 'Fiji dollar' ),
    (  Code : 'FKP';  Numeric_Code : '238';  Symbol : '£';     Decimals : 2;  Name : 'Falkland Islands pound' ),
    (  Code : 'GBP';  Numeric_Code : '826';  Symbol : '£';     Decimals : 2;  Name : 'Pound sterling' ),
    (  Code : 'GEL';  Numeric_Code : '981';  Symbol : '';    Decimals : 2;  Name : 'Lari' ),
    (  Code : 'GHS';  Numeric_Code : '936';  Symbol : '';     Decimals : 2;  Name : 'Cedi' ),
    (  Code : 'GIP';  Numeric_Code : '292';  Symbol : '£';     Decimals : 2;  Name : 'Gibraltar pound' ),
    (  Code : 'GMD';  Numeric_Code : '270';  Symbol : 'D';     Decimals : 2;  Name : 'Dalasi' ),
    (  Code : 'GNF';  Numeric_Code : '324';  Symbol : 'Fr';    Decimals : 0;  Name : 'Guinea franc' ),
    (  Code : 'GTQ';  Numeric_Code : '320';  Symbol : 'Q';     Decimals : 2;  Name : 'Quetzal' ),
    (  Code : 'GYD';  Numeric_Code : '328';  Symbol : '$';     Decimals : 2;  Name : 'Guyana dollar' ),
    (  Code : 'HKD';  Numeric_Code : '344';  Symbol : '$';     Decimals : 2;  Name : 'Hong Kong dollar' ),
    (  Code : 'HNL';  Numeric_Code : '340';  Symbol : 'L';     Decimals : 2;  Name : 'Lempira' ),
    (  Code : 'HRK';  Numeric_Code : '191';  Symbol : 'kn';    Decimals : 2;  Name : 'Croatian kuna' ),
    (  Code : 'HTG';  Numeric_Code : '332';  Symbol : 'G';     Decimals : 2;  Name : 'Haiti gourde' ),
    (  Code : 'HUF';  Numeric_Code : '348';  Symbol : 'Ft';    Decimals : 2;  Name : 'Forint' ),
    (  Code : 'IDR';  Numeric_Code : '360';  Symbol : 'Rp';    Decimals : 2;  Name : 'Rupiah' ),
    (  Code : 'ILS';  Numeric_Code : '376';  Symbol : '';     Decimals : 2;  Name : 'Israeli new sheqel' ),
    (  Code : 'INR';  Numeric_Code : '356';  Symbol : '';      Decimals : 2;  Name : 'Indian rupee' ),
    (  Code : 'IQD';  Numeric_Code : '368';  Symbol : '';   Decimals : 3;  Name : 'Iraqi dinar' ),
    (  Code : 'IRR';  Numeric_Code : '364';  Symbol : '';     Decimals : 2;  Name : 'Iranian rial' ),
    (  Code : 'ISK';  Numeric_Code : '352';  Symbol : 'kr';    Decimals : 2;  Name : 'Iceland krona' ),
    (  Code : 'JMD';  Numeric_Code : '388';  Symbol : '$';     Decimals : 2;  Name : 'Jamaican dollar' ),
    (  Code : 'JOD';  Numeric_Code : '400';  Symbol : '';   Decimals : 3;  Name : 'Jordanian dinar' ),
    (  Code : 'JPY';  Numeric_Code : '392';  Symbol : '¥';     Decimals : 0;  Name : 'Japanese yen' ),
    (  Code : 'KES';  Numeric_Code : '404';  Symbol : 'Sh';    Decimals : 2;  Name : 'Kenyan shilling' ),
    (  Code : 'KGS';  Numeric_Code : '417';  Symbol : '';    Decimals : 2;  Name : 'Som' ),
    (  Code : 'KHR';  Numeric_Code : '116';  Symbol : '';     Decimals : 2;  Name : 'Riel' ),
    (  Code : 'KMF';  Numeric_Code : '174';  Symbol : 'Fr';    Decimals : 0;  Name : 'Comoro franc' ),
    (  Code : 'KPW';  Numeric_Code : '408';  Symbol : '';     Decimals : 2;  Name : 'North Korean won' ),
    (  Code : 'KRW';  Numeric_Code : '410';  Symbol : '';     Decimals : 0;  Name : 'South Korean won' ),
    (  Code : 'KWD';  Numeric_Code : '414';  Symbol : '';   Decimals : 3;  Name : 'Kuwaiti dinar' ),
    (  Code : 'KYD';  Numeric_Code : '136';  Symbol : '$';     Decimals : 2;  Name : 'Cayman Islands dollar' ),
    (  Code : 'KZT';  Numeric_Code : '398';  Symbol : '';    Decimals : 2;  Name : 'Tenge' ),
    (  Code : 'LAK';  Numeric_Code : '418';  Symbol : '';     Decimals : 2;  Name : 'Kip' ),
    (  Code : 'LBP';  Numeric_Code : '422';  Symbol : '';   Decimals : 2;  Name : 'Lebanese pound' ),
    (  Code : 'LKR';  Numeric_Code : '144';  Symbol : 'Rs';    Decimals : 2;  Name : 'Sri Lanka rupee' ),
    (  Code : 'LRD';  Numeric_Code : '430';  Symbol : '$';     Decimals : 2;  Name : 'Liberian dollar' ),
    (  Code : 'LSL';  Numeric_Code : '426';  Symbol : 'L';     Decimals : 2;  Name : 'Loti' ),
    (  Code : 'LTL';  Numeric_Code : '440';  Symbol : 'Lt';    Decimals : 2;  Name : 'Lithuanian litas' ),
    (  Code : 'LVL';  Numeric_Code : '428';  Symbol : 'Ls';    Decimals : 2;  Name : 'Latvian lats' ),
    (  Code : 'LYD';  Numeric_Code : '434';  Symbol : '';   Decimals : 3;  Name : 'Libyan dinar' ),
    (  Code : 'MAD';  Numeric_Code : '504';  Symbol : '';  Decimals : 2;  Name : 'Moroccan dirham' ),
    (  Code : 'MDL';  Numeric_Code : '498';  Symbol : 'L';     Decimals : 2;  Name : 'Moldovan leu' ),
    (  Code : 'MGA';  Numeric_Code : '969';  Symbol : 'Ar';    Decimals : 7;  Name : 'Malagasy ariary' ),
    (  Code : 'MKD';  Numeric_Code : '807';  Symbol : '';   Decimals : 2;  Name : 'Denar' ),
    (  Code : 'MMK';  Numeric_Code : '104';  Symbol : 'K';     Decimals : 2;  Name : 'Kyat' ),
    (  Code : 'MNT';  Numeric_Code : '496';  Symbol : '';     Decimals : 2;  Name : 'Tugrik' ),
    (  Code : 'MOP';  Numeric_Code : '446';  Symbol : 'P';     Decimals : 2;  Name : 'Pataca' ),
    (  Code : 'MRO';  Numeric_Code : '478';  Symbol : 'UM';    Decimals : 7;  Name : 'Ouguiya' ),
    (  Code : 'MUR';  Numeric_Code : '480';  Symbol : '';     Decimals : 2;  Name : 'Mauritius rupee' ),
    (  Code : 'MVR';  Numeric_Code : '462';  Symbol : '';   Decimals : 2;  Name : 'Rufiyaa' ),
    (  Code : 'MWK';  Numeric_Code : '454';  Symbol : 'MK';    Decimals : 2;  Name : 'Kwacha' ),
    (  Code : 'MXN';  Numeric_Code : '484';  Symbol : '$';     Decimals : 2;  Name : 'Mexican peso' ),
    (  Code : 'MXV';  Numeric_Code : '979';  Symbol : 'UDI';   Decimals : 2;  Name : 'Mexican Unidad de Inversion (UDI) (funds code)' ),
    (  Code : 'MYR';  Numeric_Code : '458';  Symbol : 'RM';    Decimals : 2;  Name : 'Malaysian ringgit' ),
    (  Code : 'MZN';  Numeric_Code : '943';  Symbol : 'MTn';   Decimals : 2;  Name : 'Metical' ),
    (  Code : 'NAD';  Numeric_Code : '516';  Symbol : '$';     Decimals : 2;  Name : 'Namibian dollar' ),
    (  Code : 'NGN';  Numeric_Code : '566';  Symbol : '';     Decimals : 2;  Name : 'Naira' ),
    (  Code : 'NIO';  Numeric_Code : '558';  Symbol : 'C$';    Decimals : 2;  Name : 'Cordoba oro' ),
    (  Code : 'NOK';  Numeric_Code : '578';  Symbol : 'kr';    Decimals : 2;  Name : 'Norwegian krone' ),
    (  Code : 'NPR';  Numeric_Code : '524';  Symbol : '';     Decimals : 2;  Name : 'Nepalese rupee' ),
    (  Code : 'NZD';  Numeric_Code : '554';  Symbol : '$';     Decimals : 2;  Name : 'New Zealand dollar' ),
    (  Code : 'OMR';  Numeric_Code : '512';  Symbol : '';  Decimals : 3;  Name : 'Rial Omani' ),
    (  Code : 'PAB';  Numeric_Code : '590';  Symbol : 'B/.';   Decimals : 2;  Name : 'Balboa' ),
    (  Code : 'PEN';  Numeric_Code : '604';  Symbol : 'S/.';   Decimals : 2;  Name : 'Nuevo sol' ),
    (  Code : 'PGK';  Numeric_Code : '598';  Symbol : 'K';     Decimals : 2;  Name : 'Kina' ),
    (  Code : 'PHP';  Numeric_Code : '608';  Symbol : '';     Decimals : 2;  Name : 'Philippine peso' ),
    (  Code : 'PKR';  Numeric_Code : '586';  Symbol : '';     Decimals : 2;  Name : 'Pakistan rupee' ),
    (  Code : 'PLN';  Numeric_Code : '985';  Symbol : '';    Decimals : 2;  Name : 'Zloty' ),
    (  Code : 'PYG';  Numeric_Code : '600';  Symbol : '';     Decimals : 0;  Name : 'Guarani' ),
    (  Code : 'QAR';  Numeric_Code : '634';  Symbol : '';   Decimals : 2;  Name : 'Qatari rial' ),
    (  Code : 'RON';  Numeric_Code : '946';  Symbol : 'L';     Decimals : 2;  Name : 'Romanian new leu' ),
    (  Code : 'RSD';  Numeric_Code : '941';  Symbol : '';  Decimals : 2;  Name : 'Serbian dinar' ),
    (  Code : 'RUB';  Numeric_Code : '643';  Symbol : '';  Decimals : 2;  Name : 'Russian ruble' ),
    (  Code : 'RWF';  Numeric_Code : '646';  Symbol : 'Fr';    Decimals : 0;  Name : 'Rwanda franc' ),
    (  Code : 'SAR';  Numeric_Code : '682';  Symbol : '';   Decimals : 2;  Name : 'Saudi riyal' ),
    (  Code : 'SBD';  Numeric_Code : '090';  Symbol : '$';     Decimals : 2;  Name : 'Solomon Islands dollar' ),
    (  Code : 'SCR';  Numeric_Code : '690';  Symbol : '';     Decimals : 2;  Name : 'Seychelles rupee' ),
    (  Code : 'SDG';  Numeric_Code : '938';  Symbol : '£';     Decimals : 2;  Name : 'Sudanese pound' ),
    (  Code : 'SEK';  Numeric_Code : '752';  Symbol : 'kr';    Decimals : 2;  Name : 'Swedish krona' ),
    (  Code : 'SGD';  Numeric_Code : '702';  Symbol : '$';     Decimals : 2;  Name : 'Singapore dollar' ),
    (  Code : 'SHP';  Numeric_Code : '654';  Symbol : '£';     Decimals : 2;  Name : 'Saint Helena pound' ),
    (  Code : 'SKK';  Numeric_Code : '703';  Symbol : 'Sk.';   Decimals : 2;  Name : 'Slovak koruna' ), // note: as of 01-01-09 Slovakia has switched to the Euro
    (  Code : 'SLL';  Numeric_Code : '694';  Symbol : 'Le';    Decimals : 2;  Name : 'Leone' ),
    (  Code : 'SOS';  Numeric_Code : '706';  Symbol : 'Sh';    Decimals : 2;  Name : 'Somali shilling' ),
    (  Code : 'SRD';  Numeric_Code : '968';  Symbol : '$';     Decimals : 2;  Name : 'Surinam dollar' ),
    (  Code : 'STD';  Numeric_Code : '678';  Symbol : 'Db';    Decimals : 2;  Name : 'Dobra' ),
    (  Code : 'SYP';  Numeric_Code : '760';  Symbol : '£';     Decimals : 2;  Name : 'Syrian pound' ),
    (  Code : 'SZL';  Numeric_Code : '748';  Symbol : 'L';     Decimals : 2;  Name : 'Lilangeni' ),
    (  Code : 'THB';  Numeric_Code : '764';  Symbol : '';     Decimals : 2;  Name : 'Baht' ),
    (  Code : 'TJS';  Numeric_Code : '972';  Symbol : 'SM';    Decimals : 2;  Name : 'Somoni' ),
    (  Code : 'TMM';  Numeric_Code : '795';  Symbol : 'm';     Decimals : 2;  Name : 'Manat' ),
    (  Code : 'TND';  Numeric_Code : '788';  Symbol : '';      Decimals : 3;  Name : 'Tunisian dinar' ),
    (  Code : 'TOP';  Numeric_Code : '776';  Symbol : 'T$';    Decimals : 2;  Name : 'Pa''anga' ),
    (  Code : 'TRY';  Numeric_Code : '949';  Symbol : '';     Decimals : 2;  Name : 'New Turkish lira' ),
    (  Code : 'TTD';  Numeric_Code : '780';  Symbol : '$';     Decimals : 2;  Name : 'Trinidad and Tobago dollar' ),
    (  Code : 'TWD';  Numeric_Code : '901';  Symbol : '$';     Decimals : 2;  Name : 'New Taiwan dollar' ),
    (  Code : 'TZS';  Numeric_Code : '834';  Symbol : 'Sh';    Decimals : 2;  Name : 'Tanzanian shilling' ),
    (  Code : 'UAH';  Numeric_Code : '980';  Symbol : '';     Decimals : 2;  Name : 'Hryvnia' ),
    (  Code : 'UGX';  Numeric_Code : '800';  Symbol : 'Sh';    Decimals : 2;  Name : 'Uganda shilling' ),
    (  Code : 'USD';  Numeric_Code : '840';  Symbol : '$';     Decimals : 2;  Name : 'US dollar' ),
    (  Code : 'USN';  Numeric_Code : '997';  Symbol : '$';     Decimals : 2;  Name : 'United States dollar (next day) (funds code)' ),
    (  Code : 'USS';  Numeric_Code : '998';  Symbol : '$';     Decimals : 2;  Name : 'United States dollar (same day) (funds code) (one source claims it is no longer used, but it is still on the ISO 4217-MA list)' ),
    (  Code : 'UYU';  Numeric_Code : '858';  Symbol : '$';     Decimals : 2;  Name : 'Peso' ),
    (  Code : 'UZS';  Numeric_Code : '860';  Symbol : '';    Decimals : 2;  Name : 'Uzbekistan som' ),
    (  Code : 'VEF';  Numeric_Code : '937';  Symbol : 'Bs F';  Decimals : 2;  Name : 'Venezuelan bolívar fuerte' ),
    (  Code : 'VND';  Numeric_Code : '704';  Symbol : '';     Decimals : 2;  Name : 'Vietnamese dong' ),
    (  Code : 'VUV';  Numeric_Code : '548';  Symbol : 'Vt';    Decimals : 0;  Name : 'Vatu' ),
    (  Code : 'WST';  Numeric_Code : '882';  Symbol : 'T';     Decimals : 2;  Name : 'Samoan tala' ),
    (  Code : 'XAF';  Numeric_Code : '950';  Symbol : 'Fr';    Decimals : 0;  Name : 'CFA franc BEAC' ),
    (  Code : 'XAG';  Numeric_Code : '961';  Symbol : '';      Decimals : -1;  Name : 'Silver (one troy ounce)' ),
    (  Code : 'XAU';  Numeric_Code : '959';  Symbol : '';      Decimals : -1;  Name : 'Gold (one troy ounce)' ),
    (  Code : 'XBA';  Numeric_Code : '955';  Symbol : '';      Decimals : -1;  Name : 'European Composite Unit (EURCO) (bond market unit)' ),
    (  Code : 'XBB';  Numeric_Code : '956';  Symbol : '';      Decimals : -1;  Name : 'European Monetary Unit (E.M.U.-6) (bond market unit)' ),
    (  Code : 'XBC';  Numeric_Code : '957';  Symbol : '';      Decimals : -1;  Name : 'European Unit of Account 9 (E.U.A.-9) (bond market unit)' ),
    (  Code : 'XBD';  Numeric_Code : '958';  Symbol : '';      Decimals : -1;  Name : 'European Unit of Account 17 (E.U.A.-17) (bond market unit)' ),
    (  Code : 'XCD';  Numeric_Code : '951';  Symbol : '$';     Decimals : 2;  Name : 'East Caribbean dollar' ),
    (  Code : 'XDR';  Numeric_Code : '960';  Symbol : '';      Decimals : -1;  Name : 'Special Drawing Rights' ),
    (  Code : 'XFU';  Numeric_Code : 'Nil';  Symbol : '';      Decimals : -1;  Name : 'UIC franc (special settlement currency)' ),
    (  Code : 'XOF';  Numeric_Code : '952';  Symbol : '';      Decimals : 0;  Name : 'CFA Franc BCEAO' ),
    (  Code : 'XPD';  Numeric_Code : '964';  Symbol : '';      Decimals : -1;  Name : 'Palladium (one troy ounce)' ),
    (  Code : 'XPF';  Numeric_Code : '953';  Symbol : '';      Decimals : 0;  Name : 'CFP franc' ),
    (  Code : 'XPT';  Numeric_Code : '962';  Symbol : '';      Decimals : -1;  Name : 'Platinum (one troy ounce)' ),
    (  Code : 'XTS';  Numeric_Code : '963';  Symbol : '';      Decimals : -1;  Name : 'Code reserved for testing purposes' ),
    (  Code : 'XXX';  Numeric_Code : '999';  Symbol : '';      Decimals : -1;  Name : 'No currency' ),
    (  Code : 'YER';  Numeric_Code : '886';  Symbol : '';     Decimals : 2;  Name : 'Yemeni rial' ),
    (  Code : 'ZAR';  Numeric_Code : '710';  Symbol : 'R';     Decimals : 2;  Name : 'South African rand' ),
    (  Code : 'ZMK';  Numeric_Code : '894';  Symbol : 'ZK';    Decimals : 2;  Name : 'Kwacha' ),
    (  Code : 'ZWD';  Numeric_Code : '716';  Symbol : '$';     Decimals : 2;  Name : 'Zimbabwe dollar' )
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

Function Get_ISO_4217_Symbol( Const ACode : String ): string;
var
  ISORecord: pISO_4217_Record;
Begin
  Result := '';
  ISORecord := Get_ISO_4217_Record(ACode);
  if Assigned(ISORecord) then
    Result := ISORecord.Symbol
  else
    raise Exception.CreateFmt( 'MoneyUtils Error : Unknown Currency Code %s', [ ACode ] );
End;

end.
