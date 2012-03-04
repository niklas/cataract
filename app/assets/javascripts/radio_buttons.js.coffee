jQuery ->
  updateBtnState = (btn, input, updateRadios) ->
    btn.toggleClass('active', input.prop('checked'))
    btn.toggleClass('disabled', input.prop('disabled'))

  $(document).live 'change', '.btn-toggle input', (e) ->
    $input = $(e.target)
    # radio button that are automatically unchecked dont trigger a change event
    if $input.is ':radio'
      selector = "input[type='radio'][name='#{$input.attr('name')}']"
      $(selector).each ->
        updateBtnState $(this).parents('.btn-toggle'), $(this)
    else
        updateBtnState $input.parents('.btn-toggle'), $input

    
  $('.btn-toggle').each ->
    updateBtnState $(this), $(this).find('input')
