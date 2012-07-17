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
      case 'webkitTransitionEnd':
      case 'msTransitionEnd':
      case 'oTransitionEnd':
      case 'transitionend': this.transitionEnd(e); break;
    }
  },

  transitionEnd: function(e) {
    
    if(this.topPosition < -this.element.offsetHeight - 20 + this.container.offsetHeight)
    {
      var destination = -this.element.offsetHeight - 20 + this.container.offsetHeight;
      this.topPosition = destination;
      this.element.style.webkitTransitionDuration = this.element.style.MozTransitionDuration = this.element.style.msTransitionDuration = this.element.style.OTransitionDuration = this.element.style.transitionDuration = '300ms';
      this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + destination + 'px,0)';
      this.element.style.msTransform = this.element.style.OTransform = 'translateY(' + destination + 'px)';
    }
    else if( this.topPosition > 0 )
    {
      var destination = 0;
      this.topPosition = destination;
      this.element.style.webkitTransitionDuration = this.element.style.MozTransitionDuration = this.element.style.msTransitionDuration = this.element.style.OTransitionDuration = this.element.style.transitionDuration = '300ms';
      this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + destination + 'px,0)';
      this.element.style.msTransform = this.element.style.OTransform = 'translateY(' + destination + 'px)';
    }
  },

  onTouchStart: function(e) {
    this.start = {
      
      pageX: e.touches[0].pageX,
      pageY: e.touches[0].pageY -  this.topPosition,

      time: (Number (new Date() ))
    };

    this.deltaY = 0;

    // estimate velocity
    this.lastTick = Number( new Date() );
    this.lastY = 0;
    this.yVelocity = 0;

    this.element.style.MozTransitionDuration = this.element.style.webkitTransitionDuration = 0;
  },

  onTouchMove: function(e) {
    if(e.touches.length > 1 || e.scale && e.scale !== 1) return;

    e.preventDefault();

    this.deltaY = this.start.pageY - e.touches[0].pageY;
    this.deltaY = 
      this.deltaY /
        ( (this.deltaY > this.element.offsetHeight + 20 - this.container.offsetHeight     // if scrolling past bottom
          || this.deltaY < 0                                                            // or scrolling past top
        ) ?
        ( Math.abs(this.deltaY) / this.container.offsetHeight + 1 )
        : 1);

         this.start.pageY - e.touches[0].pageY;

    var now = Number( new Date() );
    this.yVelocity = (this.lastY - this.deltaY) / (now - this.lastTick);
    this.lastTick = now;
    this.lastY = this.deltaY;

    this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + -this.deltaY + 'px,0)';
  },

  onTouchEnd: function(e) {
    var destination = -this.deltaY + this.yVelocity * 30;

    document.getElementById('debug').innerHTML = destination;
    this.topPosition = destination;
    this.element.style.webkitTransitionDuration = this.element.style.MozTransitionDuration = this.element.style.msTransitionDuration = this.element.style.OTransitionDuration = this.element.style.transitionDuration = '100ms';
    this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + destination + 'px,0)';
    this.element.style.msTransform = this.element.style.OTransform = 'translateY(' + destination + 'px)';
  }

}
