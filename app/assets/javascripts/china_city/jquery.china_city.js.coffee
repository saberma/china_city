(($) ->

  $.fn.china_city = ->
    @each ->
      selects = undefined
      selects = $(this).find('.city-select')
      #因为这里是用代码覆盖原gem中的js，所以，需要先将原js绑定的代码解除绑定
      #所以这里需要先unbind
      selects.unbind 'change'
      selects.bind 'change', ->
        $this = undefined
        next_selects = undefined
        $this = $(this)
        next_selects = selects.slice(selects.index(this) + 1)
        $('option:gt(0)', next_selects).remove()
        if next_selects.first()[0] and $this.val()
          return $.get('/china_city/' + $(this).val(), (data) ->
            i = undefined
            len = undefined
            option = undefined
            results = undefined
            results = []
            data = data.data
            i = 0
            len = data.length
            while i < len
              option = data[i]
              results.push next_selects.first()[0].options.add(new Option(option[0], option[1]))
              i++
            results
          )
        #如果没有下面这一句，则手机上选择了城市后，地区的下拉框不会刷新
        $this.blur()
        return
      return

  $ ->
    $('.city-group').china_city()
) jQuery

# ---
# generated by js2coffee 2.1.0