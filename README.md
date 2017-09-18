# ABOUT
  This library is to facilitate the use of http requests.

## how use http.request

##### GET
- use simple request
``` pascal
    HTTPRequest.GET('http://url');
```
    
- with use queryParams
``` pascal
    HTTPRequest.GET('http://url/resource/001',[],['param1=valu1', 'param2=value2']);
```
    
##### PUT
- use simple request
``` pascal
    
    HTTPRequest.PUT('http://url/resource/001',myObjectInJSON);
```

##### POST
- use simple request
``` pascal
    
    HTTPRequest.POST('http://url/resource',myObjectInJSON);
```

##### DELETE
- use simple request
``` pascal
    
    HTTPRequest.DELETE('http://url/resource/001');
```
