$(document)
  .ready(function() {
    $('.ui.form')
      .form({
        fields: {
          email: {
            identifier  : 'user_email',
            rules: [
              {
                type   : 'empty',
                prompt : 'Please enter your e-mail'
              },
              {
                type   : 'email',
                prompt : 'Please enter a valid e-mail'
              }
            ]
          },
          password: {
            identifier  : 'user_email',
            rules: [
              {
                type   : 'empty',
                prompt : 'Please enter your password'
              },
              {
                type   : 'length[6]',
                prompt : 'Your password must be at least 6 characters'
              }
            ]
          }
        }
      })
    ;
  })
;

$('.ui.accordion')
  .accordion()
;
$('.ui.modal')
  .modal('attach events', '.delete.my.account.button', 'show')
;
