$(".scrollable").bind('touchend', function(e) {
  this.start = {
    
    pageX: e.touches[0].pageX,
    pageY: e.touches[0].pageY,

    time: (Number (new Date() ))

  };

  this.deltaY = 0;

  this.element.style.MozTransitionDuration = this.element.style.webkitTransitionDuration = 0;
});

$(".scrollable").bind('touchmove', function(e) {
  if(e.touches.length > 1 || e.scale && e.scale !== 1) return;

  e.preventDefault();

  this.deltaY = e.touches[0] - this.start.pageY;
    

  this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + (this.deltaY) + 'px,0)';
});


$(".scrollable").bind('touchend', function(e) {

});
