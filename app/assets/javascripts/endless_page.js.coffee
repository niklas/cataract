$ = jQuery

$.fn.endlessSearch = ->
  nearBottomOfPage = ->
    $(window).scrollTop() > $(document).height() - $(window).height() - 200

  $(@).each ->
    $wrapper = $(@)
    $form    = $wrapper.find('form:first')
    $list    = $wrapper.find('table:first')
    $field   = $form.find('input.page')
    loading  = false

    $(window).scroll ->
      numPages = $list.data('num-pages')
      page     = $field.val() || 1

      return if loading == true
      return if page >= numPages

      if nearBottomOfPage()
        loading = true
        page++
        $field.val(page)
        $.ajax
          url: $list.data('url')
          type: 'get'
          data: $form.serialize()
          dataType: 'script'
          success: ->
            $(window).sausage('draw')
            loading=false

    $(window).sausage()
