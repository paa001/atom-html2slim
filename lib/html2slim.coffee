{CompositeDisposable} = require 'atom'
path = require('path')
exec = require('child_process').exec

module.exports = Html2slim =
  subscriptions: null
  whitelist: ['.html', '.erb']
  config:
    executePath:
      type: 'string'
      default: 'erb2slim'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'html2slim:convert': => @convert()

  deactivate: ->
    @subscriptions.dispose()

  convert: ->
    editor = atom.workspace.getActivePaneItem()
    filePath = editor.buffer.file.path

    sourceFileObj = path.parse(filePath)
    resultFile = "#{sourceFileObj.dir}/#{sourceFileObj.name}.slim"

    unless (sourceFileObj.ext in @whitelist)
      atom.notifications.addError("Converting only #{@whitelist} files")
      return

    execCommand = atom.config.get('html2slim.executePath')
    exec "#{execCommand} #{filePath} #{resultFile}", (error, stdout, stderr) ->
      if stderr
        atom.notifications.addError(stderr)
        exec "rm #{resultFile}", {}
        return

      atom.notifications.addInfo(stdout) if stdout
      atom.workspace.open(resultFile)
