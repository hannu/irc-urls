  /* Pretty dates */
  $(".timestamp").prettyDate();

  setInterval(function() {
    $(".timestamp").prettyDate();
  }, 5000);

  $(".gridview .occurrence").tooltip({
    delay: 0,
    track: true,
    fade: 100,
    showURL: false, 
    bodyHandler: function() { 
      return $(this).children(".tooltip").html();
    }
  });

  /* Embedded video players */
  $(".embed > a").click(function(e) {
    var url = $(this).parent().children("span.video-url").text() + '&fs=1&rel=0&autoplay=1';
    var obj = $('<object />').attr({
      type: 'application/x-shockwave-flash',
      data: url,
      title: $(this).text(),
      width: 640,
      height: 430,
    }).append($('<param />').attr({
      name: 'movie',
      value: url
    })).append($('<param />').attr({
      name: 'wmode',
      value: 'opaque'
    })).append($('<param />').attr({
      name: 'allowFullScreen',
      value: 'true'
    }));

    var element = $("<div>").addClass("overlay").append(obj).appendTo($("body"));
    element.overlay({
      load: true,
      onLoad: function() {
        function show() { element.find(".close").show(); }
        function hide() { element.find(".close").hide(); }
        // Fix to show close button if mouse cursor is within element on load
        element.one("mousemove", show);
        element.hover(show, hide);
      },
      onClose: function() {
        element.remove();
      }
    });
    e.preventDefault();
    return false;
  });
