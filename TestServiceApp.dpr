program TestServiceApp;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  ServiceBase in 'ServiceBase.pas',
  Config in 'Config.pas',
  Logger in 'Logger.pas',
  WebServer in 'WebServer.pas',
  DatabaseManager in 'DatabaseManager.pas',
  TaskScheduler in 'TaskScheduler.pas',
  TestService in 'TestService.pas';

var
  Tester: TServiceTester;
  AllPassed: Boolean;

begin
  WriteLn('===============================================');
  WriteLn('    TEST DEL SERVEI WEB ERP - Delphi 10.4    ');
  WriteLn('===============================================');
  WriteLn;
  
  try
    // Crear el tester
    Tester := TServiceTester.Create;
    try
      // Executar tots els tests
      AllPassed := Tester.RunAllTests;
      
      WriteLn;
      WriteLn('===============================================');
      WriteLn('               RESUM DELS TESTS              ');
      WriteLn('===============================================');
      WriteLn(Tester.GetTestResults);
      
      // Codi de sortida segons el resultat
      if AllPassed then
      begin
        WriteLn('El servei està llest per a la producció!');
        ExitCode := 0;
      end
      else
      begin
        WriteLn('Hi ha problemes que cal resoldre abans de continuar.');
        ExitCode := 1;
      end;
      
    finally
      Tester.Free;
    end;
    
  except
    on E: Exception do
    begin
      WriteLn('ERROR CRÍTIC: ', E.Message);
      WriteLn('Els tests no s''han pogut executar correctament.');
      ExitCode := 2;
    end;
  end;
  
  WriteLn;
  WriteLn('Premeu Enter per sortir...');
  ReadLn;
end.