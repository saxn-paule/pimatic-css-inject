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
				console.log(css)

				if css and css.length > 2
					cssObj = JSON.parse(css)

					for key of cssObj
						selector = key.split("|_|_|")[0].replace(/"/g, "")
						attribute = key.split("|_|_|")[1].replace(/"/g, "")
						val = cssObj[key][0].replace(/"/g, "")

						newStyle = selector + " { " + attribute + ": " + val + "; }"

						style = document.createElement('style')
						style.type = 'text/css'

						if style.styleSheet
								style.styleSheet.cssText = newStyle
						else
							style.appendChild document.createTextNode(newStyle)

						#remove old injected style
						oldStyle = "style:contains('" + selector + "'):contains('" + attribute + "')"
						$(oldStyle).remove()

						document.getElementsByTagName('head')[0].appendChild(style)

			updateCss(@getAttribute('css').value())

			@getAttribute('css').value.subscribe(updateCss)

			return
			
	# register the item-class
	pimatic.templateClasses['cssInject'] = cssInjectDeviceItem
)