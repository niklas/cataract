# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def settings
    @settings ||= Setting.singleton
  end

  def link_to_bookmarklet(title, url, opts={})
    raise "url must be absolute" unless url.starts_with?('http')
    version = 1
    js = %Q~javascript:var d=document,w=window,e=w.getSelection,k=d.getSelection,x=d.selection,s=(e?e():(k)?k():(x?x.createRange().text:0)),f= '#{url}',l=d.location,e=encodeURIComponent,p='?v=#{version}&u='+e(l.href)%20+'&t='+e(d.title.replace(/^\s*|\s*$/g,''))%20+'&s='+e(s),u=f+p;location.href=u;~
    link_to title, js, opts
  end
end
