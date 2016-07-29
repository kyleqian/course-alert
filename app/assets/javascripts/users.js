$(document).on('ready page:load', function () {

  //////////////////////////////////
  // PARSLEY MULTISTEP VALIDATION //
  //////////////////////////////////

  var $sections = $('.form-section');

  function navigateTo(index) {
    // Mark the current section with the class 'current'
    $sections
      .removeClass('current')
      .eq(index)
        .addClass('current');
    // Show only the navigation buttons that make sense for the current section:
    var atTheEnd = index >= $sections.length - 1;
    $('.form-navigation .next').toggle(!atTheEnd);
    $('.form-navigation [type=submit]').toggle(atTheEnd);
  }

  function curIndex() {
    // Return the current index by looking at which section has the class 'current'
    return $sections.index($sections.filter('.current'));
  }

  $('.form-navigation .next').click(function() {
    submitEmail();
  });

  // Submits email and shows checkboxes iff current block validates
  function submitEmail() {
    if ($('#main-form').parsley().validate({group: 'block-' + curIndex()})) {
      var email = $('#user_email').val();
      showCheckboxes(email);
    }
  }

  function showCheckboxes(email) {
    // POST to get user settings, or default settings if new user
    $.post('/users/login', {'email': email}, function(data, status) {
      if (status == "success" && Array.isArray(data)) {
        
        // Loads checkboxes
        for (var i = 0; i < data.length; i++) {
          $('input[value="' + data[i] + '"]').prop('checked', true);
        }

        // Shows submit button
        navigateTo(curIndex() + 1);

        // Greys out email field
        $('#user_email').attr('readonly', 'readonly');

        // Shows checkboxes
        $('.subject-settings-section').show();
      }
    }, 'json');
  }

  // Prepare sections by setting the `data-parsley-group` attribute to 'block-0', 'block-1', etc.
  $sections.each(function(index, section) {
    $(section).find(':input').attr('data-parsley-group', 'block-' + index);
  });
  
  navigateTo(0); // Start at the beginning

  // Repurpose Enter key for inputting email
  $('#user_email').on('keyup keypress', function (e) {
    var key = e.keyCode || e.which;
    if (key == 13) {
      e.preventDefault();
      submitEmail();
    }
  });
});