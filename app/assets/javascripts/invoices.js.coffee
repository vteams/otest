# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.applyChosen = (single_row) =>
  # listen to Chosen liszt:ready even
  # add a Add New button at the bottom of every chosen list
  jQuery(".invoices-main .chzn-select").on "liszt:ready", ->
    chzn_drop = jQuery(this).next().find(".chzn-drop")
    unless chzn_drop.find("div.add-new").length > 0
      chzn_drop.append("<div data-dropdown-id='#{this.id}' class='add-new'>Add New</div>")

  # apply chosen on dropdown lists
  # trigger the "liszt:ready" manually so that we can add Add New button to list. See above
  dropdowns = unless single_row? then jQuery(".chzn-select") else jQuery(single_row)
  dropdowns.chosen({allow_single_deselect: true}).trigger("liszt:ready", this)

  # Add New click handler to show form inside the list
  jQuery(".add-new").live "click", ->
    new InlineForms(jQuery(this).attr("data-dropdown-id")).showForm()


jQuery ->

  window.applyChosen()
  # setup talbesorter parser for amount columns with currency and ',' signs
  jQuery.tablesorter.addParser
    id: "thousands"
    is: (s) ->
      sp = s.replace(/,/, ".")
      /([£$€] ?\d+\.?\d*|\d+\.?\d* ?)/.test(sp) #check currency with symbol
    format: (s) ->
      jQuery.tablesorter.formatFloat s.replace(new RegExp(/[^\d\.]/g), "")
    type: "numeric"

  # Apply sorting on listing tables
  jQuery("table.table_listing").tablesorter
    widgets: ['staticRow']
    sortList: [[1,1]]

# Calculate the line total for invoice
  updateLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    cost = jQuery(container).find("input.cost").val()
    qty = jQuery(container).find("input.qty").val()
    cost = 0 if not cost? or cost is "" or not jQuery.isNumeric(cost)
    qty = 0 if not qty? or qty is "" or not jQuery.isNumeric(qty)
    line_total = ((parseFloat(cost) * parseFloat(qty))).toFixed(2)
    jQuery(container).find(".line_total").text(line_total)

  # Calculate grand total from line totals
  updateInvoiceTotal = ->
    total = 0
    tax_amount = 0
    discount_amount = 0
    jQuery("table.invoice_grid_fields tr:visible .line_total").each ->
      line_total = parseFloat(jQuery(this).text())
      total += line_total
      jQuery("#invoice_sub_total").val(total.toFixed(2))
      jQuery("#invoice_sub_total_lbl").text(total.toFixed(2))
      jQuery("#invoice_invoice_total").val(total.toFixed(2))
      jQuery("#invoice_total_lbl").text(total.toFixed(2))
      tax_amount += applyTax(line_total,jQuery(this))
    discount_amount = applyDiscount(total)
    jQuery("#invoice_tax_amount_lbl").text(tax_amount.toFixed(2))
    jQuery("#invoice_tax_amount").val(tax_amount.toFixed(2))
    jQuery("#invoice_discount_amount_lbl").text((discount_amount * -1).toFixed(2))
    jQuery("span.discount_percentage_lbl").text(jQuery("#invoice_discount_percentage").val())
    jQuery("#invoice_discount_amount").val((discount_amount * -1).toFixed(2))
    total_balance = (parseFloat(jQuery("#invoice_total_lbl").text() - discount_amount) + tax_amount)
    jQuery("#invoice_invoice_total").val(total_balance.toFixed(2))
    jQuery("#invoice_total_lbl").text(total_balance.toFixed(2))
    jQuery("#invoice_total_lbl").formatCurrency()

  # Apply Tax on totals
  applyTax = (line_total,elem) ->
    tax1 = elem.parents("tr").find("select.tax1 option:selected").attr('data-tax_1')
    tax2 = elem.parents("tr").find("select.tax2 option:selected").attr('data-tax_2')
    tax1 = 0 if not tax1? or tax1 is ""
    tax2 = 0 if not tax2? or tax2 is ""
    discount_amount = applyDiscount(line_total)
    total_tax = (parseFloat(tax1) + parseFloat(tax2))
    ((line_total - discount_amount) * (parseFloat(total_tax) / 100))

  # Apply discount percentage on subtotals
  applyDiscount = (subtotal) ->
    discount_percentage = jQuery("#invoice_discount_percentage").val()
    discount_percentage = 0 if not discount_percentage? or discount_percentage is ""
    (subtotal * (parseFloat(discount_percentage)/100))

  # update taxes rows in invoice total section
