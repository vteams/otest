jQuery(".alert").hide()
<%if params[:item_ids].blank? %>
 <%
  if @action == "recovered from archived" or @action == "recovered from deleted"
    no_msg = "Recover"
  else
    no_msg = "delete/archive"
  end
%>
jQuery(".alert.alert-error").show().find('span').html("You haven't selected any item to <%= no_msg%>. Please select one or more items and try again.");
<% elsif @action == "archived" or @action == "deleted" %>
jQuery(".alert.alert-success").show().find('span').html("<%= escape_javascript @message %>");
<% else %>
jQuery(".alert.alert-success").show().find('span').html("Item(s) are <%= @action %> successfully");
<% end %>
<% unless params[:item_ids].blank? %>
jQuery('tbody#item_body').html('<%= escape_javascript render("items") %>');
<% end %>
jQuery('#active_links').html('<%= escape_javascript render("filter_links") %>');
jQuery('#active_links a').removeClass('active');
<% if @action == "recovered from archived"%>
jQuery('.get_archived').addClass('active');
<% elsif @action == "recovered from deleted" %>
jQuery('.get_deleted').addClass('active');
<%else%>
jQuery('.get_actives').addClass('active');
<%end%>
jQuery('#select_all').attr('checked',false);