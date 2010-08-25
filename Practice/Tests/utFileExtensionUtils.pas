unit utFileExtensionUtils;
{$TYPEINFO ON} //Needed for classes with published methods
interface
uses
  TestFramework;  //DUnit

type
 TFileExtensionUtils = class(TTestCase)
 private

 protected

 published
   procedure TestSuffixTranslation;
   procedure TestMakeSuffix;
   procedure TestSuffixToSequenceNo;
   procedure TestCompareDiskExtensions;
 end;


implementation
uses
  FileExtensionUtils, SysUtils;

{ TDownloadUtilTests }

procedure TFileExtensionUtils.TestCompareDiskExtensions;
  procedure DoTest(Ext1, Ext2: String; ExpResult: Integer);
  begin
    CheckEquals(ExpResult, CompareDiskExtensions(Ext1, Ext2), 'CompareDiskExtensions return an unexpected result');
  end;
begin
  DoTest('Z99','Z99',0);
  DoTest('234','A00',-1);
  DoTest('A00','Z99',-1);
  DoTest('Z99','3600',-1);
  DoTest('3600','Z99',1);
  DoTest('A321','Z99',1);
  DoTest('A342','A342',0);
end;

procedure TFileExtensionUtils.TestMakeSuffix;
  procedure DoTest(Value: Integer; ExpResult: string);
  begin
    CheckEquals(ExpResult, MakeSuffix(Value), 'Make Suffix returned an unexpected result');
  end;
begin
  //Run some tests on MakeSuffix Alone against expected results
  DoTest(0, '000');
  DoTest(54, '054');
  DoTest(100, '100');
  DoTest(999, '999');
  DoTest(1000, 'A00');
  DoTest(1100, 'B00');
  DoTest(3599, 'Z99');
  DoTest(3600, '3600');
  DoTest(5600, '5600');
  DoTest(9999, '9999');
  DoTest(10000, 'A000');
  DoTest(25989, 'P989');
  DoTest(35999, 'Z999');
end;

procedure TFileExtensionUtils.TestSuffixToSequenceNo;
  procedure DoTest(Suffix: string; ExpResult: Integer);
  begin
    CheckEquals(ExpResult, SuffixToSequenceNo(Suffix), 'SuffixToSequenceNo returned an unexpected result');
  end;
begin
  //Run some tests on MakeSuffix Alone against expected results
  DoTest('000', 0);
  DoTest('054', 54);
  DoTest('100', 100);
  DoTest('999', 999);
  DoTest('A00', 1000);
  DoTest('B00', 1100);
  DoTest('Z99', 3599);
  DoTest('1000', InvalidSuffixValue); //Numbers between 1000 and 3599 (inc) are invalid
  DoTest('2000', InvalidSuffixValue);
  DoTest('3599', InvalidSuffixValue);
  DoTest('3600', 3600);
  DoTest('5600', 5600);
  DoTest('9999', 9999);
  DoTest('A000', 10000);
  DoTest('Z999', 35999);
end;

procedure TFileExtensionUtils.TestSuffixTranslation;
//test that the makesuffix and suffixtoSequenceNo functions work
var
  i : integer;
  Suffix : string;
  ConvertedBackNum: integer;
begin
  for i := 0 to 35999 do
  begin
    Suffix := MakeSuffix(i);
    ConvertedBackNum := SuffixToSequenceNo(Suffix);
    CheckEquals(i, ConvertedBackNum,
      Format('value->suffix->value %d->%s->%d', [i, Suffix, ConvertedBackNum]));
  end;
end;

initialization
  TestFramework.RegisterTest(TFileExtensionUtils.Suite);
end.
