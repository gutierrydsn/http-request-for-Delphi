unit HTTP.request;

interface

uses
  SysUtils, Variants, Classes, Datasnap.DSClientRest, REST.Client, REST.Types,
  DBXJSON, System.JSON, Data.DB, Datasnap.DBClient,
  Data.DBXJSONCommon, IPPeerClient, REST.Exception;

type
  THTTPResponse = String;
  THTTPRequestParams = Array of String;

  THTTPRequest = class
  private
    RESTClient  : TRESTClient;
    RESTRequest : TRESTRequest;
    RESTResponse: TRESTResponse;

    class var instance : THTTPRequest;

    function getURI(URL : String; pParams : THTTPRequestParams = []; pQueryParams : THTTPRequestParams = []) : String;
    function ParseJSON(Value : String) : TJSONObject;
    function request(pMethod : TRESTRequestMethod;URL : String; pBodyJSON : TJSONObject = Nil;
                     pParams : THTTPRequestParams = [];
                     pQueryParams : THTTPRequestParams = []) : THTTPResponse;

    procedure RequestBuilder();
    procedure PrepareRequest();
    procedure CloseRequest();
    procedure checkResponse(_message: String = '');
  public
    constructor create;
    destructor Destroy; override;

    class function getInstace : THTTPRequest;

    function GET(URL : String; pParams : THTTPRequestParams = []; pQueryParams : THTTPRequestParams = [])  : THTTPResponse;
    function POST(URL : String; pBodyJSON : TJSONObject; pParams : THTTPRequestParams = []; pQueryParams : THTTPRequestParams = []) : THTTPResponse; Overload;
    function POST(URL : String; pBodyJSON : String; pParams : THTTPRequestParams = []; pQueryParams : THTTPRequestParams = []): THTTPResponse; Overload;
    function PUT(URL : String; pBodyJSON : TJSONObject; pParams : THTTPRequestParams = []; pQueryParams : THTTPRequestParams = []) : THTTPResponse; Overload;
    function PUT(URL : String; pBodyJSON : String; pParams : THTTPRequestParams = []; pQueryParams : THTTPRequestParams = []): THTTPResponse; Overload;
    function DELETE(URL : String; pParams : THTTPRequestParams = []; pQueryParams : THTTPRequestParams = [])  : THTTPResponse;
  end;

Var
  HTTPRequest : THTTPRequest;

Const
  ERROR_SERVER_NOT_FOUND = 0;
  ERROR_PAGE_NOT_FOUND   = 404;
  ERROR_INTERNAL_SERVER  = 500;

implementation

procedure THTTPRequest.CloseRequest;
begin
  FreeAndNil(RESTClient);
  FreeAndNil(RESTRequest);
  FreeAndNil(RESTResponse);
end;

constructor THTTPRequest.create;
begin
  if Assigned(instance) then
    raise Exception.Create('Connetion já instanciado. Utilize o método getInstance');

  instance := self;
end;

function THTTPRequest.DELETE(URL : String; pParams, pQueryParams: THTTPRequestParams): THTTPResponse;
begin
  result := request(rmDELETE, URL,nil,pParams,pQueryParams);
end;

destructor THTTPRequest.Destroy;
begin
  inherited;
end;

function THTTPRequest.Get(URL : String; pParams : THTTPRequestParams ; pQueryParams : THTTPRequestParams): THTTPResponse;
begin
  result := request(rmGET,URL,nil,pParams,pQueryParams);
end;

function THTTPRequest.POST(URL : String; pBodyJSON : TJSONObject; pParams : THTTPRequestParams; pQueryParams : THTTPRequestParams) : THTTPResponse;
begin
  result := request(rmPOST, URL, pBodyJSON,pParams,pQueryParams);
end;

class function THTTPRequest.getInstace: THTTPRequest;
begin
  if Not(Assigned(instance)) then
    THTTPRequest.create;

  result := instance;
end;

