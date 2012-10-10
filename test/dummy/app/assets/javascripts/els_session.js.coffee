$ ->
  
  $('.els_session input#override').on "click", ->
    if $(this).is(':checked')
      $('.els_session input#password').parent().fadeOut()
    else
      $('.els_session input#password').parent().fadeIn()