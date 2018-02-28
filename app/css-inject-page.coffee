$(document).on( "templateinit", (event) ->
# define the item class
	class cssInjectDeviceItem extends pimatic.DeviceItem
		constructor: (templData, @device) ->
			@id = @device.id
			super(templData,@device)

		afterRender: (elements) ->
			super(elements)

			updateCss = (css) =>
				console.log("updating CSS....")
				if css and css.length > 0
					cssObj = JSON.parse(css)
					attribute = cssObj.attribute[0].replace(/"/g, "")
					val = cssObj.val[0].replace(/"/g, "")
					selector = cssObj.selector[0].replace(/"/g, "")

					$(selector).css(attribute, val)

			updateCss(@getAttribute('css').value())

			@getAttribute('css').value.subscribe(updateCss)

			return
			
	# register the item-class
	pimatic.templateClasses['cssInject'] = cssInjectDeviceItem
)