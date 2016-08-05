$(document).on('turbolinks:load', function() {

  //////////////////////////////////
  // PARSLEY MULTISTEP VALIDATION //
  //////////////////////////////////

  var $mainForm = $('#main-form');
  var $loginButton = $('#login-btn');
  var $selectAllButton = $('#select-all-btn');
  var $deselectAllButton = $('#deselect-all-btn');
  var $submitButton = $('#submit-btn');
  var $userEmail = $('#user_email');
  var $checkBoxes = $('.subject-settings-section input');
  $selectAllButton.attr('disabled', '');
  $deselectAllButton.attr('disabled', '');
  $userEmail.attr('data-parsley-errors-messages-disabled', '');
  $userEmail.attr('data-parsley-group', 'email');
  $submitButton.attr('disabled', '');

  // Displays greyed out checkboxes
  $checkBoxes.each(function() {
    $this = $(this);
    $this.attr('disabled', '');
    $this.prop('checked', true);
  });

  $selectAllButton.click(function() {
    $checkBoxes.each(function() {
      $this = $(this);
      $this.prop('checked', true);
    });
  });

  $deselectAllButton.click(function() {
    $checkBoxes.each(function() {
      $this = $(this);
      $this.prop('checked', false);
    });
  })

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
    if ($mainForm.parsley().validate({group: 'email'})) {
      // Returns border for input field to original color
      $userEmail.css('border-color', '#ccc');

      // Remove login button
      $loginButton.remove();

      // Enable selecting buttons
      $selectAllButton.removeAttr('disabled');
      $deselectAllButton.removeAttr('disabled');

      // Disable email field
      $userEmail.attr('readonly', '');

      // Check email with AJAX
      var email = $userEmail.val();
      enableCheckboxes(email);
    } else {
      // Red border for input field if invalid
      $userEmail.css('border-color', 'red');
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

        // Enable submit button
        $submitButton.removeAttr('disabled');
        $submitButton.show();
      }
    }, 'json');
  }
});