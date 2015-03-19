(($) ->
  bind_data = (china_city, parent, child) ->
    china_city.on 'change', parent, ->
      child_select = china_city.find(child)
      child_select.find('option').slice(1).remove()
      child_select.change()
      value = $(this).find(':checked').data('value')
      if value?
        $.get "/china_city/#{value}", (data) ->
          $('<option>', {value: option[0], text: option[0]}).data('value', option[1]).appendTo(child_select) for option in data
          # init value after data completed.
          child_select.trigger('china_city:load_data_completed');
  
  $.fn.china_city = (options) ->
    options = $.extend
      state: '.state'
      city: '.city'
      district: '.district'
    , options
    
    this.each (index, china_city) ->
      bind_data $(china_city), options.state, options.city
      bind_data $(china_city), options.city, options.district
)(jQuery)

$ ->
  $('.china-city').china_city()
