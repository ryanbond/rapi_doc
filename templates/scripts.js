/**
 * created by: salilwadnerkar
 * Date: 11/4/12
 */
$(function () {
    $('#resource_index input').keyup(function(event) {
        if ( event.keyCode == 13 ) {
            event.preventDefault();
        } else {
            var search_txt = $(this).val();
            var search_regex = new RegExp(search_txt, 'g');
            $("#resource_index ul li").each ( function() {
                var elem = $(this)
                var h_elem = elem.find('a')[0];
                var link_txt = h_elem.text;
                var match = link_txt.match(search_regex);
                match ? elem.show() : elem.hide();
            });
        }
    });
});

