/*
 * Swipe 1.0
 *
 * Brad Birdsall, Prime
 * Copyright 2011, Licensed GPL & MIT
 *
*/
window.Swipe = function(element, options) {

  // return immediately if element doesn't exist
  if (!element) return null;

  var _this = this;

  // retreive options
  this.options = options || {};
  this.index = this.options.startSlide || 0;
  this.initindex = this.index;
  this.speed = this.options.speed || 300;
  this.callback = this.options.callback || function() {};
  this.delay = this.options.auto || 0;

  // reference dom elements
  this.container = element;
  this.element = this.container.children[0]; // the slide pane

  // static css
  this.container.style.overflow = 'hidden';
  this.element.style.listStyle = 'none';

  // trigger slider initialization
  this.setup();

  // begin auto slideshow
  this.begin();

  // add event listeners
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

Swipe.prototype = {

  setup: function() {

    // get and measure amt of slides
    this.slides = this.element.children;
    this.length = this.slides.length;

    // return immediately if their are less than two slides
    if (this.length < 2) return null;

    // determine height of each slide
    this.height = this.container.getBoundingClientRect().height;

    // return immediately if measurement fails
    if (!this.height) return null;

    // hide slider element but keep positioning during setup
    this.container.style.visibility = 'hidden';

    // dynamic css
    var height = 0;
    var index = this.slides.length;
    while (index--) {
      var el = this.slides[index];
      height += el.height;
      el.style.width = this.width + 'px';
    }
    this.element.style.height = height + 'px';

    // set start position and force translate to remove initial flickering
    this.slide(this.index, 0); 

    // show slider element
    this.container.style.visibility = 'visible';

  },

  slide: function(index, duration) {
    var style = this.element.style;
    
    // set new index to allow for expression arguments
    this.index = index;

    // fallback to default speed
    if (duration == undefined) {
        duration = this.speed;
    }

    // set duration speed (0 represents 1-to-1 scrolling)
    style.webkitTransitionDuration = style.MozTransitionDuration = style.msTransitionDuration = style.OTransitionDuration = style.transitionDuration = duration + 'ms';

    // translate to given index position
    style.MozTransform = style.webkitTransform = 'translate3d(0,' + (this.container.offsetTop - this.startPosition(this.index)) + 'px,0)';
    style.msTransform = style.OTransform = 'translateY(' + (this.container.offsetTop - this.startPosition(this.index)) + 'px)';

  },

  getPos: function() {
    
    // return current index position
    return this.index;

  },

  startPosition: function(i) {
    return i ? this.slides[i - 1].offsetTop + this.slides[i - 1].offsetHeight : this.container.offsetTop;
  },

  prev: function(delay) {

    // cancel next scheduled automatic transition, if any
    this.delay = delay || 0;
    clearTimeout(this.interval);

    // if not at first slide
    if (this.index) this.slide(this.index-1, this.speed);

  },

  next: function(delay) {

    // cancel next scheduled automatic transition, if any
    this.delay = delay || 0;
    clearTimeout(this.interval);

    if (this.index < this.length - 1) this.slide(this.index+1, this.speed); // if not last slide
    else this.slide(0, this.speed); //if last slide return to start

  },

  begin: function() {

    var _this = this;

    this.interval = (this.delay)
      ? setTimeout(function() { 
        _this.next(_this.delay);
      }, this.delay)
      : 0;
  
  },
  
  stop: function() {
    this.delay = 0;
    clearTimeout(this.interval);
  },
  
  resume: function() {
    this.delay = this.options.auto || 0;
    this.begin();
  },

  handleEvent: function(e) {
    switch (e.type) {
      case 'touchstart': this.onTouchStart(e); break;
      case 'touchmove': this.onTouchMove(e); break;
      case 'touchend': this.onTouchEnd(e); break;
      case 'webkitTransitionEnd':
      case 'msTransitionEnd':
      case 'oTransitionEnd':
      case 'transitionend': this.transitionEnd(e); break;
      case 'resize': this.setup(); break;
    }
  },

  transitionEnd: function(e) {
    
    if (this.delay) this.begin();

    this.callback(e, this.index, this.slides[this.index]);

  },

  onTouchStart: function(e) {
    
    this.start = {

      // get touch coordinates for delta calculations in onTouchMove
      pageX: e.touches[0].pageX,
      pageY: e.touches[0].pageY,

      // set initial timestamp of touch sequence
      time: Number( new Date() )

    };

    // used for testing first onTouchMove event
    this.isScrolling = undefined;
    
    // reset deltaY
    this.deltaY = 0;

    // estimate velocity
    this.lastTick = Number( new Date() );
    this.lastY = 0;
    this.yVelocity = 0;

    // set transition time to 0 for 1-to-1 touch movement
    this.element.style.MozTransitionDuration = this.element.style.webkitTransitionDuration = 0;

  },

  onTouchMove: function(e) {

    // ensure swiping with one touch and not pinching
    if(e.touches.length > 1 || e.scale && e.scale !== 1) return;

    this.deltaY = e.touches[0].pageY - this.start.pageY;

    // determine if scrolling test has run - one time test
    if ( typeof this.isScrolling == 'undefined') {
      this.isScrolling = !!( this.isScrolling || Math.abs(this.deltaY) < Math.abs(e.touches[0].pageX - this.start.pageX) );
    }

    // if user is not trying to scroll horizontally
    if (!this.isScrolling) {

      // prevent native scrolling 
      e.preventDefault();

      // cancel slideshow
      clearTimeout(this.interval);

      // increase resistance if first or last slide
      this.deltaY = 
        this.deltaY / 
          ( (!this.index && this.deltaY > 0               // if first slide and sliding up
            || this.index == this.length - 1              // or if last slide and sliding down
            && this.deltaY < 0                            // and if sliding at all
          ) ?                      
          ( Math.abs(this.deltaY) / this.height + 1 )      // determine resistance level
          : 1 );                                          // no resistance if false
      var now = Number( new Date() );
      this.yVelocity = (this.lastY - this.deltaY) / (now - this.lastTick);
      this.lastTick = now;
      this.lastY = this.deltaY;

      var top_dist = this.container.offsetTop - this.slides[this.index].offsetTop;

      // translate immediately 1-to-1
      this.element.style.MozTransform = this.element.style.webkitTransform = 'translate3d(0,' + (this.deltaY + top_dist) + 'px,0)';
    }

  },

  onTouchEnd: function(e) {

    // determine if slide attempt triggers next/prev slide
    var isValidSlide = 
          Number(new Date()) - this.start.time < 250      // if slide duration is less than 250ms
          && Math.abs(this.deltaY) > 20                   // and if slide amt is greater than 20px
          || Math.abs(this.deltaY) > this.slides[this.index].getBoundingClientRect().height/2,        // or if slide amt is greater than half the height

    // determine if slide attempt is past start and end
        isPastBounds = 
          !this.index && this.deltaY > 0                          // if first slide and slide amt is greater than 0
          || this.index == this.length - 1 && this.deltaY < 0;    // or if last slide and slide amt is less than 0

      var position = -this.deltaY + this.slides[this.index].offsetTop + .5*this.slides[this.index].getBoundingClientRect().height;
      var destination = position + (Math.abs(this.yVelocity) < .05 ? 0 : this.yVelocity * this.speed*.6);
    // if not scrolling horizontally
    if (!this.isScrolling) {
      var end_index = 0;
      if( destination < this.startPosition(0) ) 
        end_index = 0;
      else if(destination >= this.startPosition(this.length-1))
        end_index = this.length - 1;
      else {
        for( var i = 0; i < this.length-1; i++ )
          if( this.startPosition(i) <= destination && destination < this.startPosition(i+1) )
            end_index = i;
      }

      // call slide function with slide end value based on isValidSlide and isPastBounds tests
      this.slide( isValidSlide && !isPastBounds ?  end_index : this.index , this.speed );

    }

  }

};
