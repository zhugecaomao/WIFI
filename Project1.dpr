program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1};

{$R *.res}


begin
  Application.Initialize;
  Application.Title := 'Win7/Win8 无线热点（Wi-Fi）开启设置工具';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
