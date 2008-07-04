Screw.Mock = {
  confirmWith: function(val) {
    Screw.Mock.confirmText = null;
    iframeWindow.confirm = function(str) {
      Screw.Mock.confirmText = str;
      return val;
    };
  }
};
Screw.XHR = function() {};
Screw.XHR.returns = function(str, type) {
  Screw.XHR.prototype.responseText = str;
  Screw.XHR.prototype.headers = {"content-type": "application/json"};
  if(type == "xml") Screw.XHR.prototype.responseXML = $(str).get();
};
Screw.XHR.prototype = {
  abort: function() {},
  getAllResponseHeaders: function() {},
  getResponseHeader: function(header) {
    return this.headers[header.toLowerCase()];
  },
  open: function(method, url, async, user, pass) {
    Screw.XHR.url = url;
  },
  send: function(content) {
    this.readyState = 4;
    this.status = 200;
    this.statusText = "OK";
  },
  setRequestHeader: function(label, value) {}
};