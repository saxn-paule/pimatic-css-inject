module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  M = env.matcher
  t = env.require('decl-api').types
  cssObj = ""
  separator = "|_|_|"

  class CssInjectPlugin extends env.plugins.Plugin

    init: (app, @framework, @config) =>

      deviceConfigDef = require("./device-config-schema")
      @framework.deviceManager.registerDeviceClass("CssInjectDevice",{
        configDef : deviceConfigDef.CssInjectDevice,
        createCallback : (config) => new CssInjectDevice(config,this)
      })

      @framework.ruleManager.addActionProvider(new InjectCssActionProvider(@framework))

      @framework.on "after init", =>
        mobileFrontend = @framework.pluginManager.getPlugin 'mobile-frontend'
        if mobileFrontend?
          mobileFrontend.registerAssetFile 'js', "pimatic-css-inject/app/css-inject-page.coffee"
          mobileFrontend.registerAssetFile 'html', "pimatic-css-inject/app/css-inject-template.html"
          mobileFrontend.registerAssetFile 'css', "pimatic-css-inject/app/css/css-inject.css"

        return

  class CssInjectDevice extends env.devices.Device
    template: 'cssInject'

    attributes:
      css:
        description: 'the CSS attribute'
        type: t.string

    constructor: (config, plugin) ->
      super(config.id, config.name)
      @config = config
      @css = ""

      @reLoadCss()

      @timerId = setInterval ( =>
        @reLoadCss()
      ), 2000

    getCss: -> Promise.resolve(@css)

    setCss: (value) ->
      if @css is value then return
      @css = value
      @emit 'css', value

    reLoadCss: ->
      @setCss(cssObj)

    destroy: () ->
      if @timerId?
        clearInterval @timerId
        @timerId = null
      super()

  ####### ACTION PROVIDER #######
  class InjectCssActionProvider extends env.actions.ActionProvider
    constructor: (framework) ->
      super()

    parseAction: (input, context) =>

      value = null
      attribute = null
      selector = null
      match = null

      # Match action
      # set css "attribute" of "selector" to "value"
      m = M(input, context)
        .match('set ')
        .match('css ', optional: yes)
        .matchStringWithVars((m, _attribute) ->
          m.match(' of ')
            .matchStringWithVars((m, _selector) ->
              m.match(' to ')
                .matchStringWithVars((m, _value) ->
                  value = _value
                  selector = _selector
                  attribute = _attribute
                  match = m.getFullMatch()
                )
            )
        )

      # Does the action match with our syntax?
      if match?
        assert value?
        assert attribute?
        assert selector?
        assert typeof match is 'string'
        return {
          token: match
          nextInput: input.substring match.length
          actionHandler: new InjectCssActionHandler @framework, value, attribute, selector
        }
      return null

  ####### ACTION HANDLER ######
  class InjectCssActionHandler extends env.actions.ActionHandler
    constructor: (framework, value, attribute, selector) ->
      super()
      @framework = framework
      @value = value
      @attribute = attribute
      @selector = selector

    executeAction: (simulate) =>
      return (
        if cssObj.length is 0
          cssObj = "{}"

        tempObj = JSON.parse(cssObj)

        key = @selector + separator + @attribute
        tempObj[key] = @value

        cssObj = JSON.stringify(tempObj)

        Promise.resolve __('added CSS ' + @attribute + ': ' + @value + ' to ' + @selector)
      )

  return new CssInjectPlugin