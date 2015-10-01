// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require s3_direct_upload
//= require jquery.remotipart
//= require jquery-ui/tabs
//= require jquery-ui/autocomplete
//= require_tree .

function clickTrigger(selector) {
	var divs = $(selector);
	$.each(divs, function(index, d) {
		$("a.expandable-trigger-more", d).click(function(event){
			event.preventDefault();
			$("div.expandable-content-full", d).toggle();
			$("div.expandable-content-summary", d).toggle();
		});
	});
}

$(document).on("page:change", function() {
	clickTrigger("div.expandable");
});

var ready;
ready = function() {
	if($('#home-slider-thumbs').length){
		$('#home-slider-thumbs').flexslider({
			animation: "slide",
			controlNav: false,
			directionNav: false,
			animationLoop: false,
			slideshow: false,
			itemWidth: 80,
			itemMargin: 15,
			asNavFor: '#home-slider-canvas'
		}); 
	}

	// inventory listing slider
	if($('#home-slider-canvas').length){
		$('#home-slider-canvas').flexslider({
			animation: "slide",
			controlNav: false,
			directionNav: true,
			animationLoop: false,
			slideshow: false,
			sync: "#home-slider-thumbs"
		});
	}
	$("#checklisttabs").tabs();
};

$(window).ready(ready);
$(document).on('page:load', ready);

