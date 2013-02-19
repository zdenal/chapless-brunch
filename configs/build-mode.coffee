{basename} = require 'path'
typeof$ = (obj) -> ({}).toString.call(obj).slice(8, -1)

module.exports = (mode, config) ->
  switch mode
    when 'dev' then setDevMode config
    when 'prod' then setProdMode config

# Modify given config so that test files are included
setDevMode = (config) ->
  # Get reference to CSS and JS joinTos
  jsJoinTo = config.files.javascripts.joinTo
  cssJoinTo = config.files.stylesheets.joinTo

  # Add test javascript files
  jsJoinTo['test/javascripts/tests.js'] = /^test[\\/]tests/
  jsJoinTo['test/javascripts/vendor.js'] = /^test[\\/]vendor/
  config.files.javascripts.order.after.push 'test/vendor/scripts/test-helper.js'

  # Add test css files
  cssJoinTo['test/stylesheets/test.css'] = /^test/

  config

# Modify given config so that test files are ignored
setProdMode = (config) ->
  addIgnored config, /^test/
  config

# Add a number of tests to the ignored. Tests can be any of the following:
#   Function: Return true to ignore
#   RegExp:   Match to ignore
#   String:   Equal to ignore
addIgnored = (config, tests...) ->
  config.conventions ?= {}
  {ignored} = config.conventions
  config.conventions.ignored = (file) ->
    for test in tests
      switch typeof$ test
        when 'Function' then return true if test file
        when 'RegExp' then return true if test.test file
        when 'String' then return true if test is file
    switch typeof$ ignored
      when 'Function' then ignored file
      when 'RegExp' then ignored.test file
      else basename(file).indexOf('_') is 0