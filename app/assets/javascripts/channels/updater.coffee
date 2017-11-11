blocked = (obj) ->
  obj.find('.dropdown-menu.show, .modal.show').length >= 1

App.cable.subscriptions.create { channel: "BasketChannel", basket_id: basket_id },
  received: (data) ->
    parsed = $(data)
    for selector in ["#reSubmitted", "#reMoney", "#reTable"]
      $sel = $(selector)

      if blocked($sel)
        console.log("not updating #{selector} because there's a modal or dropdown open")
        continue

      $sel.replaceWith parsed.find(selector)
    return

App.cable.subscriptions.create { channel: "OrderChannel", basket_id: basket_id, nick: nick },
  received: (data) ->
    $sel = $('#reOrder')
    $sel.html(data) unless blocked($sel)
    return
