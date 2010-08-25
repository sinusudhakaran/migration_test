unit PwdSeed;
{used by bk5 and bk5support systems to generate a password for special functions}
interface
uses
   sysutils, math;

function PasswordFromSeed(Seed : integer) : string;
function SeedFromString(input : string) : integer;

implementation
function SeedFromString(input : string) : integer;
var
  i : integer;
  total : integer;
  C : char;
begin
  total := 0;

  for i := 1 to length(input) do
  begin
     c := input[i];
     if Odd(i) then total := total + 2*Ord(c)
               else total := total + 3*Ord(c);

     if i > 1 then
       total := total + Ord(input[i]) * Ord(input[i-1]);
  end;

  result := total;
end;

function PasswordFromSeed(Seed : integer) : string;
{formular = sqrt(x^3+17x+37)}
begin
   result := inttostr(Round(Sqrt(Power(Seed,3)+(17*Seed)+37)));
end;

end.
 