function THTTPRequest.getURI(URL : String; pParams : THTTPRequestParams; pQueryParams : THTTPRequestParams): String;
Var i : Integer;
begin
  result := URL;
  for i := 0 to Length(pParams)-1 do
    result := result + pParams[i] + '/';

  result := result + '?';
  for i := 0 to Length(pQueryParams)-1 do
    result := result + pQueryParams[i] + '&';
end;

function THTTPRequest.ParseJSON(Value: String): TJSONObject;
begin
  result := TJSONObject(TJSONObject.ParseJSONValue(Value));
end;

function THTTPRequest.POST(URL : String; pBodyJSON: String; pParams : THTTPRequestParams; pQueryParams : THTTPRequestParams): THTTPResponse;
begin
  result := POST(URL,ParseJSON(pBodyJSON), pParams, pQueryParams);
end;

procedure THTTPRequest.PrepareRequest;
begin
  RESTClient   := TRESTClient.Create(EmptyStr);
  RESTRequest  := TRESTRequest.Create(nil);
  RESTResponse := TRESTResponse.Create(nil);

  RESTRequest.Client   := RESTClient;
  RESTRequest.Response := RESTResponse;

  RequestBuilder();
end;

function THTTPRequest.PUT(URL : String; pBodyJSON: TJSONObject; pParams : THTTPRequestParams; pQueryParams : THTTPRequestParams): THTTPResponse;
begin
  result := request(rmPUT, URL, pBodyJSON, pParams,pQueryParams);
end;

function THTTPRequest.PUT(URL : String; pBodyJSON: String; pParams : THTTPRequestParams; pQueryParams : THTTPRequestParams): THTTPResponse;
begin
  result := PUT(URL,ParseJSON(pBodyJSON),pParams,pQueryParams);
end;

function THTTPRequest.request(pMethod : TRESTRequestMethod;URL : String; pBodyJSON : TJSONObject;
pParams : THTTPRequestParams; pQueryParams : THTTPRequestParams): THTTPResponse;
Var
  JsonToSend    : TRESTRequestParameter;
begin
  PrepareRequest();
  try
    RESTClient.BaseURL := getURI(URL,pParams,pQueryParams);
    RESTRequest.Method := pMethod;

    if (Assigned(pBodyJSON)) then
    Begin
      JsonToSend := RESTRequest.Params.AddItem();
      JsonToSend.Value := pBodyJSON.ToJSON;
      JsonToSend.ContentType := ctAPPLICATION_JSON;
    End;

    try
      RESTRequest.Execute;
    except
      on e : exception do
      begin
        checkResponse(e.Message);
        raise Exception.Create('Ops... Ocorreu um erro.' + #13#10 + RESTResponse.Content);
      end;
    end;

    checkResponse();
    result := RESTResponse.Content;
  finally
    CloseRequest();
  end;
end;

procedure THTTPRequest.RequestBuilder();
Begin
  RESTClient.Accept  := 'application/json';
  RESTClient.AcceptCharset := 'UTF-8';

  RESTRequest.Accept := 'application/json';
  RESTRequest.AcceptCharset := 'UTF-8';

  RESTResponse.ContentType := 'application/json';
  RESTResponse.ContentEncoding := 'utf-8';
End;

procedure THTTPRequest.checkResponse(_message : String);
begin
  if RESTResponse.StatusCode = ERROR_SERVER_NOT_FOUND then
    raise Exception.Create('Ops... Unable to connect to server' +#13+ _message +#13+ RESTResponse.Content);

  if RESTResponse.StatusCode = ERROR_PAGE_NOT_FOUND then
    raise Exception.Create('Ops... The requested URL was not found' +#13+ _message +#13+ RESTResponse.Content);

  if RESTResponse.StatusCode = ERROR_INTERNAL_SERVER then
    raise Exception.Create('Ops... The server could not process your request' +#13+ _message +#13+ RESTResponse.Content);
end;

initialization
  HTTPRequest := THTTPRequest.getInstace;

finalization
  if Assigned(HTTPRequest) then
    FreeAndNil(HTTPRequest);
end.

