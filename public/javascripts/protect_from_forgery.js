//jQuery
var _token = jQuery("meta[name='csrf-token']").attr('content');
if (typeof(jQuery) != "undefined") {
  (function(jQuery){
    var originalAjax = jQuery.ajax;
    jQuery.extend({
      ajax: function(o) {
        if (!(o.type && o.type.toUpperCase()=="GET")) {
          o.data = o.data || {};
          if (typeof(o.data)==="string") {
            if (o.data.indexOf("authenticity_token") == -1)
              o.data += "&authenticity_token="+_token;
          } else {
            o.data.authenticity_token = _token;
          }
        }
        return originalAjax.call(this, o);
      }
    });
  })(jQuery);
}
