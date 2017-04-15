{CompositeDisposable} = require 'atom'
path = require('path')
exec = require('child_process').exec
temp = require('temp').track()
fs = require('fs')

module.exports = Html2slim =
  subscriptions: null
  whitelist: ['.html', '.erb', '.slim']
  config:
    executePath:
      type: 'string'
      default: 'erb2slim'

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'html2slim:convert': => @convert()
    @subscriptions.add atom.commands.add 'atom-workspace', 'html2slim:convert-selection': => @convertSelection()

  deactivate: ->
    @subscriptions.dispose()

  convertSelection: ->
    editor = atom.workspace.getActivePaneItem()

    filePath = editor.buffer.file.path
    unless (path.parse(filePath).ext in @whitelist)
      atom.notifications.addError("Converting only #{@whitelist} files")
      return

    # Create some temporary files to hold the selected html and the resulting slim
    sourceFile = temp.path({suffix: '.html'})
    resultFile = temp.path({suffix: '.slim'})

    # Populate the source file with the html to be converted
    fs.writeFile(sourceFile, editor.getSelectedText())

    execCommand = atom.config.get('html2slim.executePath')
    exec "#{execCommand} #{sourceFile} #{resultFile}", (error, stdout, stderr) ->
      if stderr
        atom.notifications.addError(stderr)
        return

      if stdout
        atom.notifications.addInfo(stdout)

      editor.insertText(fs.readFileSync(resultFile, 'utf8'))

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
