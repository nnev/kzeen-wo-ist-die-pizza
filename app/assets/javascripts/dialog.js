$(document).on('turbolinks:load', function() {
  // static jQuery refs
  var modal = $('#productDialog');
  var body = modal.find('#productDialogBody');
  var deleteButton = modal.find('.btn-danger');
  // variable jQuery refs
  var button = null;
  var submitButton = null;
  // values
  var productId = null;
  var selectedIndex = null;

  function showPricesForSize(evt) {
    var sizeId = body.find('input[name=size]:checked').val();

    modal.find('.price:not(.price-'+sizeId+')').addClass('hidden');
    modal.find('.price-'+sizeId).removeClass('hidden');
  }

  function calculateSum(evt) {
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
    var selected = body.find(selectors.join());

    var prices = selected.map(function() { return $(this).data('price') }).toArray();
    var sum = prices.reduce(function(acc, val) { return acc + val }, 0);
    var formatted = sum.toLocaleString('de-DE', { style: 'currency', currency: 'EUR' });

    modal.find('#sum-price').text(formatted);
  }

  function handleAjaxResponse(jqAjax) {
    jqAjax.done(function(data, textStatus, jqXHR) {
      modal.modal('hide');
      $('#basket').replaceWith(jqXHR.responseText);
      $('.basket-sum').text($('#basket-sum').text());
    }).fail(function(jqXHR, textStatus, errorThrown) {
      alert('OMG Unexpected error!\n\nDetails have been printed to the console.\n\nPreview:\n' + jqXHR.responseText);
      console.log(jqXHR);
      console.log(jqXHR.responseJSON);
      deleteButton.removeClass('disabled');
      submitButton.removeClass('disabled');
    });
  }

  function updateBasket(evt) {
    deleteButton.addClass('disabled');
    submitButton.addClass('disabled');

    handleAjaxResponse($.post(submissionUrl(), body.serialize()));
  }

  function deleteFromBasket(evt) {
    deleteButton.addClass('disabled');
    submitButton.addClass('disabled');

    handleAjaxResponse($.ajax({url: submissionUrl(), method: 'DELETE'}));
  }

  function submissionUrl() {
    return selectedIndex !== null ? '/order/item/' + selectedIndex : '/order/item/create'
  }

  function setupActionButtons() {
    var css = selectedIndex !== null ? '.edit' : '.add';
    submitButton = modal.find(css + ' .btn-primary');
    modal.find('.edit, .add').hide().filter(css).show();
    submitButton.off('click').click(updateBasket);
  }

  function setupDialogLoading() {
    modal.find('#productDialogHeader').text(button.data('product-name'));
    body.text(body.data('loading'));
    submitButton.addClass('disabled');
  }

  function loadBody() {
    body.load('/product/' + productId + '?select=' + selectedIndex, function() {
      modal.find('.size-selector input').on('change', showPricesForSize);
      modal.find('input').on('change', calculateSum);

      modal.find('input').trigger('change');
      submitButton.removeClass('disabled');
      deleteButton.removeClass('disabled');
    });
  }

  deleteButton.on('click', deleteFromBasket);
  modal.on('show.bs.modal', function (event) {
    button = $(event.relatedTarget);
    productId = button.data('product-id');

    // XXX: cannot use `|| null` pattern, because !!0 === false.
    selectedIndex = button.data('select');
    if(typeof selectedIndex === "undefined") selectedIndex = null;

    setupActionButtons();
    setupDialogLoading();
    loadBody();
    console.log('Dialog for: productId=' + productId + ' selectedIndex=' + selectedIndex);
  });
});
