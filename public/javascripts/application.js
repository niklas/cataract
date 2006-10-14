// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var show_menu = false;
var menu_ani = false;
var observer = false;
function MenuHovered() {
//   $('menustatus').innerHTML = 'hovered';
   clearTimeout(observer);
   if (!show_menu) {
      show_menu = true;
      menu_ani = new Effect.SlideDown('actions');
   }
//   $('menustatus').innerHTML = 'opened';
}
function MenuUnhovered() {
//   $('menustatus').innerHTML = 'unhovered';
   observer = setTimeout(function() {
//      $('menustatus').innerHTML = 'closing';
      show_menu = false;
      menu_ani = new Effect.SlideUp('actions');
//      $('menustatus').innerHTML = 'closed';
   }, 1000);
}

