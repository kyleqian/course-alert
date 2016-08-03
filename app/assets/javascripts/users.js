$(document).on('turbolinks:load', function() {

  //////////////////////////////////
  // PARSLEY MULTISTEP VALIDATION //
  //////////////////////////////////

  var $loginButton = $('#login-button');
  var $submitButton = $('#submit-button');  
  var $userEmail = $('#user_email');
  var $sections = $('.form-section');
  var $checkBoxes = $('.subject-settings-section input');
  $submitButton.attr('disabled', '');

  // Displays greyed out checkboxes
  $checkBoxes.each(function() {
    $this = $(this);
    $this.attr('disabled', '');
    $this.prop('checked', true);
  });

  // Prepare sections by setting the `data-parsley-group` attribute to 'block-0', 'block-1', etc.
  $sections.each(function(index, section) {
    $(section).find(':input').attr('data-parsley-group', 'block-' + index);
  });

  $loginButton.click(function() {
    tryToLogin();
  });

  // Repurpose Enter key for submitting email
  $userEmail.on('keyup keypress', function(e) {
    var key = e.keyCode || e.which;
    if (key == 13) {
      e.preventDefault();
      tryToLogin();
    }
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
      enableCheckboxes(email);
    }
  }

  function enableCheckboxes(email) {
    // POST to get user settings, or default settings if new user
    $.post('/login', {'email': email}, function(data, status) {
      if (status == "success" && Array.isArray(data)) {

        // Enables checkboxes and unchecks all of them
        $checkBoxes.each(function() {
          $this = $(this);
          $this.removeAttr('disabled');
          $this.prop('checked', false);
        });
        
        // Checks checkboxes based on user settings
        for (var i = 0; i < data.length; i++) {
          $('input[value="' + data[i] + '"]').prop('checked', true);
        }

        // Shows checkboxes
        // $('.subject-settings-section').show();

        // Enable submit button
        $submitButton.removeAttr('disabled');
      }
    }, 'json');
  }
});