unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,richedit,
  uLog,uConfig,uDM,uOrder;

type
  TfMain = class(TForm)
    Bar1: TStatusBar;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    btnSendMSG: TButton;
    btnClose: TButton;
    Splitter1: TSplitter;
    edtInput: TRichEdit;
    btnSendFile: TButton;
    edtInfo: TRichEdit;
    GroupBox2: TGroupBox;
    edtFriendID: TEdit;
    procedure btnCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnSendMSGClick(Sender: TObject);
  private
    { Private declarations }
    procedure TryExcepts(Sender: TObject; E: Exception);
    procedure SetRichEditNum(RichEdit1:tRichEdit);
    procedure SetRichEditLineSpacing(RichEdit1:tRichEdit);
  public
    { Public declarations }
    procedure LogMain(const str: string);
    procedure MSGmain(friendID:integer;msg:ansistring);
    procedure myMSGmain(msg:string);
  end;

var
  fMain: TfMain;

implementation

{$R *.dfm}
procedure TfMain.myMSGmain(msg:string);
var
  selStart:integer;
begin

  edtInfo.Lines.Add(msg);
  selStart:=length(edtInfo.Lines.Text)-length(msg)-4;
  edtINfo.SelStart:=selStart;
  edtInfo.SelLength:=length(msg);
  edtInfo.SelAttributes.Size:=12;
  edtInfo.SelAttributes.Color:=clBlue;
  edtInfo.SelStart := 0;
  edtInfo.SelLength := 0;

end;
procedure TfMain.MSGmain(friendID:integer;msg:ansistring);
var
  selStart:integer;
  mysmg:string;
begin
  edtFriendID.Text:=inttostr(friendID);
  selStart:=length(edtInfo.Lines.Text);
  mysmg:=string(msg);
  edtInfo.Lines.Add(mysmg);
  edtINfo.SelStart:=selStart;
  edtInfo.SelLength:=length(mysmg);
  edtInfo.SelAttributes.Size:=12;
  edtInfo.SelAttributes.Color:=claqua;
  edtInfo.SelStart := 0;
  edtInfo.SelLength := 0;
end;
procedure TfMain.TryExcepts(Sender: TObject; E: Exception);
begin
  LogMain(E.Message);
end;
procedure TfMain.btnSendMSGClick(Sender: TObject);
var
  userID:integer;
  msg:string;
  ansimsg:ansiString;
  len:integer;
begin
  if dm.cs1.Active=false then
  begin
    showmessage('δ���ӷ�������');
    exit;
  end;
  if trim(edtFriendID.text)='' then
  begin
    showmessage('������Է���ţ�');
    exit;
  end;
  if trim(edtInput.text)='' then
  begin
    showmessage('��Ϣ����Ϊ�գ�');
    exit;
  end;
  msg:=trim(edtInput.text);
  ansimsg:=ansiString(msg);
  len:=length(ansimsg);
  if len>=uDM.MAX_BUF_SIZE-sizeof(stOrderHeader) then
  begin
    showmessage('��Ϣ���ݲ��ܴ���'+inttostr(uDM.MAX_BUF_SIZE-sizeof(stOrderHeader)));
    exit;
  end;
try
  userID:=strtoint(trim(edtFriendID.Text));

  dm.SendMSG(userID,ansimsg);
  myMSGmain(msg);
finally

end;
end;

procedure TfMain.FormCreate(Sender: TObject);
begin
Application.OnException := TryExcepts;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  fmain.Caption:=uConfig.APP_NAME+uConfig.APP_VERSION;
  if(dm.cs1.Active)then bar1.Panels[0].Text:='���ӷ������ɹ���';
end;

procedure tfmain.LogMain(const str: string);
var
  selStart:integer;
  msg:string;
begin

  msg:=Log(str);
  edtInfo.Lines.Add(msg);

  selStart:=length(edtInfo.Lines.Text)-length(msg)-2;
  edtINfo.SelStart:=selStart;
  edtInfo.SelLength:=length(msg);
  edtInfo.SelAttributes.Size:=8;
  edtInfo.SelAttributes.Color:=clGray;
  edtInfo.SelStart := 0;
  edtInfo.SelLength := 0;
