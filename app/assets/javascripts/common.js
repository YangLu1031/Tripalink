/**
 * Created by yugu on 7/18/15.
 */

//  var setupAvatarUpload = function() {
//   $(".picture-preview").click(function() {
//     $(".picture-file-field").click();
//   });

//   $('.picture-file-field').change(function() {
//     alert('changed')
//   });

//   // $('#test').change(function() {
//   //   $('#test_form').submit();
//   // });
// }

/** user/cars/index.html.erb ...*/
var ready;
ready = function () {
  $('.car_picture_upload').click(function() {
    $('.car_picture_field').click();
  });

  $('.tab').click(function(event) {
    $('.tab').each(function() {
      $(this).attr('class', 'tab')
    });
    $(this).attr('class', 'tab active');
  });

  $('.timeline-panel-btn').click(function(event) {
    var body = $('.timeline-body', $(this).parent('.timeline-panel'));
    if (body.is(":visible")) {
      $(this).attr('class', 'glyphicon glyphicon-chevron-down timeline-panel-btn');
    } else {
      $(this).attr('class', 'glyphicon glyphicon-chevron-up timeline-panel-btn');
    }
    body.toggle();
  });

  var statuses = {};
  $('.button-checkbox').each(function () {

    // Settings
    var $widget = $(this),
      $button = $widget.find('button'),
      $checkbox = $widget.find('input:checkbox'),
      color = $button.data('color'),
      settings = {
        on: {
          icon: 'glyphicon glyphicon-check'
        },
        off: {
          icon: 'glyphicon glyphicon-unchecked'
        }
      };

    // Event Handlers
    $button.on('click', function () {
      $checkbox.prop('checked', !$checkbox.is(':checked'));
      $checkbox.triggerHandler('change');
      updateDisplay();
    });
    $checkbox.on('change', function () {
      updateDisplay();
    });

    // Actions
    function updateDisplay() {
      var isChecked = $checkbox.is(':checked');

      // Set the button's state
      $button.data('state', (isChecked) ? "on" : "off");

      // Set the button's icon
      $button.find('.state-icon')
        .removeClass()
        .addClass('state-icon ' + settings[$button.data('state')].icon);

      // Update the button's color
      if (isChecked) {
        $button
          .removeClass('btn-default')
          .addClass('btn-' + color + ' active');
        statuses[$button.attr('id')] = true;
      }
      else {
        $button
          .removeClass('btn-' + color + ' active')
          .addClass('btn-default');
        statuses[$button.attr('id')] = false;
      }
      updateCheckboxContents();
    }

    function updateCheckboxContents() {
      var has_check = false;
      for (status in statuses) {
        if (statuses[status]) {
          has_check = true;
          break;
        }
      }
      $('.checkbox-content').each(function() {
        var $content = $(this);
        var status = $content.data('status');
        if (!has_check || (status in statuses && statuses[status])) {
          $content.show();
        } else {
          $content.hide();
        }
      })
    }

    // Initialization
    function init() {

      updateDisplay();

      // Inject the icon if applicable
      if ($button.find('.state-icon').length == 0) {
        $button.prepend('<i class="state-icon ' + settings[$button.data('state')].icon + '"></i> ');
      }
    }
    init();
  });
};

$(window).ready(ready);
$(document).on('page:load', ready);
