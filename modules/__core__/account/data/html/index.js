$(function() {

  $('.wallet-container').hide();

  window.addEventListener("message", (event) => {
    let item = event.data;
    let accounts;

    if (item.hide === true) {
      $('.wallet-container').hide();
    } else if (item.hide === false) {
      $('.wallet-container').show();
    }
  })

  accounts = [
    {
      id: 1,
      type: 'cash',
      amount: 340
    },
    {
      id: 2,
      type: 'maze bank',
      amount: 500
    }
  ]

  accounts.forEach((element) => {
    $('.wallet-container').append('<p class="money-type">' + element.type + '</p>')
    $('.wallet-container').append('<p class="account-amount">$' + element.amount + '</p>')
    console.log("fuck")
  })


})