#  updateIndividualTaxes = (tax_dropdown) ->
#    # get tax amount and tax name from tax dropdown
#    tax = tax_dropdown.find('option:selected')
#    tax_name = tax.text()
#    tax_percentage = if tax.parents('select').hasClass('tax1') then tax.attr('data-tax_1') else tax.attr('data-tax_2')
#    line_total = parseFloat(tax_dropdown.parents('tr.fields').find('.line_total').text())
#    removeTaxRow(tax_name)
#    getTaxRow(tax_name,tax_percentage,line_total)

  # Remove tax row if it is not applied on any item.
#  removeTaxRow = (tax_name) ->
#    jQuery("#tax_totals .tax_amount").each ->
#      tax_name = jQuery(this).attr 'data-name'
#      found = false
#      jQuery("table.invoice_grid_fields tr.fields:visible").each ->
#        tax1 = jQuery(this).find("select.tax1 option:selected").text()
#        tax2 = jQuery(this).find("select.tax2 option:selected").text()
#        if tax1 is tax_name or tax2 is tax_name
#          found = true
#          false
#      #console.log "#{tax_name}: #{found}"
#      if found is false
#        jQuery("#tax_totals #tax_#{tax_name}").remove()
        #console.log "#{tax_name} is removed."

  # Individual taxes row
