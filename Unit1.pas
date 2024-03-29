unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellAPI, Mask;//使用ShellExecute需要 uses ShellAPI 声明

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Memo1: TMemo;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{$R UAC.res}
//请求UAC权限声明

//CMD信息显示到Memo中 *开始

procedure CmdExecAndView(FileName: string; memo: TMemo);
procedure _AddInfo(mmInfo:TMemo; S: string; var line: string);

var
i, p: Integer;

begin
  //if mmInfo.Lines.Count > 80 then
  //mmInfo.Lines.Clear;
  //去掉 \r
  for i := 0 to Length(S) - 1 do
  if S[i] = #13 then S[i] := ' ';
  line := line + S;
  // \n 断行
  p := Pos(#10, line);
  if p > 0 then
  begin
  // \n 前面的加入一行，后面的留到下次
  mmInfo.Lines.Add(Copy(line, 1, p - 1));
  line := Copy(line, p + 1, Length(line) - p);
  end;
end;

var
hReadPipe, hWritePipe: THandle;
si: STARTUPINFO;
lsa: SECURITY_ATTRIBUTES;
pi: PROCESS_INFORMATION;
cchReadBuffer: DWORD;
ph: PChar;
fname: PChar;
line: string;

begin
  fname := Allocmem(1024);
  ph := AllocMem(1024);
  lsa.nLength := sizeof(SECURITY_ATTRIBUTES);
  lsa.lpSecurityDescriptor := nil;
  lsa.bInheritHandle := True;
  if CreatePipe(hReadPipe, hWritePipe, @lsa, 0) = false then
  Exit;
  fillchar(si, sizeof(STARTUPINFO), 0);
  si.cb := sizeof(STARTUPINFO);
  si.dwFlags := (STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW);
  si.wShowWindow := SW_HIDE;
  si.hStdOutput := hWritePipe;
  si.hStdError := hWritePipe;
  StrPCopy(fname, FileName);
  if CreateProcess(nil, fname, nil, nil, true, 0, nil, nil, si, pi) = False then
  begin
  FreeMem(ph);
  FreeMem(fname);
  Exit;
  end;
  CloseHandle(hWritePipe);
  while (true) do
  begin
  if not PeekNamedPipe(hReadPipe, ph, 1, @cchReadBuffer, nil, nil) then break;
  if cchReadBuffer <> 0 then
  begin
  if ReadFile(hReadPipe, ph^, 64, cchReadBuffer, nil) = false then break;
  ph[cchReadbuffer] := chr(0);
  _AddInfo(memo, ph, line);
  end
  else if (WaitForSingleObject(pi.hProcess, 0) = WAIT_OBJECT_0) then break;
  Application.ProcessMessages;
  Sleep(200);
  end;
  ph[cchReadBuffer] := chr(0);
  _AddInfo(memo, ph, line);
  CloseHandle(hReadPipe);
  CloseHandle(pi.hThread);
  CloseHandle(pi.hProcess);
  FreeMem(ph);
  FreeMem(fname);
end;

//CMD信息显示到Memo中 *结束

procedure TForm1.Button4Click(Sender: TObject);
begin
  Memo1.Clear;
  CmdExecAndView('Netsh wlan show hostednetwork',Memo1);
end;

procedure TForm1.Button1Click(Sender: TObject);

var
setup : String;

begin
  setup := 'netsh wlan set hostednetwork mode=allow ssid=' + Edit1.Text + ' Key=' + Edit2.Text;
  if Edit1.Text = '' then
  begin
  ShowMessage('用户名为空，请输入用户名，用户名由英文或者数字组成！');
  Edit1.SetFocus;
  end
  else
  if Edit2.Text = '' then
  begin
  ShowMessage('密码为空，请输入密码，密码由英文或者数字组成，并且不少于八位！');
  Edit2.SetFocus;
  end
  else
  if Length(Edit2.Text) < 8 then
  begin
  ShowMessage('密码位数少于八位，请重新输入！');
  Edit2.SetFocus;
  end
  else
  CmdExecAndView(setup,Memo1);
  //ShellExecute(Handle,nil,'cmd.exe',pchar('/c pause&netsh wlan set hostednetwork mode=allow ssid=' + Edit1.Text + ' Key=' + Edit2.Text + '&pause'),nil,SW_Show);  //此句另一种写法： winexec(pchar('cmd.exe /c pause&' + p + '&pause'),SW_Show);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  ShellExecute(Handle,nil,'Ncpa.cpl',nil,nil,SW_Hide);
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  ShellExecute(Handle,nil,'explorer.exe',pchar('http://zhugecaomao.jimdo.com'),nil,SW_Hide);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  CmdExecAndView('netsh wlan start hostednetwork',Memo1);
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  CmdExecAndView('Netsh wlan stop hostednetwork',Memo1);
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  CmdExecAndView('netsh wlan set hostednetwork mode=disallow',Memo1);
end;

end.
