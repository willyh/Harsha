window.Scrollable = function(element) {

  if (!element) return null;

  var _this = this;

  this.topPosition = 0;

  this.container = element;
  this.element = this.container.children[0];

  //this.container.style.overflow = 'hidden';
  this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,0,0)';

  if (this.element.addEventListener) {
    this.element.addEventListener('touchstart', this, false);
    this.element.addEventListener('touchmove', this, false);
    this.element.addEventListener('touchend', this, false);
    this.element.addEventListener('webkitTransitionEnd', this, false);
    this.element.addEventListener('msTransitionEnd', this, false);
    this.element.addEventListener('oTransitionEnd', this, false);
    this.element.addEventListener('transitionend', this, false);
    window.addEventListener('resize', this, false);
  }
};

Scrollable.prototype = {

  handleEvent: function(e) {
    switch (e.type) {
      case 'touchstart': this.onTouchStart(e); break;
      case 'touchmove': this.onTouchMove(e); break;
      case 'touchend': this.onTouchEnd(e); break;
    }
  },
  
  onTouchStart: function(e) {
    this.start = {
      
      pageX: e.touches[0].pageX,
      pageY: e.touches[0].pageY -  this.topPosition,

      time: (Number (new Date() ))

    };

    this.deltaY = 0;

    this.element.style.MozTransitionDuration = this.element.style.webkitTransitionDuration = 0;
  },

  onTouchMove: function(e) {
    if(e.touches.length > 1 || e.scale && e.scale !== 1) return;

    e.preventDefault();

    var temp = this.start.pageY - e.touches[0].pageY;

    if( temp > this.element.offsetHeight + 20 - this.container.offsetHeight)
      this.deltaY = this.element.offsetHeight + 20 - this.container.offsetHeight;
    else if(temp < 0)
     this.deltaY = 0;
    else
      this.deltaY = temp;

    this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + -this.deltaY + 'px,0)';
  },

  onTouchEnd: function(e) {
    this.topPosition = -this.deltaY;
  }

}
