$(document).on('turbolinks:load', function() {
  function showPricesForSize(evt) {
    var modal = $(evt.target).closest('.modal-content');
    var sizeId = modal.find('input[name=size]:checked').val();

    modal.find('.price:not(.price-'+sizeId+')').addClass('hidden');
    modal.find('.price-'+sizeId).removeClass('hidden');
  }

  function calculateTotal(evt) {
    var modal = $(evt.target).closest('.modal-content');

    var selectors = [
      // fields with direct price on them, e.g. size selectors
      'input:checked[data-price]:not(.hidden)',
      // when there's only one size
      'input[type=hidden][data-price]',
      // fields that have the price in a sibling, e.g. checkboxes
      'input:checked ~ [data-price]:not(.hidden)',
      // fields that have the price in a child, e.g. ??
      // 'input:checked [data-price]:not(.hidden)',
    ]
    var selected = modal.find(selectors.join());

    var prices = selected.map(function() { return $(this).data('price') }).toArray();
    var total = prices.reduce(function(acc, val) { return acc + val }, 0);
    var formatted = total.toLocaleString('de-DE', { style: 'currency', currency: 'EUR' });

    modal.find('#total-price').text(formatted);
  }

  function addToBasket(evt) {
    var modal = $(evt.target).closest('.modal');
    var form = modal.find('#productAddBody');
    var submit = modal.find('.btn-primary');

    submit.addClass('disabled');

    var url = form.attr('action');
    var data = form.serialize();
    $.post(url, data)
    .done(function(data, textStatus, jqXHR) {
      modal.modal('hide');
      $('#basket').html(jqXHR.responseText);
    }).fail(function(jqXHR, textStatus, errorThrown) {
      alert('OMG Unexpected error!\n\nDetails have been printed to the console.\n\nPreview:\n' + jqXHR.responseText);
      console.log(jqXHR);
      console.log(jqXHR.responseJSON);
      submit.removeClass('disabled');
    });

    // Too complicated, and code has to be duplicated within BE.
    // var text = form
    //   .find('input:checked').closest('label') // get description from label
    //   .contents().filter(function(){ return this.nodeType == 3; }) // only own text
    //   .map(function(x) { return this.textContent; }).toArray(); // cleanup
    // var select = form.find()
  }


  $('#productAdd').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget);
    var productId = button.data('product-id');
    var modal = $(this);
    var body = modal.find('#productAddBody');
    var submit = modal.find('.btn-primary');

    modal.find('#productAddHeader').text(button.data('product-name'));
    body.text(body.data('loading'));
    submit.addClass('disabled');
    submit.off('click').click(addToBasket);

    body.load('/product/' + productId, function() {
      modal.find('.size-selector input').on('change', showPricesForSize);
      modal.find('input').on('change', calculateTotal);

      modal.find('input').trigger('change');
      submit.removeClass('disabled');
    });
  })
});
