program checks;

{$mode objfpc}{$H+}


uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, accounts, unit30, SQLDBLaz,
  printer4lazarus;

begin
 // {$I checks.lrs}
  Application.Initialize;
  Application.CreateForm(TCheckForm, CheckForm);
  Application.CreateForm(TDataMod, DataMod);
  Application.Run;
end.
