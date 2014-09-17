var _dialogs = [];
var _modal = document.createElement("div");
document.body.appendChild(_modal);
_modal.style.position = "fixed";
_modal.style.left = 0; _modal.style.right = 0; _modal.style.top = 0; _modal.style.bottom = 0;
_modal.style.background = "rgba(200, 200, 200, 0.7)";
_modal.style.zIndex = 9999;
_modal.style.display = "none";

function dialogPolyfill(element){
  // Do multiple
  if(Array.isArray(element)){
    for(var k in element){
      dialogPolyfill(element[k]);
    }
    return;
  }
  // Is it already supported?
  if(element.show) return;

  _dialogs.push(element);
  _rszDialogs();

  element.style.display = "none";
  element.style.position = "fixed";
  element.style.zIndex = 10000;
  if(!element.style.background){
      element.style.background = "#FFF";
  }

  element.show = function(){
    element.style.display = "block";
    _rszDialogs()
  };
  element.showModal = function(){
    this.show();
    _modal.style.display = "block";

    // Only bit from the Google one we're using
    var first_form_ctrl = null;
    var autofocus = null;
    var findElementToFocus = function(root) {
      for (var i = 0; i < root.children.length; i++) {
        var elem = root.children[i];
        if (first_form_ctrl === null && !elem.disabled && (
        elem.nodeName == 'BUTTON' ||
        elem.nodeName == 'INPUT' ||
        elem.nodeName == 'KEYGEN' ||
        elem.nodeName == 'SELECT' ||
        elem.nodeName == 'TEXTAREA')) {
          first_form_ctrl = elem;
        }
        if (elem.autofocus) {
          autofocus = elem;
          return;
        }
        findElementToFocus(elem);
        if (autofocus !== null) return;
      }
      };
      findElementToFocus(this);

      if (autofocus !== null) {
        autofocus.focus();
      } else if (first_form_ctrl !== null) {
        first_form_ctrl.focus();
      }

      _rszDialogs()
  };
  element.close = function(){
    element.style.display = "none";
    _modal.style.display = "none";
  }
}
function _rszDialogs(){
  for(var k in _dialogs){
    var element = _dialogs[k];
    element.style.top = ((window.innerHeight/2) - (element.clientHeight/2)) + "px";
    element.style.left = ((window.innerWidth/2) - (element.clientWidth/2)) + "px";
  }
}

window.addEventListener("resize", _rszDialogs);
