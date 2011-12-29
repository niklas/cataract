jQuery ($) ->
  $.fn.endlessPage = ->
    nearBottomOfPage = ->
      $(window).scrollTop() > $(document).height() - $(window).height() - 200

    $(@).each ->
      $list    = $(@)
      loading  = false
      page     = 1
      numPages = $list.data('num-pages')
      url      = $list.data('url')

      $(window).scroll ->
        return if loading == true
        return if page == numPages

        if nearBottomOfPage()
          loading = true
          page++
          $.ajax
            url: "#{url}/page/#{page}"
            type: 'get'
            dataType: 'script'
            success: ->
              $(window).sausage('draw')
              loading=false

      $(window).sausage()
