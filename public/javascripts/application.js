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

