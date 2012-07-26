window.Scrollable = function(element) {

  if (!element) return null;

  var _this = this;

  this.topPosition = 0;

  var dv = document.createElement('div');
  element.parentNode.insertBefore(dv, element);
  dv.setAttribute('class', 'scrollable');
  var reg = new RegExp('(\\s|^)'+'scrollable'+'(\\s|$)');
  element.className=element.className.replace(reg,' max-height ');
  dv.appendChild(element);
  var injection = document.createElement('div');
  injection.style.margin = '0';
  injection.style.height = '1px';
  element.insertBefore(injection,element.childNodes[0]);

  this.container = element.parentNode;
  this.element = element;

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


  onTouchStart: function(e) {
    this.start = {
      
      pageX: e.touches[0].pageX,
      pageY: e.touches[0].pageY + this.topPosition,

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
    if(this.deltaY > this.element.offsetHeight - this.container.offsetHeight) {
      var dif = this.deltaY - this.element.offsetHeight + this.container.offsetHeight;
      this.deltaY = (this.element.offsetHeight - this.container.offsetHeight) + dif / 2;
    }
    if(this.deltaY < 0)
      this.deltaY = this.deltaY / 2;

    var now = Number( new Date() );
    this.yVelocity = (this.lastY - this.deltaY) / (this.lastTick - now );
    this.lastTick = now;
    this.lastY = this.deltaY;

    this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + -this.deltaY + 'px,0)';
  },

  onTouchEnd: function(e) {
    var speed = 300;
    var destination = this.deltaY;
    this.topPosition = destination;
    if(-this.container.offsetHeight/3 < this.deltaY &&
        this.deltaY < this.element.offsetHeight - 2/3*this.container.offsetHeight)
    {
      destination = this.deltaY + this.yVelocity * speed;
      if(destination > this.element.offsetHeight - this.container.offsetHeight)
      {
        var dif = destination - (this.element.offsetHeight - this.container.offsetHeight);
        destination = (this.element.offsetHeight - this.container.offsetHeight)
          + Math.min(dif / (Math.abs(this.yVelocity)+1), this.container.offsetHeight/3);
      }
      if(destination < 0)
        destination = Math.max(destination / (Math.abs(this.yVelocity)+1), -this.container.offsetHeight/3);

      if(this.yVelocity != 0)
        speed = (destination - this.deltaY) / this.yVelocity;


      this.topPosition = destination;
      this.element.style.webkitTransitionDuration = this.element.style.MozTransitionDuration = this.element.style.msTransitionDuration = this.element.style.OTransitionDuration = this.element.style.transitionDuration = speed+'ms';
      this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + -destination + 'px,0)';
      this.element.style.msTransform = this.element.style.OTransform = 'translateY(' + -destination + 'px)';
    }
    if(destination == this.deltaY)
      this.transitionEnd(e);
  },

  transitionEnd: function(e) {
    var destination = this.topPosition;
    if(destination > this.element.offsetHeight - this.container.offsetHeight)
    {
      destination = this.element.offsetHeight - this.container.offsetHeight;
      this.topPosition = destination;
      this.element.style.webkitTransitionDuration = this.element.style.MozTransitionDuration = this.element.style.msTransitionDuration = this.element.style.OTransitionDuration = this.element.style.transitionDuration = '300ms';
      this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + -destination + 'px,0)';
      this.element.style.msTransform = this.element.style.OTransform = 'translateY(' + -destination + 'px)';
    }
    else if(destination < 0)
    {
      destination = 0;
      this.topPosition = destination;
      this.element.style.webkitTransitionDuration = this.element.style.MozTransitionDuration = this.element.style.msTransitionDuration = this.element.style.OTransitionDuration = this.element.style.transitionDuration = '300ms';
      this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + -destination + 'px,0)';
      this.element.style.msTransform = this.element.style.OTransform = 'translateY(' + -destination + 'px)';
    }
  }
}
