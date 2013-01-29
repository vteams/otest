jQuery(".alert").hide()
<%if params[:client_ids].blank? %>
jQuery(".alert.alert-error").show().find('span').html("No client is selected.");
<% else %>
jQuery(".alert.alert-success").show().find('span').html("Client(s) are <%= @action %> successfully");
<% end %>
jQuery('tbody#client_body').html('<%= escape_javascript render("clients") %>');
jQuery('#active_links').html('<%= escape_javascript render("filter_links") %>');
jQuery('#select_all').attr('checked',false);
