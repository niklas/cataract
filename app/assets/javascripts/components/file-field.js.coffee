Cataract.FileFieldComponent = Ember.Component.extend
  tagName: 'input'
  attributeBindings: ['type', 'id']
  type: 'file'

  change: (event)->
    reader = new FileReader()
    reader.onload = (upload)=>
      @set('file', upload.target.result)
    first = event.target.files[0]
    @set('filename', first.name)
    reader.readAsDataURL(first)

