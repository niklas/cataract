$ = jQuery

$.fn.endlessPage = ->
  nearBottomOfPage = ->
    $(window).scrollTop() > $(document).height() - $(window).height() - 200

  $(@).each ->
    $list    = $(@)
    loading  = false

    $(window).scroll ->
      numPages = $list.data('num-pages')
      page     = $list.data('page') || 1

      return if loading == true
      return if page >= numPages

      if nearBottomOfPage()
        loading = true
        page++
        $list.data('page', page)
        $.ajax
          url: $list.data('url')
          type: 'get'
          data:
            torrent_search:
              page: page
          dataType: 'script'
          success: ->
            $(window).sausage('draw')
            loading=false

    $(window).sausage()
