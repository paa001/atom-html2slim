{CompositeDisposable} = require 'atom'
path = require('path')
exec = require('child_process').exec

module.exports = Html2slim =
  subscriptions: null
  whitelist: ['.html', '.erb']

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
      editor.notificationManager.addError("Converting only #{@whitelist} files")
      return

    exec "erb2slim #{filePath} #{resultFile}", (error, stdout, stderr) ->
      if stderr
        editor.notificationManager.addError(stderr)
        exec "rm #{resultFile}", {}
        return

      editor.notificationManager.addInfo(stdout) if stdout
      atom.workspace.open(resultFile)
