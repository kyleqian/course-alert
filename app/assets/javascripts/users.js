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

  // Next button goes forward iff current block validates
  $('.form-navigation .next').click(function() {
    submitEmail();
  });

  function submitEmail() {
    if ($('#main-form').parsley().validate({group: 'block-' + curIndex()})) {
      navigateTo(curIndex() + 1);
      $('#user_email').attr('readonly', 'readonly');
      $('.subject-settings-section').show();
    }
  }

  // Prepare sections by setting the `data-parsley-group` attribute to 'block-0', 'block-1', etc.
  $sections.each(function(index, section) {
    $(section).find(':input').attr('data-parsley-group', 'block-' + index);
  });
  
  navigateTo(0); // Start at the beginning


  //////////////////////////
  // REPURPOSE RETURN KEY //
  //////////////////////////

  $('#user_email').on('keyup keypress', function (e) {
    var key = e.keyCode || e.which;
    if (key == 13) {
      e.preventDefault();
      submitEmail();
    }
  });
});