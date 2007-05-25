// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var show_menu = false;
var menu_ani = false;
var observer = false;
function MenuHovered() {
   clearTimeout(observer);
   if (!show_menu) {
      show_menu = true;
      menu_ani = new Effect.SlideDown('actions');
   }
}
function MenuUnhovered() {
   observer = setTimeout(function() {
      menu_ani = new Effect.SlideUp('actions');
      show_menu = false;
   }, 1000);
}

function MenuReset() {
  menu_ani = false;
  show_menu = true;
  a = $('actions');
  a.style.display = 'block';
  a.style.height  = '100px';
}

function bad_log(message) {
  m = "<div>" + message + "</div>";
  new Insertion.Bottom('watchlist', m);
}

function clearQueueFromNotice() {
  var queue = Effect.Queues.get('notice');
  queue.each(function(e) { 
      if (e.element == $('notice')) {
        e.cancel();
      }
  })
  queue = Effect.Queues.get('notice');
  queue.each(function(e) { 
      if (e.element == $('notice')) {
        e.cancel();
      }
  })
}

var noticeCount = 0;
function noticeWillBeRemoved() {
  noticeCount--;
  if (noticeCount <= 0) {
    noticeCount = 0;
    new Effect.Fade("notice", { duration:2.3, from:0.4, queue: { scope:'notice',position:'end' }, to:0 });
  }
}
function noticeWasInserted() {
  clearQueueFromNotice();
  noticeCount++;
  new Effect.Appear("notice", { from: $('notice').style.opacity, queue: { scope:'notice',position:'front' }, to:0.4 });
}

