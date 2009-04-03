(function($){
  $.fn.lcars = function() {
    return this.each(function() {
      switch( $(this).lcarsKind() ) {
        case 'nes':
          $(this).setLcarsDecorations([
            ['corner','ne'],
            ['bow','ne'],
            ['corner','se'],
            ['bow','se'],
            ['stump','w','nw'],
            ['stump','w','sw']
          ]);
          break;
        case 'nws':
          $(this).setLcarsDecorations([
            ['corner','nw'],
            ['bow','nw'],
            ['corner','sw'],
            ['bow','sw'],
            ['stump','e','ne'],
            ['stump','e','se']
          ]);
          break;
        case 'ne':
          $(this).setLcarsDecorations([
            ['corner','ne'],
            ['bow','ne'],
            ['stump','w','nw'],
            ['stump','s','se']
          ]);
          break;
        case 'nw':
          $(this).setLcarsDecorations([
            ['corner','nw'],
            ['bow','nw'],
            ['stump','e','ne'],
            ['stump','s','sw']
          ]);
          break;
        case 'sen':
          $(this).setLcarsDecorations([
            ['corner','ne'],
            ['bow','ne'],
            ['corner','se'],
            ['bow','se'],
            ['stump','w','nw'],
            ['stump','w','sw']
          ]);
          break;
        case 'swn':
          $(this).setLcarsDecorations([
            ['corner','nw'],
            ['bow','nw'],
            ['corner','sw'],
            ['bow','sw'],
            ['stump','e','ne'],
            ['stump','e','se']
          ]);
          break;
        case 'wse':
          $(this).setLcarsDecorations([
            ['corner','sw'],
            ['bow','sw'],
            ['corner','se'],
            ['bow','se'],
            ['stump','n','ne'],
            ['stump','n','nw']
          ]);
          break;
        case 'wne':
          $(this).setLcarsDecorations([
            ['corner','nw'],
            ['corner','ne'],
            ['bow','nw'],
            ['bow','ne'],
            ['stump','s','sw'],
            ['stump','s','se']
          ]);
          break;
        case 'se':
          $(this).setLcarsDecorations([
            ['corner','se'],
            ['bow','se'],
            ['stump','w','sw'],
            ['stump','n','ne']
          ]);
          break;
        case 'sw':
          $(this).setLcarsDecorations([
            ['corner','sw'],
            ['bow','sw'],
            ['stump','e','se'],
            ['stump','n','nw']
          ]);
          break;
      }
      $(this).find('ul.buttons').removeClass('right').removeClass('left');
      if ( $(this).lcarsKind().match(/w/) ) {
        $(this).find('ul.buttons:has(li)').addClass('left');
      } else {
        $(this).find('ul.buttons:has(li)').addClass('right');
      }
    })
  };

  $.fn.setLcarsDecorations =  function(decs) {
    var old = $(this).find('img.decoration');
    var html = '';
    $(decs).each(function() {
      html = html + $.lcars.decoration(this[0],this[1],this[2])
    });
    $(html).appendTo(this);
    old.remove();
    return $(this);
  };


  $.fn.lcarsKind = function() {
    if (m = $(this).attr('class').match(/\b([nwse]{2,3})\b/)) {
      return m[1]
    } else {
      return '';
    }
  };

  $.lcars = {};
  $.lcars.decoration = function(kind, variant, klass) {
    return '<img class="' + kind + ' ' + variant + ' ' + klass + ' decoration"' +
    ' src="/lcars/decoration/' + kind + '/' + variant + '.png" />'
  };
}(jQuery));