#  getTaxRow = (tax_name,tax_percentage,line_total) ->
#    discount_amount = applyDiscount(line_total)
#    tax_amount = ((line_total - discount_amount) * (parseFloat(tax_percentage) / 100))
#    #console.log "Line total: #{line_total}, Disount: #{discount_amount}, Tax: #{tax_amount}"
#    # Create and append selected tax row to invoice total section.
#    unless jQuery("#tax_totals #tax_#{tax_name}").length or tax_name is ""
#      tax_row = "<div class='grid_summary_row' id='tax_#{tax_name}'><div class='grid_summary_title'>
#      #{tax_name} <span class='tax_percentage_lbl'>#{tax_percentage}</span>%
#      </div>
#      <div class='grid_summary_description'>
#      <label id = 'tax_#{tax_name}_amount' class='tax_amount' data-name='#{tax_name}'>#{tax_amount}</label>
#      </div></div>"
#      jQuery('#tax_totals').append(tax_row)
#      console.log "#{tax_name} added"
#    else
#      # if tax row already exists change its value accordinly
#      existing_tax = parseFloat(jQuery("#tax_totals #tax_#{tax_name}_amount").text()) + tax_amount
#      #console.log "Existing: #{existing_tax}, tax_amount: #{tax_amount}"
#      unless tax_name is ""
#        jQuery("#tax_totals #tax_#{tax_name}_amount").text(existing_tax)
#        console.log "#{tax_name} updated, Amount: #{existing_tax}"

  # Update line and grand total if line item fields are changed
  jQuery("input.cost, input.qty").live "blur", ->
     updateLineTotal(jQuery(this))
     updateInvoiceTotal()

  jQuery("input.cost, input.qty").live "keyup", ->
     updateLineTotal(jQuery(this))
     updateInvoiceTotal()
     #jQuery(this).popover "hide"

  # Update line and grand total when tax is selected from dropdown
  jQuery("select.tax1, select.tax2").live "change", ->
     #updateIndividualTaxes(jQuery(this))
     updateInvoiceTotal()

  # Prevent form submission if enter key is press in cost,quantity or tax inputs.
  jQuery("input.cost, input.qty").live "keypress", (e) ->
     if e.which is 13
       e.preventDefault()
       false

  # Load Items data when an item is selected from dropdown list
  jQuery(".invoice_grid_fields select.items_list").live "change", ->
     # Add an empty line item row at the end if last item is changed.
     elem = jQuery(this)
     if elem.val() is ""
       clearLineTotal(elem)
       false
     else
       addLineItemRow(elem)
       jQuery.ajax '/items/load_item_data',
         type: 'POST'
         data: "id=" + jQuery(this).val()
         dataType: 'html'
         error: (jqXHR, textStatus, errorThrown) ->
          alert "Error: #{textStatus}"
         success: (data, textStatus, jqXHR) ->
          item = JSON.parse(data)
          container = elem.parents("tr.fields")
          # populate item's discription, cost, quantity and taxes.
          container.find("input.description").val(item[0])
          container.find("input.cost").val(item[1].toFixed(2))
          container.find("input.qty").val(item[2])
          container.find("select.tax1,select.tax2").val('').trigger("liszt:updated")
          container.find("select.tax1").val(item[3]).trigger("liszt:updated") if item[3] isnt 0
          container.find("select.tax2").val(item[4]).trigger("liszt:updated") if item[4] isnt 0
          updateLineTotal(elem)
          updateInvoiceTotal()
          #jQuery("table.invoice_grid_fields tr.fields:visible").each ->
          #updateIndividualTaxes(container.find("select.tax1"))
          #updateIndividualTaxes(container.find("select.tax2"))

  # Add empty line item row
  addLineItemRow = (elem) ->
   if elem.parents('tr.fields').next('tr.fields:visible').length is 0
    jQuery(".add_nested_fields").click()
    applyChosen(jQuery('.invoice_grid_fields tr.fields:last .chzn-select'))

  jQuery(".add_nested_fields").live "click", ->
    setTimeout "applyChosen(jQuery('.invoice_grid_fields tr.fields:last .chzn-select'))", 0

 # Re calculate the total invoice balance if an item is removed
  jQuery(".remove_nested_fields").live "click", ->
    setTimeout (->
     updateInvoiceTotal()
    ), 100

  # Subtract discount percentage from subtotal
  jQuery("#invoice_discount_percentage").blur ->
     updateInvoiceTotal()

  # Don't allow nagetive value for discount
  jQuery("#invoice_discount_percentage,.qty").keydown (e) ->
     if e.keyCode is 109 or e.keyCode is 13
       e.preventDefault()
       false

  # Don't allow paste and right click in discount field
  jQuery("#invoice_discount_percentage,.qty").bind "paste contextmenu", (e) ->
     e.preventDefault()

  # Add date picker to invoice date field
  jQuery("#invoice_invoice_date, #invoice_due_date").datepicker
    dateFormat: 'yy-mm-dd'
    beforeShow: (input, inst) ->
     widget = jQuery(inst).datepicker('widget');
     widget.css('margin-left', jQuery(input).outerWidth() - widget.outerWidth());
  # Add date picker to payment date field
  jQuery(".date_picker_class").datepicker
    dateFormat: 'yy-mm-dd'
  # Makes the invoice line item list sortable
  jQuery("#invoice_grid_fields tbody").sortable
    handle: ".sort_icon"
    items: "tr.fields"
    axis: "y"

  # Calculate line total and invoice total on page load
  jQuery(".invoice_grid_fields tr:visible .line_total").each ->
    updateLineTotal(jQuery(this))
  updateInvoiceTotal()

  # Validate client, cost and quantity on invoice save
  jQuery("form.form-horizontal").submit ->
    item_rows = jQuery("table#invoice_grid_fields tr.fields:visible")
    flag = true
    # Check if client is selected
    if jQuery("#invoice_client_id").val() is ""
      applyPopover(jQuery("#invoice_client_id_chzn"),"bottomMiddle","topLeft","Select a client")
      flag = false
    # check if invoice date is selected
    else if jQuery("#invoice_invoice_date").val() is ""
      applyPopover(jQuery("#invoice_invoice_date"),"rightTop","leftMiddle","Select invoice date")
      flag =false
    # Check if item is selected
    else if item_rows.find("select.items_list option:selected[value='']").length is item_rows.length
      first_item = jQuery("table#invoice_grid_fields tr.fields:visible:first").find("select.items_list").next()
      applyPopover(first_item,"bottomMiddle","topLeft","Select an item")
      flag = false

    # Item cost and quantity should be greater then 0
    else
      jQuery("tr.fields:visible").each ->
        row = jQuery(this)
        if row.find("select.items_list").val() isnt ""
          cost = row.find(".cost")
          qty =  row.find(".qty")
          tax1 = row.find("select.tax1")
          tax2 = row.find("select.tax2")
          tax1_value = jQuery("option:selected",tax1).val()
          tax2_value = jQuery("option:selected",tax2).val()

          if cost.val() is ""
            applyPopover(cost,"bottomMiddle","topLeft","Enter item cost")
          else if cost.val() <= 0
            applyPopover(cost,"bottomLeft","topLeft","Unit cost should be greater then 0")
          else if not jQuery.isNumeric(cost.val())
            applyPopover(cost,"bottomLeft","topLeft","Enter valid Item cost")
          else hidePopover(cost)

          if qty.val() is ""
            applyPopover(qty,"bottomMiddle","topLeft","Enter item quantity")
          else if qty.val() <= 0
            applyPopover(qty,"bottomLeft","topLeft","Quantity should be greater then 0")
          else if not jQuery.isNumeric(qty.val())
            applyPopover(qty,"bottomLeft","topLeft","Enter valid Item quantity")
          else if (tax1_value is tax2_value) and (tax1_value isnt "" and tax2_value isnt "")
            applyPopover(tax2.next(),"bottomLeft","topLeft","Tax1 and Tax2 should be different")
            flag = false
          else hidePopover(qty)
          if cost.val() is "" or cost.val() <= 0 or not jQuery.isNumeric(cost.val()) or qty.val() is "" or qty.val() <= 0 or not jQuery.isNumeric(qty.val()) then flag = false
    flag

  applyPopover = (elem,position,corner,message) ->
    elem.qtip
      content:
        text: message
      show:
        event: false
      hide:
        event: false
      position:
        at: position
      style:
        tip:
          corner: corner
    elem.qtip().show()
    elem.focus()

  useAsTemplatePopover = (elem,id,client_name) ->
    elem.qtip
      content:
        text: "<a href='/invoices/new/#{id}'>To create new invoice use the last invoice send to '#{client_name}'.</a><span class='close_qtip'>x</span>"
      show:
        event: false
      hide:
        event: false
      position:
        at: "topMiddle"
      style:
        classes: 'use_as_template'
        tip:
          corner: "bottomLeft"
    elem.qtip().show()
    elem.focus()

  hidePopover = (elem) ->
    #elem.next(".popover").hide()
    elem.qtip("hide")

  # Hide use as template qtip
  jQuery('.use_as_template .close_qtip').live "click", ->
    hidePopover(jQuery("#invoice_client_id_chzn"))

  jQuery("#invoice_client_id_chzn,.chzn-container").live "click", ->
    jQuery(this).qtip("hide")

  # Don't send an ajax request if an item is deselected.
  clearLineTotal = (elem) ->
    container = elem.parents("tr.fields")
    container.find("input.description").val('')
    container.find("input.cost").val('')
    container.find("input.qty").val('')
    container.find("select.tax1,select.tax2").val('').trigger("liszt:updated")
    updateLineTotal(elem)
    updateInvoiceTotal()

  # Check all checkboxes using from main checkbox
  jQuery('#select_all').live "click", ->
    listing_table =  jQuery(this).parents('table.table_listing')
    selected = if @checked then "selected" else ""
    listing_table.find(':checkbox').attr('checked', @checked).parents('tr').removeClass('selected').addClass(selected)

  jQuery(".alert button.close").click ->
    jQuery(this).parent(".alert").hide()


 # Check/uncheck all invoice listing checkboxes using from main checkbox
  jQuery('#main-invoice-checkbox').live "click", ->
     jQuery(this).parents('table.table-striped').find(':checkbox').attr('checked', this.checked)

 # Check/uncheck main checkbox if all checkboxes are checked
  jQuery('table.table_listing tbody :checkbox').live "click", ->
     jQuery(this).parents('tr').toggleClass('selected')
     status = unless jQuery('table.table_listing tbody input[type=checkbox]:not(:checked)').length then true else false
     jQuery('#select_all').attr('checked', status)


  jQuery('#active_links a').live 'click', ->
     jQuery('#active_links a').removeClass('active')
     jQuery(this).addClass('active')

  jQuery(".invoice_action_links input[type=submit]").click ->
    jQuery(this).parents("FORM:eq(0)").find("table.table_listing").find(':checkbox').attr()

  # Load last invoice for client if any
  jQuery("#invoice_client_id").change ->
    client_id = jQuery(this).val()
    hidePopover(jQuery("#invoice_client_id_chzn")) if client_id is ""
    jQuery("#last_invoice").hide()
    if not client_id? or client_id isnt ""
      jQuery.ajax '/clients/get_last_invoice',
      type: 'POST'
      data: "id=" + client_id
      dataType: 'html'
      error: (jqXHR, textStatus, errorThrown) ->
        alert "Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        data = JSON.parse(data)
        id = jQuery.trim(data[0])
        client_name = data[1]
        unless id is "no invoice"
          useAsTemplatePopover(jQuery("#invoice_client_id_chzn"),id,client_name)
        else
          hidePopover(jQuery(".hint_text:eq(0)"))

  # tool tip on links not implemented yet
  jQuery(".no_links").attr("title", "This feature is not implemented yet.").qtip
    position:
      at: "bottomCenter"

  # tool tip on invoice statuses
  jQuery(".sent, .draft, .partial, .draft-partial, .paid, .disputed, .viewed, .remove_item, .sort_icon").qtip
    position:
      at: "bottomCenter"

 # Autofill due date
  jQuery("#invoice_payment_terms_id").change ->
    number_of_days = jQuery("option:selected",this).attr('number_of_days')
    setDuedate(jQuery("#invoice_invoice_date").val(),number_of_days)

  # calculate invoice due date
  setDuedate = (invoice_date,term_days) ->
    if term_days? and invoice_date?
      invoice_due_date = new Date(invoice_date);
      invoice_due_date.setDate(invoice_due_date.getDate() + parseInt(term_days));
      jQuery("#invoice_due_date").val(formated_date(invoice_due_date))
    else
      jQuery("#invoice_due_date").val("")

  # re calculate invoice due date on invoice date change
  jQuery("#invoice_invoice_date").change ->
    jQuery(this).qtip("hide") if jQuery(this).qtip()
    term_days = jQuery("#invoice_payment_terms_id option:selected").attr('number_of_days')
    setDuedate(jQuery(this).val(),term_days)

 # Date formating function
  formated_date = (elem) ->
   separator = "-"
   new_date  = elem.getFullYear()
   new_date += separator + ("0" + (elem.getMonth() + 1)).slice(-2)
   new_date += separator + ("0" + elem.getDate()).slice(-2)

  # Hide placeholder text on focus
  jQuery("input[type=text],input[type=number]",".quick_create_wrapper").live("focus",->
    @dataPlaceholder = @placeholder
    @removeAttribute "placeholder"
  ).live("blur", ->
    @placeholder = @dataPlaceholder
    @removeAttribute "dataPlaceholder"
  ).live "keypress", ->
    hidePopover(jQuery(this))

  # Show quick create popups under create buttons
  jQuery(".quick_create").click ->
    pos = $(this).position()
    height = $(this).outerHeight()
    jQuery('.quick_create_wrapper').hide()
    jQuery("##{jQuery(this).attr('name')}").css(
      position: "absolute"
      top: (pos.top + height) + "px"
      left: pos.left + "px"
    ).show()

  jQuery(".close_btn").live "click", ->
    jQuery(this).parents('.quick_create_wrapper').hide().find("input").qtip("hide")

  # Alert on no record selection and confirm to delete forever payment
  jQuery(".top_links").live "click", ->
    title = jQuery(this).parents("ul").attr "value"
    title = title.toLowerCase()
    action = jQuery(this).val().toLowerCase()
    flag = true
    if jQuery("table.table_listing tbody").find(":checked").length is 0
       jQuery('.alert').hide();
       jQuery(".alert.alert-error").show().find("span").html "You haven't selected any #{title} to #{action}. Please select one or more #{title}s and try again."
       flag = false
    else if title is "payment" and action is "delete forever"
         flag = confirm("Are you sure you want to delete these payment(s)?")
    else if title is "invoice" and action is "send"
         flag = confirm("Are you sure you want to send selected invoice(s)?")
    flag
  # Alert on dispute if invoice is paid
  jQuery('#dispute_link').click ->
    flag = true
    status = jQuery(this).attr "value"
    if status is "paid"
           alert "Paid invoice can not be disputed."
           flag = false
    flag
