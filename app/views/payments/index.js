jQuery('tbody#payment_body').html('<%= escape_javascript render("payment") %>');
jQuery('.paginator').html('<%= escape_javascript(paginate(@payments, :remote => true).to_s) %>' +
    '<div class="paging_info"><%= page_entries_info @payments %></div>');