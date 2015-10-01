 var setupPictureUpload = function() {
  $(".picture-upload-btn").click(function() {
    $(".picture-file-field").click();
  });

  $(".picture-file-field").change(function(){
    previewImage($(this));
  });
};

var previewImage = function(input) {
  var files = input.prop('files');
  if (files && files[0]) {
    var reader = new FileReader();
    reader.onload = function (e) {
      $('.picture-preview').attr('src', e.target.result);
    };
    reader.readAsDataURL(files[0]);
  }
};

var setupCollapseTab = function() {
  $('.nav-tabs [data-toggle="collapse"]').on('click', function () {
    if ($($(this).attr('href')).hasClass('in')) return false;
    //make collapse links act like tabs
    $(this).parent().addClass('active').siblings('li').removeClass('active');
  });

  $('.nav-tabs > li > a').on('click', function () {
    $(this).parent().siblings('.collapse.in').collapse('hide')
           .find('.active').removeClass('active');
  });

  // $('.subnavtab').on('click', function() {
  //   var tab_id = $(this).data('toggle-dest');
  //   var tab_pane = $('#' + tab_id);
  //   tab_pane.siblings('.tab-pane').removeClass('active in');
  //   tab_pane.addClass('active in');
  // });
};

var setupPictureCaptionSlide = function() {
  $('.controller-experts .thumbnail').hover( function() {
    $(this).find('.caption').slideDown(250); //.fadeIn(250)
  }, function() {
    $(this).find('.caption').slideUp(250); //.fadeOut(205)
  });
};

ready = function () {
  setupPictureUpload();

  setupCollapseTab();

  setupPictureCaptionSlide();
};

$(window).ready(ready);
$(document).on('page:load', ready);
