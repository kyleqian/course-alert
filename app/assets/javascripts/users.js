$(document).on('turbolinks:load', function() {

  //////////////////////////////////
  // PARSLEY MULTISTEP VALIDATION //
  //////////////////////////////////

  var $loginButton = $('#login-button');
  var $submitButton = $('#submit-button');  
  var $userEmail = $('#user_email');
  var $sections = $('.form-section');
  $submitButton.attr('disabled', '');

  // Prepare sections by setting the `data-parsley-group` attribute to 'block-0', 'block-1', etc.
  $sections.each(function(index, section) {
    $(section).find(':input').attr('data-parsley-group', 'block-' + index);
  });

  $loginButton.click(function() {
    tryToLogin();
  });

  // Submits email and shows checkboxes iff current block validates
  function tryToLogin() {
    if ($('#main-form').parsley().validate({group: 'block-0'})) {
      // Disable login button
      $loginButton.attr('disabled', '');

      // Disable email field
      $userEmail.attr('readonly', 'readonly');

      // Check email with AJAX
      var email = $userEmail.val();
      showCheckboxes(email);
    }
  }

  function showCheckboxes(email) {
    // POST to get user settings, or default settings if new user
    $.post('/login', {'email': email}, function(data, status) {
      if (status == "success" && Array.isArray(data)) {
        
        // Loads checkboxes
        for (var i = 0; i < data.length; i++) {
          $('input[value="' + data[i] + '"]').prop('checked', true);
        }

        // Shows checkboxes
        $('.subject-settings-section').show();

        // Enable submit button
        $submitButton.removeAttr('disabled');
      }
    }, 'json');
  }

  // Repurpose Enter key for inputting email
  $userEmail.on('keyup keypress', function (e) {
    var key = e.keyCode || e.which;
    if (key == 13) {
      e.preventDefault();
      tryToLogin();
    }
  });
});