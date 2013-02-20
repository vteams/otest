# Inline form handling inside Chosen list
class window.InlineForms

  constructor: (@dropdownId) ->
    # our dropdown and formcontainer to retrieve form html
    @dropdown = jQuery("##{@dropdownId}")
    @formContainerId = @dropdown.attr("data-form-container")
    @resource = @formContainerId.split("_")[0]
    # clients|items|taxes|terms
    # chosen elements
    @chznContainerWidth = @dropdown.attr("data-dropdown-width")
    @chznContainer = jQuery("##{@dropdownId}_chzn")
    @chznDrop = @chznContainer.find(".chzn-drop")
    @chznResults = @chznContainer.find(".chzn-results")
    @chznSearchBox = @chznContainer.find(".chzn-drop .chzn-search input[type=text]")
    @addNewRecordButton = @chznContainer.find(".add-new")
    @inlineFormContainer = null
    # will be set later in showForm method below
    @chznContainerOriginalWidth = parseInt(@chznContainer.css("width"), 10)
    # trigger these event from .js.erb file when record is saved
    @dropdown.on "inlineform:save", (e, new_record) =>
      @dropdown.append(new_record).trigger("liszt:updated")
      @hideForm()
    # trigger these event from .js.erb file when use press "save & add more"
    @dropdown.on "inlineform:save_and_add_more", (e, new_record) =>
      @dropdown.append(new_record).trigger("liszt:updated")
      @showForm()

  showForm: ->
    # code to show form
    @addFormToList()
    # hide chosen list
    @chznResults.hide()
    # hide add new button
    @addNewRecordButton.hide()
    # ajust chosen list width to fit the form
    @adjustChosenWidth()
    # Show form
    @inlineFormContainer.show()
    # bind the hideForm to form's close button
    @chznContainer.find(".close_btn").live "click", (e) =>
      @hideForm()
      @revertChosenWidth()
    # setup 'save' and 'save & add more' actions
    @setupSaveActions()

    # listen to dropdown hiding event to revert width ajustments back to original
    @dropdown.unbind "liszt:hiding_dropdown liszt:showing_dropdown"
    @dropdown.on "liszt:hiding_dropdown liszt:showing_dropdown", =>
      @hideForm()
      @revertChosenWidth()

  hideForm: =>
    console.log "hiding form... #{@formContainerId}"
    @inlineFormContainer.removeClass("active-form").hide()
    @chznResults.show()
    @addNewRecordButton.show()

  addFormToList: =>
    # clone the form from DOM and append in chozen list and set the inlineForm
    @inlineFormContainer = jQuery(jQuery("##{@formContainerId}").clone().wrap('<p>').parent().html())
    @inlineFormContainer.addClass("active-form")
    @chznContainer.find("##{@formContainerId}").remove()
    @chznResults.after(@inlineFormContainer)

  setupSaveActions: =>
    @chznContainer.find(".btn_large").live "click", =>
      # serialize the inputs in tiny create form
      form_data = @chznContainer.find(".tiny_create_form :input").serialize()
      console.log "form data: #{form_data}"
      jQuery.ajax "/#{@resource}/create",
        type: 'POST'
        data: form_data
        dataType: 'html'
        success: (data, textStatus, jqXHR) =>
          data = JSON.parse(data)
          @dropdown.trigger(data["action"], data["record"])
        error: (jqXHR, textStatus, errorThrown) =>
          alert "Error: #{textStatus}"

  adjustChosenWidth: =>
    console.log "adjusting chosen width"
    if @chznContainerWidth?
      @chznContainer.css width: "#{@chznContainerWidth}px", position: "absolute", "z-index": 9999
      @chznDrop.css width: "#{@chznContainerWidth - 2}px"
      @chznSearchBox.css width: "#{@chznContainerWidth - 30}px"
    else
      console.log "no need to adjust width"

  revertChosenWidth: =>
    console.log "reverting chosen width..."
    if @chznContainerWidth?
      @chznContainer.css width: "#{@chznContainerOriginalWidth}px", position: "relative", "z-index": ""
      @chznDrop.css width: "#{@chznContainerOriginalWidth - 2}px"
      @chznSearchBox.css width: "#{@chznContainerOriginalWidth - 30}px"
    else
      console.log "no need to revert width"

  validateForm: =>
    valid_form = true
    # fetch all required inputs with empty value
    @chznContainer.find(".tiny_create_form input[required,value=]").each =>
      console.log "#{thid.id} is required"
      jQuery(this).qtip({content:
        text: "This field is require",
        show:
          event: false, hide:
            event: false})
      valid_form = false
    valid_form