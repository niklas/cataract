$ = jQuery

$.fn.endlessPage = ->
  nearBottomOfPage = ->
    $(window).scrollTop() > $(document).height() - $(window).height() - 200

  $(@).each ->
    $list    = $(@)
    loading  = false
    numPages = $list.data('num-pages')
    url      = $list.data('url')
    page     = $list.data('page') || 1

    return if page > 1 or page >= numPages

    $(window).scroll ->
      return if loading == true
      return if page >= numPages

      if nearBottomOfPage()
        loading = true
        page++
        $list.data('page', page)
        $.ajax
          url: "#{url}/page/#{page}"
          type: 'get'
          dataType: 'script'
          success: ->
            $(window).sausage('draw')
            loading=false

    $(window).sausage()
