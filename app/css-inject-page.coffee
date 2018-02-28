$(document).on( "templateinit", (event) ->
# define the item class
	class cssInjectDeviceItem extends pimatic.DeviceItem
		constructor: (templData, @device) ->
			@id = @device.id
			super(templData,@device)

		afterRender: (elements) ->
			super(elements)

			updateCss = (css) =>
				console.log("updateing CSS....")
				cssObj = JSON.parse(css)
				$(cssObj.selector).css(cssObj.attribute, cssObj.value)

			updateCss(@getAttribute('css').value())

			@getAttribute('css').value.subscribe(updateCss)

			return
			
	# register the item-class
	pimatic.templateClasses['cssInject'] = cssInjectDeviceItem
)