end;

procedure TfMain.btnCloseClick(Sender: TObject);
begin
  close;
end;


























procedure TfMain.SetRichEditLineSpacing(RichEdit1:tRichEdit);
var
  pf: PARAFORMAT2;
begin
  FillChar(pf, sizeof(paraformat2), #0);
  pf.cbSize := SizeOf(paraformat2);
  pf.dwMask := PFM_LINESPACING  ;   //��Ҫ������ PFM_LINESPACING ��־��bLineSpacingRule��dyLineSpacing�ſ�����Ч

//  pf.bLineSpacingRule := 0;   //�����о࣬dyLineSpacing��ֵ��������
//  pf.bLineSpacingRule := 1;   //1.5���о࣬dyLineSpacing��ֵ��������
//  pf.bLineSpacingRule := 2;   //�����о࣬dyLineSpacing��ֵ��������
//  pf.bLineSpacingRule := 3;   //��dyLineSpacing���Ϊ��λָ���м�࣬����ֵС�ڵ����о�ʱ��Ч��Ϊ�����о�
//  pf.bLineSpacingRule := 5;   //��dyLineSpacing/20ָ���м��

  pf.bLineSpacingRule := 4;   //��dyLineSpacing���Ϊ��λָ���м��
  pf.dyLineSpacing := RichEdit1.Font.Size * 20 + 20 * 4; //���Ǳ��ߴ�ż���ģ����Ը��������С���ڵģ��м���С���룬������ʱ���ܳ����������ص�����������Ϊ300�����Լ�����

  RichEdit1.SelectAll;   //ֻ��ѡ����ı���Ч��***��Ҫ***
  SendMessage(RichEdit1.Handle, EM_SETPARAFORMAT, 0, LPARAM(@pf));
  RichEdit1.SelStart := 0;
  RichEdit1.SelLength := 0;

end;
procedure TfMain.SetRichEditNum(RichEdit1:tRichEdit);
const
  PFNS_PAREN    =   $000;  //e.g. 1)
  PFNS_PARENS   = $100;  //e.g. (1)
  PFNS_PERIOD   = $200;  //e.g. 1.
  PFNS_PLAIN    =   $300;
  PFNS_NONUMBER =   $400;

const
  PFN_NONE     = $00000000;  //��
  PFN_BULLET   = $00000001;  //��ɫʵ��Բ��
  PFN_ARABIC   = $00000002;  //0,1,2
  PFN_LCLETTER = $00000003;  //a,b,c
  PFN_UCLETTER = $00000004;  //A,B,C
  PFN_LCROMAN  = $00000005;  //i,ii,iii
  PFN_UCROMAN  = $00000006;  //I,II,III

  var
  pf: PARAFORMAT2;
begin
  FillChar(pf, sizeof(paraformat2), #0);
  pf.cbSize := SizeOf(paraformat2);
  //PFM_NUMBERING: wNumbering ֵ��Ч
  //PFM_NUMBERINGSTYLE: wNumberingStyleֵ��Ч
  //PFM_NUMBERINGSTART: wNumberingStartֵ��Ч
  //PFM_STARTINDENT: dxStartIndentֵ��Ч
  pf.dwMask := PFM_NUMBERING or PFM_NUMBERINGSTYLE or PFM_NUMBERINGSTART or PFM_STARTINDENT;//or PFM_OFFSET;

  pf.wNumberingStyle := PFNS_PERIOD;  //�����кŵ���ʽ������Ϊ��)������.������()��
  pf.wNumberingStart := 1;            //�����к���ʼֵ
  pf.wNumbering := PFN_ARABIC;        //�����кŵĸ�ʽ������Ϊ���������ֻ���Ӣ����ĸ�ȸ�ʽ
  pf.dxStartIndent := 60;             //������������ֵ

  RichEdit1.SelectAll;
  SendMessage(RichEdit1.Handle, EM_SETPARAFORMAT, 0, LPARAM(@pf));
  RichEdit1.SelStart := 0;
  RichEdit1.SelLength := 0;

end;

end.